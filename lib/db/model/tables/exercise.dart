import 'package:drift/drift.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/db/model/tables/set.dart' show GTSetListConverter;
import 'package:gymtracker/model/exercise.dart'
    show GTGymEquipment, GTMuscleGroup;
import 'package:gymtracker/model/set.dart';
import 'package:syncable/syncable.dart';
import 'package:uuid/uuid.dart';

export 'package:gymtracker/model/exercise.dart'
    show GTMuscleGroup, GTMuscleCategory;

const _uuid = Uuid();

@UseRowClass(CustomExercise)
class CustomExercises extends Table implements SyncableTable {
  @override
  Set<Column<Object>> get primaryKey => {id, userId};

  @override
  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get name => text()();
  TextColumn get parameters => textEnum<GTSetParameters>()();
  TextColumn get primaryMuscleGroup => textEnum<GTMuscleGroup>()();
  TextColumn get secondaryMuscleGroups =>
      text().map(const MuscleGroupSetConverter())();
  TextColumn get equipment => textEnum<GTGymEquipment>()
      .nullable()
      .clientDefault(() => GTGymEquipment.none.name)();
  @override
  DateTimeColumn get updatedAt => dateTime().withDefault(
    Constant(DateTime.fromMicrosecondsSinceEpoch(0, isUtc: true)),
  )();
  @override
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  @override
  TextColumn get userId => text().nullable()();
}

final class CustomExercise implements Syncable {
  @override
  final String id;
  final String name;
  final GTSetParameters parameters;
  final GTMuscleGroup primaryMuscleGroup;
  final Set<GTMuscleGroup> secondaryMuscleGroups;
  final GTGymEquipment equipment;
  @override
  final DateTime updatedAt;
  @override
  final bool deleted;
  @override
  final String? userId;

  CustomExercise({
    required this.id,
    required this.name,
    required this.parameters,
    required this.primaryMuscleGroup,
    required this.secondaryMuscleGroups,
    GTGymEquipment? equipment,
    DateTime? updatedAt,
    bool? deleted,
    this.userId,
  }) : equipment = equipment ?? GTGymEquipment.none,
       updatedAt = updatedAt ?? DateTime.now().toUtc(),
       deleted = deleted ?? false;

