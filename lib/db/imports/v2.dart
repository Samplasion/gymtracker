import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/db/imports/types.dart';

class VersionedJsonImportV2 extends VersionedJsonImportBase {
  @override
  int get version => 2;

  const VersionedJsonImportV2();

  @override
  DatabaseSnapshot process(Map<String, dynamic> json) {
    return DatabaseSnapshot(
      customExercises: [
        for (final exercise in json['customExercises'])
          GTLibraryExercise.fromJson(exercise)
      ],
      routines: [
        for (final routine in json['routines']) GTRoutine.fromJson(routine)
      ],
      routineExercises: [
        for (final exercise in json['routineExercises'])
          GTExerciseOrSuperset.fromJson(exercise)
      ],
      historyWorkouts: [
        for (final workout in json['workouts'])
          GTHistoryWorkout.fromJson(workout)
      ],
      historyWorkoutExercises: [
        for (final exercise in json['workoutExercises'])
          GTExerciseOrSuperset.fromJson(exercise)
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
