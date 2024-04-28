import 'package:drift/internal/versioned_schema.dart' as i0;
import 'package:drift/drift.dart' as i1;
import 'package:drift/drift.dart'; // ignore_for_file: type=lint,unused_import

// GENERATED BY drift_dev, DO NOT MODIFY.
final class Schema3 extends i0.VersionedSchema {
  Schema3({required super.database}) : super(version: 3);
  @override
  late final List<i1.DatabaseSchemaEntity> entities = [
    customExercises,
    routines,
    historyWorkouts,
    historyWorkoutExercises,
    routineExercises,
    preferences,
    ongoingData,
    weightMeasurements,
  ];
  late final Shape0 customExercises = Shape0(
      source: i0.VersionedTable(
        entityName: 'custom_exercises',
        withoutRowId: false,
        isStrict: false,
        tableConstraints: [
          'PRIMARY KEY(id)',
        ],
        columns: [
          _column_0,
          _column_1,
          _column_2,
          _column_3,
          _column_4,
        ],
        attachedDatabase: database,
      ),
      alias: null);
  late final Shape1 routines = Shape1(
      source: i0.VersionedTable(
        entityName: 'routines',
        withoutRowId: false,
        isStrict: false,
        tableConstraints: [
          'PRIMARY KEY(id)',
        ],
        columns: [
          _column_0,
          _column_1,
          _column_5,
          _column_6,
          _column_7,
          _column_8,
        ],
        attachedDatabase: database,
      ),
      alias: null);
  late final Shape2 historyWorkouts = Shape2(
      source: i0.VersionedTable(
        entityName: 'history_workouts',
        withoutRowId: false,
        isStrict: false,
        tableConstraints: [
          'PRIMARY KEY(id)',
          'UNIQUE(completed_by, completes)',
        ],
        columns: [
          _column_0,
          _column_1,
          _column_9,
          _column_10,
          _column_11,
          _column_12,
          _column_13,
          _column_14,
          _column_6,
          _column_7,
        ],
        attachedDatabase: database,
      ),
      alias: null);
  late final Shape3 historyWorkoutExercises = Shape3(
      source: i0.VersionedTable(
        entityName: 'history_workout_exercises',
        withoutRowId: false,
        isStrict: false,
        tableConstraints: [
          'PRIMARY KEY(id)',
        ],
        columns: [
          _column_0,
          _column_15,
          _column_1,
          _column_16,
          _column_17,
          _column_18,
          _column_19,
          _column_20,
          _column_21,
          _column_22,
          _column_23,
          _column_24,
          _column_25,
          _column_26,
          _column_27,
          _column_8,
          _column_28,
        ],
        attachedDatabase: database,
      ),
      alias: null);
  late final Shape3 routineExercises = Shape3(
      source: i0.VersionedTable(
        entityName: 'routine_exercises',
        withoutRowId: false,
        isStrict: false,
        tableConstraints: [
          'PRIMARY KEY(id)',
        ],
        columns: [
          _column_0,
          _column_29,
          _column_1,
          _column_16,
          _column_17,
          _column_18,
          _column_19,
          _column_20,
          _column_21,
          _column_22,
          _column_23,
          _column_24,
          _column_25,
          _column_26,
          _column_30,
          _column_8,
          _column_31,
        ],
        attachedDatabase: database,
      ),
      alias: null);
  late final Shape4 preferences = Shape4(
      source: i0.VersionedTable(
        entityName: 'preferences',
        withoutRowId: false,
        isStrict: false,
        tableConstraints: [],
        columns: [
          _column_32,
        ],
        attachedDatabase: database,
      ),
      alias: null);
  late final Shape4 ongoingData = Shape4(
      source: i0.VersionedTable(
        entityName: 'ongoing_data',
        withoutRowId: false,
        isStrict: false,
        tableConstraints: [],
        columns: [
          _column_32,
        ],
        attachedDatabase: database,
      ),
      alias: null);
  late final Shape5 weightMeasurements = Shape5(
      source: i0.VersionedTable(
        entityName: 'weight_measurements',
        withoutRowId: false,
        isStrict: false,
        tableConstraints: [
          'PRIMARY KEY(id)',
        ],
        columns: [
          _column_0,
          _column_33,
          _column_34,
          _column_6,
        ],
        attachedDatabase: database,
      ),
      alias: null);
}

