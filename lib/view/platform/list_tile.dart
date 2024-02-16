import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gymtracker/view/platform/platform_widget.dart';

class PlatformListTile extends PlatformStatelessWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const PlatformListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget buildMaterial(BuildContext context) {
    return ListTile(
      leading: leading,
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      onTap: onTap,
    );
  }

  @override
  Widget buildCupertino(BuildContext context) {
    return CupertinoListTile(
      leading: leading,
      title: title!,
      subtitle: subtitle,
      trailing: trailing,
      onTap: onTap,
    );
  }
}

class PlatformLeadingIcon extends PlatformStatelessWidget {
  final Widget child;
  final Color? materialBackgroundColor;
  final Color? foregroundColor;

  const PlatformLeadingIcon({
    super.key,
    required this.child,
    this.materialBackgroundColor,
    this.foregroundColor,
  });

  @override
  Widget buildMaterial(BuildContext context) {
    return CircleAvatar(
      foregroundColor: foregroundColor,
      backgroundColor: materialBackgroundColor,
      child: child,
    );
  }

  @override
  Widget buildCupertino(BuildContext context) {
    return DefaultTextStyle(
      style: CupertinoTheme.of(context).textTheme.actionTextStyle.copyWith(
            color: foregroundColor,
          ),
      child: IconTheme(
        data: IconThemeData(color: foregroundColor),
        child: child,
      ),
    );
  }
}
