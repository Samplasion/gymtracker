import 'package:get/get.dart';
import 'package:gymtracker/controller/serviceable_controller.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/set.dart';

class ExercisesController extends GetxController with ServiceableController {
  RxList<Exercise> exercises = <Exercise>[].obs;

  @override
  void onServiceChange() {
    exercises(service.exercises);
  }

  bool isNameValid(String name) =>
      !exercises.any((element) => element.name == name);

  Exercise generateEmpty({
    required String name,
    required SetParameters parameters,
    required MuscleGroup primaryMuscleGroup,
    required Set<MuscleGroup> secondaryMuscleGroups,
    List<ExSet> sets = const [],
    required Duration restTime,
  }) {
    return Exercise.custom(
      name: name,
      parameters: parameters,
      sets: sets,
      primaryMuscleGroup: primaryMuscleGroup,
      secondaryMuscleGroups: secondaryMuscleGroups,
      restTime: restTime,
      notes: '',
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

    service.setExercise(exercise);

    Get.back();
  }

  void deleteExercise(Exercise exercise) {
    service.removeExercise(exercise);
  }
}
