import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:gymtracker/model/set.dart';

import '../model/exercise.dart';
import '../service/database.dart';
import 'serviceable_controller.dart';

class ExercisesController extends GetxController with ServiceableController {
  RxList<Exercise> exercises = <Exercise>[].obs;

  @override
  void onServiceChange() {
    exercises(service.exercises);
  }

  bool isNameValid(String name) =>
      !exercises.any((element) => element.name == name);

  void deleteWorkout(Exercise exercise) {
    service.exercises = service.exercises.where((e) {
      return e.name != exercise.name;
    }).toList();
  }

  Exercise generateEmpty({
    required String name,
    required SetParameters parameters,
    required MuscleGroup primaryMuscleGroup,
    required Set<MuscleGroup> secondaryMuscleGroups,
    List<ExSet> sets = const [],
    required Duration restTime,
  }) {
    return Exercise(
      name: name,
      parameters: parameters,
      sets: sets,
      primaryMuscleGroup: primaryMuscleGroup,
      secondaryMuscleGroups: secondaryMuscleGroups,
      restTime: restTime,
    );
  }

  void submit({
    required String name,
    required SetParameters parameters,
    required MuscleGroup primaryMuscleGroup,
    required Set<MuscleGroup> otherMuscleGroups,
    required Duration restTime,
  }) {
    final exercise = generateEmpty(
      name: name,
      parameters: parameters,
      sets: [],
      primaryMuscleGroup: primaryMuscleGroup,
      secondaryMuscleGroups: otherMuscleGroups,
      restTime: restTime,
    );

    service.exercises = [
      ...service.exercises,
      exercise,
    ];

    Get.back();
  }

  void deleteExercise(Exercise exercise) {
    service.exercises =
        service.exercises.where((e) => e.id != exercise.id).toList();
  }
}
