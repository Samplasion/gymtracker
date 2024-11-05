import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:gymtracker/utils/theme.dart';

class ThemedSubtree extends StatelessWidget {
  final Color color;
  final Widget? child;
  final Widget Function(BuildContext)? builder;
  final bool enabled;

  const ThemedSubtree({
    required this.color,
    required this.child,
    this.enabled = true,
    super.key,
  }) : builder = null;

  const ThemedSubtree.builder({
    required this.color,
    required this.builder,
    this.enabled = true,
    super.key,
  }) : child = null;

  ColorScheme _getScheme(BuildContext context) {
    return ColorScheme.fromSeed(
      seedColor: color,
      brightness: Theme.of(context).brightness,
    ).harmonized();
  }

  Widget _childBuilder(BuildContext context) {
    if (child != null) return child!;

    return builder!(context);
  }

  @override
  Widget build(BuildContext context) {
    if (!enabled) return _childBuilder(context);
    return Theme(
      data: getGymTrackerThemeFor(context, color, Theme.of(context).brightness),
      child: Builder(builder: _childBuilder),
    );
  }
}
