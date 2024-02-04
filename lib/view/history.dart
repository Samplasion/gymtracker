import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
            SliverList.builder(
              itemCount: controller.history.length,
              itemBuilder: (context, index) {
                final workout =
                    controller.history[controller.history.length - index - 1];
                return HistoryWorkout(workout: workout);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class HistoryWorkout extends StatelessWidget {
  final Workout workout;
  final int showExercises;

  const HistoryWorkout(
      {required this.workout, this.showExercises = 5, super.key});

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
                                              text: DateFormat.yMd(context
                                                      .locale.languageCode)
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
              for (final exercise in workout.exercises.take(showExercises))
                ExerciseListTile(
                  exercise: exercise,
                  selected: false,
                  isConcrete: true,
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
