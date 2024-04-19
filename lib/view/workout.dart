import 'dart:convert';

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/countdown_controller.dart';
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/controller/stopwatch_controller.dart';
import 'package:gymtracker/controller/workout_controller.dart';
import 'package:gymtracker/model/exercisable.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/model/superset.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/utils/constants.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/utils/utils.dart';
import 'package:gymtracker/view/components/infobox.dart';
import 'package:gymtracker/view/components/rich_text_editor.dart';
import 'package:gymtracker/view/components/split_button.dart';
import 'package:gymtracker/view/exercise_picker.dart';
import 'package:gymtracker/view/utils/crossfade.dart';
import 'package:gymtracker/view/utils/date_field.dart';
import 'package:gymtracker/view/utils/exercise.dart';
import 'package:gymtracker/view/utils/superset.dart';
import 'package:gymtracker/view/utils/time.dart';
import 'package:gymtracker/view/utils/timer.dart';
import 'package:gymtracker/view/utils/weight_calculator.dart';
import 'package:gymtracker/view/utils/workout.dart';
import 'package:gymtracker/view/utils/workout_done.dart';

WorkoutController get _controller {
  if (Get.isRegistered<WorkoutController>()) {
    return Get.find<WorkoutController>();
  }

  return Get.put(WorkoutController("Untitled workout", null, null));
}

WorkoutController? get safeController {
  if (Get.isRegistered<WorkoutController>()) {
    return Get.find<WorkoutController>();
  }
}

class WorkoutView extends StatefulWidget {
  const WorkoutView({super.key});

  @override
  State<WorkoutView> createState() => _WorkoutViewState();
}

class _WorkoutViewState extends State<WorkoutView> {
  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();

