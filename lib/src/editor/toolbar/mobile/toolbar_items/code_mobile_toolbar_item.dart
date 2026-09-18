import 'package:appflowy_editor_ce/appflowy_editor_ce.dart';

final codeMobileToolbarItem = MobileToolbarItem.action(
  itemIconBuilder: (context, __, ___) => AFMobileIcon(
    afMobileIcons: AFMobileIcons.code,
    color: MobileToolbarTheme.of(context).iconColor,
  ),
  actionHandler: (_, editorState) => editorState.toggleAttribute(
    AppFlowyRichTextKeys.code,
  ),
);
