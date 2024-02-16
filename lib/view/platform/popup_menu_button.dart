import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gymtracker/view/platform/platform_widget.dart';
import 'package:pull_down_button/pull_down_button.dart';

export 'package:pull_down_button/pull_down_button.dart' show PullDownMenuItem;

class PlatformPopupMenuButton extends PlatformStatelessWidget {
  final List<PullDownMenuItem> Function(BuildContext) itemBuilder;

  const PlatformPopupMenuButton({
    super.key,
    required this.itemBuilder,
  });

  @override
  Widget buildMaterial(BuildContext context) {
    return PopupMenuButton(
      itemBuilder: (context) => itemBuilder(context).map((item) {
        return PopupMenuItem(
          value: item,
          child: Text.rich(
            TextSpan(
              text: item.title,
              children: [
                if (item.iconWidget != null) ...[
                  const TextSpan(text: ' '),
                  WidgetSpan(
                    child: item.iconWidget!,
                    alignment: PlaceholderAlignment.middle,
                  ),
                ]
              ],
            ),
            style: TextStyle(
              color: item.isDestructive
                  ? Theme.of(context).colorScheme.error
                  : null,
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget buildCupertino(BuildContext context) {
    return PullDownButton(
      itemBuilder: itemBuilder,
      buttonBuilder: (context, showMenu) => CupertinoButton(
        onPressed: showMenu,
        padding: EdgeInsets.zero,
        child: const Icon(CupertinoIcons.ellipsis_circle),
      ),
    );
  }
}
