import 'package:flutter/material.dart';
import 'package:gymtracker/data/exercises.dart';
import 'package:gymtracker/model/exercisable.dart';
import 'package:gymtracker/model/superset.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/utils.dart';

import '../../model/exercise.dart';

class ExerciseIcon extends StatelessWidget {
  final WorkoutExercisable exercise;

  const ExerciseIcon({required this.exercise, super.key});

  @override
  Widget build(BuildContext context) {
    final exercise = this.exercise;

    Color backgroundColor = Theme.of(context).colorScheme.secondaryContainer;
    Color foregroundColor = Theme.of(context).colorScheme.onSecondaryContainer;

    if (exercise is Exercise && exercise.standard) {
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
      child: _getName(),
    );
  }

  Text _getName() {
    if (exercise is Exercise) {
      return Text(
          (exercise as Exercise).displayName.characters.first.toUpperCase());
    } else if (exercise is Superset) {
      return Text((exercise as Superset).exercises.length.toString());
    } else {
      return const Text("E");
    }
  }
}

class ExerciseListTile extends StatelessWidget {
  final WorkoutExercisable exercise;
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
    final exercise = this.exercise;

    final unselectedIcon = ExerciseIcon(exercise: exercise);
    Color backgroundColor = Theme.of(context).colorScheme.secondary;
    Color foregroundColor = Theme.of(context).colorScheme.onSecondary;

    if (exercise is Exercise && exercise.standard) {
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
          if (exercise is Superset) ...[
            const WidgetSpan(
              baseline: TextBaseline.ideographic,
              alignment: PlaceholderAlignment.middle,
              child: Icon(Icons.layers),
            ),
            const TextSpan(text: " "),
            TextSpan(text: "superset".plural(exercise.exercises.length)),
          ] else if (exercise is Exercise) ...[
            TextSpan(text: exercise.displayName),
            if (exercise.isCustom) ...[
              const TextSpan(text: " "),
              const WidgetSpan(
                baseline: TextBaseline.ideographic,
                alignment: PlaceholderAlignment.middle,
                child: CustomExerciseBadge(),
              ),
            ],
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
