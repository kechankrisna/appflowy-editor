import 'package:appflowy_editor_ce/appflowy_editor_ce.dart';
import 'package:markdown/markdown.dart' as md;

abstract class CustomMarkdownParser {
  const CustomMarkdownParser();

  List<Node> transform(
    md.Node element,
    List<CustomMarkdownParser> parsers, {
    MarkdownListType listType = MarkdownListType.unknown,
    int? startNumber,
  });
}
