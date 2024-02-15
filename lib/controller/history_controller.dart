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
import 'package:gymtracker/view/workout_editor.dart';

class HistoryController extends GetxController with ServiceableController {
  RxList<Workout> history = <Workout>[].obs;

  int get userVisibleLength => userVisibleWorkouts.length;

  List<Workout> get userVisibleWorkouts => history
      .where((workout) => !workout.isContinuation || kDebugMode)
      .toList();

  @override
  void onServiceChange() {
    history(service.workoutHistory);
    history.sort((a, b) => (a.startingDate ??
            DateTime.fromMillisecondsSinceEpoch(0))
        .compareTo(b.startingDate ?? DateTime.fromMillisecondsSinceEpoch(0)));
  }

  void deleteWorkout(Workout workout) {
    service.workoutHistory = service.workoutHistory.where((w) {
      // Remove the workout and its continuation, if any
      return w.id != workout.id && w.id != workout.completedBy;
    }).toList();
  }

  void setParentID(Workout workout, {String? newParentID}) {
    final index = service.workoutHistory
        .indexWhere((element) => element.id == workout.id);
    if (index >= 0) {
      service.workoutHistory = [
        ...service.workoutHistory.sublist(0, index),
        workout.copyWith.parentID(newParentID),
        ...service.workoutHistory.sublist(index + 1),
      ];
    }
  }

  Workout rename(Workout workout, {String? newName}) {
    final index = service.workoutHistory
        .indexWhere((element) => element.id == workout.id);
    final newWorkout = workout.copyWith(name: newName);
    if (index >= 0) {
      service.workoutHistory = [
        ...service.workoutHistory.sublist(0, index),
        newWorkout,
        ...service.workoutHistory.sublist(index + 1),
      ];
    }
    return newWorkout;
  }

  Workout fixWorkout(Workout workout) {
    workout.id.printInfo(info: "Fixing workout");
    if (workout.parentID == null) {
      workout.id.printInfo(info: "No parent ID");
      return workout;
    }
    final parent = service.routines.firstWhereOrNull(
      (element) => element.id == workout.parentID,
    );
    if (parent == null) {
      workout.id.printInfo(info: "Parent not found");
      return workout;
    }

    final exercises = <WorkoutExercisable>[];
    for (final exercise in workout.exercises) {
      Exercise getFixedExercise(Exercise exercise) {
        if (exercise.isCustom) {
          workout.id.printInfo(info: "Custom exercise found");
          return exercise;
        }

        // Returns the standard exercise, which is not an instance
        // of an exercise in the Standard Library but a child of it.
        final standard = parent.exercises.firstWhereOrNull(
          (element) => element is Exercise && element.id == exercise.parentID,
        );
        if (standard == null) {
          workout.id.printInfo(info: "Standard exercise not found");
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
    service.workoutHistory = service.workoutHistory.map((workout) {
      if (workout.parentID == id) {
        return workout.copyWith(parentID: null);
      }
      return workout;
    }).toList();
  }

  void bindContinuation({required Workout continuation}) {
    service.workoutHistory = service.workoutHistory.map((workout) {
      if (workout.id == continuation.completes) {
        return workout.copyWith(completedBy: continuation.id);
      }
      return workout;
    }).toList();
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
    final index = service.workoutHistory
        .indexWhere((element) => element.id == workout.id);
    if (index >= 0) {
      service.workoutHistory = [
        ...service.workoutHistory.sublist(0, index),
        workout,
        ...service.workoutHistory.sublist(index + 1),
      ];
    }
    Get.back();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      Get.back();
      Get.back();
    });
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
