import 'package:flutter/material.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/utils/colors.dart';

enum GTBadgeSize {
  small(fontSize: 10, padding: 2.5),
  medium(fontSize: 12, padding: 4),
  large(fontSize: 14, padding: 6);

  const GTBadgeSize({
    required this.fontSize,
    required this.padding,
  });

  final double fontSize;
  final double padding;
}

class GTBadge extends StatelessWidget {
  final String content;
  final Color? background;
  final Color? foreground;
  final GTMaterialColor color;
  final GTBadgeSize size;
  final bool invert;

  const GTBadge({
    super.key,
    required this.content,
    this.background,
    this.foreground,
    this.color = GTMaterialColor.tertiary,
    this.size = GTBadgeSize.medium,
    this.invert = false,
  });

  @override
  Widget build(BuildContext context) {
    var background = this.background ?? color.getBackground(context);
    var foreground = this.foreground ?? color.getForeground(context);

    if (invert) (background, foreground) = (foreground, background);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: size.padding),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        content,
        style: TextStyle(
          fontSize: size.fontSize,
          color: foreground,
        ),
      ),
    );
  }
}

class BetaBadge extends StatelessWidget {
  const BetaBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return const GTBadge(content: "BETA");
  }
}

class CustomExerciseBadge extends StatelessWidget {
  final bool short;

  const CustomExerciseBadge({this.short = false, super.key});

  String get text {
    final str = "exercise.custom".t.toUpperCase();
    if (short) return str[0];
    return str;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.onSecondaryContainer,
        ),
      ),
    );
  }
}
