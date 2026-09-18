import 'package:appflowy_editor_ce/appflowy_editor_ce.dart';

class DividerNodeParser extends NodeParser {
  const DividerNodeParser();

  @override
  String get id => DividerBlockKeys.type;

  @override
  String transform(Node node, DocumentMarkdownEncoder? encoder) {
    return '---\n';
  }
}
