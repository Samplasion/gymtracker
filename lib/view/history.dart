import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:intl/intl.dart';

import '../controller/history_controller.dart';
import '../model/workout.dart';
import '../service/localizations.dart';
import '../utils/go.dart';
import 'exercises.dart';
import 'utils/exercise.dart';
import 'utils/timer.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HistoryController>();
    return Scaffold(
      body: Obx(
        () => CustomScrollView(
          slivers: [
            SliverAppBar.large(
              title: Text("history.title".t),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  for (final workout in controller.history.reversed)
                    HistoryWorkout(workout: workout),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HistoryWorkout extends StatelessWidget {
  final Workout workout;

  const HistoryWorkout({required this.workout, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Go.to(() => ExercisesView(workout: workout));
          },
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                          child:
                              Text(workout.name.characters.first.toUpperCase()),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(workout.name,
                                  style:
                                      Theme.of(context).textTheme.titleMedium),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("general.exercises".plural(
                                    workout.exercises.length,
                                  )),
                                  Flexible(
                                    child: TimerView.buildTimeString(
                                      context,
                                      workout.duration ?? Duration.zero,
                                      builder: (time) => Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(
                                              text: DateFormat.yMd()
                                                  .add_Hm()
                                                  .format(
                                                      workout.startingDate ??
                                                          DateTime.now()),
                                            ),
                                            const TextSpan(text: " - "),
                                            time
                                          ],
                                        ),
                                        textAlign: TextAlign.end,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // TODO(Supersets): Fix this
              for (final exercise
                  in workout.exercises.whereType<Exercise>().take(3))
                ExerciseListTile(exercise: exercise, selected: false),
              if (workout.exercises.length > 3) ...[
                ListTile(
                  title: Text(
                    "history.andMore".plural(workout.exercises.length - 3),
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
