import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

import '../model/exercise.dart';
import '../model/set.dart';
import '../model/workout.dart';
import '../service/database.dart';
import '../view/workout.dart';
import 'countdown_controller.dart';
import 'workouts_controller.dart';

class WorkoutController extends GetxController {
  RxString name;
  Rx<DateTime> time;

  WorkoutController(String name)
      : name = name.obs,
        time = DateTime.now().obs;

  RxList<Exercise> exercises = <Exercise>[].obs;

  Workout generateWorkout() => Workout(name: name.value, exercises: exercises);

  List<ExSet> get allSets => [for (final ex in exercises) ...ex.sets];
  List<ExSet> get doneSets => [
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
      Get.find<WorkoutsController>().hasOngoingWorkout(true);
    });
  }

  @override
  void onClose() {
    super.onClose();
    removeCountdown();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      Get.find<WorkoutsController>().hasOngoingWorkout(false);
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
          icon: const Icon(Icons.info),
          title: Text("ongoingWorkout.cancel.title".tr),
          content: Text(
            "ongoingWorkout.cancel.text".tr,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: Text("ongoingWorkout.cancel.actions.no".tr),
            ),
            FilledButton.tonal(
              onPressed: () {
                Get.back();
                Get.delete<WorkoutController>();

                onCanceled();
              },
              child: Text("ongoingWorkout.cancel.actions.yes".tr),
            ),
          ],
        );
      },
    );
  }

  void finishWorkoutWithDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const WorkoutFinishPage(),
    );
  }

  void sumbit(String name, Duration duration) {
    removeCountdown();

    final workout = Workout(
      name: name,
      exercises: exercises,
      duration: duration,
      startingDate: time.value,
    );
    final service = Get.find<DatabaseService>();
    service.workoutHistory = [
      ...service.workoutHistory,
      workout,
    ];
    Get.back();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      Get.back();
      Get.delete<WorkoutController>();
    });
  }

  void removeCountdown() {
    Get.find<CountdownController>().removeCountdown();
  }
}
