import 'package:flutter/material.dart';
import 'package:gymtracker/data/exercises.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/utils.dart';

import '../../model/exercise.dart';

class ExerciseIcon extends StatelessWidget {
  final Exercise exercise;

  const ExerciseIcon({required this.exercise, super.key});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Theme.of(context).colorScheme.secondaryContainer;
    Color foregroundColor = Theme.of(context).colorScheme.onSecondaryContainer;

    if (exercise.standard) {
      final color = exerciseStandardLibrary.entries
          .firstWhereOrNull((element) => element.value.exercises
              .any((e) => e.id == (exercise.parentID ?? exercise.id)))
          ?.value
          .color;
      if (color != null) {
        backgroundColor = getContainerColor(context, color);
        foregroundColor = getOnContainerColor(context, color);
      }
    }

    return CircleAvatar(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      child: Text(exercise.displayName.characters.first.toUpperCase()),
    );
  }
}

class ExerciseListTile extends StatelessWidget {
  final Exercise exercise;
  final bool selected;
  final VoidCallback? onTap;

  const ExerciseListTile({
    required this.exercise,
    required this.selected,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final unselectedIcon = ExerciseIcon(exercise: exercise);
    Color backgroundColor = Theme.of(context).colorScheme.secondary;
    Color foregroundColor = Theme.of(context).colorScheme.onSecondary;

    if (exercise.standard) {
      final color = exerciseStandardLibrary.entries
          .firstWhereOrNull((element) => element.value.exercises
              .any((e) => e.id == (exercise.parentID ?? exercise.id)))
          ?.value
          .color;
      if (color != null) {
        backgroundColor = getContainerColor(context, color);
        foregroundColor = getOnContainerColor(context, color);
      }
    }

    final selectedIcon = CircleAvatar(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      child: const Icon(Icons.check),
    );
    return ListTile(
      leading: selected ? selectedIcon : unselectedIcon,
      title: Text.rich(
        TextSpan(children: [
          TextSpan(text: exercise.displayName),
          if (exercise.isCustom) ...[
            const TextSpan(text: " "),
            const WidgetSpan(
              baseline: TextBaseline.ideographic,
              alignment: PlaceholderAlignment.middle,
              child: CustomExerciseBadge(),
            ),
          ],
        ]),
      ),
      onTap: onTap,
    );
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
