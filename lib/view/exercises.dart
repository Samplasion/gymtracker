import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/exercises_controller.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/controller/history_controller.dart' as history;
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/model/exercisable.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/model/superset.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/utils/sets.dart';
import 'package:gymtracker/utils/utils.dart';
import 'package:gymtracker/view/charts/routine_history.dart';
import 'package:gymtracker/view/charts/workout_muscle_categories.dart';
import 'package:gymtracker/view/components/badges.dart';
import 'package:gymtracker/view/components/infobox.dart';
import 'package:gymtracker/view/library.dart';
import 'package:gymtracker/view/routine_creator.dart';
import 'package:gymtracker/view/utils/dropdown_dialog.dart';
import 'package:gymtracker/view/utils/exercise.dart';
import 'package:gymtracker/view/utils/textfield_dialog.dart';
import 'package:gymtracker/view/utils/timer.dart';
import 'package:gymtracker/view/utils/workout_utils.dart';
import 'package:gymtracker/view/workout_editor.dart';

class ExercisesView extends StatefulWidget {
  const ExercisesView({required this.workout, super.key});

  final Workout workout;

  @override
  State<ExercisesView> createState() => _ExercisesViewState();
}

class _ExercisesViewState extends State<ExercisesView> {
  late Workout workout = widget.workout;

