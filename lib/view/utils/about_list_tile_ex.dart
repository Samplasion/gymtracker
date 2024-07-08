import 'dart:io';

import 'package:flutter/material.dart';

class AboutListTileEx extends StatelessWidget {
  const AboutListTileEx({
    super.key,
    this.icon,
    this.child,
    this.subtitle,
    this.applicationName,
    this.applicationVersion,
    this.applicationIcon,
    this.applicationLegalese,
    this.aboutBoxChildren,
    this.dense,
  });

  final Widget? icon;
  final Widget? child;
  final Widget? subtitle;
  final String? applicationName;
  final String? applicationVersion;
  final Widget? applicationIcon;
  final String? applicationLegalese;
  final List<Widget>? aboutBoxChildren;
  final bool? dense;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));
    assert(debugCheckHasMaterialLocalizations(context));
    return ListTile(
      leading: icon,
      title: child ??
          Text(MaterialLocalizations.of(context).aboutListTileTitle(
            applicationName ?? _defaultApplicationName(context),
          )),
      subtitle: subtitle,
      dense: dense,
      onTap: () {
        showAboutDialog(
          context: context,
          applicationName: applicationName,
          applicationVersion: applicationVersion,
          applicationIcon: applicationIcon,
          applicationLegalese: applicationLegalese,
          children: aboutBoxChildren,
        );
      },
    );
  }

  String _defaultApplicationName(BuildContext context) {
    final Title? ancestorTitle = context.findAncestorWidgetOfExactType<Title>();
    return ancestorTitle?.title ??
        Platform.resolvedExecutable.split(Platform.pathSeparator).last;
  }
}
