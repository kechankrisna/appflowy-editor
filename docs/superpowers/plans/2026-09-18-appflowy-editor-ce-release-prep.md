# AppFlowy Editor → appflowy_editor_ce Release Prep Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans (inline) to run this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking. This plan is a mechanical dependency-upgrade / rename / release-prep job, not new feature work, so verification steps are `flutter analyze` / `flutter test` / `dart pub publish --dry-run` runs rather than new unit tests.

**Goal:** Get this AppFlowy Editor fork onto current Flutter/Dart tooling, rename the package to `appflowy_editor_ce`, and make it publishable to pub.dev as version `6.1.1`.

**Architecture:** No architectural change. This is (1) an SDK/dependency upgrade, (2) a global rename of the package identifier (`appflowy_editor` → `appflowy_editor_ce`) across `pubspec.yaml`, `lib/`, `test/`, and `example/`, and (3) release metadata prep (version bump, changelog, publish dry-run).

**Tech Stack:** Flutter/Dart package, fvm for SDK pinning, `dart pub` / `flutter pub` tooling.

**Spec:** User request (chat, 2026-09-18): "upgrade available package first, then prepare rename suffix by `_ce`, then version for publish to dart pub dev." Follow-up decisions confirmed with the user:
- Bump the 3 major-version-gated deps (`device_info_plus`, `file_picker`, `keyboard_height_plugin`) to latest, fixing breaking API usage.
- Keep `homepage:` pointed at the upstream `https://github.com/AppFlowy-IO/appflowy-editor` repo (no new fork repo yet).
- Publish as version `6.1.1` (patch bump over the last tagged 6.1.0, reflecting fix commits merged since that changelog entry plus this rename/upgrade).

## Global Constraints

