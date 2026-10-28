import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:gymtracker/controller/achievements_controller.dart';
import 'package:gymtracker/model/achievements.dart';
import 'package:gymtracker/model/exercisable.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/model/superset.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/provider/bootstrap.dart';
import 'package:gymtracker/provider/locale.dart';
import 'package:gymtracker/provider/settings.dart';
import 'package:gymtracker/provider/training_data.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/service/native.dart';
import 'package:gymtracker/service/widgets.dart';
import 'package:gymtracker/struct/streaks.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'history_controller.g.dart';

@Riverpod(keepAlive: true)
HistoryController historyController(Ref ref) {
  final controller = HistoryController(ref);
  void update() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (ref.mounted) controller.computeStreaks();
    });
  }

  ref.listen(historyWorkoutsProvider, (_, next) {
    if (next.hasValue) update();
  });
  ref.listen(appPreferencesProvider, (_, next) {
    if (next.hasValue) update();
  });
  return controller;
}

class HistoryController {
  HistoryController(this.ref);
  final Ref ref;
  DatabaseService get service => ref.read(databaseServiceProvider);
  List<Workout> get history =>
      ref.read(historyWorkoutsProvider).value ?? const [];
  int get userVisibleLength => userVisibleWorkouts.length;
  List<Workout> get userVisibleWorkouts =>
      history.where((w) => !w.isContinuation || kDebugMode).toList();
  Map<DateTime, List<Workout>> get workoutsByDay {
    final result = <DateTime, List<Workout>>{};
    for (final workout in userVisibleWorkouts) {
      if (workout.startingDate != null) {
        (result[workout.startingDate!.startOfDay] ??= []).add(workout);
      }
    }
    return result;
  }

  Streaks get streaks => Streaks.fromMappedDays(
    workoutsByDay,
    firstDayOfWeek: firstDayOfWeekFor(
      ref.read(appPreferencesProvider).value?.locale == kSystemLocaleSentinel
          ? ref.read(platformLocaleProvider)
          : ref.read(appPreferencesProvider).value?.locale ??
                ref.read(platformLocaleProvider),
    ),
    today: ref.read(trainingClockProvider)(),
  );
  void queueStreaksRecomputation() => computeStreaks();
  void computeStreaks() {
    try {
      final current = streaks;
      ref.read(widgetsServiceProvider).updateWeeklyStreak(current.weekStreak);
      ref.read(widgetsServiceProvider).updateRestStreak(current.restDays);
      ref.read(widgetsServiceProvider).updateWorkouts(userVisibleLength);
      final now = ref.read(trainingClockProvider)();
      final density = [
        for (var i = 0; i < 7 * 18; i++)
          workoutsByDay[now.subtract(Duration(days: i)).startOfDay]?.length ??
              0,
      ];
      var remaining = density.length;
      while (density.first == 0 && remaining-- > 0) {
        density.add(density.removeAt(0));
      }
      ref
          .read(nativeServiceProvider)
          .updateHomeWidgetParameters(
            weekStreak: current.weekStreak,
            lastWorkoutDay: userVisibleWorkouts.isEmpty
                ? now.startOfDay
                : userVisibleWorkouts.last.startingDate!.startOfDay,
            workouts: userVisibleLength,
            workoutDensityChartData: density,
          );
    } catch (error, stack) {
      logger.e('Error computing streaks', error: error, stackTrace: stack);
    }
  }

  void scheduleBackup() => ref.read(backupSchedulerProvider).schedule();
  void unlockAchievements() => ref
      .read(achievementsControllerProvider)
      .maybeUnlockAchievements(AchievementTrigger.workout);

  Future<void> deleteWorkout(Workout workout) async {
    final databaseService = service;
    final owner = databaseService.db.currentUserId;
    await databaseService.transaction<void>(() async {
      await databaseService.removeHistoryWorkoutById(workout.id);
      if (workout.completedBy != null) {
        await databaseService.removeHistoryWorkoutById(workout.completedBy!);
      }
    });
    if (!ref.mounted || databaseService.db.currentUserId != owner) return;
    scheduleBackup();

    unlockAchievements();
  }

