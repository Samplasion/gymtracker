import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymtracker/model/exercisable.dart';
import 'package:gymtracker/model/superset.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:uuid/uuid.dart';

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
    Exercise cloneExercise(Exercise ex) => ex.copyWith(
          sets: ([
            for (final set in ex.sets)
              set.copyWith(
                done: false,
                reps: [SetKind.failure, SetKind.failureStripping]
                        .contains(set.kind)
                    ? 0
                    : set.reps,
              ),
          ]),
          // If we're redoing a previous workout,
          // we want to inherit the previous parent ID,
          // ie. the original routine's ID
          // But we also want to keep it if we're cloning
          // a built-in exercise, so that the translated name is kept.
          parentID: workout.isConcrete || ex.standard ? ex.parentID : ex.id,
          id: const Uuid().v4(),
        );
    Future.delayed(const Duration(milliseconds: 100)).then((_) {
      final clone = workout.clone();
      Get.find<WorkoutController>()
        ..name(clone.name)
        ..exercises([
          for (final ex in clone.exercises)
            if (ex is Exercise)
              cloneExercise(ex)
            else if (ex is Superset)
              ex.copyWith(
                exercises: ex.exercises.map(cloneExercise).toList(),
              ),
        ])
        ..time(DateTime.now())
        // Same goes for this
        ..parentID(workoutID)
        ..infobox(workout.infobox)
        ..save();
    });
  }

  void deleteWorkout(Workout workout) {
    service.routines = service.routines.where((w) {
      return w.id != workout.id;
    }).toList();
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
}
