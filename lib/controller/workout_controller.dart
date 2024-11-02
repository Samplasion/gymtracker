// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/coordinator.dart';
import 'package:gymtracker/controller/countdown_controller.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/controller/serviceable_controller.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/controller/stopwatch_controller.dart';
import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/data/exercises.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/gen/colors.gen.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/model/exercisable.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/model/superset.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/struct/editor_callback.dart';
import 'package:gymtracker/struct/optional.dart';
import 'package:gymtracker/struct/stopwatch_extended.dart';
import 'package:gymtracker/utils/constants.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/utils/utils.dart';
import 'package:gymtracker/view/components/rich_text_dialog.dart';
import 'package:gymtracker/view/exercise_picker.dart';
import 'package:gymtracker/view/utils/exercises_to_superset.dart';
import 'package:gymtracker/view/utils/workout_done.dart';
import 'package:gymtracker/view/utils/workout_generator.dart';
import 'package:gymtracker/view/workout.dart';

class WorkoutController extends GetxController with ServiceableController {
  RxString name;
  Rx<DateTime> time;
  Rx<String?> parentID;
  Rx<String?> infobox;
  RxBool isContinuation = false.obs;
  Rx<String?> continuesID = Rx(null);
  late Rx<Weights> weightUnit;
  late Rx<Distance> distanceUnit;
  RxList<WorkoutExercisable> exercises = <WorkoutExercisable>[].obs;

  WorkoutController(String name, String? parentID, String? infobox)
      : name = name.obs,
        time = DateTime.now().obs,
        parentID = Rx<String?>(parentID),
        infobox = Rx<String?>(infobox),
        weightUnit = (Get.find<SettingsController>().weightUnit()).obs,
        distanceUnit = (Get.find<SettingsController>().distanceUnit()).obs {
    final sc = Get.find<SettingsController>();
    logger.i("""
      Currently defined units:
        - Weight: \t${sc.weightUnit().name} \t(cfr. ${weightUnit.value.name})
        - Distance: \t${sc.distanceUnit().name} \t(cfr. ${distanceUnit.value.name})
    """);
    logger.w(
      "Created with name $name, parentID $parentID, and infobox $infobox",
      error: Error(),
      stackTrace: StackTrace.current,
    );
  }

  factory WorkoutController.fromSavedData(Map<String, dynamic> data) {
    final cont =
        WorkoutController(data['name'], data['parentID'], data['infobox']);

    cont.exercises((data['exercises'] as List)
        .map((el) => WorkoutExercisable.fromJson(el))
        .toList());
    cont.time(DateTime.fromMillisecondsSinceEpoch(
        data['time'] ?? DateTime.now().millisecondsSinceEpoch));
    cont.continuesID(data['continuesID']);
    cont.isContinuation(data['isContinuation'] ?? false);
    cont.weightUnit(Weights.values.firstWhere(
      (element) => element.name == data['weightUnit'],
      orElse: () => Weights.kg,
    ));
    cont.distanceUnit(Distance.values.firstWhere(
      (element) => element.name == data['distanceUnit'],
      orElse: () => Distance.km,
    ));

    if (data.containsKey("globalStopwatch")) {
      final controller = Get.find<StopwatchController>();

      // Separating the two cases this way avoids a couple of nasty bugs:
      //
      // * If the stopwatch is paused, saving the duration allows us to recover
      //   the stopwatch value without it ticking while the app is closed.
      // * If the stopwatch is running, we actually want to tick while the
      //   app is closed, so we save the starting time and the fact that it's
      //   running.
      // TODO: Test these cases.
      if (data['globalStopwatchPaused'] == false) {
        controller.globalStopwatch.stopwatch = StopwatchEx.fromMilliseconds(
          DateTime.now().millisecondsSinceEpoch -
              (data['globalStopwatch'] as int),
        );
        controller.globalStopwatch.start();
      } else {
        controller.globalStopwatch.stopwatch = StopwatchEx.fromMilliseconds(
          data['globalStopwatchNominalDuration'] as int,
        );
      }
    }

    return cont;
  }

