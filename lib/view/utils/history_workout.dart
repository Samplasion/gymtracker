import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/view/utils/exercise.dart';
import 'package:gymtracker/view/utils/timer.dart';
import 'package:intl/intl.dart';

class HistoryWorkout extends StatelessWidget {
  final Workout workout;
  final int showExercises;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  HistoryController get controller => Get.find<HistoryController>();

  late final Workout? continuation =
      controller.getContinuation(incompleteWorkout: workout);

  HistoryWorkout({
    required this.workout,
    this.showExercises = 5,
    this.isSelected = false,
    this.onTap,
    this.onLongPress,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: isSelected ? 16 : Theme.of(context).cardTheme.elevation,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          onLongPress: onLongPress,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: HistoryWorkoutHeader(
                  isSelected: isSelected,
                  workout: workout,
                  continuation: continuation,
                ),
              ),
              for (final exercise in workout.exercises.take(showExercises))
                ExerciseListTile(
                  exercise: exercise,
                  selected: false,
                  isConcrete: true,
                  weightUnit: workout.weightUnit,
                ),
              if (workout.exercises.length > showExercises) ...[
                ListTile(
                  title: Text(
                    "history.andMore"
                        .plural(workout.displayExerciseCount - showExercises),
                  ),
                ),
              ] else ...[
                const SizedBox(height: 16),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

class HistoryWorkoutHeader extends StatelessWidget {
  const HistoryWorkoutHeader({
    super.key,
    required this.workout,
    required this.continuation,
    this.isSelected = false,
  });

  final bool isSelected;
  final Workout workout;
  final Workout? continuation;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final fg =
        isSelected ? colorScheme.onSurface : colorScheme.onPrimaryContainer;
    final bg = isSelected ? colorScheme.surface : colorScheme.primaryContainer;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: bg,
              foregroundColor: fg,
              child: isSelected
                  ? const Icon(Icons.check)
                  : Text(workout.name.characters.first.toUpperCase()),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _HistoryWorkoutHeaderInner(
                  workout: workout, continuation: continuation),
            ),
          ],
        ),
      ],
    );
  }
}

class _HistoryWorkoutHeaderInner extends StatelessWidget {
  const _HistoryWorkoutHeaderInner({
    required this.workout,
    required this.continuation,
  });

  final Workout workout;
  final Workout? continuation;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: workout.name),
              if (workout.isContinuation && kDebugMode)
                TextSpan(
                  text: " [CONTINUATION]",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
            ],
          ),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("general.exercises".plural(
              workout.displayExerciseCount,
            )),
            Flexible(
              child: TimerView.buildTimeString(
                context,
                workout.duration ?? Duration.zero,
                builder: (time) => Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: DateFormat.yMd(context.locale.languageCode)
                            .add_Hm()
                            .format(workout.startingDate ?? DateTime.now()),
                      ),
                      const TextSpan(text: " - "),
                      time,
                      if (continuation != null) ...[
                        const TextSpan(text: "\n+ "),
                        TextSpan(
                          text: DateFormat.yMd(context.locale.languageCode)
                              .add_Hm()
                              .format(
                                  continuation!.startingDate ?? DateTime.now()),
                        ),
                        const TextSpan(text: " - "),
                        TimerView.buildTimeString(
                          context,
                          continuation!.duration ?? Duration.zero,
                          builder: (time) => time,
                        ),
                        const TextSpan(text: "\n"),
                        TimerView.buildTimeString(
                          context,
                          (continuation!.duration ?? Duration.zero) +
                              (workout.duration ?? Duration.zero),
                          builder: (time) => TextSpan(
                            text: "general.totalTime".tParams({
                              "time": time.text!,
                            }),
                          ),
                        )
                      ]
                    ],
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
