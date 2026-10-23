// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $CustomExercisesTable extends CustomExercises
    with TableInfo<$CustomExercisesTable, CustomExercise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: Constant(DateTime.fromMicrosecondsSinceEpoch(0, isUtc: true)),
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<GTSetParameters, String>
  parameters = GeneratedColumn<String>(
    'parameters',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<GTSetParameters>($CustomExercisesTable.$converterparameters);
  @override
  late final GeneratedColumnWithTypeConverter<GTMuscleGroup, String>
  primaryMuscleGroup =
      GeneratedColumn<String>(
        'primary_muscle_group',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<GTMuscleGroup>(
        $CustomExercisesTable.$converterprimaryMuscleGroup,
      );
  @override
  late final GeneratedColumnWithTypeConverter<Set<GTMuscleGroup>, String>
  secondaryMuscleGroups =
      GeneratedColumn<String>(
        'secondary_muscle_groups',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Set<GTMuscleGroup>>(
        $CustomExercisesTable.$convertersecondaryMuscleGroups,
      );
  @override
  late final GeneratedColumnWithTypeConverter<GTGymEquipment?, String>
  equipment = GeneratedColumn<String>(
    'equipment',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => GTGymEquipment.none.name,
  ).withConverter<GTGymEquipment?>($CustomExercisesTable.$converterequipmentn);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    updatedAt,
    deleted,
    name,
    parameters,
    primaryMuscleGroup,
    secondaryMuscleGroups,
    equipment,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_exercises';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomExercise> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id, userId};
  @override
  CustomExercise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomExercise(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      parameters: $CustomExercisesTable.$converterparameters.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}parameters'],
        )!,
      ),
      primaryMuscleGroup: $CustomExercisesTable.$converterprimaryMuscleGroup
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.string,
              data['${effectivePrefix}primary_muscle_group'],
            )!,
          ),
      secondaryMuscleGroups: $CustomExercisesTable
          .$convertersecondaryMuscleGroups
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.string,
              data['${effectivePrefix}secondary_muscle_groups'],
            )!,
          ),
      equipment: $CustomExercisesTable.$converterequipmentn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}equipment'],
        ),
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
    );
  }

  @override
  $CustomExercisesTable createAlias(String alias) {
    return $CustomExercisesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<GTSetParameters, String, String>
  $converterparameters = const EnumNameConverter<GTSetParameters>(
    GTSetParameters.values,
  );
  static JsonTypeConverter2<GTMuscleGroup, String, String>
  $converterprimaryMuscleGroup = const EnumNameConverter<GTMuscleGroup>(
    GTMuscleGroup.values,
  );
  static TypeConverter<Set<GTMuscleGroup>, String>
  $convertersecondaryMuscleGroups = const MuscleGroupSetConverter();
  static JsonTypeConverter2<GTGymEquipment, String, String>
  $converterequipment = const EnumNameConverter<GTGymEquipment>(
    GTGymEquipment.values,
  );
  static JsonTypeConverter2<GTGymEquipment?, String?, String?>
  $converterequipmentn = JsonTypeConverter2.asNullable($converterequipment);
}

