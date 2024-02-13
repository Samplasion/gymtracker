import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:gymtracker/model/exercisable.dart';
import 'package:gymtracker/model/superset.dart';
import 'package:gymtracker/service/localizations.dart';

import '../controller/history_controller.dart';
import '../model/exercise.dart';
import '../model/set.dart';
import '../model/workout.dart';
import '../utils/go.dart';
import '../utils/utils.dart' as utils;
import '../view/exercises.dart';
import '../view/workout.dart';
import 'countdown_controller.dart';
import 'serviceable_controller.dart';
import 'workout_controller.dart';

class WorkoutsController extends GetxController with ServiceableController {
  RxList<Workout> workouts = <Workout>[].obs;
  RxBool hasOngoingWorkout = false.obs;

  @override
  onInit() {
    super.onInit();
    Get.put(HistoryController());

    if (service.hasOngoing) {
      Get.put(WorkoutController.fromSavedData(service.getOngoingData()!));
    }
  }

  @override
  onServiceChange() {
    workouts(service.routines);
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    printInfo(info: "Change lifecycle state callback received (state: $state)");
    if (hasOngoingWorkout()) {
      switch (state) {
        case AppLifecycleState.inactive:
        case AppLifecycleState.paused:
        case AppLifecycleState.resumed:
          Get.find<WorkoutController>().save();
          break;
        default:
          break;
      }
    }
  }

  void submitRoutine({
    required String name,
    required List<WorkoutExercisable> exercises,
    required String? infobox,
  }) {
    final routine = Workout(
      name: name,
      exercises: exercises,
      infobox: infobox,
    );
    service.routines = [...service.routines, routine];

    Get.back();
  }

  Future<void> startRoutine(
    BuildContext context,
    Workout workout, {
    bool isEmpty = false,
  }) async {
    if (hasOngoingWorkout.isTrue) {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => const OverwriteDialog(),
      );
      if (!(result ?? false)) return;
    }

    removeCountdown();

    String? workoutID = workout.isConcrete ? workout.parentID : workout.id;
    if (isEmpty) {
      workoutID = null;
    }

    Get.put(WorkoutController("workouts.untitled".t, workoutID, null));
    // ignore: use_build_context_synchronously
    if (Navigator.of(context).canPop()) {
      Get.back();
    }
    Go.to(() => const WorkoutView());
    Future.delayed(const Duration(milliseconds: 100)).then((_) {
      _clone(
        workout,
        parentID: workoutID,
        exerciseFilter: (ex) => true,
      );
    });
  }

  bool isWorkoutContinuable(Workout workout) {
    return workout.isContinuable;
  }

  Future<void> continueWorkout(
    BuildContext context,
    Workout workout,
  ) async {
    if (hasOngoingWorkout.isTrue) {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => const OverwriteDialog(),
      );
      if (!(result ?? false)) return;
    }

    removeCountdown();

    String? parentID = workout.parentID;

    Get.put(WorkoutController(workout.name, parentID, workout.infobox));
    // ignore: use_build_context_synchronously
    if (Navigator.of(context).canPop()) {
      Get.back();
    }
    Go.to(() => const WorkoutView());
    Future.delayed(const Duration(milliseconds: 100)).then((_) {
      _clone(
        workout,
        parentID: parentID,
        exerciseFilter: (ex) => ex.sets.any((set) => !set.done),
        setFilter: (set) => !set.done,
        continuation: true,
      );
    });
  }

  _clone(
    Workout workout, {
    String? parentID,
    required bool Function(WorkoutExercisable exercise) exerciseFilter,
    bool Function(ExSet set)? setFilter,
    bool continuation = false,
  }) {
    final clone = workout.clone();
    Get.find<WorkoutController>()
      ..name(clone.name)
      ..exercises([
        for (final ex in clone.exercises)
          if (exerciseFilter(ex))
            if (ex is Exercise)
              ex.instantiate(
                workout: workout,
                setFilter: setFilter,
              )
            else if (ex is Superset)
              ex.copyWith(
                exercises: ex.exercises
                    .map((e) => e.instantiate(
                          workout: workout,
                          setFilter: setFilter,
                        ))
                    .toList(),
              ),
      ])
      ..time(DateTime.now())
      ..parentID(parentID)
      ..infobox(workout.infobox)
      ..isContinuation(continuation)
      ..continuesID(continuation ? workout.id : null)
      ..save();
  }

  void deleteWorkout(Workout workout) {
    service.routines = service.routines.where((w) {
      return w.id != workout.id;
    }).toList();
    Get.find<HistoryController>().unbindAllFromParent(workout.id);
  }

  generate({
    required String name,
    required List<WorkoutExercisable> exercises,
    required String id,
    required String? infobox,
  }) {
    return Workout(
      name: name,
      exercises: exercises,
      id: id,
      infobox: infobox,
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

  void reorder(int oldIndex, int newIndex) {
    final list = service.routines;
    utils.reorder(list, oldIndex, newIndex);
    service.routines = list;
  }

  List<Workout> getChildren(Workout routine) {
    final historyCont = Get.find<HistoryController>();
    return [
      for (final workout in historyCont.history)
        if (workout.parentID == routine.id) workout
    ];
  }

  String importWorkout(Workout workout) {
    final routine = workout.toRoutine();
    service.routines = [
      ...service.routines,
      routine,
    ];
    return routine.id;
  }

  void deleteRoutineWithDialog(
    BuildContext context, {
    required Workout workout,
    required void Function() onCanceled,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: const Icon(Icons.info),
          title: Text("routines.actions.delete.title".t),
          content: Text(
            "routines.actions.delete.text".t,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back(closeOverlays: true);
              },
              child: Text("routines.actions.delete.actions.no".t),
            ),
            FilledButton.tonal(
              onPressed: () {
                deleteWorkout(workout);
                SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                  Get.back(closeOverlays: true);
                });

                onCanceled();
              },
              child: Text("routines.actions.delete.actions.yes".t),
            ),
          ],
        );
      },
    );
  }
}
