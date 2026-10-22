import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/controller/workout_controller.dart';
import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/gen/colors.gen.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/model/exercisable.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/model/superset.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/provider/bootstrap.dart';
import 'package:gymtracker/provider/locale.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/struct/editor_callback.dart';
import 'package:gymtracker/utils/constants.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/utils/utils.dart';
import 'package:gymtracker/view/components/rich_text_dialog.dart';
import 'package:gymtracker/view/exercise_picker.dart';
import 'package:gymtracker/view/utils/exercises_to_superset.dart';
import 'package:gymtracker/view/utils/workout_done.dart';
import 'package:gymtracker/view/utils/workout_generator.dart';
import 'package:gymtracker/view/utils/workout_navigation.dart';
import 'package:gymtracker/view/workout.dart';

// ignore_for_file: use_build_context_synchronously

extension WorkoutPresentation on WorkoutController {
  EditorCallbacks get callbacks => EditorCallbacks.editor(
    onExerciseProgressionChange: onExerciseProgressionChange,
    onExerciseReorder: onExerciseReorder,
    onExerciseReplace: onExerciseReplace,
    onExerciseRemove: onExerciseRemove,
    onExerciseChangeRestTime: onExerciseChangeRestTime,
    onSetChangeRPE: onSetChangeRPE,
    onExerciseSetReorder: onExerciseSetReorder,
    onSetCreate: onSetCreate,
    onSetRemove: onSetRemove,
    onSetSelectKind: onSetSelectKind,
    onSetSetDone: onSetSetDone,
    onSetValueChange: onSetValueChange,
    onExerciseNotesChange: onExerciseNotesChange,
    onSupersetAddExercise: onSupersetAddExercise,
    onGroupExercisesIntoSuperset: onGroupExercisesIntoSuperset,
  );