    try {
      Get.find<WorkoutController>().save();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final countdownController = Get.find<CountdownController>();
    final stopwatchController = Get.find<StopwatchController>();

    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          if (stopwatchController.globalStopwatch.isStopped.isFalse ||
              stopwatchController.globalStopwatch.currentDuration.inSeconds >
                  0) {
            return TimerView(
              builder: (ctx, _) {
                return Text.rich(
                  TimerView.buildTimeString(
                    context,
                    stopwatchController.globalStopwatch.currentDuration,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary),
                    builder: (time) => TextSpan(
                      children: [
                        TextSpan(
                          children: [
                            WidgetSpan(
                              child: Icon(
                                Icons.timer,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              alignment: PlaceholderAlignment.middle,
                            ),
                            const TextSpan(text: " "),
                            time,
                          ],
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              startingTime: DateTime.now(),
            );
          }
          return Text("ongoingWorkout.title".t);
        }),
        actions: [
          IconButton(
            tooltip: "ongoingWorkout.stopwatch.label".t,
            icon: const Icon(Icons.timer),
            onPressed: () {
              GlobalStopwatch getStopwatch() =>
                  stopwatchController.globalStopwatch;
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("ongoingWorkout.stopwatch.label".t),
                  content: TimerView(
                    startingTime: DateTime.now(),
                    builder: (context, _) {
                      return Obx(
                        () => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TimerView.buildTimeString(
                              context,
                              getStopwatch().currentDuration,
                              style: Theme.of(context).textTheme.displaySmall,
                            ),
                            const SizedBox(height: 16),
                            OverflowBar(
                              alignment: MainAxisAlignment.end,
                              overflowAlignment: OverflowBarAlignment.end,
                              children: [
                                if (getStopwatch().isStopped())
                                  TextButton.icon(
                                    key: const Key("start"),
                                    icon: const Icon(Icons.play_arrow_rounded),
                                    label: Text(
                                        "ongoingWorkout.stopwatch.start".t),
                                    onPressed: () {
                                      getStopwatch().start();
                                    },
                                  )
                                else
                                  TextButton.icon(
                                    key: const Key("pause"),
                                    icon: const Icon(Icons.pause_rounded),
                                    label: Text(
                                        "ongoingWorkout.stopwatch.pause".t),
                                    onPressed: () {
                                      getStopwatch().pause();
                                    },
                                  ),
                                if (getStopwatch().isStopped() &&
                                    getStopwatch().currentDuration.inSeconds >
                                        0)
                                  TextButton.icon(
                                    key: const Key("reset"),
                                    icon: const Icon(Icons.replay_rounded),
                                    label: Text(
                                        "ongoingWorkout.stopwatch.reset".t),
                                    onPressed: () {
                                      getStopwatch().reset();
                                    },
                                  ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
          IconButton(
            tooltip: "ongoingWorkout.weightCalculator".t,
            icon: const Icon(Icons.calculate),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => WeightCalculator(
                  weightUnit: _controller.weightUnit.value,
                ),
              );
            },
          ),
          PopupMenuButton(
            key: const Key("main-menu"),
            itemBuilder: (context) => <PopupMenuEntry<dynamic>>[
              PopupMenuItem(
                child: Text(
                  "ongoingWorkout.actions.finish".t,
                ),
                onTap: () {
                  SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                    _controller.finishWorkoutWithDialog(context);
                  });
                },
              ),
              PopupMenuItem(
                child: Text(
                  "ongoingWorkout.actions.cancel".t,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                onTap: () {
                  SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                    _controller.cancelWorkoutWithDialog(context,
                        onCanceled: () {
                      SchedulerBinding.instance
                          .addPostFrameCallback((timeStamp) {
                        Get.back(closeOverlays: true);
                        Get.delete<WorkoutController>();
                      });
                    });
                  });
                },
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                child: Text(
                  "ongoingWorkout.actions.changeWeightUnit".t,
                ),
                onTap: () {
                  _controller.changeWeightUnitDialog();
                },
              ),
              PopupMenuItem(
                child: Text(
                  "ongoingWorkout.actions.changeDistanceUnit".t,
                ),
                onTap: () {
                  _controller.changeDistanceUnitDialog();
                },
              ),
              if (kDebugMode)
                PopupMenuItem(
                  child: const Text("Show Good Job dialog"),
                  onTap: () {
                    Go.showBottomModalScreen(
                      (_, controller) => WorkoutDoneSheet(
                        workout: safeController!.generateWorkout("").copyWith(
                              duration: const Duration(minutes: 1),
                            ),
                        controller: controller,
                      ),
                    );
                  },
                ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size(
              10, (AppBarTheme.of(context).toolbarHeight ?? kToolbarHeight)),
          child: const WorkoutInfoBar(),
        ),
      ),
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: Obx(() {
        return Crossfade(
          firstChild: const SizedBox.shrink(),
          secondChild: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [WorkoutTimerView()],
          ),
          showSecond: countdownController.isActive,
        );
      }),
      body: SafeArea(
        bottom: false,
        child: Obx(
          () {
            if (safeController != null &&
                Workout.shouldShowAsInfobox(safeController!.infobox())) {
              return _buildListView();
            }
            return CustomMaterialIndicator(
              onRefresh: () async {
                _controller.showEditNotesDialog();
              },
              indicatorBuilder: (context, controller) {
                final cardTheme = ContextThemingUtils(context).theme.cardTheme;
                return Container(
                  decoration: BoxDecoration(
                    color: ElevationOverlay.applySurfaceTint(
                      cardTheme.color ??
                          ContextThemingUtils(context).theme.cardColor,
                      cardTheme.surfaceTintColor,
                      cardTheme.elevation ?? 4,
                    ),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.note_add_rounded,
                    color: context.colorScheme.primary,
                  ),
                );
              },
              child: _buildListView(),
            );
          },
        ),
      ),
    );
  }

  ListView _buildListView() {
    final countdownController = Get.find<CountdownController>();
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8) +
          EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom +
                MediaQuery.of(context).padding.bottom,
          ),
      children: [
        if (Get.isRegistered<WorkoutController>() &&
            Workout.shouldShowAsInfobox(
                Get.find<WorkoutController>().infobox())) ...[
          Infobox(
            text: _controller.infobox()!,
            onLongPress: () {
              _controller.showEditNotesDialog();
            },
          ),
        ],

        // Avoid calling [get controller] in order to avoid
        // recreating it, thus starting a new workout.
        if (Get.find<RoutinesController>().hasOngoingWorkout())
          for (int i = 0; i < (safeController?.exercises.length ?? 0); i++)
            if (_controller.exercises[i] is Exercise)
              WorkoutExerciseEditor(
                key: ValueKey((_controller.exercises[i] as Exercise).id),
                exercise: _controller.exercises[i] as Exercise,
                index: i,
                isCreating: false,
                weightUnit: _controller.weightUnit.value,
                distanceUnit: _controller.distanceUnit.value,
                onReorder: () async {
                  SchedulerBinding.instance
                      .addPostFrameCallback((timeStamp) async {
                    final newIndices = await showDialog<List<int>>(
                      builder: (context) => WorkoutExerciseReorderDialog(
                        exercises: _controller.exercises,
                      ),
                      context: context,
                    );
                    if (newIndices == null ||
                        newIndices.length != _controller.exercises.length) {
                      return;
                    }
                    _controller.exercises([
                      for (int i = 0; i < newIndices.length; i++)
                        _controller.exercises[newIndices[i]]
                    ]);
                  });
                  _controller.exercises.refresh();
                  _controller.save();
                },
                onReplace: () {
                  SchedulerBinding.instance
                      .addPostFrameCallback((timeStamp) async {
                    final old = _controller.exercises[i] as Exercise;
                    final ex = await Go.to<List<Exercise>>(
                        () => const ExercisePicker(singlePick: true));
                    if (ex == null || ex.isEmpty) return;
                    _controller.exercises[i] = Exercise.replaced(
                      from: old,
                      to: ex.first.makeChild(),
                    );
                    _controller.exercises.refresh();
                    _controller.save();
                  });
                },
                onRemove: () {
                  _controller.exercises.removeAt(i);
                  _controller.exercises.refresh();
                  _controller.save();
                },
                onChangeRestTime: (value) {
                  (_controller.exercises[i] as Exercise).restTime = value;
                  _controller.exercises.refresh();
                  _controller.save();
                },
                onSetCreate: () {
                  _controller.exercises[i].sets.add(GTSet.empty(
                    kind: GTSetKind.normal,
                    parameters:
                        (_controller.exercises[i] as Exercise).parameters,
                  ));
                  _controller.exercises.refresh();
                  _controller.save();
                },
                onSetRemove: (index) {
                  setState(() {
                    _controller.exercises[i].sets.removeAt(index);
                    _controller.exercises.refresh();
                    _controller.save();
                  });
                },
                onSetSelectKind: (set, kind) {
                  set.kind = kind;
                  _controller.exercises.refresh();
                  _controller.save();
                },
                onSetSetDone: (exercise, set, done) {
                  set.done = done;
                  if (done) {
                    if (exercise.restTime.inSeconds > 0) {
                      countdownController.setCountdown(exercise.restTime);
                    }
                  }
                  _controller.save();
                  _controller.exercises.refresh();
                },
                onSetValueChange: () {
                  _controller.exercises.refresh();
                  _controller.save();
                },
                onNotesChange: (exercise, notes) {
                  exercise.notes = notes;
                  _controller.exercises.refresh();
                  _controller.save();
                },
              )
            else
              SupersetEditor(
                superset: _controller.exercises[i] as Superset,
                index: i,
                isCreating: false,
                key: ValueKey((_controller.exercises[i] as Superset).id),
                weightUnit: _controller.weightUnit.value,
                distanceUnit: _controller.distanceUnit.value,
                onSupersetRemove: () {
                  _controller.exercises.removeAt(i);
                  _controller.exercises.refresh();
                  _controller.save();
                },
                onSupersetReorder: () {
                  SchedulerBinding.instance
                      .addPostFrameCallback((timeStamp) async {
                    final newIndices = await showDialog<List<int>>(
                      builder: (context) => WorkoutExerciseReorderDialog(
                        exercises: _controller.exercises,
                      ),
                      context: context,
                    );
                    if (newIndices == null ||
                        newIndices.length != _controller.exercises.length) {
                      return;
                    }
                    _controller.exercises([
                      for (int i = 0; i < newIndices.length; i++)
                        _controller.exercises[newIndices[i]]
                    ]);
                  });
                },
                onSupersetReplace: () {
                  SchedulerBinding.instance
                      .addPostFrameCallback((timeStamp) async {
                    final ex = await Go.to<List<Exercise>>(
                        () => const ExercisePicker(singlePick: true));
                    if (ex == null || ex.isEmpty) return;
                    _controller.exercises[i] =
                        ex.first.makeChild().copyWith.sets([
                      GTSet.empty(
                        kind: GTSetKind.normal,
                        parameters: ex.first.parameters,
                      ),
                    ]);
                    _controller.exercises.refresh();
                    _controller.save();
                  });
                },
                onSupersetChangeRestTime: (time) {
                  (_controller.exercises[i] as Superset).restTime = time;
                  _controller.exercises.refresh();
                  _controller.save();
                },
                onNotesChange: (_, notes) {
                  (_controller.exercises[i] as Superset).notes = notes;
                  _controller.exercises.refresh();
                  _controller.save();
                },
                onExerciseAdd: () {
                  SchedulerBinding.instance
                      .addPostFrameCallback((timeStamp) async {
                    _controller.pickExercisesForSuperset(i);
                  });
                },
                onExerciseRemove: (index) {
                  setState(() {
                    (_controller.exercises[i] as Superset)
                        .exercises
                        .removeAt(index);
                    _controller.exercises.refresh();
                    _controller.save();
                  });
                },
                onExerciseReorder: (_) {
                  SchedulerBinding.instance
                      .addPostFrameCallback((timeStamp) async {
                    final exercises = (_controller.exercises[i] as Superset)
                        .exercises
                        .cast<Exercise>();
                    final newIndices = await showDialog<List<int>>(
                      builder: (context) => WorkoutExerciseReorderDialog(
                        exercises: exercises,
                      ),
                      context: context,
                    );
                    if (newIndices == null ||
                        newIndices.length != exercises.length) {
                      return;
                    }
                    _controller.exercises[i] =
                        (_controller.exercises[i] as Superset)
                            .copyWith
                            .exercises([
                      for (int j = 0; j < newIndices.length; j++)
                        (_controller.exercises[i] as Superset)
                            .exercises[newIndices[j]]
                    ]);
                  });
                  _controller.save();
                  _controller.exercises.refresh();
                },
                onExerciseReorderIndexed: (_, __) {},
                onExerciseReplace: (index) {
                  SchedulerBinding.instance
                      .addPostFrameCallback((timeStamp) async {
                    final old =
                        (_controller.exercises[i] as Superset).exercises[index];
                    final ex = await Go.to<List<Exercise>>(
                        () => const ExercisePicker(singlePick: true));
                    if (ex == null || ex.isEmpty) return;
                    (_controller.exercises[i] as Superset).exercises[index] =
                        Exercise.replaced(
                      from: old,
                      to: ex.first.makeChild(),
                    );
                    _controller.exercises.refresh();
                    _controller.save();
                  });
                },
                onExerciseSetCreate: (index) {
                  (_controller.exercises[i] as Superset)
                      .exercises[index]
                      .sets
                      .add(GTSet.empty(
                        kind: GTSetKind.normal,
                        parameters: (_controller.exercises[i] as Superset)
                            .exercises[index]
                            .parameters,
                      ));
                  _controller.exercises.refresh();
                  _controller.save();
                },
                onExerciseSetRemove: (index, setIndex) {
                  setState(() {
                    (_controller.exercises[i] as Superset)
                        .exercises[index]
                        .sets
                        .removeAt(setIndex);
                    _controller.exercises.refresh();
                    _controller.save();
                  });
                },
                onExerciseSetSelectKind: (index, set, kind) {
                  set.kind = kind;
                  _controller.exercises.refresh();
                  _controller.save();
                },
                onExerciseSetSetDone: (exercise, set, done) {
                  final superset = _controller.exercises[i] as Superset;
                  set.done = done;
                  if (done) {
                    final index =
                        superset.exercises.findExerciseIndex(exercise);
                    if (index == superset.exercises.length - 1 &&
                        superset.restTime.inSeconds > 0) {
                      countdownController.setCountdown(superset.restTime);
                    }
                  }
                  _controller.save();
                  _controller.exercises.refresh();
                },
                onExerciseSetValueChange: () {
                  _controller.exercises.refresh();
                  _controller.save();
                },
                onExerciseChangeRestTime: (index, time) {
                  // Currently unsupported
                },
                onExerciseNotesChange: (exercise, notes) {
                  exercise.notes = notes;
                  _controller.exercises.refresh();
                  _controller.save();
                },
              ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: SplitButton(segments: [
            SplitButtonSegment(
              title: 'ongoingWorkout.exercises.add'.t,
              type: SplitButtonSegmentType.filled,
              onTap: () async {
                _controller.pickExercises();
              },
            ),
            SplitButtonSegment(
              title: "ongoingWorkout.exercises.addSuperset".t,
              onTap: () {
                _controller.exercises.add(Superset.empty());
                _controller.exercises.refresh();
              },
            ),
          ]),
        ),
      ],
    );
  }
}

class WorkoutInfoBar extends StatelessWidget {
  const WorkoutInfoBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 16),
          child: Row(
            children: [
              Obx(
                () {
                  if (safeController == null) return const SizedBox.shrink();
                  return TimerView(
                    startingTime: safeController!.time.value,
                    builder: (context, text) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "ongoingWorkout.info.time".t,
                            style: Theme.of(context).textTheme.labelMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Hero(
                            tag: "Ongoing",
                            child: text,
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "ongoingWorkout.info.reps".t,
                    style: Theme.of(context).textTheme.labelMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Obx(
                    () => TweenAnimationBuilder(
                      tween: Tween<double>(
                        begin: 0,
                        end: safeController?.reps.toDouble() ?? 0,
                      ),
                      curve: Curves.decelerate,
                      duration: const Duration(milliseconds: 400),
                      builder: (context, value, _) {
                        return Text("${value.round()}");
                      },
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "ongoingWorkout.info.volume".t,
                    style: Theme.of(context).textTheme.labelMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Obx(
                    () => TweenAnimationBuilder(
                      tween: Tween<double>(
                        begin: 0,
                        end: safeController?.liftedWeight ?? 0,
                      ),
                      curve: Curves.decelerate,
                      duration: const Duration(milliseconds: 400),
                      builder: (context, value, _) {
                        if (doubleIsActuallyInt(
                            safeController?.liftedWeight ?? 0)) {
                          return Text("${value.round()}");
                        }
                        return Text(stringifyDouble(value));
                      },
                    ),
                  ),
                ],
              ),
            ].map((w) => Expanded(child: w)).toList(),
          ),
        ),
        Obx(
          () => TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 300),
            curve: Curves.linearToEaseOut,
            tween: Tween<double>(
              begin: 0,
              end: safeController?.progress ?? 0,
            ),
            builder: (context, value, _) => LinearProgressIndicator(
              value: value,
            ),
          ),
        ),
      ],
    );
  }
}

class WorkoutTimerView extends StatelessWidget {
  const WorkoutTimerView({super.key});