class Shape0 extends i0.VersionedTable {
  Shape0({required super.source, required super.alias}) : super.aliased();
  i1.GeneratedColumn<String> get id =>
      columnsByName['id']! as i1.GeneratedColumn<String>;
  i1.GeneratedColumn<String> get name =>
      columnsByName['name']! as i1.GeneratedColumn<String>;
  i1.GeneratedColumn<String> get parameters =>
      columnsByName['parameters']! as i1.GeneratedColumn<String>;
  i1.GeneratedColumn<String> get primaryMuscleGroup =>
      columnsByName['primary_muscle_group']! as i1.GeneratedColumn<String>;
  i1.GeneratedColumn<String> get secondaryMuscleGroups =>
      columnsByName['secondary_muscle_groups']! as i1.GeneratedColumn<String>;
}

i1.GeneratedColumn<String> _column_0(String aliasedName) =>
    i1.GeneratedColumn<String>('id', aliasedName, false,
        type: i1.DriftSqlType.string);
i1.GeneratedColumn<String> _column_1(String aliasedName) =>
    i1.GeneratedColumn<String>('name', aliasedName, false,
        type: i1.DriftSqlType.string);
i1.GeneratedColumn<String> _column_2(String aliasedName) =>
    i1.GeneratedColumn<String>('parameters', aliasedName, false,
        type: i1.DriftSqlType.string);
i1.GeneratedColumn<String> _column_3(String aliasedName) =>
    i1.GeneratedColumn<String>('primary_muscle_group', aliasedName, false,
        type: i1.DriftSqlType.string);
i1.GeneratedColumn<String> _column_4(String aliasedName) =>
    i1.GeneratedColumn<String>('secondary_muscle_groups', aliasedName, false,
        type: i1.DriftSqlType.string);

class Shape1 extends i0.VersionedTable {
  Shape1({required super.source, required super.alias}) : super.aliased();
  i1.GeneratedColumn<String> get id =>
      columnsByName['id']! as i1.GeneratedColumn<String>;
  i1.GeneratedColumn<String> get name =>
      columnsByName['name']! as i1.GeneratedColumn<String>;
  i1.GeneratedColumn<String> get infobox =>
      columnsByName['infobox']! as i1.GeneratedColumn<String>;
  i1.GeneratedColumn<String> get weightUnit =>
      columnsByName['weight_unit']! as i1.GeneratedColumn<String>;
  i1.GeneratedColumn<String> get distanceUnit =>
      columnsByName['distance_unit']! as i1.GeneratedColumn<String>;
  i1.GeneratedColumn<int> get sortOrder =>
      columnsByName['sort_order']! as i1.GeneratedColumn<int>;
}

i1.GeneratedColumn<String> _column_5(String aliasedName) =>
    i1.GeneratedColumn<String>('infobox', aliasedName, false,
        type: i1.DriftSqlType.string);
i1.GeneratedColumn<String> _column_6(String aliasedName) =>
    i1.GeneratedColumn<String>('weight_unit', aliasedName, false,
        type: i1.DriftSqlType.string);
i1.GeneratedColumn<String> _column_7(String aliasedName) =>
    i1.GeneratedColumn<String>('distance_unit', aliasedName, false,
        type: i1.DriftSqlType.string);
i1.GeneratedColumn<int> _column_8(String aliasedName) =>
    i1.GeneratedColumn<int>('sort_order', aliasedName, false,
        type: i1.DriftSqlType.int);

