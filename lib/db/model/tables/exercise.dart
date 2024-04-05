import 'package:drift/drift.dart';
import 'package:gymtracker/db/model/tables/set.dart';

enum GTMuscleCategory {
  arms,
  back,
  chest,
  core,
  legs,
  shoulders,
}

enum GTMuscleGroup {
  abductors(GTMuscleCategory.legs),
  abs(GTMuscleCategory.core),
  adductors(GTMuscleCategory.legs),
  biceps(GTMuscleCategory.arms),
  calves(GTMuscleCategory.legs),
  chest(GTMuscleCategory.chest),
  forearm(GTMuscleCategory.arms),
  glutes(GTMuscleCategory.legs),
  hamstrings(GTMuscleCategory.legs),
  lats(GTMuscleCategory.legs),
  lowerBack(GTMuscleCategory.back),

  /// Or cardio
  none,
  other,
  quadriceps(GTMuscleCategory.legs),
  shoulders(GTMuscleCategory.shoulders),
  traps(GTMuscleCategory.back),
  triceps(GTMuscleCategory.arms),
  upperBack(GTMuscleCategory.back);

  const GTMuscleGroup([this.category]);

  final GTMuscleCategory? category;
}

class CustomExercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get parameters => textEnum<GTSetParameters>()();
  TextColumn get primaryMuscleGroup => textEnum<GTMuscleGroup>()();
  TextColumn get secondaryMuscleGroups => text().map(
        const MuscleGroupSetConverter(),
      )();
}

class MuscleGroupSetConverter
    extends TypeConverter<Set<GTMuscleGroup>, String> {
  const MuscleGroupSetConverter();

  @override
  Set<GTMuscleGroup> fromSql(String fromDb) {
    if (fromDb.trim().isEmpty) return {};
    return fromDb
        .split(',')
        .map((e) =>
            GTMuscleGroup.values.firstWhere((element) => element.name == e))
        .toSet();
  }

  @override
  String toSql(Set<GTMuscleGroup> value) {
    return value.map((e) => e.name).join(',');
  }
}

abstract class LinkedExerciseBase extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get routineId;
  TextColumn get name => text()();
  TextColumn get parameters => textEnum<GTSetParameters>().nullable()();
  TextColumn get sets => text().nullable().map(const GTSetListConverter())();
  TextColumn get primaryMuscleGroup => textEnum<GTMuscleGroup>().nullable()();
  TextColumn get secondaryMuscleGroups => text().nullable().map(
        const MuscleGroupSetConverter(),
      )();
  IntColumn get restTime => integer().nullable()();
  BoolColumn get isCustom => boolean()();
  TextColumn get libraryExerciseId => text().nullable()();
  IntColumn get customExerciseId =>
      integer().nullable().references(CustomExercises, #id)();
  TextColumn get notes => text().nullable()();
  BoolColumn get isSuperset => boolean()();
  BoolColumn get isInSuperset => boolean()();
  IntColumn get supersetId;
  IntColumn get sortOrder => integer()();
}
