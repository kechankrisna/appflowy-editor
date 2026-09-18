import 'dart:async';
import 'package:appflowy_editor_ce/appflowy_editor_ce.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../util/util.dart';
import '../test_character_shortcut.dart';

void main() async {
  group('formatDoubleQuoteToQuote', () {
    const text = 'Welcome to AppFlowy Editor 🔥!';
    // Before
    // >|Welcome to AppFlowy Editor 🔥!
    // After
    // [quote] Welcome to AppFlowy Editor 🔥!
    test('mock inputting a ` ` after the > but not dot', () async {
      unawaited(
        testFormatCharacterShortcut(
          formatDoubleQuoteToQuote,
          '"',
          1,
          (result, before, after, editorState) {
            expect(result, true);
            expect(after.delta!.toPlainText(), text);
            expect(after.type, 'quote');
          },
        ),
      );
    });

    // Before
    // >W|elcome to AppFlowy Editor 🔥!
    // After
    // >W|elcome to AppFlowy Editor 🔥!
    test('mock inputting a ` ` in the middle of the node', () async {
      unawaited(
        testFormatCharacterShortcut(
          formatDoubleQuoteToQuote,
          '"',
          2,
          (result, before, after, editorState) {
            // nothing happens
            expect(result, false);
            expect(before.toJson(), after.toJson());
          },
        ),
      );
    });

    // Before
    // Welcome to AppFlowy Editor 🔥!
    // >|Welcome to AppFlowy Editor 🔥!
    // After
    // Welcome to AppFlowy Editor 🔥!
    //[quote] Welcome to AppFlowy Editor 🔥!
    test(
        'mock inputting a ` ` in the middle of the node, and there\'s a other node at the front of it.',
        () async {
      const text = 'Welcome to AppFlowy Editor 🔥!';
      final document = Document.blank()
          .addParagraph(
            initialText: text,
          )
          .addParagraph(
            initialText: '"$text',
          );
      final editorState = EditorState(document: document);

      // Welcome to AppFlowy Editor 🔥!
      // *|Welcome to AppFlowy Editor 🔥!
      final selection = Selection.collapsed(
        Position(path: [1], offset: 1),
      );
      editorState.selection = selection;
      final result = await formatDoubleQuoteToQuote.execute(editorState);
      final after = editorState.getNodeAtPath([1])!;

      // the second line will be formatted as the bulleted list style
      expect(result, true);
      expect(after.type, 'quote');
      expect(after.delta!.toPlainText(), text);
    });
  });
}
