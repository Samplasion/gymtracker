import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/provider/training_data.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/view/exercises.dart';
import 'package:gymtracker/view/utils/exercise.dart';
import 'package:gymtracker/view/utils/workout_utils.dart';
import 'package:intl/intl.dart';

class HistoryWorkout extends ConsumerWidget {
  final Workout workout;
  final int showExercises;
  final bool isSelected;
  final bool withStats;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Widget Function(BuildContext context, Workout workout)? headerBuilder;
  final bool _naked;

  const HistoryWorkout({
    required this.workout,
    this.showExercises = 5,
    this.isSelected = false,
    this.withStats = false,
    this.onTap,
    this.onLongPress,
    this.headerBuilder,
    super.key,
  }) : _naked = false;

  const HistoryWorkout.naked({
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
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(historyWorkoutsProvider);
    ref.watch(customExercisesProvider);
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
                    continuation: ref
                        .read(historyControllerProvider)
                        .getContinuation(incompleteWorkout: workout),
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
                  context.t.history.andMore(
                    n: workout.displayExerciseCount - showExercises,
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

class TerseWorkoutListTile extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(historyWorkoutsProvider);
    ref.watch(customExercisesProvider);
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
