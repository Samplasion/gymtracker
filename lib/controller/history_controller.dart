import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/serviceable_controller.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/model/exercisable.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/model/superset.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/struct/streaks.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/exercises.dart';
import 'package:gymtracker/view/workout_editor.dart';

class HistoryController extends GetxController with ServiceableController {
  RxList<Workout> history = <Workout>[].obs;

  int get userVisibleLength => userVisibleWorkouts.length;

  List<Workout> get userVisibleWorkouts => history
      .where((workout) => !workout.isContinuation || kDebugMode)
      .toList();
  Map<DateTime, List<Workout>> workoutsByDay = {};

  Rx<Streaks> streaks = Streaks.zero.obs;

  @override
  onInit() {
    super.onInit();
    service.history$.listen((event) {
      logger.i("Updated with ${event.length} workouts");
      event.sort((a, b) => (a.startingDate ??
              DateTime.fromMillisecondsSinceEpoch(0))
          .compareTo(b.startingDate ?? DateTime.fromMillisecondsSinceEpoch(0)));
      history(event);
      _computeWorkoutsByDay();
      computeStreaks();
      coordinator.computeSuggestions();
    });
  }

  @override
  void onServiceChange() {}

  void _computeWorkoutsByDay() {
    final _counts = <DateTime, List<Workout>>{};
    for (final workout in userVisibleWorkouts) {
      final date = workout.startingDate!.startOfDay;
      _counts.putIfAbsent(date, () => []);
      _counts[date]!.add(workout);
    }
    workoutsByDay = _counts;
  }

  void computeStreaks() {
    try {
      if (Get.context == null) {
        logger.w("[computeStreaks] Context is null, ignoring.");
        return;
      }

      streaks(Streaks.fromMappedDays(
        workoutsByDay,
        firstDayOfWeek: GTLocalizations.firstDayOfWeekFor(Get.context!),
        today: DateTime.now(),
      ));

      logger.i("Recomputed streaks: $streaks");
    } catch (e, s) {
      logger.e("Error computing streaks", error: e, stackTrace: s);
    }
  }

  Future<void> deleteWorkout(Workout workout) async {
    await service.removeHistoryWorkoutById(workout.id);
    if (workout.completedBy != null) {
      await service.removeHistoryWorkoutById(workout.completedBy!);
    }
  }

  void setParentID(Workout workout, {String? newParentID}) {
    if (service.hasHistoryWorkout(workout.id)) {
      service.setHistoryWorkout(
        workout.copyWith(parentID: newParentID),
      );
    }
  }

  Workout rename(Workout workout, {String? newName}) {
    if (newName == null) return workout;
    final newWorkout = workout.copyWith(name: newName);
    if (service.hasHistoryWorkout(workout.id)) {
      service.setHistoryWorkout(newWorkout);
    }
    return newWorkout;
  }

  Workout fixWorkout(Workout workout) {
    workout.id.logger.i("Fixing workout");
    if (workout.parentID == null) {
      workout.id.logger.w("No parent ID");
      return workout;
    }
    final parent = service.routines.firstWhereOrNull(
      (element) => element.id == workout.parentID,
    );
    if (parent == null) {
      workout.id.logger.w("Parent not found");
      return workout;
    }

    final exercises = <WorkoutExercisable>[];
    for (final exercise in workout.exercises) {
      Exercise getFixedExercise(Exercise exercise) {
        if (exercise.isCustom) {
          workout.id.logger.i("Custom exercise found");
          return exercise;
        }

        // Returns the standard exercise, which is not an instance
        // of an exercise in the Standard Library but a child of it.
        final standard = parent.exercises.firstWhereOrNull(
          (element) => element is Exercise && element.id == exercise.parentID,
        );
        if (standard == null) {
          workout.id.logger.i("Standard exercise not found");
          return exercise;
        }

        return exercise.copyWith(
          parentID: (standard as Exercise).parentID ?? standard.id,
        );
      }

      if (exercise is Exercise) {
        exercises.add(getFixedExercise(exercise));
      } else if (exercise is Superset) {
        exercises.add(
          exercise.copyWith(
            exercises: exercise.exercises.map(getFixedExercise).toList(),
          ),
        );
      }
    }

    return workout.copyWith(
      exercises: exercises,
    );
  }

