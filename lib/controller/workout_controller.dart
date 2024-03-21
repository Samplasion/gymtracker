import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/countdown_controller.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/controller/serviceable_controller.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/controller/stopwatch_controller.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/model/exercisable.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/model/superset.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/struct/stopwatch_extended.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/exercise_picker.dart';
import 'package:gymtracker/view/utils/workout_done.dart';
import 'package:gymtracker/view/workout.dart';

class WorkoutController extends GetxController with ServiceableController {
  RxString name;
  Rx<DateTime> time;
  Rx<String?> parentID;
  Rx<String?> infobox;
  RxBool isContinuation = false.obs;
  Rx<String?> continuesID = Rx(null);
  late Rx<Weights> weightUnit;

  WorkoutController(String name, String? parentID, String? infobox)
      : name = name.obs,
        time = DateTime.now().obs,
        parentID = Rx<String?>(parentID),
        infobox = Rx<String?>(infobox),
        weightUnit =
            (Get.find<SettingsController>().weightUnit() ?? Weights.kg).obs;

  factory WorkoutController.fromSavedData(Map<String, dynamic> data) {
    final cont =
        WorkoutController(data['name'], data['parentID'], data['infobox']);

    cont.exercises((data['exercises'] as List)
        .map((el) => WorkoutExercisable.fromJson(el))
        .toList());
    cont.time(DateTime.fromMillisecondsSinceEpoch(
        data['time'] ?? DateTime.now().millisecondsSinceEpoch));
    cont.continuesID(data['continuesID']);
    cont.isContinuation(data['isContinuation'] ?? false);
    cont.weightUnit(Weights.values.firstWhere(
      (element) => element.name == data['weightUnit'],
      orElse: () => Weights.kg,
    ));

    if (data.containsKey("globalStopwatch")) {
      final controller = Get.find<StopwatchController>();

      // Separating the two cases this way avoids a couple of nasty bugs:
      //
      // * If the stopwatch is paused, saving the duration allows us to recover
      //   the stopwatch value without it ticking while the app is closed.
      // * If the stopwatch is running, we actually want to tick while the
      //   app is closed, so we save the starting time and the fact that it's
      //   running.
      if (data['globalStopwatchPaused'] == false) {
        controller.globalStopwatch.stopwatch = StopwatchEx.fromMilliseconds(
          DateTime.now().millisecondsSinceEpoch -
              (data['globalStopwatch'] as int),
        );
        controller.globalStopwatch.start();
      } else {
        controller.globalStopwatch.stopwatch = StopwatchEx.fromMilliseconds(
          data['globalStopwatchNominalDuration'] as int,
        );
      }
    }

    return cont;
  }

  RxList<WorkoutExercisable> exercises = <WorkoutExercisable>[].obs;

  Workout generateWorkout(String parentID) => Workout(
        name: name.value,
        exercises: exercises,
        parentID: parentID,
        infobox: infobox(),
        duration: DateTime.now().difference(time.value),
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
    final stopwatchController = Get.find<StopwatchController>();

    printInfo(info: "Saving ongoing data");
    service.writeToOngoing({
      "name": name.value,
      "exercises": exercises.map((ex) => ex.toJson()).toList(),
      "parentID": parentID.value,
      "time": time.value.millisecondsSinceEpoch,
      "infobox": infobox.value,
      "isContinuation": isContinuation.value,
      "continuesID": continuesID.value,
      "weightUnit": weightUnit.value.name,
      if (stopwatchController.globalStopwatch.currentDuration.inSeconds >
          0) ...{
        "globalStopwatch": stopwatchController
            .globalStopwatch.startingTime.millisecondsSinceEpoch,
        "globalStopwatchPaused":
            stopwatchController.globalStopwatch.isStopped(),
        "globalStopwatchNominalDuration":
            stopwatchController.globalStopwatch.currentDuration.inMilliseconds,
      }
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

  Future<void> submit(String name, Duration duration) async {
    final historyController = Get.find<HistoryController>();

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
      weightUnit: weightUnit.value,
    );

    if (isContinuation.isTrue) {
      historyController.bindContinuation(continuation: workout);
    }

    historyController.addNewWorkout(workout);
    Get.back();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      Get.back();
      Get.delete<WorkoutController>();
      askToUpdateRoutine(workout).then((_) {
        if (workout.doneSets.isNotEmpty) {
          Go.showBottomModalScreen(
            (context, controller) => WorkoutDoneSheet(
              workout: workout,
              controller: controller,
            ),
          );
        }
      });
    });
  }

  Future<void> askToUpdateRoutine(Workout workout) async {
    final routinesController = Get.find<RoutinesController>();

    if (workout.parentID != null &&
        routinesController.hasRoutine(workout.parentID!)) {
      final routine = routinesController.getRoutine(workout.parentID!);
      final difference = WorkoutDifference.fromWorkouts(
        oldWorkout: routine!,
        newWorkout: workout,
      );
      if (!difference.isEmpty) {
        final confirm = await Go.confirm(
          "ongoingWorkout.updateRoutine.differenceTitle".t,
          () {
            String text =
                "${"ongoingWorkout.updateRoutine.differenceText".t}\n\n";
            if (difference.addedExercises > 0) {
              text +=
                  "- ${"ongoingWorkout.updateRoutine.differences.added".plural(difference.addedExercises)}\n";
            }
            if (difference.removedExercises > 0) {
              text +=
                  "- ${"ongoingWorkout.updateRoutine.differences.removed".plural(difference.removedExercises)}\n";
            }
            if (difference.changedExercises > 0) {
              text +=
                  "- ${"ongoingWorkout.updateRoutine.differences.changed".plural(difference.changedExercises)}\n";
            }

            return text.trim();
          }(),
          transformText: (s) => s,
        );
        if (confirm) {
          routinesController.updateRoutineFromWorkout(
              workout.parentID!, workout);
        }
      }
    }
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

  bool hasExercise(Exercise exercise) {
    return exercises.any((element) {
      return element.map(
          exercise: (ex) => exercise.isParentOf(ex),
          superset: (ss) =>
              ss.exercises.any((element) => exercise.isParentOf(element)));
    });
  }

  void applyExerciseModification(Exercise exercise) {
    assert(exercise.isCustom);
    assert(hasExercise(exercise));

    final res = exercises.toList();
    for (int i = 0; i < exercises.length; i++) {
      exercises[i].when(
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

    exercises(res);
  }

  Future<void> pickExercises() async {
    final exs = await Go.to<List<Exercise>>(
        () => const ExercisePicker(singlePick: false));
    if (exs == null || exs.isEmpty) return;
    exercises.addAll(
      exs.map(
        (ex) => ex.makeChild().copyWith.sets(
          [
            ExSet.empty(
              kind: SetKind.normal,
              parameters: ex.parameters,
            ),
          ],
        ),
      ),
    );
    exercises.refresh();
  }

  Future<void> pickExercisesForSuperset(int i) async {
    final exs = await Go.to<List<Exercise>>(
        () => const ExercisePicker(singlePick: false));
    if (exs == null || exs.isEmpty) return;
    (exercises[i] as Superset).exercises.addAll(
          exs.map(
            (ex) => ex.makeChild().copyWith.sets([
              ExSet.empty(
                kind: SetKind.normal,
                parameters: ex.parameters,
              ),
            ]),
          ),
        );
    exercises.refresh();
    save();
  }

  @override
  void onServiceChange() {}
}