  Future<void> onExerciseReorder(int? supersetIndex) async {
    final generation = sessionGeneration;
    final target = supersetIndex == null
        ? exercises
        : (exercises[supersetIndex] as Superset).exercises
              as List<WorkoutExercisable>;
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      if (!isSessionActive(generation)) return;
      final newIndices = await showDialog<List<int>>(
        builder: (context) => WorkoutExerciseReorderDialog(exercises: target),
        context: Go.context!,
      );
      if (!isSessionActive(generation)) return;
      if (newIndices == null || newIndices.length != target.length) {
        return;
      }

      if (supersetIndex == null) {
        setExercises([
          for (int i = 0; i < newIndices.length; i++) target[newIndices[i]],
        ]);
      } else {
        exercises[supersetIndex] = (exercises[supersetIndex] as Superset)
            .copyWith(
              exercises: [
                for (int i = 0; i < newIndices.length; i++)
                  target[newIndices[i]] as Exercise,
              ],
            );
      }
    });
    publishExercises();
    save();
  }

  void onExerciseReplace(ExerciseIndex index) {
    final generation = sessionGeneration;
    final (exerciseIndex: i, supersetIndex: supersetIndex) = index;
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      if (!isSessionActive(generation)) return;
      final old = supersetIndex == null
          ? exercises[i]
          : (exercises[supersetIndex] as Superset).exercises[i];
      final ex = await Go.to<List<Exercise>>(
        () => const ExercisePicker(singlePick: true),
      );
      if (!isSessionActive(generation)) return;
      if (ex == null || ex.isEmpty) return;
      final newExercise =
          (old is Exercise
                  ? Exercise.replaced(from: old, to: ex.first.makeChild())
                  : ex.first.makeChild().copyWith(
                      sets: [
                        if (!ex.first.parameters.isSetless)
                          GTSet.empty(
                            kind: GTSetKind.normal,
                            parameters: ex.first.parameters,
                          ),
                      ],
                    ))
              .copyWith
              .supersedesID(old.supersedesID);
      if (supersetIndex == null) {
        exercises[i] = newExercise;
      } else {
        exercises[supersetIndex] = (exercises[supersetIndex] as Superset)
            .copyWith(
              exercises: [
                for (
                  int j = 0;
                  j < (exercises[supersetIndex] as Superset).exercises.length;
                  j++
                )
                  if (j == i)
                    newExercise
                  else
                    (exercises[supersetIndex] as Superset).exercises[j],
              ],
            );
      }
      publishExercises();
      save();
    });
  }

  void onSupersetAddExercise(int supersetIndex) {
    final generation = sessionGeneration;
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      if (!isSessionActive(generation)) return;
      pickExercisesForSuperset(supersetIndex);
    });
  }

  Future<void> onGroupExercisesIntoSuperset(int startingIndex) async {
    final generation = sessionGeneration;
    final indices = await Go.toDialog(
      () => ExercisesToSupersetDialog(
        exercises: exercises,
        startingIndex: startingIndex,
      ),
    );

    if (!isSessionActive(generation)) return;
    if (indices == null || indices.length < 2) return;

    final newSuperset = Superset(
      restTime: Duration.zero,
      workoutID: null,
      exercises: [for (final index in indices) exercises[index] as Exercise],
    );

    final newExercises = [
      for (int i = 0; i < indices.first; i++) exercises[i],
      newSuperset,
      for (int i = indices.last + 1; i < exercises.length; i++) exercises[i],
    ];

    setExercises(newExercises);
    publishExercises();
    save();
  }

  void cancelWorkoutWithDialog(
    BuildContext context, {
    required void Function() onCanceled,
  }) {
    final generation = sessionGeneration;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: const Icon(GTIcons.info),
          title: Text(context.t.ongoingWorkout.cancel.title),
          content: Text(context.t.ongoingWorkout.cancel.text),
          actions: [
            TextButton(
              onPressed: () {
                Go.back();
              },
              child: Text(context.t.ongoingWorkout.cancel.actions.no),
            ),
            FilledButton.tonal(
              onPressed: () async {
                Go.back();
                if (!isSessionActive(generation)) return;
                unawaited(cancel());

                onCanceled();
              },
              child: Text(context.t.ongoingWorkout.cancel.actions.yes),
            ),
          ],
        );
      },
    );
  }

  void finishWorkoutWithDialog(BuildContext context) {
    final generation = sessionGeneration;
    generateNameIfEmpty();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!isSessionActive(generation)) return;
      Go.showBottomModalScreen((context, _) => const WorkoutFinishPage());
    });
  }

  Future<void> askToUpdateRoutine(
    Workout workout, {
    required HistoryController history,
    required RoutinesController routinesController,
    required Translations t,
    required String? expectedOwner,
  }) async {
    if (routinesController.service.db.currentUserId != expectedOwner) return;
    if (workout.isContinuation) {
      final orig = workout.originalWorkoutForContinuationIn(history.history)!;
      workout = SynthesizedWorkout([
        orig.copyWith(completedBy: workout.id),
        workout.copyWith(completes: orig.id),
      ]);
    }

    if (workout.parentID != null &&
        routinesController.hasRoutine(workout.parentID!)) {
      final routine = routinesController.getRoutine(workout.parentID!);
      final difference = WorkoutDifference.fromWorkouts(
        oldWorkout: routine!,
        newWorkout: workout,
      );
      if (!difference.isEmpty) {
        final confirm = await Go.confirm(
          t.ongoingWorkout.updateRoutine.differenceTitle,
          () {
            String text =
                "${t.ongoingWorkout.updateRoutine.differenceText}\n\n";
            if (difference.addedExercises > 0) {
              text +=
                  "- ${t.ongoingWorkout.updateRoutine.differences.added(n: difference.addedExercises)}\n";
            }
            if (difference.removedExercises > 0) {
              text +=
                  "- ${t.ongoingWorkout.updateRoutine.differences.removed(n: difference.removedExercises)}\n";
            }
            if (difference.changedExercises > 0) {
              text +=
                  "- ${t.ongoingWorkout.updateRoutine.differences.changed(n: difference.changedExercises)}\n";
            }

            return text.trim();
          }(),
        );
        if (confirm &&
            routinesController.service.db.currentUserId == expectedOwner) {
          await routinesController.updateRoutineFromWorkout(
            workout.parentID!,
            workout,
          );
        }
      }
    }
  }

  Future<void> pickExercises() async {
    final generation = sessionGeneration;
    final exs = await Go.to<List<Exercise>>(
      () => const ExercisePicker(singlePick: false),
    );
    if (!isSessionActive(generation)) return;
    if (exs == null || exs.isEmpty) return;
    exercises.addAll(
      exs
          .map(
            (ex) => ex.makeChild().copyWith.sets([
              if (!ex.parameters.isSetless)
                GTSet.empty(kind: GTSetKind.normal, parameters: ex.parameters),
            ]),
          )
          .toList(),
    );
    publishExercises();
    save();
  }

  Future<void> pickExercisesForSuperset(int i) async {
    final generation = sessionGeneration;
    final exs = await Go.to<List<Exercise>>(
      () => const ExercisePicker(singlePick: false),
    );
    if (!isSessionActive(generation)) return;
    if (exs == null || exs.isEmpty) return;

    final superset = exercises[i] as Superset;
    exercises[i] = superset.copyWith(
      exercises: [
        ...superset.exercises,
        ...exs.map(
          (ex) => ex.makeChild().copyWith.sets([
            if (!ex.parameters.isSetless)
              GTSet.empty(kind: GTSetKind.normal, parameters: ex.parameters),
          ]),
        ),
      ],
    );

    publishExercises();
    save();
  }

  void showEditNotesDialog() {
    final generation = sessionGeneration;
    final controller = quillControllerFromText(infobox);
    Go.toDialog(
      () => GTRichTextEditDialog(
        controller: controller,
        onNotesChange: (text) {
          if (!isSessionActive(generation)) return;
          setInfobox(text);
          save();
          Go.back();
        },
      ),
    );
  }

  void changeWeightUnitDialog() {
    final generation = sessionGeneration;
    Go.showRadioModal(
      selectedValue: weightUnit,
      title: Text(t.ongoingWorkout.actions.changeWeightUnit),
      values: {
        for (final val in Weights.values)
          val: t.weightUnits[val.name] ?? "UNKNOWN",
      },
      onChange: (value) {
        if (!isSessionActive(generation)) return;
        logger.w("Changing weight unit to $value");
        if (value != null) setWeightUnit(value);
        save();
      },
    );
  }

  void changeDistanceUnitDialog() {
    final generation = sessionGeneration;
    Go.showRadioModal(
      selectedValue: distanceUnit,
      title: Text(t.ongoingWorkout.actions.changeDistanceUnit),
      values: {
        for (final distance in Distance.values)
          distance: t.distanceUnits[distance.name] ?? "UNKNOWN",
      },
      onChange: (value) {
        if (!isSessionActive(generation)) return;
        logger.i("Changing distance unit to $value");
        if (value != null) setDistanceUnit(value);
        save();
      },
    );
  }

  void onNotificationTapped(
    NotificationResponse value, {
    required bool simple,
  }) {
    logger.t((value.id, NotificationIDs.restTimer));
    if (value.id == NotificationIDs.restTimer) {
      logger.t((Go.getTopmostRouteName(), WorkoutView.routeName));
      if (!isWorkoutRouteName(Go.getTopmostRouteName())) {
        Go.toNamed(getPreferredWorkoutRouteName(simple: simple));
      }
    }
  }

  void generateWorkout() async {
    final generation = sessionGeneration;
    if (this.exercises.isNotEmpty) {
      return;
    }

    final _res = await Go.toDialog<(Set<GTMuscleGroup>, Set<GTGymEquipment>)>(
      () => const WorkoutGeneratorSetupScreen(),
    );
    if (!isSessionActive(generation)) return;
    if (_res == null) return;

    final (muscleGroups, equipment) = _res;
    final exercises = generateWorkoutExercises(
      muscleGroups: muscleGroups,
      equipment: equipment,
    );

    if (exercises.isEmpty) {
      Go.dialog("workoutGenerator.empty.title", "workoutGenerator.empty.text");
      return;
    }

    this.exercises.addAll(exercises);
    publishExercises();

    final context = Go.context;
    final onThemedColor = context == null
            ? null
            : getOnThemedColor(context, GTColors.ai),
        themedColor = context == null
            ? null
            : getThemedColor(context, GTColors.ai),
        containerColor = context == null
            ? null
            : getContainerColor(context, GTColors.ai),
        onContainerColor = context == null
            ? null
            : getOnContainerColor(context, GTColors.ai);

    Go.snack(
      ListTile(
        leading: const Icon(GTIcons.generate),
        title: Text(t.workoutGenerator.success.title),
        textColor: onContainerColor,
        iconColor: onContainerColor,
      ),
      backgroundColor: containerColor,
      action: SnackBarAction(
        label: t.workoutGenerator.success.undo,
        backgroundColor: themedColor,
        textColor: onThemedColor,
        onPressed: () {
          if (!isSessionActive(generation)) return;
          setExercises([]);
        },
      ),
      duration: const Duration(milliseconds: 2250) * exercises.length,
    );
  }

  Future<void> submitWithPresentation(
    String name,
    Duration duration, {
    required WidgetRef ref,
  }) async {
    final generation = sessionGeneration;
    final owner = ownerId;
    final routines = ref.read(routinesControllerProvider);
    final history = ref.read(historyControllerProvider);
    final translations = ref.read(translationsProvider);
    final backups = ref.read(backupSchedulerProvider);
    final workout = await submit(name, duration);
    if (!isSessionActive(generation)) return;
    Go.back();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      if (!isSessionActive(generation)) return;
      Go.back();
      await cancel(saveHealthWorkout: true);
      final completionGeneration = sessionGeneration;
      await askToUpdateRoutine(
        workout,
        history: history,
        routinesController: routines,
        t: translations,
        expectedOwner: owner,
      );
      if (sessionGeneration != completionGeneration ||
          routines.service.db.currentUserId != owner) {
        return;
      }
      await routines.advanceProgressionsFromWorkout(workout);

      if (workout.doneSets.isNotEmpty) {
        await Go.showBottomModalScreen(
          (context, controller) =>
              WorkoutDoneSheet(workout: workout, controller: controller),
        );
      }

      // Always keep at the very end
      backups.schedule();
    });
  }
}
