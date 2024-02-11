import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:gymtracker/model/exercisable.dart';
import 'package:gymtracker/model/superset.dart';
import 'package:gymtracker/service/localizations.dart';

import '../model/exercise.dart';
import '../model/workout.dart';
import 'serviceable_controller.dart';

class HistoryController extends GetxController with ServiceableController {
  RxList<Workout> history = <Workout>[].obs;

  @override
  void onServiceChange() {
    history(service.workoutHistory);
    history.sort((a, b) => (a.startingDate ??
            DateTime.fromMillisecondsSinceEpoch(0))
        .compareTo(b.startingDate ?? DateTime.fromMillisecondsSinceEpoch(0)));
  }

  void deleteWorkout(Workout workout) {
    service.workoutHistory = service.workoutHistory.where((w) {
      return w.id != workout.id;
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
}
