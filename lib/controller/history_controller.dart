import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/serviceable_controller.dart';
import 'package:gymtracker/model/exercisable.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/superset.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/view/workout_editor.dart';

class HistoryController extends GetxController with ServiceableController {
  RxList<Workout> history = <Workout>[].obs;

  int get userVisibleLength => userVisibleWorkouts.length;

  List<Workout> get userVisibleWorkouts => history
      .where((workout) => !workout.isContinuation || kDebugMode)
      .toList();
  Map<DateTime, List<Workout>> workoutsByDay = {};

  Rx<(int, int)> streaks = (0, 0).obs;

  @override
  void onServiceChange() {
    final hist = service.workoutHistory;
    hist.sort((a, b) => (a.startingDate ??
            DateTime.fromMillisecondsSinceEpoch(0))
        .compareTo(b.startingDate ?? DateTime.fromMillisecondsSinceEpoch(0)));
    history(hist);
    _computeWorkoutsByDay();
    _computeStreaks();
  }

  void _computeWorkoutsByDay() {
    final _counts = <DateTime, List<Workout>>{};
    for (final workout in userVisibleWorkouts) {
      final date = workout.startingDate!.startOfDay;
      _counts.putIfAbsent(date, () => []);
      _counts[date]!.add(workout);
    }
    workoutsByDay = _counts;
  }

  // TODO: Localize the first day-of-week for streak weeks computation
  void _computeStreaks() {
    logger.t("Recomputed streaks");

    var (streak, rest) = (0, 0);

    final keys = workoutsByDay.keys.toList();
    keys.sort();

    var today = DateTime.now().startOfDay;
    var lastMonday = today.weekday == DateTime.monday
        ? today
        : today.subtract(Duration(days: today.weekday - 1));

    while (true) {
      if (keys.any((element) =>
          element.isAfter(lastMonday) &&
          element.isBefore(lastMonday.add(const Duration(days: 7))))) {
        streak++;
        lastMonday = lastMonday.subtract(const Duration(days: 7));
      } else {
        break;
      }
    }

    if (!workoutsByDay.containsKey(today)) {
      final keys = workoutsByDay.keys.toList()..sort();
      if (keys.isNotEmpty) {
        rest = today.difference(keys.last).inDays;
      }
    }

    streaks((streak, rest));
  }

  void deleteWorkout(Workout workout) {
    service.removeHistoryWorkoutById(workout.id);
    if (workout.completedBy != null) {
      service.removeHistoryWorkoutById(workout.completedBy!);
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
          icon: const Icon(Icons.info),
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
          icon: const Icon(Icons.info),
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
    return service.workoutHistory.firstWhereOrNull(
      (element) => element.completedBy == continuationWorkout.id,
    );
  }

  void finishEditingWorkoutWithDialog(BuildContext context, Workout workout) {
    showDialog(
      context: context,
      builder: (context) => WorkoutFinishEditingPage(
        workout: workout,
      ),
    );
  }

  void submitEditedWorkout(Workout workout) {
    service.setHistoryWorkout(workout);
    Get.back();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      Get.back();
      Get.back();
    });
  }

  /// Adds a new workout to the history, avoiding collisions
  void addNewWorkout(Workout workout) {
    final collides = service.hasHistoryWorkout(workout.id);
    if (collides) {
      workout = workout.regenerateID();
      if (workout.completes != null) {
        final completed = service.getHistoryWorkout(workout.completes!);
        if (completed != null) {
          service.setHistoryWorkout(completed.copyWith(
            completedBy: workout.id,
          ));
        } else {
          workout = workout.copyWith(completes: null);
        }
      }
    }
    service.setHistoryWorkout(workout);
  }

  Map<MuscleCategory, double> calculateMuscleCategoryDistributionFor({
    required List<Workout> workouts,
  }) {
    Map<MuscleCategory, double> map = {
      for (final category in MuscleCategory.values) category: 0,
    };

    void handleExercise(Workout workout, Exercise exercise) {
      for (final group in [
        exercise.primaryMuscleGroup,
        ...exercise.secondaryMuscleGroups
      ]) {
        if (group.category == null) continue;
        map[group.category!] = map[group.category!]! +
            exercise.sets
                .where((element) => !workout.isConcrete || element.done)
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

  void applyExerciseModification(Exercise exercise) {
    assert(exercise.isCustom);

    final newHistory = service.historyBox.values.toList();
    for (int i = 0; i < newHistory.length; i++) {
      final workout = newHistory[i];

      final res = workout.exercises.toList();
      for (int i = 0; i < res.length; i++) {
        res[i].when(
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
      newHistory[i] = workout.copyWith.exercises(res);
    }
    service.writeAllHistory(newHistory);
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
}

extension WorkoutHistory on Workout {
  bool get hasContinuation =>
      Get.find<HistoryController>().hasContinuation(incompleteWorkout: this);
  Workout? get continuation =>
      Get.find<HistoryController>().getContinuation(incompleteWorkout: this);
  Workout? get originalWorkoutForContinuation => Get.find<HistoryController>()
      .getOriginalForContinuation(continuationWorkout: this);
}