  EditorCallbacks get callbacks => EditorCallbacks.editor(
        onExerciseReorder: (supersetIndex) async {
          final target = supersetIndex == null
              ? exercises
              : (exercises[supersetIndex] as Superset).exercises
                  as List<WorkoutExercisable>;
          SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
            final newIndices = await showDialog<List<int>>(
              builder: (context) => WorkoutExerciseReorderDialog(
                exercises: target,
              ),
              context: Get.context!,
            );
            if (newIndices == null || newIndices.length != target.length) {
              return;
            }

            if (supersetIndex == null) {
              exercises([
                for (int i = 0; i < newIndices.length; i++)
                  target[newIndices[i]]
              ]);
            } else {
              exercises[supersetIndex] =
                  (exercises[supersetIndex] as Superset).copyWith(exercises: [
                for (int i = 0; i < newIndices.length; i++)
                  target[newIndices[i]] as Exercise,
              ]);
            }
          });
          exercises.refresh();
          save();
        },
        onExerciseReplace: (ExerciseIndex index) {
          final (exerciseIndex: i, supersetIndex: supersetIndex) = index;
          SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
            final old = supersetIndex == null
                ? exercises[i]
                : (exercises[supersetIndex] as Superset).exercises[i];
            final ex = await Go.to<List<Exercise>>(
                () => const ExercisePicker(singlePick: true));
            if (ex == null || ex.isEmpty) return;
            final newExercise = old is Exercise
                ? Exercise.replaced(
                    from: old,
                    to: ex.first.makeChild(),
                  )
                : ex.first.makeChild().copyWith(sets: [
                    if (!ex.first.parameters.isSetless)
                      GTSet.empty(
                          kind: GTSetKind.normal,
                          parameters: ex.first.parameters),
                  ]);
            if (supersetIndex == null) {
              exercises[i] = newExercise;
            } else {
              exercises[supersetIndex] =
                  (exercises[supersetIndex] as Superset).copyWith(exercises: [
                for (int j = 0;
                    j < (exercises[supersetIndex] as Superset).exercises.length;
                    j++)
                  if (j == i)
                    newExercise
                  else
                    (exercises[supersetIndex] as Superset).exercises[j]
              ]);
            }
            exercises.refresh();
            save();
          });
        },
        onExerciseRemove: (index) {
          final (
            exerciseIndex: exerciseIndex,
            supersetIndex: supersetIndex,
          ) = index;
          if (supersetIndex == null) {
            exercises.removeAt(exerciseIndex);
          } else {
            final superset = exercises[supersetIndex] as Superset;
            exercises[supersetIndex] = superset.copyWith(exercises: [
              for (int j = 0; j < superset.exercises.length; j++)
                if (j != exerciseIndex) superset.exercises[j]
            ]);
          }
          exercises.refresh();
          save();
        },
        onExerciseChangeRestTime: (index, value) {
          final (
            exerciseIndex: exerciseIndex,
            supersetIndex: supersetIndex,
          ) = index;

          if (supersetIndex == null) {
            final ex = exercises[exerciseIndex];
            // Type safety
            exercises[exerciseIndex] = ex is Exercise
                ? ex.copyWith(
                    restTime: value,
                  )
                : ex is Superset
                    ? ex.copyWith(
                        restTime: value,
                      )
                    : throw AssertionError("Unreachable yet");
          } else {
            // We don't support changing rest time for individual exercises in a superset
            throw UnimplementedError();
          }

          exercises.refresh();
          save();
        },
        onExerciseChangeRPE: (index, value) {
          final (
            exerciseIndex: exerciseIndex,
            supersetIndex: supersetIndex,
          ) = index;

          if (supersetIndex == null) {
            final ex = exercises[exerciseIndex];
            // Type safety
            exercises[exerciseIndex] = ex is Exercise
                ? ex.copyWith(rpe: value)
                : ex is Superset
                    ? ex.copyWith(
                        exercises: [
                          for (final e in ex.exercises) e.copyWith(rpe: value),
                        ],
                      )
                    : throw AssertionError("Unreachable yet");
          } else {
            final superset = exercises[supersetIndex] as Superset;
            exercises[supersetIndex] = superset.copyWith(exercises: [
              for (final e in superset.exercises) e.copyWith(rpe: value),
            ]);
          }

          exercises.refresh();
          save();
        },
        onExerciseSetReorder: (index, newIndices) {
          final (
            exerciseIndex: exerciseIndex,
            supersetIndex: supersetIndex,
          ) = index;

          if (supersetIndex == null) {
            final ex = exercises[exerciseIndex];
            // Type safety
            exercises[exerciseIndex] = ex is Exercise
                ? ex.copyWith(
                    sets: [
                      for (int i = 0; i < newIndices.length; i++)
                        ex.sets[newIndices[i]]
                    ],
                  )
                : ex is Superset
                    ? ex.copyWith(
                        exercises: [
                          for (final e in ex.exercises)
                            e.copyWith(
                              sets: [
                                for (int i = 0; i < newIndices.length; i++)
                                  e.sets[newIndices[i]]
                              ],
                            ),
                        ],
                      )
                    : throw AssertionError("Unreachable yet");
          } else {
            final superset = exercises[supersetIndex] as Superset;
            exercises[supersetIndex] = superset.copyWith(exercises: [
              for (final e in superset.exercises)
                e.copyWith(
                  sets: [
                    for (int i = 0; i < newIndices.length; i++)
                      e.sets[newIndices[i]]
                  ],
                ),
            ]);
          }

          exercises.refresh();
          save();
        },
        onSetCreate: (index) {
          final (exerciseIndex: i, supersetIndex: supersetIndex) = index;
          final set = GTSet.empty(
            kind: GTSetKind.normal,
            parameters: supersetIndex == null
                ? (exercises[i] as Exercise).parameters
                : (exercises[supersetIndex] as Superset)
                    .exercises[i]
                    .parameters,
          );

          if (supersetIndex == null) {
            exercises[i].sets.add(set);
          } else {
            final superset = exercises[supersetIndex] as Superset;
            exercises[supersetIndex] = superset.copyWith(exercises: [
              for (int j = 0; j < superset.exercises.length; j++)
                if (j == i)
                  superset.exercises[j].copyWith(
                    sets: [
                      ...superset.exercises[j].sets,
                      set,
                    ],
                  )
                else
                  superset.exercises[j]
            ]);
          }

          exercises.refresh();
          save();
        },
        onSetRemove: (index, setIndex) {
          final (exerciseIndex: i, supersetIndex: supersetIndex) = index;

          if (supersetIndex == null) {
            exercises[i].sets.removeAt(setIndex);
          } else {
            final superset = exercises[supersetIndex] as Superset;
            exercises[supersetIndex] = superset.copyWith(exercises: [
              for (int j = 0; j < superset.exercises.length; j++)
                if (j == i)
                  superset.exercises[j].copyWith(
                    sets: [
                      for (int k = 0;
                          k < superset.exercises[j].sets.length;
                          k++)
                        if (k != setIndex) superset.exercises[j].sets[k]
                    ],
                  )
                else
                  superset.exercises[j]
            ]);
          }

          exercises.refresh();
          save();
        },
        onSetSelectKind: (index, setIndex, kind) {
          final (exerciseIndex: i, supersetIndex: supersetIndex) = index;

          final exercise = supersetIndex == null
              ? (exercises[i] as Exercise)
              : (exercises[supersetIndex] as Superset).exercises[i];
          final set = exercise.sets[setIndex];

          final newSet = set.copyWith(kind: kind);

          if (supersetIndex == null) {
            final ex = exercises[i] as Exercise;
            exercises[i] = ex.copyWith(
              sets: [
                for (int j = 0; j < ex.sets.length; j++)
                  if (j == setIndex) newSet else ex.sets[j]
              ],
            );
          } else {
            final superset = exercises[supersetIndex] as Superset;
            exercises[supersetIndex] = superset.copyWith(exercises: [
              for (int j = 0; j < superset.exercises.length; j++)
                if (j == i)
                  superset.exercises[j].copyWith(
                    sets: [
                      for (int k = 0;
                          k < superset.exercises[j].sets.length;
                          k++)
                        if (k == setIndex)
                          newSet
                        else
                          superset.exercises[j].sets[k]
                    ],
                  )
                else
                  superset.exercises[j]
            ]);
          }

          exercises.refresh();
          save();
        },
        onSetSetDone: (index, setIndex, done) {
          final (exerciseIndex: i, supersetIndex: supersetIndex) = index;

          final exercise = supersetIndex == null
              ? (exercises[i] as Exercise)
              : (exercises[supersetIndex] as Superset).exercises[i];
          final set = exercise.sets[setIndex];

          final newSet = set.copyWith(done: done);

          if (supersetIndex == null) {
            final ex = exercises[i] as Exercise;
            exercises[i] = ex.copyWith(
              sets: [
                for (int j = 0; j < ex.sets.length; j++)
                  if (j == setIndex) newSet else ex.sets[j]
              ],
            );
          } else {
            final superset = exercises[supersetIndex] as Superset;
            exercises[supersetIndex] = superset.copyWith(exercises: [
              for (int j = 0; j < superset.exercises.length; j++)
                if (j == i)
                  superset.exercises[j].copyWith(
                    sets: [
                      for (int k = 0;
                          k < superset.exercises[j].sets.length;
                          k++)
                        if (k == setIndex)
                          newSet
                        else
                          superset.exercises[j].sets[k]
                    ],
                  )
                else
                  superset.exercises[j]
            ]);
          }

          if (done) {
            final nextSet = exercise.sets.getAt(setIndex + 1);
            final superset = supersetIndex == null
                ? null
                : (exercises[supersetIndex] as Superset);

            bool shouldStart = false;
            shouldStart |=
                (supersetIndex == null && exercise.restTime.inSeconds > 0);
            shouldStart |= supersetIndex != null &&
                superset!.restTime.inSeconds > 0 &&
                i == superset.exercises.length - 1;

            if (nextSet != null && nextSet.kind == GTSetKind.failureStripping) {
              shouldStart = false;
            }

            // Start a countdown if:
            // either:
            //  - This is an exercise
            //  - This is the last exercise in a superset
            // and:
            //  - The rest time is greater than 0
            // and:
            //  - The next set is not a stripping set
            if (shouldStart) {
              Get.find<CountdownController>().setCountdown(supersetIndex == null
                  ? exercise.restTime
                  : superset!.restTime);
            }
          }
          exercises.refresh();
          save();
        },
        onSetValueChange: (index, setIndex, set) {
          final (
            exerciseIndex: exerciseIndex,
            supersetIndex: supersetIndex,
          ) = index;

          if (supersetIndex == null) {
            final ex = exercises[exerciseIndex];
            // Type safety
            exercises[exerciseIndex] = ex is Exercise
                ? ex.copyWith(
                    sets: [
                      for (int j = 0; j < ex.sets.length; j++)
                        if (j == setIndex) set else ex.sets[j]
                    ],
                  )
                : ex is Superset
                    ? ex.copyWith(
                        exercises: [
                          for (int j = 0; j < ex.exercises.length; j++)
                            if (j == setIndex)
                              ex.exercises[j].copyWith(
                                sets: [
                                  for (int k = 0;
                                      k < ex.exercises[j].sets.length;
                                      k++)
                                    if (k == setIndex)
                                      set
                                    else
                                      ex.exercises[j].sets[k]
                                ],
                              )
                            else
                              ex.exercises[j]
                        ],
                      )
                    : throw AssertionError("Unreachable yet");
          } else {
            final superset = exercises[supersetIndex] as Superset;
            exercises[supersetIndex] = superset.copyWith(exercises: [
              for (int j = 0; j < superset.exercises.length; j++)
                if (j == exerciseIndex)
                  superset.exercises[j].copyWith(
                    sets: [
                      for (int k = 0;
                          k < superset.exercises[j].sets.length;
                          k++)
                        if (k == setIndex)
                          set
                        else
                          superset.exercises[j].sets[k]
                    ],
                  )
                else
                  superset.exercises[j]
            ]);
          }

          exercises.refresh();
          save();
        },
        onExerciseNotesChange: (index, notes) {
          final (
            exerciseIndex: exerciseIndex,
            supersetIndex: supersetIndex,
          ) = index;

          if (supersetIndex == null) {
            final ex = exercises[exerciseIndex];
            // Type safety
            exercises[exerciseIndex] = ex is Exercise
                ? ex.copyWith(
                    notes: notes,
                  )
                : ex is Superset
                    ? ex.copyWith(
                        notes: notes,
                      )
                    : throw AssertionError("Unreachable yet");
          } else {
            final superset = exercises[supersetIndex] as Superset;
            exercises[supersetIndex] = superset.copyWith(exercises: [
              for (int j = 0; j < superset.exercises.length; j++)
                if (j == exerciseIndex)
                  superset.exercises[j].copyWith(
                    notes: notes,
                  )
                else
                  superset.exercises[j]
            ]);
          }

          exercises.refresh();
          save();
        },
        onSupersetAddExercise: (supersetIndex) {
          SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
            pickExercisesForSuperset(supersetIndex);
          });
        },
        onGroupExercisesIntoSuperset: (startingIndex) async {
          final indices = await Go.toDialog(() => ExercisesToSupersetDialog(
              exercises: exercises, startingIndex: startingIndex));

          if (indices == null || indices.length < 2) return;

          final newSuperset = Superset(
            restTime: Duration.zero,
            workoutID: null,
            exercises: [
              for (final index in indices) exercises[index] as Exercise,
            ],
          );

          final newExercises = [
            for (int i = 0; i < indices.first; i++) exercises[i],
            newSuperset,
            for (int i = indices.last + 1; i < exercises.length; i++)
              exercises[i],
          ];

          exercises(newExercises);
          exercises.refresh();
          save();
        },
      );

  static String generateWorkoutTitle(Set<GTMuscleCategory> selectedGroups) {
    globalLogger.d("[WorkoutController#generateWorkoutTitle]\n$selectedGroups");
    globalLogger.d(
        "[WorkoutController#generateWorkoutTitle]\n${"titleGenerator.title".tByIndex(selectedGroups.length)}");
    return "titleGenerator.template".tParams({
      "muscles":
          "titleGenerator.title".tByIndexWithParams(selectedGroups.length, {
        for (int i = 0; i < selectedGroups.length; i++)
          "$i": "muscleCategories.${selectedGroups.elementAt(i).name}".t,
      }),
    }).trim();
  }

  List<GTSet> get allSets => [for (final ex in exercises) ...ex.sets];
  List<GTSet> get doneSets => [
        for (final set in allSets)
          if (set.done) set
      ];

  double get progress => allSets.isEmpty
      ? 0
      : allSets.where((set) => set.done).length / allSets.length;
  int get reps =>
      doneSets.fold(0, (value, element) => value + (element.reps ?? 0));
  double get liftedWeight => doneSets.fold(0.0,
      (value, element) => value + (element.weight ?? 0) * (element.reps ?? 1));

  @override
  void onInit() {
    super.onInit();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      Get.find<RoutinesController>().hasOngoingWorkout(true);
      save();
    });
  }

  @override
  void onClose() {
    super.onClose();
    removeCountdown();
    removeRelevantStopwatches();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      Get.find<RoutinesController>().hasOngoingWorkout(false);
      service.deleteOngoing();
    });
  }

  /// Writes the ongoing workout to the database so that we can restore it on app restart.
  void save() {
    // TODO: Figure out if this is still necessary
    if (Get.find<RoutinesController>().hasOngoingWorkout.isFalse) {
      logger
          .d("Not saving ongoing workout because there is no ongoing workout");
      return;
    }
    final stopwatchController = Get.find<StopwatchController>();

    service.writeToOngoing({
      "name": name.value,
      "exercises": exercises.map((ex) => ex.toJson()).toList(),
      "parentID": parentID.value,
      "time": time.value.millisecondsSinceEpoch,
      "infobox": infobox.value,
      "isContinuation": isContinuation.value,
      "continuesID": continuesID.value,
      "weightUnit": weightUnit.value.name,
      "distanceUnit": distanceUnit.value.name,
      if (stopwatchController.globalStopwatch.currentDuration.inSeconds >
          0) ...{
        "globalStopwatch": stopwatchController
            .globalStopwatch.startingTime.millisecondsSinceEpoch,
        "globalStopwatchPaused":
            stopwatchController.globalStopwatch.isStopped(),
        "globalStopwatchNominalDuration":
            stopwatchController.globalStopwatch.currentDuration.inMilliseconds,
      }
    });
  }

  void cancelWorkoutWithDialog(
    BuildContext context, {
    required void Function() onCanceled,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: const Icon(GTIcons.info),
          title: Text("ongoingWorkout.cancel.title".t),
          content: Text(
            "ongoingWorkout.cancel.text".t,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: Text("ongoingWorkout.cancel.actions.no".t),
            ),
            FilledButton.tonal(
              onPressed: () {
                Get.back();
                Get.delete<WorkoutController>();

                onCanceled();
              },
              child: Text("ongoingWorkout.cancel.actions.yes".t),
            ),
          ],
        );
      },
    );
  }

  void finishWorkoutWithDialog(BuildContext context) {
    generateNameIfEmpty();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      Go.showBottomModalScreen((context, _) => const WorkoutFinishPage());
    });
  }

  void generateNameIfEmpty() {
    if (name.value.trim().isEmpty) {
      final groups = <GTMuscleCategory>{};

      for (final ex in exercises) {
        ex.when(
          exercise: (e) {
            final cat = e.primaryMuscleGroup.category;
            if (cat != null) groups.add(cat);
          },
          superset: (s) => groups.addAll(
            s.exercises
                .map((e) => e.primaryMuscleGroup.category)
                .whereType<GTMuscleCategory>(),
          ),
        );
      }

      name(WorkoutController.generateWorkoutTitle(groups));
    }
  }

  Future<void> submit(String name, Duration duration) async {
    final historyController = Get.find<HistoryController>();

    removeCountdown();
    removeRelevantStopwatches();

    final workout = Workout(
      name: name,
      exercises: exercises,
      duration: duration,
      startingDate: time.value,
      parentID: parentID.value,
      infobox: infobox.value,
      completes: continuesID.value,
      weightUnit: weightUnit.value,
      distanceUnit: distanceUnit.value,
    );

    if (isContinuation.isTrue) {
      historyController.bindContinuation(continuation: workout);
    }

    workout.logger.i("Submitting workout");
    await historyController.addNewWorkout(workout);
    Get.back();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      Get.back();
      Get.delete<WorkoutController>();
      await askToUpdateRoutine(workout);

      if (workout.doneSets.isNotEmpty) {
        await Go.showBottomModalScreen(
          (context, controller) => WorkoutDoneSheet(
            workout: workout,
            controller: controller,
          ),
        );
      }

      // Always keep at the very end
      Get.find<Coordinator>().scheduleBackup();
    });
  }

  Future<void> askToUpdateRoutine(Workout workout) async {
    final routinesController = Get.find<RoutinesController>();

    if (workout.parentID != null &&
        routinesController.hasRoutine(workout.parentID!)) {
      final routine = routinesController.getRoutine(workout.parentID!);
      final difference = WorkoutDifference.fromWorkouts(
        oldWorkout: routine!,
        newWorkout: workout,
      );
      if (!difference.isEmpty) {
        final confirm = await Go.confirm(
          "ongoingWorkout.updateRoutine.differenceTitle".t,
          () {
            String text =
                "${"ongoingWorkout.updateRoutine.differenceText".t}\n\n";
            if (difference.addedExercises > 0) {
              text +=
                  "- ${"ongoingWorkout.updateRoutine.differences.added".plural(difference.addedExercises)}\n";
            }
            if (difference.removedExercises > 0) {
              text +=
                  "- ${"ongoingWorkout.updateRoutine.differences.removed".plural(difference.removedExercises)}\n";
            }
            if (difference.changedExercises > 0) {
              text +=
                  "- ${"ongoingWorkout.updateRoutine.differences.changed".plural(difference.changedExercises)}\n";
            }

            return text.trim();
          }(),
          transformText: (s) => s,
        );
        if (confirm) {
          routinesController.updateRoutineFromWorkout(
              workout.parentID!, workout);
        }
      }
    }
  }

  void removeCountdown() {
    Get.find<CountdownController>().removeCountdown();
  }

  void removeRelevantStopwatches() {
    final ids = allSets.map((e) => e.id);
    final controller = Get.find<StopwatchController>();

    for (final id in ids) {
      controller.updateBinding(id, (timer, duration, encoded) {
        // no-op
      });
    }

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      controller.removeStopwatches(ids);
    });

    // Stop the global stopwatch
    controller.globalStopwatch.reset();
  }

  bool hasExercise(Exercise exercise) {
    return exercises.any((element) {
      return element.map(
          exercise: (ex) => exercise.isParentOf(ex),
          superset: (ss) =>
              ss.exercises.any((element) => exercise.isParentOf(element)));
    });
  }

  void applyExerciseModification(Exercise exercise) {
    assert(exercise.isCustom);
    assert(hasExercise(exercise));

    final res = exercises.toList();
    for (int i = 0; i < exercises.length; i++) {
      exercises[i].when(
        exercise: (e) {
          if (exercise.isParentOf(e)) {
            res[i] = Exercise.replaced(from: e, to: exercise).copyWith(
              id: e.id,
              parentID: e.parentID,
            );
          }
        },
        superset: (superset) {
          for (int j = 0; j < superset.exercises.length; j++) {
            if (exercise.isParentOf(superset.exercises[j])) {
              (res[i] as Superset).exercises[j] =
                  Exercise.replaced(from: superset.exercises[j], to: exercise)
                      .copyWith(
                id: superset.exercises[j].id,
                parentID: superset.exercises[j].parentID,
              );
            }
          }
        },
      );
    }

    exercises(res);
  }

  Future<void> pickExercises() async {
    final exs = await Go.to<List<Exercise>>(
        () => const ExercisePicker(singlePick: false));
    if (exs == null || exs.isEmpty) return;
    exercises.addAll(
      exs.map(
        (ex) => ex.makeChild().copyWith.sets(
          [
            if (!ex.parameters.isSetless)
              GTSet.empty(
                kind: GTSetKind.normal,
                parameters: ex.parameters,
              ),
          ],
        ),
      ),
    );
    exercises.refresh();
    save();
  }

  Future<void> pickExercisesForSuperset(int i) async {
    final exs = await Go.to<List<Exercise>>(
        () => const ExercisePicker(singlePick: false));
    if (exs == null || exs.isEmpty) return;

    final superset = exercises[i] as Superset;
    exercises[i] = superset.copyWith(
      exercises: [
        ...superset.exercises,
        ...exs.map(
          (ex) => ex.makeChild().copyWith.sets(
            [
              if (!ex.parameters.isSetless)
                GTSet.empty(
                  kind: GTSetKind.normal,
                  parameters: ex.parameters,
                ),
            ],
          ),
        ),
      ],
    );

    exercises.refresh();
    save();
  }

  void showEditNotesDialog() {
    final controller = quillControllerFromText(infobox.value);
    Go.toDialog(
      () => GTRichTextEditDialog(
        controller: controller,
        onNotesChange: (text) {
          infobox(text);
          save();
          Get.back();
        },
      ),
    );
  }

  void changeWeightUnitDialog() {
    Go.showRadioModal(
      selectedValue: weightUnit.value,
      title: Text("ongoingWorkout.actions.changeWeightUnit".t),
      values: {
        for (final val in Weights.values) val: "weightUnits.${val.name}".t,
      },
      onChange: (value) {
        logger.w("Changing weight unit to $value");
        if (value != null) weightUnit(value);
        save();
      },
    );
  }

  void changeDistanceUnitDialog() {
    Go.showRadioModal(
      selectedValue: distanceUnit.value,
      title: Text("ongoingWorkout.actions.changeDistanceUnit".t),
      values: {
        for (final distance in Distance.values)
          distance: "distanceUnits.${distance.name}".t,
      },
      onChange: (value) {
        logger.i("Changing distance unit to $value");
        if (value != null) distanceUnit(value);
        save();
      },
    );
  }

  void applyExistingWorkout(
    Workout workout, {
    String? parentID,
    required bool Function(WorkoutExercisable exercise) exerciseFilter,
    bool Function(GTSet set)? setFilter,
    bool continuation = false,
    required bool shouldKeepRPEs,
  }) {
    this
      ..name(workout.name)
      ..exercises([
        for (final ex in workout.exercises)
          if (exerciseFilter(ex))
            if (ex is Exercise)
              ex.instantiate(
                workout: workout,
                setFilter: setFilter,
                isSupersedence: continuation && ex.isSupersedence,
                rpe: shouldKeepRPEs ? Some(ex.rpe) : const None(),
              )
            else if (ex is Superset)
              ex.copyWith(
                exercises: ex.exercises
                    .map((e) => e.instantiate(
                          workout: workout,
                          setFilter: setFilter,
                          isSupersedence: continuation && e.isSupersedence,
                          rpe: shouldKeepRPEs ? Some(e.rpe) : const None(),
                        ))
                    .toList(),
              ),
      ])
      ..time(DateTime.now())
      ..parentID(parentID)
      ..infobox(workout.infobox)
      ..isContinuation(continuation)
      ..continuesID(continuation ? workout.id : null)
      ..weightUnit(workout.weightUnit)
      ..distanceUnit(workout.distanceUnit)
      ..save();
  }

  @override
  void onServiceChange() {}

  void onNotificationTapped(NotificationResponse value) {
    logger.t((value.id, NotificationIDs.restTimer));
    if (value.id == NotificationIDs.restTimer) {
      logger.t((Go.getTopmostRouteName(), WorkoutView.routeName));
      if (Go.getTopmostRouteName() != WorkoutView.routeName) {
        Go.toNamed(WorkoutView.routeName);
      }
    }
  }

  /// Helper method used in debug mode to show "Good job" dialog while workout
  /// is running
  Workout synthesizeTemporaryWorkout() {
    return Workout(
      name: name.value,
      exercises: exercises,
      duration: DateTime.now().difference(time.value),
      startingDate: time.value,
      parentID: parentID.value,
      infobox: infobox.value,
      weightUnit: weightUnit.value,
      distanceUnit: distanceUnit.value,
      completedBy: null,
      completes: continuesID.value,
      folder: null,
    );
  }

  void generateWorkout() async {
    if (this.exercises.isNotEmpty) {
      return;
    }

    final _res = await Go.toDialog<(Set<GTMuscleGroup>, Set<GTGymEquipment>)>(
      () => const WorkoutGeneratorSetupScreen(),
    );
    if (_res == null) return;

    final (muscleGroups, equipment) = _res;
    final exercises = _workoutGenerator(
      muscleGroups: muscleGroups,
      equipment: equipment,
    );

    if (exercises.isEmpty) {
      Go.dialog("workoutGenerator.empty.title", "workoutGenerator.empty.text");
      return;
    }

    this.exercises(exercises);

    final context = Get.context;
    final onThemedColor =
            context == null ? null : getOnThemedColor(context, GTColors.ai),
        themedColor =
            context == null ? null : getThemedColor(context, GTColors.ai),
        containerColor =
            context == null ? null : getContainerColor(context, GTColors.ai),
        onContainerColor =
            context == null ? null : getOnContainerColor(context, GTColors.ai);

    Go.snack(
      ListTile(
        leading: const Icon(GTIcons.generate),
        title: Text("workoutGenerator.success.title".t),
        textColor: onContainerColor,
        iconColor: onContainerColor,
      ),
      backgroundColor: containerColor,
      action: SnackBarAction(
        label: "workoutGenerator.success.undo".t,
        backgroundColor: themedColor,
        textColor: onThemedColor,
        onPressed: () {
          this.exercises([]);
        },
      ),
      duration: const Duration(milliseconds: 2250) * exercises.length,
    );
  }

  List<Exercise> _workoutGenerator({
    required Set<GTMuscleGroup> muscleGroups,
    required Set<GTGymEquipment> equipment,
  }) {
    final filteredLibrary = exerciseStandardLibraryAsList
        .where((exercise) =>
            (muscleGroups.contains(exercise.primaryMuscleGroup) ||
                muscleGroups
                    .intersection(exercise.secondaryMuscleGroups)
                    .isNotEmpty) &&
            equipment.contains(exercise.gymEquipment))
        .toList();
    final exercises = <Exercise>[];

    for (final group in muscleGroups) {
      final groupExercises = filteredLibrary
          .where((exercise) =>
              exercise.primaryMuscleGroup == group ||
              muscleGroups
                  .intersection(exercise.secondaryMuscleGroups)
                  .isNotEmpty)
          .toList();
      groupExercises.shuffle();

      final toAdd = switch (muscleGroups.length) {
        1 => 4,
        2 => 2,
        3 => muscleGroups.toList().indexOf(group) == 0 ? 2 : 1,
        _ => 1,
      };
      int i = 0;
      exercises.addAll(groupExercises.take(toAdd).map((e) {
        i++;
        return e.makeChild().copyWith(
          restTime: const Duration(minutes: 1),
          sets: [
            for (int j = 0; j < (i == toAdd - 1 && i > 3 ? 2 : 3); j++)
              GTSet(
                weight: 0,
                reps: 10,
                time: const Duration(minutes: 1),
                distance: 0,
                kind: GTSetKind.normal,
                parameters: e.parameters,
              ),
          ],
        );
      }));
    }

    return exercises;
  }
}
