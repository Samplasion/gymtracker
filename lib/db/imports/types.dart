import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/db/imports/v1.dart';
import 'package:gymtracker/db/imports/v2.dart';

const converters = {
  1: VersionedJsonImportV1(),
  2: VersionedJsonImportV2(),
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
  final List<GTLibraryExercise> customExercises;
  final List<GTRoutine> routines;
  final List<GTExerciseOrSuperset> routineExercises;
  final List<GTHistoryWorkout> historyWorkouts;
  final List<GTExerciseOrSuperset> historyWorkoutExercises;

  const DatabaseSnapshot({
    required this.customExercises,
    required this.routines,
    required this.routineExercises,
    required this.historyWorkouts,
    required this.historyWorkoutExercises,
  });
}
