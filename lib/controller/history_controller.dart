import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:gymtracker/service/database.dart';

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
}
