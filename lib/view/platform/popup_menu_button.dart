import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gymtracker/view/platform/platform_widget.dart';
import 'package:pull_down_button/pull_down_button.dart';

export 'package:pull_down_button/pull_down_button.dart' show PullDownMenuItem;

class PlatformPopupMenuButton extends PlatformStatelessWidget {
  final List<PullDownMenuEntry> Function(BuildContext) itemBuilder;
  final Widget? child;
  final String? tooltip;

  const PlatformPopupMenuButton({
    super.key,
    required this.itemBuilder,
    this.child,
    this.tooltip,
  });

  @override
  Widget buildMaterial(BuildContext context) {
    return PopupMenuButton(
      icon: child,
      tooltip: tooltip,
      itemBuilder: (context) => itemBuilder(context)
          .map((item) {
            return _cupertinoToMaterial(context, item);
          })
          .whereType<PopupMenuEntry>()
          .toList(),
    );
  }

  @override
  Widget buildCupertino(BuildContext context) {
    return PullDownButton(
      itemBuilder: itemBuilder,
      buttonBuilder: (context, showMenu) => CupertinoButton(
        onPressed: showMenu,
        padding: EdgeInsets.zero,
        child: child ?? const Icon(CupertinoIcons.ellipsis_circle),
      ),
    );
  }

  PopupMenuEntry? _cupertinoToMaterial(
      BuildContext context, PullDownMenuEntry item) {
    if (item is PullDownMenuItem) {
      return PopupMenuItem(
        value: item,
        onTap: item.onTap,
        child: ListTile(
          leading: item.iconWidget,
          title: Text(
            item.title,
            style: TextStyle(
              color: item.isDestructive
                  ? Theme.of(context).colorScheme.error
                  : null,
            ),
          ),
        ),
      );
    } else if (item is PullDownMenuDivider) {
      return PopupMenuDivider();
    }
  }
}
