import 'package:get/get.dart';
import 'package:gymtracker/controller/exercises_controller.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/model/exercise.dart';
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

  CustomToLibraryExerciseMigration(this.from, this.to);

  RoutinesController get routinesController => Get.find<RoutinesController>();
  HistoryController get historyController => Get.find<HistoryController>();

  @override
  List<Workout> get affectedRoutines => [
        for (final workout in routinesController.workouts)
          if (workout.hasExercise(from)) workout
      ];

  @override
  List<Workout> get affectedHistory => [
        for (final workout in historyController.history)
          if (workout.hasExercise(from)) workout
      ];

  @override
  void apply() {
    routinesController.replaceExercise(from, to);
    historyController.replaceExercise(from, to);
  }
}

class RemoveUnusedExercisesMigration extends DataMigration {
  RemoveUnusedExercisesMigration();

  ExercisesController get exercisesController =>
      Get.find<ExercisesController>();
  RoutinesController get routinesController => Get.find<RoutinesController>();
  HistoryController get historyController => Get.find<HistoryController>();

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
