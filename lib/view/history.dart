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
    final controller = Get.put(HistoryController());
    return Scaffold(
      body: Obx(
        () => CustomScrollView(
          slivers: [
            SliverAppBar.large(
              title: Text("history.title".tr),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                ListTile.divideTiles(
                  tiles: [
                    for (final workout in controller.history.reversed)
                      HistoryWorkout(workout: workout),
                  ],
                  context: context,
                ).toList(),
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
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
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
                                style: Theme.of(context).textTheme.titleMedium),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("general.exercises".plural(
                                  workout.exercises.length,
                                )),
                                Flexible(
                                  child: TimerView.buildTimeString(
                                    context,
                                    workout.duration!,
                                    builder: (time) => Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: DateFormat.yMd()
                                                .add_Hm()
                                                .format(workout.startingDate!),
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
            for (final exercise in workout.exercises.take(3))
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
    );
  }
}