  factory CustomExercise.fromJson(Map<String, dynamic> json) {
    Set<GTMuscleGroup> parseSecondary(dynamic val) {
      if (val == null) return {};
      if (val is List) {
        return val
            .map((e) => GTMuscleGroup.values.byName(e.toString()))
            .toSet();
      }
      if (val is String && val.trim().isNotEmpty) {
        return val
            .split(',')
            .map((e) => GTMuscleGroup.values.byName(e))
            .toSet();
      }
      return {};
    }

    return CustomExercise(
      id: json['id'] as String? ?? _uuid.v4(),
      name: json['name'] as String,
      parameters: GTSetParameters.values.byName(json['parameters'] as String),
      primaryMuscleGroup: GTMuscleGroup.values.byName(
        json['primary_muscle_group'] as String? ??
            json['primaryMuscleGroup'] as String,
      ),
      secondaryMuscleGroups: parseSecondary(
        json['secondary_muscle_groups'] ?? json['secondaryMuscleGroups'],
      ),
      equipment: json['equipment'] != null
          ? GTGymEquipment.values.byName(json['equipment'] as String)
          : GTGymEquipment.none,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      deleted: json['deleted'] as bool? ?? false,
      userId: json['user_id'] as String? ?? json['userId'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'parameters': parameters.name,
    'primary_muscle_group': primaryMuscleGroup.name,
    'secondary_muscle_groups': secondaryMuscleGroups
        .map((e) => e.name)
        .toList(),
    'equipment': equipment.name,
    'updated_at': updatedAt.toUtc().toIso8601String(),
    'deleted': deleted,
    'user_id': userId,
  };

  @override
  UpdateCompanion<Syncable> toCompanion() {
    return CustomExercisesCompanion.insert(
      id: Value(id),
      name: name,
      parameters: parameters,
      primaryMuscleGroup: primaryMuscleGroup,
      secondaryMuscleGroups: secondaryMuscleGroups,
      equipment: Value(equipment),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      userId: Value(userId),
    );
  }
}

// @UseRowClass(ConcreteExercise)
abstract class LinkedExerciseBase extends Table implements SyncableTable {
  @override
  Set<Column<Object>> get primaryKey => {id, userId};

  @override
  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get routineId;
  TextColumn get name => text()();
  TextColumn get parameters => textEnum<GTSetParameters>().nullable()();
  TextColumn get sets => text().nullable().map(const GTSetListConverter())();
  TextColumn get primaryMuscleGroup => textEnum<GTMuscleGroup>().nullable()();
  TextColumn get secondaryMuscleGroups =>
      text().nullable().map(const MuscleGroupSetConverter())();
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
  TextColumn get supersedesId;
  IntColumn get rpe => integer().nullable()();
  TextColumn get equipment => textEnum<GTGymEquipment>()
      .nullable()
      .clientDefault(() => GTGymEquipment.none.name)();
  @override
  DateTimeColumn get updatedAt => dateTime().withDefault(
    Constant(DateTime.fromMicrosecondsSinceEpoch(0, isUtc: true)),
  )();
  @override
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  @override
  TextColumn get userId => text().nullable()();
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
  final String? supersedesId;
  final int? rpe;
  final GTGymEquipment equipment;
  final DateTime updatedAt;
  final bool deleted;
  final String? userId;

  ConcreteExercise({
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
    required this.supersedesId,
    required this.rpe,
    required GTGymEquipment? equipment,
    DateTime? updatedAt,
    bool? deleted,
    this.userId,
  }) : equipment = equipment ?? GTGymEquipment.none,
       updatedAt = updatedAt ?? DateTime.now().toUtc(),
       deleted = deleted ?? false,
       assert(
         isSuperset
             ? true
             : isCustom
             ? customExerciseId != null
             : libraryExerciseId != null,
         "Concrete exercises must have a parent ID (ID: $id, customExerciseId: $customExerciseId, libraryExerciseId: $libraryExerciseId)",
       ),
       assert(
         isInSuperset ? supersetId != null : true,
         "If isInSuperset is true, supersetId must be set (ID: $id)",
       );
}

class RoutineExercise extends ConcreteExercise implements Syncable {
  RoutineExercise({
    required super.id,
    required super.routineId,
    required super.name,
    required super.parameters,
    required super.sets,
    required super.primaryMuscleGroup,
    required super.secondaryMuscleGroups,
    required super.restTime,
    required super.isCustom,
    required super.libraryExerciseId,
    required super.customExerciseId,
    required super.notes,
    required super.isSuperset,
    required super.isInSuperset,
    required super.supersetId,
    required super.sortOrder,
    required super.supersedesId,
    required super.rpe,
    required super.equipment,
    super.updatedAt,
    super.deleted,
    super.userId,
  });

  factory RoutineExercise.fromJson(Map<String, dynamic> json) {
    Set<GTMuscleGroup>? parseSecondary(dynamic val) {
      if (val == null) return null;
      if (val is List) {
        return val
            .map((e) => GTMuscleGroup.values.byName(e.toString()))
            .toSet();
      }
      if (val is String && val.trim().isNotEmpty) {
        return val
            .split(',')
            .map((e) => GTMuscleGroup.values.byName(e))
            .toSet();
      }
      return {};
    }

    return RoutineExercise(
      id: json['id'] as String? ?? _uuid.v4(),
      routineId: json['routine_id'] as String? ?? json['routineId'] as String,
      name: json['name'] as String,
      parameters: json['parameters'] != null
          ? GTSetParameters.values.byName(json['parameters'] as String)
          : null,
      sets: (json['sets'] as List?)
          ?.map((e) => GTSet.fromJson(e as Map<String, dynamic>))
          .toList(),
      primaryMuscleGroup:
          json['primary_muscle_group'] != null ||
              json['primaryMuscleGroup'] != null
          ? GTMuscleGroup.values.byName(
              json['primary_muscle_group'] as String? ??
                  json['primaryMuscleGroup'] as String,
            )
          : null,
      secondaryMuscleGroups: parseSecondary(
        json['secondary_muscle_groups'] ?? json['secondaryMuscleGroups'],
      ),
      restTime: json['rest_time'] as int? ?? json['restTime'] as int?,
      isCustom:
          json['is_custom'] as bool? ?? json['isCustom'] as bool? ?? false,
      libraryExerciseId:
          json['library_exercise_id'] as String? ??
          json['libraryExerciseId'] as String?,
      customExerciseId:
          json['custom_exercise_id'] as String? ??
          json['customExerciseId'] as String?,
      notes: json['notes'] as String?,
      isSuperset:
          json['is_superset'] as bool? ?? json['isSuperset'] as bool? ?? false,
      isInSuperset:
          json['is_in_superset'] as bool? ??
          json['isInSuperset'] as bool? ??
          false,
      supersetId:
          json['superset_id'] as String? ?? json['supersetId'] as String?,
      sortOrder: json['sort_order'] as int? ?? json['sortOrder'] as int? ?? 0,
      supersedesId:
          json['supersedes_id'] as String? ?? json['supersedesId'] as String?,
      rpe: json['rpe'] as int?,
      equipment: json['equipment'] != null
          ? GTGymEquipment.values.byName(json['equipment'] as String)
          : GTGymEquipment.none,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      deleted: json['deleted'] as bool? ?? false,
      userId: json['user_id'] as String? ?? json['userId'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'routine_id': routineId,
    'name': name,
    'parameters': parameters?.name,
    'sets': sets?.map((e) => e.toJson()).toList(),
    'primary_muscle_group': primaryMuscleGroup?.name,
    'secondary_muscle_groups': secondaryMuscleGroups
        ?.map((e) => e.name)
        .toList(),
    'rest_time': restTime,
    'is_custom': isCustom,
    'library_exercise_id': libraryExerciseId,
    'custom_exercise_id': customExerciseId,
    'notes': notes,
    'is_superset': isSuperset,
    'is_in_superset': isInSuperset,
    'superset_id': supersetId,
    'sort_order': sortOrder,
    'supersedes_id': supersedesId,
    'rpe': rpe,
    'equipment': equipment.name,
    'updated_at': updatedAt.toUtc().toIso8601String(),
    'deleted': deleted,
    'user_id': userId,
  };

  @override
  UpdateCompanion<Syncable> toCompanion() {
    return RoutineExercisesCompanion.insert(
      id: Value(id),
      routineId: routineId,
      name: name,
      parameters: Value(parameters),
      sets: Value(sets),
      primaryMuscleGroup: Value(primaryMuscleGroup),
      secondaryMuscleGroups: Value(secondaryMuscleGroups),
      restTime: Value(restTime),
      isCustom: isCustom,
      libraryExerciseId: Value(libraryExerciseId),
      customExerciseId: Value(customExerciseId),
      notes: Value(notes),
      isSuperset: isSuperset,
      isInSuperset: isInSuperset,
      supersetId: Value(supersetId),
      sortOrder: sortOrder,
      supersedesId: Value(supersedesId),
      rpe: Value(rpe),
      equipment: Value(equipment),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      userId: Value(userId),
    );
  }
}

class HistoryWorkoutExercise extends ConcreteExercise implements Syncable {
  HistoryWorkoutExercise({
    required super.id,
    required super.routineId,
    required super.name,
    required super.parameters,
    required super.sets,
    required super.primaryMuscleGroup,
    required super.secondaryMuscleGroups,
    required super.restTime,
    required super.isCustom,
    required super.libraryExerciseId,
    required super.customExerciseId,
    required super.notes,
    required super.isSuperset,
    required super.isInSuperset,
    required super.supersetId,
    required super.sortOrder,
    required super.supersedesId,
    required super.rpe,
    required super.equipment,
    super.updatedAt,
    super.deleted,
    super.userId,
  });

  factory HistoryWorkoutExercise.fromJson(Map<String, dynamic> json) {
    Set<GTMuscleGroup>? parseSecondary(dynamic val) {
      if (val == null) return null;
      if (val is List) {
        return val
            .map((e) => GTMuscleGroup.values.byName(e.toString()))
            .toSet();
      }
      if (val is String && val.trim().isNotEmpty) {
        return val
            .split(',')
            .map((e) => GTMuscleGroup.values.byName(e))
            .toSet();
      }
      return {};
    }

    return HistoryWorkoutExercise(
      id: json['id'] as String? ?? _uuid.v4(),
      routineId: json['routine_id'] as String? ?? json['routineId'] as String,
      name: json['name'] as String,
      parameters: json['parameters'] != null
          ? GTSetParameters.values.byName(json['parameters'] as String)
          : null,
      sets: (json['sets'] as List?)
          ?.map((e) => GTSet.fromJson(e as Map<String, dynamic>))
          .toList(),
      primaryMuscleGroup:
          json['primary_muscle_group'] != null ||
              json['primaryMuscleGroup'] != null
          ? GTMuscleGroup.values.byName(
              json['primary_muscle_group'] as String? ??
                  json['primaryMuscleGroup'] as String,
            )
          : null,
      secondaryMuscleGroups: parseSecondary(
        json['secondary_muscle_groups'] ?? json['secondaryMuscleGroups'],
      ),
      restTime: json['rest_time'] as int? ?? json['restTime'] as int?,
      isCustom:
          json['is_custom'] as bool? ?? json['isCustom'] as bool? ?? false,
      libraryExerciseId:
          json['library_exercise_id'] as String? ??
          json['libraryExerciseId'] as String?,
      customExerciseId:
          json['custom_exercise_id'] as String? ??
          json['customExerciseId'] as String?,
      notes: json['notes'] as String?,
      isSuperset:
          json['is_superset'] as bool? ?? json['isSuperset'] as bool? ?? false,
      isInSuperset:
          json['is_in_superset'] as bool? ??
          json['isInSuperset'] as bool? ??
          false,
      supersetId:
          json['superset_id'] as String? ?? json['supersetId'] as String?,
      sortOrder: json['sort_order'] as int? ?? json['sortOrder'] as int? ?? 0,
      supersedesId:
          json['supersedes_id'] as String? ?? json['supersedesId'] as String?,
      rpe: json['rpe'] as int?,
      equipment: json['equipment'] != null
          ? GTGymEquipment.values.byName(json['equipment'] as String)
          : GTGymEquipment.none,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      deleted: json['deleted'] as bool? ?? false,
      userId: json['user_id'] as String? ?? json['userId'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'routine_id': routineId,
    'name': name,
    'parameters': parameters?.name,
    'sets': sets?.map((e) => e.toJson()).toList(),
    'primary_muscle_group': primaryMuscleGroup?.name,
    'secondary_muscle_groups': secondaryMuscleGroups
        ?.map((e) => e.name)
        .toList(),
    'rest_time': restTime,
    'is_custom': isCustom,
    'library_exercise_id': libraryExerciseId,
    'custom_exercise_id': customExerciseId,
    'notes': notes,
    'is_superset': isSuperset,
    'is_in_superset': isInSuperset,
    'superset_id': supersetId,
    'sort_order': sortOrder,
    'supersedes_id': supersedesId,
    'rpe': rpe,
    'equipment': equipment.name,
    'updated_at': updatedAt.toUtc().toIso8601String(),
    'deleted': deleted,
    'user_id': userId,
  };

  @override
  UpdateCompanion<Syncable> toCompanion() {
    return HistoryWorkoutExercisesCompanion.insert(
      id: Value(id),
      routineId: routineId,
      name: name,
      parameters: Value(parameters),
      sets: Value(sets),
      primaryMuscleGroup: Value(primaryMuscleGroup),
      secondaryMuscleGroups: Value(secondaryMuscleGroups),
      restTime: Value(restTime),
      isCustom: isCustom,
      libraryExerciseId: Value(libraryExerciseId),
      customExerciseId: Value(customExerciseId),
      notes: Value(notes),
      isSuperset: isSuperset,
      isInSuperset: isInSuperset,
      supersetId: Value(supersetId),
      sortOrder: sortOrder,
      supersedesId: Value(supersedesId),
      rpe: Value(rpe),
      equipment: Value(equipment),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      userId: Value(userId),
    );
  }
}

class MuscleGroupSetConverter
    extends TypeConverter<Set<GTMuscleGroup>, String> {
  const MuscleGroupSetConverter();

  @override
  Set<GTMuscleGroup> fromSql(String fromDb) {
    if (fromDb.trim().isEmpty) return {};
    return fromDb
        .split(',')
        .map(
          (e) =>
              GTMuscleGroup.values.firstWhere((element) => element.name == e),
        )
        .toSet();
  }

  @override
  String toSql(Set<GTMuscleGroup> value) {
    return value.map((e) => e.name).join(',');
  }
}
