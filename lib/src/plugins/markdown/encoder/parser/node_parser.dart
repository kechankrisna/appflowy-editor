import 'package:appflowy_editor_ce/appflowy_editor_ce.dart';

abstract class NodeParser {
  const NodeParser();

  String get id;

  String transform(Node node, DocumentMarkdownEncoder? encoder);
}
