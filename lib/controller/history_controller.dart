import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:gymtracker/service/database.dart';

import '../model/exercise.dart';
import '../model/workout.dart';
import 'serviceable_controller.dart';

class HistoryController extends GetxController with ServiceableController {
  RxList<Workout> history = <Workout>[].obs;

  @override
  void onServiceChange() {
    history(service.workoutHistory);
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

    final exercises = <Exercise>[];
    for (final exercise in workout.exercises) {
      if (exercise.isCustom) {
        workout.id.printInfo(info: "Custom exercise found");
        exercises.add(exercise);
        continue;
      }

      // Returns the standard exercise, which is not an instance
      // of an exercise in the Standard Library but a child of it.
      final standard = parent.exercises.firstWhereOrNull(
        (element) => element.id == exercise.parentID,
      );
      if (standard == null) {
        workout.id.printInfo(info: "Standard exercise not found");
        exercises.add(exercise);
        continue;
      }

      exercises.add(exercise.copyWith(
        parentID: standard.parentID ?? standard.id,
      ));
    }

    return workout.copyWith(
      exercises: exercises,
    );
  }
}
