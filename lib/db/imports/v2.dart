import 'package:gymtracker/db/imports/types.dart';
import 'package:gymtracker/model/exercisable.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/workout.dart';

class VersionedJsonImportV2 extends VersionedJsonImportBase {
  @override
  int get version => 2;

  const VersionedJsonImportV2();

  @override
  DatabaseSnapshot process(Map<String, dynamic> json) {
    return DatabaseSnapshot(
      customExercises: [
        for (final exercise in json['customExercises'])
          Exercise.fromJson(exercise)
      ],
      routines: [
        for (final routine in json['routines']) Workout.fromJson(routine)
      ],
      routineExercises: [
        for (final exercise in json['routineExercises'])
          WorkoutExercisable.fromJson(exercise)
      ],
      historyWorkouts: [
        for (final workout in json['workouts']) Workout.fromJson(workout)
      ],
      historyWorkoutExercises: [
        for (final exercise in json['workoutExercises'])
          WorkoutExercisable.fromJson(exercise)
      ],
    );
  }

  @override
  Map<String, dynamic> export(DatabaseSnapshot data) {
    return {
      'version': version,
      'customExercises': [for (final ex in data.customExercises) ex.toJson()],
      'routines': [for (final routine in data.routines) routine.toJson()],
      'routineExercises': [for (final ex in data.routineExercises) ex.toJson()],
      'workouts': [
        for (final workout in data.historyWorkouts) workout.toJson()
      ],
      'workoutExercises': [
        for (final ex in data.historyWorkoutExercises) ex.toJson()
      ],
    };
  }
}
