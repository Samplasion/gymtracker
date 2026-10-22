import 'package:collection/collection.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/controller/workout_controller.dart';
import 'package:gymtracker/data/exercises.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/provider/training_data.dart';
import 'package:gymtracker/service/database.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'exercises_controller.g.dart';

@Riverpod(keepAlive: true)
ExercisesController exercisesController(Ref ref) {
  ref.listen(customExercisesProvider, (_, _) {});
  return ExercisesController(ref);
}

class ExercisesController {
  ExercisesController(this.ref);
  final Ref ref;
  DatabaseService get service => ref.read(databaseServiceProvider);
  List<Exercise> get exercises =>
      ref.read(customExercisesProvider).value ?? const [];
  Stream<List<Exercise>> get exercises$ => service.exercises$;
  bool hasExerciseInUse(Exercise exercise) =>
      ref.read(routinesControllerProvider).hasExercise(exercise) ||
      ref.read(historyControllerProvider).hasExercise(exercise) ||
      (ref.read(workoutControllerProvider) != null &&
          ref.read(workoutControllerProvider.notifier).hasExercise(exercise));
  Future<void> applyExerciseModification(Exercise exercise) async {
    final owner = service.db.currentUserId;
    final routines = ref.read(routinesControllerProvider);
    final history = ref.read(historyControllerProvider);
    if (history.hasExercise(exercise)) {
      await history.applyExerciseModification(exercise);
    }
    if (!ref.mounted || service.db.currentUserId != owner) return;
    if (routines.hasExercise(exercise)) {
      await routines.applyExerciseModification(exercise);
    }
    if (!ref.mounted || service.db.currentUserId != owner) return;
    if (ref.read(workoutControllerProvider) != null &&
        ref.read(workoutControllerProvider.notifier).hasExercise(exercise)) {
      ref
          .read(workoutControllerProvider.notifier)
          .applyExerciseModification(exercise);
    }
  }

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

  Exercise? getExerciseByID(String id) {
    return exercises.firstWhereOrNull((element) => element.id == id);
  }

  void removeWeightFromExercise(Exercise exercise) {
    final newExercise = exercise.copyWith(
      parameters: GTSetParameters.freeBodyReps,
      sets: [
        for (final set in exercise.sets)
          set.copyWith(parameters: GTSetParameters.freeBodyReps),
      ],
    );
    saveEdit(newExercise);
  }

  void applyWeightMultiplier(Exercise exercise, double multiplier) {
    final newExercise = exercise.copyWith(
      sets: exercise.sets
          .map((e) => e.copyWith(weight: e.weight! * multiplier))
          .toList(),
    );
    saveEdit(newExercise);
  }

  List<Exercise> search(String text, {required Translations t}) {
    final allExercises = exercises + exerciseStandardLibraryAsList;
    final results = extractTop<Exercise>(
      query: text,
      choices: allExercises.toList(),
      limit: 20,
      getter: (exercise) =>
          "${exercise.getDisplayName(t)} ${exercise.id} ${exercise.primaryMuscleGroup.getLocalizedName(t)}",
    ).map((e) => e.choice).toList();
    return results;
  }
}

extension ExerciseParent on Exercise {
  Exercise? getParent([Iterable<Exercise> customExercises = const []]) {
    if (parentID == null) return null;
    if (standard) return getStandardExerciseByID(parentID!);
    return customExercises
        .where((exercise) => exercise.id == parentID)
        .firstOrNull;
  }
}
