import 'package:get/get.dart';
import 'package:gymtracker/controller/coordinator.dart';
import 'package:gymtracker/controller/serviceable_controller.dart';
import 'package:gymtracker/controller/workout_controller.dart';
import 'package:gymtracker/data/exercises.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/exercise_creator.dart';
import 'package:gymtracker/view/library.dart';

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

    addExercise(exercise);

    Get.back();
  }

  void addExercise(Exercise exercise) {
    service.setExercise(exercise);
  }

  void deleteExercise(Exercise exercise) {
    service.removeExercise(exercise);
  }

  void saveEdit(Exercise exercise) {
    service.setExercise(exercise);
  }

  void editExercise(
      Exercise exercise, List<(Exercise, int, Workout)> history) async {
    if (Get.isRegistered<WorkoutController>() &&
        Get.find<WorkoutController>().hasExercise(exercise)) {
      final shouldOverwrite = await Go.confirm(
        "exercise.editor.overwriteInWorkout.title",
        "exercise.editor.overwriteInWorkout.body",
      );
      if (!shouldOverwrite) {
        return;
      }
    }
    final ex = await Go.showBottomModalScreen<Exercise>(
        (context, controller) => ExerciseCreator(
              base: exercise,
              scrollController: controller,
              shouldChangeParameters: history.isEmpty,
            ));
    final isInUse = Get.find<Coordinator>().hasExercise(exercise);
    print(("IS IN USE", isInUse));
    if (ex != null) {
      assert(ex.id == exercise.id);
      Get.find<ExercisesController>().saveEdit(ex);
      if (isInUse) {
        Get.find<Coordinator>().applyExerciseModification(ex);
      }
      Go.off(() => ExerciseInfoView(exercise: ex));
    }
  }

  getExerciseByID(String id) {
    return exercises.firstWhereOrNull((element) => element.id == id);
  }
}

extension ExerciseParent on Exercise {
  ExercisesController get _controller => Get.find<ExercisesController>();

  Exercise? getParent() {
    if (parentID == null) return null;

    if (standard) {
      return getStandardExerciseByID(parentID!);
    }

    return _controller.getExerciseByID(parentID!);
  }
}
