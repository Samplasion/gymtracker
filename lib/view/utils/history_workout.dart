import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/view/exercises.dart';
import 'package:gymtracker/view/utils/exercise.dart';
import 'package:gymtracker/view/utils/workout_utils.dart';
import 'package:intl/intl.dart';

class HistoryWorkout extends StatelessWidget {
  final Workout workout;
  final int showExercises;
  final bool isSelected;
  final bool withStats;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Widget Function(BuildContext context, Workout workout)? headerBuilder;
  final bool _naked;

  HistoryController get controller => Get.find<HistoryController>();

  late final Workout? _continuation = controller.getContinuation(
    incompleteWorkout: workout,
  );

  HistoryWorkout({
    required this.workout,
    this.showExercises = 5,
    this.isSelected = false,
    this.withStats = false,
    this.onTap,
    this.onLongPress,
    this.headerBuilder,
    super.key,
  }) : _naked = false;

  HistoryWorkout.naked({
    required this.workout,
    this.showExercises = 5,
    this.isSelected = false,
    this.withStats = false,
    this.onTap,
    this.onLongPress,
    this.headerBuilder,
    super.key,
  }) : _naked = true;

  @override
  Widget build(BuildContext context) {
    var child = Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Column(
          crossAxisAlignment: .stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child:
                  headerBuilder?.call(context, workout) ??
                  WorkoutHeader(
                    isSelected: isSelected,
                    workout: workout,
                    continuation: _continuation,
                  ),
            ),
            if (withStats) ...[
              WorkoutStatsRow(workout: workout),
              if (workout.exercises.isNotEmpty) Divider(),
            ],
            for (final exercise in workout.exercises.take(showExercises))
              ExerciseListTile(
                exercise: exercise,
                selected: false,
                isConcrete: true,
                weightUnit: workout.weightUnit,
                distanceUnit: workout.distanceUnit,
              ),
            if (workout.exercises.length > showExercises) ...[
              ListTile(
                title: Text(
                  "history.andMore".plural(
                    workout.displayExerciseCount - showExercises,
                  ),
                ),
              ),
            ] else ...[
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );

    if (_naked) {
      return child;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: isSelected ? 16 : Theme.of(context).cardTheme.elevation,
      child: child,
    );
  }
}

class TerseWorkoutListTile extends StatelessWidget {
  final Workout workout;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? contentPadding;

  const TerseWorkoutListTile({
    super.key,
    required this.workout,
    this.onTap,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        child: Text(workout.name.characters.first.toUpperCase()),
      ),
      title: Text(workout.name),
      subtitle: Text(
        DateFormat.yMd(
          context.locale.languageCode,
        ).add_Hm().format(workout.startingDate ?? DateTime.now()),
      ),
      trailing: onTap == null ? null : const Icon(GTIcons.lt_chevron),
      onTap: onTap,
      contentPadding: contentPadding,
    );
  }
}