  void setParentID(Workout workout, {String? newParentID}) {
    if (service.hasHistoryWorkout(workout.id)) {
      service.setHistoryWorkout(workout.copyWith(parentID: newParentID));
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

    return workout.copyWith(exercises: exercises);
  }

  void unbindAllFromParent(String id) {
    for (final workout in service.workoutHistory) {
      if (workout.parentID == id) {
        service.setHistoryWorkout(workout.copyWith(parentID: null));
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
    return service.workoutHistory.firstWhereOrNull(
      (element) => element.completes == incompleteWorkout.id,
    );
  }

  Workout? getOriginalForContinuation({required Workout continuationWorkout}) {
    assert(
      continuationWorkout.completes != null,
      "Workout must be a continuation",
    );
    return service.workoutHistory.firstWhereOrNull(
      (element) => element.id == continuationWorkout.completes,
    );
  }

  Future<void> submitEditedWorkout(Workout workout) async {
    final owner = service.db.currentUserId;
    await service.setHistoryWorkout(workout);
    if (!ref.mounted || service.db.currentUserId != owner) return;
    if (hasContinuation(incompleteWorkout: workout)) {
      await service.setHistoryWorkout(
        getContinuation(
          incompleteWorkout: workout,
        )!.copyWith(parentID: workout.parentID),
      );
    }
    if (ref.mounted && service.db.currentUserId == owner) unlockAchievements();
  }

  /// Adds a new workout to the history, avoiding collisions
  Future<void> addNewWorkout(Workout workout) async {
    logger.d(workout.toJson().toPrettyString());
    logger.i("Adding new workout to history");
    if (service.hasHistoryWorkout(workout.id)) {
      workout = workout.regenerateID();
    }
    if (workout.completes == null) {
      await service.setHistoryWorkout(workout);
      return;
    }
    await service.transaction(() async {
      final completed = service.getHistoryWorkout(workout.completes!);
      if (completed == null) {
        await service.setHistoryWorkout(workout.copyWith(completes: null));
        return;
      }
      await service.setHistoryWorkout(workout);
      await service.setHistoryWorkout(
        completed.copyWith(completedBy: workout.id),
      );
    });
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
        ...exercise.secondaryMuscleGroups,
      ]) {
        if (group.category == null) continue;
        map[group.category!] =
            map[group.category!]! +
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
              ss.exercises.any((element) => exercise.isParentOf(element)),
        );
      }),
    );
  }

  List<Workout> getRoutineHistory(Workout routine) {
    final history = this.history
        .where((element) => element.parentID == routine.id)
        .toList();
    history.sort(
      (a, b) => (b.startingDate ?? DateTime.fromMillisecondsSinceEpoch(0))
          .compareTo(a.startingDate ?? DateTime.fromMillisecondsSinceEpoch(0)),
    );
    return history;
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
                    return Exercise.replaced(from: ex, to: to.makeChild());
                  } else {
                    return ex;
                  }
                },
                superset: (ss) => ss.copyWith(
                  exercises: [
                    for (final ex in ss.exercises)
                      if (from.isTheSameAs(ex))
                        Exercise.replaced(from: ex, to: to.makeChild())
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

  List<(Exercise ex, int index, Workout workout)> getHistoryOf(
    Exercise exercise,
  ) {
    final controller = this;
    final history = <(Exercise, int, Workout)>[];
    for (final workout in controller.history) {
      history.addAll(
        [
              for (int i = 0; i < workout.exercises.length; i++)
                if (workout.exercises[i] is Exercise) ...[
                  (workout.exercises[i] as Exercise, i),
                ] else if (workout.exercises[i] is Superset) ...[
                  for (final e in (workout.exercises[i] as Superset).exercises)
                    (e, i),
                ],
            ]
            .where((element) => exercise.isTheSameAs(element.$1))
            .map((e) => (e.$1, e.$2, workout)),
      );
    }
    history.sort(
      (a, b) => (b.$3.startingDate ?? DateTime.fromMillisecondsSinceEpoch(0))
          .compareTo(
            a.$3.startingDate ?? DateTime.fromMillisecondsSinceEpoch(0),
          ),
    );
    return history;
  }

  void applyWeightMultiplier(Exercise exercise, double multiplier) {
    service.writeAllHistory([
      for (final workout in service.workoutHistory)
        workout.copyWith(
          exercises: [
            for (final ex in workout.exercises)
              ex.map(
                exercise: (ex) {
                  if (exercise.isTheSameAs(ex)) {
                    return ex.copyWith(
                      sets: [
                        for (final set in ex.sets)
                          set.copyWith(weight: set.weight! * multiplier),
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
                          sets: [
                            for (final set in ex.sets)
                              set.copyWith(weight: set.weight! * multiplier),
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
  bool hasContinuationIn(Iterable<Workout> history) =>
      continuationIn(history) != null;
  Workout? continuationIn(Iterable<Workout> history) =>
      history.where((w) => w.completes == id).firstOrNull;
  Workout? originalWorkoutForContinuationIn(Iterable<Workout> history) =>
      history.where((w) => w.id == completes).firstOrNull;
  SynthesizedWorkout synthesizeContinuations({
    required Iterable<Workout> history,
    bool previous = true,
    bool next = true,
  }) {
    final self = this is SynthesizedWorkout
        ? (this as SynthesizedWorkout).components.first
        : this;
    return SynthesizedWorkout([
      if (previous &&
          self.isContinuation &&
          self.originalWorkoutForContinuationIn(history) != null)
        self.originalWorkoutForContinuationIn(history)!,
      self,
      if (next &&
          self.completedBy != null &&
          self.continuationIn(history) != null)
        self.continuationIn(history)!,
    ]);
  }
}
