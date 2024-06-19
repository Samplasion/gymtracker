import 'package:flutter/material.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/data/exercises.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/model/exercisable.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/model/superset.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/utils.dart';
import 'package:gymtracker/view/components/badges.dart';
import 'package:gymtracker/view/utils/timer.dart';

class ExerciseIcon extends StatelessWidget {
  final WorkoutExercisable exercise;

  const ExerciseIcon({required this.exercise, super.key});

  @override
  Widget build(BuildContext context) {
    final exercise = this.exercise;

    Color backgroundColor = Theme.of(context).colorScheme.secondaryContainer;
    Color foregroundColor = Theme.of(context).colorScheme.onSecondaryContainer;

    if (exercise is Exercise &&
        exercise.standard &&
        exercise.category != null) {
      final color = exerciseStandardLibrary[exercise.category]?.color;
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
  final Weights? weightUnit;
  final Distance? distanceUnit;
  final VoidCallback? onTap;
  final Widget? trailing;
  final VisualDensity? visualDensity;
  final MouseCursor? mouseCursor;
  final EdgeInsetsGeometry? contentPadding;

  const ExerciseListTile({
    required this.exercise,
    required this.selected,
    required this.isConcrete,
    this.weightUnit,
    this.distanceUnit,
    this.onTap,
    this.trailing,
    this.visualDensity,
    this.mouseCursor,
    this.contentPadding,
    super.key,
  })  : assert((weightUnit == null) == !isConcrete,
            "Weight unit must be set if the exercise is concrete"),
        assert((distanceUnit == null) == !isConcrete,
            "Distance unit must be set if the exercise is concrete");

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
      backgroundColor: foregroundColor,
      foregroundColor: backgroundColor,
      child: const Icon(GymTrackerIcons.done),
    );
    return ListTile(
      leading: selected ? selectedIcon : unselectedIcon,
      title: Text.rich(
        TextSpan(children: [
          if (exercise is Superset) ...[
            const WidgetSpan(
              baseline: TextBaseline.ideographic,
              alignment: PlaceholderAlignment.middle,
              child: Icon(GymTrackerIcons.superset),
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
      trailing: trailing,
      visualDensity: visualDensity,
      mouseCursor: mouseCursor,
      contentPadding: contentPadding,
    );
  }

  String _buildWeight(double weight) => Weights.convert(
          value: weight,
          from: weightUnit!,
          to: settingsController.weightUnit.value)
      .userFacingWeight;
  String _buildReps(int? reps) => "exerciseList.fields.reps".plural(reps ?? 0);
  String _buildTime(BuildContext context, Duration time) =>
      TimerView.buildTimeString(context, time, builder: (time) => time.text!);
  String _buildDistance(double? distance) => Distance.convert(
          value: distance ?? 0,
          from: distanceUnit!,
          to: settingsController.distanceUnit.value)
      .userFacingDistance;

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
        case GTSetParameters.repsWeight:
          formattedSets = exercise.sets.map((set) =>
              "${_buildReps(set.reps)} ${_buildWeight(set.weight ?? 0)}");

        case GTSetParameters.freeBodyReps:
          formattedSets = exercise.sets.map((set) => _buildReps(set.reps));

        case GTSetParameters.timeWeight:
          formattedSets = exercise.sets.map((set) =>
              "${_buildReps(set.reps)} ${_buildTime(context, set.time ?? Duration.zero)}");

        case GTSetParameters.time:
          formattedSets = exercise.sets
              .map((set) => _buildTime(context, set.time ?? Duration.zero));

        case GTSetParameters.distance:
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
            ![GTSetParameters.time, GTSetParameters.distance]
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
