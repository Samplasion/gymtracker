import 'package:drift/drift.dart';
import 'package:gymtracker/db/model/tables/set.dart' show GTSetListConverter;
import 'package:gymtracker/model/exercise.dart' show GTMuscleGroup;
import 'package:gymtracker/model/set.dart';
import 'package:uuid/uuid.dart';

export 'package:gymtracker/model/exercise.dart'
    show GTMuscleGroup, GTMuscleCategory;

const _uuid = Uuid();

class CustomExercises extends Table {
  @override
  Set<Column<Object>> get primaryKey => {id};

  TextColumn get id => text().clientDefault(() => _uuid.v4())();
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
  @override
  Set<Column<Object>> get primaryKey => {id};

  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get routineId;
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
  TextColumn get customExerciseId =>
      text().nullable().references(CustomExercises, #id)();
  TextColumn get notes => text().nullable()();
  BoolColumn get isSuperset => boolean()();
  BoolColumn get isInSuperset => boolean()();
  TextColumn get supersetId;
  IntColumn get sortOrder => integer()();
}

class ConcreteExercise {
  final String id;
  final String routineId;
  final String name;
  final GTSetParameters? parameters;
  final List<GTSet>? sets;
  final GTMuscleGroup? primaryMuscleGroup;
  final Set<GTMuscleGroup>? secondaryMuscleGroups;
  final int? restTime;
  final bool isCustom;
  final String? libraryExerciseId;
  final String? customExerciseId;
  final String? notes;
  final bool isSuperset;
  final bool isInSuperset;
  final String? supersetId;
  final int sortOrder;

  const ConcreteExercise({
    required this.id,
    required this.routineId,
    required this.name,
    required this.parameters,
    required this.sets,
    required this.primaryMuscleGroup,
    required this.secondaryMuscleGroups,
    required this.restTime,
    required this.isCustom,
    required this.libraryExerciseId,
    required this.customExerciseId,
    required this.notes,
    required this.isSuperset,
    required this.isInSuperset,
    required this.supersetId,
    required this.sortOrder,
  })  : assert(
            isSuperset
                ? true
                : isCustom
                    ? customExerciseId != null
                    : libraryExerciseId != null,
            "Concrete exercises must have a parent ID (ID: $id, customExerciseId: $customExerciseId, libraryExerciseId: $libraryExerciseId)"),
        assert(isInSuperset ? supersetId != null : true,
            "If isInSuperset is true, supersetId must be set (ID: $id)");
}