  RoutinesController get controller => Get.find<RoutinesController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(workout.name),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              if (workout.isConcrete) ...[
                PopupMenuItem(
                  child: Text("workouts.actions.saveAsRoutine.button".t),
                  onTap: () {
                    final newID =
                        Get.find<RoutinesController>().importWorkout(workout);
                    if (workout.parentID == null) {
                      changeParent(newID);
                    }
                    Go.snack("workouts.actions.saveAsRoutine.done".t);
                  },
                ),
                PopupMenuItem(
                  key: const Key("edit-workout"),
                  // TODO: Remove beta status
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "workouts.actions.edit.label".t,
                        ),
                        const TextSpan(text: " "),
                        const WidgetSpan(
                          child: BetaBadge(),
                          alignment: PlaceholderAlignment.middle,
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                      Go.to(() => WorkoutEditor(baseWorkout: workout));
                    });
                  },
                ),
                PopupMenuItem(
                  child: Text("workouts.actions.rename.label".t),
                  onTap: () {
                    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                      showDialog(
                        context: context,
                        builder: (_) {
                          return TextFieldDialog(
                            title: Text("workouts.actions.rename.label".t),
                            initialValue: workout.name,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "workouts.actions.rename.errors.empty".t;
                              }
                              return null;
                            },
                            onDone: (value) {
                              rename(value);
                            },
                          );
                        },
                      );
                    });
                  },
                ),
                PopupMenuItem(
                  child: Text("workouts.actions.changeParent.label".t),
                  onTap: () {
                    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                      String? initialItem = workout.parentID;
                      if (controller.workouts
                          .every((element) => element.id != initialItem)) {
                        initialItem = null;
                      }
                      showDialog(
                        context: context,
                        builder: (_) {
                          return DropdownDialog(
                            title:
                                Text("workouts.actions.changeParent.label".t),
                            items: [
                              DropdownMenuItem(
                                value: null,
                                child: Text(
                                  "workouts.actions.changeParent.options.none"
                                      .t,
                                  style: const TextStyle(
                                      fontStyle: FontStyle.italic),
                                ),
                              ),
                              for (final workout in controller.workouts)
                                DropdownMenuItem(
                                  value: workout.id,
                                  child: Text(workout.name),
                                ),
                            ],
                            initialItem: initialItem,
                            onSelect: (value) {
                              changeParent(value);
                            },
                          );
                        },
                      );
                    });
                  },
                ),
                PopupMenuItem(
                  textStyle: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                  child: Text(
                    "workouts.actions.delete.title".t,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  onTap: () {
                    Get.find<history.HistoryController>()
                        .deleteWorkoutWithDialog(context, workout: workout,
                            onCanceled: () {
                      SchedulerBinding.instance
                          .addPostFrameCallback((timeStamp) {
                        Get.back();
                        Go.snack("workouts.actions.delete.done".t);
                      });
                    });
                  },
                ),
              ] else ...[
                PopupMenuItem(
                  child: Text("workouts.actions.share.button".t),
                  onTap: () {
                    final uri = Uri(
                      scheme: "gymtracker",
                      host: "routine",
                      queryParameters: {
                        "json": jsonEncode(workout.toJson()).compressed,
                      },
                    );
                    controller.shareRoutine(uri);
                  },
                ),
                PopupMenuItem(
                  child: Text("routines.actions.edit".t),
                  onTap: () {
                    SchedulerBinding.instance
                        .addPostFrameCallback((timeStamp) async {
                      final newRoutine = await Go.to<Workout>(
                          () => RoutineCreator(base: workout));

                      if (newRoutine != null) {
                        Get.find<RoutinesController>().editRoutine(newRoutine);
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
                  child: Text(
                    "routines.actions.delete.title".t,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  onTap: () {
                    Get.find<RoutinesController>()
                        .deleteRoutineWithDialog(context, workout: workout,
                            onCanceled: () {
                      SchedulerBinding.instance
                          .addPostFrameCallback((timeStamp) {
                        Get.back();
                        Go.snack("routines.actions.delete.done".t);
                      });
                    });
                  },
                ),
              ],
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Card(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      WorkoutHeader(
                        workout: workout,
                        continuation: workout.continuation,
                      ),
                      const Divider(height: 32),
                      FilledButton(
                        onPressed: () {
                          controller.startRoutine(context, workout);
                        },
                        child: Text(() {
                          if (workout.isConcrete) {
                            return "workouts.actions.start".t;
                          } else {
                            return "routines.actions.start".t;
                          }
                        }()),
                      ),
                      if (controller.isWorkoutContinuable(workout))
                        FilledButton.tonal(
                          onPressed: () {
                            controller.continueWorkout(context, workout);
                          },
                          child: Text("workouts.actions.continue".t),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            if (!workout.isConcrete &&
                controller.getChildren(workout).length >= 2)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: RoutineHistoryChart(routine: workout),
                ),
              ),
            if (WorkoutMuscleCategoriesBarChart.shouldShow(workout))
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: WorkoutMuscleCategoriesBarChart(workout: workout),
                ),
              ),
            if (workout.shouldShowInfobox)
              SliverToBoxAdapter(
                child: Infobox(
                  text: workout.infobox!,
                ),
              ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final exercise = workout.exercises[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: ExerciseDataView(
                      exercise: exercise,
                      workout: workout,
                      index: index,
                      isInSuperset: false,
                      weightUnit: workout.weightUnit,
                    ),
                  );
                },
                childCount: workout.exercises.length,
              ),
            ),
            if (kDebugMode) ...[
              SliverToBoxAdapter(
                child:
                    Text("own id: ${workout.id}", textAlign: TextAlign.center),
              ),
              SliverToBoxAdapter(
                child: Text("parent: ${workout.parentID}",
                    textAlign: TextAlign.center),
              ),
              SliverToBoxAdapter(
                child: Text(
                  workout.toJson().toString(),
                  style: const TextStyle(
                    fontFamily: "monospace",
                    fontFamilyFallback: <String>["Menlo", "Courier"],
                  ),
                ),
              ),
            ],
            if (workout.isContinuation && kDebugMode) ...[
              SliverToBoxAdapter(
                child: ListTile(
                  title: const Text("See original workout"),
                  onTap: () {
                    Go.to(
                      () => ExercisesView(
                        workout: workout.originalWorkoutForContinuation!,
                      ),
                    );
                  },
                ),
              ),
            ],
            if (workout.isConcrete && workout.hasContinuation) ...[
              const SliverToBoxAdapter(child: Divider()),
              SliverToBoxAdapter(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.add)),
                  title: Text("exercise.continuation.label".t),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final exercise = workout.continuation!.exercises[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: ExerciseDataView(
                        exercise: exercise,
                        workout: workout.continuation!,
                        index: index,
                        isInSuperset: false,
                        weightUnit: workout.weightUnit,
                      ),
                    );
                  },
                  childCount: workout.continuation!.exercises.length,
                ),
              ),
              if (kDebugMode)
                SliverToBoxAdapter(
                  child: Text(
                    "cont id: ${workout.continuation!.id}",
                    textAlign: TextAlign.center,
                  ),
                ),
              if (kDebugMode)
                SliverToBoxAdapter(
                  child: Text(
                    "cont parent: ${workout.continuation!.parentID}",
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  void changeParent(String? value) {
    setState(() => workout.parentID = value);
    Get.find<history.HistoryController>()
        .setParentID(workout, newParentID: value);
  }

  void rename(String? value) {
    final newWorkout =
        Get.find<history.HistoryController>().rename(workout, newName: value);
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() => workout = newWorkout);
    });
  }
}

