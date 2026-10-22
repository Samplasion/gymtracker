import 'package:gymtracker/controller/exercises_controller.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/utils/extensions.dart';

abstract class DataMigration {
  List<Workout> get affectedRoutines => [];
  List<Workout> get affectedHistory => [];
  List<Exercise> get affectedExercises => [];

  void apply();
}

class CustomToLibraryExerciseMigration extends DataMigration {
  final Exercise from;
  final Exercise to;

  CustomToLibraryExerciseMigration(
    this.from,
    this.to, {
    required this.routinesController,
    required this.historyController,
  });

  final RoutinesController routinesController;
  final HistoryController historyController;

  @override
  List<Workout> get affectedRoutines => [
    for (final workout in routinesController.workouts)
      if (workout.hasExercise(from)) workout,
  ];

  @override
  List<Workout> get affectedHistory => [
    for (final workout in historyController.history)
      if (workout.hasExercise(from)) workout,
  ];

  @override
  void apply() {
    routinesController.replaceExercise(from, to);
    historyController.replaceExercise(from, to);
  }
}

class RemoveUnusedExercisesMigration extends DataMigration {
  RemoveUnusedExercisesMigration({
    required this.exercisesController,
    required this.routinesController,
    required this.historyController,
  });

  final ExercisesController exercisesController;
  final RoutinesController routinesController;
  final HistoryController historyController;

  @override
  List<Exercise> get affectedExercises {
    final usedExercises = {
      for (final workout in routinesController.workouts)
        for (final exercise in workout.flattenedExercises.whereType<Exercise>())
          exercise.parentID,
      for (final workout in historyController.history)
        for (final exercise in workout.flattenedExercises.whereType<Exercise>())
          exercise.parentID,
    };

    return exercisesController.exercises
        .where((exercise) => !usedExercises.contains(exercise.id))
        .toList();
  }

  @override
  void apply() {
    for (final exercise in affectedExercises) {
      exercisesController.deleteExercise(exercise);
    }
  }
}

class RemoveWeightFromCustomExerciseMigration extends DataMigration {
  final Exercise exercise;

  RemoveWeightFromCustomExerciseMigration(
    this.exercise, {
    required this.exercisesController,
    required this.routinesController,
    required this.historyController,
  });

  final ExercisesController exercisesController;
  final RoutinesController routinesController;
  final HistoryController historyController;

  bool get isCompatible =>
      exercise.isCustom &&
      exercise.parameters == GTSetParameters.repsWeight &&
      affectedHistory.every(
        (workout) => workout.flattenedExercises
            .whereType<Exercise>()
            .where((ex) => exercise.isTheSameAs(ex))
            .every(
              (ex) =>
                  ex.sets.every((set) => set.weight == null || set.weight == 0),
            ),
      );

  @override
  List<Workout> get affectedRoutines => [
    for (final workout in routinesController.workouts)
      if (workout.hasExercise(exercise)) workout,
  ];

  @override
  List<Workout> get affectedHistory => [
    for (final workout in historyController.history)
      if (workout.hasExercise(exercise)) workout,
  ];

  @override
  void apply() {
    exercisesController.removeWeightFromExercise(exercise);
    routinesController.removeWeightFromExercise(exercise);
    historyController.removeWeightFromExercise(exercise);
  }
}

class GenericMultiplyWeightInExerciseMigration extends DataMigration {
  final Exercise exercise;
  final double multiplier;

  GenericMultiplyWeightInExerciseMigration(
    this.exercise,
    this.multiplier, {
    required this.exercisesController,
    required this.routinesController,
    required this.historyController,
  });

  final ExercisesController exercisesController;
  final RoutinesController routinesController;
  final HistoryController historyController;

  bool get isCompatible =>
      exercise.parameters == GTSetParameters.repsWeight &&
      affectedHistory.every(
        (workout) => workout.flattenedExercises
            .whereType<Exercise>()
            .where((ex) => exercise.isTheSameAs(ex))
            .every((ex) => ex.sets.every((set) => set.weight != null)),
      );

  @override
  List<Workout> get affectedRoutines => [
    for (final workout in routinesController.workouts)
      if (workout.hasExercise(exercise)) workout,
  ];

  @override
  List<Workout> get affectedHistory => [
    for (final workout in historyController.history)
      if (workout.hasExercise(exercise)) workout,
  ];

  @override
  void apply() {
    if (exercise.isCustom) {
      exercisesController.applyWeightMultiplier(exercise, multiplier);
    }
    routinesController.applyWeightMultiplier(exercise, multiplier);
    historyController.applyWeightMultiplier(exercise, multiplier);
  }
}
