import 'dart:async';
import 'package:appflowy_editor_ce/appflowy_editor_ce.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_character_shortcut.dart';

void main() async {
  group(
    'todo_list_character_shortcut.dart',
    () {
      // Before
      // []|Welcome to AppFlowy Editor 🔥!
      // After
      // [uncheckedbox]Welcome to AppFlowy Editor 🔥!
      test('[] to unchecked todo list ', () async {
        const text = 'Welcome to AppFlowy Editor 🔥!';
        unawaited(
          testFormatCharacterShortcut(
            formatEmptyBracketsToUncheckedBox,
            '[]',
            2,
            (result, before, after, editorState) {
              expect(result, true);
              expect(after.delta!.toPlainText(), text);
              expect(after.type, 'todo_list');
              expect(after.attributes['checked'], false);
            },
          ),
        );
      });

      // Before
      // -[]|Welcome to AppFlowy Editor 🔥!
      // After
      // [uncheckedbox]Welcome to AppFlowy Editor 🔥!
      test('-[] to unchecked todo list ', () async {
        const text = 'Welcome to AppFlowy Editor 🔥!';
        unawaited(
          testFormatCharacterShortcut(
            formatHyphenEmptyBracketsToUncheckedBox,
            '-[]',
            3,
            (result, before, after, editorState) {
              expect(result, true);
              expect(after.delta!.toPlainText(), text);
              expect(after.type, 'todo_list');
              expect(after.attributes['checked'], false);
            },
          ),
        );
      });

      // Before
      // [x]|Welcome to AppFlowy Editor 🔥!
      // After
      // [checkedbox]Welcome to AppFlowy Editor 🔥!
      test('[x] to checked todo list ', () async {
        const text = 'Welcome to AppFlowy Editor 🔥!';
        unawaited(
          testFormatCharacterShortcut(
            formatFilledBracketsToCheckedBox,
            '[x]',
            3,
            (result, before, after, editorState) {
              expect(result, true);
              expect(after.delta!.toPlainText(), text);
              expect(after.type, 'todo_list');
              expect(after.attributes['checked'], true);
            },
          ),
        );
      });

      // Before
      // -[x]|Welcome to AppFlowy Editor 🔥!
      // After
      // [checkedbox]Welcome to AppFlowy Editor 🔥!
      test('-[x] to checked todo list ', () async {
        const text = 'Welcome to AppFlowy Editor 🔥!';
        unawaited(
          testFormatCharacterShortcut(
            formatHyphenFilledBracketsToCheckedBox,
            '-[x]',
            4,
            (result, before, after, editorState) {
              expect(result, true);
              expect(after.delta!.toPlainText(), text);
              expect(after.type, 'todo_list');
              expect(after.attributes['checked'], true);
            },
          ),
        );
      });

      test('convert numbered_list to todo_list', () async {
        const syntax = '-[x]';
        const text = 'Welcome to AppFlowy Editor 🔥!';
        unawaited(
          testFormatCharacterShortcut(
            formatHyphenFilledBracketsToCheckedBox,
            syntax,
            syntax.length,
            (result, before, after, editorState) {
              expect(result, true);
              expect(after.delta!.toPlainText(), text);
              expect(after.type, TodoListBlockKeys.type);
              expect(after.attributes[TodoListBlockKeys.checked], true);
              expect(after.children[0].delta!.toPlainText(), '1 $text');
              expect(after.children[1].delta!.toPlainText(), '2 $text');
            },
            node: bulletedListNode(
              text: '$syntax$text',
              children: [
                bulletedListNode(text: '1 $text'),
                bulletedListNode(text: '2 $text'),
              ],
            ),
          ),
        );
      });
    },
  );
}
