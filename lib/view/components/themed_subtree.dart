import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:gymtracker/utils/theme.dart';

class ThemedSubtree extends StatelessWidget {
  final Color color;
  final Widget child;
  final bool enabled;

  const ThemedSubtree({
    required this.color,
    required this.child,
    this.enabled = true,
    super.key,
  });

  ColorScheme _getScheme(BuildContext context) {
    return ColorScheme.fromSeed(
      seedColor: color,
      brightness: Theme.of(context).brightness,
    ).harmonized();
  }

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;
    return Theme(
      data: getGymTrackerThemeFor(_getScheme(context)),
      child: child,
    );
  }
}