class Shape2 extends i0.VersionedTable {
  Shape2({required super.source, required super.alias}) : super.aliased();
  i1.GeneratedColumn<String> get id =>
      columnsByName['id']! as i1.GeneratedColumn<String>;
  i1.GeneratedColumn<String> get name =>
      columnsByName['name']! as i1.GeneratedColumn<String>;
  i1.GeneratedColumn<String> get infobox =>
      columnsByName['infobox']! as i1.GeneratedColumn<String>;
  i1.GeneratedColumn<int> get duration =>
      columnsByName['duration']! as i1.GeneratedColumn<int>;
  i1.GeneratedColumn<DateTime> get startingDate =>
      columnsByName['starting_date']! as i1.GeneratedColumn<DateTime>;
  i1.GeneratedColumn<String> get parentId =>
      columnsByName['parent_id']! as i1.GeneratedColumn<String>;
  i1.GeneratedColumn<String> get completedBy =>
      columnsByName['completed_by']! as i1.GeneratedColumn<String>;
  i1.GeneratedColumn<String> get completes =>
      columnsByName['completes']! as i1.GeneratedColumn<String>;
  i1.GeneratedColumn<String> get weightUnit =>
      columnsByName['weight_unit']! as i1.GeneratedColumn<String>;
  i1.GeneratedColumn<String> get distanceUnit =>
      columnsByName['distance_unit']! as i1.GeneratedColumn<String>;
}

i1.GeneratedColumn<String> _column_9(String aliasedName) =>
    i1.GeneratedColumn<String>('infobox', aliasedName, true,
        type: i1.DriftSqlType.string);
i1.GeneratedColumn<int> _column_10(String aliasedName) =>
    i1.GeneratedColumn<int>('duration', aliasedName, false,
        type: i1.DriftSqlType.int);
i1.GeneratedColumn<DateTime> _column_11(String aliasedName) =>
    i1.GeneratedColumn<DateTime>('starting_date', aliasedName, false,
        type: i1.DriftSqlType.dateTime);
i1.GeneratedColumn<String> _column_12(String aliasedName) =>
    i1.GeneratedColumn<String>('parent_id', aliasedName, true,
        type: i1.DriftSqlType.string,
        defaultConstraints:
            i1.GeneratedColumn.constraintIsAlways('REFERENCES routines (id)'));
i1.GeneratedColumn<String> _column_13(String aliasedName) =>
    i1.GeneratedColumn<String>('completed_by', aliasedName, true,
        type: i1.DriftSqlType.string,
        defaultConstraints: i1.GeneratedColumn.constraintIsAlways(
            'REFERENCES history_workouts (id)'));
i1.GeneratedColumn<String> _column_14(String aliasedName) =>
    i1.GeneratedColumn<String>('completes', aliasedName, true,
        type: i1.DriftSqlType.string,
        defaultConstraints: i1.GeneratedColumn.constraintIsAlways(
            'REFERENCES history_workouts (id)'));

class Shape3 extends i0.VersionedTable {
  Shape3({required super.source, required super.alias}) : super.aliased();
  i1.GeneratedColumn<String> get id =>
      columnsByName['id']! as i1.GeneratedColumn<String>;
  i1.GeneratedColumn<String> get routineId =>
      columnsByName['routine_id']! as i1.GeneratedColumn<String>;
  i1.GeneratedColumn<String> get name =>
      columnsByName['name']! as i1.GeneratedColumn<String>;
  i1.GeneratedColumn<String> get parameters =>
      columnsByName['parameters']! as i1.GeneratedColumn<String>;
  i1.GeneratedColumn<String> get sets =>
      columnsByName['sets']! as i1.GeneratedColumn<String>;
  i1.GeneratedColumn<String> get primaryMuscleGroup =>
      columnsByName['primary_muscle_group']! as i1.GeneratedColumn<String>;
  i1.GeneratedColumn<String> get secondaryMuscleGroups =>
      columnsByName['secondary_muscle_groups']! as i1.GeneratedColumn<String>;
  i1.GeneratedColumn<int> get restTime =>
      columnsByName['rest_time']! as i1.GeneratedColumn<int>;
  i1.GeneratedColumn<bool> get isCustom =>
      columnsByName['is_custom']! as i1.GeneratedColumn<bool>;
  i1.GeneratedColumn<String> get libraryExerciseId =>
      columnsByName['library_exercise_id']! as i1.GeneratedColumn<String>;
  i1.GeneratedColumn<String> get customExerciseId =>
      columnsByName['custom_exercise_id']! as i1.GeneratedColumn<String>;
  i1.GeneratedColumn<String> get notes =>
      columnsByName['notes']! as i1.GeneratedColumn<String>;
  i1.GeneratedColumn<bool> get isSuperset =>
      columnsByName['is_superset']! as i1.GeneratedColumn<bool>;
  i1.GeneratedColumn<bool> get isInSuperset =>
      columnsByName['is_in_superset']! as i1.GeneratedColumn<bool>;
  i1.GeneratedColumn<String> get supersetId =>
      columnsByName['superset_id']! as i1.GeneratedColumn<String>;
  i1.GeneratedColumn<int> get sortOrder =>
      columnsByName['sort_order']! as i1.GeneratedColumn<int>;
  i1.GeneratedColumn<String> get supersedesId =>
      columnsByName['supersedes_id']! as i1.GeneratedColumn<String>;
}

