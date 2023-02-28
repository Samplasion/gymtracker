import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/state_manager.dart';

import '../model/exercise.dart';
import '../model/set.dart';
import '../model/workout.dart';
import '../utils/go.dart';
import '../view/exercises.dart';
import '../view/workout.dart';
import 'countdown_controller.dart';
import 'serviceable_controller.dart';
import 'workout_controller.dart';

class WorkoutsController extends GetxController with ServiceableController {
  RxList<Workout> workouts = <Workout>[].obs;
  RxBool hasOngoingWorkout = false.obs;

  @override
  onServiceChange() {
    workouts(service.routines);
  }

  void submitRoutine({
    required String name,
    required List<Exercise> exercises,
  }) {
    final routine = Workout(
      name: name,
      exercises: exercises,
    );
    service.routines = [...service.routines, routine];

    Get.back();
  }

  Future<void> startRoutine(BuildContext context, Workout workout) async {
    if (hasOngoingWorkout.isTrue) {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => const OverwriteDialog(),
      );
      if (!(result ?? false)) return;
    }

    removeCountdown();

    Get.put(WorkoutController("workouts.untitled".tr));
    // ignore: use_build_context_synchronously
    if (Navigator.of(context).canPop()) {
      Get.back();
    }
    Go.to(() => const WorkoutView());
    Future.delayed(const Duration(milliseconds: 100)).then((_) {
      final clone = workout.clone();
      Get.find<WorkoutController>()
        ..name(clone.name)
        ..exercises([
          for (final ex in clone.exercises)
            ex.copyWith.sets([
              for (final set in ex.sets) set.copyWith.done(false),
            ]),
        ])
        ..time(DateTime.now());
    });
  }

  void deleteWorkout(Workout workout) {
    service.routines = service.routines.where((w) {
      return w.id != workout.id;
    }).toList();
  }

  generate({
    required String name,
    required List<Exercise> exercises,
    required String id,
  }) {
    return Workout(
      name: name,
      exercises: exercises,
      id: id,
    );
  }

  void editRoutine(Workout newRoutine) {
    final index =
        service.routines.indexWhere((element) => element.id == newRoutine.id);
    if (index >= 0) {
      service.routines = [
        ...service.routines.sublist(0, index),
        newRoutine,
        ...service.routines.sublist(index + 1),
      ];
    }
  }

  void removeCountdown() {
    Get.find<CountdownController>().removeCountdown();
  }
}