  @override
  Widget build(BuildContext context) {
    final countdownController = Get.find<CountdownController>();
    final isPhone = context.width < Breakpoints.xs.screenWidth;

    return Card(
      elevation: 8,
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(13),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        left: false,
        right: false,
        child: Column(
          children: [
            TimerView(
              startingTime: () {
                try {
                  return Get.find<WorkoutController>().time.value;
                } catch (e, s) {
                  logger.e("Error getting workout time",
                      error: e, stackTrace: s);
                  return DateTime.now();
                }
              }(),
              builder: (_, time) {
                return TweenAnimationBuilder(
                  tween: Tween<double>(
                    begin: 1,
                    end: countdownController.progress,
                  ),
                  duration: const Duration(milliseconds: 220),
                  builder: (context, value, child) {
                    return LinearProgressIndicator(value: value);
                  },
                );
              },
            ),
            SafeArea(
              top: false,
              bottom: false,
              child: Container(
                constraints: const BoxConstraints(minHeight: 64),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Center(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Obx(
                          () => TimerView(
                            startingTime: () {
                              try {
                                return Get.find<WorkoutController>().time.value;
                              } catch (e, s) {
                                logger.e(
                                  "Error getting workout time",
                                  error: e,
                                  stackTrace: s,
                                );
                                return DateTime.now();
                              }
                            }(),
                            builder: (_, time) => TimerView.buildTimeString(
                              context,
                              countdownController.remaining,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Text(
                          "timer.subtract15s".t,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        onPressed: () =>
                            countdownController.subtract15Seconds(),
                      ),
                      IconButton(
                        icon: Text(
                          "timer.add15s".t,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                        onPressed: () => countdownController.add15Seconds(),
                      ),
                      Crossfade(
                        firstChild: TextButton.icon(
                          onPressed: skipCountdown,
                          icon: const Icon(Icons.skip_next_rounded),
                          clipBehavior: Clip.hardEdge,
                          label: Text(
                            "timer.skip".t,
                            overflow: TextOverflow.clip,
                            maxLines: 1,
                          ),
                        ),
                        secondChild: IconButton(
                          onPressed: skipCountdown,
                          icon: Icon(
                            Icons.skip_next_rounded,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        showSecond: isPhone,
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void skipCountdown() {
    final countdownController = Get.find<CountdownController>();
    countdownController.removeCountdown();
  }
}

class WorkoutFinishPage extends StatefulWidget {
  const WorkoutFinishPage({super.key});

  @override
  State<WorkoutFinishPage> createState() => _WorkoutFinishPageState();
}

class _WorkoutFinishPageState extends State<WorkoutFinishPage> {
  late Duration workoutDuration;
  final formKey = GlobalKey<FormState>();

  final titleController = TextEditingController(text: _controller.name.value);
  final timeController = TextEditingController(
    text: TimeInputField.encodeDuration(
        DateTime.now().difference(_controller.time.value)),
  );
  final dateController = TextEditingController();
  final infoboxController = QuillController(
    document: (_controller.infobox.value ?? "").asQuillDocument(),
    selection: const TextSelection.collapsed(offset: 0),
  );

  late String? pwInitialItem = () {
    // Parent workout data
    String? pwInitialItem = _controller.parentID.value;
    if (Get.find<RoutinesController>()
        .workouts
        .every((element) => element.id != pwInitialItem)) {
      pwInitialItem = null;
    }

    return pwInitialItem;
  }();

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size(0, kToolbarHeight + 1),
          child: AppBar(
            title: Text("ongoingWorkout.finish.title".t),
            leading: const CloseButton(),
            bottom: const PreferredSize(
              preferredSize: Size(0, 1),
              child: Divider(height: 1),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.check),
                onPressed: _submit,
              )
            ],
          ),
        ),
        body: Form(
          key: formKey,
          child: ListView(
            children: [
              const SizedBox(height: 8),
              TextFormField(
                controller: titleController,
                decoration:
                    _decoration("ongoingWorkout.finish.fields.name.label".t),
                validator: (string) {
                  if (string == null || string.isEmpty) {
                    return "ongoingWorkout.finish.fields.name.errors.empty".t;
                  }
                  return null;
                },
              ),
              DateField(
                decoration: _decoration(
                    "ongoingWorkout.finish.fields.startingTime.label".t),
                date: _controller.time.value,
                onSelect: (date) => setState(() => _controller.time(date)),
                firstDate: DateTime.fromMillisecondsSinceEpoch(0),
                lastDate: DateTime.now().add(const Duration(days: 7)),
              ),
              DropdownButtonFormField<String?>(
                decoration:
                    _decoration("ongoingWorkout.finish.fields.parent.label".t),
                items: [
                  DropdownMenuItem(
                    value: null,
                    child: Text(
                        "ongoingWorkout.finish.fields.parent.options.none".t),
                  ),
                  for (final routine in Get.find<RoutinesController>().workouts)
                    DropdownMenuItem(
                      value: routine.id,
                      child: Text(routine.name),
                    ),
                ],
                onChanged: (v) =>
                    setState(() => _controller.parentID.value = v),
                value: pwInitialItem,
              ),
              TimeInputField(
                controller: timeController,
                decoration: _decoration(
                    "ongoingWorkout.finish.fields.duration.label".t),
                validator: (duration) {
                  if (duration == null || duration.inSeconds == 0) {
                    return "ongoingWorkout.finish.fields.duration.errors.empty"
                        .t;
                  }
                  return null;
                },
              ),
              GTRichTextEditor(
                infoboxController: infoboxController,
                decoration: InputDecoration(
                  isDense: true,
                  border: const OutlineInputBorder(),
                  labelText: "ongoingWorkout.finish.fields.infobox.label".t,
                  alignLabelWithHint: true,
                ),
                onTapOutside: () {
                  logger.d("Quill Editor onTapOutside");
                  _controller.infobox(jsonEncode(
                      infoboxController.document.toDelta().toJson()));
                },
              ),
            ]
                .map((c) => Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 16,
                      ).copyWith(top: 0),
                      child: c,
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      isDense: true,
      border: const OutlineInputBorder(),
      labelText: label,
    );
  }

  void _submit() {
    final isValid = formKey.currentState!.validate();

    if (isValid) {
      _controller.submit(
        titleController.text,
        TimeInputField.parseDuration(timeController.text),
      );
    }
  }
}

class WorkoutExerciseReorderDialog extends StatefulWidget {
  final List<WorkoutExercisable> exercises;

  const WorkoutExerciseReorderDialog({required this.exercises, super.key});

  @override
  State<WorkoutExerciseReorderDialog> createState() =>
      _WorkoutExerciseReorderDialogState();
}

class _WorkoutExerciseReorderDialogState
    extends State<WorkoutExerciseReorderDialog> {
  late List<int> indices = List.generate(widget.exercises.length, (i) => i);

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size(0, kToolbarHeight + 1),
          child: AppBar(
            title: Text("ongoingWorkout.exercises.reorder".t),
            leading: const CloseButton(),
            bottom: const PreferredSize(
              preferredSize: Size(0, 1),
              child: Divider(height: 1),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.check),
                onPressed: _submit,
              )
            ],
          ),
        ),
        body: ReorderableListView.builder(
          itemCount: indices.length,
          itemBuilder: (context, i) {
            final index = indices[i];
            final exercise = widget.exercises[index];
            return ExerciseListTile(
              key: ValueKey(exercise.id),
              exercise: exercise,
              isConcrete: false,
              selected: false,
            );
          },
          onReorder: (oldIndex, newIndex) {
            setState(() {
              reorder(indices, oldIndex, newIndex);
            });
          },
        ),
      ),
    );
  }

  void _submit() {
    Get.back(result: indices);
  }
}
