import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/coordinator.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/controller/history_controller.dart' as history;
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/model/exercisable.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/superset.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/charts/bar_charts.dart';
import 'package:gymtracker/view/charts/line_charts_by_workout.dart';
import 'package:gymtracker/view/components/badges.dart';
import 'package:gymtracker/view/components/exercise_set_view.dart';
import 'package:gymtracker/view/components/infobox.dart';
import 'package:gymtracker/view/components/maybe_rich_text.dart';
import 'package:gymtracker/view/components/parent_viewer.dart';
import 'package:gymtracker/view/components/stats.dart';
import 'package:gymtracker/view/routine_creator.dart';
import 'package:gymtracker/view/utils/exercise.dart';
import 'package:gymtracker/view/utils/timer.dart';
import 'package:gymtracker/view/utils/workout_utils.dart';
import 'package:gymtracker/view/workout_editor.dart';

class ExercisesView extends StatefulWidget {
  final Workout workout;
  final bool Function(WorkoutExercisable) highlightExercise;

  const ExercisesView({
    required this.workout,
    this.highlightExercise = _highlightExercise,
    super.key,
  });

  static bool _highlightExercise(WorkoutExercisable exercise) {
    return false;
  }

  @override
  State<ExercisesView> createState() => _ExercisesViewState();
}

class _ExercisesViewState extends State<ExercisesView> {
  late Workout workout = widget.workout;

  RoutinesController get controller => Get.find<RoutinesController>();

