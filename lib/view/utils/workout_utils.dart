import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/view/utils/timer.dart';
import 'package:intl/intl.dart';

class WorkoutHeader extends StatelessWidget {
  const WorkoutHeader({
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
            if (workout.isConcrete)
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
                                .format(continuation!.startingDate ??
                                    DateTime.now()),
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