i1.GeneratedColumn<String> _column_15(String aliasedName) =>
    i1.GeneratedColumn<String>('routine_id', aliasedName, false,
        type: i1.DriftSqlType.string,
        defaultConstraints: i1.GeneratedColumn.constraintIsAlways(
            'REFERENCES history_workouts (id)'));
i1.GeneratedColumn<String> _column_16(String aliasedName) =>
    i1.GeneratedColumn<String>('parameters', aliasedName, true,
        type: i1.DriftSqlType.string);
i1.GeneratedColumn<String> _column_17(String aliasedName) =>
    i1.GeneratedColumn<String>('sets', aliasedName, true,
        type: i1.DriftSqlType.string);
i1.GeneratedColumn<String> _column_18(String aliasedName) =>
    i1.GeneratedColumn<String>('primary_muscle_group', aliasedName, true,
        type: i1.DriftSqlType.string);
i1.GeneratedColumn<String> _column_19(String aliasedName) =>
    i1.GeneratedColumn<String>('secondary_muscle_groups', aliasedName, true,
        type: i1.DriftSqlType.string);
i1.GeneratedColumn<int> _column_20(String aliasedName) =>
    i1.GeneratedColumn<int>('rest_time', aliasedName, true,
        type: i1.DriftSqlType.int);
i1.GeneratedColumn<bool> _column_21(String aliasedName) =>
    i1.GeneratedColumn<bool>('is_custom', aliasedName, false,
        type: i1.DriftSqlType.bool,
        defaultConstraints: i1.GeneratedColumn.constraintIsAlways(
            'CHECK ("is_custom" IN (0, 1))'));
i1.GeneratedColumn<String> _column_22(String aliasedName) =>
    i1.GeneratedColumn<String>('library_exercise_id', aliasedName, true,
        type: i1.DriftSqlType.string);
i1.GeneratedColumn<String> _column_23(String aliasedName) =>
    i1.GeneratedColumn<String>('custom_exercise_id', aliasedName, true,
        type: i1.DriftSqlType.string,
        defaultConstraints: i1.GeneratedColumn.constraintIsAlways(
            'REFERENCES custom_exercises (id)'));
i1.GeneratedColumn<String> _column_24(String aliasedName) =>
    i1.GeneratedColumn<String>('notes', aliasedName, true,
        type: i1.DriftSqlType.string);
i1.GeneratedColumn<bool> _column_25(String aliasedName) =>
    i1.GeneratedColumn<bool>('is_superset', aliasedName, false,
        type: i1.DriftSqlType.bool,
        defaultConstraints: i1.GeneratedColumn.constraintIsAlways(
            'CHECK ("is_superset" IN (0, 1))'));
