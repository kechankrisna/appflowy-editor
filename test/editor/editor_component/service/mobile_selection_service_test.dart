import 'package:appflowy_editor_ce/appflowy_editor_ce.dart';
import 'package:appflowy_editor_ce/src/editor/editor_component/service/selection/mobile_selection_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../../test_helper.dart';

void main() {
  group('MobileSelectionServiceWidget', () {
    testWidgets('can render', (tester) async {
      final document = Document.blank();
      final editorState = EditorState(document: document);

      await tester.buildAndPump(
        Provider(
          create: (context) => editorState,
          child: const MobileSelectionServiceWidget(
            child: SizedBox.shrink(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MobileSelectionServiceWidget), findsOneWidget);
    });
  });
}
