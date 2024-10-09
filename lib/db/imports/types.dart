import 'dart:convert';

import 'package:gymtracker/db/imports/v1.dart';
import 'package:gymtracker/db/imports/v2.dart';
import 'package:gymtracker/db/imports/v3.dart';
import 'package:gymtracker/db/imports/v4.dart';
import 'package:gymtracker/db/imports/v5.dart';
import 'package:gymtracker/db/imports/v6.dart';
import 'package:gymtracker/db/imports/v7.dart';
import 'package:gymtracker/db/imports/v8.dart';
import 'package:gymtracker/db/imports/v9.dart';
import 'package:gymtracker/model/exercisable.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/measurements.dart';
import 'package:gymtracker/model/preferences.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/struct/nutrition.dart';

const converters = {
  1: VersionedJsonImportV1(),
  2: VersionedJsonImportV2(),
  3: VersionedJsonImportV3(),
  4: VersionedJsonImportV4(),
  5: VersionedJsonImportV5(),
  6: VersionedJsonImportV6(),
  7: VersionedJsonImportV7(),
  8: VersionedJsonImportV8(),
  9: VersionedJsonImportV9(),
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
  void validate(DatabaseSnapshot data) => true;
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
  final List<GTRoutineFolder> folders;
  final List<TaggedFood> foods;
  final List<TaggedNutritionGoal> nutritionGoals;
  final Map<String, Food> customBarcodeFoods;
  final List<String> favoriteFoods;
  final Map<DateTime, List<NutritionCategory>> foodCategories;

  const DatabaseSnapshot({
    required this.customExercises,
    required this.routines,
    required this.routineExercises,
    required this.historyWorkouts,
    required this.historyWorkoutExercises,
    required this.preferences,
    required this.weightMeasurements,
    required this.folders,
    required this.foods,
    required this.nutritionGoals,
    required this.customBarcodeFoods,
    required this.favoriteFoods,
    required this.foodCategories,
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
  folders: ${jsonEncode(folders)},
  foods: ${jsonEncode(foods)},
  nutritionGoals: ${jsonEncode(nutritionGoals)},
  customBarcodeFoods: ${jsonEncode(customBarcodeFoods)},
  favoriteFoods: ${jsonEncode(favoriteFoods)},
  foodCategories: ${jsonEncode(foodCategories)},
)""";
  }
}