i1.GeneratedColumn<bool> _column_26(String aliasedName) =>
    i1.GeneratedColumn<bool>('is_in_superset', aliasedName, false,
        type: i1.DriftSqlType.bool,
        defaultConstraints: i1.GeneratedColumn.constraintIsAlways(
            'CHECK ("is_in_superset" IN (0, 1))'));
i1.GeneratedColumn<String> _column_27(String aliasedName) =>
    i1.GeneratedColumn<String>('superset_id', aliasedName, true,
        type: i1.DriftSqlType.string,
        defaultConstraints: i1.GeneratedColumn.constraintIsAlways(
            'REFERENCES history_workout_exercises (id)'));
i1.GeneratedColumn<String> _column_28(String aliasedName) =>
    i1.GeneratedColumn<String>('supersedes_id', aliasedName, true,
        type: i1.DriftSqlType.string,
        defaultConstraints: i1.GeneratedColumn.constraintIsAlways(
            'REFERENCES history_workout_exercises (id)'));
i1.GeneratedColumn<String> _column_29(String aliasedName) =>
    i1.GeneratedColumn<String>('routine_id', aliasedName, false,
        type: i1.DriftSqlType.string,
        defaultConstraints:
            i1.GeneratedColumn.constraintIsAlways('REFERENCES routines (id)'));
i1.GeneratedColumn<String> _column_30(String aliasedName) =>
    i1.GeneratedColumn<String>('superset_id', aliasedName, true,
        type: i1.DriftSqlType.string,
        defaultConstraints: i1.GeneratedColumn.constraintIsAlways(
            'REFERENCES routine_exercises (id)'));
i1.GeneratedColumn<String> _column_31(String aliasedName) =>
    i1.GeneratedColumn<String>('supersedes_id', aliasedName, true,
        type: i1.DriftSqlType.string,
        defaultConstraints: i1.GeneratedColumn.constraintIsAlways(
            'REFERENCES routine_exercises (id)'));

class Shape4 extends i0.VersionedTable {
  Shape4({required super.source, required super.alias}) : super.aliased();
  i1.GeneratedColumn<String> get data =>
      columnsByName['data']! as i1.GeneratedColumn<String>;
}

i1.GeneratedColumn<String> _column_32(String aliasedName) =>
    i1.GeneratedColumn<String>('data', aliasedName, false,
        type: i1.DriftSqlType.string);

class Shape5 extends i0.VersionedTable {
  Shape5({required super.source, required super.alias}) : super.aliased();
  i1.GeneratedColumn<String> get id =>
      columnsByName['id']! as i1.GeneratedColumn<String>;
  i1.GeneratedColumn<double> get weight =>
      columnsByName['weight']! as i1.GeneratedColumn<double>;
  i1.GeneratedColumn<DateTime> get time =>
      columnsByName['time']! as i1.GeneratedColumn<DateTime>;
  i1.GeneratedColumn<String> get weightUnit =>
      columnsByName['weight_unit']! as i1.GeneratedColumn<String>;
}

i1.GeneratedColumn<double> _column_33(String aliasedName) =>
    i1.GeneratedColumn<double>('weight', aliasedName, false,
        type: i1.DriftSqlType.double);
i1.GeneratedColumn<DateTime> _column_34(String aliasedName) =>
    i1.GeneratedColumn<DateTime>('time', aliasedName, false,
        type: i1.DriftSqlType.dateTime);
i0.MigrationStepWithVersion migrationSteps({
  required Future<void> Function(i1.Migrator m, Schema3 schema) from2To3,
}) {
  return (currentVersion, database) async {
    switch (currentVersion) {
      case 2:
        final schema = Schema3(database: database);
        final migrator = i1.Migrator(database, schema);
        await from2To3(migrator, schema);
        return 3;
      default:
        throw ArgumentError.value('Unknown migration from $currentVersion');
    }
  };
}

i1.OnUpgrade stepByStep({
  required Future<void> Function(i1.Migrator m, Schema3 schema) from2To3,
}) =>
    i0.VersionedSchema.stepByStepHelper(
        step: migrationSteps(
      from2To3: from2To3,
    ));