  void deleteWorkoutWithDialog(
    BuildContext context, {
    required Workout workout,
    required void Function() onCanceled,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: const Icon(GTIcons.info),
          title: Text("workouts.actions.delete.title".t),
          content: Text(
            "workouts.actions.delete.text".t,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back(closeOverlays: true);
              },
              child: Text("workouts.actions.delete.actions.no".t),
            ),
            FilledButton.tonal(
              onPressed: () {
                deleteWorkout(workout);
                SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                  Get.back(closeOverlays: true);
                });

                onCanceled();
              },
              child: Text("workouts.actions.delete.actions.yes".t),
            ),
          ],
        );
      },
    );
  }

  void deleteWorkoutsWithDialog(
    BuildContext context, {
    required Set<String> workoutIDs,
    required void Function() onDeleted,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: const Icon(GTIcons.info),
          title: Text(
              "history.actions.deleteMultiple.title".plural(workoutIDs.length)),
          content: Text(
            "history.actions.deleteMultiple.text".plural(workoutIDs.length),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back(closeOverlays: true);
              },
              child: Text("history.actions.deleteMultiple.actions.no".t),
            ),
            FilledButton.tonal(
              onPressed: () {
                final deletedWorkouts = service.workoutHistory
                    .where((element) => workoutIDs.contains(element.id))
                    .toList();
                for (final workout in deletedWorkouts) {
                  deleteWorkout(workout);
                }

                SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                  Get.back(closeOverlays: true);
                });

                onDeleted();
              },
              child: Text("history.actions.deleteMultiple.actions.yes".t),
            ),
          ],
        );
      },
    );
  }

  void unbindAllFromParent(String id) {
    for (final workout in service.workoutHistory) {
      if (workout.parentID == id) {
        service.setHistoryWorkout(
          workout.copyWith(parentID: null),
        );
      }
    }
  }

  void bindContinuation({required Workout continuation}) {
    for (final workout in service.workoutHistory) {
      if (workout.id == continuation.completes) {
        service.setHistoryWorkout(
          workout.copyWith(completedBy: continuation.id),
        );
      }
    }
  }

  bool hasContinuation({required Workout incompleteWorkout}) =>
      getContinuation(incompleteWorkout: incompleteWorkout) != null;

  Workout? getContinuation({required Workout incompleteWorkout}) {
    if (incompleteWorkout.isComplete) return null;
    return service.workoutHistory.firstWhereOrNull(
      (element) => element.completes == incompleteWorkout.id,
    );
  }

  Workout? getOriginalForContinuation({required Workout continuationWorkout}) {
    assert(continuationWorkout.completes != null,
        "Workout must be a continuation");
    return service.workoutHistory.firstWhereOrNull(
      (element) => element.id == continuationWorkout.completes,
    );
  }

  void finishEditingWorkoutWithDialog(BuildContext context, Workout workout) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Go.showBottomModalScreen(
        (context, _) => WorkoutFinishEditingPage(workout: workout),
      );
    });
  }

  Future<void> submitEditedWorkout(Workout workout) async {
    await service.setHistoryWorkout(workout);
    if (workout.hasContinuation) {
      service.setHistoryWorkout(workout.continuation!.copyWith(
        parentID: workout.parentID,
      ));
    }
    Get.back();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      Get.back();
      Get.back();
    });
  }

  /// Adds a new workout to the history, avoiding collisions
  Future<void> addNewWorkout(Workout workout) async {
    logger.d(workout.toJson().toPrettyString());
    logger.i("Adding new workout to history");
    final collides = service.hasHistoryWorkout(workout.id);
    if (collides) {
      workout = workout.regenerateID();
      if (workout.completes != null) {
        final completed = service.getHistoryWorkout(workout.completes!);
        if (completed != null) {
          await service.setHistoryWorkout(completed.copyWith(
            completedBy: workout.id,
          ));
        } else {
          workout = workout.copyWith(completes: null);
        }
      }
    }
    await service.setHistoryWorkout(workout);
  }

  Map<GTMuscleCategory, double> calculateMuscleCategoryDistributionFor({
    required List<Workout> workouts,
  }) {
    Map<GTMuscleCategory, double> map = {
      for (final category in GTMuscleCategory.values) category: 0,
    };

    void handleExercise(Workout workout, Exercise exercise) {
      for (final group in [
        exercise.primaryMuscleGroup,
        ...exercise.secondaryMuscleGroups
      ]) {
        if (group.category == null) continue;
        map[group.category!] = map[group.category!]! +
            exercise.sets
                .where((element) => element.done || !workout.isConcrete)
                .length;
      }
    }

    for (final workout in workouts) {
      for (final exercise in workout.exercises) {
        exercise.when(
          exercise: (ex) => handleExercise(workout, ex),
          superset: (superset) {
            for (final exercise in superset.exercises) {
              handleExercise(workout, exercise);
            }
          },
        );
      }
    }

    return map;
  }

  Map<GTGymEquipment, double> calculateGymEquipmentDistributionFor({
    required List<Workout> workouts,
  }) {
    Map<GTGymEquipment, double> map = {
      for (final equipment in GTGymEquipment.values) equipment: 0,
    };

    for (final workout in workouts) {
      for (final exercise in workout.flattenedExercises.whereType<Exercise>()) {
        for (final set in exercise.sets) {
          if (set.done || !workout.isConcrete) {
            map[exercise.gymEquipment] = map[exercise.gymEquipment]! + 1;
          }
        }
      }
    }

    return map;
  }

  Future<void> applyExerciseModification(Exercise exercise) {
    assert(exercise.isCustom);

    return service.applyExerciseModificationToHistory(exercise);
  }

  bool hasExercise(Exercise exercise) {
    return history.any(
      (workout) => workout.exercises.any((element) {
        return element.map(
            exercise: (ex) => exercise.isParentOf(ex),
            superset: (ss) =>
                ss.exercises.any((element) => exercise.isParentOf(element)));
      }),
    );
  }

  List<Workout> getRoutineHistory(Workout routine) {
    final history = this
        .history
        .where((element) => element.parentID == routine.id)
        .toList();
    history.sort((a, b) => (b.startingDate ??
            DateTime.fromMillisecondsSinceEpoch(0))
        .compareTo(a.startingDate ?? DateTime.fromMillisecondsSinceEpoch(0)));
    return history;
  }

  Future<void> combineWorkoutsFlow(Workout workout) async {
    if (!workout.hasContinuation) {
      throw ArgumentError.value(
        workout,
        'workout',
        "Workout must have a continuation.",
      );
    }

    // Rationale: The old algorithm used a filter on the base workout to filter
    // done exercises so that they don't show up twice. To the new algorithm
    // that's counter-productive so we don't do that.
    // That is counter-productive because the new algorithm uses the
    // [supersedesID] field on exercises to know what exercise goes where,
    // so filtering exercises means that the combined workout has some
    // exercises missing.
    final w1 = linearExercisesUseNewAlgorithm(workout, workout.continuation!)
        ? workout
        : workout.withFilters(
            exerciseFilter: (e) => e.sets.any((element) => element.done),
            setFilter: (e, s) => s.done,
          );
    // Rationale: the continuation's infobox is pre-populated with the base
    // workout's notes. Since the continuation algorithm appends the second
    // workout's notes to the first, we want to avoid showing them twice
    // if the user hasn't touched them.
    final w2 = workout.continuation!.copyWith.infobox(
        workout.continuation!.infobox == w1.infobox
            ? null
            : workout.continuation!.infobox);

    final shouldCombine = await Go.confirm(
      "exercise.continuation.combine.confirm.title",
      "exercise.continuation.combine.confirm.body",
      icon: const Icon(GTIcons.combine),
    );

    logger.t("Should combine: $shouldCombine");

    if (!shouldCombine) {
      return;
    }

    final combined = Workout.combine(w1, w2);

    logger.d(combined.toJson().toPrettyString());

    replaceWorkoutsWithCombined(
      workouts: [w1, w2],
      combined: combined,
    );

    Go.off(() => ExercisesView(workout: combined));
  }

  void replaceWorkoutsWithCombined({
    required List<Workout> workouts,
    required Workout combined,
  }) {
    service.transaction(() async {
      for (final workout in workouts) {
        await deleteWorkout(workout);
      }
      await addNewWorkout(combined);
    });
  }

  Workout? getByID(String id) {
    return history.firstWhereOrNull((element) => element.id == id);
  }

  void replaceExercise(Exercise from, Exercise to) {
    service.writeAllHistory([
      for (final workout in service.workoutHistory)
        workout.copyWith(
          exercises: [
            for (final ex in workout.exercises)
              ex.map(
                exercise: (ex) {
                  if (from.isTheSameAs(ex)) {
                    return Exercise.replaced(
                      from: ex,
                      to: to.makeChild(),
                    );
                  } else {
                    return ex;
                  }
                },
                superset: (ss) => ss.copyWith(
                  exercises: [
                    for (final ex in ss.exercises)
                      if (from.isTheSameAs(ex))
                        Exercise.replaced(
                          from: ex,
                          to: to.makeChild(),
                        )
                      else
                        ex,
                  ],
                ),
              ),
          ],
        ),
    ]);
  }

  void removeWeightFromExercise(Exercise exercise) {
    service.writeAllHistory([
      for (final workout in service.workoutHistory)
        workout.copyWith(
          exercises: [
            for (final ex in workout.exercises)
              ex.map(
                exercise: (ex) {
                  if (exercise.isTheSameAs(ex)) {
                    return ex.copyWith(
                      parameters: GTSetParameters.freeBodyReps,
                      sets: [
                        for (final set in ex.sets)
                          set.copyWith(
                            parameters: GTSetParameters.freeBodyReps,
                          ),
                      ],
                    );
                  } else {
                    return ex;
                  }
                },
                superset: (ss) => ss.copyWith(
                  exercises: [
                    for (final ex in ss.exercises)
                      if (exercise.isTheSameAs(ex))
                        ex.copyWith(
                          parameters: GTSetParameters.freeBodyReps,
                          sets: [
                            for (final set in ex.sets)
                              set.copyWith(
                                parameters: GTSetParameters.freeBodyReps,
                              ),
                          ],
                        )
                      else
                        ex,
                  ],
                ),
              ),
          ],
        ),
    ]);
  }
}

extension WorkoutHistory on Workout {
  bool get hasContinuation =>
      Get.find<HistoryController>().hasContinuation(incompleteWorkout: this);
  Workout? get continuation =>
      Get.find<HistoryController>().getContinuation(incompleteWorkout: this);
  Workout? get originalWorkoutForContinuation => Get.find<HistoryController>()
      .getOriginalForContinuation(continuationWorkout: this);

  SynthesizedWorkout synthesizeContinuations({
    bool previous = true,
    bool next = true,
  }) {
    final self = this is SynthesizedWorkout
        ? (this as SynthesizedWorkout).components.first
        : this;
    return SynthesizedWorkout([
      if (previous && self.isContinuation) self.originalWorkoutForContinuation!,
      self,
      if (next && self.completedBy != null && self.continuation != null)
        self.continuation!,
    ]);
  }
}
