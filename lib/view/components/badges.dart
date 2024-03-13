import 'package:flutter/material.dart';
import 'package:gymtracker/service/localizations.dart';

class GTBadge extends StatelessWidget {
  final String content;
  final Color? background;
  final Color? foreground;

  const GTBadge({
    super.key,
    required this.content,
    this.background,
    this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    final background =
        this.background ?? Theme.of(context).colorScheme.tertiaryContainer;
    final foreground =
        this.foreground ?? Theme.of(context).colorScheme.onTertiaryContainer;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        content,
        style: TextStyle(
          fontSize: 12,
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
  const CustomExerciseBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        "exercise.custom".t.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.onSecondaryContainer,
        ),
      ),
    );
  }
}
