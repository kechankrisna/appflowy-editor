import 'package:appflowy_editor_ce/appflowy_editor_ce.dart';

class ImageNodeParser extends NodeParser {
  const ImageNodeParser();

  @override
  String get id => ImageBlockKeys.type;

  @override
  String transform(Node node, DocumentMarkdownEncoder? encoder) {
    return '![](${node.attributes[ImageBlockKeys.url]})';
  }
}
