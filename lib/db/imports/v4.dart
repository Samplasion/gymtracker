import 'package:gymtracker/db/imports/types.dart';
import 'package:gymtracker/model/exercisable.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/measurements.dart';
import 'package:gymtracker/model/preferences.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/logger.dart';

class VersionedJsonImportV4 extends VersionedJsonImportBase {
  @override
  int get version => 4;

  const VersionedJsonImportV4();

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
      preferences: Prefs.fromJson(json['preferences']),
      weightMeasurements: [
        for (final weight in json['weightMeasurements'])
          WeightMeasurement.fromJson(weight)
      ],
      folders: [
        for (final folder in json['folders']) GTRoutineFolder.fromJson(folder)
      ],
      foods: [],
      nutritionGoals: [],
      customBarcodeFoods: {},
      favoriteFoods: [],
    )..logger.t("Importing");
  }

  @override
  void validate(DatabaseSnapshot data) {
    final folders = data.folders.map((f) => f.id).toSet();
    if (data.routines
        .any((ex) => ex.folder != null && !folders.contains(ex.folder!.id))) {
      final invalidFolders = data.routines
          .where((ex) => ex.folder != null && !folders.contains(ex.folder!.id))
          .map((ex) => ex.folder!.id)
          .toSet();
      throw Exception(
          "Invalid folder reference(s) in routines: $invalidFolders.");
    }
  }

  @override
  Map<String, dynamic> export(DatabaseSnapshot data) {
    return {
      'version': version,
      'customExercises': [for (final ex in data.customExercises) ex.toJson()],
      'routines': [
        for (final routine in data.routines)
          routine.copyWith.exercises([]).toJson()
      ],
      'routineExercises': [for (final ex in data.routineExercises) ex.toJson()],
      'workouts': [
        for (final workout in data.historyWorkouts)
          workout.copyWith.exercises([]).toJson()
      ],
      'workoutExercises': [
        for (final ex in data.historyWorkoutExercises) ex.toJson()
      ],
      'preferences': data.preferences.toJson(),
      'weightMeasurements': [
        for (final weight in data.weightMeasurements) weight.toJson()
      ],
      'folders': [for (final folder in data.folders) folder.toJson()],
    };
  }
}
