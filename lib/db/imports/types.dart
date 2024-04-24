import 'dart:convert';

import 'package:gymtracker/db/imports/v1.dart';
import 'package:gymtracker/db/imports/v2.dart';
import 'package:gymtracker/db/imports/v3.dart';
import 'package:gymtracker/model/exercisable.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/measurements.dart';
import 'package:gymtracker/model/preferences.dart';
import 'package:gymtracker/model/workout.dart';

const converters = {
  1: VersionedJsonImportV1(),
  2: VersionedJsonImportV2(),
  3: VersionedJsonImportV3(),
};

VersionedJsonImportBase getConverter(int version) {
  final converter = converters[version];
  if (converter == null) {
    throw Exception("No converter found for version $version");
  }
  return converter;
}

abstract class VersionedJsonImportBase {
  const VersionedJsonImportBase();

  int get version;

  DatabaseSnapshot process(Map<String, dynamic> json);
  Map<String, dynamic> export(DatabaseSnapshot data) {
    throw Exception("Unable to export data in database version $version");
  }
}

class DatabaseSnapshot {
  final List<Exercise> customExercises;
  final List<Workout> routines;
  final List<WorkoutExercisable> routineExercises;
  final List<Workout> historyWorkouts;
  final List<WorkoutExercisable> historyWorkoutExercises;
  final Prefs preferences;
  final List<WeightMeasurement> weightMeasurements;

  const DatabaseSnapshot({
    required this.customExercises,
    required this.routines,
    required this.routineExercises,
    required this.historyWorkouts,
    required this.historyWorkoutExercises,
    required this.preferences,
    required this.weightMeasurements,
  });

  @override
  String toString() {
    return """DatabaseSnapshot(
  customExercises: ${jsonEncode(customExercises)},
  routines: ${jsonEncode(routines)},
  routineExercises: ${jsonEncode(routineExercises)},
  historyWorkouts: ${jsonEncode(historyWorkouts)},
  historyWorkoutExercises: ${jsonEncode(historyWorkoutExercises)},
  preferences: ${jsonEncode(preferences.toJson())},
  weightMeasurements: ${jsonEncode(weightMeasurements)},
)""";
  }
}
