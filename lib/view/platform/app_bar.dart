import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gymtracker/view/platform/platform_widget.dart';

class PlatformSliverAppBar extends PlatformStatelessWidget {
  final Widget title;
  final Color? materialBackgroundColor;
  final Color? materialForegroundColor;
  final Color? materialSurfaceTintColor;
  final Widget? leading;
  final List<Widget>? actions;

  const PlatformSliverAppBar({
    super.key,
    required this.title,
    this.materialBackgroundColor,
    this.materialForegroundColor,
    this.materialSurfaceTintColor,
    this.leading,
    this.actions,
  });

  @override
  Widget buildMaterial(BuildContext context) {
    return SliverAppBar.large(
      title: title,
      backgroundColor: materialBackgroundColor,
      foregroundColor: materialForegroundColor,
      shadowColor: materialSurfaceTintColor,
      leading: leading,
      actions: actions,
    );
  }

  @override
  Widget buildCupertino(BuildContext context) {
    return CupertinoSliverNavigationBar(
      largeTitle: title,
      leading: leading,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: actions ?? const <Widget>[],
      ),
    );
  }
}
