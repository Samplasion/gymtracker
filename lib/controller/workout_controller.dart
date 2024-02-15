import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/countdown_controller.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/controller/serviceable_controller.dart';
import 'package:gymtracker/controller/stopwatch_controller.dart';
import 'package:gymtracker/model/exercisable.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/view/workout.dart';

class WorkoutController extends GetxController with ServiceableController {
  RxString name;
  Rx<DateTime> time;
  Rx<String?> parentID;
  Rx<String?> infobox;
  RxBool isContinuation = false.obs;
  Rx<String?> continuesID = Rx(null);

  WorkoutController(String name, String? parentID, String? infobox)
      : name = name.obs,
        time = DateTime.now().obs,
        parentID = Rx<String?>(parentID),
        infobox = Rx<String?>(infobox);

  factory WorkoutController.fromSavedData(Map<String, dynamic> data) {
    // final  data = service.getOngoingData()!;
    final cont =
        WorkoutController(data['name'], data['parentID'], data['infobox']);
    cont.exercises((data['exercises'] as List)
        .map((el) => WorkoutExercisable.fromJson(el))
        .toList());
    cont.time(DateTime.fromMillisecondsSinceEpoch(
        data['time'] ?? DateTime.now().millisecondsSinceEpoch));
    cont.continuesID(data['continuesID']);
    cont.isContinuation(data['isContinuation'] ?? false);
    return cont;
  }

  RxList<WorkoutExercisable> exercises = <WorkoutExercisable>[].obs;

  Workout generateWorkout(String parentID) => Workout(
        name: name.value,
        exercises: exercises,
        parentID: parentID,
        infobox: infobox(),
      );

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

  void save() {
    if (Get.find<RoutinesController>().hasOngoingWorkout.isFalse) return;

    printInfo(info: "Saving ongoing data");
    service.writeToOngoing({
      "name": name.value,
      "exercises": exercises.map((ex) => ex.toJson()).toList(),
      "parentID": parentID.value,
      "time": time.value.millisecondsSinceEpoch,
      "infobox": infobox.value,
      "isContinuation": isContinuation.value,
      "continuesID": continuesID.value,
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
    showDialog(
      context: context,
      builder: (context) => const WorkoutFinishPage(),
    );
  }

  void sumbit(String name, Duration duration) {
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
    );

    if (isContinuation.isTrue) {
      final historyController = Get.find<HistoryController>();
      historyController.bindContinuation(continuation: workout);
    }

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

  @override
  void onServiceChange() {}
}