  @override
  Widget build(BuildContext context) {
    final charts = [
      if (RoutineHistoryChart.shouldShow(workout))
        Padding(
          padding: const EdgeInsets.all(16),
          child: RoutineHistoryChart(routine: workout),
        ),
      if (WeightDistributionBarChart.shouldShow(_getSynthesizedWorkout()))
        Padding(
          padding: const EdgeInsets.all(16),
          child: WeightDistributionBarChart(
            workout: _getSynthesizedWorkout(),
          ),
        ),
      if (WorkoutMuscleCategoriesBarChart.shouldShow(_getSynthesizedWorkout()))
        Padding(
          padding: const EdgeInsets.all(16),
          child: WorkoutMuscleCategoriesBarChart(
            workout: _getSynthesizedWorkout(),
          ),
        ),
      if (EquipmentDistributionBarChart.shouldShow(_getSynthesizedWorkout()))
        Padding(
          padding: const EdgeInsets.all(16),
          child: EquipmentDistributionBarChart(
            workout: _getSynthesizedWorkout(),
          ),
        ),
    ].separated();

    return Scaffold(
      appBar: AppBar(
        title: Text(workout.name),
        actions: [
          PopupMenuButton(
            key: const Key('menu'),
            itemBuilder: (context) => [
              if (workout.isConcrete) ...[
                PopupMenuItem(
                  key: const Key("save-as-routine"),
                  child: Text("workouts.actions.saveAsRoutine.button".t),
                  onTap: () {
                    Get.find<Coordinator>().saveWorkoutAsRoutine(workout);
                  },
                ),
                PopupMenuItem(
                  key: const Key("edit-workout"),
                  child: Text(
                    "workouts.actions.edit.label".t,
                  ),
                  onTap: () {
                    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                      Go.to(() => WorkoutEditor(baseWorkout: workout));
                    });
                  },
                ),
                if (workout.hasContinuation)
                  PopupMenuItem(
                    key: const Key("edit-workout-cont"),
                    child: Text(
                      "workouts.actions.editContinuation.label".t,
                    ),
                    onTap: () {
                      SchedulerBinding.instance
                          .addPostFrameCallback((timeStamp) {
                        Go.to(() =>
                            WorkoutEditor(baseWorkout: workout.continuation!));
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
                    controller.shareRoutine(workout);
                  },
                ),
                PopupMenuItem(
                  child: Text(
                    "routines.actions.viewHistory".t,
                  ),
                  onTap: () {
                    Get.find<RoutinesController>()
                        .viewHistory(routine: workout);
                  },
                ),
                PopupMenuItem(
                  child: Text("routines.actions.edit".t),
                  onTap: () {
                    SchedulerBinding.instance
                        .addPostFrameCallback((timeStamp) async {
                      final newRoutine = await Go.to<Workout>(
                          () => RoutineCreator(base: workout));

                      logger.d("newRoutine: $newRoutine");

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
        bottom: false,
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
                      if (workout.isConcrete) ...[
                        const Divider(height: 32),
                        WorkoutStatsRow(
                          workout: _getSynthesizedWorkout(),
                        ),
                      ],
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
                      if (controller.isWorkoutContinuable(workout)) ...[
                        const SizedBox(height: 8),
                        FilledButton.tonal(
                          onPressed: () {
                            controller.continueWorkout(context, workout);
                          },
                          child: Text("workouts.actions.continue".t),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            if (charts.isNotEmpty)
              SliverToBoxAdapter(
                child: Card(
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: charts,
                  ),
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
                      highlight: widget.highlightExercise(exercise),
                      weightUnit: workout.weightUnit,
                      distanceUnit: workout.distanceUnit,
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
                  leading:
                      const CircleAvatar(child: Icon(GTIcons.continuation)),
                  title: Text("exercise.continuation.label".t),
                  subtitle: Text("exercise.continuation.description".t),
                  onTap: () {
                    Get.find<HistoryController>().combineWorkoutsFlow(workout);
                  },
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
                        highlight: widget.highlightExercise(exercise),
                        weightUnit: workout.continuation!.weightUnit,
                        distanceUnit: workout.continuation!.distanceUnit,
                      ),
                    );
                  },
                  childCount: workout.continuation!.exercises.length,
                ),
              ),
              if (kDebugMode) ...[
                SliverToBoxAdapter(
                  child: Text(
                    "cont id: ${workout.continuation!.id}",
                    textAlign: TextAlign.center,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Text(
                    "cont parent: ${workout.continuation!.parentID}",
                    textAlign: TextAlign.center,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Text(
                    workout.continuation!.toJson().toPrettyString(),
                    style: const TextStyle(
                      fontFamily: "monospace",
                      fontFamilyFallback: <String>["Menlo", "Courier"],
                    ),
                  ),
                ),
              ],
            ],
            SliverPadding(
              padding: MediaQuery.of(context).padding.copyWith(
                    top: 0,
                    left: 0,
                    right: 0,
                  ),
              sliver: const SliverToBoxAdapter(
                child: SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SynthesizedWorkout _getSynthesizedWorkout() {
    return SynthesizedWorkout([
      workout,
      if (workout.isConcrete && workout.hasContinuation) workout.continuation!,
    ]);
  }

  void rename(String? value) {
    final newWorkout =
        Get.find<history.HistoryController>().rename(workout, newName: value);
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() => workout = newWorkout);
    });
  }
}

class WorkoutStatsRow extends StatelessWidget {
  const WorkoutStatsRow({
    super.key,
    required this.workout,
  });

  final Workout workout;

  @override
  Widget build(BuildContext context) {
    return StatsRow(
      stats: [
        Stats(
          value: TimerView.buildTimeString(
            context,
            workout.duration!,
            builder: (time) => time.text!,
          ),
          label: "exerciseList.stats.time".t,
        ),
        if (workout.liftedWeight > 0)
          Stats(
            value: Weights.convert(
              value: workout.liftedWeight,
              from: workout.weightUnit,
              to: settingsController.weightUnit.value,
            ).userFacingWeight,
            label: "exerciseList.stats.volume".t,
          ),
        if (workout.distanceRun > 0)
          Stats(
            value: Distance.convert(
              value: workout.distanceRun,
              from: workout.distanceUnit,
              to: settingsController.distanceUnit.value,
            ).userFacingDistance,
            label: "exerciseList.stats.distance".t,
          ),
        Stats(
          value: workout.doneSets.length.toString(),
          label: "exerciseList.stats.sets".t,
        ),
      ],
    );
  }
}

class ExerciseDataView extends StatelessWidget {
  const ExerciseDataView({
    super.key,
    required this.exercise,
    required this.workout,
    required this.index,
    required this.isInSuperset,
    required this.highlight,
    required this.weightUnit,
    required this.distanceUnit,
  });

  final WorkoutExercisable exercise;
  final Workout workout;
  final int index;
  final bool isInSuperset;
  final bool highlight;
  final Weights weightUnit;
  final Distance distanceUnit;

  @override
  Widget build(BuildContext context) {
    if (this.exercise is Superset) return _buildSuperset(context);

    assert(this.exercise is! Superset);

    final exercise = this.exercise as Exercise;
    return ColoredBox(
      color: highlight
          ? Theme.of(context).colorScheme.tertiary.withAlpha(0.15 * 255 ~/ 100)
          : Colors.transparent,
      child: Padding(
        padding: EdgeInsets.only(top: highlight ? 8 : 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  ExerciseParentViewGesture(
                    exercise: exercise,
                    child: ExerciseIcon(exercise: exercise),
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
                        if (!isInSuperset && !exercise.parameters.isSetless)
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
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                              ),
                            ),
                            style: const TextStyle(),
                          ),
                        if (kDebugMode) ...[
                          Text(exercise.id),
                          Text("parent: ${exercise.parentID}"),
                          Text("supersede: ${exercise.supersedesID}"),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (workout.isConcrete &&
                ExerciseBadgeRow.shouldShow(exercise)) ...[
              const SizedBox(height: 8),
              ExerciseBadgeRow(exercise: exercise),
            ],
            if (exercise.notes.isNotEmpty)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: MaybeRichText(text: exercise.notes),
              ),
            if (!exercise.parameters.isSetless)
              for (int i = 0; i < exercise.sets.length; i++)
                ExerciseSetView(
                  set: exercise.sets[i],
                  exercise: exercise,
                  isConcrete: workout.isConcrete,
                  alt: i % 2 == 0,
                  weightUnit: weightUnit,
                  distanceUnit: distanceUnit,
                )
            else
              const SizedBox(height: 16),
          ],
        ),
      ),
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
                highlight: highlight,
                weightUnit: weightUnit,
                distanceUnit: distanceUnit,
              ),
            ),
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
      icon: const Icon(GTIcons.info),
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
