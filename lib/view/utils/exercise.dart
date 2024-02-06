import 'package:flutter/material.dart';
import 'package:gymtracker/data/exercises.dart';
import 'package:gymtracker/model/exercisable.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/model/superset.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/utils.dart';
import 'package:gymtracker/view/utils/timer.dart';

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
  final bool isConcrete;
  final VoidCallback? onTap;

  const ExerciseListTile({
    required this.exercise,
    required this.selected,
    required this.isConcrete,
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
      subtitle: _buildSubtitle(
        context,
      ),
      onTap: onTap,
    );
  }

  String _buildWeight(double weight) => "exerciseList.fields.weight".tParams({
        "weight": stringifyDouble(weight),
        "unit": "units.kg".t,
      });
  String _buildReps(int? reps) => "exerciseList.fields.reps".plural(reps ?? 0);
  String _buildTime(BuildContext context, Duration time) =>
      TimerView.buildTimeString(context, time, builder: (time) => time.text!);
  String _buildDistance(double? distance) =>
      "exerciseList.fields.distance".tParams({
        "distance": stringifyDouble(distance ?? 0),
        "unit": "units.km".t,
      });

  Text? _buildSubtitle(BuildContext context) {
    final exercise = this.exercise;
    if (exercise is Superset) {
      if (exercise.exercises.isEmpty) return null;
      return Text(
        exercise.exercises.map((e) => e.displayName).join(", "),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    } else if (exercise is Exercise) {
      if (!isConcrete) return null;

      Iterable<String> formattedSets;

      switch (exercise.parameters) {
        case SetParameters.repsWeight:
          formattedSets = exercise.sets.map((set) =>
              "${_buildReps(set.reps)} ${_buildWeight(set.weight ?? 0)}");

        case SetParameters.freeBodyReps:
          formattedSets = exercise.sets.map((set) => _buildReps(set.reps));

        case SetParameters.timeWeight:
          formattedSets = exercise.sets.map((set) =>
              "${_buildReps(set.reps)} ${_buildTime(context, set.time ?? Duration.zero)}");

        case SetParameters.time:
          formattedSets = exercise.sets
              .map((set) => _buildTime(context, set.time ?? Duration.zero));

        case SetParameters.distance:
          formattedSets =
              exercise.sets.map((set) => _buildDistance(set.distance));
      }

      final text =
          formattedSets.fold(<(String, int)>[], (previousValue, element) {
        if (previousValue.isEmpty || previousValue.last.$1 != element) {
          return [...previousValue, (element, 1)];
        }
        return [
          ...previousValue.sublist(0, previousValue.length - 1),
          (element, previousValue.last.$2 + 1)
        ];
      }).map((e) {
        if (e.$2 == 1 &&
            ![SetParameters.time, SetParameters.distance]
                .contains(exercise.parameters)) {
          return e.$1;
        }
        return "${e.$2} × ${e.$1}";
      }).join(", ");
      if (text.isNotEmpty) {
        return Text(
          text,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        );
      }
    }
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
