import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/coordinator.dart';
import 'package:gymtracker/controller/serviceable_controller.dart';
import 'package:gymtracker/controller/workout_controller.dart';
import 'package:gymtracker/data/exercises.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/exercise_creator.dart';
import 'package:rxdart/rxdart.dart';

class ExercisesController extends GetxController with ServiceableController {
  RxList<Exercise> exercises = <Exercise>[].obs;
  BehaviorSubject<List<Exercise>> exercises$ =
      BehaviorSubject<List<Exercise>>.seeded([]);

  @override
  onInit() {
    super.onInit();
    service.exercises$.listen((event) {
      logger.i("Updated with ${event.length} exercises");
      exercises(event);
      exercises$.add(event);
    });
  }

  @override
  void onServiceChange() {}

  bool isNameValid(String name) =>
      !exercises.any((element) => element.name == name);

  Exercise generateEmpty({
    required String name,
    required GTSetParameters parameters,
    required GTMuscleGroup primaryMuscleGroup,
    required Set<GTMuscleGroup> secondaryMuscleGroups,
    List<GTSet> sets = const [],
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
      supersetID: null,
      workoutID: null,
      equipment: GTGymEquipment.none,
    );
  }

  void submit({
    required String name,
    required GTSetParameters parameters,
    required GTMuscleGroup primaryMuscleGroup,
    required Set<GTMuscleGroup> otherMuscleGroups,
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

  Future<void> saveEdit(Exercise exercise) {
    return service.setExercise(exercise);
  }

  Future<Exercise?> editExercise(
      Exercise exercise, List<(Exercise, int, Workout)> history) async {
    if (Get.isRegistered<WorkoutController>() &&
        Get.find<WorkoutController>().hasExercise(exercise)) {
      final shouldOverwrite = await Go.confirm(
        "exercise.editor.overwriteInWorkout.title",
        "exercise.editor.overwriteInWorkout.body",
      );
      if (!shouldOverwrite) {
        return null;
      }
    }
    final ex = await Go.showBottomModalScreen<Exercise>(
        (context, controller) => ExerciseCreator(
              base: exercise,
              scrollController: controller,
              shouldChangeParameters: history.isEmpty,
            ));
    final isInUse = Get.find<Coordinator>().hasExercise(exercise);
    logger.d(("IS IN USE", isInUse));
    if (ex != null) {
      assert(ex.id == exercise.id);
      await Get.find<ExercisesController>().saveEdit(ex);
      if (isInUse) {
        await Get.find<Coordinator>().applyExerciseModification(ex);
      }
    }
    return ex;
  }

  getExerciseByID(String id) {
    return exercises.firstWhereOrNull((element) => element.id == id);
  }

  void removeWeightFromExercise(Exercise exercise) {
    final newExercise =
        exercise.copyWith(parameters: GTSetParameters.freeBodyReps);
    saveEdit(newExercise);
  }

  void applyWeightMultiplier(Exercise exercise, double multiplier) {
    final newExercise =
        exercise.copyWith(sets: exercise.sets.map((e) => e.copyWith(weight: e.weight! * multiplier)).toList());
    saveEdit(newExercise);
  }

  List<Exercise> search(String text) {
    final allExercises = exercises$.value + exerciseStandardLibraryAsList;
    final results = extractTop<Exercise>(
      query: text,
      choices: allExercises.toList(),
      limit: 20,
      getter: (exercise) => "${exercise.displayName} ${exercise.id} ${exercise.primaryMuscleGroup.localizedName}",
    ).map((e) => e.choice).toList();
    return results;
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