class ExerciseDataView extends StatelessWidget {
  const ExerciseDataView({
    super.key,
    required this.exercise,
    required this.workout,
    required this.index,
    required this.isInSuperset,
    required this.weightUnit,
  });

  final WorkoutExercisable exercise;
  final Workout workout;
  final int index;
  final bool isInSuperset;
  final Weights weightUnit;

  @override
  Widget build(BuildContext context) {
    if (this.exercise is Superset) return _buildSuperset(context);

    assert(this.exercise is! Superset);

    final exercise = this.exercise as Exercise;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              GestureDetector(
                child: ExerciseIcon(exercise: exercise),
                onTap: () {
                  Go.to(() => ExerciseInfoView(
                      exercise: workout.isConcrete
                          ? exercise.parent ?? exercise
                          : exercise));
                },
              ),
              const SizedBox(width: 16),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
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
                      ),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (!isInSuperset)
                      TimerView.buildTimeString(
                        context,
                        workout.exercises[index].restTime,
                        builder: (time) => Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(text: "exerciseList.restTime".t),
                              time
                            ],
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium!
                                .copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ),
                        style: const TextStyle(),
                      ),
                    if (kDebugMode) ...[
                      Text(exercise.id),
                      Text("parent: ${exercise.parentID}"),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        if (exercise.notes.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(exercise.notes),
          ),
        for (int i = 0; i < exercise.sets.length; i++)
          ExerciseSetView(
            set: exercise.sets[i],
            exercise: exercise,
            isConcrete: workout.isConcrete,
            alt: i % 2 == 0,
            weightUnit: weightUnit,
          ),
      ],
    );
  }

  Widget _buildSuperset(BuildContext context) {
    final superset = exercise as Superset;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
                .copyWith(top: 16),
            child: Row(
              children: [
                ExerciseIcon(exercise: superset),
                const SizedBox(width: 16),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                                text: "superset"
                                    .plural(superset.exercises.length)),
                          ],
                        ),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      TimerView.buildTimeString(
                        context,
                        workout.exercises[index].restTime,
                        builder: (time) => Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(text: "exerciseList.restTime".t),
                              time
                            ],
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium!
                                .copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ),
                        style: const TextStyle(),
                      ),
                      if (kDebugMode) ...[
                        Text(superset.id),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (exercise.notes.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(exercise.notes),
            ),
          const Divider(),
          for (final exercise in (this.exercise as Superset).exercises)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ExerciseDataView(
                exercise: exercise,
                workout: workout,
                index: index,
                isInSuperset: true,
                weightUnit: weightUnit,
              ),
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
  final Weights weightUnit;

  const ExerciseSetView({
    required this.set,
    required this.exercise,
    required this.isConcrete,
    required this.alt,
    required this.weightUnit,
    super.key,
  });

  List<Widget> get fields => [
        if ([SetParameters.repsWeight, SetParameters.timeWeight]
            .contains(set.parameters))
          Text(Weights.convert(
            value: set.weight!,
            from: weightUnit,
            to: settingsController.weightUnit.value!,
          ).userFacingWeight),
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
          Text("exerciseList.fields.reps".plural(set.reps ?? 0)),
        if ([SetParameters.distance].contains(set.parameters))
          Text("exerciseList.fields.distance".trParams({
            "distance": stringifyDouble(set.distance!),
            "unit": "units.km".t,
          })),
      ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    var colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: alt
          ? scheme.background.withOpacity(0)
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
      title: Text("ongoingWorkout.overwrite.title".t),
      content: Text(
        "ongoingWorkout.overwrite.text".t,
      ),
      actions: [
        TextButton(
          onPressed: () {
            Get.back(result: false);
          },
          child: Text("ongoingWorkout.overwrite.actions.no".t),
        ),
        FilledButton.tonal(
          onPressed: () {
            Get.back(result: true);
          },
          child: Text("ongoingWorkout.overwrite.actions.yes".t),
        ),
      ],
    );
  }
}