- New package name: `appflowy_editor_ce` (pubspec `name:`, every `package:appflowy_editor/...` import, every dependency reference).
- `homepage:` stays `https://github.com/AppFlowy-IO/appflowy-editor` (user's explicit choice — do not invent a new repo URL).
- Target version: `6.1.0` → `6.1.1`.
- SDK floor already bumped in the working tree to `sdk: '>=3.12.0 <4.0.0'` and `.fvmrc` to `3.47.4` — finish wiring these up (fvm setup), don't re-decide them.
- Confirmed available on pub.dev (checked 2026-09-18): `appflowy_editor_ce` name is free (404 on pub.dev).
- Never run the real `dart pub publish` — stop at `--dry-run`. Actual publish is a separate, explicit user-approved step.

---

## Task 1: Bring up Flutter 3.47.4 via fvm and refresh the lockfile

**Files:**
- `.fvmrc` (already modified in working tree to `3.47.4` — no further edit)
- `pubspec.yaml` (already modified in working tree, `sdk: '>=3.12.0 <4.0.0'` — no further edit in this task)

**Why:** `flutter pub upgrade --dry-run` currently fails with "Because appflowy_editor requires SDK version >=3.12.0 <4.0.0, version solving failed" because the active global Flutter is 3.41.9 (Dart 3.11.5), while `.fvmrc` already declares 3.47.4 (Dart 3.13.3). `fvm list` shows 3.47.4 is set as this project's **Local** version but "Need setup" (not yet installed into the fvm cache).

- [ ] **Step 1: Install/set up Flutter 3.47.4 under fvm**

Run: `fvm install 3.47.4` (or `fvm use 3.47.4` from the repo root, which reads `.fvmrc`)
Expected: fvm downloads/caches Flutter 3.47.4 and it shows as both Local and ready in `fvm list`.

- [ ] **Step 2: Get packages with the correct SDK**

Run: `cd /Users/whitehat/coding/mylekha/frontend/mylekha_helper/appflowy-editor && fvm flutter pub get`
Expected: resolves cleanly, no SDK version-solving error.

- [ ] **Step 3: Upgrade within existing constraints**

Run: `fvm flutter pub upgrade`
Expected: picks up in-range upgrades (e.g. `intl_utils` → 2.8.16, `mockito` → 5.8.1) without editing `pubspec.yaml`.

- [ ] **Step 4: Commit the SDK bump**

```bash
git add .fvmrc pubspec.yaml pubspec.lock example/analysis_options.yaml
git commit -m "chore: move to Flutter 3.47.4 / Dart >=3.12.0 and refresh lockfile"
```

(`example/analysis_options.yaml`'s analyzer-exclude block was already added in the working tree as part of this same upgrade prep — include it here since it's config, not a separate feature.)

---

## Task 2: Bump the three major-version-gated dependencies and fix breaking usage

**Files:**
- Modify: `pubspec.yaml:16` (`device_info_plus`), `pubspec.yaml:18` (`file_picker`), `pubspec.yaml:25` (`keyboard_height_plugin`)
- Modify: `lib/src/editor/util/file_picker/file_picker_service.dart`
- Modify: `lib/src/editor/util/file_picker/file_picker_impl.dart`
- Modify: `example/lib/home_page.dart` (~line 439, desktop save-file branch)
- No changes expected in `lib/src/editor/toolbar/mobile/utils/keyboard_height_observer.dart` (device_info_plus/keyboard_height_plugin have no breaking API changes in range, only build-tooling floor bumps — confirmed via pub.dev changelogs)

**Interfaces:**
- Produces: `FilePickerService.saveFile()` now takes `required Uint8List bytes` (caller must have file contents ready before invoking) and still returns `Future<String?>` (String form of the resulting `Uri`, so existing callers get a usable identifier without a hard dependency on it being a filesystem path).

**Context — why this isn't a pure version-number edit:**
file_picker 13.x changed `FilePicker.platform.saveFile()` from "open a dialog, return a path, caller writes bytes afterwards" (`Future<String?> saveFile({fileName, ...})`) to "open a dialog, write `bytes` for you, return a `Uri`" (`Future<Uri?> saveFile({required String fileName, required Uint8List bytes, ...})`). It also changed `pickFiles()` from returning a nullable `FilePickerResult` wrapper to returning `Future<List<PlatformFile>>` directly, and dropped the `allowMultiple`/`withData`/`withReadStream`/`lockParentWindow` params.

- [ ] **Step 1: Bump the three constraints in pubspec.yaml**

In `pubspec.yaml`, change:
```yaml
  device_info_plus: ^12.3.0
```
to
```yaml
  device_info_plus: ^13.2.0
```
change:
```yaml
  file_picker: ^10.3.10
```
to
```yaml
  file_picker: ^13.1.0
```
change:
```yaml
  keyboard_height_plugin: "^0.1.5"
```
to
```yaml
  keyboard_height_plugin: "^0.3.0"
```

- [ ] **Step 2: Resolve and see what breaks**

Run: `fvm flutter pub get`
Expected: resolves. Then run `fvm flutter analyze lib` — expect compile errors in `lib/src/editor/util/file_picker/file_picker_impl.dart` (from the removed `pickFiles`/`saveFile` params and changed return types).

- [ ] **Step 3: Update the FilePickerService abstract contract**

In `lib/src/editor/util/file_picker/file_picker_service.dart`, add the `dart:typed_data` import and change `saveFile`'s signature to require `bytes`:

```dart
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

class FilePickerResult {
  const FilePickerResult(this.files);

  /// Picked files.
  final List<PlatformFile> files;
}

/// Abstract file picker as a service to implement dependency injection.
abstract class FilePickerService {
  Future<String?> getDirectoryPath({
    String? title,
  }) async =>
      throw UnimplementedError('getDirectoryPath() has not been implemented.');

  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
  }) async =>
      throw UnimplementedError('pickFiles() has not been implemented.');

  Future<String?> saveFile({
    required Uint8List bytes,
    String? dialogTitle,
    String? fileName,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
  }) async =>
      throw UnimplementedError('saveFile() has not been implemented.');
}
```

(`allowMultiple`, `withData`, `withReadStream`, `lockParentWindow` are dropped from both methods since file_picker 13 removed them.)

- [ ] **Step 4: Update the default FilePicker implementation**

Replace `lib/src/editor/util/file_picker/file_picker_impl.dart` with:

```dart
import 'dart:typed_data';

import 'package:appflowy_editor_ce/src/editor/util/file_picker/file_picker_service.dart';
import 'package:file_picker/file_picker.dart' as fp;

class FilePicker implements FilePickerService {
  @override
  Future<String?> getDirectoryPath({String? title}) {
    return fp.FilePicker.platform.getDirectoryPath();
  }

  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    fp.FileType type = fp.FileType.any,
    List<String>? allowedExtensions,
    Function(fp.FilePickerStatus p1)? onFileLoading,
  }) async {
    final result = await fp.FilePicker.platform.pickFiles(
      dialogTitle: dialogTitle,
      initialDirectory: initialDirectory,
      type: type,
      allowedExtensions: allowedExtensions,
      onFileLoading: onFileLoading,
    );

    return FilePickerResult(result);
  }

  @override
  Future<String?> saveFile({
    required Uint8List bytes,
    String? dialogTitle,
    String? fileName,
    String? initialDirectory,
    fp.FileType type = fp.FileType.any,
    List<String>? allowedExtensions,
  }) async {
    final uri = await fp.FilePicker.platform.saveFile(
      fileName: fileName ?? 'untitled',
      bytes: bytes,
      dialogTitle: dialogTitle,
      initialDirectory: initialDirectory,
      type: type,
      allowedExtensions: allowedExtensions,
    );
    return uri?.toString();
  }
}
```

(Note the import switches to `package:appflowy_editor_ce/...` — this file is also touched by the Task 3 rename; if Task 3 hasn't run yet, keep the import as `package:appflowy_editor/...` for now and let Task 3's global replace catch it.)

- [ ] **Step 5: Fix the example app's desktop save-file call site**

In `example/lib/home_page.dart`, the desktop branch (~line 437-453) currently gets a path first and writes to it after. Since `saveFile` now needs bytes upfront, restructure to build the bytes before calling it:

```dart
    } else {
      // for desktop
      Uint8List bytes;
      if (fileType == ExportFileType.pdf) {
        final pdf = await PdfHTMLEncoder(
          fontFallback: [
            await PdfGoogleFonts.notoColorEmoji(),
            await PdfGoogleFonts.notoColorEmojiRegular(),
          ],
        ).convert(result);
        bytes = await pdf.save();
      } else {
        bytes = Uint8List.fromList(utf8.encode(result));
      }

      final path = await FilePicker.platform.saveFile(
        fileName: 'document.${fileType.extension}',
        bytes: bytes,
      );
      if (path != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('This document is saved to the $path'),
            ),
```
Keep the rest of that `if (mounted) { ... }` block (closing braces) as-is; only the two lines building `path` and the removed manual `File(path).write...` calls change. Add `import 'dart:convert';` and `import 'dart:typed_data';` at the top of `example/lib/home_page.dart` if not already present (check first — `dart:io`'s `File` is already imported there for the mobile branch).

- [ ] **Step 6: Re-run analyze and the test suite**

Run: `fvm flutter analyze lib` then `fvm flutter test`
Expected: no errors from file_picker/device_info_plus/keyboard_height_plugin usage; existing test suite passes (it exercises editor logic, not the file picker, so this is mainly a compile-clean check).

- [ ] **Step 7: Commit**

```bash
git add pubspec.yaml pubspec.lock lib/src/editor/util/file_picker/file_picker_service.dart lib/src/editor/util/file_picker/file_picker_impl.dart example/lib/home_page.dart example/pubspec.lock
git commit -m "chore: upgrade device_info_plus, file_picker, keyboard_height_plugin to latest majors"
```

---

## Task 3: Rename the package to appflowy_editor_ce

**Files:**
- Modify: `pubspec.yaml:1` (`name:`)
- Modify: every `.dart` file under `lib/`, `test/`, `example/lib/` containing `package:appflowy_editor/`
- Modify: `example/pubspec.yaml` (`dependencies.appflowy_editor` and `dependency_overrides.appflowy_editor` keys)

**Why:** Publishing this fork to pub.dev under the original `appflowy_editor` name would collide with the upstream package. The user asked for an `_ce` suffix, matching the same convention used by other CE forks already vendored in this monorepo (e.g. `hive_ce`).

- [ ] **Step 1: Confirm the exact blast radius before touching anything**

Run:
```bash
cd /Users/whitehat/coding/mylekha/frontend/mylekha_helper/appflowy-editor
grep -rl "package:appflowy_editor/" --include="*.dart" lib test example/lib | wc -l
```
Expected: a count matching what was surveyed earlier in this session (lib + test + example/lib combined, several hundred files/occurrences). This is just a sanity check that nothing surprising changed since the survey.

- [ ] **Step 2: Rewrite the pubspec name**

In `pubspec.yaml`, change:
```yaml
name: "appflowy_editor"
```
to
```yaml
name: "appflowy_editor_ce"
```

- [ ] **Step 3: Global replace the import URI across lib/, test/, example/lib/**

Run:
```bash
cd /Users/whitehat/coding/mylekha/frontend/mylekha_helper/appflowy-editor
grep -rl "package:appflowy_editor/" --include="*.dart" lib test example/lib | \
  xargs sed -i '' 's/package:appflowy_editor\//package:appflowy_editor_ce\//g'
```
(macOS `sed -i ''` — this environment is darwin, confirmed via the session's platform info.)

Do **not** touch `package:appflowy_editor_sync_plugin/` or `package:appflowy_editor_plugins/` occurrences in `example/lib/` — those are separate third-party packages, not this one; the pattern `package:appflowy_editor/` (with the trailing slash right after `appflowy_editor`) already excludes them since their URIs are `package:appflowy_editor_sync_plugin/...` and `package:appflowy_editor_plugins/...`, not `package:appflowy_editor/...`.

- [ ] **Step 4: Update example/pubspec.yaml's dependency keys**

In `example/pubspec.yaml`, under `dependencies:`, change:
```yaml
  appflowy_editor:
```
to
```yaml
  appflowy_editor_ce:
```
and under `dependency_overrides:`, change:
```yaml
  appflowy_editor:
    path: ../
```
to
```yaml
  appflowy_editor_ce:
    path: ../
```
Leave `appflowy_editor_sync_plugin`, `appflowy_editor_plugins`, and their entries untouched — different packages.

- [ ] **Step 5: Verify nothing was missed**

Run:
```bash
grep -rn "package:appflowy_editor/" --include="*.dart" lib test example/lib | wc -l
grep -n "^  appflowy_editor:$" example/pubspec.yaml
```
Expected: both return zero/no matches.

- [ ] **Step 6: Resolve and verify both packages still build**

Run:
```bash
fvm flutter pub get
cd example && fvm flutter pub get && cd ..
fvm flutter analyze lib
fvm flutter test
```
Expected: no unresolved-import errors, test suite passes (same pass/fail status as before the rename — the rename must not change behavior).

- [ ] **Step 7: Commit**

```bash
git add pubspec.yaml pubspec.lock example/pubspec.yaml example/pubspec.lock lib test example/lib
git commit -m "refactor: rename package to appflowy_editor_ce"
```

---

## Task 4: Bump version, update CHANGELOG, verify publish-readiness

**Files:**
- Modify: `pubspec.yaml:3` (`version:`)
- Modify: `CHANGELOG.md` (new entry at top)

- [ ] **Step 1: Bump the version**

In `pubspec.yaml`, change:
```yaml
version: 6.1.0
```
to
```yaml
version: 6.1.1
```

- [ ] **Step 2: Add a CHANGELOG entry**

At the top of `CHANGELOG.md`, above the existing `## 6.1.0` entry, insert:
```markdown
## 6.1.1
* Renamed the package to `appflowy_editor_ce` to publish independently of the upstream `appflowy_editor` name.
* chore: upgrade to Flutter 3.47.4 / Dart >=3.12.0
* chore: upgrade device_info_plus, file_picker, keyboard_height_plugin to latest major versions
* fix: prevent remote updates from scrolling local viewport
* fix: detach shrink-wrapped editor listeners on dispose
* fix: don't leak HTML comment content into pasted paragraph text

```
(Those three `fix:` lines summarize the commits already on `main` since the 6.1.0 changelog entry was written — `a9697798`, `829d4edf`, `bb995825` — so the changelog reflects what's actually shipping in this version, not just the rename.)

- [ ] **Step 3: Dry-run the publish**

Run: `fvm flutter pub publish --dry-run` (or `dart pub publish --dry-run` if the flutter wrapper complains about being a plugin-less package)
Expected: package validates with at most warnings (e.g. missing `repository:` field is fine since `homepage:` is set per the user's choice to keep pointing at upstream). No **errors** — resolve any that appear (e.g. import ordering, `dart format` issues) before treating this task as done.

- [ ] **Step 4: Commit**

```bash
git add pubspec.yaml CHANGELOG.md
git commit -m "chore: release appflowy_editor_ce 6.1.1"
```

- [ ] **Step 5: Report back to the user — do not publish**

Summarize the dry-run output and stop. Actually running `dart pub publish` (no `--dry-run`) is irreversible and visible to the world; it requires the user's explicit go-ahead in a separate turn, plus them being logged into the `pub.dev` account they want to publish under (`fvm dart pub login` if not already).

---

## Self-Review Notes

- **Spec coverage:** upgrade (Tasks 1-2) → rename (Task 3) → version-for-publish (Task 4). All three user-requested steps are covered in that order.
- **Downstream consumers out of scope:** `mylekha/packages/mylekha_core/pubspec.yaml:197` still depends on `appflowy_editor: ^6.1.0` (the upstream/pre-rename name). This plan does **not** touch it — updating that consumer to `appflowy_editor_ce` is a separate follow-up in a different repo, only worth doing once this package is actually published (or pointed at via a path/git override).
- **CI workflows** (`.github/workflows/commit_lint.yml`, `.github/workflows/test.yml`) were not inspected for hardcoded `appflowy_editor` references; out of scope for a pub.dev publish but worth a quick look before this fork's CI is relied on.
