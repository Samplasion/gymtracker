import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

import '../controller/history_controller.dart';
import '../controller/workouts_controller.dart';
import '../model/exercise.dart';
import '../model/set.dart';
import '../model/workout.dart';
import '../utils/go.dart';
import '../utils/sets.dart';
import '../utils/utils.dart';
import 'routine_creator.dart';
import 'utils/exercise.dart';
import 'utils/timer.dart';

class ExercisesView extends StatefulWidget {
  const ExercisesView({required this.workout, super.key});

  final Workout workout;

  @override
  State<ExercisesView> createState() => _ExercisesViewState();
}

class _ExercisesViewState extends State<ExercisesView> {
  late Workout workout;

  @override
  void initState() {
    super.initState();
    workout = widget.workout;
  }

  WorkoutsController get controller => Get.find<WorkoutsController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(workout.name),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              if (workout.isConcrete)
                PopupMenuItem(
                  textStyle: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                  child: Text("workouts.actions.delete".tr),
                  onTap: () {
                    Get.find<HistoryController>().deleteWorkout(workout);
                    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                      Get.back();
                      Get.back();
                    });
                  },
                )
              else ...[
                PopupMenuItem(
                  child: Text("routines.actions.edit".tr),
                  onTap: () {
                    SchedulerBinding.instance
                        .addPostFrameCallback((timeStamp) async {
                      final newRoutine = await Go.to<Workout>(
                          () => RoutineCreator(base: workout));

                      if (newRoutine != null) {
                        Get.find<WorkoutsController>().editRoutine(newRoutine);
                        setState(() {
                          workout = newRoutine;
                        });
                      }
                    });
                  },
                ),
                PopupMenuItem(
                  textStyle: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                  child: Text("routines.actions.delete".tr),
                  onTap: () {
                    Get.find<WorkoutsController>().deleteWorkout(workout);
                    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                      Get.back();
                      Get.back();
                    });
                  },
                ),
              ],
            ],
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                onPressed: () {
                  controller.startRoutine(context, workout);
                },
                child: Text(() {
                  if (workout.isConcrete) {
                    return "workouts.actions.start".tr;
                  } else {
                    return "routines.actions.start".tr;
                  }
                }()),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final exercise = workout.exercises[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            ExerciseIcon(exercise: exercise),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(exercise.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium),
                                TimerView.buildTimeString(
                                  context,
                                  workout.exercises[index].restTime,
                                  builder: (time) => Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                            text: "exerciseList.restTime".tr),
                                        time
                                      ],
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium!
                                          .copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                    ),
                                  ),
                                  style: const TextStyle(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      for (int i = 0; i < exercise.sets.length; i++)
                        ExerciseSetView(
                          set: exercise.sets[i],
                          exercise: exercise,
                          isConcrete: workout.isConcrete,
                          alt: i % 2 == 0,
                        ),
                    ],
                  ),
                );
              },
              childCount: workout.exercises.length,
            ),
          ),
          if (kDebugMode)
            SliverToBoxAdapter(
              child: Text(workout.id, textAlign: TextAlign.center),
            ),
        ],
      ),
    );
  }
}

class ExerciseSetView extends StatelessWidget {
  final ExSet set;
  final Exercise exercise;
  final bool isConcrete;
  final bool alt;

  const ExerciseSetView({
    required this.set,
    required this.exercise,
    required this.isConcrete,
    required this.alt,
    super.key,
  });

  List<Widget> get fields => [
        if ([SetParameters.repsWeight, SetParameters.timeWeight]
            .contains(set.parameters))
          Text("exerciseList.fields.weight".trParams({
            "weight": stringifyDouble(set.weight!),
            "unit": "units.kg".tr,
          })),
        if ([
          SetParameters.timeWeight,
          SetParameters.time,
        ].contains(set.parameters))
          Text("exerciseList.fields.time".trParams({
            "time":
                "${(set.time!.inSeconds ~/ 60).toString().padLeft(2, "0")}:${(set.time!.inSeconds % 60).toString().padLeft(2, "0")}",
          })),
        if ([SetParameters.repsWeight, SetParameters.freeBodyReps]
            .contains(set.parameters))
          Text("exerciseList.fields.reps_singular".trPlural(
              "exerciseList.fields.reps_plural", set.reps, ["${set.reps}"])),
        if ([SetParameters.distance].contains(set.parameters))
          Text("exerciseList.fields.distance".trParams({
            "distance": stringifyDouble(set.distance!),
            "unit": "units.km".tr,
          })),
      ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    var colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: alt
          ? scheme.background
          : ElevationOverlay.applySurfaceTint(
              scheme.surface,
              scheme.surfaceTint,
              0.7,
            ),
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          PopupMenuButton(
            icon: buildSetType(
              context,
              set.kind,
              set: set,
              allSets: exercise.sets,
            ),
            itemBuilder: (context) => <PopupMenuEntry<SetKind>>[],
            enabled: false,
          ),
          const SizedBox(width: 8),
          for (int i = 0; i < fields.length; i++) ...[
            if (i != 0) const SizedBox(width: 8),
            Expanded(child: fields[i])
          ],
          const SizedBox(width: 8),
          if (isConcrete) ...[
            if (set.done)
              Icon(Icons.check_box, color: colorScheme.tertiary)
            else
              Icon(Icons.check_box_outline_blank,
                  color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class OverwriteDialog extends StatelessWidget {
  const OverwriteDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.info),
      title: Text("ongoingWorkout.overwrite.title".tr),
      content: Text(
        "ongoingWorkout.overwrite.text".tr,
      ),
      actions: [
        TextButton(
          onPressed: () {
            Get.back(result: false);
          },
          child: Text("ongoingWorkout.overwrite.actions.no".tr),
        ),
        FilledButton.tonal(
          onPressed: () {
            Get.back(result: true);
          },
          child: Text("ongoingWorkout.overwrite.actions.yes".tr),
        ),
      ],
    );
  }
}
