import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymtracker/view/platform/platform_widget.dart';

class PlatformListTile extends PlatformStatelessWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool cupertinoIsNotched;

  const PlatformListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.cupertinoIsNotched = false,
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
    final trailing = this.trailing ??
        (onTap != null
            ? const Icon(
                CupertinoIcons.forward,
              )
            : null);
    if (cupertinoIsNotched) {
      return CupertinoListTile.notched(
        leading: leading,
        title: title!,
        subtitle: subtitle,
        trailing: trailing == null
            ? null
            : IconTheme(
                data: const IconThemeData(color: CupertinoColors.systemGrey),
                child: trailing,
              ),
        onTap: onTap,
      );
    }
    return CupertinoListTile(
      leading: leading,
      title: title!,
      subtitle: subtitle,
      trailing: trailing == null
          ? null
          : IconTheme(
              data: const IconThemeData(color: CupertinoColors.systemGrey),
              child: trailing,
            ),
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
        data: IconThemeData(
            color: foregroundColor ?? IconTheme.of(context).color),
        child: child,
      ),
    );
  }
}

class PlatformSwitchListTile extends PlatformStatelessWidget {
  final Widget title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool cupertinoIsNotched;

  const PlatformSwitchListTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.cupertinoIsNotched = false,
  });

  @override
  Widget buildCupertino(BuildContext context) {
    return PlatformListTile(
      title: title,
      trailing: CupertinoSwitch(
        value: value,
        onChanged: onChanged,
      ),
      cupertinoIsNotched: cupertinoIsNotched,
    );
  }

  @override
  Widget buildMaterial(BuildContext context) {
    return SwitchListTile(
      title: title,
      value: value,
      onChanged: onChanged,
    );
  }
}