class CustomExercisesCompanion extends UpdateCompanion<CustomExercise> {
  final Value<String> id;
  final Value<String?> userId;
  final Value<DateTime> updatedAt;
  final Value<bool> deleted;
  final Value<String> name;
  final Value<GTSetParameters> parameters;
  final Value<GTMuscleGroup> primaryMuscleGroup;
  final Value<Set<GTMuscleGroup>> secondaryMuscleGroups;
  final Value<GTGymEquipment?> equipment;
  final Value<int> rowid;
  const CustomExercisesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.name = const Value.absent(),
    this.parameters = const Value.absent(),
    this.primaryMuscleGroup = const Value.absent(),
    this.secondaryMuscleGroups = const Value.absent(),
    this.equipment = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomExercisesCompanion.insert({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    required String name,
    required GTSetParameters parameters,
    required GTMuscleGroup primaryMuscleGroup,
    required Set<GTMuscleGroup> secondaryMuscleGroups,
    this.equipment = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : name = Value(name),
       parameters = Value(parameters),
       primaryMuscleGroup = Value(primaryMuscleGroup),
       secondaryMuscleGroups = Value(secondaryMuscleGroups);
  static Insertable<CustomExercise> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<DateTime>? updatedAt,
    Expression<bool>? deleted,
    Expression<String>? name,
    Expression<String>? parameters,
    Expression<String>? primaryMuscleGroup,
    Expression<String>? secondaryMuscleGroups,
    Expression<String>? equipment,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (name != null) 'name': name,
      if (parameters != null) 'parameters': parameters,
      if (primaryMuscleGroup != null)
        'primary_muscle_group': primaryMuscleGroup,
      if (secondaryMuscleGroups != null)
        'secondary_muscle_groups': secondaryMuscleGroups,
      if (equipment != null) 'equipment': equipment,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomExercisesCompanion copyWith({
    Value<String>? id,
    Value<String?>? userId,
    Value<DateTime>? updatedAt,
    Value<bool>? deleted,
    Value<String>? name,
    Value<GTSetParameters>? parameters,
    Value<GTMuscleGroup>? primaryMuscleGroup,
    Value<Set<GTMuscleGroup>>? secondaryMuscleGroups,
    Value<GTGymEquipment?>? equipment,
    Value<int>? rowid,
  }) {
    return CustomExercisesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      name: name ?? this.name,
      parameters: parameters ?? this.parameters,
      primaryMuscleGroup: primaryMuscleGroup ?? this.primaryMuscleGroup,
      secondaryMuscleGroups:
          secondaryMuscleGroups ?? this.secondaryMuscleGroups,
      equipment: equipment ?? this.equipment,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (parameters.present) {
      map['parameters'] = Variable<String>(
        $CustomExercisesTable.$converterparameters.toSql(parameters.value),
      );
    }
    if (primaryMuscleGroup.present) {
      map['primary_muscle_group'] = Variable<String>(
        $CustomExercisesTable.$converterprimaryMuscleGroup.toSql(
          primaryMuscleGroup.value,
        ),
      );
    }
    if (secondaryMuscleGroups.present) {
      map['secondary_muscle_groups'] = Variable<String>(
        $CustomExercisesTable.$convertersecondaryMuscleGroups.toSql(
          secondaryMuscleGroups.value,
        ),
      );
    }
    if (equipment.present) {
      map['equipment'] = Variable<String>(
        $CustomExercisesTable.$converterequipmentn.toSql(equipment.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomExercisesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('name: $name, ')
          ..write('parameters: $parameters, ')
          ..write('primaryMuscleGroup: $primaryMuscleGroup, ')
          ..write('secondaryMuscleGroups: $secondaryMuscleGroups, ')
          ..write('equipment: $equipment, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoutineFoldersTable extends RoutineFolders
    with TableInfo<$RoutineFoldersTable, RoutineFolder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutineFoldersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 100000),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    updatedAt,
    deleted,
    name,
    sortOrder,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routine_folders';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoutineFolder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id, userId};
  @override
  RoutineFolder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoutineFolder(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
    );
  }

  @override
  $RoutineFoldersTable createAlias(String alias) {
    return $RoutineFoldersTable(attachedDatabase, alias);
  }
}

class RoutineFoldersCompanion extends UpdateCompanion<RoutineFolder> {
  final Value<String> id;
  final Value<String?> userId;
  final Value<DateTime?> updatedAt;
  final Value<bool> deleted;
  final Value<String> name;
  final Value<int> sortOrder;
  final Value<String?> notes;
  final Value<int> rowid;
  const RoutineFoldersCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.name = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoutineFoldersCompanion.insert({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    required String name,
    required int sortOrder,
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : name = Value(name),
       sortOrder = Value(sortOrder);
  static Insertable<RoutineFolder> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<DateTime>? updatedAt,
    Expression<bool>? deleted,
    Expression<String>? name,
    Expression<int>? sortOrder,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (name != null) 'name': name,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoutineFoldersCompanion copyWith({
    Value<String>? id,
    Value<String?>? userId,
    Value<DateTime?>? updatedAt,
    Value<bool>? deleted,
    Value<String>? name,
    Value<int>? sortOrder,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return RoutineFoldersCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutineFoldersCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoutinesTable extends Routines with TableInfo<$RoutinesTable, Routine> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: Constant(DateTime.fromMicrosecondsSinceEpoch(0, isUtc: true)),
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _infoboxMeta = const VerificationMeta(
    'infobox',
  );
  @override
  late final GeneratedColumn<String> infobox = GeneratedColumn<String>(
    'infobox',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Weights, String> weightUnit =
      GeneratedColumn<String>(
        'weight_unit',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Weights>($RoutinesTable.$converterweightUnit);
  @override
  late final GeneratedColumnWithTypeConverter<Distance, String> distanceUnit =
      GeneratedColumn<String>(
        'distance_unit',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Distance>($RoutinesTable.$converterdistanceUnit);
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _folderIdMeta = const VerificationMeta(
    'folderId',
  );
  @override
  late final GeneratedColumn<String> folderId = GeneratedColumn<String>(
    'folder_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES routine_folders (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    updatedAt,
    deleted,
    name,
    infobox,
    weightUnit,
    distanceUnit,
    sortOrder,
    folderId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routines';
  @override
  VerificationContext validateIntegrity(
    Insertable<Routine> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('infobox')) {
      context.handle(
        _infoboxMeta,
        infobox.isAcceptableOrUnknown(data['infobox']!, _infoboxMeta),
      );
    } else if (isInserting) {
      context.missing(_infoboxMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('folder_id')) {
      context.handle(
        _folderIdMeta,
        folderId.isAcceptableOrUnknown(data['folder_id']!, _folderIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id, userId};
  @override
  Routine map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Routine(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      infobox: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}infobox'],
      )!,
      weightUnit: $RoutinesTable.$converterweightUnit.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}weight_unit'],
        )!,
      ),
      distanceUnit: $RoutinesTable.$converterdistanceUnit.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}distance_unit'],
        )!,
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      folderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}folder_id'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
    );
  }

  @override
  $RoutinesTable createAlias(String alias) {
    return $RoutinesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Weights, String, String> $converterweightUnit =
      const EnumNameConverter<Weights>(Weights.values);
  static JsonTypeConverter2<Distance, String, String> $converterdistanceUnit =
      const EnumNameConverter<Distance>(Distance.values);
}

class RoutinesCompanion extends UpdateCompanion<Routine> {
  final Value<String> id;
  final Value<String?> userId;
  final Value<DateTime> updatedAt;
  final Value<bool> deleted;
  final Value<String> name;
  final Value<String> infobox;
  final Value<Weights> weightUnit;
  final Value<Distance> distanceUnit;
  final Value<int> sortOrder;
  final Value<String?> folderId;
  final Value<int> rowid;
  const RoutinesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.name = const Value.absent(),
    this.infobox = const Value.absent(),
    this.weightUnit = const Value.absent(),
    this.distanceUnit = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.folderId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoutinesCompanion.insert({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    required String name,
    required String infobox,
    required Weights weightUnit,
    required Distance distanceUnit,
    required int sortOrder,
    this.folderId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : name = Value(name),
       infobox = Value(infobox),
       weightUnit = Value(weightUnit),
       distanceUnit = Value(distanceUnit),
       sortOrder = Value(sortOrder);
  static Insertable<Routine> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<DateTime>? updatedAt,
    Expression<bool>? deleted,
    Expression<String>? name,
    Expression<String>? infobox,
    Expression<String>? weightUnit,
    Expression<String>? distanceUnit,
    Expression<int>? sortOrder,
    Expression<String>? folderId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (name != null) 'name': name,
      if (infobox != null) 'infobox': infobox,
      if (weightUnit != null) 'weight_unit': weightUnit,
      if (distanceUnit != null) 'distance_unit': distanceUnit,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (folderId != null) 'folder_id': folderId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoutinesCompanion copyWith({
    Value<String>? id,
    Value<String?>? userId,
    Value<DateTime>? updatedAt,
    Value<bool>? deleted,
    Value<String>? name,
    Value<String>? infobox,
    Value<Weights>? weightUnit,
    Value<Distance>? distanceUnit,
    Value<int>? sortOrder,
    Value<String?>? folderId,
    Value<int>? rowid,
  }) {
    return RoutinesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      name: name ?? this.name,
      infobox: infobox ?? this.infobox,
      weightUnit: weightUnit ?? this.weightUnit,
      distanceUnit: distanceUnit ?? this.distanceUnit,
      sortOrder: sortOrder ?? this.sortOrder,
      folderId: folderId ?? this.folderId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (infobox.present) {
      map['infobox'] = Variable<String>(infobox.value);
    }
    if (weightUnit.present) {
      map['weight_unit'] = Variable<String>(
        $RoutinesTable.$converterweightUnit.toSql(weightUnit.value),
      );
    }
    if (distanceUnit.present) {
      map['distance_unit'] = Variable<String>(
        $RoutinesTable.$converterdistanceUnit.toSql(distanceUnit.value),
      );
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (folderId.present) {
      map['folder_id'] = Variable<String>(folderId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutinesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('name: $name, ')
          ..write('infobox: $infobox, ')
          ..write('weightUnit: $weightUnit, ')
          ..write('distanceUnit: $distanceUnit, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('folderId: $folderId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HistoryWorkoutsTable extends HistoryWorkouts
    with TableInfo<$HistoryWorkoutsTable, HistoryWorkout> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HistoryWorkoutsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: Constant(DateTime.fromMicrosecondsSinceEpoch(0, isUtc: true)),
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _visibilityMeta = const VerificationMeta(
    'visibility',
  );
  @override
  late final GeneratedColumn<String> visibility = GeneratedColumn<String>(
    'visibility',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('friends'),
  );
  static const VerificationMeta _publicationManifestMeta =
      const VerificationMeta('publicationManifest');
  @override
  late final GeneratedColumn<String> publicationManifest =
      GeneratedColumn<String>(
        'publication_manifest',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _infoboxMeta = const VerificationMeta(
    'infobox',
  );
  @override
  late final GeneratedColumn<String> infobox = GeneratedColumn<String>(
    'infobox',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMeta = const VerificationMeta(
    'duration',
  );
  @override
  late final GeneratedColumn<int> duration = GeneratedColumn<int>(
    'duration',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startingDateMeta = const VerificationMeta(
    'startingDate',
  );
  @override
  late final GeneratedColumn<DateTime> startingDate = GeneratedColumn<DateTime>(
    'starting_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES routines (id)',
    ),
  );
  static const VerificationMeta _completedByMeta = const VerificationMeta(
    'completedBy',
  );
  @override
  late final GeneratedColumn<String> completedBy = GeneratedColumn<String>(
    'completed_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES history_workouts (id)',
    ),
  );
  static const VerificationMeta _completesMeta = const VerificationMeta(
    'completes',
  );
  @override
  late final GeneratedColumn<String> completes = GeneratedColumn<String>(
    'completes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES history_workouts (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<Weights, String> weightUnit =
      GeneratedColumn<String>(
        'weight_unit',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Weights>($HistoryWorkoutsTable.$converterweightUnit);
  @override
  late final GeneratedColumnWithTypeConverter<Distance, String> distanceUnit =
      GeneratedColumn<String>(
        'distance_unit',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Distance>($HistoryWorkoutsTable.$converterdistanceUnit);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    updatedAt,
    deleted,
    visibility,
    publicationManifest,
    name,
    infobox,
    duration,
    startingDate,
    parentId,
    completedBy,
    completes,
    weightUnit,
    distanceUnit,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'history_workouts';
  @override
  VerificationContext validateIntegrity(
    Insertable<HistoryWorkout> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('visibility')) {
      context.handle(
        _visibilityMeta,
        visibility.isAcceptableOrUnknown(data['visibility']!, _visibilityMeta),
      );
    }
    if (data.containsKey('publication_manifest')) {
      context.handle(
        _publicationManifestMeta,
        publicationManifest.isAcceptableOrUnknown(
          data['publication_manifest']!,
          _publicationManifestMeta,
        ),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('infobox')) {
      context.handle(
        _infoboxMeta,
        infobox.isAcceptableOrUnknown(data['infobox']!, _infoboxMeta),
      );
    }
    if (data.containsKey('duration')) {
      context.handle(
        _durationMeta,
        duration.isAcceptableOrUnknown(data['duration']!, _durationMeta),
      );
    } else if (isInserting) {
      context.missing(_durationMeta);
    }
    if (data.containsKey('starting_date')) {
      context.handle(
        _startingDateMeta,
        startingDate.isAcceptableOrUnknown(
          data['starting_date']!,
          _startingDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startingDateMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('completed_by')) {
      context.handle(
        _completedByMeta,
        completedBy.isAcceptableOrUnknown(
          data['completed_by']!,
          _completedByMeta,
        ),
      );
    }
    if (data.containsKey('completes')) {
      context.handle(
        _completesMeta,
        completes.isAcceptableOrUnknown(data['completes']!, _completesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id, userId};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {completedBy, completes},
  ];
  @override
  HistoryWorkout map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HistoryWorkout(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      visibility: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}visibility'],
      )!,
      publicationManifest: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}publication_manifest'],
      ),
      infobox: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}infobox'],
      ),
      duration: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration'],
      )!,
      startingDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}starting_date'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_id'],
      ),
      completedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}completed_by'],
      ),
      completes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}completes'],
      ),
      weightUnit: $HistoryWorkoutsTable.$converterweightUnit.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}weight_unit'],
        )!,
      ),
      distanceUnit: $HistoryWorkoutsTable.$converterdistanceUnit.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}distance_unit'],
        )!,
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
    );
  }

  @override
  $HistoryWorkoutsTable createAlias(String alias) {
    return $HistoryWorkoutsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Weights, String, String> $converterweightUnit =
      const EnumNameConverter<Weights>(Weights.values);
  static JsonTypeConverter2<Distance, String, String> $converterdistanceUnit =
      const EnumNameConverter<Distance>(Distance.values);
}

class HistoryWorkoutsCompanion extends UpdateCompanion<HistoryWorkout> {
  final Value<String> id;
  final Value<String?> userId;
  final Value<DateTime> updatedAt;
  final Value<bool> deleted;
  final Value<String> visibility;
  final Value<String?> publicationManifest;
  final Value<String> name;
  final Value<String?> infobox;
  final Value<int> duration;
  final Value<DateTime> startingDate;
  final Value<String?> parentId;
  final Value<String?> completedBy;
  final Value<String?> completes;
  final Value<Weights> weightUnit;
  final Value<Distance> distanceUnit;
  final Value<int> rowid;
  const HistoryWorkoutsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.visibility = const Value.absent(),
    this.publicationManifest = const Value.absent(),
    this.name = const Value.absent(),
    this.infobox = const Value.absent(),
    this.duration = const Value.absent(),
    this.startingDate = const Value.absent(),
    this.parentId = const Value.absent(),
    this.completedBy = const Value.absent(),
    this.completes = const Value.absent(),
    this.weightUnit = const Value.absent(),
    this.distanceUnit = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HistoryWorkoutsCompanion.insert({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.visibility = const Value.absent(),
    this.publicationManifest = const Value.absent(),
    required String name,
    this.infobox = const Value.absent(),
    required int duration,
    required DateTime startingDate,
    this.parentId = const Value.absent(),
    this.completedBy = const Value.absent(),
    this.completes = const Value.absent(),
    required Weights weightUnit,
    required Distance distanceUnit,
    this.rowid = const Value.absent(),
  }) : name = Value(name),
       duration = Value(duration),
       startingDate = Value(startingDate),
       weightUnit = Value(weightUnit),
       distanceUnit = Value(distanceUnit);
  static Insertable<HistoryWorkout> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<DateTime>? updatedAt,
    Expression<bool>? deleted,
    Expression<String>? visibility,
    Expression<String>? publicationManifest,
    Expression<String>? name,
    Expression<String>? infobox,
    Expression<int>? duration,
    Expression<DateTime>? startingDate,
    Expression<String>? parentId,
    Expression<String>? completedBy,
    Expression<String>? completes,
    Expression<String>? weightUnit,
    Expression<String>? distanceUnit,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (visibility != null) 'visibility': visibility,
      if (publicationManifest != null)
        'publication_manifest': publicationManifest,
      if (name != null) 'name': name,
      if (infobox != null) 'infobox': infobox,
      if (duration != null) 'duration': duration,
      if (startingDate != null) 'starting_date': startingDate,
      if (parentId != null) 'parent_id': parentId,
      if (completedBy != null) 'completed_by': completedBy,
      if (completes != null) 'completes': completes,
      if (weightUnit != null) 'weight_unit': weightUnit,
      if (distanceUnit != null) 'distance_unit': distanceUnit,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HistoryWorkoutsCompanion copyWith({
    Value<String>? id,
    Value<String?>? userId,
    Value<DateTime>? updatedAt,
    Value<bool>? deleted,
    Value<String>? visibility,
    Value<String?>? publicationManifest,
    Value<String>? name,
    Value<String?>? infobox,
    Value<int>? duration,
    Value<DateTime>? startingDate,
    Value<String?>? parentId,
    Value<String?>? completedBy,
    Value<String?>? completes,
    Value<Weights>? weightUnit,
    Value<Distance>? distanceUnit,
    Value<int>? rowid,
  }) {
    return HistoryWorkoutsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      visibility: visibility ?? this.visibility,
      publicationManifest: publicationManifest ?? this.publicationManifest,
      name: name ?? this.name,
      infobox: infobox ?? this.infobox,
      duration: duration ?? this.duration,
      startingDate: startingDate ?? this.startingDate,
      parentId: parentId ?? this.parentId,
      completedBy: completedBy ?? this.completedBy,
      completes: completes ?? this.completes,
      weightUnit: weightUnit ?? this.weightUnit,
      distanceUnit: distanceUnit ?? this.distanceUnit,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (visibility.present) {
      map['visibility'] = Variable<String>(visibility.value);
    }
    if (publicationManifest.present) {
      map['publication_manifest'] = Variable<String>(publicationManifest.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (infobox.present) {
      map['infobox'] = Variable<String>(infobox.value);
    }
    if (duration.present) {
      map['duration'] = Variable<int>(duration.value);
    }
    if (startingDate.present) {
      map['starting_date'] = Variable<DateTime>(startingDate.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (completedBy.present) {
      map['completed_by'] = Variable<String>(completedBy.value);
    }
    if (completes.present) {
      map['completes'] = Variable<String>(completes.value);
    }
    if (weightUnit.present) {
      map['weight_unit'] = Variable<String>(
        $HistoryWorkoutsTable.$converterweightUnit.toSql(weightUnit.value),
      );
    }
    if (distanceUnit.present) {
      map['distance_unit'] = Variable<String>(
        $HistoryWorkoutsTable.$converterdistanceUnit.toSql(distanceUnit.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HistoryWorkoutsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('visibility: $visibility, ')
          ..write('publicationManifest: $publicationManifest, ')
          ..write('name: $name, ')
          ..write('infobox: $infobox, ')
          ..write('duration: $duration, ')
          ..write('startingDate: $startingDate, ')
          ..write('parentId: $parentId, ')
          ..write('completedBy: $completedBy, ')
          ..write('completes: $completes, ')
          ..write('weightUnit: $weightUnit, ')
          ..write('distanceUnit: $distanceUnit, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HistoryWorkoutExercisesTable extends HistoryWorkoutExercises
    with TableInfo<$HistoryWorkoutExercisesTable, HistoryWorkoutExercise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HistoryWorkoutExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _routineIdMeta = const VerificationMeta(
    'routineId',
  );
  @override
  late final GeneratedColumn<String> routineId = GeneratedColumn<String>(
    'routine_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES history_workouts (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<GTSetParameters?, String>
  parameters =
      GeneratedColumn<String>(
        'parameters',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<GTSetParameters?>(
        $HistoryWorkoutExercisesTable.$converterparametersn,
      );
  @override
  late final GeneratedColumnWithTypeConverter<List<GTSet>?, String> sets =
      GeneratedColumn<String>(
        'sets',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<List<GTSet>?>(
        $HistoryWorkoutExercisesTable.$convertersetsn,
      );
  @override
  late final GeneratedColumnWithTypeConverter<GTMuscleGroup?, String>
  primaryMuscleGroup =
      GeneratedColumn<String>(
        'primary_muscle_group',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<GTMuscleGroup?>(
        $HistoryWorkoutExercisesTable.$converterprimaryMuscleGroupn,
      );
  @override
  late final GeneratedColumnWithTypeConverter<Set<GTMuscleGroup>?, String>
  secondaryMuscleGroups =
      GeneratedColumn<String>(
        'secondary_muscle_groups',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Set<GTMuscleGroup>?>(
        $HistoryWorkoutExercisesTable.$convertersecondaryMuscleGroupsn,
      );
  static const VerificationMeta _restTimeMeta = const VerificationMeta(
    'restTime',
  );
  @override
  late final GeneratedColumn<int> restTime = GeneratedColumn<int>(
    'rest_time',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isCustomMeta = const VerificationMeta(
    'isCustom',
  );
  @override
  late final GeneratedColumn<bool> isCustom = GeneratedColumn<bool>(
    'is_custom',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_custom" IN (0, 1))',
    ),
  );
  static const VerificationMeta _libraryExerciseIdMeta = const VerificationMeta(
    'libraryExerciseId',
  );
  @override
  late final GeneratedColumn<String> libraryExerciseId =
      GeneratedColumn<String>(
        'library_exercise_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _customExerciseIdMeta = const VerificationMeta(
    'customExerciseId',
  );
  @override
  late final GeneratedColumn<String> customExerciseId = GeneratedColumn<String>(
    'custom_exercise_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES custom_exercises (id)',
    ),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isSupersetMeta = const VerificationMeta(
    'isSuperset',
  );
  @override
  late final GeneratedColumn<bool> isSuperset = GeneratedColumn<bool>(
    'is_superset',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_superset" IN (0, 1))',
    ),
  );
  static const VerificationMeta _isInSupersetMeta = const VerificationMeta(
    'isInSuperset',
  );
  @override
  late final GeneratedColumn<bool> isInSuperset = GeneratedColumn<bool>(
    'is_in_superset',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_in_superset" IN (0, 1))',
    ),
  );
  static const VerificationMeta _supersetIdMeta = const VerificationMeta(
    'supersetId',
  );
  @override
  late final GeneratedColumn<String> supersetId = GeneratedColumn<String>(
    'superset_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES history_workout_exercises (id)',
    ),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _supersedesIdMeta = const VerificationMeta(
    'supersedesId',
  );
  @override
  late final GeneratedColumn<String> supersedesId = GeneratedColumn<String>(
    'supersedes_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES history_workout_exercises (id)',
    ),
  );
  static const VerificationMeta _rpeMeta = const VerificationMeta('rpe');
  @override
  late final GeneratedColumn<int> rpe = GeneratedColumn<int>(
    'rpe',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ExerciseProgression?, String>
  progression =
      GeneratedColumn<String>(
        'progression',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<ExerciseProgression?>(
        $HistoryWorkoutExercisesTable.$converterprogressionn,
      );
  @override
  late final GeneratedColumnWithTypeConverter<GTGymEquipment?, String>
  equipment =
      GeneratedColumn<String>(
        'equipment',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        clientDefault: () => GTGymEquipment.none.name,
      ).withConverter<GTGymEquipment?>(
        $HistoryWorkoutExercisesTable.$converterequipmentn,
      );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: Constant(DateTime.fromMicrosecondsSinceEpoch(0, isUtc: true)),
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _publicationVersionMeta =
      const VerificationMeta('publicationVersion');
  @override
  late final GeneratedColumn<String> publicationVersion =
      GeneratedColumn<String>(
        'publication_version',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    routineId,
    name,
    parameters,
    sets,
    primaryMuscleGroup,
    secondaryMuscleGroups,
    restTime,
    isCustom,
    libraryExerciseId,
    customExerciseId,
    notes,
    isSuperset,
    isInSuperset,
    supersetId,
    sortOrder,
    supersedesId,
    rpe,
    progression,
    equipment,
    updatedAt,
    deleted,
    userId,
    publicationVersion,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'history_workout_exercises';
  @override
  VerificationContext validateIntegrity(
    Insertable<HistoryWorkoutExercise> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('routine_id')) {
      context.handle(
        _routineIdMeta,
        routineId.isAcceptableOrUnknown(data['routine_id']!, _routineIdMeta),
      );
    } else if (isInserting) {
      context.missing(_routineIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('rest_time')) {
      context.handle(
        _restTimeMeta,
        restTime.isAcceptableOrUnknown(data['rest_time']!, _restTimeMeta),
      );
    }
    if (data.containsKey('is_custom')) {
      context.handle(
        _isCustomMeta,
        isCustom.isAcceptableOrUnknown(data['is_custom']!, _isCustomMeta),
      );
    } else if (isInserting) {
      context.missing(_isCustomMeta);
    }
    if (data.containsKey('library_exercise_id')) {
      context.handle(
        _libraryExerciseIdMeta,
        libraryExerciseId.isAcceptableOrUnknown(
          data['library_exercise_id']!,
          _libraryExerciseIdMeta,
        ),
      );
    }
    if (data.containsKey('custom_exercise_id')) {
      context.handle(
        _customExerciseIdMeta,
        customExerciseId.isAcceptableOrUnknown(
          data['custom_exercise_id']!,
          _customExerciseIdMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('is_superset')) {
      context.handle(
        _isSupersetMeta,
        isSuperset.isAcceptableOrUnknown(data['is_superset']!, _isSupersetMeta),
      );
    } else if (isInserting) {
      context.missing(_isSupersetMeta);
    }
    if (data.containsKey('is_in_superset')) {
      context.handle(
        _isInSupersetMeta,
        isInSuperset.isAcceptableOrUnknown(
          data['is_in_superset']!,
          _isInSupersetMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_isInSupersetMeta);
    }
    if (data.containsKey('superset_id')) {
      context.handle(
        _supersetIdMeta,
        supersetId.isAcceptableOrUnknown(data['superset_id']!, _supersetIdMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('supersedes_id')) {
      context.handle(
        _supersedesIdMeta,
        supersedesId.isAcceptableOrUnknown(
          data['supersedes_id']!,
          _supersedesIdMeta,
        ),
      );
    }
    if (data.containsKey('rpe')) {
      context.handle(
        _rpeMeta,
        rpe.isAcceptableOrUnknown(data['rpe']!, _rpeMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('publication_version')) {
      context.handle(
        _publicationVersionMeta,
        publicationVersion.isAcceptableOrUnknown(
          data['publication_version']!,
          _publicationVersionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id, userId};
  @override
  HistoryWorkoutExercise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HistoryWorkoutExercise(
      publicationVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}publication_version'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      routineId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}routine_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      parameters: $HistoryWorkoutExercisesTable.$converterparametersn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}parameters'],
        ),
      ),
      sets: $HistoryWorkoutExercisesTable.$convertersetsn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sets'],
        ),
      ),
      primaryMuscleGroup: $HistoryWorkoutExercisesTable
          .$converterprimaryMuscleGroupn
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.string,
              data['${effectivePrefix}primary_muscle_group'],
            ),
          ),
      secondaryMuscleGroups: $HistoryWorkoutExercisesTable
          .$convertersecondaryMuscleGroupsn
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.string,
              data['${effectivePrefix}secondary_muscle_groups'],
            ),
          ),
      restTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rest_time'],
      ),
      isCustom: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_custom'],
      )!,
      libraryExerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}library_exercise_id'],
      ),
      customExerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_exercise_id'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      isSuperset: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_superset'],
      )!,
      isInSuperset: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_in_superset'],
      )!,
      supersetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}superset_id'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      supersedesId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supersedes_id'],
      ),
      rpe: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rpe'],
      ),
      progression: $HistoryWorkoutExercisesTable.$converterprogressionn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}progression'],
        ),
      ),
      equipment: $HistoryWorkoutExercisesTable.$converterequipmentn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}equipment'],
        ),
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
    );
  }

  @override
  $HistoryWorkoutExercisesTable createAlias(String alias) {
    return $HistoryWorkoutExercisesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<GTSetParameters, String, String>
  $converterparameters = const EnumNameConverter<GTSetParameters>(
    GTSetParameters.values,
  );
  static JsonTypeConverter2<GTSetParameters?, String?, String?>
  $converterparametersn = JsonTypeConverter2.asNullable($converterparameters);
  static TypeConverter<List<GTSet>, String> $convertersets =
      const GTSetListConverter();
  static TypeConverter<List<GTSet>?, String?> $convertersetsn =
      NullAwareTypeConverter.wrap($convertersets);
  static JsonTypeConverter2<GTMuscleGroup, String, String>
  $converterprimaryMuscleGroup = const EnumNameConverter<GTMuscleGroup>(
    GTMuscleGroup.values,
  );
  static JsonTypeConverter2<GTMuscleGroup?, String?, String?>
  $converterprimaryMuscleGroupn = JsonTypeConverter2.asNullable(
    $converterprimaryMuscleGroup,
  );
  static TypeConverter<Set<GTMuscleGroup>, String>
  $convertersecondaryMuscleGroups = const MuscleGroupSetConverter();
  static TypeConverter<Set<GTMuscleGroup>?, String?>
  $convertersecondaryMuscleGroupsn = NullAwareTypeConverter.wrap(
    $convertersecondaryMuscleGroups,
  );
  static TypeConverter<ExerciseProgression, String> $converterprogression =
      const ExerciseProgressionConverter();
  static TypeConverter<ExerciseProgression?, String?> $converterprogressionn =
      NullAwareTypeConverter.wrap($converterprogression);
  static JsonTypeConverter2<GTGymEquipment, String, String>
  $converterequipment = const EnumNameConverter<GTGymEquipment>(
    GTGymEquipment.values,
  );
  static JsonTypeConverter2<GTGymEquipment?, String?, String?>
  $converterequipmentn = JsonTypeConverter2.asNullable($converterequipment);
}

class HistoryWorkoutExercisesCompanion
    extends UpdateCompanion<HistoryWorkoutExercise> {
  final Value<String> id;
  final Value<String> routineId;
  final Value<String> name;
  final Value<GTSetParameters?> parameters;
  final Value<List<GTSet>?> sets;
  final Value<GTMuscleGroup?> primaryMuscleGroup;
  final Value<Set<GTMuscleGroup>?> secondaryMuscleGroups;
  final Value<int?> restTime;
  final Value<bool> isCustom;
  final Value<String?> libraryExerciseId;
  final Value<String?> customExerciseId;
  final Value<String?> notes;
  final Value<bool> isSuperset;
  final Value<bool> isInSuperset;
  final Value<String?> supersetId;
  final Value<int> sortOrder;
  final Value<String?> supersedesId;
  final Value<int?> rpe;
  final Value<ExerciseProgression?> progression;
  final Value<GTGymEquipment?> equipment;
  final Value<DateTime> updatedAt;
  final Value<bool> deleted;
  final Value<String?> userId;
  final Value<String?> publicationVersion;
  final Value<int> rowid;
  const HistoryWorkoutExercisesCompanion({
    this.id = const Value.absent(),
    this.routineId = const Value.absent(),
    this.name = const Value.absent(),
    this.parameters = const Value.absent(),
    this.sets = const Value.absent(),
    this.primaryMuscleGroup = const Value.absent(),
    this.secondaryMuscleGroups = const Value.absent(),
    this.restTime = const Value.absent(),
    this.isCustom = const Value.absent(),
    this.libraryExerciseId = const Value.absent(),
    this.customExerciseId = const Value.absent(),
    this.notes = const Value.absent(),
    this.isSuperset = const Value.absent(),
    this.isInSuperset = const Value.absent(),
    this.supersetId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.supersedesId = const Value.absent(),
    this.rpe = const Value.absent(),
    this.progression = const Value.absent(),
    this.equipment = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.userId = const Value.absent(),
    this.publicationVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HistoryWorkoutExercisesCompanion.insert({
    this.id = const Value.absent(),
    required String routineId,
    required String name,
    this.parameters = const Value.absent(),
    this.sets = const Value.absent(),
    this.primaryMuscleGroup = const Value.absent(),
    this.secondaryMuscleGroups = const Value.absent(),
    this.restTime = const Value.absent(),
    required bool isCustom,
    this.libraryExerciseId = const Value.absent(),
    this.customExerciseId = const Value.absent(),
    this.notes = const Value.absent(),
    required bool isSuperset,
    required bool isInSuperset,
    this.supersetId = const Value.absent(),
    required int sortOrder,
    this.supersedesId = const Value.absent(),
    this.rpe = const Value.absent(),
    this.progression = const Value.absent(),
    this.equipment = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.userId = const Value.absent(),
    this.publicationVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : routineId = Value(routineId),
       name = Value(name),
       isCustom = Value(isCustom),
       isSuperset = Value(isSuperset),
       isInSuperset = Value(isInSuperset),
       sortOrder = Value(sortOrder);
  static Insertable<HistoryWorkoutExercise> custom({
    Expression<String>? id,
    Expression<String>? routineId,
    Expression<String>? name,
    Expression<String>? parameters,
    Expression<String>? sets,
    Expression<String>? primaryMuscleGroup,
    Expression<String>? secondaryMuscleGroups,
    Expression<int>? restTime,
    Expression<bool>? isCustom,
    Expression<String>? libraryExerciseId,
    Expression<String>? customExerciseId,
    Expression<String>? notes,
    Expression<bool>? isSuperset,
    Expression<bool>? isInSuperset,
    Expression<String>? supersetId,
    Expression<int>? sortOrder,
    Expression<String>? supersedesId,
    Expression<int>? rpe,
    Expression<String>? progression,
    Expression<String>? equipment,
    Expression<DateTime>? updatedAt,
    Expression<bool>? deleted,
    Expression<String>? userId,
    Expression<String>? publicationVersion,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (routineId != null) 'routine_id': routineId,
      if (name != null) 'name': name,
      if (parameters != null) 'parameters': parameters,
      if (sets != null) 'sets': sets,
      if (primaryMuscleGroup != null)
        'primary_muscle_group': primaryMuscleGroup,
      if (secondaryMuscleGroups != null)
        'secondary_muscle_groups': secondaryMuscleGroups,
      if (restTime != null) 'rest_time': restTime,
      if (isCustom != null) 'is_custom': isCustom,
      if (libraryExerciseId != null) 'library_exercise_id': libraryExerciseId,
      if (customExerciseId != null) 'custom_exercise_id': customExerciseId,
      if (notes != null) 'notes': notes,
      if (isSuperset != null) 'is_superset': isSuperset,
      if (isInSuperset != null) 'is_in_superset': isInSuperset,
      if (supersetId != null) 'superset_id': supersetId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (supersedesId != null) 'supersedes_id': supersedesId,
      if (rpe != null) 'rpe': rpe,
      if (progression != null) 'progression': progression,
      if (equipment != null) 'equipment': equipment,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (userId != null) 'user_id': userId,
      if (publicationVersion != null) 'publication_version': publicationVersion,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HistoryWorkoutExercisesCompanion copyWith({
    Value<String>? id,
    Value<String>? routineId,
    Value<String>? name,
    Value<GTSetParameters?>? parameters,
    Value<List<GTSet>?>? sets,
    Value<GTMuscleGroup?>? primaryMuscleGroup,
    Value<Set<GTMuscleGroup>?>? secondaryMuscleGroups,
    Value<int?>? restTime,
    Value<bool>? isCustom,
    Value<String?>? libraryExerciseId,
    Value<String?>? customExerciseId,
    Value<String?>? notes,
    Value<bool>? isSuperset,
    Value<bool>? isInSuperset,
    Value<String?>? supersetId,
    Value<int>? sortOrder,
    Value<String?>? supersedesId,
    Value<int?>? rpe,
    Value<ExerciseProgression?>? progression,
    Value<GTGymEquipment?>? equipment,
    Value<DateTime>? updatedAt,
    Value<bool>? deleted,
    Value<String?>? userId,
    Value<String?>? publicationVersion,
    Value<int>? rowid,
  }) {
    return HistoryWorkoutExercisesCompanion(
      id: id ?? this.id,
      routineId: routineId ?? this.routineId,
      name: name ?? this.name,
      parameters: parameters ?? this.parameters,
      sets: sets ?? this.sets,
      primaryMuscleGroup: primaryMuscleGroup ?? this.primaryMuscleGroup,
      secondaryMuscleGroups:
          secondaryMuscleGroups ?? this.secondaryMuscleGroups,
      restTime: restTime ?? this.restTime,
      isCustom: isCustom ?? this.isCustom,
      libraryExerciseId: libraryExerciseId ?? this.libraryExerciseId,
      customExerciseId: customExerciseId ?? this.customExerciseId,
      notes: notes ?? this.notes,
      isSuperset: isSuperset ?? this.isSuperset,
      isInSuperset: isInSuperset ?? this.isInSuperset,
      supersetId: supersetId ?? this.supersetId,
      sortOrder: sortOrder ?? this.sortOrder,
      supersedesId: supersedesId ?? this.supersedesId,
      rpe: rpe ?? this.rpe,
      progression: progression ?? this.progression,
      equipment: equipment ?? this.equipment,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      userId: userId ?? this.userId,
      publicationVersion: publicationVersion ?? this.publicationVersion,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (routineId.present) {
      map['routine_id'] = Variable<String>(routineId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (parameters.present) {
      map['parameters'] = Variable<String>(
        $HistoryWorkoutExercisesTable.$converterparametersn.toSql(
          parameters.value,
        ),
      );
    }
    if (sets.present) {
      map['sets'] = Variable<String>(
        $HistoryWorkoutExercisesTable.$convertersetsn.toSql(sets.value),
      );
    }
    if (primaryMuscleGroup.present) {
      map['primary_muscle_group'] = Variable<String>(
        $HistoryWorkoutExercisesTable.$converterprimaryMuscleGroupn.toSql(
          primaryMuscleGroup.value,
        ),
      );
    }
    if (secondaryMuscleGroups.present) {
      map['secondary_muscle_groups'] = Variable<String>(
        $HistoryWorkoutExercisesTable.$convertersecondaryMuscleGroupsn.toSql(
          secondaryMuscleGroups.value,
        ),
      );
    }
    if (restTime.present) {
      map['rest_time'] = Variable<int>(restTime.value);
    }
    if (isCustom.present) {
      map['is_custom'] = Variable<bool>(isCustom.value);
    }
    if (libraryExerciseId.present) {
      map['library_exercise_id'] = Variable<String>(libraryExerciseId.value);
    }
    if (customExerciseId.present) {
      map['custom_exercise_id'] = Variable<String>(customExerciseId.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isSuperset.present) {
      map['is_superset'] = Variable<bool>(isSuperset.value);
    }
    if (isInSuperset.present) {
      map['is_in_superset'] = Variable<bool>(isInSuperset.value);
    }
    if (supersetId.present) {
      map['superset_id'] = Variable<String>(supersetId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (supersedesId.present) {
      map['supersedes_id'] = Variable<String>(supersedesId.value);
    }
    if (rpe.present) {
      map['rpe'] = Variable<int>(rpe.value);
    }
    if (progression.present) {
      map['progression'] = Variable<String>(
        $HistoryWorkoutExercisesTable.$converterprogressionn.toSql(
          progression.value,
        ),
      );
    }
    if (equipment.present) {
      map['equipment'] = Variable<String>(
        $HistoryWorkoutExercisesTable.$converterequipmentn.toSql(
          equipment.value,
        ),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (publicationVersion.present) {
      map['publication_version'] = Variable<String>(publicationVersion.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HistoryWorkoutExercisesCompanion(')
          ..write('id: $id, ')
          ..write('routineId: $routineId, ')
          ..write('name: $name, ')
          ..write('parameters: $parameters, ')
          ..write('sets: $sets, ')
          ..write('primaryMuscleGroup: $primaryMuscleGroup, ')
          ..write('secondaryMuscleGroups: $secondaryMuscleGroups, ')
          ..write('restTime: $restTime, ')
          ..write('isCustom: $isCustom, ')
          ..write('libraryExerciseId: $libraryExerciseId, ')
          ..write('customExerciseId: $customExerciseId, ')
          ..write('notes: $notes, ')
          ..write('isSuperset: $isSuperset, ')
          ..write('isInSuperset: $isInSuperset, ')
          ..write('supersetId: $supersetId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('supersedesId: $supersedesId, ')
          ..write('rpe: $rpe, ')
          ..write('progression: $progression, ')
          ..write('equipment: $equipment, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('userId: $userId, ')
          ..write('publicationVersion: $publicationVersion, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoutineExercisesTable extends RoutineExercises
    with TableInfo<$RoutineExercisesTable, RoutineExercise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutineExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _routineIdMeta = const VerificationMeta(
    'routineId',
  );
  @override
  late final GeneratedColumn<String> routineId = GeneratedColumn<String>(
    'routine_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES routines (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<GTSetParameters?, String>
  parameters =
      GeneratedColumn<String>(
        'parameters',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<GTSetParameters?>(
        $RoutineExercisesTable.$converterparametersn,
      );
  @override
  late final GeneratedColumnWithTypeConverter<List<GTSet>?, String> sets =
      GeneratedColumn<String>(
        'sets',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<List<GTSet>?>($RoutineExercisesTable.$convertersetsn);
  @override
  late final GeneratedColumnWithTypeConverter<GTMuscleGroup?, String>
  primaryMuscleGroup =
      GeneratedColumn<String>(
        'primary_muscle_group',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<GTMuscleGroup?>(
        $RoutineExercisesTable.$converterprimaryMuscleGroupn,
      );
  @override
  late final GeneratedColumnWithTypeConverter<Set<GTMuscleGroup>?, String>
  secondaryMuscleGroups =
      GeneratedColumn<String>(
        'secondary_muscle_groups',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Set<GTMuscleGroup>?>(
        $RoutineExercisesTable.$convertersecondaryMuscleGroupsn,
      );
  static const VerificationMeta _restTimeMeta = const VerificationMeta(
    'restTime',
  );
  @override
  late final GeneratedColumn<int> restTime = GeneratedColumn<int>(
    'rest_time',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isCustomMeta = const VerificationMeta(
    'isCustom',
  );
  @override
  late final GeneratedColumn<bool> isCustom = GeneratedColumn<bool>(
    'is_custom',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_custom" IN (0, 1))',
    ),
  );
  static const VerificationMeta _libraryExerciseIdMeta = const VerificationMeta(
    'libraryExerciseId',
  );
  @override
  late final GeneratedColumn<String> libraryExerciseId =
      GeneratedColumn<String>(
        'library_exercise_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _customExerciseIdMeta = const VerificationMeta(
    'customExerciseId',
  );
  @override
  late final GeneratedColumn<String> customExerciseId = GeneratedColumn<String>(
    'custom_exercise_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES custom_exercises (id)',
    ),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isSupersetMeta = const VerificationMeta(
    'isSuperset',
  );
  @override
  late final GeneratedColumn<bool> isSuperset = GeneratedColumn<bool>(
    'is_superset',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_superset" IN (0, 1))',
    ),
  );
  static const VerificationMeta _isInSupersetMeta = const VerificationMeta(
    'isInSuperset',
  );
  @override
  late final GeneratedColumn<bool> isInSuperset = GeneratedColumn<bool>(
    'is_in_superset',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_in_superset" IN (0, 1))',
    ),
  );
  static const VerificationMeta _supersetIdMeta = const VerificationMeta(
    'supersetId',
  );
  @override
  late final GeneratedColumn<String> supersetId = GeneratedColumn<String>(
    'superset_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES routine_exercises (id)',
    ),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _supersedesIdMeta = const VerificationMeta(
    'supersedesId',
  );
  @override
  late final GeneratedColumn<String> supersedesId = GeneratedColumn<String>(
    'supersedes_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES routine_exercises (id)',
    ),
  );
  static const VerificationMeta _rpeMeta = const VerificationMeta('rpe');
  @override
  late final GeneratedColumn<int> rpe = GeneratedColumn<int>(
    'rpe',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ExerciseProgression?, String>
  progression =
      GeneratedColumn<String>(
        'progression',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<ExerciseProgression?>(
        $RoutineExercisesTable.$converterprogressionn,
      );
  @override
  late final GeneratedColumnWithTypeConverter<GTGymEquipment?, String>
  equipment = GeneratedColumn<String>(
    'equipment',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => GTGymEquipment.none.name,
  ).withConverter<GTGymEquipment?>($RoutineExercisesTable.$converterequipmentn);
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: Constant(DateTime.fromMicrosecondsSinceEpoch(0, isUtc: true)),
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    routineId,
    name,
    parameters,
    sets,
    primaryMuscleGroup,
    secondaryMuscleGroups,
    restTime,
    isCustom,
    libraryExerciseId,
    customExerciseId,
    notes,
    isSuperset,
    isInSuperset,
    supersetId,
    sortOrder,
    supersedesId,
    rpe,
    progression,
    equipment,
    updatedAt,
    deleted,
    userId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routine_exercises';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoutineExercise> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('routine_id')) {
      context.handle(
        _routineIdMeta,
        routineId.isAcceptableOrUnknown(data['routine_id']!, _routineIdMeta),
      );
    } else if (isInserting) {
      context.missing(_routineIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('rest_time')) {
      context.handle(
        _restTimeMeta,
        restTime.isAcceptableOrUnknown(data['rest_time']!, _restTimeMeta),
      );
    }
    if (data.containsKey('is_custom')) {
      context.handle(
        _isCustomMeta,
        isCustom.isAcceptableOrUnknown(data['is_custom']!, _isCustomMeta),
      );
    } else if (isInserting) {
      context.missing(_isCustomMeta);
    }
    if (data.containsKey('library_exercise_id')) {
      context.handle(
        _libraryExerciseIdMeta,
        libraryExerciseId.isAcceptableOrUnknown(
          data['library_exercise_id']!,
          _libraryExerciseIdMeta,
        ),
      );
    }
    if (data.containsKey('custom_exercise_id')) {
      context.handle(
        _customExerciseIdMeta,
        customExerciseId.isAcceptableOrUnknown(
          data['custom_exercise_id']!,
          _customExerciseIdMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('is_superset')) {
      context.handle(
        _isSupersetMeta,
        isSuperset.isAcceptableOrUnknown(data['is_superset']!, _isSupersetMeta),
      );
    } else if (isInserting) {
      context.missing(_isSupersetMeta);
    }
    if (data.containsKey('is_in_superset')) {
      context.handle(
        _isInSupersetMeta,
        isInSuperset.isAcceptableOrUnknown(
          data['is_in_superset']!,
          _isInSupersetMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_isInSupersetMeta);
    }
    if (data.containsKey('superset_id')) {
      context.handle(
        _supersetIdMeta,
        supersetId.isAcceptableOrUnknown(data['superset_id']!, _supersetIdMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('supersedes_id')) {
      context.handle(
        _supersedesIdMeta,
        supersedesId.isAcceptableOrUnknown(
          data['supersedes_id']!,
          _supersedesIdMeta,
        ),
      );
    }
    if (data.containsKey('rpe')) {
      context.handle(
        _rpeMeta,
        rpe.isAcceptableOrUnknown(data['rpe']!, _rpeMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id, userId};
  @override
  RoutineExercise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoutineExercise(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      routineId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}routine_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      parameters: $RoutineExercisesTable.$converterparametersn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}parameters'],
        ),
      ),
      sets: $RoutineExercisesTable.$convertersetsn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sets'],
        ),
      ),
      primaryMuscleGroup: $RoutineExercisesTable.$converterprimaryMuscleGroupn
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.string,
              data['${effectivePrefix}primary_muscle_group'],
            ),
          ),
      secondaryMuscleGroups: $RoutineExercisesTable
          .$convertersecondaryMuscleGroupsn
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.string,
              data['${effectivePrefix}secondary_muscle_groups'],
            ),
          ),
      restTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rest_time'],
      ),
      isCustom: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_custom'],
      )!,
      libraryExerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}library_exercise_id'],
      ),
      customExerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_exercise_id'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      isSuperset: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_superset'],
      )!,
      isInSuperset: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_in_superset'],
      )!,
      supersetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}superset_id'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      supersedesId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supersedes_id'],
      ),
      rpe: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rpe'],
      ),
      progression: $RoutineExercisesTable.$converterprogressionn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}progression'],
        ),
      ),
      equipment: $RoutineExercisesTable.$converterequipmentn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}equipment'],
        ),
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
    );
  }

  @override
  $RoutineExercisesTable createAlias(String alias) {
    return $RoutineExercisesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<GTSetParameters, String, String>
  $converterparameters = const EnumNameConverter<GTSetParameters>(
    GTSetParameters.values,
  );
  static JsonTypeConverter2<GTSetParameters?, String?, String?>
  $converterparametersn = JsonTypeConverter2.asNullable($converterparameters);
  static TypeConverter<List<GTSet>, String> $convertersets =
      const GTSetListConverter();
  static TypeConverter<List<GTSet>?, String?> $convertersetsn =
      NullAwareTypeConverter.wrap($convertersets);
  static JsonTypeConverter2<GTMuscleGroup, String, String>
  $converterprimaryMuscleGroup = const EnumNameConverter<GTMuscleGroup>(
    GTMuscleGroup.values,
  );
  static JsonTypeConverter2<GTMuscleGroup?, String?, String?>
  $converterprimaryMuscleGroupn = JsonTypeConverter2.asNullable(
    $converterprimaryMuscleGroup,
  );
  static TypeConverter<Set<GTMuscleGroup>, String>
  $convertersecondaryMuscleGroups = const MuscleGroupSetConverter();
  static TypeConverter<Set<GTMuscleGroup>?, String?>
  $convertersecondaryMuscleGroupsn = NullAwareTypeConverter.wrap(
    $convertersecondaryMuscleGroups,
  );
  static TypeConverter<ExerciseProgression, String> $converterprogression =
      const ExerciseProgressionConverter();
  static TypeConverter<ExerciseProgression?, String?> $converterprogressionn =
      NullAwareTypeConverter.wrap($converterprogression);
  static JsonTypeConverter2<GTGymEquipment, String, String>
  $converterequipment = const EnumNameConverter<GTGymEquipment>(
    GTGymEquipment.values,
  );
  static JsonTypeConverter2<GTGymEquipment?, String?, String?>
  $converterequipmentn = JsonTypeConverter2.asNullable($converterequipment);
}

class RoutineExercisesCompanion extends UpdateCompanion<RoutineExercise> {
  final Value<String> id;
  final Value<String> routineId;
  final Value<String> name;
  final Value<GTSetParameters?> parameters;
  final Value<List<GTSet>?> sets;
  final Value<GTMuscleGroup?> primaryMuscleGroup;
  final Value<Set<GTMuscleGroup>?> secondaryMuscleGroups;
  final Value<int?> restTime;
  final Value<bool> isCustom;
  final Value<String?> libraryExerciseId;
  final Value<String?> customExerciseId;
  final Value<String?> notes;
  final Value<bool> isSuperset;
  final Value<bool> isInSuperset;
  final Value<String?> supersetId;
  final Value<int> sortOrder;
  final Value<String?> supersedesId;
  final Value<int?> rpe;
  final Value<ExerciseProgression?> progression;
  final Value<GTGymEquipment?> equipment;
  final Value<DateTime> updatedAt;
  final Value<bool> deleted;
  final Value<String?> userId;
  final Value<int> rowid;
  const RoutineExercisesCompanion({
    this.id = const Value.absent(),
    this.routineId = const Value.absent(),
    this.name = const Value.absent(),
    this.parameters = const Value.absent(),
    this.sets = const Value.absent(),
    this.primaryMuscleGroup = const Value.absent(),
    this.secondaryMuscleGroups = const Value.absent(),
    this.restTime = const Value.absent(),
    this.isCustom = const Value.absent(),
    this.libraryExerciseId = const Value.absent(),
    this.customExerciseId = const Value.absent(),
    this.notes = const Value.absent(),
    this.isSuperset = const Value.absent(),
    this.isInSuperset = const Value.absent(),
    this.supersetId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.supersedesId = const Value.absent(),
    this.rpe = const Value.absent(),
    this.progression = const Value.absent(),
    this.equipment = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.userId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoutineExercisesCompanion.insert({
    this.id = const Value.absent(),
    required String routineId,
    required String name,
    this.parameters = const Value.absent(),
    this.sets = const Value.absent(),
    this.primaryMuscleGroup = const Value.absent(),
    this.secondaryMuscleGroups = const Value.absent(),
    this.restTime = const Value.absent(),
    required bool isCustom,
    this.libraryExerciseId = const Value.absent(),
    this.customExerciseId = const Value.absent(),
    this.notes = const Value.absent(),
    required bool isSuperset,
    required bool isInSuperset,
    this.supersetId = const Value.absent(),
    required int sortOrder,
    this.supersedesId = const Value.absent(),
    this.rpe = const Value.absent(),
    this.progression = const Value.absent(),
    this.equipment = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.userId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : routineId = Value(routineId),
       name = Value(name),
       isCustom = Value(isCustom),
       isSuperset = Value(isSuperset),
       isInSuperset = Value(isInSuperset),
       sortOrder = Value(sortOrder);
  static Insertable<RoutineExercise> custom({
    Expression<String>? id,
    Expression<String>? routineId,
    Expression<String>? name,
    Expression<String>? parameters,
    Expression<String>? sets,
    Expression<String>? primaryMuscleGroup,
    Expression<String>? secondaryMuscleGroups,
    Expression<int>? restTime,
    Expression<bool>? isCustom,
    Expression<String>? libraryExerciseId,
    Expression<String>? customExerciseId,
    Expression<String>? notes,
    Expression<bool>? isSuperset,
    Expression<bool>? isInSuperset,
    Expression<String>? supersetId,
    Expression<int>? sortOrder,
    Expression<String>? supersedesId,
    Expression<int>? rpe,
    Expression<String>? progression,
    Expression<String>? equipment,
    Expression<DateTime>? updatedAt,
    Expression<bool>? deleted,
    Expression<String>? userId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (routineId != null) 'routine_id': routineId,
      if (name != null) 'name': name,
      if (parameters != null) 'parameters': parameters,
      if (sets != null) 'sets': sets,
      if (primaryMuscleGroup != null)
        'primary_muscle_group': primaryMuscleGroup,
      if (secondaryMuscleGroups != null)
        'secondary_muscle_groups': secondaryMuscleGroups,
      if (restTime != null) 'rest_time': restTime,
      if (isCustom != null) 'is_custom': isCustom,
      if (libraryExerciseId != null) 'library_exercise_id': libraryExerciseId,
      if (customExerciseId != null) 'custom_exercise_id': customExerciseId,
      if (notes != null) 'notes': notes,
      if (isSuperset != null) 'is_superset': isSuperset,
      if (isInSuperset != null) 'is_in_superset': isInSuperset,
      if (supersetId != null) 'superset_id': supersetId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (supersedesId != null) 'supersedes_id': supersedesId,
      if (rpe != null) 'rpe': rpe,
      if (progression != null) 'progression': progression,
      if (equipment != null) 'equipment': equipment,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (userId != null) 'user_id': userId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoutineExercisesCompanion copyWith({
    Value<String>? id,
    Value<String>? routineId,
    Value<String>? name,
    Value<GTSetParameters?>? parameters,
    Value<List<GTSet>?>? sets,
    Value<GTMuscleGroup?>? primaryMuscleGroup,
    Value<Set<GTMuscleGroup>?>? secondaryMuscleGroups,
    Value<int?>? restTime,
    Value<bool>? isCustom,
    Value<String?>? libraryExerciseId,
    Value<String?>? customExerciseId,
    Value<String?>? notes,
    Value<bool>? isSuperset,
    Value<bool>? isInSuperset,
    Value<String?>? supersetId,
    Value<int>? sortOrder,
    Value<String?>? supersedesId,
    Value<int?>? rpe,
    Value<ExerciseProgression?>? progression,
    Value<GTGymEquipment?>? equipment,
    Value<DateTime>? updatedAt,
    Value<bool>? deleted,
    Value<String?>? userId,
    Value<int>? rowid,
  }) {
    return RoutineExercisesCompanion(
      id: id ?? this.id,
      routineId: routineId ?? this.routineId,
      name: name ?? this.name,
      parameters: parameters ?? this.parameters,
      sets: sets ?? this.sets,
      primaryMuscleGroup: primaryMuscleGroup ?? this.primaryMuscleGroup,
      secondaryMuscleGroups:
          secondaryMuscleGroups ?? this.secondaryMuscleGroups,
      restTime: restTime ?? this.restTime,
      isCustom: isCustom ?? this.isCustom,
      libraryExerciseId: libraryExerciseId ?? this.libraryExerciseId,
      customExerciseId: customExerciseId ?? this.customExerciseId,
      notes: notes ?? this.notes,
      isSuperset: isSuperset ?? this.isSuperset,
      isInSuperset: isInSuperset ?? this.isInSuperset,
      supersetId: supersetId ?? this.supersetId,
      sortOrder: sortOrder ?? this.sortOrder,
      supersedesId: supersedesId ?? this.supersedesId,
      rpe: rpe ?? this.rpe,
      progression: progression ?? this.progression,
      equipment: equipment ?? this.equipment,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      userId: userId ?? this.userId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (routineId.present) {
      map['routine_id'] = Variable<String>(routineId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (parameters.present) {
      map['parameters'] = Variable<String>(
        $RoutineExercisesTable.$converterparametersn.toSql(parameters.value),
      );
    }
    if (sets.present) {
      map['sets'] = Variable<String>(
        $RoutineExercisesTable.$convertersetsn.toSql(sets.value),
      );
    }
    if (primaryMuscleGroup.present) {
      map['primary_muscle_group'] = Variable<String>(
        $RoutineExercisesTable.$converterprimaryMuscleGroupn.toSql(
          primaryMuscleGroup.value,
        ),
      );
    }
    if (secondaryMuscleGroups.present) {
      map['secondary_muscle_groups'] = Variable<String>(
        $RoutineExercisesTable.$convertersecondaryMuscleGroupsn.toSql(
          secondaryMuscleGroups.value,
        ),
      );
    }
    if (restTime.present) {
      map['rest_time'] = Variable<int>(restTime.value);
    }
    if (isCustom.present) {
      map['is_custom'] = Variable<bool>(isCustom.value);
    }
    if (libraryExerciseId.present) {
      map['library_exercise_id'] = Variable<String>(libraryExerciseId.value);
    }
    if (customExerciseId.present) {
      map['custom_exercise_id'] = Variable<String>(customExerciseId.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isSuperset.present) {
      map['is_superset'] = Variable<bool>(isSuperset.value);
    }
    if (isInSuperset.present) {
      map['is_in_superset'] = Variable<bool>(isInSuperset.value);
    }
    if (supersetId.present) {
      map['superset_id'] = Variable<String>(supersetId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (supersedesId.present) {
      map['supersedes_id'] = Variable<String>(supersedesId.value);
    }
    if (rpe.present) {
      map['rpe'] = Variable<int>(rpe.value);
    }
    if (progression.present) {
      map['progression'] = Variable<String>(
        $RoutineExercisesTable.$converterprogressionn.toSql(progression.value),
      );
    }
    if (equipment.present) {
      map['equipment'] = Variable<String>(
        $RoutineExercisesTable.$converterequipmentn.toSql(equipment.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutineExercisesCompanion(')
          ..write('id: $id, ')
          ..write('routineId: $routineId, ')
          ..write('name: $name, ')
          ..write('parameters: $parameters, ')
          ..write('sets: $sets, ')
          ..write('primaryMuscleGroup: $primaryMuscleGroup, ')
          ..write('secondaryMuscleGroups: $secondaryMuscleGroups, ')
          ..write('restTime: $restTime, ')
          ..write('isCustom: $isCustom, ')
          ..write('libraryExerciseId: $libraryExerciseId, ')
          ..write('customExerciseId: $customExerciseId, ')
          ..write('notes: $notes, ')
          ..write('isSuperset: $isSuperset, ')
          ..write('isInSuperset: $isInSuperset, ')
          ..write('supersetId: $supersetId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('supersedesId: $supersedesId, ')
          ..write('rpe: $rpe, ')
          ..write('progression: $progression, ')
          ..write('equipment: $equipment, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('userId: $userId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PreferencesTable extends Preferences
    with TableInfo<$PreferencesTable, Preference> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PreferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _onboardingCompleteMeta =
      const VerificationMeta('onboardingComplete');
  @override
  late final GeneratedColumn<bool> onboardingComplete = GeneratedColumn<bool>(
    'onboarding_complete',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("onboarding_complete" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [data, onboardingComplete];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'preferences';
  @override
  VerificationContext validateIntegrity(
    Insertable<Preference> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('onboarding_complete')) {
      context.handle(
        _onboardingCompleteMeta,
        onboardingComplete.isAcceptableOrUnknown(
          data['onboarding_complete']!,
          _onboardingCompleteMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  Preference map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Preference(
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data'],
      )!,
      onboardingComplete: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}onboarding_complete'],
      )!,
    );
  }

  @override
  $PreferencesTable createAlias(String alias) {
    return $PreferencesTable(attachedDatabase, alias);
  }
}

class Preference extends DataClass implements Insertable<Preference> {
  final String data;
  final bool onboardingComplete;
  const Preference({required this.data, required this.onboardingComplete});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['data'] = Variable<String>(data);
    map['onboarding_complete'] = Variable<bool>(onboardingComplete);
    return map;
  }

  PreferencesCompanion toCompanion(bool nullToAbsent) {
    return PreferencesCompanion(
      data: Value(data),
      onboardingComplete: Value(onboardingComplete),
    );
  }

  factory Preference.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Preference(
      data: serializer.fromJson<String>(json['data']),
      onboardingComplete: serializer.fromJson<bool>(json['onboardingComplete']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'data': serializer.toJson<String>(data),
      'onboardingComplete': serializer.toJson<bool>(onboardingComplete),
    };
  }

  Preference copyWith({String? data, bool? onboardingComplete}) => Preference(
    data: data ?? this.data,
    onboardingComplete: onboardingComplete ?? this.onboardingComplete,
  );
  Preference copyWithCompanion(PreferencesCompanion data) {
    return Preference(
      data: data.data.present ? data.data.value : this.data,
      onboardingComplete: data.onboardingComplete.present
          ? data.onboardingComplete.value
          : this.onboardingComplete,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Preference(')
          ..write('data: $data, ')
          ..write('onboardingComplete: $onboardingComplete')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(data, onboardingComplete);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Preference &&
          other.data == this.data &&
          other.onboardingComplete == this.onboardingComplete);
}

class PreferencesCompanion extends UpdateCompanion<Preference> {
  final Value<String> data;
  final Value<bool> onboardingComplete;
  final Value<int> rowid;
  const PreferencesCompanion({
    this.data = const Value.absent(),
    this.onboardingComplete = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PreferencesCompanion.insert({
    required String data,
    this.onboardingComplete = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : data = Value(data);
  static Insertable<Preference> custom({
    Expression<String>? data,
    Expression<bool>? onboardingComplete,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (data != null) 'data': data,
      if (onboardingComplete != null) 'onboarding_complete': onboardingComplete,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PreferencesCompanion copyWith({
    Value<String>? data,
    Value<bool>? onboardingComplete,
    Value<int>? rowid,
  }) {
    return PreferencesCompanion(
      data: data ?? this.data,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (onboardingComplete.present) {
      map['onboarding_complete'] = Variable<bool>(onboardingComplete.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PreferencesCompanion(')
          ..write('data: $data, ')
          ..write('onboardingComplete: $onboardingComplete, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OngoingDataTable extends OngoingData
    with TableInfo<$OngoingDataTable, OngoingDatum> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OngoingDataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerMeta = const VerificationMeta('owner');
  @override
  late final GeneratedColumn<String> owner = GeneratedColumn<String>(
    'owner',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('legacy'),
  );
  @override
  List<GeneratedColumn> get $columns => [data, owner];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ongoing_data';
  @override
  VerificationContext validateIntegrity(
    Insertable<OngoingDatum> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('owner')) {
      context.handle(
        _ownerMeta,
        owner.isAcceptableOrUnknown(data['owner']!, _ownerMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {owner};
  @override
  OngoingDatum map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OngoingDatum(
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data'],
      )!,
      owner: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner'],
      )!,
    );
  }

  @override
  $OngoingDataTable createAlias(String alias) {
    return $OngoingDataTable(attachedDatabase, alias);
  }
}

class OngoingDatum extends DataClass implements Insertable<OngoingDatum> {
  final String data;
  final String owner;
  const OngoingDatum({required this.data, required this.owner});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['data'] = Variable<String>(data);
    map['owner'] = Variable<String>(owner);
    return map;
  }

  OngoingDataCompanion toCompanion(bool nullToAbsent) {
    return OngoingDataCompanion(data: Value(data), owner: Value(owner));
  }

  factory OngoingDatum.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OngoingDatum(
      data: serializer.fromJson<String>(json['data']),
      owner: serializer.fromJson<String>(json['owner']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'data': serializer.toJson<String>(data),
      'owner': serializer.toJson<String>(owner),
    };
  }

  OngoingDatum copyWith({String? data, String? owner}) =>
      OngoingDatum(data: data ?? this.data, owner: owner ?? this.owner);
  OngoingDatum copyWithCompanion(OngoingDataCompanion data) {
    return OngoingDatum(
      data: data.data.present ? data.data.value : this.data,
      owner: data.owner.present ? data.owner.value : this.owner,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OngoingDatum(')
          ..write('data: $data, ')
          ..write('owner: $owner')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(data, owner);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OngoingDatum &&
          other.data == this.data &&
          other.owner == this.owner);
}

class OngoingDataCompanion extends UpdateCompanion<OngoingDatum> {
  final Value<String> data;
  final Value<String> owner;
  final Value<int> rowid;
  const OngoingDataCompanion({
    this.data = const Value.absent(),
    this.owner = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OngoingDataCompanion.insert({
    required String data,
    this.owner = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : data = Value(data);
  static Insertable<OngoingDatum> custom({
    Expression<String>? data,
    Expression<String>? owner,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (data != null) 'data': data,
      if (owner != null) 'owner': owner,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OngoingDataCompanion copyWith({
    Value<String>? data,
    Value<String>? owner,
    Value<int>? rowid,
  }) {
    return OngoingDataCompanion(
      data: data ?? this.data,
      owner: owner ?? this.owner,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (owner.present) {
      map['owner'] = Variable<String>(owner.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OngoingDataCompanion(')
          ..write('data: $data, ')
          ..write('owner: $owner, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WeightMeasurementsTable extends WeightMeasurements
    with TableInfo<$WeightMeasurementsTable, WeightMeasurement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WeightMeasurementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: Constant(DateTime.fromMicrosecondsSinceEpoch(0, isUtc: true)),
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
    'weight',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeMeta = const VerificationMeta('time');
  @override
  late final GeneratedColumn<DateTime> time = GeneratedColumn<DateTime>(
    'time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Weights, String> weightUnit =
      GeneratedColumn<String>(
        'weight_unit',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Weights>($WeightMeasurementsTable.$converterweightUnit);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    updatedAt,
    deleted,
    weight,
    time,
    weightUnit,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'weight_measurements';
  @override
  VerificationContext validateIntegrity(
    Insertable<WeightMeasurement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('weight')) {
      context.handle(
        _weightMeta,
        weight.isAcceptableOrUnknown(data['weight']!, _weightMeta),
      );
    } else if (isInserting) {
      context.missing(_weightMeta);
    }
    if (data.containsKey('time')) {
      context.handle(
        _timeMeta,
        time.isAcceptableOrUnknown(data['time']!, _timeMeta),
      );
    } else if (isInserting) {
      context.missing(_timeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id, userId};
  @override
  WeightMeasurement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WeightMeasurement(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      weight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight'],
      )!,
      time: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}time'],
      )!,
      weightUnit: $WeightMeasurementsTable.$converterweightUnit.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}weight_unit'],
        )!,
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
    );
  }

  @override
  $WeightMeasurementsTable createAlias(String alias) {
    return $WeightMeasurementsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Weights, String, String> $converterweightUnit =
      const EnumNameConverter<Weights>(Weights.values);
}

class WeightMeasurementsCompanion extends UpdateCompanion<WeightMeasurement> {
  final Value<String> id;
  final Value<String?> userId;
  final Value<DateTime> updatedAt;
  final Value<bool> deleted;
  final Value<double> weight;
  final Value<DateTime> time;
  final Value<Weights> weightUnit;
  final Value<int> rowid;
  const WeightMeasurementsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.weight = const Value.absent(),
    this.time = const Value.absent(),
    this.weightUnit = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WeightMeasurementsCompanion.insert({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    required double weight,
    required DateTime time,
    required Weights weightUnit,
    this.rowid = const Value.absent(),
  }) : weight = Value(weight),
       time = Value(time),
       weightUnit = Value(weightUnit);
  static Insertable<WeightMeasurement> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<DateTime>? updatedAt,
    Expression<bool>? deleted,
    Expression<double>? weight,
    Expression<DateTime>? time,
    Expression<String>? weightUnit,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (weight != null) 'weight': weight,
      if (time != null) 'time': time,
      if (weightUnit != null) 'weight_unit': weightUnit,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WeightMeasurementsCompanion copyWith({
    Value<String>? id,
    Value<String?>? userId,
    Value<DateTime>? updatedAt,
    Value<bool>? deleted,
    Value<double>? weight,
    Value<DateTime>? time,
    Value<Weights>? weightUnit,
    Value<int>? rowid,
  }) {
    return WeightMeasurementsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      weight: weight ?? this.weight,
      time: time ?? this.time,
      weightUnit: weightUnit ?? this.weightUnit,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    if (time.present) {
      map['time'] = Variable<DateTime>(time.value);
    }
    if (weightUnit.present) {
      map['weight_unit'] = Variable<String>(
        $WeightMeasurementsTable.$converterweightUnit.toSql(weightUnit.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WeightMeasurementsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('weight: $weight, ')
          ..write('time: $time, ')
          ..write('weightUnit: $weightUnit, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BodyMeasurementsTable extends BodyMeasurements
    with TableInfo<$BodyMeasurementsTable, BodyMeasurement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BodyMeasurementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: Constant(DateTime.fromMicrosecondsSinceEpoch(0, isUtc: true)),
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<double> value = GeneratedColumn<double>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeMeta = const VerificationMeta('time');
  @override
  late final GeneratedColumn<DateTime> time = GeneratedColumn<DateTime>(
    'time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<BodyMeasurementPart, String>
  type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<BodyMeasurementPart>($BodyMeasurementsTable.$convertertype);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    updatedAt,
    deleted,
    value,
    time,
    type,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'body_measurements';
  @override
  VerificationContext validateIntegrity(
    Insertable<BodyMeasurement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('time')) {
      context.handle(
        _timeMeta,
        time.isAcceptableOrUnknown(data['time']!, _timeMeta),
      );
    } else if (isInserting) {
      context.missing(_timeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id, userId};
  @override
  BodyMeasurement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BodyMeasurement(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}value'],
      )!,
      time: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}time'],
      )!,
      type: $BodyMeasurementsTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
    );
  }

  @override
  $BodyMeasurementsTable createAlias(String alias) {
    return $BodyMeasurementsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<BodyMeasurementPart, String, String>
  $convertertype = const EnumNameConverter<BodyMeasurementPart>(
    BodyMeasurementPart.values,
  );
}

class BodyMeasurementsCompanion extends UpdateCompanion<BodyMeasurement> {
  final Value<String> id;
  final Value<String?> userId;
  final Value<DateTime> updatedAt;
  final Value<bool> deleted;
  final Value<double> value;
  final Value<DateTime> time;
  final Value<BodyMeasurementPart> type;
  final Value<int> rowid;
  const BodyMeasurementsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.value = const Value.absent(),
    this.time = const Value.absent(),
    this.type = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BodyMeasurementsCompanion.insert({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    required double value,
    required DateTime time,
    required BodyMeasurementPart type,
    this.rowid = const Value.absent(),
  }) : value = Value(value),
       time = Value(time),
       type = Value(type);
  static Insertable<BodyMeasurement> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<DateTime>? updatedAt,
    Expression<bool>? deleted,
    Expression<double>? value,
    Expression<DateTime>? time,
    Expression<String>? type,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (value != null) 'value': value,
      if (time != null) 'time': time,
      if (type != null) 'type': type,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BodyMeasurementsCompanion copyWith({
    Value<String>? id,
    Value<String?>? userId,
    Value<DateTime>? updatedAt,
    Value<bool>? deleted,
    Value<double>? value,
    Value<DateTime>? time,
    Value<BodyMeasurementPart>? type,
    Value<int>? rowid,
  }) {
    return BodyMeasurementsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      value: value ?? this.value,
      time: time ?? this.time,
      type: type ?? this.type,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (value.present) {
      map['value'] = Variable<double>(value.value);
    }
    if (time.present) {
      map['time'] = Variable<DateTime>(time.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $BodyMeasurementsTable.$convertertype.toSql(type.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BodyMeasurementsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('value: $value, ')
          ..write('time: $time, ')
          ..write('type: $type, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FoodsTable extends Foods with TableInfo<$FoodsTable, DBFood> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoodsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: Constant(DateTime.fromMicrosecondsSinceEpoch(0, isUtc: true)),
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _dateAddedMeta = const VerificationMeta(
    'dateAdded',
  );
  @override
  late final GeneratedColumn<DateTime> dateAdded = GeneratedColumn<DateTime>(
    'date_added',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _referenceDateMeta = const VerificationMeta(
    'referenceDate',
  );
  @override
  late final GeneratedColumn<DateTime> referenceDate =
      GeneratedColumn<DateTime>(
        'reference_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _jsonDataMeta = const VerificationMeta(
    'jsonData',
  );
  @override
  late final GeneratedColumn<String> jsonData = GeneratedColumn<String>(
    'json_data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    updatedAt,
    deleted,
    dateAdded,
    referenceDate,
    jsonData,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'foods';
  @override
  VerificationContext validateIntegrity(
    Insertable<DBFood> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('date_added')) {
      context.handle(
        _dateAddedMeta,
        dateAdded.isAcceptableOrUnknown(data['date_added']!, _dateAddedMeta),
      );
    } else if (isInserting) {
      context.missing(_dateAddedMeta);
    }
    if (data.containsKey('reference_date')) {
      context.handle(
        _referenceDateMeta,
        referenceDate.isAcceptableOrUnknown(
          data['reference_date']!,
          _referenceDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_referenceDateMeta);
    }
    if (data.containsKey('json_data')) {
      context.handle(
        _jsonDataMeta,
        jsonData.isAcceptableOrUnknown(data['json_data']!, _jsonDataMeta),
      );
    } else if (isInserting) {
      context.missing(_jsonDataMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id, userId};
  @override
  DBFood map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DBFood(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      dateAdded: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_added'],
      )!,
      referenceDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}reference_date'],
      )!,
      jsonData: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json_data'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
    );
  }

  @override
  $FoodsTable createAlias(String alias) {
    return $FoodsTable(attachedDatabase, alias);
  }
}

class FoodsCompanion extends UpdateCompanion<DBFood> {
  final Value<String> id;
  final Value<String?> userId;
  final Value<DateTime> updatedAt;
  final Value<bool> deleted;
  final Value<DateTime> dateAdded;
  final Value<DateTime> referenceDate;
  final Value<String> jsonData;
  final Value<int> rowid;
  const FoodsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.dateAdded = const Value.absent(),
    this.referenceDate = const Value.absent(),
    this.jsonData = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FoodsCompanion.insert({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    required DateTime dateAdded,
    required DateTime referenceDate,
    required String jsonData,
    this.rowid = const Value.absent(),
  }) : dateAdded = Value(dateAdded),
       referenceDate = Value(referenceDate),
       jsonData = Value(jsonData);
  static Insertable<DBFood> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<DateTime>? updatedAt,
    Expression<bool>? deleted,
    Expression<DateTime>? dateAdded,
    Expression<DateTime>? referenceDate,
    Expression<String>? jsonData,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (dateAdded != null) 'date_added': dateAdded,
      if (referenceDate != null) 'reference_date': referenceDate,
      if (jsonData != null) 'json_data': jsonData,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FoodsCompanion copyWith({
    Value<String>? id,
    Value<String?>? userId,
    Value<DateTime>? updatedAt,
    Value<bool>? deleted,
    Value<DateTime>? dateAdded,
    Value<DateTime>? referenceDate,
    Value<String>? jsonData,
    Value<int>? rowid,
  }) {
    return FoodsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      dateAdded: dateAdded ?? this.dateAdded,
      referenceDate: referenceDate ?? this.referenceDate,
      jsonData: jsonData ?? this.jsonData,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (dateAdded.present) {
      map['date_added'] = Variable<DateTime>(dateAdded.value);
    }
    if (referenceDate.present) {
      map['reference_date'] = Variable<DateTime>(referenceDate.value);
    }
    if (jsonData.present) {
      map['json_data'] = Variable<String>(jsonData.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FoodsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('dateAdded: $dateAdded, ')
          ..write('referenceDate: $referenceDate, ')
          ..write('jsonData: $jsonData, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NutritionGoalsTable extends NutritionGoals
    with TableInfo<$NutritionGoalsTable, DBNutritionGoal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NutritionGoalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: Constant(DateTime.fromMicrosecondsSinceEpoch(0, isUtc: true)),
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _referenceDateMeta = const VerificationMeta(
    'referenceDate',
  );
  @override
  late final GeneratedColumn<DateTime> referenceDate =
      GeneratedColumn<DateTime>(
        'reference_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _caloriesMeta = const VerificationMeta(
    'calories',
  );
  @override
  late final GeneratedColumn<double> calories = GeneratedColumn<double>(
    'calories',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fatMeta = const VerificationMeta('fat');
  @override
  late final GeneratedColumn<double> fat = GeneratedColumn<double>(
    'fat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _carbsMeta = const VerificationMeta('carbs');
  @override
  late final GeneratedColumn<double> carbs = GeneratedColumn<double>(
    'carbs',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _proteinMeta = const VerificationMeta(
    'protein',
  );
  @override
  late final GeneratedColumn<double> protein = GeneratedColumn<double>(
    'protein',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    updatedAt,
    deleted,
    referenceDate,
    calories,
    fat,
    carbs,
    protein,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'nutrition_goals';
  @override
  VerificationContext validateIntegrity(
    Insertable<DBNutritionGoal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('reference_date')) {
      context.handle(
        _referenceDateMeta,
        referenceDate.isAcceptableOrUnknown(
          data['reference_date']!,
          _referenceDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_referenceDateMeta);
    }
    if (data.containsKey('calories')) {
      context.handle(
        _caloriesMeta,
        calories.isAcceptableOrUnknown(data['calories']!, _caloriesMeta),
      );
    } else if (isInserting) {
      context.missing(_caloriesMeta);
    }
    if (data.containsKey('fat')) {
      context.handle(
        _fatMeta,
        fat.isAcceptableOrUnknown(data['fat']!, _fatMeta),
      );
    } else if (isInserting) {
      context.missing(_fatMeta);
    }
    if (data.containsKey('carbs')) {
      context.handle(
        _carbsMeta,
        carbs.isAcceptableOrUnknown(data['carbs']!, _carbsMeta),
      );
    } else if (isInserting) {
      context.missing(_carbsMeta);
    }
    if (data.containsKey('protein')) {
      context.handle(
        _proteinMeta,
        protein.isAcceptableOrUnknown(data['protein']!, _proteinMeta),
      );
    } else if (isInserting) {
      context.missing(_proteinMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id, userId};
  @override
  DBNutritionGoal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DBNutritionGoal(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      referenceDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}reference_date'],
      )!,
      calories: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}calories'],
      )!,
      fat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat'],
      )!,
      carbs: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carbs'],
      )!,
      protein: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
    );
  }

  @override
  $NutritionGoalsTable createAlias(String alias) {
    return $NutritionGoalsTable(attachedDatabase, alias);
  }
}

class NutritionGoalsCompanion extends UpdateCompanion<DBNutritionGoal> {
  final Value<String> id;
  final Value<String?> userId;
  final Value<DateTime> updatedAt;
  final Value<bool> deleted;
  final Value<DateTime> referenceDate;
  final Value<double> calories;
  final Value<double> fat;
  final Value<double> carbs;
  final Value<double> protein;
  final Value<int> rowid;
  const NutritionGoalsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.referenceDate = const Value.absent(),
    this.calories = const Value.absent(),
    this.fat = const Value.absent(),
    this.carbs = const Value.absent(),
    this.protein = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NutritionGoalsCompanion.insert({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    required DateTime referenceDate,
    required double calories,
    required double fat,
    required double carbs,
    required double protein,
    this.rowid = const Value.absent(),
  }) : referenceDate = Value(referenceDate),
       calories = Value(calories),
       fat = Value(fat),
       carbs = Value(carbs),
       protein = Value(protein);
  static Insertable<DBNutritionGoal> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<DateTime>? updatedAt,
    Expression<bool>? deleted,
    Expression<DateTime>? referenceDate,
    Expression<double>? calories,
    Expression<double>? fat,
    Expression<double>? carbs,
    Expression<double>? protein,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (referenceDate != null) 'reference_date': referenceDate,
      if (calories != null) 'calories': calories,
      if (fat != null) 'fat': fat,
      if (carbs != null) 'carbs': carbs,
      if (protein != null) 'protein': protein,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NutritionGoalsCompanion copyWith({
    Value<String>? id,
    Value<String?>? userId,
    Value<DateTime>? updatedAt,
    Value<bool>? deleted,
    Value<DateTime>? referenceDate,
    Value<double>? calories,
    Value<double>? fat,
    Value<double>? carbs,
    Value<double>? protein,
    Value<int>? rowid,
  }) {
    return NutritionGoalsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      referenceDate: referenceDate ?? this.referenceDate,
      calories: calories ?? this.calories,
      fat: fat ?? this.fat,
      carbs: carbs ?? this.carbs,
      protein: protein ?? this.protein,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (referenceDate.present) {
      map['reference_date'] = Variable<DateTime>(referenceDate.value);
    }
    if (calories.present) {
      map['calories'] = Variable<double>(calories.value);
    }
    if (fat.present) {
      map['fat'] = Variable<double>(fat.value);
    }
    if (carbs.present) {
      map['carbs'] = Variable<double>(carbs.value);
    }
    if (protein.present) {
      map['protein'] = Variable<double>(protein.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NutritionGoalsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('referenceDate: $referenceDate, ')
          ..write('calories: $calories, ')
          ..write('fat: $fat, ')
          ..write('carbs: $carbs, ')
          ..write('protein: $protein, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomBarcodeFoodsTable extends CustomBarcodeFoods
    with TableInfo<$CustomBarcodeFoodsTable, DBCustomBarcodeFood> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomBarcodeFoodsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'barcode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: Constant(DateTime.fromMicrosecondsSinceEpoch(0, isUtc: true)),
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _jsonDataMeta = const VerificationMeta(
    'jsonData',
  );
  @override
  late final GeneratedColumn<String> jsonData = GeneratedColumn<String>(
    'json_data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    updatedAt,
    deleted,
    jsonData,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_barcode_foods';
  @override
  VerificationContext validateIntegrity(
    Insertable<DBCustomBarcodeFood> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('barcode')) {
      context.handle(
        _idMeta,
        id.isAcceptableOrUnknown(data['barcode']!, _idMeta),
      );
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('json_data')) {
      context.handle(
        _jsonDataMeta,
        jsonData.isAcceptableOrUnknown(data['json_data']!, _jsonDataMeta),
      );
    } else if (isInserting) {
      context.missing(_jsonDataMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id, userId};
  @override
  DBCustomBarcodeFood map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DBCustomBarcodeFood(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode'],
      )!,
      jsonData: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json_data'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
    );
  }

  @override
  $CustomBarcodeFoodsTable createAlias(String alias) {
    return $CustomBarcodeFoodsTable(attachedDatabase, alias);
  }
}

class CustomBarcodeFoodsCompanion extends UpdateCompanion<DBCustomBarcodeFood> {
  final Value<String> id;
  final Value<String?> userId;
  final Value<DateTime> updatedAt;
  final Value<bool> deleted;
  final Value<String> jsonData;
  final Value<int> rowid;
  const CustomBarcodeFoodsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.jsonData = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomBarcodeFoodsCompanion.insert({
    required String id,
    this.userId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    required String jsonData,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       jsonData = Value(jsonData);
  static Insertable<DBCustomBarcodeFood> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<DateTime>? updatedAt,
    Expression<bool>? deleted,
    Expression<String>? jsonData,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'barcode': id,
      if (userId != null) 'user_id': userId,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (jsonData != null) 'json_data': jsonData,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomBarcodeFoodsCompanion copyWith({
    Value<String>? id,
    Value<String?>? userId,
    Value<DateTime>? updatedAt,
    Value<bool>? deleted,
    Value<String>? jsonData,
    Value<int>? rowid,
  }) {
    return CustomBarcodeFoodsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      jsonData: jsonData ?? this.jsonData,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['barcode'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (jsonData.present) {
      map['json_data'] = Variable<String>(jsonData.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomBarcodeFoodsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('jsonData: $jsonData, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FavoriteFoodsTable extends FavoriteFoods
    with TableInfo<$FavoriteFoodsTable, DBFavoriteFood> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FavoriteFoodsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'food_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES foods (id)',
    ),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: Constant(DateTime.fromMicrosecondsSinceEpoch(0, isUtc: true)),
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, userId, updatedAt, deleted];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'favorite_foods';
  @override
  VerificationContext validateIntegrity(
    Insertable<DBFavoriteFood> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('food_id')) {
      context.handle(
        _idMeta,
        id.isAcceptableOrUnknown(data['food_id']!, _idMeta),
      );
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  DBFavoriteFood map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DBFavoriteFood(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}food_id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
    );
  }

  @override
  $FavoriteFoodsTable createAlias(String alias) {
    return $FavoriteFoodsTable(attachedDatabase, alias);
  }
}

class FavoriteFoodsCompanion extends UpdateCompanion<DBFavoriteFood> {
  final Value<String> id;
  final Value<String?> userId;
  final Value<DateTime> updatedAt;
  final Value<bool> deleted;
  final Value<int> rowid;
  const FavoriteFoodsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FavoriteFoodsCompanion.insert({
    required String id,
    this.userId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<DBFavoriteFood> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<DateTime>? updatedAt,
    Expression<bool>? deleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'food_id': id,
      if (userId != null) 'user_id': userId,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FavoriteFoodsCompanion copyWith({
    Value<String>? id,
    Value<String?>? userId,
    Value<DateTime>? updatedAt,
    Value<bool>? deleted,
    Value<int>? rowid,
  }) {
    return FavoriteFoodsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['food_id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteFoodsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NutritionCategoriesTable extends NutritionCategories
    with TableInfo<$NutritionCategoriesTable, DBNutritionCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NutritionCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: Constant(DateTime.fromMicrosecondsSinceEpoch(0, isUtc: true)),
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _referenceDateMeta = const VerificationMeta(
    'referenceDate',
  );
  @override
  late final GeneratedColumn<DateTime> referenceDate =
      GeneratedColumn<DateTime>(
        'reference_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _jsonDataMeta = const VerificationMeta(
    'jsonData',
  );
  @override
  late final GeneratedColumn<String> jsonData = GeneratedColumn<String>(
    'json_data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    updatedAt,
    deleted,
    referenceDate,
    jsonData,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'nutrition_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<DBNutritionCategory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('reference_date')) {
      context.handle(
        _referenceDateMeta,
        referenceDate.isAcceptableOrUnknown(
          data['reference_date']!,
          _referenceDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_referenceDateMeta);
    }
    if (data.containsKey('json_data')) {
      context.handle(
        _jsonDataMeta,
        jsonData.isAcceptableOrUnknown(data['json_data']!, _jsonDataMeta),
      );
    } else if (isInserting) {
      context.missing(_jsonDataMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, id};
  @override
  DBNutritionCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DBNutritionCategory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      ),
      referenceDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}reference_date'],
      )!,
      jsonData: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json_data'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
    );
  }

  @override
  $NutritionCategoriesTable createAlias(String alias) {
    return $NutritionCategoriesTable(attachedDatabase, alias);
  }
}

class NutritionCategoriesCompanion
    extends UpdateCompanion<DBNutritionCategory> {
  final Value<String?> id;
  final Value<String?> userId;
  final Value<DateTime> updatedAt;
  final Value<bool> deleted;
  final Value<DateTime> referenceDate;
  final Value<String> jsonData;
  final Value<int> rowid;
  const NutritionCategoriesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.referenceDate = const Value.absent(),
    this.jsonData = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NutritionCategoriesCompanion.insert({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    required DateTime referenceDate,
    required String jsonData,
    this.rowid = const Value.absent(),
  }) : referenceDate = Value(referenceDate),
       jsonData = Value(jsonData);
  static Insertable<DBNutritionCategory> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<DateTime>? updatedAt,
    Expression<bool>? deleted,
    Expression<DateTime>? referenceDate,
    Expression<String>? jsonData,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (referenceDate != null) 'reference_date': referenceDate,
      if (jsonData != null) 'json_data': jsonData,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NutritionCategoriesCompanion copyWith({
    Value<String?>? id,
    Value<String?>? userId,
    Value<DateTime>? updatedAt,
    Value<bool>? deleted,
    Value<DateTime>? referenceDate,
    Value<String>? jsonData,
    Value<int>? rowid,
  }) {
    return NutritionCategoriesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      referenceDate: referenceDate ?? this.referenceDate,
      jsonData: jsonData ?? this.jsonData,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (referenceDate.present) {
      map['reference_date'] = Variable<DateTime>(referenceDate.value);
    }
    if (jsonData.present) {
      map['json_data'] = Variable<String>(jsonData.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NutritionCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('referenceDate: $referenceDate, ')
          ..write('jsonData: $jsonData, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AchievementsTable extends Achievements
    with TableInfo<$AchievementsTable, AchievementCompletion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AchievementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    generatedAs: GeneratedAs(
      achievementID + Constant("_") + level.cast(),
      true,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _achievementIDMeta = const VerificationMeta(
    'achievementID',
  );
  @override
  late final GeneratedColumn<String> achievementID = GeneratedColumn<String>(
    'achievement_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<int> level = GeneratedColumn<int>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    updatedAt,
    deleted,
    achievementID,
    level,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'achievements_v2';
  @override
  VerificationContext validateIntegrity(
    Insertable<AchievementCompletion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('achievement_id')) {
      context.handle(
        _achievementIDMeta,
        achievementID.isAcceptableOrUnknown(
          data['achievement_id']!,
          _achievementIDMeta,
        ),
      );
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    } else if (isInserting) {
      context.missing(_levelMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {achievementID, level, userId};
  @override
  AchievementCompletion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AchievementCompletion(
      achievementID: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}achievement_id'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}level'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
    );
  }

  @override
  $AchievementsTable createAlias(String alias) {
    return $AchievementsTable(attachedDatabase, alias);
  }
}

class AchievementsCompanion extends UpdateCompanion<AchievementCompletion> {
  final Value<String?> userId;
  final Value<DateTime> updatedAt;
  final Value<bool> deleted;
  final Value<String> achievementID;
  final Value<int> level;
  final Value<DateTime> completedAt;
  final Value<int> rowid;
  const AchievementsCompanion({
    this.userId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.achievementID = const Value.absent(),
    this.level = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AchievementsCompanion.insert({
    this.userId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.achievementID = const Value.absent(),
    required int level,
    required DateTime completedAt,
    this.rowid = const Value.absent(),
  }) : level = Value(level),
       completedAt = Value(completedAt);
  static Insertable<AchievementCompletion> custom({
    Expression<String>? userId,
    Expression<DateTime>? updatedAt,
    Expression<bool>? deleted,
    Expression<String>? achievementID,
    Expression<int>? level,
    Expression<DateTime>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deleted != null) 'deleted': deleted,
      if (achievementID != null) 'achievement_id': achievementID,
      if (level != null) 'level': level,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AchievementsCompanion copyWith({
    Value<String?>? userId,
    Value<DateTime>? updatedAt,
    Value<bool>? deleted,
    Value<String>? achievementID,
    Value<int>? level,
    Value<DateTime>? completedAt,
    Value<int>? rowid,
  }) {
    return AchievementsCompanion(
      userId: userId ?? this.userId,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      achievementID: achievementID ?? this.achievementID,
      level: level ?? this.level,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (achievementID.present) {
      map['achievement_id'] = Variable<String>(achievementID.value);
    }
    if (level.present) {
      map['level'] = Variable<int>(level.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AchievementsCompanion(')
          ..write('userId: $userId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deleted: $deleted, ')
          ..write('achievementID: $achievementID, ')
          ..write('level: $level, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncOutboxTable extends SyncOutbox
    with TableInfo<$SyncOutboxTable, SyncOutboxData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncOutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sequenceMeta = const VerificationMeta(
    'sequence',
  );
  @override
  late final GeneratedColumn<int> sequence = GeneratedColumn<int>(
    'sequence',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _operationIdMeta = const VerificationMeta(
    'operationId',
  );
  @override
  late final GeneratedColumn<String> operationId = GeneratedColumn<String>(
    'operation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerMeta = const VerificationMeta('owner');
  @override
  late final GeneratedColumn<String> owner = GeneratedColumn<String>(
    'owner',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
    'entity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordIdMeta = const VerificationMeta(
    'recordId',
  );
  @override
  late final GeneratedColumn<String> recordId = GeneratedColumn<String>(
    'record_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baseRevisionMeta = const VerificationMeta(
    'baseRevision',
  );
  @override
  late final GeneratedColumn<int> baseRevision = GeneratedColumn<int>(
    'base_revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _errorMeta = const VerificationMeta('error');
  @override
  late final GeneratedColumn<String> error = GeneratedColumn<String>(
    'error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _blockedMeta = const VerificationMeta(
    'blocked',
  );
  @override
  late final GeneratedColumn<bool> blocked = GeneratedColumn<bool>(
    'blocked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("blocked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    sequence,
    operationId,
    owner,
    entity,
    recordId,
    baseRevision,
    payload,
    attempts,
    error,
    blocked,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_outbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncOutboxData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sequence')) {
      context.handle(
        _sequenceMeta,
        sequence.isAcceptableOrUnknown(data['sequence']!, _sequenceMeta),
      );
    }
    if (data.containsKey('operation_id')) {
      context.handle(
        _operationIdMeta,
        operationId.isAcceptableOrUnknown(
          data['operation_id']!,
          _operationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_operationIdMeta);
    }
    if (data.containsKey('owner')) {
      context.handle(
        _ownerMeta,
        owner.isAcceptableOrUnknown(data['owner']!, _ownerMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerMeta);
    }
    if (data.containsKey('entity')) {
      context.handle(
        _entityMeta,
        entity.isAcceptableOrUnknown(data['entity']!, _entityMeta),
      );
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('record_id')) {
      context.handle(
        _recordIdMeta,
        recordId.isAcceptableOrUnknown(data['record_id']!, _recordIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recordIdMeta);
    }
    if (data.containsKey('base_revision')) {
      context.handle(
        _baseRevisionMeta,
        baseRevision.isAcceptableOrUnknown(
          data['base_revision']!,
          _baseRevisionMeta,
        ),
      );
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('error')) {
      context.handle(
        _errorMeta,
        error.isAcceptableOrUnknown(data['error']!, _errorMeta),
      );
    }
    if (data.containsKey('blocked')) {
      context.handle(
        _blockedMeta,
        blocked.isAcceptableOrUnknown(data['blocked']!, _blockedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sequence};
  @override
  SyncOutboxData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncOutboxData(
      sequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sequence'],
      )!,
      operationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation_id'],
      )!,
      owner: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner'],
      )!,
      entity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity'],
      )!,
      recordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_id'],
      )!,
      baseRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}base_revision'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      error: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error'],
      ),
      blocked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}blocked'],
      )!,
    );
  }

  @override
  $SyncOutboxTable createAlias(String alias) {
    return $SyncOutboxTable(attachedDatabase, alias);
  }
}

class SyncOutboxData extends DataClass implements Insertable<SyncOutboxData> {
  final int sequence;
  final String operationId;
  final String owner;
  final String entity;
  final String recordId;
  final int baseRevision;
  final String payload;
  final int attempts;
  final String? error;
  final bool blocked;
  const SyncOutboxData({
    required this.sequence,
    required this.operationId,
    required this.owner,
    required this.entity,
    required this.recordId,
    required this.baseRevision,
    required this.payload,
    required this.attempts,
    this.error,
    required this.blocked,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sequence'] = Variable<int>(sequence);
    map['operation_id'] = Variable<String>(operationId);
    map['owner'] = Variable<String>(owner);
    map['entity'] = Variable<String>(entity);
    map['record_id'] = Variable<String>(recordId);
    map['base_revision'] = Variable<int>(baseRevision);
    map['payload'] = Variable<String>(payload);
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || error != null) {
      map['error'] = Variable<String>(error);
    }
    map['blocked'] = Variable<bool>(blocked);
    return map;
  }

  SyncOutboxCompanion toCompanion(bool nullToAbsent) {
    return SyncOutboxCompanion(
      sequence: Value(sequence),
      operationId: Value(operationId),
      owner: Value(owner),
      entity: Value(entity),
      recordId: Value(recordId),
      baseRevision: Value(baseRevision),
      payload: Value(payload),
      attempts: Value(attempts),
      error: error == null && nullToAbsent
          ? const Value.absent()
          : Value(error),
      blocked: Value(blocked),
    );
  }

  factory SyncOutboxData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncOutboxData(
      sequence: serializer.fromJson<int>(json['sequence']),
      operationId: serializer.fromJson<String>(json['operationId']),
      owner: serializer.fromJson<String>(json['owner']),
      entity: serializer.fromJson<String>(json['entity']),
      recordId: serializer.fromJson<String>(json['recordId']),
      baseRevision: serializer.fromJson<int>(json['baseRevision']),
      payload: serializer.fromJson<String>(json['payload']),
      attempts: serializer.fromJson<int>(json['attempts']),
      error: serializer.fromJson<String?>(json['error']),
      blocked: serializer.fromJson<bool>(json['blocked']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sequence': serializer.toJson<int>(sequence),
      'operationId': serializer.toJson<String>(operationId),
      'owner': serializer.toJson<String>(owner),
      'entity': serializer.toJson<String>(entity),
      'recordId': serializer.toJson<String>(recordId),
      'baseRevision': serializer.toJson<int>(baseRevision),
      'payload': serializer.toJson<String>(payload),
      'attempts': serializer.toJson<int>(attempts),
      'error': serializer.toJson<String?>(error),
      'blocked': serializer.toJson<bool>(blocked),
    };
  }

  SyncOutboxData copyWith({
    int? sequence,
    String? operationId,
    String? owner,
    String? entity,
    String? recordId,
    int? baseRevision,
    String? payload,
    int? attempts,
    Value<String?> error = const Value.absent(),
    bool? blocked,
  }) => SyncOutboxData(
    sequence: sequence ?? this.sequence,
    operationId: operationId ?? this.operationId,
    owner: owner ?? this.owner,
    entity: entity ?? this.entity,
    recordId: recordId ?? this.recordId,
    baseRevision: baseRevision ?? this.baseRevision,
    payload: payload ?? this.payload,
    attempts: attempts ?? this.attempts,
    error: error.present ? error.value : this.error,
    blocked: blocked ?? this.blocked,
  );
  SyncOutboxData copyWithCompanion(SyncOutboxCompanion data) {
    return SyncOutboxData(
      sequence: data.sequence.present ? data.sequence.value : this.sequence,
      operationId: data.operationId.present
          ? data.operationId.value
          : this.operationId,
      owner: data.owner.present ? data.owner.value : this.owner,
      entity: data.entity.present ? data.entity.value : this.entity,
      recordId: data.recordId.present ? data.recordId.value : this.recordId,
      baseRevision: data.baseRevision.present
          ? data.baseRevision.value
          : this.baseRevision,
      payload: data.payload.present ? data.payload.value : this.payload,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      error: data.error.present ? data.error.value : this.error,
      blocked: data.blocked.present ? data.blocked.value : this.blocked,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxData(')
          ..write('sequence: $sequence, ')
          ..write('operationId: $operationId, ')
          ..write('owner: $owner, ')
          ..write('entity: $entity, ')
          ..write('recordId: $recordId, ')
          ..write('baseRevision: $baseRevision, ')
          ..write('payload: $payload, ')
          ..write('attempts: $attempts, ')
          ..write('error: $error, ')
          ..write('blocked: $blocked')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    sequence,
    operationId,
    owner,
    entity,
    recordId,
    baseRevision,
    payload,
    attempts,
    error,
    blocked,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncOutboxData &&
          other.sequence == this.sequence &&
          other.operationId == this.operationId &&
          other.owner == this.owner &&
          other.entity == this.entity &&
          other.recordId == this.recordId &&
          other.baseRevision == this.baseRevision &&
          other.payload == this.payload &&
          other.attempts == this.attempts &&
          other.error == this.error &&
          other.blocked == this.blocked);
}

class SyncOutboxCompanion extends UpdateCompanion<SyncOutboxData> {
  final Value<int> sequence;
  final Value<String> operationId;
  final Value<String> owner;
  final Value<String> entity;
  final Value<String> recordId;
  final Value<int> baseRevision;
  final Value<String> payload;
  final Value<int> attempts;
  final Value<String?> error;
  final Value<bool> blocked;
  const SyncOutboxCompanion({
    this.sequence = const Value.absent(),
    this.operationId = const Value.absent(),
    this.owner = const Value.absent(),
    this.entity = const Value.absent(),
    this.recordId = const Value.absent(),
    this.baseRevision = const Value.absent(),
    this.payload = const Value.absent(),
    this.attempts = const Value.absent(),
    this.error = const Value.absent(),
    this.blocked = const Value.absent(),
  });
  SyncOutboxCompanion.insert({
    this.sequence = const Value.absent(),
    required String operationId,
    required String owner,
    required String entity,
    required String recordId,
    this.baseRevision = const Value.absent(),
    required String payload,
    this.attempts = const Value.absent(),
    this.error = const Value.absent(),
    this.blocked = const Value.absent(),
  }) : operationId = Value(operationId),
       owner = Value(owner),
       entity = Value(entity),
       recordId = Value(recordId),
       payload = Value(payload);
  static Insertable<SyncOutboxData> custom({
    Expression<int>? sequence,
    Expression<String>? operationId,
    Expression<String>? owner,
    Expression<String>? entity,
    Expression<String>? recordId,
    Expression<int>? baseRevision,
    Expression<String>? payload,
    Expression<int>? attempts,
    Expression<String>? error,
    Expression<bool>? blocked,
  }) {
    return RawValuesInsertable({
      if (sequence != null) 'sequence': sequence,
      if (operationId != null) 'operation_id': operationId,
      if (owner != null) 'owner': owner,
      if (entity != null) 'entity': entity,
      if (recordId != null) 'record_id': recordId,
      if (baseRevision != null) 'base_revision': baseRevision,
      if (payload != null) 'payload': payload,
      if (attempts != null) 'attempts': attempts,
      if (error != null) 'error': error,
      if (blocked != null) 'blocked': blocked,
    });
  }

  SyncOutboxCompanion copyWith({
    Value<int>? sequence,
    Value<String>? operationId,
    Value<String>? owner,
    Value<String>? entity,
    Value<String>? recordId,
    Value<int>? baseRevision,
    Value<String>? payload,
    Value<int>? attempts,
    Value<String?>? error,
    Value<bool>? blocked,
  }) {
    return SyncOutboxCompanion(
      sequence: sequence ?? this.sequence,
      operationId: operationId ?? this.operationId,
      owner: owner ?? this.owner,
      entity: entity ?? this.entity,
      recordId: recordId ?? this.recordId,
      baseRevision: baseRevision ?? this.baseRevision,
      payload: payload ?? this.payload,
      attempts: attempts ?? this.attempts,
      error: error ?? this.error,
      blocked: blocked ?? this.blocked,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sequence.present) {
      map['sequence'] = Variable<int>(sequence.value);
    }
    if (operationId.present) {
      map['operation_id'] = Variable<String>(operationId.value);
    }
    if (owner.present) {
      map['owner'] = Variable<String>(owner.value);
    }
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (recordId.present) {
      map['record_id'] = Variable<String>(recordId.value);
    }
    if (baseRevision.present) {
      map['base_revision'] = Variable<int>(baseRevision.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (error.present) {
      map['error'] = Variable<String>(error.value);
    }
    if (blocked.present) {
      map['blocked'] = Variable<bool>(blocked.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxCompanion(')
          ..write('sequence: $sequence, ')
          ..write('operationId: $operationId, ')
          ..write('owner: $owner, ')
          ..write('entity: $entity, ')
          ..write('recordId: $recordId, ')
          ..write('baseRevision: $baseRevision, ')
          ..write('payload: $payload, ')
          ..write('attempts: $attempts, ')
          ..write('error: $error, ')
          ..write('blocked: $blocked')
          ..write(')'))
        .toString();
  }
}

class $SyncMetadataTable extends SyncMetadata
    with TableInfo<$SyncMetadataTable, SyncMetadataData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncMetadataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ownerMeta = const VerificationMeta('owner');
  @override
  late final GeneratedColumn<String> owner = GeneratedColumn<String>(
    'owner',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
    'entity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordIdMeta = const VerificationMeta(
    'recordId',
  );
  @override
  late final GeneratedColumn<String> recordId = GeneratedColumn<String>(
    'record_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    owner,
    entity,
    recordId,
    revision,
    payload,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_metadata';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncMetadataData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('owner')) {
      context.handle(
        _ownerMeta,
        owner.isAcceptableOrUnknown(data['owner']!, _ownerMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerMeta);
    }
    if (data.containsKey('entity')) {
      context.handle(
        _entityMeta,
        entity.isAcceptableOrUnknown(data['entity']!, _entityMeta),
      );
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('record_id')) {
      context.handle(
        _recordIdMeta,
        recordId.isAcceptableOrUnknown(data['record_id']!, _recordIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recordIdMeta);
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    } else if (isInserting) {
      context.missing(_revisionMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {owner, entity, recordId};
  @override
  SyncMetadataData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncMetadataData(
      owner: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner'],
      )!,
      entity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity'],
      )!,
      recordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_id'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
    );
  }

  @override
  $SyncMetadataTable createAlias(String alias) {
    return $SyncMetadataTable(attachedDatabase, alias);
  }
}

class SyncMetadataData extends DataClass
    implements Insertable<SyncMetadataData> {
  final String owner;
  final String entity;
  final String recordId;
  final int revision;
  final String payload;
  const SyncMetadataData({
    required this.owner,
    required this.entity,
    required this.recordId,
    required this.revision,
    required this.payload,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['owner'] = Variable<String>(owner);
    map['entity'] = Variable<String>(entity);
    map['record_id'] = Variable<String>(recordId);
    map['revision'] = Variable<int>(revision);
    map['payload'] = Variable<String>(payload);
    return map;
  }

  SyncMetadataCompanion toCompanion(bool nullToAbsent) {
    return SyncMetadataCompanion(
      owner: Value(owner),
      entity: Value(entity),
      recordId: Value(recordId),
      revision: Value(revision),
      payload: Value(payload),
    );
  }

  factory SyncMetadataData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncMetadataData(
      owner: serializer.fromJson<String>(json['owner']),
      entity: serializer.fromJson<String>(json['entity']),
      recordId: serializer.fromJson<String>(json['recordId']),
      revision: serializer.fromJson<int>(json['revision']),
      payload: serializer.fromJson<String>(json['payload']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'owner': serializer.toJson<String>(owner),
      'entity': serializer.toJson<String>(entity),
      'recordId': serializer.toJson<String>(recordId),
      'revision': serializer.toJson<int>(revision),
      'payload': serializer.toJson<String>(payload),
    };
  }

  SyncMetadataData copyWith({
    String? owner,
    String? entity,
    String? recordId,
    int? revision,
    String? payload,
  }) => SyncMetadataData(
    owner: owner ?? this.owner,
    entity: entity ?? this.entity,
    recordId: recordId ?? this.recordId,
    revision: revision ?? this.revision,
    payload: payload ?? this.payload,
  );
  SyncMetadataData copyWithCompanion(SyncMetadataCompanion data) {
    return SyncMetadataData(
      owner: data.owner.present ? data.owner.value : this.owner,
      entity: data.entity.present ? data.entity.value : this.entity,
      recordId: data.recordId.present ? data.recordId.value : this.recordId,
      revision: data.revision.present ? data.revision.value : this.revision,
      payload: data.payload.present ? data.payload.value : this.payload,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetadataData(')
          ..write('owner: $owner, ')
          ..write('entity: $entity, ')
          ..write('recordId: $recordId, ')
          ..write('revision: $revision, ')
          ..write('payload: $payload')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(owner, entity, recordId, revision, payload);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncMetadataData &&
          other.owner == this.owner &&
          other.entity == this.entity &&
          other.recordId == this.recordId &&
          other.revision == this.revision &&
          other.payload == this.payload);
}

class SyncMetadataCompanion extends UpdateCompanion<SyncMetadataData> {
  final Value<String> owner;
  final Value<String> entity;
  final Value<String> recordId;
  final Value<int> revision;
  final Value<String> payload;
  final Value<int> rowid;
  const SyncMetadataCompanion({
    this.owner = const Value.absent(),
    this.entity = const Value.absent(),
    this.recordId = const Value.absent(),
    this.revision = const Value.absent(),
    this.payload = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncMetadataCompanion.insert({
    required String owner,
    required String entity,
    required String recordId,
    required int revision,
    required String payload,
    this.rowid = const Value.absent(),
  }) : owner = Value(owner),
       entity = Value(entity),
       recordId = Value(recordId),
       revision = Value(revision),
       payload = Value(payload);
  static Insertable<SyncMetadataData> custom({
    Expression<String>? owner,
    Expression<String>? entity,
    Expression<String>? recordId,
    Expression<int>? revision,
    Expression<String>? payload,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (owner != null) 'owner': owner,
      if (entity != null) 'entity': entity,
      if (recordId != null) 'record_id': recordId,
      if (revision != null) 'revision': revision,
      if (payload != null) 'payload': payload,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncMetadataCompanion copyWith({
    Value<String>? owner,
    Value<String>? entity,
    Value<String>? recordId,
    Value<int>? revision,
    Value<String>? payload,
    Value<int>? rowid,
  }) {
    return SyncMetadataCompanion(
      owner: owner ?? this.owner,
      entity: entity ?? this.entity,
      recordId: recordId ?? this.recordId,
      revision: revision ?? this.revision,
      payload: payload ?? this.payload,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (owner.present) {
      map['owner'] = Variable<String>(owner.value);
    }
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (recordId.present) {
      map['record_id'] = Variable<String>(recordId.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetadataCompanion(')
          ..write('owner: $owner, ')
          ..write('entity: $entity, ')
          ..write('recordId: $recordId, ')
          ..write('revision: $revision, ')
          ..write('payload: $payload, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncCursorsTable extends SyncCursors
    with TableInfo<$SyncCursorsTable, SyncCursor> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncCursorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ownerMeta = const VerificationMeta('owner');
  @override
  late final GeneratedColumn<String> owner = GeneratedColumn<String>(
    'owner',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cursorMeta = const VerificationMeta('cursor');
  @override
  late final GeneratedColumn<int> cursor = GeneratedColumn<int>(
    'cursor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _reconcileCursorMeta = const VerificationMeta(
    'reconcileCursor',
  );
  @override
  late final GeneratedColumn<int> reconcileCursor = GeneratedColumn<int>(
    'reconcile_cursor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _reconcileHorizonMeta = const VerificationMeta(
    'reconcileHorizon',
  );
  @override
  late final GeneratedColumn<int> reconcileHorizon = GeneratedColumn<int>(
    'reconcile_horizon',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bootstrappedMeta = const VerificationMeta(
    'bootstrapped',
  );
  @override
  late final GeneratedColumn<bool> bootstrapped = GeneratedColumn<bool>(
    'bootstrapped',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("bootstrapped" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _reconciledAtMeta = const VerificationMeta(
    'reconciledAt',
  );
  @override
  late final GeneratedColumn<DateTime> reconciledAt = GeneratedColumn<DateTime>(
    'reconciled_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    owner,
    cursor,
    reconcileCursor,
    reconcileHorizon,
    bootstrapped,
    reconciledAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_cursors';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncCursor> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('owner')) {
      context.handle(
        _ownerMeta,
        owner.isAcceptableOrUnknown(data['owner']!, _ownerMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerMeta);
    }
    if (data.containsKey('cursor')) {
      context.handle(
        _cursorMeta,
        cursor.isAcceptableOrUnknown(data['cursor']!, _cursorMeta),
      );
    }
    if (data.containsKey('reconcile_cursor')) {
      context.handle(
        _reconcileCursorMeta,
        reconcileCursor.isAcceptableOrUnknown(
          data['reconcile_cursor']!,
          _reconcileCursorMeta,
        ),
      );
    }
    if (data.containsKey('reconcile_horizon')) {
      context.handle(
        _reconcileHorizonMeta,
        reconcileHorizon.isAcceptableOrUnknown(
          data['reconcile_horizon']!,
          _reconcileHorizonMeta,
        ),
      );
    }
    if (data.containsKey('bootstrapped')) {
      context.handle(
        _bootstrappedMeta,
        bootstrapped.isAcceptableOrUnknown(
          data['bootstrapped']!,
          _bootstrappedMeta,
        ),
      );
    }
    if (data.containsKey('reconciled_at')) {
      context.handle(
        _reconciledAtMeta,
        reconciledAt.isAcceptableOrUnknown(
          data['reconciled_at']!,
          _reconciledAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {owner};
  @override
  SyncCursor map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncCursor(
      owner: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner'],
      )!,
      cursor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cursor'],
      )!,
      reconcileCursor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reconcile_cursor'],
      )!,
      reconcileHorizon: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reconcile_horizon'],
      ),
      bootstrapped: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}bootstrapped'],
      )!,
      reconciledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}reconciled_at'],
      ),
    );
  }

  @override
  $SyncCursorsTable createAlias(String alias) {
    return $SyncCursorsTable(attachedDatabase, alias);
  }
}

class SyncCursor extends DataClass implements Insertable<SyncCursor> {
  final String owner;
  final int cursor;
  final int reconcileCursor;
  final int? reconcileHorizon;
  final bool bootstrapped;
  final DateTime? reconciledAt;
  const SyncCursor({
    required this.owner,
    required this.cursor,
    required this.reconcileCursor,
    this.reconcileHorizon,
    required this.bootstrapped,
    this.reconciledAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['owner'] = Variable<String>(owner);
    map['cursor'] = Variable<int>(cursor);
    map['reconcile_cursor'] = Variable<int>(reconcileCursor);
    if (!nullToAbsent || reconcileHorizon != null) {
      map['reconcile_horizon'] = Variable<int>(reconcileHorizon);
    }
    map['bootstrapped'] = Variable<bool>(bootstrapped);
    if (!nullToAbsent || reconciledAt != null) {
      map['reconciled_at'] = Variable<DateTime>(reconciledAt);
    }
    return map;
  }

  SyncCursorsCompanion toCompanion(bool nullToAbsent) {
    return SyncCursorsCompanion(
      owner: Value(owner),
      cursor: Value(cursor),
      reconcileCursor: Value(reconcileCursor),
      reconcileHorizon: reconcileHorizon == null && nullToAbsent
          ? const Value.absent()
          : Value(reconcileHorizon),
      bootstrapped: Value(bootstrapped),
      reconciledAt: reconciledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(reconciledAt),
    );
  }

  factory SyncCursor.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncCursor(
      owner: serializer.fromJson<String>(json['owner']),
      cursor: serializer.fromJson<int>(json['cursor']),
      reconcileCursor: serializer.fromJson<int>(json['reconcileCursor']),
      reconcileHorizon: serializer.fromJson<int?>(json['reconcileHorizon']),
      bootstrapped: serializer.fromJson<bool>(json['bootstrapped']),
      reconciledAt: serializer.fromJson<DateTime?>(json['reconciledAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'owner': serializer.toJson<String>(owner),
      'cursor': serializer.toJson<int>(cursor),
      'reconcileCursor': serializer.toJson<int>(reconcileCursor),
      'reconcileHorizon': serializer.toJson<int?>(reconcileHorizon),
      'bootstrapped': serializer.toJson<bool>(bootstrapped),
      'reconciledAt': serializer.toJson<DateTime?>(reconciledAt),
    };
  }

  SyncCursor copyWith({
    String? owner,
    int? cursor,
    int? reconcileCursor,
    Value<int?> reconcileHorizon = const Value.absent(),
    bool? bootstrapped,
    Value<DateTime?> reconciledAt = const Value.absent(),
  }) => SyncCursor(
    owner: owner ?? this.owner,
    cursor: cursor ?? this.cursor,
    reconcileCursor: reconcileCursor ?? this.reconcileCursor,
    reconcileHorizon: reconcileHorizon.present
        ? reconcileHorizon.value
        : this.reconcileHorizon,
    bootstrapped: bootstrapped ?? this.bootstrapped,
    reconciledAt: reconciledAt.present ? reconciledAt.value : this.reconciledAt,
  );
  SyncCursor copyWithCompanion(SyncCursorsCompanion data) {
    return SyncCursor(
      owner: data.owner.present ? data.owner.value : this.owner,
      cursor: data.cursor.present ? data.cursor.value : this.cursor,
      reconcileCursor: data.reconcileCursor.present
          ? data.reconcileCursor.value
          : this.reconcileCursor,
      reconcileHorizon: data.reconcileHorizon.present
          ? data.reconcileHorizon.value
          : this.reconcileHorizon,
      bootstrapped: data.bootstrapped.present
          ? data.bootstrapped.value
          : this.bootstrapped,
      reconciledAt: data.reconciledAt.present
          ? data.reconciledAt.value
          : this.reconciledAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncCursor(')
          ..write('owner: $owner, ')
          ..write('cursor: $cursor, ')
          ..write('reconcileCursor: $reconcileCursor, ')
          ..write('reconcileHorizon: $reconcileHorizon, ')
          ..write('bootstrapped: $bootstrapped, ')
          ..write('reconciledAt: $reconciledAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    owner,
    cursor,
    reconcileCursor,
    reconcileHorizon,
    bootstrapped,
    reconciledAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncCursor &&
          other.owner == this.owner &&
          other.cursor == this.cursor &&
          other.reconcileCursor == this.reconcileCursor &&
          other.reconcileHorizon == this.reconcileHorizon &&
          other.bootstrapped == this.bootstrapped &&
          other.reconciledAt == this.reconciledAt);
}

class SyncCursorsCompanion extends UpdateCompanion<SyncCursor> {
  final Value<String> owner;
  final Value<int> cursor;
  final Value<int> reconcileCursor;
  final Value<int?> reconcileHorizon;
  final Value<bool> bootstrapped;
  final Value<DateTime?> reconciledAt;
  final Value<int> rowid;
  const SyncCursorsCompanion({
    this.owner = const Value.absent(),
    this.cursor = const Value.absent(),
    this.reconcileCursor = const Value.absent(),
    this.reconcileHorizon = const Value.absent(),
    this.bootstrapped = const Value.absent(),
    this.reconciledAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncCursorsCompanion.insert({
    required String owner,
    this.cursor = const Value.absent(),
    this.reconcileCursor = const Value.absent(),
    this.reconcileHorizon = const Value.absent(),
    this.bootstrapped = const Value.absent(),
    this.reconciledAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : owner = Value(owner);
  static Insertable<SyncCursor> custom({
    Expression<String>? owner,
    Expression<int>? cursor,
    Expression<int>? reconcileCursor,
    Expression<int>? reconcileHorizon,
    Expression<bool>? bootstrapped,
    Expression<DateTime>? reconciledAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (owner != null) 'owner': owner,
      if (cursor != null) 'cursor': cursor,
      if (reconcileCursor != null) 'reconcile_cursor': reconcileCursor,
      if (reconcileHorizon != null) 'reconcile_horizon': reconcileHorizon,
      if (bootstrapped != null) 'bootstrapped': bootstrapped,
      if (reconciledAt != null) 'reconciled_at': reconciledAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncCursorsCompanion copyWith({
    Value<String>? owner,
    Value<int>? cursor,
    Value<int>? reconcileCursor,
    Value<int?>? reconcileHorizon,
    Value<bool>? bootstrapped,
    Value<DateTime?>? reconciledAt,
    Value<int>? rowid,
  }) {
    return SyncCursorsCompanion(
      owner: owner ?? this.owner,
      cursor: cursor ?? this.cursor,
      reconcileCursor: reconcileCursor ?? this.reconcileCursor,
      reconcileHorizon: reconcileHorizon ?? this.reconcileHorizon,
      bootstrapped: bootstrapped ?? this.bootstrapped,
      reconciledAt: reconciledAt ?? this.reconciledAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (owner.present) {
      map['owner'] = Variable<String>(owner.value);
    }
    if (cursor.present) {
      map['cursor'] = Variable<int>(cursor.value);
    }
    if (reconcileCursor.present) {
      map['reconcile_cursor'] = Variable<int>(reconcileCursor.value);
    }
    if (reconcileHorizon.present) {
      map['reconcile_horizon'] = Variable<int>(reconcileHorizon.value);
    }
    if (bootstrapped.present) {
      map['bootstrapped'] = Variable<bool>(bootstrapped.value);
    }
    if (reconciledAt.present) {
      map['reconciled_at'] = Variable<DateTime>(reconciledAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncCursorsCompanion(')
          ..write('owner: $owner, ')
          ..write('cursor: $cursor, ')
          ..write('reconcileCursor: $reconcileCursor, ')
          ..write('reconcileHorizon: $reconcileHorizon, ')
          ..write('bootstrapped: $bootstrapped, ')
          ..write('reconciledAt: $reconciledAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncConflictsTable extends SyncConflicts
    with TableInfo<$SyncConflictsTable, SyncConflict> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncConflictsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _operationIdMeta = const VerificationMeta(
    'operationId',
  );
  @override
  late final GeneratedColumn<String> operationId = GeneratedColumn<String>(
    'operation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerMeta = const VerificationMeta('owner');
  @override
  late final GeneratedColumn<String> owner = GeneratedColumn<String>(
    'owner',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
    'entity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordIdMeta = const VerificationMeta(
    'recordId',
  );
  @override
  late final GeneratedColumn<String> recordId = GeneratedColumn<String>(
    'record_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localPayloadMeta = const VerificationMeta(
    'localPayload',
  );
  @override
  late final GeneratedColumn<String> localPayload = GeneratedColumn<String>(
    'local_payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverPayloadMeta = const VerificationMeta(
    'serverPayload',
  );
  @override
  late final GeneratedColumn<String> serverPayload = GeneratedColumn<String>(
    'server_payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverRevisionMeta = const VerificationMeta(
    'serverRevision',
  );
  @override
  late final GeneratedColumn<int> serverRevision = GeneratedColumn<int>(
    'server_revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resolvedMeta = const VerificationMeta(
    'resolved',
  );
  @override
  late final GeneratedColumn<bool> resolved = GeneratedColumn<bool>(
    'resolved',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("resolved" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    operationId,
    owner,
    entity,
    recordId,
    localPayload,
    serverPayload,
    serverRevision,
    resolved,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_conflicts';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncConflict> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('operation_id')) {
      context.handle(
        _operationIdMeta,
        operationId.isAcceptableOrUnknown(
          data['operation_id']!,
          _operationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_operationIdMeta);
    }
    if (data.containsKey('owner')) {
      context.handle(
        _ownerMeta,
        owner.isAcceptableOrUnknown(data['owner']!, _ownerMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerMeta);
    }
    if (data.containsKey('entity')) {
      context.handle(
        _entityMeta,
        entity.isAcceptableOrUnknown(data['entity']!, _entityMeta),
      );
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('record_id')) {
      context.handle(
        _recordIdMeta,
        recordId.isAcceptableOrUnknown(data['record_id']!, _recordIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recordIdMeta);
    }
    if (data.containsKey('local_payload')) {
      context.handle(
        _localPayloadMeta,
        localPayload.isAcceptableOrUnknown(
          data['local_payload']!,
          _localPayloadMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localPayloadMeta);
    }
    if (data.containsKey('server_payload')) {
      context.handle(
        _serverPayloadMeta,
        serverPayload.isAcceptableOrUnknown(
          data['server_payload']!,
          _serverPayloadMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_serverPayloadMeta);
    }
    if (data.containsKey('server_revision')) {
      context.handle(
        _serverRevisionMeta,
        serverRevision.isAcceptableOrUnknown(
          data['server_revision']!,
          _serverRevisionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_serverRevisionMeta);
    }
    if (data.containsKey('resolved')) {
      context.handle(
        _resolvedMeta,
        resolved.isAcceptableOrUnknown(data['resolved']!, _resolvedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {operationId};
  @override
  SyncConflict map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncConflict(
      operationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation_id'],
      )!,
      owner: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner'],
      )!,
      entity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity'],
      )!,
      recordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_id'],
      )!,
      localPayload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_payload'],
      )!,
      serverPayload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_payload'],
      )!,
      serverRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_revision'],
      )!,
      resolved: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}resolved'],
      )!,
    );
  }

  @override
  $SyncConflictsTable createAlias(String alias) {
    return $SyncConflictsTable(attachedDatabase, alias);
  }
}

class SyncConflict extends DataClass implements Insertable<SyncConflict> {
  final String operationId;
  final String owner;
  final String entity;
  final String recordId;
  final String localPayload;
  final String serverPayload;
  final int serverRevision;
  final bool resolved;
  const SyncConflict({
    required this.operationId,
    required this.owner,
    required this.entity,
    required this.recordId,
    required this.localPayload,
    required this.serverPayload,
    required this.serverRevision,
    required this.resolved,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['operation_id'] = Variable<String>(operationId);
    map['owner'] = Variable<String>(owner);
    map['entity'] = Variable<String>(entity);
    map['record_id'] = Variable<String>(recordId);
    map['local_payload'] = Variable<String>(localPayload);
    map['server_payload'] = Variable<String>(serverPayload);
    map['server_revision'] = Variable<int>(serverRevision);
    map['resolved'] = Variable<bool>(resolved);
    return map;
  }

  SyncConflictsCompanion toCompanion(bool nullToAbsent) {
    return SyncConflictsCompanion(
      operationId: Value(operationId),
      owner: Value(owner),
      entity: Value(entity),
      recordId: Value(recordId),
      localPayload: Value(localPayload),
      serverPayload: Value(serverPayload),
      serverRevision: Value(serverRevision),
      resolved: Value(resolved),
    );
  }

  factory SyncConflict.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncConflict(
      operationId: serializer.fromJson<String>(json['operationId']),
      owner: serializer.fromJson<String>(json['owner']),
      entity: serializer.fromJson<String>(json['entity']),
      recordId: serializer.fromJson<String>(json['recordId']),
      localPayload: serializer.fromJson<String>(json['localPayload']),
      serverPayload: serializer.fromJson<String>(json['serverPayload']),
      serverRevision: serializer.fromJson<int>(json['serverRevision']),
      resolved: serializer.fromJson<bool>(json['resolved']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'operationId': serializer.toJson<String>(operationId),
      'owner': serializer.toJson<String>(owner),
      'entity': serializer.toJson<String>(entity),
      'recordId': serializer.toJson<String>(recordId),
      'localPayload': serializer.toJson<String>(localPayload),
      'serverPayload': serializer.toJson<String>(serverPayload),
      'serverRevision': serializer.toJson<int>(serverRevision),
      'resolved': serializer.toJson<bool>(resolved),
    };
  }

  SyncConflict copyWith({
    String? operationId,
    String? owner,
    String? entity,
    String? recordId,
    String? localPayload,
    String? serverPayload,
    int? serverRevision,
    bool? resolved,
  }) => SyncConflict(
    operationId: operationId ?? this.operationId,
    owner: owner ?? this.owner,
    entity: entity ?? this.entity,
    recordId: recordId ?? this.recordId,
    localPayload: localPayload ?? this.localPayload,
    serverPayload: serverPayload ?? this.serverPayload,
    serverRevision: serverRevision ?? this.serverRevision,
    resolved: resolved ?? this.resolved,
  );
  SyncConflict copyWithCompanion(SyncConflictsCompanion data) {
    return SyncConflict(
      operationId: data.operationId.present
          ? data.operationId.value
          : this.operationId,
      owner: data.owner.present ? data.owner.value : this.owner,
      entity: data.entity.present ? data.entity.value : this.entity,
      recordId: data.recordId.present ? data.recordId.value : this.recordId,
      localPayload: data.localPayload.present
          ? data.localPayload.value
          : this.localPayload,
      serverPayload: data.serverPayload.present
          ? data.serverPayload.value
          : this.serverPayload,
      serverRevision: data.serverRevision.present
          ? data.serverRevision.value
          : this.serverRevision,
      resolved: data.resolved.present ? data.resolved.value : this.resolved,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncConflict(')
          ..write('operationId: $operationId, ')
          ..write('owner: $owner, ')
          ..write('entity: $entity, ')
          ..write('recordId: $recordId, ')
          ..write('localPayload: $localPayload, ')
          ..write('serverPayload: $serverPayload, ')
          ..write('serverRevision: $serverRevision, ')
          ..write('resolved: $resolved')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    operationId,
    owner,
    entity,
    recordId,
    localPayload,
    serverPayload,
    serverRevision,
    resolved,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncConflict &&
          other.operationId == this.operationId &&
          other.owner == this.owner &&
          other.entity == this.entity &&
          other.recordId == this.recordId &&
          other.localPayload == this.localPayload &&
          other.serverPayload == this.serverPayload &&
          other.serverRevision == this.serverRevision &&
          other.resolved == this.resolved);
}

class SyncConflictsCompanion extends UpdateCompanion<SyncConflict> {
  final Value<String> operationId;
  final Value<String> owner;
  final Value<String> entity;
  final Value<String> recordId;
  final Value<String> localPayload;
  final Value<String> serverPayload;
  final Value<int> serverRevision;
  final Value<bool> resolved;
  final Value<int> rowid;
  const SyncConflictsCompanion({
    this.operationId = const Value.absent(),
    this.owner = const Value.absent(),
    this.entity = const Value.absent(),
    this.recordId = const Value.absent(),
    this.localPayload = const Value.absent(),
    this.serverPayload = const Value.absent(),
    this.serverRevision = const Value.absent(),
    this.resolved = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncConflictsCompanion.insert({
    required String operationId,
    required String owner,
    required String entity,
    required String recordId,
    required String localPayload,
    required String serverPayload,
    required int serverRevision,
    this.resolved = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : operationId = Value(operationId),
       owner = Value(owner),
       entity = Value(entity),
       recordId = Value(recordId),
       localPayload = Value(localPayload),
       serverPayload = Value(serverPayload),
       serverRevision = Value(serverRevision);
  static Insertable<SyncConflict> custom({
    Expression<String>? operationId,
    Expression<String>? owner,
    Expression<String>? entity,
    Expression<String>? recordId,
    Expression<String>? localPayload,
    Expression<String>? serverPayload,
    Expression<int>? serverRevision,
    Expression<bool>? resolved,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (operationId != null) 'operation_id': operationId,
      if (owner != null) 'owner': owner,
      if (entity != null) 'entity': entity,
      if (recordId != null) 'record_id': recordId,
      if (localPayload != null) 'local_payload': localPayload,
      if (serverPayload != null) 'server_payload': serverPayload,
      if (serverRevision != null) 'server_revision': serverRevision,
      if (resolved != null) 'resolved': resolved,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncConflictsCompanion copyWith({
    Value<String>? operationId,
    Value<String>? owner,
    Value<String>? entity,
    Value<String>? recordId,
    Value<String>? localPayload,
    Value<String>? serverPayload,
    Value<int>? serverRevision,
    Value<bool>? resolved,
    Value<int>? rowid,
  }) {
    return SyncConflictsCompanion(
      operationId: operationId ?? this.operationId,
      owner: owner ?? this.owner,
      entity: entity ?? this.entity,
      recordId: recordId ?? this.recordId,
      localPayload: localPayload ?? this.localPayload,
      serverPayload: serverPayload ?? this.serverPayload,
      serverRevision: serverRevision ?? this.serverRevision,
      resolved: resolved ?? this.resolved,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (operationId.present) {
      map['operation_id'] = Variable<String>(operationId.value);
    }
    if (owner.present) {
      map['owner'] = Variable<String>(owner.value);
    }
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (recordId.present) {
      map['record_id'] = Variable<String>(recordId.value);
    }
    if (localPayload.present) {
      map['local_payload'] = Variable<String>(localPayload.value);
    }
    if (serverPayload.present) {
      map['server_payload'] = Variable<String>(serverPayload.value);
    }
    if (serverRevision.present) {
      map['server_revision'] = Variable<int>(serverRevision.value);
    }
    if (resolved.present) {
      map['resolved'] = Variable<bool>(resolved.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncConflictsCompanion(')
          ..write('operationId: $operationId, ')
          ..write('owner: $owner, ')
          ..write('entity: $entity, ')
          ..write('recordId: $recordId, ')
          ..write('localPayload: $localPayload, ')
          ..write('serverPayload: $serverPayload, ')
          ..write('serverRevision: $serverRevision, ')
          ..write('resolved: $resolved, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncContextTable extends SyncContext
    with TableInfo<$SyncContextTable, SyncContextData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncContextTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _receivingMeta = const VerificationMeta(
    'receiving',
  );
  @override
  late final GeneratedColumn<bool> receiving = GeneratedColumn<bool>(
    'receiving',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("receiving" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, receiving];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_context';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncContextData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('receiving')) {
      context.handle(
        _receivingMeta,
        receiving.isAcceptableOrUnknown(data['receiving']!, _receivingMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncContextData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncContextData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      receiving: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}receiving'],
      )!,
    );
  }

  @override
  $SyncContextTable createAlias(String alias) {
    return $SyncContextTable(attachedDatabase, alias);
  }
}

class SyncContextData extends DataClass implements Insertable<SyncContextData> {
  final int id;
  final bool receiving;
  const SyncContextData({required this.id, required this.receiving});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['receiving'] = Variable<bool>(receiving);
    return map;
  }

  SyncContextCompanion toCompanion(bool nullToAbsent) {
    return SyncContextCompanion(id: Value(id), receiving: Value(receiving));
  }

  factory SyncContextData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncContextData(
      id: serializer.fromJson<int>(json['id']),
      receiving: serializer.fromJson<bool>(json['receiving']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'receiving': serializer.toJson<bool>(receiving),
    };
  }

  SyncContextData copyWith({int? id, bool? receiving}) => SyncContextData(
    id: id ?? this.id,
    receiving: receiving ?? this.receiving,
  );
  SyncContextData copyWithCompanion(SyncContextCompanion data) {
    return SyncContextData(
      id: data.id.present ? data.id.value : this.id,
      receiving: data.receiving.present ? data.receiving.value : this.receiving,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncContextData(')
          ..write('id: $id, ')
          ..write('receiving: $receiving')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, receiving);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncContextData &&
          other.id == this.id &&
          other.receiving == this.receiving);
}

class SyncContextCompanion extends UpdateCompanion<SyncContextData> {
  final Value<int> id;
  final Value<bool> receiving;
  const SyncContextCompanion({
    this.id = const Value.absent(),
    this.receiving = const Value.absent(),
  });
  SyncContextCompanion.insert({
    this.id = const Value.absent(),
    this.receiving = const Value.absent(),
  });
  static Insertable<SyncContextData> custom({
    Expression<int>? id,
    Expression<bool>? receiving,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (receiving != null) 'receiving': receiving,
    });
  }

  SyncContextCompanion copyWith({Value<int>? id, Value<bool>? receiving}) {
    return SyncContextCompanion(
      id: id ?? this.id,
      receiving: receiving ?? this.receiving,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (receiving.present) {
      map['receiving'] = Variable<bool>(receiving.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncContextCompanion(')
          ..write('id: $id, ')
          ..write('receiving: $receiving')
          ..write(')'))
        .toString();
  }
}

class $SyncQuarantineTable extends SyncQuarantine
    with TableInfo<$SyncQuarantineTable, SyncQuarantineData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQuarantineTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _ownerMeta = const VerificationMeta('owner');
  @override
  late final GeneratedColumn<String> owner = GeneratedColumn<String>(
    'owner',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
    'entity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, owner, entity, payload, reason];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_quarantine';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncQuarantineData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('owner')) {
      context.handle(
        _ownerMeta,
        owner.isAcceptableOrUnknown(data['owner']!, _ownerMeta),
      );
    }
    if (data.containsKey('entity')) {
      context.handle(
        _entityMeta,
        entity.isAcceptableOrUnknown(data['entity']!, _entityMeta),
      );
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQuarantineData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQuarantineData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      owner: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner'],
      ),
      entity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
    );
  }

  @override
  $SyncQuarantineTable createAlias(String alias) {
    return $SyncQuarantineTable(attachedDatabase, alias);
  }
}

class SyncQuarantineData extends DataClass
    implements Insertable<SyncQuarantineData> {
  final int id;
  final String? owner;
  final String entity;
  final String payload;
  final String reason;
  const SyncQuarantineData({
    required this.id,
    this.owner,
    required this.entity,
    required this.payload,
    required this.reason,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || owner != null) {
      map['owner'] = Variable<String>(owner);
    }
    map['entity'] = Variable<String>(entity);
    map['payload'] = Variable<String>(payload);
    map['reason'] = Variable<String>(reason);
    return map;
  }

  SyncQuarantineCompanion toCompanion(bool nullToAbsent) {
    return SyncQuarantineCompanion(
      id: Value(id),
      owner: owner == null && nullToAbsent
          ? const Value.absent()
          : Value(owner),
      entity: Value(entity),
      payload: Value(payload),
      reason: Value(reason),
    );
  }

  factory SyncQuarantineData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQuarantineData(
      id: serializer.fromJson<int>(json['id']),
      owner: serializer.fromJson<String?>(json['owner']),
      entity: serializer.fromJson<String>(json['entity']),
      payload: serializer.fromJson<String>(json['payload']),
      reason: serializer.fromJson<String>(json['reason']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'owner': serializer.toJson<String?>(owner),
      'entity': serializer.toJson<String>(entity),
      'payload': serializer.toJson<String>(payload),
      'reason': serializer.toJson<String>(reason),
    };
  }

  SyncQuarantineData copyWith({
    int? id,
    Value<String?> owner = const Value.absent(),
    String? entity,
    String? payload,
    String? reason,
  }) => SyncQuarantineData(
    id: id ?? this.id,
    owner: owner.present ? owner.value : this.owner,
    entity: entity ?? this.entity,
    payload: payload ?? this.payload,
    reason: reason ?? this.reason,
  );
  SyncQuarantineData copyWithCompanion(SyncQuarantineCompanion data) {
    return SyncQuarantineData(
      id: data.id.present ? data.id.value : this.id,
      owner: data.owner.present ? data.owner.value : this.owner,
      entity: data.entity.present ? data.entity.value : this.entity,
      payload: data.payload.present ? data.payload.value : this.payload,
      reason: data.reason.present ? data.reason.value : this.reason,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQuarantineData(')
          ..write('id: $id, ')
          ..write('owner: $owner, ')
          ..write('entity: $entity, ')
          ..write('payload: $payload, ')
          ..write('reason: $reason')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, owner, entity, payload, reason);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQuarantineData &&
          other.id == this.id &&
          other.owner == this.owner &&
          other.entity == this.entity &&
          other.payload == this.payload &&
          other.reason == this.reason);
}

class SyncQuarantineCompanion extends UpdateCompanion<SyncQuarantineData> {
  final Value<int> id;
  final Value<String?> owner;
  final Value<String> entity;
  final Value<String> payload;
  final Value<String> reason;
  const SyncQuarantineCompanion({
    this.id = const Value.absent(),
    this.owner = const Value.absent(),
    this.entity = const Value.absent(),
    this.payload = const Value.absent(),
    this.reason = const Value.absent(),
  });
  SyncQuarantineCompanion.insert({
    this.id = const Value.absent(),
    this.owner = const Value.absent(),
    required String entity,
    required String payload,
    required String reason,
  }) : entity = Value(entity),
       payload = Value(payload),
       reason = Value(reason);
  static Insertable<SyncQuarantineData> custom({
    Expression<int>? id,
    Expression<String>? owner,
    Expression<String>? entity,
    Expression<String>? payload,
    Expression<String>? reason,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (owner != null) 'owner': owner,
      if (entity != null) 'entity': entity,
      if (payload != null) 'payload': payload,
      if (reason != null) 'reason': reason,
    });
  }

  SyncQuarantineCompanion copyWith({
    Value<int>? id,
    Value<String?>? owner,
    Value<String>? entity,
    Value<String>? payload,
    Value<String>? reason,
  }) {
    return SyncQuarantineCompanion(
      id: id ?? this.id,
      owner: owner ?? this.owner,
      entity: entity ?? this.entity,
      payload: payload ?? this.payload,
      reason: reason ?? this.reason,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (owner.present) {
      map['owner'] = Variable<String>(owner.value);
    }
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQuarantineCompanion(')
          ..write('id: $id, ')
          ..write('owner: $owner, ')
          ..write('entity: $entity, ')
          ..write('payload: $payload, ')
          ..write('reason: $reason')
          ..write(')'))
        .toString();
  }
}

abstract class _$GTDatabaseImpl extends GeneratedDatabase {
  _$GTDatabaseImpl(QueryExecutor e) : super(e);
  $GTDatabaseImplManager get managers => $GTDatabaseImplManager(this);
  late final $CustomExercisesTable customExercises = $CustomExercisesTable(
    this,
  );
  late final $RoutineFoldersTable routineFolders = $RoutineFoldersTable(this);
  late final $RoutinesTable routines = $RoutinesTable(this);
  late final $HistoryWorkoutsTable historyWorkouts = $HistoryWorkoutsTable(
    this,
  );
  late final $HistoryWorkoutExercisesTable historyWorkoutExercises =
      $HistoryWorkoutExercisesTable(this);
  late final $RoutineExercisesTable routineExercises = $RoutineExercisesTable(
    this,
  );
  late final $PreferencesTable preferences = $PreferencesTable(this);
  late final $OngoingDataTable ongoingData = $OngoingDataTable(this);
  late final $WeightMeasurementsTable weightMeasurements =
      $WeightMeasurementsTable(this);
  late final $BodyMeasurementsTable bodyMeasurements = $BodyMeasurementsTable(
    this,
  );
  late final $FoodsTable foods = $FoodsTable(this);
  late final $NutritionGoalsTable nutritionGoals = $NutritionGoalsTable(this);
  late final $CustomBarcodeFoodsTable customBarcodeFoods =
      $CustomBarcodeFoodsTable(this);
  late final $FavoriteFoodsTable favoriteFoods = $FavoriteFoodsTable(this);
  late final $NutritionCategoriesTable nutritionCategories =
      $NutritionCategoriesTable(this);
  late final $AchievementsTable achievements = $AchievementsTable(this);
  late final $SyncOutboxTable syncOutbox = $SyncOutboxTable(this);
  late final $SyncMetadataTable syncMetadata = $SyncMetadataTable(this);
  late final $SyncCursorsTable syncCursors = $SyncCursorsTable(this);
  late final $SyncConflictsTable syncConflicts = $SyncConflictsTable(this);
  late final $SyncContextTable syncContext = $SyncContextTable(this);
  late final $SyncQuarantineTable syncQuarantine = $SyncQuarantineTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    customExercises,
    routineFolders,
    routines,
    historyWorkouts,
    historyWorkoutExercises,
    routineExercises,
    preferences,
    ongoingData,
    weightMeasurements,
    bodyMeasurements,
    foods,
    nutritionGoals,
    customBarcodeFoods,
    favoriteFoods,
    nutritionCategories,
    achievements,
    syncOutbox,
    syncMetadata,
    syncCursors,
    syncConflicts,
    syncContext,
    syncQuarantine,
  ];
}

typedef $$CustomExercisesTableCreateCompanionBuilder =
    CustomExercisesCompanion Function({
      Value<String> id,
      Value<String?> userId,
      Value<DateTime> updatedAt,
      Value<bool> deleted,
      required String name,
      required GTSetParameters parameters,
      required GTMuscleGroup primaryMuscleGroup,
      required Set<GTMuscleGroup> secondaryMuscleGroups,
      Value<GTGymEquipment?> equipment,
      Value<int> rowid,
    });
typedef $$CustomExercisesTableUpdateCompanionBuilder =
    CustomExercisesCompanion Function({
      Value<String> id,
      Value<String?> userId,
      Value<DateTime> updatedAt,
      Value<bool> deleted,
      Value<String> name,
      Value<GTSetParameters> parameters,
      Value<GTMuscleGroup> primaryMuscleGroup,
      Value<Set<GTMuscleGroup>> secondaryMuscleGroups,
      Value<GTGymEquipment?> equipment,
      Value<int> rowid,
    });

final class $$CustomExercisesTableReferences
    extends
        BaseReferences<
          _$GTDatabaseImpl,
          $CustomExercisesTable,
          CustomExercise
        > {
  $$CustomExercisesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $HistoryWorkoutExercisesTable,
    List<HistoryWorkoutExercise>
  >
  _historyWorkoutExercisesRefsTable(
    _$GTDatabaseImpl db,
  ) => MultiTypedResultKey.fromTable(
    db.historyWorkoutExercises,
    aliasName:
        'custom_exercises__id__history_workout_exercises__custom_exercise_id',
  );

  $$HistoryWorkoutExercisesTableProcessedTableManager
  get historyWorkoutExercisesRefs {
    final manager =
        $$HistoryWorkoutExercisesTableTableManager(
          $_db,
          $_db.historyWorkoutExercises,
        ).filter(
          (f) => f.customExerciseId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _historyWorkoutExercisesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RoutineExercisesTable, List<RoutineExercise>>
  _routineExercisesRefsTable(_$GTDatabaseImpl db) =>
      MultiTypedResultKey.fromTable(
        db.routineExercises,
        aliasName:
            'custom_exercises__id__routine_exercises__custom_exercise_id',
      );

  $$RoutineExercisesTableProcessedTableManager get routineExercisesRefs {
    final manager =
        $$RoutineExercisesTableTableManager($_db, $_db.routineExercises).filter(
          (f) => f.customExerciseId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _routineExercisesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CustomExercisesTableFilterComposer
    extends Composer<_$GTDatabaseImpl, $CustomExercisesTable> {
  $$CustomExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<GTSetParameters, GTSetParameters, String>
  get parameters => $composableBuilder(
    column: $table.parameters,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<GTMuscleGroup, GTMuscleGroup, String>
  get primaryMuscleGroup => $composableBuilder(
    column: $table.primaryMuscleGroup,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<Set<GTMuscleGroup>, Set<GTMuscleGroup>, String>
  get secondaryMuscleGroups => $composableBuilder(
    column: $table.secondaryMuscleGroups,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<GTGymEquipment?, GTGymEquipment, String>
  get equipment => $composableBuilder(
    column: $table.equipment,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  Expression<bool> historyWorkoutExercisesRefs(
    Expression<bool> Function($$HistoryWorkoutExercisesTableFilterComposer f) f,
  ) {
    final $$HistoryWorkoutExercisesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.historyWorkoutExercises,
          getReferencedColumn: (t) => t.customExerciseId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$HistoryWorkoutExercisesTableFilterComposer(
                $db: $db,
                $table: $db.historyWorkoutExercises,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> routineExercisesRefs(
    Expression<bool> Function($$RoutineExercisesTableFilterComposer f) f,
  ) {
    final $$RoutineExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routineExercises,
      getReferencedColumn: (t) => t.customExerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineExercisesTableFilterComposer(
            $db: $db,
            $table: $db.routineExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CustomExercisesTableOrderingComposer
    extends Composer<_$GTDatabaseImpl, $CustomExercisesTable> {
  $$CustomExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parameters => $composableBuilder(
    column: $table.parameters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get primaryMuscleGroup => $composableBuilder(
    column: $table.primaryMuscleGroup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get secondaryMuscleGroups => $composableBuilder(
    column: $table.secondaryMuscleGroups,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get equipment => $composableBuilder(
    column: $table.equipment,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomExercisesTableAnnotationComposer
    extends Composer<_$GTDatabaseImpl, $CustomExercisesTable> {
  $$CustomExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<GTSetParameters, String> get parameters =>
      $composableBuilder(
        column: $table.parameters,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<GTMuscleGroup, String>
  get primaryMuscleGroup => $composableBuilder(
    column: $table.primaryMuscleGroup,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Set<GTMuscleGroup>, String>
  get secondaryMuscleGroups => $composableBuilder(
    column: $table.secondaryMuscleGroups,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<GTGymEquipment?, String> get equipment =>
      $composableBuilder(column: $table.equipment, builder: (column) => column);

  Expression<T> historyWorkoutExercisesRefs<T extends Object>(
    Expression<T> Function($$HistoryWorkoutExercisesTableAnnotationComposer a)
    f,
  ) {
    final $$HistoryWorkoutExercisesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.historyWorkoutExercises,
          getReferencedColumn: (t) => t.customExerciseId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$HistoryWorkoutExercisesTableAnnotationComposer(
                $db: $db,
                $table: $db.historyWorkoutExercises,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> routineExercisesRefs<T extends Object>(
    Expression<T> Function($$RoutineExercisesTableAnnotationComposer a) f,
  ) {
    final $$RoutineExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routineExercises,
      getReferencedColumn: (t) => t.customExerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.routineExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CustomExercisesTableTableManager
    extends
        RootTableManager<
          _$GTDatabaseImpl,
          $CustomExercisesTable,
          CustomExercise,
          $$CustomExercisesTableFilterComposer,
          $$CustomExercisesTableOrderingComposer,
          $$CustomExercisesTableAnnotationComposer,
          $$CustomExercisesTableCreateCompanionBuilder,
          $$CustomExercisesTableUpdateCompanionBuilder,
          (CustomExercise, $$CustomExercisesTableReferences),
          CustomExercise,
          PrefetchHooks Function({
            bool historyWorkoutExercisesRefs,
            bool routineExercisesRefs,
          })
        > {
  $$CustomExercisesTableTableManager(
    _$GTDatabaseImpl db,
    $CustomExercisesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<GTSetParameters> parameters = const Value.absent(),
                Value<GTMuscleGroup> primaryMuscleGroup = const Value.absent(),
                Value<Set<GTMuscleGroup>> secondaryMuscleGroups =
                    const Value.absent(),
                Value<GTGymEquipment?> equipment = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomExercisesCompanion(
                id: id,
                userId: userId,
                updatedAt: updatedAt,
                deleted: deleted,
                name: name,
                parameters: parameters,
                primaryMuscleGroup: primaryMuscleGroup,
                secondaryMuscleGroups: secondaryMuscleGroups,
                equipment: equipment,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                required String name,
                required GTSetParameters parameters,
                required GTMuscleGroup primaryMuscleGroup,
                required Set<GTMuscleGroup> secondaryMuscleGroups,
                Value<GTGymEquipment?> equipment = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomExercisesCompanion.insert(
                id: id,
                userId: userId,
                updatedAt: updatedAt,
                deleted: deleted,
                name: name,
                parameters: parameters,
                primaryMuscleGroup: primaryMuscleGroup,
                secondaryMuscleGroups: secondaryMuscleGroups,
                equipment: equipment,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CustomExercisesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                historyWorkoutExercisesRefs = false,
                routineExercisesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (historyWorkoutExercisesRefs) db.historyWorkoutExercises,
                    if (routineExercisesRefs) db.routineExercises,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (historyWorkoutExercisesRefs)
                        await $_getPrefetchedData<
                          CustomExercise,
                          $CustomExercisesTable,
                          HistoryWorkoutExercise
                        >(
                          currentTable: table,
                          referencedTable: $$CustomExercisesTableReferences
                              ._historyWorkoutExercisesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CustomExercisesTableReferences(
                                db,
                                table,
                                p0,
                              ).historyWorkoutExercisesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.customExerciseId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (routineExercisesRefs)
                        await $_getPrefetchedData<
                          CustomExercise,
                          $CustomExercisesTable,
                          RoutineExercise
                        >(
                          currentTable: table,
                          referencedTable: $$CustomExercisesTableReferences
                              ._routineExercisesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CustomExercisesTableReferences(
                                db,
                                table,
                                p0,
                              ).routineExercisesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.customExerciseId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CustomExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$GTDatabaseImpl,
      $CustomExercisesTable,
      CustomExercise,
      $$CustomExercisesTableFilterComposer,
      $$CustomExercisesTableOrderingComposer,
      $$CustomExercisesTableAnnotationComposer,
      $$CustomExercisesTableCreateCompanionBuilder,
      $$CustomExercisesTableUpdateCompanionBuilder,
      (CustomExercise, $$CustomExercisesTableReferences),
      CustomExercise,
      PrefetchHooks Function({
        bool historyWorkoutExercisesRefs,
        bool routineExercisesRefs,
      })
    >;
typedef $$RoutineFoldersTableCreateCompanionBuilder =
    RoutineFoldersCompanion Function({
      Value<String> id,
      Value<String?> userId,
      Value<DateTime?> updatedAt,
      Value<bool> deleted,
      required String name,
      required int sortOrder,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$RoutineFoldersTableUpdateCompanionBuilder =
    RoutineFoldersCompanion Function({
      Value<String> id,
      Value<String?> userId,
      Value<DateTime?> updatedAt,
      Value<bool> deleted,
      Value<String> name,
      Value<int> sortOrder,
      Value<String?> notes,
      Value<int> rowid,
    });

final class $$RoutineFoldersTableReferences
    extends
        BaseReferences<_$GTDatabaseImpl, $RoutineFoldersTable, RoutineFolder> {
  $$RoutineFoldersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$RoutinesTable, List<Routine>> _routinesRefsTable(
    _$GTDatabaseImpl db,
  ) => MultiTypedResultKey.fromTable(
    db.routines,
    aliasName: 'routine_folders__id__routines__folder_id',
  );

  $$RoutinesTableProcessedTableManager get routinesRefs {
    final manager = $$RoutinesTableTableManager(
      $_db,
      $_db.routines,
    ).filter((f) => f.folderId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_routinesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RoutineFoldersTableFilterComposer
    extends Composer<_$GTDatabaseImpl, $RoutineFoldersTable> {
  $$RoutineFoldersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> routinesRefs(
    Expression<bool> Function($$RoutinesTableFilterComposer f) f,
  ) {
    final $$RoutinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routines,
      getReferencedColumn: (t) => t.folderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutinesTableFilterComposer(
            $db: $db,
            $table: $db.routines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoutineFoldersTableOrderingComposer
    extends Composer<_$GTDatabaseImpl, $RoutineFoldersTable> {
  $$RoutineFoldersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RoutineFoldersTableAnnotationComposer
    extends Composer<_$GTDatabaseImpl, $RoutineFoldersTable> {
  $$RoutineFoldersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  Expression<T> routinesRefs<T extends Object>(
    Expression<T> Function($$RoutinesTableAnnotationComposer a) f,
  ) {
    final $$RoutinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routines,
      getReferencedColumn: (t) => t.folderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutinesTableAnnotationComposer(
            $db: $db,
            $table: $db.routines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoutineFoldersTableTableManager
    extends
        RootTableManager<
          _$GTDatabaseImpl,
          $RoutineFoldersTable,
          RoutineFolder,
          $$RoutineFoldersTableFilterComposer,
          $$RoutineFoldersTableOrderingComposer,
          $$RoutineFoldersTableAnnotationComposer,
          $$RoutineFoldersTableCreateCompanionBuilder,
          $$RoutineFoldersTableUpdateCompanionBuilder,
          (RoutineFolder, $$RoutineFoldersTableReferences),
          RoutineFolder,
          PrefetchHooks Function({bool routinesRefs})
        > {
  $$RoutineFoldersTableTableManager(
    _$GTDatabaseImpl db,
    $RoutineFoldersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoutineFoldersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoutineFoldersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoutineFoldersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoutineFoldersCompanion(
                id: id,
                userId: userId,
                updatedAt: updatedAt,
                deleted: deleted,
                name: name,
                sortOrder: sortOrder,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                required String name,
                required int sortOrder,
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoutineFoldersCompanion.insert(
                id: id,
                userId: userId,
                updatedAt: updatedAt,
                deleted: deleted,
                name: name,
                sortOrder: sortOrder,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RoutineFoldersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({routinesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (routinesRefs) db.routines],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (routinesRefs)
                    await $_getPrefetchedData<
                      RoutineFolder,
                      $RoutineFoldersTable,
                      Routine
                    >(
                      currentTable: table,
                      referencedTable: $$RoutineFoldersTableReferences
                          ._routinesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$RoutineFoldersTableReferences(
                            db,
                            table,
                            p0,
                          ).routinesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.folderId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$RoutineFoldersTableProcessedTableManager =
    ProcessedTableManager<
      _$GTDatabaseImpl,
      $RoutineFoldersTable,
      RoutineFolder,
      $$RoutineFoldersTableFilterComposer,
      $$RoutineFoldersTableOrderingComposer,
      $$RoutineFoldersTableAnnotationComposer,
      $$RoutineFoldersTableCreateCompanionBuilder,
      $$RoutineFoldersTableUpdateCompanionBuilder,
      (RoutineFolder, $$RoutineFoldersTableReferences),
      RoutineFolder,
      PrefetchHooks Function({bool routinesRefs})
    >;
typedef $$RoutinesTableCreateCompanionBuilder =
    RoutinesCompanion Function({
      Value<String> id,
      Value<String?> userId,
      Value<DateTime> updatedAt,
      Value<bool> deleted,
      required String name,
      required String infobox,
      required Weights weightUnit,
      required Distance distanceUnit,
      required int sortOrder,
      Value<String?> folderId,
      Value<int> rowid,
    });
typedef $$RoutinesTableUpdateCompanionBuilder =
    RoutinesCompanion Function({
      Value<String> id,
      Value<String?> userId,
      Value<DateTime> updatedAt,
      Value<bool> deleted,
      Value<String> name,
      Value<String> infobox,
      Value<Weights> weightUnit,
      Value<Distance> distanceUnit,
      Value<int> sortOrder,
      Value<String?> folderId,
      Value<int> rowid,
    });

final class $$RoutinesTableReferences
    extends BaseReferences<_$GTDatabaseImpl, $RoutinesTable, Routine> {
  $$RoutinesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RoutineFoldersTable _folderIdTable(_$GTDatabaseImpl db) =>
      db.routineFolders.createAlias('routines__folder_id__routine_folders__id');

  $$RoutineFoldersTableProcessedTableManager? get folderId {
    final $_column = $_itemColumn<String>('folder_id');
    if ($_column == null) return null;
    final manager = $$RoutineFoldersTableTableManager(
      $_db,
      $_db.routineFolders,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_folderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$HistoryWorkoutsTable, List<HistoryWorkout>>
  _historyWorkoutsRefsTable(_$GTDatabaseImpl db) =>
      MultiTypedResultKey.fromTable(
        db.historyWorkouts,
        aliasName: 'routines__id__history_workouts__parent_id',
      );

  $$HistoryWorkoutsTableProcessedTableManager get historyWorkoutsRefs {
    final manager = $$HistoryWorkoutsTableTableManager(
      $_db,
      $_db.historyWorkouts,
    ).filter((f) => f.parentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _historyWorkoutsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RoutineExercisesTable, List<RoutineExercise>>
  _routineExercisesRefsTable(_$GTDatabaseImpl db) =>
      MultiTypedResultKey.fromTable(
        db.routineExercises,
        aliasName: 'routines__id__routine_exercises__routine_id',
      );

  $$RoutineExercisesTableProcessedTableManager get routineExercisesRefs {
    final manager = $$RoutineExercisesTableTableManager(
      $_db,
      $_db.routineExercises,
    ).filter((f) => f.routineId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _routineExercisesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RoutinesTableFilterComposer
    extends Composer<_$GTDatabaseImpl, $RoutinesTable> {
  $$RoutinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get infobox => $composableBuilder(
    column: $table.infobox,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Weights, Weights, String> get weightUnit =>
      $composableBuilder(
        column: $table.weightUnit,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Distance, Distance, String> get distanceUnit =>
      $composableBuilder(
        column: $table.distanceUnit,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$RoutineFoldersTableFilterComposer get folderId {
    final $$RoutineFoldersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.folderId,
      referencedTable: $db.routineFolders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineFoldersTableFilterComposer(
            $db: $db,
            $table: $db.routineFolders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> historyWorkoutsRefs(
    Expression<bool> Function($$HistoryWorkoutsTableFilterComposer f) f,
  ) {
    final $$HistoryWorkoutsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.historyWorkouts,
      getReferencedColumn: (t) => t.parentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HistoryWorkoutsTableFilterComposer(
            $db: $db,
            $table: $db.historyWorkouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> routineExercisesRefs(
    Expression<bool> Function($$RoutineExercisesTableFilterComposer f) f,
  ) {
    final $$RoutineExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routineExercises,
      getReferencedColumn: (t) => t.routineId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineExercisesTableFilterComposer(
            $db: $db,
            $table: $db.routineExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoutinesTableOrderingComposer
    extends Composer<_$GTDatabaseImpl, $RoutinesTable> {
  $$RoutinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get infobox => $composableBuilder(
    column: $table.infobox,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weightUnit => $composableBuilder(
    column: $table.weightUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get distanceUnit => $composableBuilder(
    column: $table.distanceUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$RoutineFoldersTableOrderingComposer get folderId {
    final $$RoutineFoldersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.folderId,
      referencedTable: $db.routineFolders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineFoldersTableOrderingComposer(
            $db: $db,
            $table: $db.routineFolders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutinesTableAnnotationComposer
    extends Composer<_$GTDatabaseImpl, $RoutinesTable> {
  $$RoutinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get infobox =>
      $composableBuilder(column: $table.infobox, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Weights, String> get weightUnit =>
      $composableBuilder(
        column: $table.weightUnit,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Distance, String> get distanceUnit =>
      $composableBuilder(
        column: $table.distanceUnit,
        builder: (column) => column,
      );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$RoutineFoldersTableAnnotationComposer get folderId {
    final $$RoutineFoldersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.folderId,
      referencedTable: $db.routineFolders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineFoldersTableAnnotationComposer(
            $db: $db,
            $table: $db.routineFolders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> historyWorkoutsRefs<T extends Object>(
    Expression<T> Function($$HistoryWorkoutsTableAnnotationComposer a) f,
  ) {
    final $$HistoryWorkoutsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.historyWorkouts,
      getReferencedColumn: (t) => t.parentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HistoryWorkoutsTableAnnotationComposer(
            $db: $db,
            $table: $db.historyWorkouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> routineExercisesRefs<T extends Object>(
    Expression<T> Function($$RoutineExercisesTableAnnotationComposer a) f,
  ) {
    final $$RoutineExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routineExercises,
      getReferencedColumn: (t) => t.routineId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.routineExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoutinesTableTableManager
    extends
        RootTableManager<
          _$GTDatabaseImpl,
          $RoutinesTable,
          Routine,
          $$RoutinesTableFilterComposer,
          $$RoutinesTableOrderingComposer,
          $$RoutinesTableAnnotationComposer,
          $$RoutinesTableCreateCompanionBuilder,
          $$RoutinesTableUpdateCompanionBuilder,
          (Routine, $$RoutinesTableReferences),
          Routine,
          PrefetchHooks Function({
            bool folderId,
            bool historyWorkoutsRefs,
            bool routineExercisesRefs,
          })
        > {
  $$RoutinesTableTableManager(_$GTDatabaseImpl db, $RoutinesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoutinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoutinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoutinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> infobox = const Value.absent(),
                Value<Weights> weightUnit = const Value.absent(),
                Value<Distance> distanceUnit = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String?> folderId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoutinesCompanion(
                id: id,
                userId: userId,
                updatedAt: updatedAt,
                deleted: deleted,
                name: name,
                infobox: infobox,
                weightUnit: weightUnit,
                distanceUnit: distanceUnit,
                sortOrder: sortOrder,
                folderId: folderId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                required String name,
                required String infobox,
                required Weights weightUnit,
                required Distance distanceUnit,
                required int sortOrder,
                Value<String?> folderId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoutinesCompanion.insert(
                id: id,
                userId: userId,
                updatedAt: updatedAt,
                deleted: deleted,
                name: name,
                infobox: infobox,
                weightUnit: weightUnit,
                distanceUnit: distanceUnit,
                sortOrder: sortOrder,
                folderId: folderId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RoutinesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                folderId = false,
                historyWorkoutsRefs = false,
                routineExercisesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (historyWorkoutsRefs) db.historyWorkouts,
                    if (routineExercisesRefs) db.routineExercises,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (folderId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.folderId,
                                    referencedTable: $$RoutinesTableReferences
                                        ._folderIdTable(db),
                                    referencedColumn: $$RoutinesTableReferences
                                        ._folderIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (historyWorkoutsRefs)
                        await $_getPrefetchedData<
                          Routine,
                          $RoutinesTable,
                          HistoryWorkout
                        >(
                          currentTable: table,
                          referencedTable: $$RoutinesTableReferences
                              ._historyWorkoutsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RoutinesTableReferences(
                                db,
                                table,
                                p0,
                              ).historyWorkoutsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.parentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (routineExercisesRefs)
                        await $_getPrefetchedData<
                          Routine,
                          $RoutinesTable,
                          RoutineExercise
                        >(
                          currentTable: table,
                          referencedTable: $$RoutinesTableReferences
                              ._routineExercisesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RoutinesTableReferences(
                                db,
                                table,
                                p0,
                              ).routineExercisesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.routineId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$RoutinesTableProcessedTableManager =
    ProcessedTableManager<
      _$GTDatabaseImpl,
      $RoutinesTable,
      Routine,
      $$RoutinesTableFilterComposer,
      $$RoutinesTableOrderingComposer,
      $$RoutinesTableAnnotationComposer,
      $$RoutinesTableCreateCompanionBuilder,
      $$RoutinesTableUpdateCompanionBuilder,
      (Routine, $$RoutinesTableReferences),
      Routine,
      PrefetchHooks Function({
        bool folderId,
        bool historyWorkoutsRefs,
        bool routineExercisesRefs,
      })
    >;
typedef $$HistoryWorkoutsTableCreateCompanionBuilder =
    HistoryWorkoutsCompanion Function({
      Value<String> id,
      Value<String?> userId,
      Value<DateTime> updatedAt,
      Value<bool> deleted,
      Value<String> visibility,
      Value<String?> publicationManifest,
      required String name,
      Value<String?> infobox,
      required int duration,
      required DateTime startingDate,
      Value<String?> parentId,
      Value<String?> completedBy,
      Value<String?> completes,
      required Weights weightUnit,
      required Distance distanceUnit,
      Value<int> rowid,
    });
typedef $$HistoryWorkoutsTableUpdateCompanionBuilder =
    HistoryWorkoutsCompanion Function({
      Value<String> id,
      Value<String?> userId,
      Value<DateTime> updatedAt,
      Value<bool> deleted,
      Value<String> visibility,
      Value<String?> publicationManifest,
      Value<String> name,
      Value<String?> infobox,
      Value<int> duration,
      Value<DateTime> startingDate,
      Value<String?> parentId,
      Value<String?> completedBy,
      Value<String?> completes,
      Value<Weights> weightUnit,
      Value<Distance> distanceUnit,
      Value<int> rowid,
    });

final class $$HistoryWorkoutsTableReferences
    extends
        BaseReferences<
          _$GTDatabaseImpl,
          $HistoryWorkoutsTable,
          HistoryWorkout
        > {
  $$HistoryWorkoutsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $RoutinesTable _parentIdTable(_$GTDatabaseImpl db) =>
      db.routines.createAlias('history_workouts__parent_id__routines__id');

  $$RoutinesTableProcessedTableManager? get parentId {
    final $_column = $_itemColumn<String>('parent_id');
    if ($_column == null) return null;
    final manager = $$RoutinesTableTableManager(
      $_db,
      $_db.routines,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_parentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $HistoryWorkoutsTable _completedByTable(_$GTDatabaseImpl db) => db
      .historyWorkouts
      .createAlias('history_workouts__completed_by__history_workouts__id');

  $$HistoryWorkoutsTableProcessedTableManager? get completedBy {
    final $_column = $_itemColumn<String>('completed_by');
    if ($_column == null) return null;
    final manager = $$HistoryWorkoutsTableTableManager(
      $_db,
      $_db.historyWorkouts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_completedByTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $HistoryWorkoutsTable _completesTable(_$GTDatabaseImpl db) => db
      .historyWorkouts
      .createAlias('history_workouts__completes__history_workouts__id');

  $$HistoryWorkoutsTableProcessedTableManager? get completes {
    final $_column = $_itemColumn<String>('completes');
    if ($_column == null) return null;
    final manager = $$HistoryWorkoutsTableTableManager(
      $_db,
      $_db.historyWorkouts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_completesTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $HistoryWorkoutExercisesTable,
    List<HistoryWorkoutExercise>
  >
  _historyWorkoutExercisesRefsTable(_$GTDatabaseImpl db) =>
      MultiTypedResultKey.fromTable(
        db.historyWorkoutExercises,
        aliasName:
            'history_workouts__id__history_workout_exercises__routine_id',
      );

  $$HistoryWorkoutExercisesTableProcessedTableManager
  get historyWorkoutExercisesRefs {
    final manager = $$HistoryWorkoutExercisesTableTableManager(
      $_db,
      $_db.historyWorkoutExercises,
    ).filter((f) => f.routineId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _historyWorkoutExercisesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$HistoryWorkoutsTableFilterComposer
    extends Composer<_$GTDatabaseImpl, $HistoryWorkoutsTable> {
  $$HistoryWorkoutsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get visibility => $composableBuilder(
    column: $table.visibility,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get publicationManifest => $composableBuilder(
    column: $table.publicationManifest,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get infobox => $composableBuilder(
    column: $table.infobox,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startingDate => $composableBuilder(
    column: $table.startingDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Weights, Weights, String> get weightUnit =>
      $composableBuilder(
        column: $table.weightUnit,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Distance, Distance, String> get distanceUnit =>
      $composableBuilder(
        column: $table.distanceUnit,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $$RoutinesTableFilterComposer get parentId {
    final $$RoutinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.routines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutinesTableFilterComposer(
            $db: $db,
            $table: $db.routines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$HistoryWorkoutsTableFilterComposer get completedBy {
    final $$HistoryWorkoutsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.completedBy,
      referencedTable: $db.historyWorkouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HistoryWorkoutsTableFilterComposer(
            $db: $db,
            $table: $db.historyWorkouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$HistoryWorkoutsTableFilterComposer get completes {
    final $$HistoryWorkoutsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.completes,
      referencedTable: $db.historyWorkouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HistoryWorkoutsTableFilterComposer(
            $db: $db,
            $table: $db.historyWorkouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> historyWorkoutExercisesRefs(
    Expression<bool> Function($$HistoryWorkoutExercisesTableFilterComposer f) f,
  ) {
    final $$HistoryWorkoutExercisesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.historyWorkoutExercises,
          getReferencedColumn: (t) => t.routineId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$HistoryWorkoutExercisesTableFilterComposer(
                $db: $db,
                $table: $db.historyWorkoutExercises,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$HistoryWorkoutsTableOrderingComposer
    extends Composer<_$GTDatabaseImpl, $HistoryWorkoutsTable> {
  $$HistoryWorkoutsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get visibility => $composableBuilder(
    column: $table.visibility,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get publicationManifest => $composableBuilder(
    column: $table.publicationManifest,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get infobox => $composableBuilder(
    column: $table.infobox,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startingDate => $composableBuilder(
    column: $table.startingDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weightUnit => $composableBuilder(
    column: $table.weightUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get distanceUnit => $composableBuilder(
    column: $table.distanceUnit,
    builder: (column) => ColumnOrderings(column),
  );

  $$RoutinesTableOrderingComposer get parentId {
    final $$RoutinesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.routines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutinesTableOrderingComposer(
            $db: $db,
            $table: $db.routines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$HistoryWorkoutsTableOrderingComposer get completedBy {
    final $$HistoryWorkoutsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.completedBy,
      referencedTable: $db.historyWorkouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HistoryWorkoutsTableOrderingComposer(
            $db: $db,
            $table: $db.historyWorkouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$HistoryWorkoutsTableOrderingComposer get completes {
    final $$HistoryWorkoutsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.completes,
      referencedTable: $db.historyWorkouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HistoryWorkoutsTableOrderingComposer(
            $db: $db,
            $table: $db.historyWorkouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HistoryWorkoutsTableAnnotationComposer
    extends Composer<_$GTDatabaseImpl, $HistoryWorkoutsTable> {
  $$HistoryWorkoutsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get visibility => $composableBuilder(
    column: $table.visibility,
    builder: (column) => column,
  );

  GeneratedColumn<String> get publicationManifest => $composableBuilder(
    column: $table.publicationManifest,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get infobox =>
      $composableBuilder(column: $table.infobox, builder: (column) => column);

  GeneratedColumn<int> get duration =>
      $composableBuilder(column: $table.duration, builder: (column) => column);

  GeneratedColumn<DateTime> get startingDate => $composableBuilder(
    column: $table.startingDate,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Weights, String> get weightUnit =>
      $composableBuilder(
        column: $table.weightUnit,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Distance, String> get distanceUnit =>
      $composableBuilder(
        column: $table.distanceUnit,
        builder: (column) => column,
      );

  $$RoutinesTableAnnotationComposer get parentId {
    final $$RoutinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.routines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutinesTableAnnotationComposer(
            $db: $db,
            $table: $db.routines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$HistoryWorkoutsTableAnnotationComposer get completedBy {
    final $$HistoryWorkoutsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.completedBy,
      referencedTable: $db.historyWorkouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HistoryWorkoutsTableAnnotationComposer(
            $db: $db,
            $table: $db.historyWorkouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$HistoryWorkoutsTableAnnotationComposer get completes {
    final $$HistoryWorkoutsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.completes,
      referencedTable: $db.historyWorkouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HistoryWorkoutsTableAnnotationComposer(
            $db: $db,
            $table: $db.historyWorkouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> historyWorkoutExercisesRefs<T extends Object>(
    Expression<T> Function($$HistoryWorkoutExercisesTableAnnotationComposer a)
    f,
  ) {
    final $$HistoryWorkoutExercisesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.historyWorkoutExercises,
          getReferencedColumn: (t) => t.routineId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$HistoryWorkoutExercisesTableAnnotationComposer(
                $db: $db,
                $table: $db.historyWorkoutExercises,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$HistoryWorkoutsTableTableManager
    extends
        RootTableManager<
          _$GTDatabaseImpl,
          $HistoryWorkoutsTable,
          HistoryWorkout,
          $$HistoryWorkoutsTableFilterComposer,
          $$HistoryWorkoutsTableOrderingComposer,
          $$HistoryWorkoutsTableAnnotationComposer,
          $$HistoryWorkoutsTableCreateCompanionBuilder,
          $$HistoryWorkoutsTableUpdateCompanionBuilder,
          (HistoryWorkout, $$HistoryWorkoutsTableReferences),
          HistoryWorkout,
          PrefetchHooks Function({
            bool parentId,
            bool completedBy,
            bool completes,
            bool historyWorkoutExercisesRefs,
          })
        > {
  $$HistoryWorkoutsTableTableManager(
    _$GTDatabaseImpl db,
    $HistoryWorkoutsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HistoryWorkoutsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HistoryWorkoutsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HistoryWorkoutsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> visibility = const Value.absent(),
                Value<String?> publicationManifest = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> infobox = const Value.absent(),
                Value<int> duration = const Value.absent(),
                Value<DateTime> startingDate = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                Value<String?> completedBy = const Value.absent(),
                Value<String?> completes = const Value.absent(),
                Value<Weights> weightUnit = const Value.absent(),
                Value<Distance> distanceUnit = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HistoryWorkoutsCompanion(
                id: id,
                userId: userId,
                updatedAt: updatedAt,
                deleted: deleted,
                visibility: visibility,
                publicationManifest: publicationManifest,
                name: name,
                infobox: infobox,
                duration: duration,
                startingDate: startingDate,
                parentId: parentId,
                completedBy: completedBy,
                completes: completes,
                weightUnit: weightUnit,
                distanceUnit: distanceUnit,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> visibility = const Value.absent(),
                Value<String?> publicationManifest = const Value.absent(),
                required String name,
                Value<String?> infobox = const Value.absent(),
                required int duration,
                required DateTime startingDate,
                Value<String?> parentId = const Value.absent(),
                Value<String?> completedBy = const Value.absent(),
                Value<String?> completes = const Value.absent(),
                required Weights weightUnit,
                required Distance distanceUnit,
                Value<int> rowid = const Value.absent(),
              }) => HistoryWorkoutsCompanion.insert(
                id: id,
                userId: userId,
                updatedAt: updatedAt,
                deleted: deleted,
                visibility: visibility,
                publicationManifest: publicationManifest,
                name: name,
                infobox: infobox,
                duration: duration,
                startingDate: startingDate,
                parentId: parentId,
                completedBy: completedBy,
                completes: completes,
                weightUnit: weightUnit,
                distanceUnit: distanceUnit,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$HistoryWorkoutsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                parentId = false,
                completedBy = false,
                completes = false,
                historyWorkoutExercisesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (historyWorkoutExercisesRefs) db.historyWorkoutExercises,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (parentId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.parentId,
                                    referencedTable:
                                        $$HistoryWorkoutsTableReferences
                                            ._parentIdTable(db),
                                    referencedColumn:
                                        $$HistoryWorkoutsTableReferences
                                            ._parentIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (completedBy) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.completedBy,
                                    referencedTable:
                                        $$HistoryWorkoutsTableReferences
                                            ._completedByTable(db),
                                    referencedColumn:
                                        $$HistoryWorkoutsTableReferences
                                            ._completedByTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (completes) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.completes,
                                    referencedTable:
                                        $$HistoryWorkoutsTableReferences
                                            ._completesTable(db),
                                    referencedColumn:
                                        $$HistoryWorkoutsTableReferences
                                            ._completesTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (historyWorkoutExercisesRefs)
                        await $_getPrefetchedData<
                          HistoryWorkout,
                          $HistoryWorkoutsTable,
                          HistoryWorkoutExercise
                        >(
                          currentTable: table,
                          referencedTable: $$HistoryWorkoutsTableReferences
                              ._historyWorkoutExercisesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$HistoryWorkoutsTableReferences(
                                db,
                                table,
                                p0,
                              ).historyWorkoutExercisesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.routineId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$HistoryWorkoutsTableProcessedTableManager =
    ProcessedTableManager<
      _$GTDatabaseImpl,
      $HistoryWorkoutsTable,
      HistoryWorkout,
      $$HistoryWorkoutsTableFilterComposer,
      $$HistoryWorkoutsTableOrderingComposer,
      $$HistoryWorkoutsTableAnnotationComposer,
      $$HistoryWorkoutsTableCreateCompanionBuilder,
      $$HistoryWorkoutsTableUpdateCompanionBuilder,
      (HistoryWorkout, $$HistoryWorkoutsTableReferences),
      HistoryWorkout,
      PrefetchHooks Function({
        bool parentId,
        bool completedBy,
        bool completes,
        bool historyWorkoutExercisesRefs,
      })
    >;
typedef $$HistoryWorkoutExercisesTableCreateCompanionBuilder =
    HistoryWorkoutExercisesCompanion Function({
      Value<String> id,
      required String routineId,
      required String name,
      Value<GTSetParameters?> parameters,
      Value<List<GTSet>?> sets,
      Value<GTMuscleGroup?> primaryMuscleGroup,
      Value<Set<GTMuscleGroup>?> secondaryMuscleGroups,
      Value<int?> restTime,
      required bool isCustom,
      Value<String?> libraryExerciseId,
      Value<String?> customExerciseId,
      Value<String?> notes,
      required bool isSuperset,
      required bool isInSuperset,
      Value<String?> supersetId,
      required int sortOrder,
      Value<String?> supersedesId,
      Value<int?> rpe,
      Value<ExerciseProgression?> progression,
      Value<GTGymEquipment?> equipment,
      Value<DateTime> updatedAt,
      Value<bool> deleted,
      Value<String?> userId,
      Value<String?> publicationVersion,
      Value<int> rowid,
    });
typedef $$HistoryWorkoutExercisesTableUpdateCompanionBuilder =
    HistoryWorkoutExercisesCompanion Function({
      Value<String> id,
      Value<String> routineId,
      Value<String> name,
      Value<GTSetParameters?> parameters,
      Value<List<GTSet>?> sets,
      Value<GTMuscleGroup?> primaryMuscleGroup,
      Value<Set<GTMuscleGroup>?> secondaryMuscleGroups,
      Value<int?> restTime,
      Value<bool> isCustom,
      Value<String?> libraryExerciseId,
      Value<String?> customExerciseId,
      Value<String?> notes,
      Value<bool> isSuperset,
      Value<bool> isInSuperset,
      Value<String?> supersetId,
      Value<int> sortOrder,
      Value<String?> supersedesId,
      Value<int?> rpe,
      Value<ExerciseProgression?> progression,
      Value<GTGymEquipment?> equipment,
      Value<DateTime> updatedAt,
      Value<bool> deleted,
      Value<String?> userId,
      Value<String?> publicationVersion,
      Value<int> rowid,
    });

final class $$HistoryWorkoutExercisesTableReferences
    extends
        BaseReferences<
          _$GTDatabaseImpl,
          $HistoryWorkoutExercisesTable,
          HistoryWorkoutExercise
        > {
  $$HistoryWorkoutExercisesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $HistoryWorkoutsTable _routineIdTable(_$GTDatabaseImpl db) =>
      db.historyWorkouts.createAlias(
        'history_workout_exercises__routine_id__history_workouts__id',
      );

  $$HistoryWorkoutsTableProcessedTableManager get routineId {
    final $_column = $_itemColumn<String>('routine_id')!;

    final manager = $$HistoryWorkoutsTableTableManager(
      $_db,
      $_db.historyWorkouts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_routineIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CustomExercisesTable _customExerciseIdTable(_$GTDatabaseImpl db) =>
      db.customExercises.createAlias(
        'history_workout_exercises__custom_exercise_id__custom_exercises__id',
      );

  $$CustomExercisesTableProcessedTableManager? get customExerciseId {
    final $_column = $_itemColumn<String>('custom_exercise_id');
    if ($_column == null) return null;
    final manager = $$CustomExercisesTableTableManager(
      $_db,
      $_db.customExercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_customExerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $HistoryWorkoutExercisesTable _supersetIdTable(_$GTDatabaseImpl db) =>
      db.historyWorkoutExercises.createAlias(
        'history_workout_exercises__superset_id__history_workout_exercises__id',
      );

  $$HistoryWorkoutExercisesTableProcessedTableManager? get supersetId {
    final $_column = $_itemColumn<String>('superset_id');
    if ($_column == null) return null;
    final manager = $$HistoryWorkoutExercisesTableTableManager(
      $_db,
      $_db.historyWorkoutExercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_supersetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $HistoryWorkoutExercisesTable _supersedesIdTable(
    _$GTDatabaseImpl db,
  ) => db.historyWorkoutExercises.createAlias(
    'history_workout_exercises__supersedes_id__history_workout_exercises__id',
  );

  $$HistoryWorkoutExercisesTableProcessedTableManager? get supersedesId {
    final $_column = $_itemColumn<String>('supersedes_id');
    if ($_column == null) return null;
    final manager = $$HistoryWorkoutExercisesTableTableManager(
      $_db,
      $_db.historyWorkoutExercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_supersedesIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$HistoryWorkoutExercisesTableFilterComposer
    extends Composer<_$GTDatabaseImpl, $HistoryWorkoutExercisesTable> {
  $$HistoryWorkoutExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<GTSetParameters?, GTSetParameters, String>
  get parameters => $composableBuilder(
    column: $table.parameters,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<List<GTSet>?, List<GTSet>, String> get sets =>
      $composableBuilder(
        column: $table.sets,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<GTMuscleGroup?, GTMuscleGroup, String>
  get primaryMuscleGroup => $composableBuilder(
    column: $table.primaryMuscleGroup,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<
    Set<GTMuscleGroup>?,
    Set<GTMuscleGroup>,
    String
  >
  get secondaryMuscleGroups => $composableBuilder(
    column: $table.secondaryMuscleGroups,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get restTime => $composableBuilder(
    column: $table.restTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCustom => $composableBuilder(
    column: $table.isCustom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get libraryExerciseId => $composableBuilder(
    column: $table.libraryExerciseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSuperset => $composableBuilder(
    column: $table.isSuperset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isInSuperset => $composableBuilder(
    column: $table.isInSuperset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rpe => $composableBuilder(
    column: $table.rpe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    ExerciseProgression?,
    ExerciseProgression,
    String
  >
  get progression => $composableBuilder(
    column: $table.progression,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<GTGymEquipment?, GTGymEquipment, String>
  get equipment => $composableBuilder(
    column: $table.equipment,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get publicationVersion => $composableBuilder(
    column: $table.publicationVersion,
    builder: (column) => ColumnFilters(column),
  );

  $$HistoryWorkoutsTableFilterComposer get routineId {
    final $$HistoryWorkoutsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineId,
      referencedTable: $db.historyWorkouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HistoryWorkoutsTableFilterComposer(
            $db: $db,
            $table: $db.historyWorkouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CustomExercisesTableFilterComposer get customExerciseId {
    final $$CustomExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customExerciseId,
      referencedTable: $db.customExercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomExercisesTableFilterComposer(
            $db: $db,
            $table: $db.customExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$HistoryWorkoutExercisesTableFilterComposer get supersetId {
    final $$HistoryWorkoutExercisesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.supersetId,
          referencedTable: $db.historyWorkoutExercises,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$HistoryWorkoutExercisesTableFilterComposer(
                $db: $db,
                $table: $db.historyWorkoutExercises,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$HistoryWorkoutExercisesTableFilterComposer get supersedesId {
    final $$HistoryWorkoutExercisesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.supersedesId,
          referencedTable: $db.historyWorkoutExercises,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$HistoryWorkoutExercisesTableFilterComposer(
                $db: $db,
                $table: $db.historyWorkoutExercises,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$HistoryWorkoutExercisesTableOrderingComposer
    extends Composer<_$GTDatabaseImpl, $HistoryWorkoutExercisesTable> {
  $$HistoryWorkoutExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parameters => $composableBuilder(
    column: $table.parameters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sets => $composableBuilder(
    column: $table.sets,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get primaryMuscleGroup => $composableBuilder(
    column: $table.primaryMuscleGroup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get secondaryMuscleGroups => $composableBuilder(
    column: $table.secondaryMuscleGroups,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get restTime => $composableBuilder(
    column: $table.restTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCustom => $composableBuilder(
    column: $table.isCustom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get libraryExerciseId => $composableBuilder(
    column: $table.libraryExerciseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSuperset => $composableBuilder(
    column: $table.isSuperset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isInSuperset => $composableBuilder(
    column: $table.isInSuperset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rpe => $composableBuilder(
    column: $table.rpe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get progression => $composableBuilder(
    column: $table.progression,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get equipment => $composableBuilder(
    column: $table.equipment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get publicationVersion => $composableBuilder(
    column: $table.publicationVersion,
    builder: (column) => ColumnOrderings(column),
  );

  $$HistoryWorkoutsTableOrderingComposer get routineId {
    final $$HistoryWorkoutsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineId,
      referencedTable: $db.historyWorkouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HistoryWorkoutsTableOrderingComposer(
            $db: $db,
            $table: $db.historyWorkouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CustomExercisesTableOrderingComposer get customExerciseId {
    final $$CustomExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customExerciseId,
      referencedTable: $db.customExercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.customExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$HistoryWorkoutExercisesTableOrderingComposer get supersetId {
    final $$HistoryWorkoutExercisesTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.supersetId,
          referencedTable: $db.historyWorkoutExercises,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$HistoryWorkoutExercisesTableOrderingComposer(
                $db: $db,
                $table: $db.historyWorkoutExercises,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$HistoryWorkoutExercisesTableOrderingComposer get supersedesId {
    final $$HistoryWorkoutExercisesTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.supersedesId,
          referencedTable: $db.historyWorkoutExercises,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$HistoryWorkoutExercisesTableOrderingComposer(
                $db: $db,
                $table: $db.historyWorkoutExercises,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$HistoryWorkoutExercisesTableAnnotationComposer
    extends Composer<_$GTDatabaseImpl, $HistoryWorkoutExercisesTable> {
  $$HistoryWorkoutExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<GTSetParameters?, String> get parameters =>
      $composableBuilder(
        column: $table.parameters,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<List<GTSet>?, String> get sets =>
      $composableBuilder(column: $table.sets, builder: (column) => column);

  GeneratedColumnWithTypeConverter<GTMuscleGroup?, String>
  get primaryMuscleGroup => $composableBuilder(
    column: $table.primaryMuscleGroup,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Set<GTMuscleGroup>?, String>
  get secondaryMuscleGroups => $composableBuilder(
    column: $table.secondaryMuscleGroups,
    builder: (column) => column,
  );

  GeneratedColumn<int> get restTime =>
      $composableBuilder(column: $table.restTime, builder: (column) => column);

  GeneratedColumn<bool> get isCustom =>
      $composableBuilder(column: $table.isCustom, builder: (column) => column);

  GeneratedColumn<String> get libraryExerciseId => $composableBuilder(
    column: $table.libraryExerciseId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isSuperset => $composableBuilder(
    column: $table.isSuperset,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isInSuperset => $composableBuilder(
    column: $table.isInSuperset,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<int> get rpe =>
      $composableBuilder(column: $table.rpe, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ExerciseProgression?, String>
  get progression => $composableBuilder(
    column: $table.progression,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<GTGymEquipment?, String> get equipment =>
      $composableBuilder(column: $table.equipment, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get publicationVersion => $composableBuilder(
    column: $table.publicationVersion,
    builder: (column) => column,
  );

  $$HistoryWorkoutsTableAnnotationComposer get routineId {
    final $$HistoryWorkoutsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineId,
      referencedTable: $db.historyWorkouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HistoryWorkoutsTableAnnotationComposer(
            $db: $db,
            $table: $db.historyWorkouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CustomExercisesTableAnnotationComposer get customExerciseId {
    final $$CustomExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customExerciseId,
      referencedTable: $db.customExercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.customExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$HistoryWorkoutExercisesTableAnnotationComposer get supersetId {
    final $$HistoryWorkoutExercisesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.supersetId,
          referencedTable: $db.historyWorkoutExercises,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$HistoryWorkoutExercisesTableAnnotationComposer(
                $db: $db,
                $table: $db.historyWorkoutExercises,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$HistoryWorkoutExercisesTableAnnotationComposer get supersedesId {
    final $$HistoryWorkoutExercisesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.supersedesId,
          referencedTable: $db.historyWorkoutExercises,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$HistoryWorkoutExercisesTableAnnotationComposer(
                $db: $db,
                $table: $db.historyWorkoutExercises,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$HistoryWorkoutExercisesTableTableManager
    extends
        RootTableManager<
          _$GTDatabaseImpl,
          $HistoryWorkoutExercisesTable,
          HistoryWorkoutExercise,
          $$HistoryWorkoutExercisesTableFilterComposer,
          $$HistoryWorkoutExercisesTableOrderingComposer,
          $$HistoryWorkoutExercisesTableAnnotationComposer,
          $$HistoryWorkoutExercisesTableCreateCompanionBuilder,
          $$HistoryWorkoutExercisesTableUpdateCompanionBuilder,
          (HistoryWorkoutExercise, $$HistoryWorkoutExercisesTableReferences),
          HistoryWorkoutExercise,
          PrefetchHooks Function({
            bool routineId,
            bool customExerciseId,
            bool supersetId,
            bool supersedesId,
          })
        > {
  $$HistoryWorkoutExercisesTableTableManager(
    _$GTDatabaseImpl db,
    $HistoryWorkoutExercisesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HistoryWorkoutExercisesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$HistoryWorkoutExercisesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$HistoryWorkoutExercisesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> routineId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<GTSetParameters?> parameters = const Value.absent(),
                Value<List<GTSet>?> sets = const Value.absent(),
                Value<GTMuscleGroup?> primaryMuscleGroup = const Value.absent(),
                Value<Set<GTMuscleGroup>?> secondaryMuscleGroups =
                    const Value.absent(),
                Value<int?> restTime = const Value.absent(),
                Value<bool> isCustom = const Value.absent(),
                Value<String?> libraryExerciseId = const Value.absent(),
                Value<String?> customExerciseId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isSuperset = const Value.absent(),
                Value<bool> isInSuperset = const Value.absent(),
                Value<String?> supersetId = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String?> supersedesId = const Value.absent(),
                Value<int?> rpe = const Value.absent(),
                Value<ExerciseProgression?> progression = const Value.absent(),
                Value<GTGymEquipment?> equipment = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String?> publicationVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HistoryWorkoutExercisesCompanion(
                id: id,
                routineId: routineId,
                name: name,
                parameters: parameters,
                sets: sets,
                primaryMuscleGroup: primaryMuscleGroup,
                secondaryMuscleGroups: secondaryMuscleGroups,
                restTime: restTime,
                isCustom: isCustom,
                libraryExerciseId: libraryExerciseId,
                customExerciseId: customExerciseId,
                notes: notes,
                isSuperset: isSuperset,
                isInSuperset: isInSuperset,
                supersetId: supersetId,
                sortOrder: sortOrder,
                supersedesId: supersedesId,
                rpe: rpe,
                progression: progression,
                equipment: equipment,
                updatedAt: updatedAt,
                deleted: deleted,
                userId: userId,
                publicationVersion: publicationVersion,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String routineId,
                required String name,
                Value<GTSetParameters?> parameters = const Value.absent(),
                Value<List<GTSet>?> sets = const Value.absent(),
                Value<GTMuscleGroup?> primaryMuscleGroup = const Value.absent(),
                Value<Set<GTMuscleGroup>?> secondaryMuscleGroups =
                    const Value.absent(),
                Value<int?> restTime = const Value.absent(),
                required bool isCustom,
                Value<String?> libraryExerciseId = const Value.absent(),
                Value<String?> customExerciseId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required bool isSuperset,
                required bool isInSuperset,
                Value<String?> supersetId = const Value.absent(),
                required int sortOrder,
                Value<String?> supersedesId = const Value.absent(),
                Value<int?> rpe = const Value.absent(),
                Value<ExerciseProgression?> progression = const Value.absent(),
                Value<GTGymEquipment?> equipment = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String?> publicationVersion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HistoryWorkoutExercisesCompanion.insert(
                id: id,
                routineId: routineId,
                name: name,
                parameters: parameters,
                sets: sets,
                primaryMuscleGroup: primaryMuscleGroup,
                secondaryMuscleGroups: secondaryMuscleGroups,
                restTime: restTime,
                isCustom: isCustom,
                libraryExerciseId: libraryExerciseId,
                customExerciseId: customExerciseId,
                notes: notes,
                isSuperset: isSuperset,
                isInSuperset: isInSuperset,
                supersetId: supersetId,
                sortOrder: sortOrder,
                supersedesId: supersedesId,
                rpe: rpe,
                progression: progression,
                equipment: equipment,
                updatedAt: updatedAt,
                deleted: deleted,
                userId: userId,
                publicationVersion: publicationVersion,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$HistoryWorkoutExercisesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                routineId = false,
                customExerciseId = false,
                supersetId = false,
                supersedesId = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (routineId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.routineId,
                                    referencedTable:
                                        $$HistoryWorkoutExercisesTableReferences
                                            ._routineIdTable(db),
                                    referencedColumn:
                                        $$HistoryWorkoutExercisesTableReferences
                                            ._routineIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (customExerciseId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.customExerciseId,
                                    referencedTable:
                                        $$HistoryWorkoutExercisesTableReferences
                                            ._customExerciseIdTable(db),
                                    referencedColumn:
                                        $$HistoryWorkoutExercisesTableReferences
                                            ._customExerciseIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (supersetId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.supersetId,
                                    referencedTable:
                                        $$HistoryWorkoutExercisesTableReferences
                                            ._supersetIdTable(db),
                                    referencedColumn:
                                        $$HistoryWorkoutExercisesTableReferences
                                            ._supersetIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (supersedesId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.supersedesId,
                                    referencedTable:
                                        $$HistoryWorkoutExercisesTableReferences
                                            ._supersedesIdTable(db),
                                    referencedColumn:
                                        $$HistoryWorkoutExercisesTableReferences
                                            ._supersedesIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$HistoryWorkoutExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$GTDatabaseImpl,
      $HistoryWorkoutExercisesTable,
      HistoryWorkoutExercise,
      $$HistoryWorkoutExercisesTableFilterComposer,
      $$HistoryWorkoutExercisesTableOrderingComposer,
      $$HistoryWorkoutExercisesTableAnnotationComposer,
      $$HistoryWorkoutExercisesTableCreateCompanionBuilder,
      $$HistoryWorkoutExercisesTableUpdateCompanionBuilder,
      (HistoryWorkoutExercise, $$HistoryWorkoutExercisesTableReferences),
      HistoryWorkoutExercise,
      PrefetchHooks Function({
        bool routineId,
        bool customExerciseId,
        bool supersetId,
        bool supersedesId,
      })
    >;
typedef $$RoutineExercisesTableCreateCompanionBuilder =
    RoutineExercisesCompanion Function({
      Value<String> id,
      required String routineId,
      required String name,
      Value<GTSetParameters?> parameters,
      Value<List<GTSet>?> sets,
      Value<GTMuscleGroup?> primaryMuscleGroup,
      Value<Set<GTMuscleGroup>?> secondaryMuscleGroups,
      Value<int?> restTime,
      required bool isCustom,
      Value<String?> libraryExerciseId,
      Value<String?> customExerciseId,
      Value<String?> notes,
      required bool isSuperset,
      required bool isInSuperset,
      Value<String?> supersetId,
      required int sortOrder,
      Value<String?> supersedesId,
      Value<int?> rpe,
      Value<ExerciseProgression?> progression,
      Value<GTGymEquipment?> equipment,
      Value<DateTime> updatedAt,
      Value<bool> deleted,
      Value<String?> userId,
      Value<int> rowid,
    });
typedef $$RoutineExercisesTableUpdateCompanionBuilder =
    RoutineExercisesCompanion Function({
      Value<String> id,
      Value<String> routineId,
      Value<String> name,
      Value<GTSetParameters?> parameters,
      Value<List<GTSet>?> sets,
      Value<GTMuscleGroup?> primaryMuscleGroup,
      Value<Set<GTMuscleGroup>?> secondaryMuscleGroups,
      Value<int?> restTime,
      Value<bool> isCustom,
      Value<String?> libraryExerciseId,
      Value<String?> customExerciseId,
      Value<String?> notes,
      Value<bool> isSuperset,
      Value<bool> isInSuperset,
      Value<String?> supersetId,
      Value<int> sortOrder,
      Value<String?> supersedesId,
      Value<int?> rpe,
      Value<ExerciseProgression?> progression,
      Value<GTGymEquipment?> equipment,
      Value<DateTime> updatedAt,
      Value<bool> deleted,
      Value<String?> userId,
      Value<int> rowid,
    });

final class $$RoutineExercisesTableReferences
    extends
        BaseReferences<
          _$GTDatabaseImpl,
          $RoutineExercisesTable,
          RoutineExercise
        > {
  $$RoutineExercisesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $RoutinesTable _routineIdTable(_$GTDatabaseImpl db) =>
      db.routines.createAlias('routine_exercises__routine_id__routines__id');

  $$RoutinesTableProcessedTableManager get routineId {
    final $_column = $_itemColumn<String>('routine_id')!;

    final manager = $$RoutinesTableTableManager(
      $_db,
      $_db.routines,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_routineIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CustomExercisesTable _customExerciseIdTable(_$GTDatabaseImpl db) =>
      db.customExercises.createAlias(
        'routine_exercises__custom_exercise_id__custom_exercises__id',
      );

  $$CustomExercisesTableProcessedTableManager? get customExerciseId {
    final $_column = $_itemColumn<String>('custom_exercise_id');
    if ($_column == null) return null;
    final manager = $$CustomExercisesTableTableManager(
      $_db,
      $_db.customExercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_customExerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $RoutineExercisesTable _supersetIdTable(_$GTDatabaseImpl db) => db
      .routineExercises
      .createAlias('routine_exercises__superset_id__routine_exercises__id');

  $$RoutineExercisesTableProcessedTableManager? get supersetId {
    final $_column = $_itemColumn<String>('superset_id');
    if ($_column == null) return null;
    final manager = $$RoutineExercisesTableTableManager(
      $_db,
      $_db.routineExercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_supersetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $RoutineExercisesTable _supersedesIdTable(_$GTDatabaseImpl db) => db
      .routineExercises
      .createAlias('routine_exercises__supersedes_id__routine_exercises__id');

  $$RoutineExercisesTableProcessedTableManager? get supersedesId {
    final $_column = $_itemColumn<String>('supersedes_id');
    if ($_column == null) return null;
    final manager = $$RoutineExercisesTableTableManager(
      $_db,
      $_db.routineExercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_supersedesIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RoutineExercisesTableFilterComposer
    extends Composer<_$GTDatabaseImpl, $RoutineExercisesTable> {
  $$RoutineExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<GTSetParameters?, GTSetParameters, String>
  get parameters => $composableBuilder(
    column: $table.parameters,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<List<GTSet>?, List<GTSet>, String> get sets =>
      $composableBuilder(
        column: $table.sets,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<GTMuscleGroup?, GTMuscleGroup, String>
  get primaryMuscleGroup => $composableBuilder(
    column: $table.primaryMuscleGroup,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<
    Set<GTMuscleGroup>?,
    Set<GTMuscleGroup>,
    String
  >
  get secondaryMuscleGroups => $composableBuilder(
    column: $table.secondaryMuscleGroups,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get restTime => $composableBuilder(
    column: $table.restTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCustom => $composableBuilder(
    column: $table.isCustom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get libraryExerciseId => $composableBuilder(
    column: $table.libraryExerciseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSuperset => $composableBuilder(
    column: $table.isSuperset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isInSuperset => $composableBuilder(
    column: $table.isInSuperset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rpe => $composableBuilder(
    column: $table.rpe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    ExerciseProgression?,
    ExerciseProgression,
    String
  >
  get progression => $composableBuilder(
    column: $table.progression,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<GTGymEquipment?, GTGymEquipment, String>
  get equipment => $composableBuilder(
    column: $table.equipment,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  $$RoutinesTableFilterComposer get routineId {
    final $$RoutinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineId,
      referencedTable: $db.routines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutinesTableFilterComposer(
            $db: $db,
            $table: $db.routines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CustomExercisesTableFilterComposer get customExerciseId {
    final $$CustomExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customExerciseId,
      referencedTable: $db.customExercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomExercisesTableFilterComposer(
            $db: $db,
            $table: $db.customExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RoutineExercisesTableFilterComposer get supersetId {
    final $$RoutineExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supersetId,
      referencedTable: $db.routineExercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineExercisesTableFilterComposer(
            $db: $db,
            $table: $db.routineExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RoutineExercisesTableFilterComposer get supersedesId {
    final $$RoutineExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supersedesId,
      referencedTable: $db.routineExercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineExercisesTableFilterComposer(
            $db: $db,
            $table: $db.routineExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutineExercisesTableOrderingComposer
    extends Composer<_$GTDatabaseImpl, $RoutineExercisesTable> {
  $$RoutineExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parameters => $composableBuilder(
    column: $table.parameters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sets => $composableBuilder(
    column: $table.sets,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get primaryMuscleGroup => $composableBuilder(
    column: $table.primaryMuscleGroup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get secondaryMuscleGroups => $composableBuilder(
    column: $table.secondaryMuscleGroups,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get restTime => $composableBuilder(
    column: $table.restTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCustom => $composableBuilder(
    column: $table.isCustom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get libraryExerciseId => $composableBuilder(
    column: $table.libraryExerciseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSuperset => $composableBuilder(
    column: $table.isSuperset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isInSuperset => $composableBuilder(
    column: $table.isInSuperset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rpe => $composableBuilder(
    column: $table.rpe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get progression => $composableBuilder(
    column: $table.progression,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get equipment => $composableBuilder(
    column: $table.equipment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  $$RoutinesTableOrderingComposer get routineId {
    final $$RoutinesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineId,
      referencedTable: $db.routines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutinesTableOrderingComposer(
            $db: $db,
            $table: $db.routines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CustomExercisesTableOrderingComposer get customExerciseId {
    final $$CustomExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customExerciseId,
      referencedTable: $db.customExercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.customExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RoutineExercisesTableOrderingComposer get supersetId {
    final $$RoutineExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supersetId,
      referencedTable: $db.routineExercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.routineExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RoutineExercisesTableOrderingComposer get supersedesId {
    final $$RoutineExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supersedesId,
      referencedTable: $db.routineExercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.routineExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutineExercisesTableAnnotationComposer
    extends Composer<_$GTDatabaseImpl, $RoutineExercisesTable> {
  $$RoutineExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<GTSetParameters?, String> get parameters =>
      $composableBuilder(
        column: $table.parameters,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<List<GTSet>?, String> get sets =>
      $composableBuilder(column: $table.sets, builder: (column) => column);

  GeneratedColumnWithTypeConverter<GTMuscleGroup?, String>
  get primaryMuscleGroup => $composableBuilder(
    column: $table.primaryMuscleGroup,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Set<GTMuscleGroup>?, String>
  get secondaryMuscleGroups => $composableBuilder(
    column: $table.secondaryMuscleGroups,
    builder: (column) => column,
  );

  GeneratedColumn<int> get restTime =>
      $composableBuilder(column: $table.restTime, builder: (column) => column);

  GeneratedColumn<bool> get isCustom =>
      $composableBuilder(column: $table.isCustom, builder: (column) => column);

  GeneratedColumn<String> get libraryExerciseId => $composableBuilder(
    column: $table.libraryExerciseId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isSuperset => $composableBuilder(
    column: $table.isSuperset,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isInSuperset => $composableBuilder(
    column: $table.isInSuperset,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<int> get rpe =>
      $composableBuilder(column: $table.rpe, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ExerciseProgression?, String>
  get progression => $composableBuilder(
    column: $table.progression,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<GTGymEquipment?, String> get equipment =>
      $composableBuilder(column: $table.equipment, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  $$RoutinesTableAnnotationComposer get routineId {
    final $$RoutinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineId,
      referencedTable: $db.routines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutinesTableAnnotationComposer(
            $db: $db,
            $table: $db.routines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CustomExercisesTableAnnotationComposer get customExerciseId {
    final $$CustomExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customExerciseId,
      referencedTable: $db.customExercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.customExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RoutineExercisesTableAnnotationComposer get supersetId {
    final $$RoutineExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supersetId,
      referencedTable: $db.routineExercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.routineExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RoutineExercisesTableAnnotationComposer get supersedesId {
    final $$RoutineExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supersedesId,
      referencedTable: $db.routineExercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.routineExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutineExercisesTableTableManager
    extends
        RootTableManager<
          _$GTDatabaseImpl,
          $RoutineExercisesTable,
          RoutineExercise,
          $$RoutineExercisesTableFilterComposer,
          $$RoutineExercisesTableOrderingComposer,
          $$RoutineExercisesTableAnnotationComposer,
          $$RoutineExercisesTableCreateCompanionBuilder,
          $$RoutineExercisesTableUpdateCompanionBuilder,
          (RoutineExercise, $$RoutineExercisesTableReferences),
          RoutineExercise,
          PrefetchHooks Function({
            bool routineId,
            bool customExerciseId,
            bool supersetId,
            bool supersedesId,
          })
        > {
  $$RoutineExercisesTableTableManager(
    _$GTDatabaseImpl db,
    $RoutineExercisesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoutineExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoutineExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoutineExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> routineId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<GTSetParameters?> parameters = const Value.absent(),
                Value<List<GTSet>?> sets = const Value.absent(),
                Value<GTMuscleGroup?> primaryMuscleGroup = const Value.absent(),
                Value<Set<GTMuscleGroup>?> secondaryMuscleGroups =
                    const Value.absent(),
                Value<int?> restTime = const Value.absent(),
                Value<bool> isCustom = const Value.absent(),
                Value<String?> libraryExerciseId = const Value.absent(),
                Value<String?> customExerciseId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isSuperset = const Value.absent(),
                Value<bool> isInSuperset = const Value.absent(),
                Value<String?> supersetId = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String?> supersedesId = const Value.absent(),
                Value<int?> rpe = const Value.absent(),
                Value<ExerciseProgression?> progression = const Value.absent(),
                Value<GTGymEquipment?> equipment = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoutineExercisesCompanion(
                id: id,
                routineId: routineId,
                name: name,
                parameters: parameters,
                sets: sets,
                primaryMuscleGroup: primaryMuscleGroup,
                secondaryMuscleGroups: secondaryMuscleGroups,
                restTime: restTime,
                isCustom: isCustom,
                libraryExerciseId: libraryExerciseId,
                customExerciseId: customExerciseId,
                notes: notes,
                isSuperset: isSuperset,
                isInSuperset: isInSuperset,
                supersetId: supersetId,
                sortOrder: sortOrder,
                supersedesId: supersedesId,
                rpe: rpe,
                progression: progression,
                equipment: equipment,
                updatedAt: updatedAt,
                deleted: deleted,
                userId: userId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String routineId,
                required String name,
                Value<GTSetParameters?> parameters = const Value.absent(),
                Value<List<GTSet>?> sets = const Value.absent(),
                Value<GTMuscleGroup?> primaryMuscleGroup = const Value.absent(),
                Value<Set<GTMuscleGroup>?> secondaryMuscleGroups =
                    const Value.absent(),
                Value<int?> restTime = const Value.absent(),
                required bool isCustom,
                Value<String?> libraryExerciseId = const Value.absent(),
                Value<String?> customExerciseId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required bool isSuperset,
                required bool isInSuperset,
                Value<String?> supersetId = const Value.absent(),
                required int sortOrder,
                Value<String?> supersedesId = const Value.absent(),
                Value<int?> rpe = const Value.absent(),
                Value<ExerciseProgression?> progression = const Value.absent(),
                Value<GTGymEquipment?> equipment = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoutineExercisesCompanion.insert(
                id: id,
                routineId: routineId,
                name: name,
                parameters: parameters,
                sets: sets,
                primaryMuscleGroup: primaryMuscleGroup,
                secondaryMuscleGroups: secondaryMuscleGroups,
                restTime: restTime,
                isCustom: isCustom,
                libraryExerciseId: libraryExerciseId,
                customExerciseId: customExerciseId,
                notes: notes,
                isSuperset: isSuperset,
                isInSuperset: isInSuperset,
                supersetId: supersetId,
                sortOrder: sortOrder,
                supersedesId: supersedesId,
                rpe: rpe,
                progression: progression,
                equipment: equipment,
                updatedAt: updatedAt,
                deleted: deleted,
                userId: userId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RoutineExercisesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                routineId = false,
                customExerciseId = false,
                supersetId = false,
                supersedesId = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (routineId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.routineId,
                                    referencedTable:
                                        $$RoutineExercisesTableReferences
                                            ._routineIdTable(db),
                                    referencedColumn:
                                        $$RoutineExercisesTableReferences
                                            ._routineIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (customExerciseId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.customExerciseId,
                                    referencedTable:
                                        $$RoutineExercisesTableReferences
                                            ._customExerciseIdTable(db),
                                    referencedColumn:
                                        $$RoutineExercisesTableReferences
                                            ._customExerciseIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (supersetId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.supersetId,
                                    referencedTable:
                                        $$RoutineExercisesTableReferences
                                            ._supersetIdTable(db),
                                    referencedColumn:
                                        $$RoutineExercisesTableReferences
                                            ._supersetIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (supersedesId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.supersedesId,
                                    referencedTable:
                                        $$RoutineExercisesTableReferences
                                            ._supersedesIdTable(db),
                                    referencedColumn:
                                        $$RoutineExercisesTableReferences
                                            ._supersedesIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$RoutineExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$GTDatabaseImpl,
      $RoutineExercisesTable,
      RoutineExercise,
      $$RoutineExercisesTableFilterComposer,
      $$RoutineExercisesTableOrderingComposer,
      $$RoutineExercisesTableAnnotationComposer,
      $$RoutineExercisesTableCreateCompanionBuilder,
      $$RoutineExercisesTableUpdateCompanionBuilder,
      (RoutineExercise, $$RoutineExercisesTableReferences),
      RoutineExercise,
      PrefetchHooks Function({
        bool routineId,
        bool customExerciseId,
        bool supersetId,
        bool supersedesId,
      })
    >;
typedef $$PreferencesTableCreateCompanionBuilder =
    PreferencesCompanion Function({
      required String data,
      Value<bool> onboardingComplete,
      Value<int> rowid,
    });
typedef $$PreferencesTableUpdateCompanionBuilder =
    PreferencesCompanion Function({
      Value<String> data,
      Value<bool> onboardingComplete,
      Value<int> rowid,
    });

class $$PreferencesTableFilterComposer
    extends Composer<_$GTDatabaseImpl, $PreferencesTable> {
  $$PreferencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get onboardingComplete => $composableBuilder(
    column: $table.onboardingComplete,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PreferencesTableOrderingComposer
    extends Composer<_$GTDatabaseImpl, $PreferencesTable> {
  $$PreferencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get onboardingComplete => $composableBuilder(
    column: $table.onboardingComplete,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PreferencesTableAnnotationComposer
    extends Composer<_$GTDatabaseImpl, $PreferencesTable> {
  $$PreferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<bool> get onboardingComplete => $composableBuilder(
    column: $table.onboardingComplete,
    builder: (column) => column,
  );
}

class $$PreferencesTableTableManager
    extends
        RootTableManager<
          _$GTDatabaseImpl,
          $PreferencesTable,
          Preference,
          $$PreferencesTableFilterComposer,
          $$PreferencesTableOrderingComposer,
          $$PreferencesTableAnnotationComposer,
          $$PreferencesTableCreateCompanionBuilder,
          $$PreferencesTableUpdateCompanionBuilder,
          (
            Preference,
            BaseReferences<_$GTDatabaseImpl, $PreferencesTable, Preference>,
          ),
          Preference,
          PrefetchHooks Function()
        > {
  $$PreferencesTableTableManager(_$GTDatabaseImpl db, $PreferencesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PreferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PreferencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PreferencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> data = const Value.absent(),
                Value<bool> onboardingComplete = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PreferencesCompanion(
                data: data,
                onboardingComplete: onboardingComplete,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String data,
                Value<bool> onboardingComplete = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PreferencesCompanion.insert(
                data: data,
                onboardingComplete: onboardingComplete,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PreferencesTableProcessedTableManager =
    ProcessedTableManager<
      _$GTDatabaseImpl,
      $PreferencesTable,
      Preference,
      $$PreferencesTableFilterComposer,
      $$PreferencesTableOrderingComposer,
      $$PreferencesTableAnnotationComposer,
      $$PreferencesTableCreateCompanionBuilder,
      $$PreferencesTableUpdateCompanionBuilder,
      (
        Preference,
        BaseReferences<_$GTDatabaseImpl, $PreferencesTable, Preference>,
      ),
      Preference,
      PrefetchHooks Function()
    >;
typedef $$OngoingDataTableCreateCompanionBuilder =
    OngoingDataCompanion Function({
      required String data,
      Value<String> owner,
      Value<int> rowid,
    });
typedef $$OngoingDataTableUpdateCompanionBuilder =
    OngoingDataCompanion Function({
      Value<String> data,
      Value<String> owner,
      Value<int> rowid,
    });

class $$OngoingDataTableFilterComposer
    extends Composer<_$GTDatabaseImpl, $OngoingDataTable> {
  $$OngoingDataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get owner => $composableBuilder(
    column: $table.owner,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OngoingDataTableOrderingComposer
    extends Composer<_$GTDatabaseImpl, $OngoingDataTable> {
  $$OngoingDataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get owner => $composableBuilder(
    column: $table.owner,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OngoingDataTableAnnotationComposer
    extends Composer<_$GTDatabaseImpl, $OngoingDataTable> {
  $$OngoingDataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<String> get owner =>
      $composableBuilder(column: $table.owner, builder: (column) => column);
}

class $$OngoingDataTableTableManager
    extends
        RootTableManager<
          _$GTDatabaseImpl,
          $OngoingDataTable,
          OngoingDatum,
          $$OngoingDataTableFilterComposer,
          $$OngoingDataTableOrderingComposer,
          $$OngoingDataTableAnnotationComposer,
          $$OngoingDataTableCreateCompanionBuilder,
          $$OngoingDataTableUpdateCompanionBuilder,
          (
            OngoingDatum,
            BaseReferences<_$GTDatabaseImpl, $OngoingDataTable, OngoingDatum>,
          ),
          OngoingDatum,
          PrefetchHooks Function()
        > {
  $$OngoingDataTableTableManager(_$GTDatabaseImpl db, $OngoingDataTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OngoingDataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OngoingDataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OngoingDataTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> data = const Value.absent(),
                Value<String> owner = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) =>
                  OngoingDataCompanion(data: data, owner: owner, rowid: rowid),
          createCompanionCallback:
              ({
                required String data,
                Value<String> owner = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OngoingDataCompanion.insert(
                data: data,
                owner: owner,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OngoingDataTableProcessedTableManager =
    ProcessedTableManager<
      _$GTDatabaseImpl,
      $OngoingDataTable,
      OngoingDatum,
      $$OngoingDataTableFilterComposer,
      $$OngoingDataTableOrderingComposer,
      $$OngoingDataTableAnnotationComposer,
      $$OngoingDataTableCreateCompanionBuilder,
      $$OngoingDataTableUpdateCompanionBuilder,
      (
        OngoingDatum,
        BaseReferences<_$GTDatabaseImpl, $OngoingDataTable, OngoingDatum>,
      ),
      OngoingDatum,
      PrefetchHooks Function()
    >;
typedef $$WeightMeasurementsTableCreateCompanionBuilder =
    WeightMeasurementsCompanion Function({
      Value<String> id,
      Value<String?> userId,
      Value<DateTime> updatedAt,
      Value<bool> deleted,
      required double weight,
      required DateTime time,
      required Weights weightUnit,
      Value<int> rowid,
    });
typedef $$WeightMeasurementsTableUpdateCompanionBuilder =
    WeightMeasurementsCompanion Function({
      Value<String> id,
      Value<String?> userId,
      Value<DateTime> updatedAt,
      Value<bool> deleted,
      Value<double> weight,
      Value<DateTime> time,
      Value<Weights> weightUnit,
      Value<int> rowid,
    });

class $$WeightMeasurementsTableFilterComposer
    extends Composer<_$GTDatabaseImpl, $WeightMeasurementsTable> {
  $$WeightMeasurementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get time => $composableBuilder(
    column: $table.time,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Weights, Weights, String> get weightUnit =>
      $composableBuilder(
        column: $table.weightUnit,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $$WeightMeasurementsTableOrderingComposer
    extends Composer<_$GTDatabaseImpl, $WeightMeasurementsTable> {
  $$WeightMeasurementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get time => $composableBuilder(
    column: $table.time,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weightUnit => $composableBuilder(
    column: $table.weightUnit,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WeightMeasurementsTableAnnotationComposer
    extends Composer<_$GTDatabaseImpl, $WeightMeasurementsTable> {
  $$WeightMeasurementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<DateTime> get time =>
      $composableBuilder(column: $table.time, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Weights, String> get weightUnit =>
      $composableBuilder(
        column: $table.weightUnit,
        builder: (column) => column,
      );
}

class $$WeightMeasurementsTableTableManager
    extends
        RootTableManager<
          _$GTDatabaseImpl,
          $WeightMeasurementsTable,
          WeightMeasurement,
          $$WeightMeasurementsTableFilterComposer,
          $$WeightMeasurementsTableOrderingComposer,
          $$WeightMeasurementsTableAnnotationComposer,
          $$WeightMeasurementsTableCreateCompanionBuilder,
          $$WeightMeasurementsTableUpdateCompanionBuilder,
          (
            WeightMeasurement,
            BaseReferences<
              _$GTDatabaseImpl,
              $WeightMeasurementsTable,
              WeightMeasurement
            >,
          ),
          WeightMeasurement,
          PrefetchHooks Function()
        > {
  $$WeightMeasurementsTableTableManager(
    _$GTDatabaseImpl db,
    $WeightMeasurementsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WeightMeasurementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WeightMeasurementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WeightMeasurementsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<double> weight = const Value.absent(),
                Value<DateTime> time = const Value.absent(),
                Value<Weights> weightUnit = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WeightMeasurementsCompanion(
                id: id,
                userId: userId,
                updatedAt: updatedAt,
                deleted: deleted,
                weight: weight,
                time: time,
                weightUnit: weightUnit,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                required double weight,
                required DateTime time,
                required Weights weightUnit,
                Value<int> rowid = const Value.absent(),
              }) => WeightMeasurementsCompanion.insert(
                id: id,
                userId: userId,
                updatedAt: updatedAt,
                deleted: deleted,
                weight: weight,
                time: time,
                weightUnit: weightUnit,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WeightMeasurementsTableProcessedTableManager =
    ProcessedTableManager<
      _$GTDatabaseImpl,
      $WeightMeasurementsTable,
      WeightMeasurement,
      $$WeightMeasurementsTableFilterComposer,
      $$WeightMeasurementsTableOrderingComposer,
      $$WeightMeasurementsTableAnnotationComposer,
      $$WeightMeasurementsTableCreateCompanionBuilder,
      $$WeightMeasurementsTableUpdateCompanionBuilder,
      (
        WeightMeasurement,
        BaseReferences<
          _$GTDatabaseImpl,
          $WeightMeasurementsTable,
          WeightMeasurement
        >,
      ),
      WeightMeasurement,
      PrefetchHooks Function()
    >;
typedef $$BodyMeasurementsTableCreateCompanionBuilder =
    BodyMeasurementsCompanion Function({
      Value<String> id,
      Value<String?> userId,
      Value<DateTime> updatedAt,
      Value<bool> deleted,
      required double value,
      required DateTime time,
      required BodyMeasurementPart type,
      Value<int> rowid,
    });
typedef $$BodyMeasurementsTableUpdateCompanionBuilder =
    BodyMeasurementsCompanion Function({
      Value<String> id,
      Value<String?> userId,
      Value<DateTime> updatedAt,
      Value<bool> deleted,
      Value<double> value,
      Value<DateTime> time,
      Value<BodyMeasurementPart> type,
      Value<int> rowid,
    });

class $$BodyMeasurementsTableFilterComposer
    extends Composer<_$GTDatabaseImpl, $BodyMeasurementsTable> {
  $$BodyMeasurementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get time => $composableBuilder(
    column: $table.time,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    BodyMeasurementPart,
    BodyMeasurementPart,
    String
  >
  get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );
}

class $$BodyMeasurementsTableOrderingComposer
    extends Composer<_$GTDatabaseImpl, $BodyMeasurementsTable> {
  $$BodyMeasurementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get time => $composableBuilder(
    column: $table.time,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BodyMeasurementsTableAnnotationComposer
    extends Composer<_$GTDatabaseImpl, $BodyMeasurementsTable> {
  $$BodyMeasurementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<double> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get time =>
      $composableBuilder(column: $table.time, builder: (column) => column);

  GeneratedColumnWithTypeConverter<BodyMeasurementPart, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);
}

class $$BodyMeasurementsTableTableManager
    extends
        RootTableManager<
          _$GTDatabaseImpl,
          $BodyMeasurementsTable,
          BodyMeasurement,
          $$BodyMeasurementsTableFilterComposer,
          $$BodyMeasurementsTableOrderingComposer,
          $$BodyMeasurementsTableAnnotationComposer,
          $$BodyMeasurementsTableCreateCompanionBuilder,
          $$BodyMeasurementsTableUpdateCompanionBuilder,
          (
            BodyMeasurement,
            BaseReferences<
              _$GTDatabaseImpl,
              $BodyMeasurementsTable,
              BodyMeasurement
            >,
          ),
          BodyMeasurement,
          PrefetchHooks Function()
        > {
  $$BodyMeasurementsTableTableManager(
    _$GTDatabaseImpl db,
    $BodyMeasurementsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BodyMeasurementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BodyMeasurementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BodyMeasurementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<double> value = const Value.absent(),
                Value<DateTime> time = const Value.absent(),
                Value<BodyMeasurementPart> type = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BodyMeasurementsCompanion(
                id: id,
                userId: userId,
                updatedAt: updatedAt,
                deleted: deleted,
                value: value,
                time: time,
                type: type,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                required double value,
                required DateTime time,
                required BodyMeasurementPart type,
                Value<int> rowid = const Value.absent(),
              }) => BodyMeasurementsCompanion.insert(
                id: id,
                userId: userId,
                updatedAt: updatedAt,
                deleted: deleted,
                value: value,
                time: time,
                type: type,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BodyMeasurementsTableProcessedTableManager =
    ProcessedTableManager<
      _$GTDatabaseImpl,
      $BodyMeasurementsTable,
      BodyMeasurement,
      $$BodyMeasurementsTableFilterComposer,
      $$BodyMeasurementsTableOrderingComposer,
      $$BodyMeasurementsTableAnnotationComposer,
      $$BodyMeasurementsTableCreateCompanionBuilder,
      $$BodyMeasurementsTableUpdateCompanionBuilder,
      (
        BodyMeasurement,
        BaseReferences<
          _$GTDatabaseImpl,
          $BodyMeasurementsTable,
          BodyMeasurement
        >,
      ),
      BodyMeasurement,
      PrefetchHooks Function()
    >;
typedef $$FoodsTableCreateCompanionBuilder =
    FoodsCompanion Function({
      Value<String> id,
      Value<String?> userId,
      Value<DateTime> updatedAt,
      Value<bool> deleted,
      required DateTime dateAdded,
      required DateTime referenceDate,
      required String jsonData,
      Value<int> rowid,
    });
typedef $$FoodsTableUpdateCompanionBuilder =
    FoodsCompanion Function({
      Value<String> id,
      Value<String?> userId,
      Value<DateTime> updatedAt,
      Value<bool> deleted,
      Value<DateTime> dateAdded,
      Value<DateTime> referenceDate,
      Value<String> jsonData,
      Value<int> rowid,
    });

final class $$FoodsTableReferences
    extends BaseReferences<_$GTDatabaseImpl, $FoodsTable, DBFood> {
  $$FoodsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$FavoriteFoodsTable, List<DBFavoriteFood>>
  _favoriteFoodsRefsTable(_$GTDatabaseImpl db) => MultiTypedResultKey.fromTable(
    db.favoriteFoods,
    aliasName: 'foods__id__favorite_foods__food_id',
  );

  $$FavoriteFoodsTableProcessedTableManager get favoriteFoodsRefs {
    final manager = $$FavoriteFoodsTableTableManager(
      $_db,
      $_db.favoriteFoods,
    ).filter((f) => f.id.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_favoriteFoodsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$FoodsTableFilterComposer
    extends Composer<_$GTDatabaseImpl, $FoodsTable> {
  $$FoodsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateAdded => $composableBuilder(
    column: $table.dateAdded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get referenceDate => $composableBuilder(
    column: $table.referenceDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jsonData => $composableBuilder(
    column: $table.jsonData,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> favoriteFoodsRefs(
    Expression<bool> Function($$FavoriteFoodsTableFilterComposer f) f,
  ) {
    final $$FavoriteFoodsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.favoriteFoods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FavoriteFoodsTableFilterComposer(
            $db: $db,
            $table: $db.favoriteFoods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FoodsTableOrderingComposer
    extends Composer<_$GTDatabaseImpl, $FoodsTable> {
  $$FoodsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateAdded => $composableBuilder(
    column: $table.dateAdded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get referenceDate => $composableBuilder(
    column: $table.referenceDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jsonData => $composableBuilder(
    column: $table.jsonData,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FoodsTableAnnotationComposer
    extends Composer<_$GTDatabaseImpl, $FoodsTable> {
  $$FoodsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<DateTime> get dateAdded =>
      $composableBuilder(column: $table.dateAdded, builder: (column) => column);

  GeneratedColumn<DateTime> get referenceDate => $composableBuilder(
    column: $table.referenceDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get jsonData =>
      $composableBuilder(column: $table.jsonData, builder: (column) => column);

  Expression<T> favoriteFoodsRefs<T extends Object>(
    Expression<T> Function($$FavoriteFoodsTableAnnotationComposer a) f,
  ) {
    final $$FavoriteFoodsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.favoriteFoods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FavoriteFoodsTableAnnotationComposer(
            $db: $db,
            $table: $db.favoriteFoods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FoodsTableTableManager
    extends
        RootTableManager<
          _$GTDatabaseImpl,
          $FoodsTable,
          DBFood,
          $$FoodsTableFilterComposer,
          $$FoodsTableOrderingComposer,
          $$FoodsTableAnnotationComposer,
          $$FoodsTableCreateCompanionBuilder,
          $$FoodsTableUpdateCompanionBuilder,
          (DBFood, $$FoodsTableReferences),
          DBFood,
          PrefetchHooks Function({bool favoriteFoodsRefs})
        > {
  $$FoodsTableTableManager(_$GTDatabaseImpl db, $FoodsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FoodsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FoodsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FoodsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<DateTime> dateAdded = const Value.absent(),
                Value<DateTime> referenceDate = const Value.absent(),
                Value<String> jsonData = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FoodsCompanion(
                id: id,
                userId: userId,
                updatedAt: updatedAt,
                deleted: deleted,
                dateAdded: dateAdded,
                referenceDate: referenceDate,
                jsonData: jsonData,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                required DateTime dateAdded,
                required DateTime referenceDate,
                required String jsonData,
                Value<int> rowid = const Value.absent(),
              }) => FoodsCompanion.insert(
                id: id,
                userId: userId,
                updatedAt: updatedAt,
                deleted: deleted,
                dateAdded: dateAdded,
                referenceDate: referenceDate,
                jsonData: jsonData,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$FoodsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({favoriteFoodsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (favoriteFoodsRefs) db.favoriteFoods,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (favoriteFoodsRefs)
                    await $_getPrefetchedData<
                      DBFood,
                      $FoodsTable,
                      DBFavoriteFood
                    >(
                      currentTable: table,
                      referencedTable: $$FoodsTableReferences
                          ._favoriteFoodsRefsTable(db),
                      managerFromTypedResult: (p0) => $$FoodsTableReferences(
                        db,
                        table,
                        p0,
                      ).favoriteFoodsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.id == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$FoodsTableProcessedTableManager =
    ProcessedTableManager<
      _$GTDatabaseImpl,
      $FoodsTable,
      DBFood,
      $$FoodsTableFilterComposer,
      $$FoodsTableOrderingComposer,
      $$FoodsTableAnnotationComposer,
      $$FoodsTableCreateCompanionBuilder,
      $$FoodsTableUpdateCompanionBuilder,
      (DBFood, $$FoodsTableReferences),
      DBFood,
      PrefetchHooks Function({bool favoriteFoodsRefs})
    >;
typedef $$NutritionGoalsTableCreateCompanionBuilder =
    NutritionGoalsCompanion Function({
      Value<String> id,
      Value<String?> userId,
      Value<DateTime> updatedAt,
      Value<bool> deleted,
      required DateTime referenceDate,
      required double calories,
      required double fat,
      required double carbs,
      required double protein,
      Value<int> rowid,
    });
typedef $$NutritionGoalsTableUpdateCompanionBuilder =
    NutritionGoalsCompanion Function({
      Value<String> id,
      Value<String?> userId,
      Value<DateTime> updatedAt,
      Value<bool> deleted,
      Value<DateTime> referenceDate,
      Value<double> calories,
      Value<double> fat,
      Value<double> carbs,
      Value<double> protein,
      Value<int> rowid,
    });

class $$NutritionGoalsTableFilterComposer
    extends Composer<_$GTDatabaseImpl, $NutritionGoalsTable> {
  $$NutritionGoalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get referenceDate => $composableBuilder(
    column: $table.referenceDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fat => $composableBuilder(
    column: $table.fat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbs => $composableBuilder(
    column: $table.carbs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get protein => $composableBuilder(
    column: $table.protein,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NutritionGoalsTableOrderingComposer
    extends Composer<_$GTDatabaseImpl, $NutritionGoalsTable> {
  $$NutritionGoalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get referenceDate => $composableBuilder(
    column: $table.referenceDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fat => $composableBuilder(
    column: $table.fat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbs => $composableBuilder(
    column: $table.carbs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get protein => $composableBuilder(
    column: $table.protein,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NutritionGoalsTableAnnotationComposer
    extends Composer<_$GTDatabaseImpl, $NutritionGoalsTable> {
  $$NutritionGoalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<DateTime> get referenceDate => $composableBuilder(
    column: $table.referenceDate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get calories =>
      $composableBuilder(column: $table.calories, builder: (column) => column);

  GeneratedColumn<double> get fat =>
      $composableBuilder(column: $table.fat, builder: (column) => column);

  GeneratedColumn<double> get carbs =>
      $composableBuilder(column: $table.carbs, builder: (column) => column);

  GeneratedColumn<double> get protein =>
      $composableBuilder(column: $table.protein, builder: (column) => column);
}

class $$NutritionGoalsTableTableManager
    extends
        RootTableManager<
          _$GTDatabaseImpl,
          $NutritionGoalsTable,
          DBNutritionGoal,
          $$NutritionGoalsTableFilterComposer,
          $$NutritionGoalsTableOrderingComposer,
          $$NutritionGoalsTableAnnotationComposer,
          $$NutritionGoalsTableCreateCompanionBuilder,
          $$NutritionGoalsTableUpdateCompanionBuilder,
          (
            DBNutritionGoal,
            BaseReferences<
              _$GTDatabaseImpl,
              $NutritionGoalsTable,
              DBNutritionGoal
            >,
          ),
          DBNutritionGoal,
          PrefetchHooks Function()
        > {
  $$NutritionGoalsTableTableManager(
    _$GTDatabaseImpl db,
    $NutritionGoalsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NutritionGoalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NutritionGoalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NutritionGoalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<DateTime> referenceDate = const Value.absent(),
                Value<double> calories = const Value.absent(),
                Value<double> fat = const Value.absent(),
                Value<double> carbs = const Value.absent(),
                Value<double> protein = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NutritionGoalsCompanion(
                id: id,
                userId: userId,
                updatedAt: updatedAt,
                deleted: deleted,
                referenceDate: referenceDate,
                calories: calories,
                fat: fat,
                carbs: carbs,
                protein: protein,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                required DateTime referenceDate,
                required double calories,
                required double fat,
                required double carbs,
                required double protein,
                Value<int> rowid = const Value.absent(),
              }) => NutritionGoalsCompanion.insert(
                id: id,
                userId: userId,
                updatedAt: updatedAt,
                deleted: deleted,
                referenceDate: referenceDate,
                calories: calories,
                fat: fat,
                carbs: carbs,
                protein: protein,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NutritionGoalsTableProcessedTableManager =
    ProcessedTableManager<
      _$GTDatabaseImpl,
      $NutritionGoalsTable,
      DBNutritionGoal,
      $$NutritionGoalsTableFilterComposer,
      $$NutritionGoalsTableOrderingComposer,
      $$NutritionGoalsTableAnnotationComposer,
      $$NutritionGoalsTableCreateCompanionBuilder,
      $$NutritionGoalsTableUpdateCompanionBuilder,
      (
        DBNutritionGoal,
        BaseReferences<_$GTDatabaseImpl, $NutritionGoalsTable, DBNutritionGoal>,
      ),
      DBNutritionGoal,
      PrefetchHooks Function()
    >;
typedef $$CustomBarcodeFoodsTableCreateCompanionBuilder =
    CustomBarcodeFoodsCompanion Function({
      required String id,
      Value<String?> userId,
      Value<DateTime> updatedAt,
      Value<bool> deleted,
      required String jsonData,
      Value<int> rowid,
    });
typedef $$CustomBarcodeFoodsTableUpdateCompanionBuilder =
    CustomBarcodeFoodsCompanion Function({
      Value<String> id,
      Value<String?> userId,
      Value<DateTime> updatedAt,
      Value<bool> deleted,
      Value<String> jsonData,
      Value<int> rowid,
    });

class $$CustomBarcodeFoodsTableFilterComposer
    extends Composer<_$GTDatabaseImpl, $CustomBarcodeFoodsTable> {
  $$CustomBarcodeFoodsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jsonData => $composableBuilder(
    column: $table.jsonData,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CustomBarcodeFoodsTableOrderingComposer
    extends Composer<_$GTDatabaseImpl, $CustomBarcodeFoodsTable> {
  $$CustomBarcodeFoodsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jsonData => $composableBuilder(
    column: $table.jsonData,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomBarcodeFoodsTableAnnotationComposer
    extends Composer<_$GTDatabaseImpl, $CustomBarcodeFoodsTable> {
  $$CustomBarcodeFoodsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get jsonData =>
      $composableBuilder(column: $table.jsonData, builder: (column) => column);
}

class $$CustomBarcodeFoodsTableTableManager
    extends
        RootTableManager<
          _$GTDatabaseImpl,
          $CustomBarcodeFoodsTable,
          DBCustomBarcodeFood,
          $$CustomBarcodeFoodsTableFilterComposer,
          $$CustomBarcodeFoodsTableOrderingComposer,
          $$CustomBarcodeFoodsTableAnnotationComposer,
          $$CustomBarcodeFoodsTableCreateCompanionBuilder,
          $$CustomBarcodeFoodsTableUpdateCompanionBuilder,
          (
            DBCustomBarcodeFood,
            BaseReferences<
              _$GTDatabaseImpl,
              $CustomBarcodeFoodsTable,
              DBCustomBarcodeFood
            >,
          ),
          DBCustomBarcodeFood,
          PrefetchHooks Function()
        > {
  $$CustomBarcodeFoodsTableTableManager(
    _$GTDatabaseImpl db,
    $CustomBarcodeFoodsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomBarcodeFoodsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomBarcodeFoodsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomBarcodeFoodsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> jsonData = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomBarcodeFoodsCompanion(
                id: id,
                userId: userId,
                updatedAt: updatedAt,
                deleted: deleted,
                jsonData: jsonData,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> userId = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                required String jsonData,
                Value<int> rowid = const Value.absent(),
              }) => CustomBarcodeFoodsCompanion.insert(
                id: id,
                userId: userId,
                updatedAt: updatedAt,
                deleted: deleted,
                jsonData: jsonData,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CustomBarcodeFoodsTableProcessedTableManager =
    ProcessedTableManager<
      _$GTDatabaseImpl,
      $CustomBarcodeFoodsTable,
      DBCustomBarcodeFood,
      $$CustomBarcodeFoodsTableFilterComposer,
      $$CustomBarcodeFoodsTableOrderingComposer,
      $$CustomBarcodeFoodsTableAnnotationComposer,
      $$CustomBarcodeFoodsTableCreateCompanionBuilder,
      $$CustomBarcodeFoodsTableUpdateCompanionBuilder,
      (
        DBCustomBarcodeFood,
        BaseReferences<
          _$GTDatabaseImpl,
          $CustomBarcodeFoodsTable,
          DBCustomBarcodeFood
        >,
      ),
      DBCustomBarcodeFood,
      PrefetchHooks Function()
    >;
typedef $$FavoriteFoodsTableCreateCompanionBuilder =
    FavoriteFoodsCompanion Function({
      required String id,
      Value<String?> userId,
      Value<DateTime> updatedAt,
      Value<bool> deleted,
      Value<int> rowid,
    });
typedef $$FavoriteFoodsTableUpdateCompanionBuilder =
    FavoriteFoodsCompanion Function({
      Value<String> id,
      Value<String?> userId,
      Value<DateTime> updatedAt,
      Value<bool> deleted,
      Value<int> rowid,
    });

final class $$FavoriteFoodsTableReferences
    extends
        BaseReferences<_$GTDatabaseImpl, $FavoriteFoodsTable, DBFavoriteFood> {
  $$FavoriteFoodsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $FoodsTable _idTable(_$GTDatabaseImpl db) =>
      db.foods.createAlias('favorite_foods__food_id__foods__id');

  $$FoodsTableProcessedTableManager get id {
    final $_column = $_itemColumn<String>('food_id')!;

    final manager = $$FoodsTableTableManager(
      $_db,
      $_db.foods,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_idTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$FavoriteFoodsTableFilterComposer
    extends Composer<_$GTDatabaseImpl, $FavoriteFoodsTable> {
  $$FavoriteFoodsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  $$FoodsTableFilterComposer get id {
    final $$FoodsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.foods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoodsTableFilterComposer(
            $db: $db,
            $table: $db.foods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FavoriteFoodsTableOrderingComposer
    extends Composer<_$GTDatabaseImpl, $FavoriteFoodsTable> {
  $$FavoriteFoodsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  $$FoodsTableOrderingComposer get id {
    final $$FoodsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.foods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoodsTableOrderingComposer(
            $db: $db,
            $table: $db.foods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FavoriteFoodsTableAnnotationComposer
    extends Composer<_$GTDatabaseImpl, $FavoriteFoodsTable> {
  $$FavoriteFoodsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  $$FoodsTableAnnotationComposer get id {
    final $$FoodsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.foods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoodsTableAnnotationComposer(
            $db: $db,
            $table: $db.foods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FavoriteFoodsTableTableManager
    extends
        RootTableManager<
          _$GTDatabaseImpl,
          $FavoriteFoodsTable,
          DBFavoriteFood,
          $$FavoriteFoodsTableFilterComposer,
          $$FavoriteFoodsTableOrderingComposer,
          $$FavoriteFoodsTableAnnotationComposer,
          $$FavoriteFoodsTableCreateCompanionBuilder,
          $$FavoriteFoodsTableUpdateCompanionBuilder,
          (DBFavoriteFood, $$FavoriteFoodsTableReferences),
          DBFavoriteFood,
          PrefetchHooks Function({bool id})
        > {
  $$FavoriteFoodsTableTableManager(
    _$GTDatabaseImpl db,
    $FavoriteFoodsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FavoriteFoodsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FavoriteFoodsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FavoriteFoodsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FavoriteFoodsCompanion(
                id: id,
                userId: userId,
                updatedAt: updatedAt,
                deleted: deleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> userId = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FavoriteFoodsCompanion.insert(
                id: id,
                userId: userId,
                updatedAt: updatedAt,
                deleted: deleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$FavoriteFoodsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({id = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (id) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.id,
                                referencedTable: $$FavoriteFoodsTableReferences
                                    ._idTable(db),
                                referencedColumn: $$FavoriteFoodsTableReferences
                                    ._idTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$FavoriteFoodsTableProcessedTableManager =
    ProcessedTableManager<
      _$GTDatabaseImpl,
      $FavoriteFoodsTable,
      DBFavoriteFood,
      $$FavoriteFoodsTableFilterComposer,
      $$FavoriteFoodsTableOrderingComposer,
      $$FavoriteFoodsTableAnnotationComposer,
      $$FavoriteFoodsTableCreateCompanionBuilder,
      $$FavoriteFoodsTableUpdateCompanionBuilder,
      (DBFavoriteFood, $$FavoriteFoodsTableReferences),
      DBFavoriteFood,
      PrefetchHooks Function({bool id})
    >;
typedef $$NutritionCategoriesTableCreateCompanionBuilder =
    NutritionCategoriesCompanion Function({
      Value<String?> id,
      Value<String?> userId,
      Value<DateTime> updatedAt,
      Value<bool> deleted,
      required DateTime referenceDate,
      required String jsonData,
      Value<int> rowid,
    });
typedef $$NutritionCategoriesTableUpdateCompanionBuilder =
    NutritionCategoriesCompanion Function({
      Value<String?> id,
      Value<String?> userId,
      Value<DateTime> updatedAt,
      Value<bool> deleted,
      Value<DateTime> referenceDate,
      Value<String> jsonData,
      Value<int> rowid,
    });

class $$NutritionCategoriesTableFilterComposer
    extends Composer<_$GTDatabaseImpl, $NutritionCategoriesTable> {
  $$NutritionCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get referenceDate => $composableBuilder(
    column: $table.referenceDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jsonData => $composableBuilder(
    column: $table.jsonData,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NutritionCategoriesTableOrderingComposer
    extends Composer<_$GTDatabaseImpl, $NutritionCategoriesTable> {
  $$NutritionCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get referenceDate => $composableBuilder(
    column: $table.referenceDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jsonData => $composableBuilder(
    column: $table.jsonData,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NutritionCategoriesTableAnnotationComposer
    extends Composer<_$GTDatabaseImpl, $NutritionCategoriesTable> {
  $$NutritionCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<DateTime> get referenceDate => $composableBuilder(
    column: $table.referenceDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get jsonData =>
      $composableBuilder(column: $table.jsonData, builder: (column) => column);
}

class $$NutritionCategoriesTableTableManager
    extends
        RootTableManager<
          _$GTDatabaseImpl,
          $NutritionCategoriesTable,
          DBNutritionCategory,
          $$NutritionCategoriesTableFilterComposer,
          $$NutritionCategoriesTableOrderingComposer,
          $$NutritionCategoriesTableAnnotationComposer,
          $$NutritionCategoriesTableCreateCompanionBuilder,
          $$NutritionCategoriesTableUpdateCompanionBuilder,
          (
            DBNutritionCategory,
            BaseReferences<
              _$GTDatabaseImpl,
              $NutritionCategoriesTable,
              DBNutritionCategory
            >,
          ),
          DBNutritionCategory,
          PrefetchHooks Function()
        > {
  $$NutritionCategoriesTableTableManager(
    _$GTDatabaseImpl db,
    $NutritionCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NutritionCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NutritionCategoriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$NutritionCategoriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String?> id = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<DateTime> referenceDate = const Value.absent(),
                Value<String> jsonData = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NutritionCategoriesCompanion(
                id: id,
                userId: userId,
                updatedAt: updatedAt,
                deleted: deleted,
                referenceDate: referenceDate,
                jsonData: jsonData,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String?> id = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                required DateTime referenceDate,
                required String jsonData,
                Value<int> rowid = const Value.absent(),
              }) => NutritionCategoriesCompanion.insert(
                id: id,
                userId: userId,
                updatedAt: updatedAt,
                deleted: deleted,
                referenceDate: referenceDate,
                jsonData: jsonData,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NutritionCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$GTDatabaseImpl,
      $NutritionCategoriesTable,
      DBNutritionCategory,
      $$NutritionCategoriesTableFilterComposer,
      $$NutritionCategoriesTableOrderingComposer,
      $$NutritionCategoriesTableAnnotationComposer,
      $$NutritionCategoriesTableCreateCompanionBuilder,
      $$NutritionCategoriesTableUpdateCompanionBuilder,
      (
        DBNutritionCategory,
        BaseReferences<
          _$GTDatabaseImpl,
          $NutritionCategoriesTable,
          DBNutritionCategory
        >,
      ),
      DBNutritionCategory,
      PrefetchHooks Function()
    >;
typedef $$AchievementsTableCreateCompanionBuilder =
    AchievementsCompanion Function({
      Value<String?> userId,
      Value<DateTime> updatedAt,
      Value<bool> deleted,
      Value<String> achievementID,
      required int level,
      required DateTime completedAt,
      Value<int> rowid,
    });
typedef $$AchievementsTableUpdateCompanionBuilder =
    AchievementsCompanion Function({
      Value<String?> userId,
      Value<DateTime> updatedAt,
      Value<bool> deleted,
      Value<String> achievementID,
      Value<int> level,
      Value<DateTime> completedAt,
      Value<int> rowid,
    });

class $$AchievementsTableFilterComposer
    extends Composer<_$GTDatabaseImpl, $AchievementsTable> {
  $$AchievementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get achievementID => $composableBuilder(
    column: $table.achievementID,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AchievementsTableOrderingComposer
    extends Composer<_$GTDatabaseImpl, $AchievementsTable> {
  $$AchievementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get achievementID => $composableBuilder(
    column: $table.achievementID,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AchievementsTableAnnotationComposer
    extends Composer<_$GTDatabaseImpl, $AchievementsTable> {
  $$AchievementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get achievementID => $composableBuilder(
    column: $table.achievementID,
    builder: (column) => column,
  );

  GeneratedColumn<int> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );
}

class $$AchievementsTableTableManager
    extends
        RootTableManager<
          _$GTDatabaseImpl,
          $AchievementsTable,
          AchievementCompletion,
          $$AchievementsTableFilterComposer,
          $$AchievementsTableOrderingComposer,
          $$AchievementsTableAnnotationComposer,
          $$AchievementsTableCreateCompanionBuilder,
          $$AchievementsTableUpdateCompanionBuilder,
          (
            AchievementCompletion,
            BaseReferences<
              _$GTDatabaseImpl,
              $AchievementsTable,
              AchievementCompletion
            >,
          ),
          AchievementCompletion,
          PrefetchHooks Function()
        > {
  $$AchievementsTableTableManager(_$GTDatabaseImpl db, $AchievementsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AchievementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AchievementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AchievementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String?> userId = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> achievementID = const Value.absent(),
                Value<int> level = const Value.absent(),
                Value<DateTime> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AchievementsCompanion(
                userId: userId,
                updatedAt: updatedAt,
                deleted: deleted,
                achievementID: achievementID,
                level: level,
                completedAt: completedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String?> userId = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> achievementID = const Value.absent(),
                required int level,
                required DateTime completedAt,
                Value<int> rowid = const Value.absent(),
              }) => AchievementsCompanion.insert(
                userId: userId,
                updatedAt: updatedAt,
                deleted: deleted,
                achievementID: achievementID,
                level: level,
                completedAt: completedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AchievementsTableProcessedTableManager =
    ProcessedTableManager<
      _$GTDatabaseImpl,
      $AchievementsTable,
      AchievementCompletion,
      $$AchievementsTableFilterComposer,
      $$AchievementsTableOrderingComposer,
      $$AchievementsTableAnnotationComposer,
      $$AchievementsTableCreateCompanionBuilder,
      $$AchievementsTableUpdateCompanionBuilder,
      (
        AchievementCompletion,
        BaseReferences<
          _$GTDatabaseImpl,
          $AchievementsTable,
          AchievementCompletion
        >,
      ),
      AchievementCompletion,
      PrefetchHooks Function()
    >;
typedef $$SyncOutboxTableCreateCompanionBuilder =
    SyncOutboxCompanion Function({
      Value<int> sequence,
      required String operationId,
      required String owner,
      required String entity,
      required String recordId,
      Value<int> baseRevision,
      required String payload,
      Value<int> attempts,
      Value<String?> error,
      Value<bool> blocked,
    });
typedef $$SyncOutboxTableUpdateCompanionBuilder =
    SyncOutboxCompanion Function({
      Value<int> sequence,
      Value<String> operationId,
      Value<String> owner,
      Value<String> entity,
      Value<String> recordId,
      Value<int> baseRevision,
      Value<String> payload,
      Value<int> attempts,
      Value<String?> error,
      Value<bool> blocked,
    });

class $$SyncOutboxTableFilterComposer
    extends Composer<_$GTDatabaseImpl, $SyncOutboxTable> {
  $$SyncOutboxTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get owner => $composableBuilder(
    column: $table.owner,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get baseRevision => $composableBuilder(
    column: $table.baseRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get blocked => $composableBuilder(
    column: $table.blocked,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncOutboxTableOrderingComposer
    extends Composer<_$GTDatabaseImpl, $SyncOutboxTable> {
  $$SyncOutboxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get owner => $composableBuilder(
    column: $table.owner,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get baseRevision => $composableBuilder(
    column: $table.baseRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get blocked => $composableBuilder(
    column: $table.blocked,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncOutboxTableAnnotationComposer
    extends Composer<_$GTDatabaseImpl, $SyncOutboxTable> {
  $$SyncOutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get sequence =>
      $composableBuilder(column: $table.sequence, builder: (column) => column);

  GeneratedColumn<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get owner =>
      $composableBuilder(column: $table.owner, builder: (column) => column);

  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<String> get recordId =>
      $composableBuilder(column: $table.recordId, builder: (column) => column);

  GeneratedColumn<int> get baseRevision => $composableBuilder(
    column: $table.baseRevision,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<String> get error =>
      $composableBuilder(column: $table.error, builder: (column) => column);

  GeneratedColumn<bool> get blocked =>
      $composableBuilder(column: $table.blocked, builder: (column) => column);
}

class $$SyncOutboxTableTableManager
    extends
        RootTableManager<
          _$GTDatabaseImpl,
          $SyncOutboxTable,
          SyncOutboxData,
          $$SyncOutboxTableFilterComposer,
          $$SyncOutboxTableOrderingComposer,
          $$SyncOutboxTableAnnotationComposer,
          $$SyncOutboxTableCreateCompanionBuilder,
          $$SyncOutboxTableUpdateCompanionBuilder,
          (
            SyncOutboxData,
            BaseReferences<_$GTDatabaseImpl, $SyncOutboxTable, SyncOutboxData>,
          ),
          SyncOutboxData,
          PrefetchHooks Function()
        > {
  $$SyncOutboxTableTableManager(_$GTDatabaseImpl db, $SyncOutboxTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncOutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncOutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncOutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> sequence = const Value.absent(),
                Value<String> operationId = const Value.absent(),
                Value<String> owner = const Value.absent(),
                Value<String> entity = const Value.absent(),
                Value<String> recordId = const Value.absent(),
                Value<int> baseRevision = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<String?> error = const Value.absent(),
                Value<bool> blocked = const Value.absent(),
              }) => SyncOutboxCompanion(
                sequence: sequence,
                operationId: operationId,
                owner: owner,
                entity: entity,
                recordId: recordId,
                baseRevision: baseRevision,
                payload: payload,
                attempts: attempts,
                error: error,
                blocked: blocked,
              ),
          createCompanionCallback:
              ({
                Value<int> sequence = const Value.absent(),
                required String operationId,
                required String owner,
                required String entity,
                required String recordId,
                Value<int> baseRevision = const Value.absent(),
                required String payload,
                Value<int> attempts = const Value.absent(),
                Value<String?> error = const Value.absent(),
                Value<bool> blocked = const Value.absent(),
              }) => SyncOutboxCompanion.insert(
                sequence: sequence,
                operationId: operationId,
                owner: owner,
                entity: entity,
                recordId: recordId,
                baseRevision: baseRevision,
                payload: payload,
                attempts: attempts,
                error: error,
                blocked: blocked,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncOutboxTableProcessedTableManager =
    ProcessedTableManager<
      _$GTDatabaseImpl,
      $SyncOutboxTable,
      SyncOutboxData,
      $$SyncOutboxTableFilterComposer,
      $$SyncOutboxTableOrderingComposer,
      $$SyncOutboxTableAnnotationComposer,
      $$SyncOutboxTableCreateCompanionBuilder,
      $$SyncOutboxTableUpdateCompanionBuilder,
      (
        SyncOutboxData,
        BaseReferences<_$GTDatabaseImpl, $SyncOutboxTable, SyncOutboxData>,
      ),
      SyncOutboxData,
      PrefetchHooks Function()
    >;
typedef $$SyncMetadataTableCreateCompanionBuilder =
    SyncMetadataCompanion Function({
      required String owner,
      required String entity,
      required String recordId,
      required int revision,
      required String payload,
      Value<int> rowid,
    });
typedef $$SyncMetadataTableUpdateCompanionBuilder =
    SyncMetadataCompanion Function({
      Value<String> owner,
      Value<String> entity,
      Value<String> recordId,
      Value<int> revision,
      Value<String> payload,
      Value<int> rowid,
    });

class $$SyncMetadataTableFilterComposer
    extends Composer<_$GTDatabaseImpl, $SyncMetadataTable> {
  $$SyncMetadataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get owner => $composableBuilder(
    column: $table.owner,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncMetadataTableOrderingComposer
    extends Composer<_$GTDatabaseImpl, $SyncMetadataTable> {
  $$SyncMetadataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get owner => $composableBuilder(
    column: $table.owner,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncMetadataTableAnnotationComposer
    extends Composer<_$GTDatabaseImpl, $SyncMetadataTable> {
  $$SyncMetadataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get owner =>
      $composableBuilder(column: $table.owner, builder: (column) => column);

  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<String> get recordId =>
      $composableBuilder(column: $table.recordId, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);
}

class $$SyncMetadataTableTableManager
    extends
        RootTableManager<
          _$GTDatabaseImpl,
          $SyncMetadataTable,
          SyncMetadataData,
          $$SyncMetadataTableFilterComposer,
          $$SyncMetadataTableOrderingComposer,
          $$SyncMetadataTableAnnotationComposer,
          $$SyncMetadataTableCreateCompanionBuilder,
          $$SyncMetadataTableUpdateCompanionBuilder,
          (
            SyncMetadataData,
            BaseReferences<
              _$GTDatabaseImpl,
              $SyncMetadataTable,
              SyncMetadataData
            >,
          ),
          SyncMetadataData,
          PrefetchHooks Function()
        > {
  $$SyncMetadataTableTableManager(_$GTDatabaseImpl db, $SyncMetadataTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncMetadataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncMetadataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncMetadataTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> owner = const Value.absent(),
                Value<String> entity = const Value.absent(),
                Value<String> recordId = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncMetadataCompanion(
                owner: owner,
                entity: entity,
                recordId: recordId,
                revision: revision,
                payload: payload,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String owner,
                required String entity,
                required String recordId,
                required int revision,
                required String payload,
                Value<int> rowid = const Value.absent(),
              }) => SyncMetadataCompanion.insert(
                owner: owner,
                entity: entity,
                recordId: recordId,
                revision: revision,
                payload: payload,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncMetadataTableProcessedTableManager =
    ProcessedTableManager<
      _$GTDatabaseImpl,
      $SyncMetadataTable,
      SyncMetadataData,
      $$SyncMetadataTableFilterComposer,
      $$SyncMetadataTableOrderingComposer,
      $$SyncMetadataTableAnnotationComposer,
      $$SyncMetadataTableCreateCompanionBuilder,
      $$SyncMetadataTableUpdateCompanionBuilder,
      (
        SyncMetadataData,
        BaseReferences<_$GTDatabaseImpl, $SyncMetadataTable, SyncMetadataData>,
      ),
      SyncMetadataData,
      PrefetchHooks Function()
    >;
typedef $$SyncCursorsTableCreateCompanionBuilder =
    SyncCursorsCompanion Function({
      required String owner,
      Value<int> cursor,
      Value<int> reconcileCursor,
      Value<int?> reconcileHorizon,
      Value<bool> bootstrapped,
      Value<DateTime?> reconciledAt,
      Value<int> rowid,
    });
typedef $$SyncCursorsTableUpdateCompanionBuilder =
    SyncCursorsCompanion Function({
      Value<String> owner,
      Value<int> cursor,
      Value<int> reconcileCursor,
      Value<int?> reconcileHorizon,
      Value<bool> bootstrapped,
      Value<DateTime?> reconciledAt,
      Value<int> rowid,
    });

class $$SyncCursorsTableFilterComposer
    extends Composer<_$GTDatabaseImpl, $SyncCursorsTable> {
  $$SyncCursorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get owner => $composableBuilder(
    column: $table.owner,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cursor => $composableBuilder(
    column: $table.cursor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reconcileCursor => $composableBuilder(
    column: $table.reconcileCursor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reconcileHorizon => $composableBuilder(
    column: $table.reconcileHorizon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get bootstrapped => $composableBuilder(
    column: $table.bootstrapped,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get reconciledAt => $composableBuilder(
    column: $table.reconciledAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncCursorsTableOrderingComposer
    extends Composer<_$GTDatabaseImpl, $SyncCursorsTable> {
  $$SyncCursorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get owner => $composableBuilder(
    column: $table.owner,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cursor => $composableBuilder(
    column: $table.cursor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reconcileCursor => $composableBuilder(
    column: $table.reconcileCursor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reconcileHorizon => $composableBuilder(
    column: $table.reconcileHorizon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get bootstrapped => $composableBuilder(
    column: $table.bootstrapped,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get reconciledAt => $composableBuilder(
    column: $table.reconciledAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncCursorsTableAnnotationComposer
    extends Composer<_$GTDatabaseImpl, $SyncCursorsTable> {
  $$SyncCursorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get owner =>
      $composableBuilder(column: $table.owner, builder: (column) => column);

  GeneratedColumn<int> get cursor =>
      $composableBuilder(column: $table.cursor, builder: (column) => column);

  GeneratedColumn<int> get reconcileCursor => $composableBuilder(
    column: $table.reconcileCursor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reconcileHorizon => $composableBuilder(
    column: $table.reconcileHorizon,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get bootstrapped => $composableBuilder(
    column: $table.bootstrapped,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get reconciledAt => $composableBuilder(
    column: $table.reconciledAt,
    builder: (column) => column,
  );
}

class $$SyncCursorsTableTableManager
    extends
        RootTableManager<
          _$GTDatabaseImpl,
          $SyncCursorsTable,
          SyncCursor,
          $$SyncCursorsTableFilterComposer,
          $$SyncCursorsTableOrderingComposer,
          $$SyncCursorsTableAnnotationComposer,
          $$SyncCursorsTableCreateCompanionBuilder,
          $$SyncCursorsTableUpdateCompanionBuilder,
          (
            SyncCursor,
            BaseReferences<_$GTDatabaseImpl, $SyncCursorsTable, SyncCursor>,
          ),
          SyncCursor,
          PrefetchHooks Function()
        > {
  $$SyncCursorsTableTableManager(_$GTDatabaseImpl db, $SyncCursorsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncCursorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncCursorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncCursorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> owner = const Value.absent(),
                Value<int> cursor = const Value.absent(),
                Value<int> reconcileCursor = const Value.absent(),
                Value<int?> reconcileHorizon = const Value.absent(),
                Value<bool> bootstrapped = const Value.absent(),
                Value<DateTime?> reconciledAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncCursorsCompanion(
                owner: owner,
                cursor: cursor,
                reconcileCursor: reconcileCursor,
                reconcileHorizon: reconcileHorizon,
                bootstrapped: bootstrapped,
                reconciledAt: reconciledAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String owner,
                Value<int> cursor = const Value.absent(),
                Value<int> reconcileCursor = const Value.absent(),
                Value<int?> reconcileHorizon = const Value.absent(),
                Value<bool> bootstrapped = const Value.absent(),
                Value<DateTime?> reconciledAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncCursorsCompanion.insert(
                owner: owner,
                cursor: cursor,
                reconcileCursor: reconcileCursor,
                reconcileHorizon: reconcileHorizon,
                bootstrapped: bootstrapped,
                reconciledAt: reconciledAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncCursorsTableProcessedTableManager =
    ProcessedTableManager<
      _$GTDatabaseImpl,
      $SyncCursorsTable,
      SyncCursor,
      $$SyncCursorsTableFilterComposer,
      $$SyncCursorsTableOrderingComposer,
      $$SyncCursorsTableAnnotationComposer,
      $$SyncCursorsTableCreateCompanionBuilder,
      $$SyncCursorsTableUpdateCompanionBuilder,
      (
        SyncCursor,
        BaseReferences<_$GTDatabaseImpl, $SyncCursorsTable, SyncCursor>,
      ),
      SyncCursor,
      PrefetchHooks Function()
    >;
typedef $$SyncConflictsTableCreateCompanionBuilder =
    SyncConflictsCompanion Function({
      required String operationId,
      required String owner,
      required String entity,
      required String recordId,
      required String localPayload,
      required String serverPayload,
      required int serverRevision,
      Value<bool> resolved,
      Value<int> rowid,
    });
typedef $$SyncConflictsTableUpdateCompanionBuilder =
    SyncConflictsCompanion Function({
      Value<String> operationId,
      Value<String> owner,
      Value<String> entity,
      Value<String> recordId,
      Value<String> localPayload,
      Value<String> serverPayload,
      Value<int> serverRevision,
      Value<bool> resolved,
      Value<int> rowid,
    });

class $$SyncConflictsTableFilterComposer
    extends Composer<_$GTDatabaseImpl, $SyncConflictsTable> {
  $$SyncConflictsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get owner => $composableBuilder(
    column: $table.owner,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPayload => $composableBuilder(
    column: $table.localPayload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverPayload => $composableBuilder(
    column: $table.serverPayload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverRevision => $composableBuilder(
    column: $table.serverRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get resolved => $composableBuilder(
    column: $table.resolved,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncConflictsTableOrderingComposer
    extends Composer<_$GTDatabaseImpl, $SyncConflictsTable> {
  $$SyncConflictsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get owner => $composableBuilder(
    column: $table.owner,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPayload => $composableBuilder(
    column: $table.localPayload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverPayload => $composableBuilder(
    column: $table.serverPayload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverRevision => $composableBuilder(
    column: $table.serverRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get resolved => $composableBuilder(
    column: $table.resolved,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncConflictsTableAnnotationComposer
    extends Composer<_$GTDatabaseImpl, $SyncConflictsTable> {
  $$SyncConflictsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get owner =>
      $composableBuilder(column: $table.owner, builder: (column) => column);

  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<String> get recordId =>
      $composableBuilder(column: $table.recordId, builder: (column) => column);

  GeneratedColumn<String> get localPayload => $composableBuilder(
    column: $table.localPayload,
    builder: (column) => column,
  );

  GeneratedColumn<String> get serverPayload => $composableBuilder(
    column: $table.serverPayload,
    builder: (column) => column,
  );

  GeneratedColumn<int> get serverRevision => $composableBuilder(
    column: $table.serverRevision,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get resolved =>
      $composableBuilder(column: $table.resolved, builder: (column) => column);
}

class $$SyncConflictsTableTableManager
    extends
        RootTableManager<
          _$GTDatabaseImpl,
          $SyncConflictsTable,
          SyncConflict,
          $$SyncConflictsTableFilterComposer,
          $$SyncConflictsTableOrderingComposer,
          $$SyncConflictsTableAnnotationComposer,
          $$SyncConflictsTableCreateCompanionBuilder,
          $$SyncConflictsTableUpdateCompanionBuilder,
          (
            SyncConflict,
            BaseReferences<_$GTDatabaseImpl, $SyncConflictsTable, SyncConflict>,
          ),
          SyncConflict,
          PrefetchHooks Function()
        > {
  $$SyncConflictsTableTableManager(
    _$GTDatabaseImpl db,
    $SyncConflictsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncConflictsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncConflictsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncConflictsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> operationId = const Value.absent(),
                Value<String> owner = const Value.absent(),
                Value<String> entity = const Value.absent(),
                Value<String> recordId = const Value.absent(),
                Value<String> localPayload = const Value.absent(),
                Value<String> serverPayload = const Value.absent(),
                Value<int> serverRevision = const Value.absent(),
                Value<bool> resolved = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncConflictsCompanion(
                operationId: operationId,
                owner: owner,
                entity: entity,
                recordId: recordId,
                localPayload: localPayload,
                serverPayload: serverPayload,
                serverRevision: serverRevision,
                resolved: resolved,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String operationId,
                required String owner,
                required String entity,
                required String recordId,
                required String localPayload,
                required String serverPayload,
                required int serverRevision,
                Value<bool> resolved = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncConflictsCompanion.insert(
                operationId: operationId,
                owner: owner,
                entity: entity,
                recordId: recordId,
                localPayload: localPayload,
                serverPayload: serverPayload,
                serverRevision: serverRevision,
                resolved: resolved,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncConflictsTableProcessedTableManager =
    ProcessedTableManager<
      _$GTDatabaseImpl,
      $SyncConflictsTable,
      SyncConflict,
      $$SyncConflictsTableFilterComposer,
      $$SyncConflictsTableOrderingComposer,
      $$SyncConflictsTableAnnotationComposer,
      $$SyncConflictsTableCreateCompanionBuilder,
      $$SyncConflictsTableUpdateCompanionBuilder,
      (
        SyncConflict,
        BaseReferences<_$GTDatabaseImpl, $SyncConflictsTable, SyncConflict>,
      ),
      SyncConflict,
      PrefetchHooks Function()
    >;
typedef $$SyncContextTableCreateCompanionBuilder =
    SyncContextCompanion Function({Value<int> id, Value<bool> receiving});
typedef $$SyncContextTableUpdateCompanionBuilder =
    SyncContextCompanion Function({Value<int> id, Value<bool> receiving});

class $$SyncContextTableFilterComposer
    extends Composer<_$GTDatabaseImpl, $SyncContextTable> {
  $$SyncContextTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get receiving => $composableBuilder(
    column: $table.receiving,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncContextTableOrderingComposer
    extends Composer<_$GTDatabaseImpl, $SyncContextTable> {
  $$SyncContextTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get receiving => $composableBuilder(
    column: $table.receiving,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncContextTableAnnotationComposer
    extends Composer<_$GTDatabaseImpl, $SyncContextTable> {
  $$SyncContextTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get receiving =>
      $composableBuilder(column: $table.receiving, builder: (column) => column);
}

class $$SyncContextTableTableManager
    extends
        RootTableManager<
          _$GTDatabaseImpl,
          $SyncContextTable,
          SyncContextData,
          $$SyncContextTableFilterComposer,
          $$SyncContextTableOrderingComposer,
          $$SyncContextTableAnnotationComposer,
          $$SyncContextTableCreateCompanionBuilder,
          $$SyncContextTableUpdateCompanionBuilder,
          (
            SyncContextData,
            BaseReferences<
              _$GTDatabaseImpl,
              $SyncContextTable,
              SyncContextData
            >,
          ),
          SyncContextData,
          PrefetchHooks Function()
        > {
  $$SyncContextTableTableManager(_$GTDatabaseImpl db, $SyncContextTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncContextTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncContextTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncContextTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> receiving = const Value.absent(),
              }) => SyncContextCompanion(id: id, receiving: receiving),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> receiving = const Value.absent(),
              }) => SyncContextCompanion.insert(id: id, receiving: receiving),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncContextTableProcessedTableManager =
    ProcessedTableManager<
      _$GTDatabaseImpl,
      $SyncContextTable,
      SyncContextData,
      $$SyncContextTableFilterComposer,
      $$SyncContextTableOrderingComposer,
      $$SyncContextTableAnnotationComposer,
      $$SyncContextTableCreateCompanionBuilder,
      $$SyncContextTableUpdateCompanionBuilder,
      (
        SyncContextData,
        BaseReferences<_$GTDatabaseImpl, $SyncContextTable, SyncContextData>,
      ),
      SyncContextData,
      PrefetchHooks Function()
    >;
typedef $$SyncQuarantineTableCreateCompanionBuilder =
    SyncQuarantineCompanion Function({
      Value<int> id,
      Value<String?> owner,
      required String entity,
      required String payload,
      required String reason,
    });
typedef $$SyncQuarantineTableUpdateCompanionBuilder =
    SyncQuarantineCompanion Function({
      Value<int> id,
      Value<String?> owner,
      Value<String> entity,
      Value<String> payload,
      Value<String> reason,
    });

class $$SyncQuarantineTableFilterComposer
    extends Composer<_$GTDatabaseImpl, $SyncQuarantineTable> {
  $$SyncQuarantineTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get owner => $composableBuilder(
    column: $table.owner,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncQuarantineTableOrderingComposer
    extends Composer<_$GTDatabaseImpl, $SyncQuarantineTable> {
  $$SyncQuarantineTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get owner => $composableBuilder(
    column: $table.owner,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncQuarantineTableAnnotationComposer
    extends Composer<_$GTDatabaseImpl, $SyncQuarantineTable> {
  $$SyncQuarantineTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get owner =>
      $composableBuilder(column: $table.owner, builder: (column) => column);

  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);
}

class $$SyncQuarantineTableTableManager
    extends
        RootTableManager<
          _$GTDatabaseImpl,
          $SyncQuarantineTable,
          SyncQuarantineData,
          $$SyncQuarantineTableFilterComposer,
          $$SyncQuarantineTableOrderingComposer,
          $$SyncQuarantineTableAnnotationComposer,
          $$SyncQuarantineTableCreateCompanionBuilder,
          $$SyncQuarantineTableUpdateCompanionBuilder,
          (
            SyncQuarantineData,
            BaseReferences<
              _$GTDatabaseImpl,
              $SyncQuarantineTable,
              SyncQuarantineData
            >,
          ),
          SyncQuarantineData,
          PrefetchHooks Function()
        > {
  $$SyncQuarantineTableTableManager(
    _$GTDatabaseImpl db,
    $SyncQuarantineTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQuarantineTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQuarantineTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQuarantineTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> owner = const Value.absent(),
                Value<String> entity = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<String> reason = const Value.absent(),
              }) => SyncQuarantineCompanion(
                id: id,
                owner: owner,
                entity: entity,
                payload: payload,
                reason: reason,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> owner = const Value.absent(),
                required String entity,
                required String payload,
                required String reason,
              }) => SyncQuarantineCompanion.insert(
                id: id,
                owner: owner,
                entity: entity,
                payload: payload,
                reason: reason,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncQuarantineTableProcessedTableManager =
    ProcessedTableManager<
      _$GTDatabaseImpl,
      $SyncQuarantineTable,
      SyncQuarantineData,
      $$SyncQuarantineTableFilterComposer,
      $$SyncQuarantineTableOrderingComposer,
      $$SyncQuarantineTableAnnotationComposer,
      $$SyncQuarantineTableCreateCompanionBuilder,
      $$SyncQuarantineTableUpdateCompanionBuilder,
      (
        SyncQuarantineData,
        BaseReferences<
          _$GTDatabaseImpl,
          $SyncQuarantineTable,
          SyncQuarantineData
        >,
      ),
      SyncQuarantineData,
      PrefetchHooks Function()
    >;

class $GTDatabaseImplManager {
  final _$GTDatabaseImpl _db;
  $GTDatabaseImplManager(this._db);
  $$CustomExercisesTableTableManager get customExercises =>
      $$CustomExercisesTableTableManager(_db, _db.customExercises);
  $$RoutineFoldersTableTableManager get routineFolders =>
      $$RoutineFoldersTableTableManager(_db, _db.routineFolders);
  $$RoutinesTableTableManager get routines =>
      $$RoutinesTableTableManager(_db, _db.routines);
  $$HistoryWorkoutsTableTableManager get historyWorkouts =>
      $$HistoryWorkoutsTableTableManager(_db, _db.historyWorkouts);
  $$HistoryWorkoutExercisesTableTableManager get historyWorkoutExercises =>
      $$HistoryWorkoutExercisesTableTableManager(
        _db,
        _db.historyWorkoutExercises,
      );
  $$RoutineExercisesTableTableManager get routineExercises =>
      $$RoutineExercisesTableTableManager(_db, _db.routineExercises);
  $$PreferencesTableTableManager get preferences =>
      $$PreferencesTableTableManager(_db, _db.preferences);
  $$OngoingDataTableTableManager get ongoingData =>
      $$OngoingDataTableTableManager(_db, _db.ongoingData);
  $$WeightMeasurementsTableTableManager get weightMeasurements =>
      $$WeightMeasurementsTableTableManager(_db, _db.weightMeasurements);
  $$BodyMeasurementsTableTableManager get bodyMeasurements =>
      $$BodyMeasurementsTableTableManager(_db, _db.bodyMeasurements);
  $$FoodsTableTableManager get foods =>
      $$FoodsTableTableManager(_db, _db.foods);
  $$NutritionGoalsTableTableManager get nutritionGoals =>
      $$NutritionGoalsTableTableManager(_db, _db.nutritionGoals);
  $$CustomBarcodeFoodsTableTableManager get customBarcodeFoods =>
      $$CustomBarcodeFoodsTableTableManager(_db, _db.customBarcodeFoods);
  $$FavoriteFoodsTableTableManager get favoriteFoods =>
      $$FavoriteFoodsTableTableManager(_db, _db.favoriteFoods);
  $$NutritionCategoriesTableTableManager get nutritionCategories =>
      $$NutritionCategoriesTableTableManager(_db, _db.nutritionCategories);
  $$AchievementsTableTableManager get achievements =>
      $$AchievementsTableTableManager(_db, _db.achievements);
  $$SyncOutboxTableTableManager get syncOutbox =>
      $$SyncOutboxTableTableManager(_db, _db.syncOutbox);
  $$SyncMetadataTableTableManager get syncMetadata =>
      $$SyncMetadataTableTableManager(_db, _db.syncMetadata);
  $$SyncCursorsTableTableManager get syncCursors =>
      $$SyncCursorsTableTableManager(_db, _db.syncCursors);
  $$SyncConflictsTableTableManager get syncConflicts =>
      $$SyncConflictsTableTableManager(_db, _db.syncConflicts);
  $$SyncContextTableTableManager get syncContext =>
      $$SyncContextTableTableManager(_db, _db.syncContext);
  $$SyncQuarantineTableTableManager get syncQuarantine =>
      $$SyncQuarantineTableTableManager(_db, _db.syncQuarantine);
}
