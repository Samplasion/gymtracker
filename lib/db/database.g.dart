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
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => _uuid.v4());
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _parametersMeta =
      const VerificationMeta('parameters');
  @override
  late final GeneratedColumnWithTypeConverter<GTSetParameters, String>
      parameters = GeneratedColumn<String>('parameters', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<GTSetParameters>(
              $CustomExercisesTable.$converterparameters);
  static const VerificationMeta _primaryMuscleGroupMeta =
      const VerificationMeta('primaryMuscleGroup');
  @override
  late final GeneratedColumnWithTypeConverter<GTMuscleGroup, String>
      primaryMuscleGroup = GeneratedColumn<String>(
              'primary_muscle_group', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<GTMuscleGroup>(
              $CustomExercisesTable.$converterprimaryMuscleGroup);
  static const VerificationMeta _secondaryMuscleGroupsMeta =
      const VerificationMeta('secondaryMuscleGroups');
  @override
  late final GeneratedColumnWithTypeConverter<Set<GTMuscleGroup>, String>
      secondaryMuscleGroups = GeneratedColumn<String>(
              'secondary_muscle_groups', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<Set<GTMuscleGroup>>(
              $CustomExercisesTable.$convertersecondaryMuscleGroups);
  static const VerificationMeta _equipmentMeta =
      const VerificationMeta('equipment');
  @override
  late final GeneratedColumnWithTypeConverter<GTGymEquipment?, String>
      equipment = GeneratedColumn<String>('equipment', aliasedName, true,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              clientDefault: () => GTGymEquipment.none.name)
          .withConverter<GTGymEquipment?>(
              $CustomExercisesTable.$converterequipmentn);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        parameters,
        primaryMuscleGroup,
        secondaryMuscleGroups,
        equipment
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_exercises';
  @override
  VerificationContext validateIntegrity(Insertable<CustomExercise> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    context.handle(_parametersMeta, const VerificationResult.success());
    context.handle(_primaryMuscleGroupMeta, const VerificationResult.success());
    context.handle(
        _secondaryMuscleGroupsMeta, const VerificationResult.success());
    context.handle(_equipmentMeta, const VerificationResult.success());
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomExercise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomExercise(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      parameters: $CustomExercisesTable.$converterparameters.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}parameters'])!),
      primaryMuscleGroup: $CustomExercisesTable.$converterprimaryMuscleGroup
          .fromSql(attachedDatabase.typeMapping.read(DriftSqlType.string,
              data['${effectivePrefix}primary_muscle_group'])!),
      secondaryMuscleGroups: $CustomExercisesTable
          .$convertersecondaryMuscleGroups
          .fromSql(attachedDatabase.typeMapping.read(DriftSqlType.string,
              data['${effectivePrefix}secondary_muscle_groups'])!),
      equipment: $CustomExercisesTable.$converterequipmentn.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.string, data['${effectivePrefix}equipment'])),
    );
  }

  @override
  $CustomExercisesTable createAlias(String alias) {
    return $CustomExercisesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<GTSetParameters, String, String>
      $converterparameters =
      const EnumNameConverter<GTSetParameters>(GTSetParameters.values);
  static JsonTypeConverter2<GTMuscleGroup, String, String>
      $converterprimaryMuscleGroup =
      const EnumNameConverter<GTMuscleGroup>(GTMuscleGroup.values);
  static TypeConverter<Set<GTMuscleGroup>, String>
      $convertersecondaryMuscleGroups = const MuscleGroupSetConverter();
  static JsonTypeConverter2<GTGymEquipment, String, String>
      $converterequipment =
      const EnumNameConverter<GTGymEquipment>(GTGymEquipment.values);
  static JsonTypeConverter2<GTGymEquipment?, String?, String?>
      $converterequipmentn = JsonTypeConverter2.asNullable($converterequipment);
}

class CustomExercise extends DataClass implements Insertable<CustomExercise> {
  final String id;
  final String name;
  final GTSetParameters parameters;
  final GTMuscleGroup primaryMuscleGroup;
  final Set<GTMuscleGroup> secondaryMuscleGroups;
  final GTGymEquipment? equipment;
  const CustomExercise(
      {required this.id,
      required this.name,
      required this.parameters,
      required this.primaryMuscleGroup,
      required this.secondaryMuscleGroups,
      this.equipment});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    {
      map['parameters'] = Variable<String>(
          $CustomExercisesTable.$converterparameters.toSql(parameters));
    }
    {
      map['primary_muscle_group'] = Variable<String>($CustomExercisesTable
          .$converterprimaryMuscleGroup
          .toSql(primaryMuscleGroup));
    }
    {
      map['secondary_muscle_groups'] = Variable<String>($CustomExercisesTable
          .$convertersecondaryMuscleGroups
          .toSql(secondaryMuscleGroups));
    }
    if (!nullToAbsent || equipment != null) {
      map['equipment'] = Variable<String>(
          $CustomExercisesTable.$converterequipmentn.toSql(equipment));
    }
    return map;
  }

  CustomExercisesCompanion toCompanion(bool nullToAbsent) {
    return CustomExercisesCompanion(
      id: Value(id),
      name: Value(name),
      parameters: Value(parameters),
      primaryMuscleGroup: Value(primaryMuscleGroup),
      secondaryMuscleGroups: Value(secondaryMuscleGroups),
      equipment: equipment == null && nullToAbsent
          ? const Value.absent()
          : Value(equipment),
    );
  }

  factory CustomExercise.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomExercise(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      parameters: $CustomExercisesTable.$converterparameters
          .fromJson(serializer.fromJson<String>(json['parameters'])),
      primaryMuscleGroup: $CustomExercisesTable.$converterprimaryMuscleGroup
          .fromJson(serializer.fromJson<String>(json['primaryMuscleGroup'])),
      secondaryMuscleGroups: serializer
          .fromJson<Set<GTMuscleGroup>>(json['secondaryMuscleGroups']),
      equipment: $CustomExercisesTable.$converterequipmentn
          .fromJson(serializer.fromJson<String?>(json['equipment'])),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'parameters': serializer.toJson<String>(
          $CustomExercisesTable.$converterparameters.toJson(parameters)),
      'primaryMuscleGroup': serializer.toJson<String>($CustomExercisesTable
          .$converterprimaryMuscleGroup
          .toJson(primaryMuscleGroup)),
      'secondaryMuscleGroups':
          serializer.toJson<Set<GTMuscleGroup>>(secondaryMuscleGroups),
      'equipment': serializer.toJson<String?>(
          $CustomExercisesTable.$converterequipmentn.toJson(equipment)),
    };
  }

  CustomExercise copyWith(
          {String? id,
          String? name,
          GTSetParameters? parameters,
          GTMuscleGroup? primaryMuscleGroup,
          Set<GTMuscleGroup>? secondaryMuscleGroups,
          Value<GTGymEquipment?> equipment = const Value.absent()}) =>
      CustomExercise(
        id: id ?? this.id,
        name: name ?? this.name,
        parameters: parameters ?? this.parameters,
        primaryMuscleGroup: primaryMuscleGroup ?? this.primaryMuscleGroup,
        secondaryMuscleGroups:
            secondaryMuscleGroups ?? this.secondaryMuscleGroups,
        equipment: equipment.present ? equipment.value : this.equipment,
      );
  CustomExercise copyWithCompanion(CustomExercisesCompanion data) {
    return CustomExercise(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      parameters:
          data.parameters.present ? data.parameters.value : this.parameters,
      primaryMuscleGroup: data.primaryMuscleGroup.present
          ? data.primaryMuscleGroup.value
          : this.primaryMuscleGroup,
      secondaryMuscleGroups: data.secondaryMuscleGroups.present
          ? data.secondaryMuscleGroups.value
          : this.secondaryMuscleGroups,
      equipment: data.equipment.present ? data.equipment.value : this.equipment,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomExercise(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('parameters: $parameters, ')
          ..write('primaryMuscleGroup: $primaryMuscleGroup, ')
          ..write('secondaryMuscleGroups: $secondaryMuscleGroups, ')
          ..write('equipment: $equipment')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, parameters, primaryMuscleGroup,
      secondaryMuscleGroups, equipment);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomExercise &&
          other.id == this.id &&
          other.name == this.name &&
          other.parameters == this.parameters &&
          other.primaryMuscleGroup == this.primaryMuscleGroup &&
          other.secondaryMuscleGroups == this.secondaryMuscleGroups &&
          other.equipment == this.equipment);
}

class CustomExercisesCompanion extends UpdateCompanion<CustomExercise> {
  final Value<String> id;
  final Value<String> name;
  final Value<GTSetParameters> parameters;
  final Value<GTMuscleGroup> primaryMuscleGroup;
  final Value<Set<GTMuscleGroup>> secondaryMuscleGroups;
  final Value<GTGymEquipment?> equipment;
  final Value<int> rowid;
  const CustomExercisesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.parameters = const Value.absent(),
    this.primaryMuscleGroup = const Value.absent(),
    this.secondaryMuscleGroups = const Value.absent(),
    this.equipment = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomExercisesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required GTSetParameters parameters,
    required GTMuscleGroup primaryMuscleGroup,
    required Set<GTMuscleGroup> secondaryMuscleGroups,
    this.equipment = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : name = Value(name),
        parameters = Value(parameters),
        primaryMuscleGroup = Value(primaryMuscleGroup),
        secondaryMuscleGroups = Value(secondaryMuscleGroups);
  static Insertable<CustomExercise> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? parameters,
    Expression<String>? primaryMuscleGroup,
    Expression<String>? secondaryMuscleGroups,
    Expression<String>? equipment,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
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

  CustomExercisesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<GTSetParameters>? parameters,
      Value<GTMuscleGroup>? primaryMuscleGroup,
      Value<Set<GTMuscleGroup>>? secondaryMuscleGroups,
      Value<GTGymEquipment?>? equipment,
      Value<int>? rowid}) {
    return CustomExercisesCompanion(
      id: id ?? this.id,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (parameters.present) {
      map['parameters'] = Variable<String>(
          $CustomExercisesTable.$converterparameters.toSql(parameters.value));
    }
    if (primaryMuscleGroup.present) {
      map['primary_muscle_group'] = Variable<String>($CustomExercisesTable
          .$converterprimaryMuscleGroup
          .toSql(primaryMuscleGroup.value));
    }
    if (secondaryMuscleGroups.present) {
      map['secondary_muscle_groups'] = Variable<String>($CustomExercisesTable
          .$convertersecondaryMuscleGroups
          .toSql(secondaryMuscleGroups.value));
    }
    if (equipment.present) {
      map['equipment'] = Variable<String>(
          $CustomExercisesTable.$converterequipmentn.toSql(equipment.value));
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
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => _uuid.v4());
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routine_folders';
  @override
  VerificationContext validateIntegrity(Insertable<RoutineFolder> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RoutineFolder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoutineFolder(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
    );
  }

  @override
  $RoutineFoldersTable createAlias(String alias) {
    return $RoutineFoldersTable(attachedDatabase, alias);
  }
}

class RoutineFolder extends DataClass implements Insertable<RoutineFolder> {
  final String id;
  final String name;
  final int sortOrder;
  const RoutineFolder(
      {required this.id, required this.name, required this.sortOrder});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  RoutineFoldersCompanion toCompanion(bool nullToAbsent) {
    return RoutineFoldersCompanion(
      id: Value(id),
      name: Value(name),
      sortOrder: Value(sortOrder),
    );
  }

  factory RoutineFolder.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoutineFolder(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  RoutineFolder copyWith({String? id, String? name, int? sortOrder}) =>
      RoutineFolder(
        id: id ?? this.id,
        name: name ?? this.name,
        sortOrder: sortOrder ?? this.sortOrder,
      );
  RoutineFolder copyWithCompanion(RoutineFoldersCompanion data) {
    return RoutineFolder(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoutineFolder(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoutineFolder &&
          other.id == this.id &&
          other.name == this.name &&
          other.sortOrder == this.sortOrder);
}

class RoutineFoldersCompanion extends UpdateCompanion<RoutineFolder> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const RoutineFoldersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoutineFoldersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int sortOrder,
    this.rowid = const Value.absent(),
  })  : name = Value(name),
        sortOrder = Value(sortOrder);
  static Insertable<RoutineFolder> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoutineFoldersCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<int>? sortOrder,
      Value<int>? rowid}) {
    return RoutineFoldersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
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
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
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
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => _uuid.v4());
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _infoboxMeta =
      const VerificationMeta('infobox');
  @override
  late final GeneratedColumn<String> infobox = GeneratedColumn<String>(
      'infobox', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _weightUnitMeta =
      const VerificationMeta('weightUnit');
  @override
  late final GeneratedColumnWithTypeConverter<Weights, String> weightUnit =
      GeneratedColumn<String>('weight_unit', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<Weights>($RoutinesTable.$converterweightUnit);
  static const VerificationMeta _distanceUnitMeta =
      const VerificationMeta('distanceUnit');
  @override
  late final GeneratedColumnWithTypeConverter<Distance, String> distanceUnit =
      GeneratedColumn<String>('distance_unit', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<Distance>($RoutinesTable.$converterdistanceUnit);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _folderIdMeta =
      const VerificationMeta('folderId');
  @override
  late final GeneratedColumn<String> folderId = GeneratedColumn<String>(
      'folder_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES routine_folders (id)'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, infobox, weightUnit, distanceUnit, sortOrder, folderId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routines';
  @override
  VerificationContext validateIntegrity(Insertable<Routine> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('infobox')) {
      context.handle(_infoboxMeta,
          infobox.isAcceptableOrUnknown(data['infobox']!, _infoboxMeta));
    } else if (isInserting) {
      context.missing(_infoboxMeta);
    }
    context.handle(_weightUnitMeta, const VerificationResult.success());
    context.handle(_distanceUnitMeta, const VerificationResult.success());
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('folder_id')) {
      context.handle(_folderIdMeta,
          folderId.isAcceptableOrUnknown(data['folder_id']!, _folderIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Routine map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Routine(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      infobox: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}infobox'])!,
      weightUnit: $RoutinesTable.$converterweightUnit.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}weight_unit'])!),
      distanceUnit: $RoutinesTable.$converterdistanceUnit.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}distance_unit'])!),
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      folderId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}folder_id']),
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

class Routine extends DataClass implements Insertable<Routine> {
  final String id;
  final String name;
  final String infobox;
  final Weights weightUnit;
  final Distance distanceUnit;
  final int sortOrder;
  final String? folderId;
  const Routine(
      {required this.id,
      required this.name,
      required this.infobox,
      required this.weightUnit,
      required this.distanceUnit,
      required this.sortOrder,
      this.folderId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['infobox'] = Variable<String>(infobox);
    {
      map['weight_unit'] = Variable<String>(
          $RoutinesTable.$converterweightUnit.toSql(weightUnit));
    }
    {
      map['distance_unit'] = Variable<String>(
          $RoutinesTable.$converterdistanceUnit.toSql(distanceUnit));
    }
    map['sort_order'] = Variable<int>(sortOrder);
    if (!nullToAbsent || folderId != null) {
      map['folder_id'] = Variable<String>(folderId);
    }
    return map;
  }

  RoutinesCompanion toCompanion(bool nullToAbsent) {
    return RoutinesCompanion(
      id: Value(id),
      name: Value(name),
      infobox: Value(infobox),
      weightUnit: Value(weightUnit),
      distanceUnit: Value(distanceUnit),
      sortOrder: Value(sortOrder),
      folderId: folderId == null && nullToAbsent
          ? const Value.absent()
          : Value(folderId),
    );
  }

  factory Routine.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Routine(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      infobox: serializer.fromJson<String>(json['infobox']),
      weightUnit: $RoutinesTable.$converterweightUnit
          .fromJson(serializer.fromJson<String>(json['weightUnit'])),
      distanceUnit: $RoutinesTable.$converterdistanceUnit
          .fromJson(serializer.fromJson<String>(json['distanceUnit'])),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      folderId: serializer.fromJson<String?>(json['folderId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'infobox': serializer.toJson<String>(infobox),
      'weightUnit': serializer.toJson<String>(
          $RoutinesTable.$converterweightUnit.toJson(weightUnit)),
      'distanceUnit': serializer.toJson<String>(
          $RoutinesTable.$converterdistanceUnit.toJson(distanceUnit)),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'folderId': serializer.toJson<String?>(folderId),
    };
  }

  Routine copyWith(
          {String? id,
          String? name,
          String? infobox,
          Weights? weightUnit,
          Distance? distanceUnit,
          int? sortOrder,
          Value<String?> folderId = const Value.absent()}) =>
      Routine(
        id: id ?? this.id,
        name: name ?? this.name,
        infobox: infobox ?? this.infobox,
        weightUnit: weightUnit ?? this.weightUnit,
        distanceUnit: distanceUnit ?? this.distanceUnit,
        sortOrder: sortOrder ?? this.sortOrder,
        folderId: folderId.present ? folderId.value : this.folderId,
      );
  Routine copyWithCompanion(RoutinesCompanion data) {
    return Routine(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      infobox: data.infobox.present ? data.infobox.value : this.infobox,
      weightUnit:
          data.weightUnit.present ? data.weightUnit.value : this.weightUnit,
      distanceUnit: data.distanceUnit.present
          ? data.distanceUnit.value
          : this.distanceUnit,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      folderId: data.folderId.present ? data.folderId.value : this.folderId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Routine(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('infobox: $infobox, ')
          ..write('weightUnit: $weightUnit, ')
          ..write('distanceUnit: $distanceUnit, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('folderId: $folderId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, name, infobox, weightUnit, distanceUnit, sortOrder, folderId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Routine &&
          other.id == this.id &&
          other.name == this.name &&
          other.infobox == this.infobox &&
          other.weightUnit == this.weightUnit &&
          other.distanceUnit == this.distanceUnit &&
          other.sortOrder == this.sortOrder &&
          other.folderId == this.folderId);
}

class RoutinesCompanion extends UpdateCompanion<Routine> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> infobox;
  final Value<Weights> weightUnit;
  final Value<Distance> distanceUnit;
  final Value<int> sortOrder;
  final Value<String?> folderId;
  final Value<int> rowid;
  const RoutinesCompanion({
    this.id = const Value.absent(),
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
    required String name,
    required String infobox,
    required Weights weightUnit,
    required Distance distanceUnit,
    required int sortOrder,
    this.folderId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : name = Value(name),
        infobox = Value(infobox),
        weightUnit = Value(weightUnit),
        distanceUnit = Value(distanceUnit),
        sortOrder = Value(sortOrder);
  static Insertable<Routine> custom({
    Expression<String>? id,
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
      if (name != null) 'name': name,
      if (infobox != null) 'infobox': infobox,
      if (weightUnit != null) 'weight_unit': weightUnit,
      if (distanceUnit != null) 'distance_unit': distanceUnit,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (folderId != null) 'folder_id': folderId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoutinesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? infobox,
      Value<Weights>? weightUnit,
      Value<Distance>? distanceUnit,
      Value<int>? sortOrder,
      Value<String?>? folderId,
      Value<int>? rowid}) {
    return RoutinesCompanion(
      id: id ?? this.id,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (infobox.present) {
      map['infobox'] = Variable<String>(infobox.value);
    }
    if (weightUnit.present) {
      map['weight_unit'] = Variable<String>(
          $RoutinesTable.$converterweightUnit.toSql(weightUnit.value));
    }
    if (distanceUnit.present) {
      map['distance_unit'] = Variable<String>(
          $RoutinesTable.$converterdistanceUnit.toSql(distanceUnit.value));
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
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => _uuid.v4());
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _infoboxMeta =
      const VerificationMeta('infobox');
  @override
  late final GeneratedColumn<String> infobox = GeneratedColumn<String>(
      'infobox', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _durationMeta =
      const VerificationMeta('duration');
  @override
  late final GeneratedColumn<int> duration = GeneratedColumn<int>(
      'duration', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _startingDateMeta =
      const VerificationMeta('startingDate');
  @override
  late final GeneratedColumn<DateTime> startingDate = GeneratedColumn<DateTime>(
      'starting_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _parentIdMeta =
      const VerificationMeta('parentId');
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
      'parent_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES routines (id)'));
  static const VerificationMeta _completedByMeta =
      const VerificationMeta('completedBy');
  @override
  late final GeneratedColumn<String> completedBy = GeneratedColumn<String>(
      'completed_by', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES history_workouts (id)'));
  static const VerificationMeta _completesMeta =
      const VerificationMeta('completes');
  @override
  late final GeneratedColumn<String> completes = GeneratedColumn<String>(
      'completes', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES history_workouts (id)'));
  static const VerificationMeta _weightUnitMeta =
      const VerificationMeta('weightUnit');
  @override
  late final GeneratedColumnWithTypeConverter<Weights, String> weightUnit =
      GeneratedColumn<String>('weight_unit', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<Weights>($HistoryWorkoutsTable.$converterweightUnit);
  static const VerificationMeta _distanceUnitMeta =
      const VerificationMeta('distanceUnit');
  @override
  late final GeneratedColumnWithTypeConverter<Distance, String> distanceUnit =
      GeneratedColumn<String>('distance_unit', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<Distance>(
              $HistoryWorkoutsTable.$converterdistanceUnit);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        infobox,
        duration,
        startingDate,
        parentId,
        completedBy,
        completes,
        weightUnit,
        distanceUnit
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'history_workouts';
  @override
  VerificationContext validateIntegrity(Insertable<HistoryWorkout> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('infobox')) {
      context.handle(_infoboxMeta,
          infobox.isAcceptableOrUnknown(data['infobox']!, _infoboxMeta));
    }
    if (data.containsKey('duration')) {
      context.handle(_durationMeta,
          duration.isAcceptableOrUnknown(data['duration']!, _durationMeta));
    } else if (isInserting) {
      context.missing(_durationMeta);
    }
    if (data.containsKey('starting_date')) {
      context.handle(
          _startingDateMeta,
          startingDate.isAcceptableOrUnknown(
              data['starting_date']!, _startingDateMeta));
    } else if (isInserting) {
      context.missing(_startingDateMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(_parentIdMeta,
          parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta));
    }
    if (data.containsKey('completed_by')) {
      context.handle(
          _completedByMeta,
          completedBy.isAcceptableOrUnknown(
              data['completed_by']!, _completedByMeta));
    }
    if (data.containsKey('completes')) {
      context.handle(_completesMeta,
          completes.isAcceptableOrUnknown(data['completes']!, _completesMeta));
    }
    context.handle(_weightUnitMeta, const VerificationResult.success());
    context.handle(_distanceUnitMeta, const VerificationResult.success());
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {completedBy, completes},
      ];
  @override
  HistoryWorkout map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HistoryWorkout(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      infobox: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}infobox']),
      duration: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration'])!,
      startingDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}starting_date'])!,
      parentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}parent_id']),
      completedBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}completed_by']),
      completes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}completes']),
      weightUnit: $HistoryWorkoutsTable.$converterweightUnit.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}weight_unit'])!),
      distanceUnit: $HistoryWorkoutsTable.$converterdistanceUnit.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}distance_unit'])!),
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

class HistoryWorkout extends DataClass implements Insertable<HistoryWorkout> {
  final String id;
  final String name;
  final String? infobox;
  final int duration;
  final DateTime startingDate;
  final String? parentId;
  final String? completedBy;
  final String? completes;
  final Weights weightUnit;
  final Distance distanceUnit;
  const HistoryWorkout(
      {required this.id,
      required this.name,
      this.infobox,
      required this.duration,
      required this.startingDate,
      this.parentId,
      this.completedBy,
      this.completes,
      required this.weightUnit,
      required this.distanceUnit});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || infobox != null) {
      map['infobox'] = Variable<String>(infobox);
    }
    map['duration'] = Variable<int>(duration);
    map['starting_date'] = Variable<DateTime>(startingDate);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    if (!nullToAbsent || completedBy != null) {
      map['completed_by'] = Variable<String>(completedBy);
    }
    if (!nullToAbsent || completes != null) {
      map['completes'] = Variable<String>(completes);
    }
    {
      map['weight_unit'] = Variable<String>(
          $HistoryWorkoutsTable.$converterweightUnit.toSql(weightUnit));
    }
    {
      map['distance_unit'] = Variable<String>(
          $HistoryWorkoutsTable.$converterdistanceUnit.toSql(distanceUnit));
    }
    return map;
  }

  HistoryWorkoutsCompanion toCompanion(bool nullToAbsent) {
    return HistoryWorkoutsCompanion(
      id: Value(id),
      name: Value(name),
      infobox: infobox == null && nullToAbsent
          ? const Value.absent()
          : Value(infobox),
      duration: Value(duration),
      startingDate: Value(startingDate),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      completedBy: completedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(completedBy),
      completes: completes == null && nullToAbsent
          ? const Value.absent()
          : Value(completes),
      weightUnit: Value(weightUnit),
      distanceUnit: Value(distanceUnit),
    );
  }

  factory HistoryWorkout.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HistoryWorkout(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      infobox: serializer.fromJson<String?>(json['infobox']),
      duration: serializer.fromJson<int>(json['duration']),
      startingDate: serializer.fromJson<DateTime>(json['startingDate']),
      parentId: serializer.fromJson<String?>(json['parentId']),
      completedBy: serializer.fromJson<String?>(json['completedBy']),
      completes: serializer.fromJson<String?>(json['completes']),
      weightUnit: $HistoryWorkoutsTable.$converterweightUnit
          .fromJson(serializer.fromJson<String>(json['weightUnit'])),
      distanceUnit: $HistoryWorkoutsTable.$converterdistanceUnit
          .fromJson(serializer.fromJson<String>(json['distanceUnit'])),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'infobox': serializer.toJson<String?>(infobox),
      'duration': serializer.toJson<int>(duration),
      'startingDate': serializer.toJson<DateTime>(startingDate),
      'parentId': serializer.toJson<String?>(parentId),
      'completedBy': serializer.toJson<String?>(completedBy),
      'completes': serializer.toJson<String?>(completes),
      'weightUnit': serializer.toJson<String>(
          $HistoryWorkoutsTable.$converterweightUnit.toJson(weightUnit)),
      'distanceUnit': serializer.toJson<String>(
          $HistoryWorkoutsTable.$converterdistanceUnit.toJson(distanceUnit)),
    };
  }

  HistoryWorkout copyWith(
          {String? id,
          String? name,
          Value<String?> infobox = const Value.absent(),
          int? duration,
          DateTime? startingDate,
          Value<String?> parentId = const Value.absent(),
          Value<String?> completedBy = const Value.absent(),
          Value<String?> completes = const Value.absent(),
          Weights? weightUnit,
          Distance? distanceUnit}) =>
      HistoryWorkout(
        id: id ?? this.id,
        name: name ?? this.name,
        infobox: infobox.present ? infobox.value : this.infobox,
        duration: duration ?? this.duration,
        startingDate: startingDate ?? this.startingDate,
        parentId: parentId.present ? parentId.value : this.parentId,
        completedBy: completedBy.present ? completedBy.value : this.completedBy,
        completes: completes.present ? completes.value : this.completes,
        weightUnit: weightUnit ?? this.weightUnit,
        distanceUnit: distanceUnit ?? this.distanceUnit,
      );
  HistoryWorkout copyWithCompanion(HistoryWorkoutsCompanion data) {
    return HistoryWorkout(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      infobox: data.infobox.present ? data.infobox.value : this.infobox,
      duration: data.duration.present ? data.duration.value : this.duration,
      startingDate: data.startingDate.present
          ? data.startingDate.value
          : this.startingDate,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      completedBy:
          data.completedBy.present ? data.completedBy.value : this.completedBy,
      completes: data.completes.present ? data.completes.value : this.completes,
      weightUnit:
          data.weightUnit.present ? data.weightUnit.value : this.weightUnit,
      distanceUnit: data.distanceUnit.present
          ? data.distanceUnit.value
          : this.distanceUnit,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HistoryWorkout(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('infobox: $infobox, ')
          ..write('duration: $duration, ')
          ..write('startingDate: $startingDate, ')
          ..write('parentId: $parentId, ')
          ..write('completedBy: $completedBy, ')
          ..write('completes: $completes, ')
          ..write('weightUnit: $weightUnit, ')
          ..write('distanceUnit: $distanceUnit')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, infobox, duration, startingDate,
      parentId, completedBy, completes, weightUnit, distanceUnit);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HistoryWorkout &&
          other.id == this.id &&
          other.name == this.name &&
          other.infobox == this.infobox &&
          other.duration == this.duration &&
          other.startingDate == this.startingDate &&
          other.parentId == this.parentId &&
          other.completedBy == this.completedBy &&
          other.completes == this.completes &&
          other.weightUnit == this.weightUnit &&
          other.distanceUnit == this.distanceUnit);
}

class HistoryWorkoutsCompanion extends UpdateCompanion<HistoryWorkout> {
  final Value<String> id;
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
  })  : name = Value(name),
        duration = Value(duration),
        startingDate = Value(startingDate),
        weightUnit = Value(weightUnit),
        distanceUnit = Value(distanceUnit);
  static Insertable<HistoryWorkout> custom({
    Expression<String>? id,
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

  HistoryWorkoutsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? infobox,
      Value<int>? duration,
      Value<DateTime>? startingDate,
      Value<String?>? parentId,
      Value<String?>? completedBy,
      Value<String?>? completes,
      Value<Weights>? weightUnit,
      Value<Distance>? distanceUnit,
      Value<int>? rowid}) {
    return HistoryWorkoutsCompanion(
      id: id ?? this.id,
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
          $HistoryWorkoutsTable.$converterweightUnit.toSql(weightUnit.value));
    }
    if (distanceUnit.present) {
      map['distance_unit'] = Variable<String>($HistoryWorkoutsTable
          .$converterdistanceUnit
          .toSql(distanceUnit.value));
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
    with TableInfo<$HistoryWorkoutExercisesTable, ConcreteExercise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HistoryWorkoutExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => _uuid.v4());
  static const VerificationMeta _routineIdMeta =
      const VerificationMeta('routineId');
  @override
  late final GeneratedColumn<String> routineId = GeneratedColumn<String>(
      'routine_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES history_workouts (id)'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _parametersMeta =
      const VerificationMeta('parameters');
  @override
  late final GeneratedColumnWithTypeConverter<GTSetParameters?, String>
      parameters = GeneratedColumn<String>('parameters', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<GTSetParameters?>(
              $HistoryWorkoutExercisesTable.$converterparametersn);
  static const VerificationMeta _setsMeta = const VerificationMeta('sets');
  @override
  late final GeneratedColumnWithTypeConverter<List<GTSet>?, String> sets =
      GeneratedColumn<String>('sets', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<List<GTSet>?>(
              $HistoryWorkoutExercisesTable.$convertersetsn);
  static const VerificationMeta _primaryMuscleGroupMeta =
      const VerificationMeta('primaryMuscleGroup');
  @override
  late final GeneratedColumnWithTypeConverter<GTMuscleGroup?, String>
      primaryMuscleGroup = GeneratedColumn<String>(
              'primary_muscle_group', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<GTMuscleGroup?>(
              $HistoryWorkoutExercisesTable.$converterprimaryMuscleGroupn);
  static const VerificationMeta _secondaryMuscleGroupsMeta =
      const VerificationMeta('secondaryMuscleGroups');
  @override
  late final GeneratedColumnWithTypeConverter<Set<GTMuscleGroup>?, String>
      secondaryMuscleGroups = GeneratedColumn<String>(
              'secondary_muscle_groups', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<Set<GTMuscleGroup>?>(
              $HistoryWorkoutExercisesTable.$convertersecondaryMuscleGroupsn);
  static const VerificationMeta _restTimeMeta =
      const VerificationMeta('restTime');
  @override
  late final GeneratedColumn<int> restTime = GeneratedColumn<int>(
      'rest_time', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _isCustomMeta =
      const VerificationMeta('isCustom');
  @override
  late final GeneratedColumn<bool> isCustom = GeneratedColumn<bool>(
      'is_custom', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_custom" IN (0, 1))'));
  static const VerificationMeta _libraryExerciseIdMeta =
      const VerificationMeta('libraryExerciseId');
  @override
  late final GeneratedColumn<String> libraryExerciseId =
      GeneratedColumn<String>('library_exercise_id', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _customExerciseIdMeta =
      const VerificationMeta('customExerciseId');
  @override
  late final GeneratedColumn<String> customExerciseId = GeneratedColumn<String>(
      'custom_exercise_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES custom_exercises (id)'));
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isSupersetMeta =
      const VerificationMeta('isSuperset');
  @override
  late final GeneratedColumn<bool> isSuperset = GeneratedColumn<bool>(
      'is_superset', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_superset" IN (0, 1))'));
  static const VerificationMeta _isInSupersetMeta =
      const VerificationMeta('isInSuperset');
  @override
  late final GeneratedColumn<bool> isInSuperset = GeneratedColumn<bool>(
      'is_in_superset', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_in_superset" IN (0, 1))'));
  static const VerificationMeta _supersetIdMeta =
      const VerificationMeta('supersetId');
  @override
  late final GeneratedColumn<String> supersetId = GeneratedColumn<String>(
      'superset_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES history_workout_exercises (id)'));
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _supersedesIdMeta =
      const VerificationMeta('supersedesId');
  @override
  late final GeneratedColumn<String> supersedesId = GeneratedColumn<String>(
      'supersedes_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES history_workout_exercises (id)'));
  static const VerificationMeta _rpeMeta = const VerificationMeta('rpe');
  @override
  late final GeneratedColumn<int> rpe = GeneratedColumn<int>(
      'rpe', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _equipmentMeta =
      const VerificationMeta('equipment');
  @override
  late final GeneratedColumnWithTypeConverter<GTGymEquipment?, String>
      equipment = GeneratedColumn<String>('equipment', aliasedName, true,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              clientDefault: () => GTGymEquipment.none.name)
          .withConverter<GTGymEquipment?>(
              $HistoryWorkoutExercisesTable.$converterequipmentn);
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
        equipment
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'history_workout_exercises';
  @override
  VerificationContext validateIntegrity(Insertable<ConcreteExercise> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('routine_id')) {
      context.handle(_routineIdMeta,
          routineId.isAcceptableOrUnknown(data['routine_id']!, _routineIdMeta));
    } else if (isInserting) {
      context.missing(_routineIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    context.handle(_parametersMeta, const VerificationResult.success());
    context.handle(_setsMeta, const VerificationResult.success());
    context.handle(_primaryMuscleGroupMeta, const VerificationResult.success());
    context.handle(
        _secondaryMuscleGroupsMeta, const VerificationResult.success());
    if (data.containsKey('rest_time')) {
      context.handle(_restTimeMeta,
          restTime.isAcceptableOrUnknown(data['rest_time']!, _restTimeMeta));
    }
    if (data.containsKey('is_custom')) {
      context.handle(_isCustomMeta,
          isCustom.isAcceptableOrUnknown(data['is_custom']!, _isCustomMeta));
    } else if (isInserting) {
      context.missing(_isCustomMeta);
    }
    if (data.containsKey('library_exercise_id')) {
      context.handle(
          _libraryExerciseIdMeta,
          libraryExerciseId.isAcceptableOrUnknown(
              data['library_exercise_id']!, _libraryExerciseIdMeta));
    }
    if (data.containsKey('custom_exercise_id')) {
      context.handle(
          _customExerciseIdMeta,
          customExerciseId.isAcceptableOrUnknown(
              data['custom_exercise_id']!, _customExerciseIdMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('is_superset')) {
      context.handle(
          _isSupersetMeta,
          isSuperset.isAcceptableOrUnknown(
              data['is_superset']!, _isSupersetMeta));
    } else if (isInserting) {
      context.missing(_isSupersetMeta);
    }
    if (data.containsKey('is_in_superset')) {
      context.handle(
          _isInSupersetMeta,
          isInSuperset.isAcceptableOrUnknown(
              data['is_in_superset']!, _isInSupersetMeta));
    } else if (isInserting) {
      context.missing(_isInSupersetMeta);
    }
    if (data.containsKey('superset_id')) {
      context.handle(
          _supersetIdMeta,
          supersetId.isAcceptableOrUnknown(
              data['superset_id']!, _supersetIdMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('supersedes_id')) {
      context.handle(
          _supersedesIdMeta,
          supersedesId.isAcceptableOrUnknown(
              data['supersedes_id']!, _supersedesIdMeta));
    }
    if (data.containsKey('rpe')) {
      context.handle(
          _rpeMeta, rpe.isAcceptableOrUnknown(data['rpe']!, _rpeMeta));
    }
    context.handle(_equipmentMeta, const VerificationResult.success());
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ConcreteExercise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConcreteExercise(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      routineId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}routine_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      parameters: $HistoryWorkoutExercisesTable.$converterparametersn.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.string, data['${effectivePrefix}parameters'])),
      sets: $HistoryWorkoutExercisesTable.$convertersetsn.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.string, data['${effectivePrefix}sets'])),
      primaryMuscleGroup: $HistoryWorkoutExercisesTable
          .$converterprimaryMuscleGroupn
          .fromSql(attachedDatabase.typeMapping.read(DriftSqlType.string,
              data['${effectivePrefix}primary_muscle_group'])),
      secondaryMuscleGroups: $HistoryWorkoutExercisesTable
          .$convertersecondaryMuscleGroupsn
          .fromSql(attachedDatabase.typeMapping.read(DriftSqlType.string,
              data['${effectivePrefix}secondary_muscle_groups'])),
      restTime: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}rest_time']),
      isCustom: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_custom'])!,
      libraryExerciseId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}library_exercise_id']),
      customExerciseId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}custom_exercise_id']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      isSuperset: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_superset'])!,
      isInSuperset: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_in_superset'])!,
      supersetId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}superset_id']),
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      supersedesId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}supersedes_id']),
      rpe: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}rpe']),
      equipment: $HistoryWorkoutExercisesTable.$converterequipmentn.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.string, data['${effectivePrefix}equipment'])),
    );
  }

  @override
  $HistoryWorkoutExercisesTable createAlias(String alias) {
    return $HistoryWorkoutExercisesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<GTSetParameters, String, String>
      $converterparameters =
      const EnumNameConverter<GTSetParameters>(GTSetParameters.values);
  static JsonTypeConverter2<GTSetParameters?, String?, String?>
      $converterparametersn =
      JsonTypeConverter2.asNullable($converterparameters);
  static TypeConverter<List<GTSet>, String> $convertersets =
      const GTSetListConverter();
  static TypeConverter<List<GTSet>?, String?> $convertersetsn =
      NullAwareTypeConverter.wrap($convertersets);
  static JsonTypeConverter2<GTMuscleGroup, String, String>
      $converterprimaryMuscleGroup =
      const EnumNameConverter<GTMuscleGroup>(GTMuscleGroup.values);
  static JsonTypeConverter2<GTMuscleGroup?, String?, String?>
      $converterprimaryMuscleGroupn =
      JsonTypeConverter2.asNullable($converterprimaryMuscleGroup);
  static TypeConverter<Set<GTMuscleGroup>, String>
      $convertersecondaryMuscleGroups = const MuscleGroupSetConverter();
  static TypeConverter<Set<GTMuscleGroup>?, String?>
      $convertersecondaryMuscleGroupsn =
      NullAwareTypeConverter.wrap($convertersecondaryMuscleGroups);
  static JsonTypeConverter2<GTGymEquipment, String, String>
      $converterequipment =
      const EnumNameConverter<GTGymEquipment>(GTGymEquipment.values);
  static JsonTypeConverter2<GTGymEquipment?, String?, String?>
      $converterequipmentn = JsonTypeConverter2.asNullable($converterequipment);
}

class HistoryWorkoutExercisesCompanion
    extends UpdateCompanion<ConcreteExercise> {
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
  final Value<GTGymEquipment?> equipment;
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
    this.equipment = const Value.absent(),
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
    this.equipment = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : routineId = Value(routineId),
        name = Value(name),
        isCustom = Value(isCustom),
        isSuperset = Value(isSuperset),
        isInSuperset = Value(isInSuperset),
        sortOrder = Value(sortOrder);
  static Insertable<ConcreteExercise> custom({
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
    Expression<String>? equipment,
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
      if (equipment != null) 'equipment': equipment,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HistoryWorkoutExercisesCompanion copyWith(
      {Value<String>? id,
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
      Value<GTGymEquipment?>? equipment,
      Value<int>? rowid}) {
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
    if (routineId.present) {
      map['routine_id'] = Variable<String>(routineId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (parameters.present) {
      map['parameters'] = Variable<String>($HistoryWorkoutExercisesTable
          .$converterparametersn
          .toSql(parameters.value));
    }
    if (sets.present) {
      map['sets'] = Variable<String>(
          $HistoryWorkoutExercisesTable.$convertersetsn.toSql(sets.value));
    }
    if (primaryMuscleGroup.present) {
      map['primary_muscle_group'] = Variable<String>(
          $HistoryWorkoutExercisesTable.$converterprimaryMuscleGroupn
              .toSql(primaryMuscleGroup.value));
    }
    if (secondaryMuscleGroups.present) {
      map['secondary_muscle_groups'] = Variable<String>(
          $HistoryWorkoutExercisesTable.$convertersecondaryMuscleGroupsn
              .toSql(secondaryMuscleGroups.value));
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
    if (equipment.present) {
      map['equipment'] = Variable<String>($HistoryWorkoutExercisesTable
          .$converterequipmentn
          .toSql(equipment.value));
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
          ..write('equipment: $equipment, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoutineExercisesTable extends RoutineExercises
    with TableInfo<$RoutineExercisesTable, ConcreteExercise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutineExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => _uuid.v4());
  static const VerificationMeta _routineIdMeta =
      const VerificationMeta('routineId');
  @override
  late final GeneratedColumn<String> routineId = GeneratedColumn<String>(
      'routine_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES routines (id)'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _parametersMeta =
      const VerificationMeta('parameters');
  @override
  late final GeneratedColumnWithTypeConverter<GTSetParameters?, String>
      parameters = GeneratedColumn<String>('parameters', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<GTSetParameters?>(
              $RoutineExercisesTable.$converterparametersn);
  static const VerificationMeta _setsMeta = const VerificationMeta('sets');
  @override
  late final GeneratedColumnWithTypeConverter<List<GTSet>?, String> sets =
      GeneratedColumn<String>('sets', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<List<GTSet>?>($RoutineExercisesTable.$convertersetsn);
  static const VerificationMeta _primaryMuscleGroupMeta =
      const VerificationMeta('primaryMuscleGroup');
  @override
  late final GeneratedColumnWithTypeConverter<GTMuscleGroup?, String>
      primaryMuscleGroup = GeneratedColumn<String>(
              'primary_muscle_group', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<GTMuscleGroup?>(
              $RoutineExercisesTable.$converterprimaryMuscleGroupn);
  static const VerificationMeta _secondaryMuscleGroupsMeta =
      const VerificationMeta('secondaryMuscleGroups');
  @override
  late final GeneratedColumnWithTypeConverter<Set<GTMuscleGroup>?, String>
      secondaryMuscleGroups = GeneratedColumn<String>(
              'secondary_muscle_groups', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<Set<GTMuscleGroup>?>(
              $RoutineExercisesTable.$convertersecondaryMuscleGroupsn);
  static const VerificationMeta _restTimeMeta =
      const VerificationMeta('restTime');
  @override
  late final GeneratedColumn<int> restTime = GeneratedColumn<int>(
      'rest_time', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _isCustomMeta =
      const VerificationMeta('isCustom');
  @override
  late final GeneratedColumn<bool> isCustom = GeneratedColumn<bool>(
      'is_custom', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_custom" IN (0, 1))'));
  static const VerificationMeta _libraryExerciseIdMeta =
      const VerificationMeta('libraryExerciseId');
  @override
  late final GeneratedColumn<String> libraryExerciseId =
      GeneratedColumn<String>('library_exercise_id', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _customExerciseIdMeta =
      const VerificationMeta('customExerciseId');
  @override
  late final GeneratedColumn<String> customExerciseId = GeneratedColumn<String>(
      'custom_exercise_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES custom_exercises (id)'));
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isSupersetMeta =
      const VerificationMeta('isSuperset');
  @override
  late final GeneratedColumn<bool> isSuperset = GeneratedColumn<bool>(
      'is_superset', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_superset" IN (0, 1))'));
  static const VerificationMeta _isInSupersetMeta =
      const VerificationMeta('isInSuperset');
  @override
  late final GeneratedColumn<bool> isInSuperset = GeneratedColumn<bool>(
      'is_in_superset', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_in_superset" IN (0, 1))'));
  static const VerificationMeta _supersetIdMeta =
      const VerificationMeta('supersetId');
  @override
  late final GeneratedColumn<String> supersetId = GeneratedColumn<String>(
      'superset_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES routine_exercises (id)'));
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _supersedesIdMeta =
      const VerificationMeta('supersedesId');
  @override
  late final GeneratedColumn<String> supersedesId = GeneratedColumn<String>(
      'supersedes_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES routine_exercises (id)'));
  static const VerificationMeta _rpeMeta = const VerificationMeta('rpe');
  @override
  late final GeneratedColumn<int> rpe = GeneratedColumn<int>(
      'rpe', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _equipmentMeta =
      const VerificationMeta('equipment');
  @override
  late final GeneratedColumnWithTypeConverter<GTGymEquipment?, String>
      equipment = GeneratedColumn<String>('equipment', aliasedName, true,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              clientDefault: () => GTGymEquipment.none.name)
          .withConverter<GTGymEquipment?>(
              $RoutineExercisesTable.$converterequipmentn);
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
        equipment
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routine_exercises';
  @override
  VerificationContext validateIntegrity(Insertable<ConcreteExercise> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('routine_id')) {
      context.handle(_routineIdMeta,
          routineId.isAcceptableOrUnknown(data['routine_id']!, _routineIdMeta));
    } else if (isInserting) {
      context.missing(_routineIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    context.handle(_parametersMeta, const VerificationResult.success());
    context.handle(_setsMeta, const VerificationResult.success());
    context.handle(_primaryMuscleGroupMeta, const VerificationResult.success());
    context.handle(
        _secondaryMuscleGroupsMeta, const VerificationResult.success());
    if (data.containsKey('rest_time')) {
      context.handle(_restTimeMeta,
          restTime.isAcceptableOrUnknown(data['rest_time']!, _restTimeMeta));
    }
    if (data.containsKey('is_custom')) {
      context.handle(_isCustomMeta,
          isCustom.isAcceptableOrUnknown(data['is_custom']!, _isCustomMeta));
    } else if (isInserting) {
      context.missing(_isCustomMeta);
    }
    if (data.containsKey('library_exercise_id')) {
      context.handle(
          _libraryExerciseIdMeta,
          libraryExerciseId.isAcceptableOrUnknown(
              data['library_exercise_id']!, _libraryExerciseIdMeta));
    }
    if (data.containsKey('custom_exercise_id')) {
      context.handle(
          _customExerciseIdMeta,
          customExerciseId.isAcceptableOrUnknown(
              data['custom_exercise_id']!, _customExerciseIdMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('is_superset')) {
      context.handle(
          _isSupersetMeta,
          isSuperset.isAcceptableOrUnknown(
              data['is_superset']!, _isSupersetMeta));
    } else if (isInserting) {
      context.missing(_isSupersetMeta);
    }
    if (data.containsKey('is_in_superset')) {
      context.handle(
          _isInSupersetMeta,
          isInSuperset.isAcceptableOrUnknown(
              data['is_in_superset']!, _isInSupersetMeta));
    } else if (isInserting) {
      context.missing(_isInSupersetMeta);
    }
    if (data.containsKey('superset_id')) {
      context.handle(
          _supersetIdMeta,
          supersetId.isAcceptableOrUnknown(
              data['superset_id']!, _supersetIdMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('supersedes_id')) {
      context.handle(
          _supersedesIdMeta,
          supersedesId.isAcceptableOrUnknown(
              data['supersedes_id']!, _supersedesIdMeta));
    }
    if (data.containsKey('rpe')) {
      context.handle(
          _rpeMeta, rpe.isAcceptableOrUnknown(data['rpe']!, _rpeMeta));
    }
    context.handle(_equipmentMeta, const VerificationResult.success());
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ConcreteExercise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConcreteExercise(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      routineId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}routine_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      parameters: $RoutineExercisesTable.$converterparametersn.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.string, data['${effectivePrefix}parameters'])),
      sets: $RoutineExercisesTable.$convertersetsn.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sets'])),
      primaryMuscleGroup: $RoutineExercisesTable.$converterprimaryMuscleGroupn
          .fromSql(attachedDatabase.typeMapping.read(DriftSqlType.string,
              data['${effectivePrefix}primary_muscle_group'])),
      secondaryMuscleGroups: $RoutineExercisesTable
          .$convertersecondaryMuscleGroupsn
          .fromSql(attachedDatabase.typeMapping.read(DriftSqlType.string,
              data['${effectivePrefix}secondary_muscle_groups'])),
      restTime: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}rest_time']),
      isCustom: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_custom'])!,
      libraryExerciseId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}library_exercise_id']),
      customExerciseId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}custom_exercise_id']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      isSuperset: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_superset'])!,
      isInSuperset: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_in_superset'])!,
      supersetId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}superset_id']),
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      supersedesId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}supersedes_id']),
      rpe: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}rpe']),
      equipment: $RoutineExercisesTable.$converterequipmentn.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.string, data['${effectivePrefix}equipment'])),
    );
  }

  @override
  $RoutineExercisesTable createAlias(String alias) {
    return $RoutineExercisesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<GTSetParameters, String, String>
      $converterparameters =
      const EnumNameConverter<GTSetParameters>(GTSetParameters.values);
  static JsonTypeConverter2<GTSetParameters?, String?, String?>
      $converterparametersn =
      JsonTypeConverter2.asNullable($converterparameters);
  static TypeConverter<List<GTSet>, String> $convertersets =
      const GTSetListConverter();
  static TypeConverter<List<GTSet>?, String?> $convertersetsn =
      NullAwareTypeConverter.wrap($convertersets);
  static JsonTypeConverter2<GTMuscleGroup, String, String>
      $converterprimaryMuscleGroup =
      const EnumNameConverter<GTMuscleGroup>(GTMuscleGroup.values);
  static JsonTypeConverter2<GTMuscleGroup?, String?, String?>
      $converterprimaryMuscleGroupn =
      JsonTypeConverter2.asNullable($converterprimaryMuscleGroup);
  static TypeConverter<Set<GTMuscleGroup>, String>
      $convertersecondaryMuscleGroups = const MuscleGroupSetConverter();
  static TypeConverter<Set<GTMuscleGroup>?, String?>
      $convertersecondaryMuscleGroupsn =
      NullAwareTypeConverter.wrap($convertersecondaryMuscleGroups);
  static JsonTypeConverter2<GTGymEquipment, String, String>
      $converterequipment =
      const EnumNameConverter<GTGymEquipment>(GTGymEquipment.values);
  static JsonTypeConverter2<GTGymEquipment?, String?, String?>
      $converterequipmentn = JsonTypeConverter2.asNullable($converterequipment);
}

class RoutineExercisesCompanion extends UpdateCompanion<ConcreteExercise> {
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
  final Value<GTGymEquipment?> equipment;
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
    this.equipment = const Value.absent(),
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
    this.equipment = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : routineId = Value(routineId),
        name = Value(name),
        isCustom = Value(isCustom),
        isSuperset = Value(isSuperset),
        isInSuperset = Value(isInSuperset),
        sortOrder = Value(sortOrder);
  static Insertable<ConcreteExercise> custom({
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
    Expression<String>? equipment,
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
      if (equipment != null) 'equipment': equipment,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoutineExercisesCompanion copyWith(
      {Value<String>? id,
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
      Value<GTGymEquipment?>? equipment,
      Value<int>? rowid}) {
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
    if (routineId.present) {
      map['routine_id'] = Variable<String>(routineId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (parameters.present) {
      map['parameters'] = Variable<String>(
          $RoutineExercisesTable.$converterparametersn.toSql(parameters.value));
    }
    if (sets.present) {
      map['sets'] = Variable<String>(
          $RoutineExercisesTable.$convertersetsn.toSql(sets.value));
    }
    if (primaryMuscleGroup.present) {
      map['primary_muscle_group'] = Variable<String>($RoutineExercisesTable
          .$converterprimaryMuscleGroupn
          .toSql(primaryMuscleGroup.value));
    }
    if (secondaryMuscleGroups.present) {
      map['secondary_muscle_groups'] = Variable<String>($RoutineExercisesTable
          .$convertersecondaryMuscleGroupsn
          .toSql(secondaryMuscleGroups.value));
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
    if (equipment.present) {
      map['equipment'] = Variable<String>(
          $RoutineExercisesTable.$converterequipmentn.toSql(equipment.value));
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
          ..write('equipment: $equipment, ')
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
      'data', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _onboardingCompleteMeta =
      const VerificationMeta('onboardingComplete');
  @override
  late final GeneratedColumn<bool> onboardingComplete = GeneratedColumn<bool>(
      'onboarding_complete', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("onboarding_complete" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [data, onboardingComplete];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'preferences';
  @override
  VerificationContext validateIntegrity(Insertable<Preference> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('data')) {
      context.handle(
          _dataMeta, this.data.isAcceptableOrUnknown(data['data']!, _dataMeta));
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('onboarding_complete')) {
      context.handle(
          _onboardingCompleteMeta,
          onboardingComplete.isAcceptableOrUnknown(
              data['onboarding_complete']!, _onboardingCompleteMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  Preference map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Preference(
      data: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}data'])!,
      onboardingComplete: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}onboarding_complete'])!,
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

  factory Preference.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
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

  PreferencesCompanion copyWith(
      {Value<String>? data,
      Value<bool>? onboardingComplete,
      Value<int>? rowid}) {
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
      'data', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [data];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ongoing_data';
  @override
  VerificationContext validateIntegrity(Insertable<OngoingDatum> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('data')) {
      context.handle(
          _dataMeta, this.data.isAcceptableOrUnknown(data['data']!, _dataMeta));
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  OngoingDatum map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OngoingDatum(
      data: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}data'])!,
    );
  }

  @override
  $OngoingDataTable createAlias(String alias) {
    return $OngoingDataTable(attachedDatabase, alias);
  }
}

class OngoingDatum extends DataClass implements Insertable<OngoingDatum> {
  final String data;
  const OngoingDatum({required this.data});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['data'] = Variable<String>(data);
    return map;
  }

  OngoingDataCompanion toCompanion(bool nullToAbsent) {
    return OngoingDataCompanion(
      data: Value(data),
    );
  }

  factory OngoingDatum.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OngoingDatum(
      data: serializer.fromJson<String>(json['data']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'data': serializer.toJson<String>(data),
    };
  }

  OngoingDatum copyWith({String? data}) => OngoingDatum(
        data: data ?? this.data,
      );
  OngoingDatum copyWithCompanion(OngoingDataCompanion data) {
    return OngoingDatum(
      data: data.data.present ? data.data.value : this.data,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OngoingDatum(')
          ..write('data: $data')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => data.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OngoingDatum && other.data == this.data);
}

class OngoingDataCompanion extends UpdateCompanion<OngoingDatum> {
  final Value<String> data;
  final Value<int> rowid;
  const OngoingDataCompanion({
    this.data = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OngoingDataCompanion.insert({
    required String data,
    this.rowid = const Value.absent(),
  }) : data = Value(data);
  static Insertable<OngoingDatum> custom({
    Expression<String>? data,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (data != null) 'data': data,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OngoingDataCompanion copyWith({Value<String>? data, Value<int>? rowid}) {
    return OngoingDataCompanion(
      data: data ?? this.data,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (data.present) {
      map['data'] = Variable<String>(data.value);
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
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => _uuid.v4());
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
      'weight', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _timeMeta = const VerificationMeta('time');
  @override
  late final GeneratedColumn<DateTime> time = GeneratedColumn<DateTime>(
      'time', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _weightUnitMeta =
      const VerificationMeta('weightUnit');
  @override
  late final GeneratedColumnWithTypeConverter<Weights, String> weightUnit =
      GeneratedColumn<String>('weight_unit', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<Weights>(
              $WeightMeasurementsTable.$converterweightUnit);
  @override
  List<GeneratedColumn> get $columns => [id, weight, time, weightUnit];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'weight_measurements';
  @override
  VerificationContext validateIntegrity(Insertable<WeightMeasurement> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('weight')) {
      context.handle(_weightMeta,
          weight.isAcceptableOrUnknown(data['weight']!, _weightMeta));
    } else if (isInserting) {
      context.missing(_weightMeta);
    }
    if (data.containsKey('time')) {
      context.handle(
          _timeMeta, time.isAcceptableOrUnknown(data['time']!, _timeMeta));
    } else if (isInserting) {
      context.missing(_timeMeta);
    }
    context.handle(_weightUnitMeta, const VerificationResult.success());
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WeightMeasurement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WeightMeasurement(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      weight: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}weight'])!,
      time: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}time'])!,
      weightUnit: $WeightMeasurementsTable.$converterweightUnit.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}weight_unit'])!),
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
  final Value<double> weight;
  final Value<DateTime> time;
  final Value<Weights> weightUnit;
  final Value<int> rowid;
  const WeightMeasurementsCompanion({
    this.id = const Value.absent(),
    this.weight = const Value.absent(),
    this.time = const Value.absent(),
    this.weightUnit = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WeightMeasurementsCompanion.insert({
    this.id = const Value.absent(),
    required double weight,
    required DateTime time,
    required Weights weightUnit,
    this.rowid = const Value.absent(),
  })  : weight = Value(weight),
        time = Value(time),
        weightUnit = Value(weightUnit);
  static Insertable<WeightMeasurement> custom({
    Expression<String>? id,
    Expression<double>? weight,
    Expression<DateTime>? time,
    Expression<String>? weightUnit,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (weight != null) 'weight': weight,
      if (time != null) 'time': time,
      if (weightUnit != null) 'weight_unit': weightUnit,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WeightMeasurementsCompanion copyWith(
      {Value<String>? id,
      Value<double>? weight,
      Value<DateTime>? time,
      Value<Weights>? weightUnit,
      Value<int>? rowid}) {
    return WeightMeasurementsCompanion(
      id: id ?? this.id,
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
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    if (time.present) {
      map['time'] = Variable<DateTime>(time.value);
    }
    if (weightUnit.present) {
      map['weight_unit'] = Variable<String>($WeightMeasurementsTable
          .$converterweightUnit
          .toSql(weightUnit.value));
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
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => _uuid.v4());
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<double> value = GeneratedColumn<double>(
      'value', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _timeMeta = const VerificationMeta('time');
  @override
  late final GeneratedColumn<DateTime> time = GeneratedColumn<DateTime>(
      'time', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumnWithTypeConverter<BodyMeasurementPart, String>
      type = GeneratedColumn<String>('type', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<BodyMeasurementPart>(
              $BodyMeasurementsTable.$convertertype);
  @override
  List<GeneratedColumn> get $columns => [id, value, time, type];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'body_measurements';
  @override
  VerificationContext validateIntegrity(Insertable<BodyMeasurement> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('time')) {
      context.handle(
          _timeMeta, time.isAcceptableOrUnknown(data['time']!, _timeMeta));
    } else if (isInserting) {
      context.missing(_timeMeta);
    }
    context.handle(_typeMeta, const VerificationResult.success());
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BodyMeasurement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BodyMeasurement(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}value'])!,
      time: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}time'])!,
      type: $BodyMeasurementsTable.$convertertype.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!),
    );
  }

  @override
  $BodyMeasurementsTable createAlias(String alias) {
    return $BodyMeasurementsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<BodyMeasurementPart, String, String>
      $convertertype =
      const EnumNameConverter<BodyMeasurementPart>(BodyMeasurementPart.values);
}

class BodyMeasurementsCompanion extends UpdateCompanion<BodyMeasurement> {
  final Value<String> id;
  final Value<double> value;
  final Value<DateTime> time;
  final Value<BodyMeasurementPart> type;
  final Value<int> rowid;
  const BodyMeasurementsCompanion({
    this.id = const Value.absent(),
    this.value = const Value.absent(),
    this.time = const Value.absent(),
    this.type = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BodyMeasurementsCompanion.insert({
    this.id = const Value.absent(),
    required double value,
    required DateTime time,
    required BodyMeasurementPart type,
    this.rowid = const Value.absent(),
  })  : value = Value(value),
        time = Value(time),
        type = Value(type);
  static Insertable<BodyMeasurement> custom({
    Expression<String>? id,
    Expression<double>? value,
    Expression<DateTime>? time,
    Expression<String>? type,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (value != null) 'value': value,
      if (time != null) 'time': time,
      if (type != null) 'type': type,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BodyMeasurementsCompanion copyWith(
      {Value<String>? id,
      Value<double>? value,
      Value<DateTime>? time,
      Value<BodyMeasurementPart>? type,
      Value<int>? rowid}) {
    return BodyMeasurementsCompanion(
      id: id ?? this.id,
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
    if (value.present) {
      map['value'] = Variable<double>(value.value);
    }
    if (time.present) {
      map['time'] = Variable<DateTime>(time.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
          $BodyMeasurementsTable.$convertertype.toSql(type.value));
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
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => _uuid.v4());
  static const VerificationMeta _dateAddedMeta =
      const VerificationMeta('dateAdded');
  @override
  late final GeneratedColumn<DateTime> dateAdded = GeneratedColumn<DateTime>(
      'date_added', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _referenceDateMeta =
      const VerificationMeta('referenceDate');
  @override
  late final GeneratedColumn<DateTime> referenceDate =
      GeneratedColumn<DateTime>('reference_date', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _jsonDataMeta =
      const VerificationMeta('jsonData');
  @override
  late final GeneratedColumn<String> jsonData = GeneratedColumn<String>(
      'json_data', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, dateAdded, referenceDate, jsonData];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'foods';
  @override
  VerificationContext validateIntegrity(Insertable<DBFood> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date_added')) {
      context.handle(_dateAddedMeta,
          dateAdded.isAcceptableOrUnknown(data['date_added']!, _dateAddedMeta));
    } else if (isInserting) {
      context.missing(_dateAddedMeta);
    }
    if (data.containsKey('reference_date')) {
      context.handle(
          _referenceDateMeta,
          referenceDate.isAcceptableOrUnknown(
              data['reference_date']!, _referenceDateMeta));
    } else if (isInserting) {
      context.missing(_referenceDateMeta);
    }
    if (data.containsKey('json_data')) {
      context.handle(_jsonDataMeta,
          jsonData.isAcceptableOrUnknown(data['json_data']!, _jsonDataMeta));
    } else if (isInserting) {
      context.missing(_jsonDataMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DBFood map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DBFood(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      dateAdded: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date_added'])!,
      referenceDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}reference_date'])!,
      jsonData: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}json_data'])!,
    );
  }

  @override
  $FoodsTable createAlias(String alias) {
    return $FoodsTable(attachedDatabase, alias);
  }
}

class DBFood extends DataClass implements Insertable<DBFood> {
  final String id;
  final DateTime dateAdded;
  final DateTime referenceDate;
  final String jsonData;
  const DBFood(
      {required this.id,
      required this.dateAdded,
      required this.referenceDate,
      required this.jsonData});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['date_added'] = Variable<DateTime>(dateAdded);
    map['reference_date'] = Variable<DateTime>(referenceDate);
    map['json_data'] = Variable<String>(jsonData);
    return map;
  }

  FoodsCompanion toCompanion(bool nullToAbsent) {
    return FoodsCompanion(
      id: Value(id),
      dateAdded: Value(dateAdded),
      referenceDate: Value(referenceDate),
      jsonData: Value(jsonData),
    );
  }

  factory DBFood.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DBFood(
      id: serializer.fromJson<String>(json['id']),
      dateAdded: serializer.fromJson<DateTime>(json['dateAdded']),
      referenceDate: serializer.fromJson<DateTime>(json['referenceDate']),
      jsonData: serializer.fromJson<String>(json['jsonData']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'dateAdded': serializer.toJson<DateTime>(dateAdded),
      'referenceDate': serializer.toJson<DateTime>(referenceDate),
      'jsonData': serializer.toJson<String>(jsonData),
    };
  }

  DBFood copyWith(
          {String? id,
          DateTime? dateAdded,
          DateTime? referenceDate,
          String? jsonData}) =>
      DBFood(
        id: id ?? this.id,
        dateAdded: dateAdded ?? this.dateAdded,
        referenceDate: referenceDate ?? this.referenceDate,
        jsonData: jsonData ?? this.jsonData,
      );
  DBFood copyWithCompanion(FoodsCompanion data) {
    return DBFood(
      id: data.id.present ? data.id.value : this.id,
      dateAdded: data.dateAdded.present ? data.dateAdded.value : this.dateAdded,
      referenceDate: data.referenceDate.present
          ? data.referenceDate.value
          : this.referenceDate,
      jsonData: data.jsonData.present ? data.jsonData.value : this.jsonData,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DBFood(')
          ..write('id: $id, ')
          ..write('dateAdded: $dateAdded, ')
          ..write('referenceDate: $referenceDate, ')
          ..write('jsonData: $jsonData')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, dateAdded, referenceDate, jsonData);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DBFood &&
          other.id == this.id &&
          other.dateAdded == this.dateAdded &&
          other.referenceDate == this.referenceDate &&
          other.jsonData == this.jsonData);
}

class FoodsCompanion extends UpdateCompanion<DBFood> {
  final Value<String> id;
  final Value<DateTime> dateAdded;
  final Value<DateTime> referenceDate;
  final Value<String> jsonData;
  final Value<int> rowid;
  const FoodsCompanion({
    this.id = const Value.absent(),
    this.dateAdded = const Value.absent(),
    this.referenceDate = const Value.absent(),
    this.jsonData = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FoodsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime dateAdded,
    required DateTime referenceDate,
    required String jsonData,
    this.rowid = const Value.absent(),
  })  : dateAdded = Value(dateAdded),
        referenceDate = Value(referenceDate),
        jsonData = Value(jsonData);
  static Insertable<DBFood> custom({
    Expression<String>? id,
    Expression<DateTime>? dateAdded,
    Expression<DateTime>? referenceDate,
    Expression<String>? jsonData,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dateAdded != null) 'date_added': dateAdded,
      if (referenceDate != null) 'reference_date': referenceDate,
      if (jsonData != null) 'json_data': jsonData,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FoodsCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? dateAdded,
      Value<DateTime>? referenceDate,
      Value<String>? jsonData,
      Value<int>? rowid}) {
    return FoodsCompanion(
      id: id ?? this.id,
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
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: () => _uuid.v4());
  static const VerificationMeta _referenceDateMeta =
      const VerificationMeta('referenceDate');
  @override
  late final GeneratedColumn<DateTime> referenceDate =
      GeneratedColumn<DateTime>('reference_date', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _caloriesMeta =
      const VerificationMeta('calories');
  @override
  late final GeneratedColumn<double> calories = GeneratedColumn<double>(
      'calories', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _fatMeta = const VerificationMeta('fat');
  @override
  late final GeneratedColumn<double> fat = GeneratedColumn<double>(
      'fat', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _carbsMeta = const VerificationMeta('carbs');
  @override
  late final GeneratedColumn<double> carbs = GeneratedColumn<double>(
      'carbs', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _proteinMeta =
      const VerificationMeta('protein');
  @override
  late final GeneratedColumn<double> protein = GeneratedColumn<double>(
      'protein', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, referenceDate, calories, fat, carbs, protein];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'nutrition_goals';
  @override
  VerificationContext validateIntegrity(Insertable<DBNutritionGoal> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('reference_date')) {
      context.handle(
          _referenceDateMeta,
          referenceDate.isAcceptableOrUnknown(
              data['reference_date']!, _referenceDateMeta));
    } else if (isInserting) {
      context.missing(_referenceDateMeta);
    }
    if (data.containsKey('calories')) {
      context.handle(_caloriesMeta,
          calories.isAcceptableOrUnknown(data['calories']!, _caloriesMeta));
    } else if (isInserting) {
      context.missing(_caloriesMeta);
    }
    if (data.containsKey('fat')) {
      context.handle(
          _fatMeta, fat.isAcceptableOrUnknown(data['fat']!, _fatMeta));
    } else if (isInserting) {
      context.missing(_fatMeta);
    }
    if (data.containsKey('carbs')) {
      context.handle(
          _carbsMeta, carbs.isAcceptableOrUnknown(data['carbs']!, _carbsMeta));
    } else if (isInserting) {
      context.missing(_carbsMeta);
    }
    if (data.containsKey('protein')) {
      context.handle(_proteinMeta,
          protein.isAcceptableOrUnknown(data['protein']!, _proteinMeta));
    } else if (isInserting) {
      context.missing(_proteinMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DBNutritionGoal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DBNutritionGoal(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      referenceDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}reference_date'])!,
      calories: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}calories'])!,
      fat: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}fat'])!,
      carbs: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}carbs'])!,
      protein: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}protein'])!,
    );
  }

  @override
  $NutritionGoalsTable createAlias(String alias) {
    return $NutritionGoalsTable(attachedDatabase, alias);
  }
}

class DBNutritionGoal extends DataClass implements Insertable<DBNutritionGoal> {
  final String id;
  final DateTime referenceDate;
  final double calories;
  final double fat;
  final double carbs;
  final double protein;
  const DBNutritionGoal(
      {required this.id,
      required this.referenceDate,
      required this.calories,
      required this.fat,
      required this.carbs,
      required this.protein});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['reference_date'] = Variable<DateTime>(referenceDate);
    map['calories'] = Variable<double>(calories);
    map['fat'] = Variable<double>(fat);
    map['carbs'] = Variable<double>(carbs);
    map['protein'] = Variable<double>(protein);
    return map;
  }

  NutritionGoalsCompanion toCompanion(bool nullToAbsent) {
    return NutritionGoalsCompanion(
      id: Value(id),
      referenceDate: Value(referenceDate),
      calories: Value(calories),
      fat: Value(fat),
      carbs: Value(carbs),
      protein: Value(protein),
    );
  }

  factory DBNutritionGoal.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DBNutritionGoal(
      id: serializer.fromJson<String>(json['id']),
      referenceDate: serializer.fromJson<DateTime>(json['referenceDate']),
      calories: serializer.fromJson<double>(json['calories']),
      fat: serializer.fromJson<double>(json['fat']),
      carbs: serializer.fromJson<double>(json['carbs']),
      protein: serializer.fromJson<double>(json['protein']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'referenceDate': serializer.toJson<DateTime>(referenceDate),
      'calories': serializer.toJson<double>(calories),
      'fat': serializer.toJson<double>(fat),
      'carbs': serializer.toJson<double>(carbs),
      'protein': serializer.toJson<double>(protein),
    };
  }

  DBNutritionGoal copyWith(
          {String? id,
          DateTime? referenceDate,
          double? calories,
          double? fat,
          double? carbs,
          double? protein}) =>
      DBNutritionGoal(
        id: id ?? this.id,
        referenceDate: referenceDate ?? this.referenceDate,
        calories: calories ?? this.calories,
        fat: fat ?? this.fat,
        carbs: carbs ?? this.carbs,
        protein: protein ?? this.protein,
      );
  DBNutritionGoal copyWithCompanion(NutritionGoalsCompanion data) {
    return DBNutritionGoal(
      id: data.id.present ? data.id.value : this.id,
      referenceDate: data.referenceDate.present
          ? data.referenceDate.value
          : this.referenceDate,
      calories: data.calories.present ? data.calories.value : this.calories,
      fat: data.fat.present ? data.fat.value : this.fat,
      carbs: data.carbs.present ? data.carbs.value : this.carbs,
      protein: data.protein.present ? data.protein.value : this.protein,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DBNutritionGoal(')
          ..write('id: $id, ')
          ..write('referenceDate: $referenceDate, ')
          ..write('calories: $calories, ')
          ..write('fat: $fat, ')
          ..write('carbs: $carbs, ')
          ..write('protein: $protein')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, referenceDate, calories, fat, carbs, protein);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DBNutritionGoal &&
          other.id == this.id &&
          other.referenceDate == this.referenceDate &&
          other.calories == this.calories &&
          other.fat == this.fat &&
          other.carbs == this.carbs &&
          other.protein == this.protein);
}

class NutritionGoalsCompanion extends UpdateCompanion<DBNutritionGoal> {
  final Value<String> id;
  final Value<DateTime> referenceDate;
  final Value<double> calories;
  final Value<double> fat;
  final Value<double> carbs;
  final Value<double> protein;
  final Value<int> rowid;
  const NutritionGoalsCompanion({
    this.id = const Value.absent(),
    this.referenceDate = const Value.absent(),
    this.calories = const Value.absent(),
    this.fat = const Value.absent(),
    this.carbs = const Value.absent(),
    this.protein = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NutritionGoalsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime referenceDate,
    required double calories,
    required double fat,
    required double carbs,
    required double protein,
    this.rowid = const Value.absent(),
  })  : referenceDate = Value(referenceDate),
        calories = Value(calories),
        fat = Value(fat),
        carbs = Value(carbs),
        protein = Value(protein);
  static Insertable<DBNutritionGoal> custom({
    Expression<String>? id,
    Expression<DateTime>? referenceDate,
    Expression<double>? calories,
    Expression<double>? fat,
    Expression<double>? carbs,
    Expression<double>? protein,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (referenceDate != null) 'reference_date': referenceDate,
      if (calories != null) 'calories': calories,
      if (fat != null) 'fat': fat,
      if (carbs != null) 'carbs': carbs,
      if (protein != null) 'protein': protein,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NutritionGoalsCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? referenceDate,
      Value<double>? calories,
      Value<double>? fat,
      Value<double>? carbs,
      Value<double>? protein,
      Value<int>? rowid}) {
    return NutritionGoalsCompanion(
      id: id ?? this.id,
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
    with TableInfo<$CustomBarcodeFoodsTable, CustomBarcodeFood> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomBarcodeFoodsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _barcodeMeta =
      const VerificationMeta('barcode');
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
      'barcode', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _jsonDataMeta =
      const VerificationMeta('jsonData');
  @override
  late final GeneratedColumn<String> jsonData = GeneratedColumn<String>(
      'json_data', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [barcode, jsonData];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_barcode_foods';
  @override
  VerificationContext validateIntegrity(Insertable<CustomBarcodeFood> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('barcode')) {
      context.handle(_barcodeMeta,
          barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta));
    } else if (isInserting) {
      context.missing(_barcodeMeta);
    }
    if (data.containsKey('json_data')) {
      context.handle(_jsonDataMeta,
          jsonData.isAcceptableOrUnknown(data['json_data']!, _jsonDataMeta));
    } else if (isInserting) {
      context.missing(_jsonDataMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {barcode};
  @override
  CustomBarcodeFood map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomBarcodeFood(
      barcode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}barcode'])!,
      jsonData: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}json_data'])!,
    );
  }

  @override
  $CustomBarcodeFoodsTable createAlias(String alias) {
    return $CustomBarcodeFoodsTable(attachedDatabase, alias);
  }
}

class CustomBarcodeFood extends DataClass
    implements Insertable<CustomBarcodeFood> {
  final String barcode;
  final String jsonData;
  const CustomBarcodeFood({required this.barcode, required this.jsonData});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['barcode'] = Variable<String>(barcode);
    map['json_data'] = Variable<String>(jsonData);
    return map;
  }

  CustomBarcodeFoodsCompanion toCompanion(bool nullToAbsent) {
    return CustomBarcodeFoodsCompanion(
      barcode: Value(barcode),
      jsonData: Value(jsonData),
    );
  }

  factory CustomBarcodeFood.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomBarcodeFood(
      barcode: serializer.fromJson<String>(json['barcode']),
      jsonData: serializer.fromJson<String>(json['jsonData']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'barcode': serializer.toJson<String>(barcode),
      'jsonData': serializer.toJson<String>(jsonData),
    };
  }

  CustomBarcodeFood copyWith({String? barcode, String? jsonData}) =>
      CustomBarcodeFood(
        barcode: barcode ?? this.barcode,
        jsonData: jsonData ?? this.jsonData,
      );
  CustomBarcodeFood copyWithCompanion(CustomBarcodeFoodsCompanion data) {
    return CustomBarcodeFood(
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      jsonData: data.jsonData.present ? data.jsonData.value : this.jsonData,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomBarcodeFood(')
          ..write('barcode: $barcode, ')
          ..write('jsonData: $jsonData')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(barcode, jsonData);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomBarcodeFood &&
          other.barcode == this.barcode &&
          other.jsonData == this.jsonData);
}

class CustomBarcodeFoodsCompanion extends UpdateCompanion<CustomBarcodeFood> {
  final Value<String> barcode;
  final Value<String> jsonData;
  final Value<int> rowid;
  const CustomBarcodeFoodsCompanion({
    this.barcode = const Value.absent(),
    this.jsonData = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomBarcodeFoodsCompanion.insert({
    required String barcode,
    required String jsonData,
    this.rowid = const Value.absent(),
  })  : barcode = Value(barcode),
        jsonData = Value(jsonData);
  static Insertable<CustomBarcodeFood> custom({
    Expression<String>? barcode,
    Expression<String>? jsonData,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (barcode != null) 'barcode': barcode,
      if (jsonData != null) 'json_data': jsonData,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomBarcodeFoodsCompanion copyWith(
      {Value<String>? barcode, Value<String>? jsonData, Value<int>? rowid}) {
    return CustomBarcodeFoodsCompanion(
      barcode: barcode ?? this.barcode,
      jsonData: jsonData ?? this.jsonData,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
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
          ..write('barcode: $barcode, ')
          ..write('jsonData: $jsonData, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FavoriteFoodsTable extends FavoriteFoods
    with TableInfo<$FavoriteFoodsTable, FavoriteFood> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FavoriteFoodsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _foodIdMeta = const VerificationMeta('foodId');
  @override
  late final GeneratedColumn<String> foodId = GeneratedColumn<String>(
      'food_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES foods (id)'));
  @override
  List<GeneratedColumn> get $columns => [foodId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'favorite_foods';
  @override
  VerificationContext validateIntegrity(Insertable<FavoriteFood> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('food_id')) {
      context.handle(_foodIdMeta,
          foodId.isAcceptableOrUnknown(data['food_id']!, _foodIdMeta));
    } else if (isInserting) {
      context.missing(_foodIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  FavoriteFood map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FavoriteFood(
      foodId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}food_id'])!,
    );
  }

  @override
  $FavoriteFoodsTable createAlias(String alias) {
    return $FavoriteFoodsTable(attachedDatabase, alias);
  }
}

class FavoriteFood extends DataClass implements Insertable<FavoriteFood> {
  final String foodId;
  const FavoriteFood({required this.foodId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['food_id'] = Variable<String>(foodId);
    return map;
  }

  FavoriteFoodsCompanion toCompanion(bool nullToAbsent) {
    return FavoriteFoodsCompanion(
      foodId: Value(foodId),
    );
  }

  factory FavoriteFood.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FavoriteFood(
      foodId: serializer.fromJson<String>(json['foodId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'foodId': serializer.toJson<String>(foodId),
    };
  }

  FavoriteFood copyWith({String? foodId}) => FavoriteFood(
        foodId: foodId ?? this.foodId,
      );
  FavoriteFood copyWithCompanion(FavoriteFoodsCompanion data) {
    return FavoriteFood(
      foodId: data.foodId.present ? data.foodId.value : this.foodId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteFood(')
          ..write('foodId: $foodId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => foodId.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FavoriteFood && other.foodId == this.foodId);
}

class FavoriteFoodsCompanion extends UpdateCompanion<FavoriteFood> {
  final Value<String> foodId;
  final Value<int> rowid;
  const FavoriteFoodsCompanion({
    this.foodId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FavoriteFoodsCompanion.insert({
    required String foodId,
    this.rowid = const Value.absent(),
  }) : foodId = Value(foodId);
  static Insertable<FavoriteFood> custom({
    Expression<String>? foodId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (foodId != null) 'food_id': foodId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FavoriteFoodsCompanion copyWith({Value<String>? foodId, Value<int>? rowid}) {
    return FavoriteFoodsCompanion(
      foodId: foodId ?? this.foodId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (foodId.present) {
      map['food_id'] = Variable<String>(foodId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteFoodsCompanion(')
          ..write('foodId: $foodId, ')
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
  static const VerificationMeta _referenceDateMeta =
      const VerificationMeta('referenceDate');
  @override
  late final GeneratedColumn<DateTime> referenceDate =
      GeneratedColumn<DateTime>('reference_date', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _jsonDataMeta =
      const VerificationMeta('jsonData');
  @override
  late final GeneratedColumn<String> jsonData = GeneratedColumn<String>(
      'json_data', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [referenceDate, jsonData];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'nutrition_categories';
  @override
  VerificationContext validateIntegrity(
      Insertable<DBNutritionCategory> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('reference_date')) {
      context.handle(
          _referenceDateMeta,
          referenceDate.isAcceptableOrUnknown(
              data['reference_date']!, _referenceDateMeta));
    } else if (isInserting) {
      context.missing(_referenceDateMeta);
    }
    if (data.containsKey('json_data')) {
      context.handle(_jsonDataMeta,
          jsonData.isAcceptableOrUnknown(data['json_data']!, _jsonDataMeta));
    } else if (isInserting) {
      context.missing(_jsonDataMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  DBNutritionCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DBNutritionCategory(
      referenceDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}reference_date'])!,
      jsonData: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}json_data'])!,
    );
  }

  @override
  $NutritionCategoriesTable createAlias(String alias) {
    return $NutritionCategoriesTable(attachedDatabase, alias);
  }
}

class DBNutritionCategory extends DataClass
    implements Insertable<DBNutritionCategory> {
  final DateTime referenceDate;
  final String jsonData;
  const DBNutritionCategory(
      {required this.referenceDate, required this.jsonData});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['reference_date'] = Variable<DateTime>(referenceDate);
    map['json_data'] = Variable<String>(jsonData);
    return map;
  }

  NutritionCategoriesCompanion toCompanion(bool nullToAbsent) {
    return NutritionCategoriesCompanion(
      referenceDate: Value(referenceDate),
      jsonData: Value(jsonData),
    );
  }

  factory DBNutritionCategory.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DBNutritionCategory(
      referenceDate: serializer.fromJson<DateTime>(json['referenceDate']),
      jsonData: serializer.fromJson<String>(json['jsonData']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'referenceDate': serializer.toJson<DateTime>(referenceDate),
      'jsonData': serializer.toJson<String>(jsonData),
    };
  }

  DBNutritionCategory copyWith({DateTime? referenceDate, String? jsonData}) =>
      DBNutritionCategory(
        referenceDate: referenceDate ?? this.referenceDate,
        jsonData: jsonData ?? this.jsonData,
      );
  DBNutritionCategory copyWithCompanion(NutritionCategoriesCompanion data) {
    return DBNutritionCategory(
      referenceDate: data.referenceDate.present
          ? data.referenceDate.value
          : this.referenceDate,
      jsonData: data.jsonData.present ? data.jsonData.value : this.jsonData,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DBNutritionCategory(')
          ..write('referenceDate: $referenceDate, ')
          ..write('jsonData: $jsonData')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(referenceDate, jsonData);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DBNutritionCategory &&
          other.referenceDate == this.referenceDate &&
          other.jsonData == this.jsonData);
}

class NutritionCategoriesCompanion
    extends UpdateCompanion<DBNutritionCategory> {
  final Value<DateTime> referenceDate;
  final Value<String> jsonData;
  final Value<int> rowid;
  const NutritionCategoriesCompanion({
    this.referenceDate = const Value.absent(),
    this.jsonData = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NutritionCategoriesCompanion.insert({
    required DateTime referenceDate,
    required String jsonData,
    this.rowid = const Value.absent(),
  })  : referenceDate = Value(referenceDate),
        jsonData = Value(jsonData);
  static Insertable<DBNutritionCategory> custom({
    Expression<DateTime>? referenceDate,
    Expression<String>? jsonData,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (referenceDate != null) 'reference_date': referenceDate,
      if (jsonData != null) 'json_data': jsonData,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NutritionCategoriesCompanion copyWith(
      {Value<DateTime>? referenceDate,
      Value<String>? jsonData,
      Value<int>? rowid}) {
    return NutritionCategoriesCompanion(
      referenceDate: referenceDate ?? this.referenceDate,
      jsonData: jsonData ?? this.jsonData,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
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
  static const VerificationMeta _achievementIDMeta =
      const VerificationMeta('achievementID');
  @override
  late final GeneratedColumn<String> achievementID = GeneratedColumn<String>(
      'achievement_i_d', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<int> level = GeneratedColumn<int>(
      'level', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [achievementID, level, completedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'achievements';
  @override
  VerificationContext validateIntegrity(
      Insertable<AchievementCompletion> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('achievement_i_d')) {
      context.handle(
          _achievementIDMeta,
          achievementID.isAcceptableOrUnknown(
              data['achievement_i_d']!, _achievementIDMeta));
    } else if (isInserting) {
      context.missing(_achievementIDMeta);
    }
    if (data.containsKey('level')) {
      context.handle(
          _levelMeta, level.isAcceptableOrUnknown(data['level']!, _levelMeta));
    } else if (isInserting) {
      context.missing(_levelMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {achievementID, level};
  @override
  AchievementCompletion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AchievementCompletion(
      achievementID: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}achievement_i_d'])!,
      level: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}level'])!,
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at'])!,
    );
  }

  @override
  $AchievementsTable createAlias(String alias) {
    return $AchievementsTable(attachedDatabase, alias);
  }
}

class AchievementsCompanion extends UpdateCompanion<AchievementCompletion> {
  final Value<String> achievementID;
  final Value<int> level;
  final Value<DateTime> completedAt;
  final Value<int> rowid;
  const AchievementsCompanion({
    this.achievementID = const Value.absent(),
    this.level = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AchievementsCompanion.insert({
    required String achievementID,
    required int level,
    required DateTime completedAt,
    this.rowid = const Value.absent(),
  })  : achievementID = Value(achievementID),
        level = Value(level),
        completedAt = Value(completedAt);
  static Insertable<AchievementCompletion> custom({
    Expression<String>? achievementID,
    Expression<int>? level,
    Expression<DateTime>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (achievementID != null) 'achievement_i_d': achievementID,
      if (level != null) 'level': level,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AchievementsCompanion copyWith(
      {Value<String>? achievementID,
      Value<int>? level,
      Value<DateTime>? completedAt,
      Value<int>? rowid}) {
    return AchievementsCompanion(
      achievementID: achievementID ?? this.achievementID,
      level: level ?? this.level,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (achievementID.present) {
      map['achievement_i_d'] = Variable<String>(achievementID.value);
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
          ..write('achievementID: $achievementID, ')
          ..write('level: $level, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$GTDatabaseImpl extends GeneratedDatabase {
  _$GTDatabaseImpl(QueryExecutor e) : super(e);
  $GTDatabaseImplManager get managers => $GTDatabaseImplManager(this);
  late final $CustomExercisesTable customExercises =
      $CustomExercisesTable(this);
  late final $RoutineFoldersTable routineFolders = $RoutineFoldersTable(this);
  late final $RoutinesTable routines = $RoutinesTable(this);
  late final $HistoryWorkoutsTable historyWorkouts =
      $HistoryWorkoutsTable(this);
  late final $HistoryWorkoutExercisesTable historyWorkoutExercises =
      $HistoryWorkoutExercisesTable(this);
  late final $RoutineExercisesTable routineExercises =
      $RoutineExercisesTable(this);
  late final $PreferencesTable preferences = $PreferencesTable(this);
  late final $OngoingDataTable ongoingData = $OngoingDataTable(this);
  late final $WeightMeasurementsTable weightMeasurements =
      $WeightMeasurementsTable(this);
  late final $BodyMeasurementsTable bodyMeasurements =
      $BodyMeasurementsTable(this);
  late final $FoodsTable foods = $FoodsTable(this);
  late final $NutritionGoalsTable nutritionGoals = $NutritionGoalsTable(this);
  late final $CustomBarcodeFoodsTable customBarcodeFoods =
      $CustomBarcodeFoodsTable(this);
  late final $FavoriteFoodsTable favoriteFoods = $FavoriteFoodsTable(this);
  late final $NutritionCategoriesTable nutritionCategories =
      $NutritionCategoriesTable(this);
  late final $AchievementsTable achievements = $AchievementsTable(this);
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
        achievements
      ];
}

typedef $$CustomExercisesTableCreateCompanionBuilder = CustomExercisesCompanion
    Function({
  Value<String> id,
  required String name,
  required GTSetParameters parameters,
  required GTMuscleGroup primaryMuscleGroup,
  required Set<GTMuscleGroup> secondaryMuscleGroups,
  Value<GTGymEquipment?> equipment,
  Value<int> rowid,
});
typedef $$CustomExercisesTableUpdateCompanionBuilder = CustomExercisesCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<GTSetParameters> parameters,
  Value<GTMuscleGroup> primaryMuscleGroup,
  Value<Set<GTMuscleGroup>> secondaryMuscleGroups,
  Value<GTGymEquipment?> equipment,
  Value<int> rowid,
});

class $$CustomExercisesTableTableManager extends RootTableManager<
    _$GTDatabaseImpl,
    $CustomExercisesTable,
    CustomExercise,
    $$CustomExercisesTableFilterComposer,
    $$CustomExercisesTableOrderingComposer,
    $$CustomExercisesTableCreateCompanionBuilder,
    $$CustomExercisesTableUpdateCompanionBuilder> {
  $$CustomExercisesTableTableManager(
      _$GTDatabaseImpl db, $CustomExercisesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$CustomExercisesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$CustomExercisesTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<GTSetParameters> parameters = const Value.absent(),
            Value<GTMuscleGroup> primaryMuscleGroup = const Value.absent(),
            Value<Set<GTMuscleGroup>> secondaryMuscleGroups =
                const Value.absent(),
            Value<GTGymEquipment?> equipment = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CustomExercisesCompanion(
            id: id,
            name: name,
            parameters: parameters,
            primaryMuscleGroup: primaryMuscleGroup,
            secondaryMuscleGroups: secondaryMuscleGroups,
            equipment: equipment,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<String> id = const Value.absent(),
            required String name,
            required GTSetParameters parameters,
            required GTMuscleGroup primaryMuscleGroup,
            required Set<GTMuscleGroup> secondaryMuscleGroups,
            Value<GTGymEquipment?> equipment = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CustomExercisesCompanion.insert(
            id: id,
            name: name,
            parameters: parameters,
            primaryMuscleGroup: primaryMuscleGroup,
            secondaryMuscleGroups: secondaryMuscleGroups,
            equipment: equipment,
            rowid: rowid,
          ),
        ));
}

class $$CustomExercisesTableFilterComposer
    extends FilterComposer<_$GTDatabaseImpl, $CustomExercisesTable> {
  $$CustomExercisesTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnWithTypeConverterFilters<GTSetParameters, GTSetParameters, String>
      get parameters => $state.composableBuilder(
          column: $state.table.parameters,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));

  ColumnWithTypeConverterFilters<GTMuscleGroup, GTMuscleGroup, String>
      get primaryMuscleGroup => $state.composableBuilder(
          column: $state.table.primaryMuscleGroup,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));

  ColumnWithTypeConverterFilters<Set<GTMuscleGroup>, Set<GTMuscleGroup>, String>
      get secondaryMuscleGroups => $state.composableBuilder(
          column: $state.table.secondaryMuscleGroups,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));

  ColumnWithTypeConverterFilters<GTGymEquipment?, GTGymEquipment, String>
      get equipment => $state.composableBuilder(
          column: $state.table.equipment,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));

  ComposableFilter historyWorkoutExercisesRefs(
      ComposableFilter Function($$HistoryWorkoutExercisesTableFilterComposer f)
          f) {
    final $$HistoryWorkoutExercisesTableFilterComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $state.db.historyWorkoutExercises,
            getReferencedColumn: (t) => t.customExerciseId,
            builder: (joinBuilder, parentComposers) =>
                $$HistoryWorkoutExercisesTableFilterComposer(ComposerState(
                    $state.db,
                    $state.db.historyWorkoutExercises,
                    joinBuilder,
                    parentComposers)));
    return f(composer);
  }

  ComposableFilter routineExercisesRefs(
      ComposableFilter Function($$RoutineExercisesTableFilterComposer f) f) {
    final $$RoutineExercisesTableFilterComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $state.db.routineExercises,
            getReferencedColumn: (t) => t.customExerciseId,
            builder: (joinBuilder, parentComposers) =>
                $$RoutineExercisesTableFilterComposer(ComposerState($state.db,
                    $state.db.routineExercises, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$CustomExercisesTableOrderingComposer
    extends OrderingComposer<_$GTDatabaseImpl, $CustomExercisesTable> {
  $$CustomExercisesTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get parameters => $state.composableBuilder(
      column: $state.table.parameters,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get primaryMuscleGroup => $state.composableBuilder(
      column: $state.table.primaryMuscleGroup,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get secondaryMuscleGroups => $state.composableBuilder(
      column: $state.table.secondaryMuscleGroups,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get equipment => $state.composableBuilder(
      column: $state.table.equipment,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$RoutineFoldersTableCreateCompanionBuilder = RoutineFoldersCompanion
    Function({
  Value<String> id,
  required String name,
  required int sortOrder,
  Value<int> rowid,
});
typedef $$RoutineFoldersTableUpdateCompanionBuilder = RoutineFoldersCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<int> sortOrder,
  Value<int> rowid,
});

class $$RoutineFoldersTableTableManager extends RootTableManager<
    _$GTDatabaseImpl,
    $RoutineFoldersTable,
    RoutineFolder,
    $$RoutineFoldersTableFilterComposer,
    $$RoutineFoldersTableOrderingComposer,
    $$RoutineFoldersTableCreateCompanionBuilder,
    $$RoutineFoldersTableUpdateCompanionBuilder> {
  $$RoutineFoldersTableTableManager(
      _$GTDatabaseImpl db, $RoutineFoldersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$RoutineFoldersTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$RoutineFoldersTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RoutineFoldersCompanion(
            id: id,
            name: name,
            sortOrder: sortOrder,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<String> id = const Value.absent(),
            required String name,
            required int sortOrder,
            Value<int> rowid = const Value.absent(),
          }) =>
              RoutineFoldersCompanion.insert(
            id: id,
            name: name,
            sortOrder: sortOrder,
            rowid: rowid,
          ),
        ));
}

class $$RoutineFoldersTableFilterComposer
    extends FilterComposer<_$GTDatabaseImpl, $RoutineFoldersTable> {
  $$RoutineFoldersTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get sortOrder => $state.composableBuilder(
      column: $state.table.sortOrder,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ComposableFilter routinesRefs(
      ComposableFilter Function($$RoutinesTableFilterComposer f) f) {
    final $$RoutinesTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.routines,
        getReferencedColumn: (t) => t.folderId,
        builder: (joinBuilder, parentComposers) =>
            $$RoutinesTableFilterComposer(ComposerState(
                $state.db, $state.db.routines, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$RoutineFoldersTableOrderingComposer
    extends OrderingComposer<_$GTDatabaseImpl, $RoutineFoldersTable> {
  $$RoutineFoldersTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get sortOrder => $state.composableBuilder(
      column: $state.table.sortOrder,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$RoutinesTableCreateCompanionBuilder = RoutinesCompanion Function({
  Value<String> id,
  required String name,
  required String infobox,
  required Weights weightUnit,
  required Distance distanceUnit,
  required int sortOrder,
  Value<String?> folderId,
  Value<int> rowid,
});
typedef $$RoutinesTableUpdateCompanionBuilder = RoutinesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> infobox,
  Value<Weights> weightUnit,
  Value<Distance> distanceUnit,
  Value<int> sortOrder,
  Value<String?> folderId,
  Value<int> rowid,
});

class $$RoutinesTableTableManager extends RootTableManager<
    _$GTDatabaseImpl,
    $RoutinesTable,
    Routine,
    $$RoutinesTableFilterComposer,
    $$RoutinesTableOrderingComposer,
    $$RoutinesTableCreateCompanionBuilder,
    $$RoutinesTableUpdateCompanionBuilder> {
  $$RoutinesTableTableManager(_$GTDatabaseImpl db, $RoutinesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$RoutinesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$RoutinesTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> infobox = const Value.absent(),
            Value<Weights> weightUnit = const Value.absent(),
            Value<Distance> distanceUnit = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<String?> folderId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RoutinesCompanion(
            id: id,
            name: name,
            infobox: infobox,
            weightUnit: weightUnit,
            distanceUnit: distanceUnit,
            sortOrder: sortOrder,
            folderId: folderId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<String> id = const Value.absent(),
            required String name,
            required String infobox,
            required Weights weightUnit,
            required Distance distanceUnit,
            required int sortOrder,
            Value<String?> folderId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RoutinesCompanion.insert(
            id: id,
            name: name,
            infobox: infobox,
            weightUnit: weightUnit,
            distanceUnit: distanceUnit,
            sortOrder: sortOrder,
            folderId: folderId,
            rowid: rowid,
          ),
        ));
}

class $$RoutinesTableFilterComposer
    extends FilterComposer<_$GTDatabaseImpl, $RoutinesTable> {
  $$RoutinesTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get infobox => $state.composableBuilder(
      column: $state.table.infobox,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnWithTypeConverterFilters<Weights, Weights, String> get weightUnit =>
      $state.composableBuilder(
          column: $state.table.weightUnit,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));

  ColumnWithTypeConverterFilters<Distance, Distance, String> get distanceUnit =>
      $state.composableBuilder(
          column: $state.table.distanceUnit,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));

  ColumnFilters<int> get sortOrder => $state.composableBuilder(
      column: $state.table.sortOrder,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$RoutineFoldersTableFilterComposer get folderId {
    final $$RoutineFoldersTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.folderId,
        referencedTable: $state.db.routineFolders,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$RoutineFoldersTableFilterComposer(ComposerState($state.db,
                $state.db.routineFolders, joinBuilder, parentComposers)));
    return composer;
  }

  ComposableFilter historyWorkoutsRefs(
      ComposableFilter Function($$HistoryWorkoutsTableFilterComposer f) f) {
    final $$HistoryWorkoutsTableFilterComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $state.db.historyWorkouts,
            getReferencedColumn: (t) => t.parentId,
            builder: (joinBuilder, parentComposers) =>
                $$HistoryWorkoutsTableFilterComposer(ComposerState($state.db,
                    $state.db.historyWorkouts, joinBuilder, parentComposers)));
    return f(composer);
  }

  ComposableFilter routineExercisesRefs(
      ComposableFilter Function($$RoutineExercisesTableFilterComposer f) f) {
    final $$RoutineExercisesTableFilterComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $state.db.routineExercises,
            getReferencedColumn: (t) => t.routineId,
            builder: (joinBuilder, parentComposers) =>
                $$RoutineExercisesTableFilterComposer(ComposerState($state.db,
                    $state.db.routineExercises, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$RoutinesTableOrderingComposer
    extends OrderingComposer<_$GTDatabaseImpl, $RoutinesTable> {
  $$RoutinesTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get infobox => $state.composableBuilder(
      column: $state.table.infobox,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get weightUnit => $state.composableBuilder(
      column: $state.table.weightUnit,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get distanceUnit => $state.composableBuilder(
      column: $state.table.distanceUnit,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get sortOrder => $state.composableBuilder(
      column: $state.table.sortOrder,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$RoutineFoldersTableOrderingComposer get folderId {
    final $$RoutineFoldersTableOrderingComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.folderId,
            referencedTable: $state.db.routineFolders,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder, parentComposers) =>
                $$RoutineFoldersTableOrderingComposer(ComposerState($state.db,
                    $state.db.routineFolders, joinBuilder, parentComposers)));
    return composer;
  }
}

typedef $$HistoryWorkoutsTableCreateCompanionBuilder = HistoryWorkoutsCompanion
    Function({
  Value<String> id,
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
typedef $$HistoryWorkoutsTableUpdateCompanionBuilder = HistoryWorkoutsCompanion
    Function({
  Value<String> id,
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

class $$HistoryWorkoutsTableTableManager extends RootTableManager<
    _$GTDatabaseImpl,
    $HistoryWorkoutsTable,
    HistoryWorkout,
    $$HistoryWorkoutsTableFilterComposer,
    $$HistoryWorkoutsTableOrderingComposer,
    $$HistoryWorkoutsTableCreateCompanionBuilder,
    $$HistoryWorkoutsTableUpdateCompanionBuilder> {
  $$HistoryWorkoutsTableTableManager(
      _$GTDatabaseImpl db, $HistoryWorkoutsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$HistoryWorkoutsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$HistoryWorkoutsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
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
          }) =>
              HistoryWorkoutsCompanion(
            id: id,
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
          createCompanionCallback: ({
            Value<String> id = const Value.absent(),
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
          }) =>
              HistoryWorkoutsCompanion.insert(
            id: id,
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
        ));
}

class $$HistoryWorkoutsTableFilterComposer
    extends FilterComposer<_$GTDatabaseImpl, $HistoryWorkoutsTable> {
  $$HistoryWorkoutsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get infobox => $state.composableBuilder(
      column: $state.table.infobox,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get duration => $state.composableBuilder(
      column: $state.table.duration,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get startingDate => $state.composableBuilder(
      column: $state.table.startingDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnWithTypeConverterFilters<Weights, Weights, String> get weightUnit =>
      $state.composableBuilder(
          column: $state.table.weightUnit,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));

  ColumnWithTypeConverterFilters<Distance, Distance, String> get distanceUnit =>
      $state.composableBuilder(
          column: $state.table.distanceUnit,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));

  $$RoutinesTableFilterComposer get parentId {
    final $$RoutinesTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.parentId,
        referencedTable: $state.db.routines,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$RoutinesTableFilterComposer(ComposerState(
                $state.db, $state.db.routines, joinBuilder, parentComposers)));
    return composer;
  }

  $$HistoryWorkoutsTableFilterComposer get completedBy {
    final $$HistoryWorkoutsTableFilterComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.completedBy,
            referencedTable: $state.db.historyWorkouts,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder, parentComposers) =>
                $$HistoryWorkoutsTableFilterComposer(ComposerState($state.db,
                    $state.db.historyWorkouts, joinBuilder, parentComposers)));
    return composer;
  }

  $$HistoryWorkoutsTableFilterComposer get completes {
    final $$HistoryWorkoutsTableFilterComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.completes,
            referencedTable: $state.db.historyWorkouts,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder, parentComposers) =>
                $$HistoryWorkoutsTableFilterComposer(ComposerState($state.db,
                    $state.db.historyWorkouts, joinBuilder, parentComposers)));
    return composer;
  }

  ComposableFilter historyWorkoutExercisesRefs(
      ComposableFilter Function($$HistoryWorkoutExercisesTableFilterComposer f)
          f) {
    final $$HistoryWorkoutExercisesTableFilterComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $state.db.historyWorkoutExercises,
            getReferencedColumn: (t) => t.routineId,
            builder: (joinBuilder, parentComposers) =>
                $$HistoryWorkoutExercisesTableFilterComposer(ComposerState(
                    $state.db,
                    $state.db.historyWorkoutExercises,
                    joinBuilder,
                    parentComposers)));
    return f(composer);
  }
}

class $$HistoryWorkoutsTableOrderingComposer
    extends OrderingComposer<_$GTDatabaseImpl, $HistoryWorkoutsTable> {
  $$HistoryWorkoutsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get infobox => $state.composableBuilder(
      column: $state.table.infobox,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get duration => $state.composableBuilder(
      column: $state.table.duration,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get startingDate => $state.composableBuilder(
      column: $state.table.startingDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get weightUnit => $state.composableBuilder(
      column: $state.table.weightUnit,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get distanceUnit => $state.composableBuilder(
      column: $state.table.distanceUnit,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$RoutinesTableOrderingComposer get parentId {
    final $$RoutinesTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.parentId,
        referencedTable: $state.db.routines,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$RoutinesTableOrderingComposer(ComposerState(
                $state.db, $state.db.routines, joinBuilder, parentComposers)));
    return composer;
  }

  $$HistoryWorkoutsTableOrderingComposer get completedBy {
    final $$HistoryWorkoutsTableOrderingComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.completedBy,
            referencedTable: $state.db.historyWorkouts,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder, parentComposers) =>
                $$HistoryWorkoutsTableOrderingComposer(ComposerState($state.db,
                    $state.db.historyWorkouts, joinBuilder, parentComposers)));
    return composer;
  }

  $$HistoryWorkoutsTableOrderingComposer get completes {
    final $$HistoryWorkoutsTableOrderingComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.completes,
            referencedTable: $state.db.historyWorkouts,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder, parentComposers) =>
                $$HistoryWorkoutsTableOrderingComposer(ComposerState($state.db,
                    $state.db.historyWorkouts, joinBuilder, parentComposers)));
    return composer;
  }
}

typedef $$HistoryWorkoutExercisesTableCreateCompanionBuilder
    = HistoryWorkoutExercisesCompanion Function({
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
  Value<GTGymEquipment?> equipment,
  Value<int> rowid,
});
typedef $$HistoryWorkoutExercisesTableUpdateCompanionBuilder
    = HistoryWorkoutExercisesCompanion Function({
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
  Value<GTGymEquipment?> equipment,
  Value<int> rowid,
});

class $$HistoryWorkoutExercisesTableTableManager extends RootTableManager<
    _$GTDatabaseImpl,
    $HistoryWorkoutExercisesTable,
    ConcreteExercise,
    $$HistoryWorkoutExercisesTableFilterComposer,
    $$HistoryWorkoutExercisesTableOrderingComposer,
    $$HistoryWorkoutExercisesTableCreateCompanionBuilder,
    $$HistoryWorkoutExercisesTableUpdateCompanionBuilder> {
  $$HistoryWorkoutExercisesTableTableManager(
      _$GTDatabaseImpl db, $HistoryWorkoutExercisesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$HistoryWorkoutExercisesTableFilterComposer(
              ComposerState(db, table)),
          orderingComposer: $$HistoryWorkoutExercisesTableOrderingComposer(
              ComposerState(db, table)),
          updateCompanionCallback: ({
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
            Value<GTGymEquipment?> equipment = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              HistoryWorkoutExercisesCompanion(
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
            equipment: equipment,
            rowid: rowid,
          ),
          createCompanionCallback: ({
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
            Value<GTGymEquipment?> equipment = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              HistoryWorkoutExercisesCompanion.insert(
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
            equipment: equipment,
            rowid: rowid,
          ),
        ));
}

class $$HistoryWorkoutExercisesTableFilterComposer
    extends FilterComposer<_$GTDatabaseImpl, $HistoryWorkoutExercisesTable> {
  $$HistoryWorkoutExercisesTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnWithTypeConverterFilters<GTSetParameters?, GTSetParameters, String>
      get parameters => $state.composableBuilder(
          column: $state.table.parameters,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));

  ColumnWithTypeConverterFilters<List<GTSet>?, List<GTSet>, String> get sets =>
      $state.composableBuilder(
          column: $state.table.sets,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));

  ColumnWithTypeConverterFilters<GTMuscleGroup?, GTMuscleGroup, String>
      get primaryMuscleGroup => $state.composableBuilder(
          column: $state.table.primaryMuscleGroup,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));

  ColumnWithTypeConverterFilters<Set<GTMuscleGroup>?, Set<GTMuscleGroup>,
          String>
      get secondaryMuscleGroups => $state.composableBuilder(
          column: $state.table.secondaryMuscleGroups,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));

  ColumnFilters<int> get restTime => $state.composableBuilder(
      column: $state.table.restTime,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isCustom => $state.composableBuilder(
      column: $state.table.isCustom,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get libraryExerciseId => $state.composableBuilder(
      column: $state.table.libraryExerciseId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get notes => $state.composableBuilder(
      column: $state.table.notes,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isSuperset => $state.composableBuilder(
      column: $state.table.isSuperset,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isInSuperset => $state.composableBuilder(
      column: $state.table.isInSuperset,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get sortOrder => $state.composableBuilder(
      column: $state.table.sortOrder,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get rpe => $state.composableBuilder(
      column: $state.table.rpe,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnWithTypeConverterFilters<GTGymEquipment?, GTGymEquipment, String>
      get equipment => $state.composableBuilder(
          column: $state.table.equipment,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));

  $$HistoryWorkoutsTableFilterComposer get routineId {
    final $$HistoryWorkoutsTableFilterComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.routineId,
            referencedTable: $state.db.historyWorkouts,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder, parentComposers) =>
                $$HistoryWorkoutsTableFilterComposer(ComposerState($state.db,
                    $state.db.historyWorkouts, joinBuilder, parentComposers)));
    return composer;
  }

  $$CustomExercisesTableFilterComposer get customExerciseId {
    final $$CustomExercisesTableFilterComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.customExerciseId,
            referencedTable: $state.db.customExercises,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder, parentComposers) =>
                $$CustomExercisesTableFilterComposer(ComposerState($state.db,
                    $state.db.customExercises, joinBuilder, parentComposers)));
    return composer;
  }

  $$HistoryWorkoutExercisesTableFilterComposer get supersetId {
    final $$HistoryWorkoutExercisesTableFilterComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.supersetId,
            referencedTable: $state.db.historyWorkoutExercises,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder, parentComposers) =>
                $$HistoryWorkoutExercisesTableFilterComposer(ComposerState(
                    $state.db,
                    $state.db.historyWorkoutExercises,
                    joinBuilder,
                    parentComposers)));
    return composer;
  }

  $$HistoryWorkoutExercisesTableFilterComposer get supersedesId {
    final $$HistoryWorkoutExercisesTableFilterComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.supersedesId,
            referencedTable: $state.db.historyWorkoutExercises,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder, parentComposers) =>
                $$HistoryWorkoutExercisesTableFilterComposer(ComposerState(
                    $state.db,
                    $state.db.historyWorkoutExercises,
                    joinBuilder,
                    parentComposers)));
    return composer;
  }
}

class $$HistoryWorkoutExercisesTableOrderingComposer
    extends OrderingComposer<_$GTDatabaseImpl, $HistoryWorkoutExercisesTable> {
  $$HistoryWorkoutExercisesTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get parameters => $state.composableBuilder(
      column: $state.table.parameters,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get sets => $state.composableBuilder(
      column: $state.table.sets,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get primaryMuscleGroup => $state.composableBuilder(
      column: $state.table.primaryMuscleGroup,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get secondaryMuscleGroups => $state.composableBuilder(
      column: $state.table.secondaryMuscleGroups,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get restTime => $state.composableBuilder(
      column: $state.table.restTime,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isCustom => $state.composableBuilder(
      column: $state.table.isCustom,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get libraryExerciseId => $state.composableBuilder(
      column: $state.table.libraryExerciseId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get notes => $state.composableBuilder(
      column: $state.table.notes,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isSuperset => $state.composableBuilder(
      column: $state.table.isSuperset,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isInSuperset => $state.composableBuilder(
      column: $state.table.isInSuperset,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get sortOrder => $state.composableBuilder(
      column: $state.table.sortOrder,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get rpe => $state.composableBuilder(
      column: $state.table.rpe,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get equipment => $state.composableBuilder(
      column: $state.table.equipment,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$HistoryWorkoutsTableOrderingComposer get routineId {
    final $$HistoryWorkoutsTableOrderingComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.routineId,
            referencedTable: $state.db.historyWorkouts,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder, parentComposers) =>
                $$HistoryWorkoutsTableOrderingComposer(ComposerState($state.db,
                    $state.db.historyWorkouts, joinBuilder, parentComposers)));
    return composer;
  }

  $$CustomExercisesTableOrderingComposer get customExerciseId {
    final $$CustomExercisesTableOrderingComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.customExerciseId,
            referencedTable: $state.db.customExercises,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder, parentComposers) =>
                $$CustomExercisesTableOrderingComposer(ComposerState($state.db,
                    $state.db.customExercises, joinBuilder, parentComposers)));
    return composer;
  }

  $$HistoryWorkoutExercisesTableOrderingComposer get supersetId {
    final $$HistoryWorkoutExercisesTableOrderingComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.supersetId,
            referencedTable: $state.db.historyWorkoutExercises,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder, parentComposers) =>
                $$HistoryWorkoutExercisesTableOrderingComposer(ComposerState(
                    $state.db,
                    $state.db.historyWorkoutExercises,
                    joinBuilder,
                    parentComposers)));
    return composer;
  }

  $$HistoryWorkoutExercisesTableOrderingComposer get supersedesId {
    final $$HistoryWorkoutExercisesTableOrderingComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.supersedesId,
            referencedTable: $state.db.historyWorkoutExercises,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder, parentComposers) =>
                $$HistoryWorkoutExercisesTableOrderingComposer(ComposerState(
                    $state.db,
                    $state.db.historyWorkoutExercises,
                    joinBuilder,
                    parentComposers)));
    return composer;
  }
}

typedef $$RoutineExercisesTableCreateCompanionBuilder
    = RoutineExercisesCompanion Function({
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
  Value<GTGymEquipment?> equipment,
  Value<int> rowid,
});
typedef $$RoutineExercisesTableUpdateCompanionBuilder
    = RoutineExercisesCompanion Function({
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
  Value<GTGymEquipment?> equipment,
  Value<int> rowid,
});

class $$RoutineExercisesTableTableManager extends RootTableManager<
    _$GTDatabaseImpl,
    $RoutineExercisesTable,
    ConcreteExercise,
    $$RoutineExercisesTableFilterComposer,
    $$RoutineExercisesTableOrderingComposer,
    $$RoutineExercisesTableCreateCompanionBuilder,
    $$RoutineExercisesTableUpdateCompanionBuilder> {
  $$RoutineExercisesTableTableManager(
      _$GTDatabaseImpl db, $RoutineExercisesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$RoutineExercisesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$RoutineExercisesTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
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
            Value<GTGymEquipment?> equipment = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RoutineExercisesCompanion(
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
            equipment: equipment,
            rowid: rowid,
          ),
          createCompanionCallback: ({
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
            Value<GTGymEquipment?> equipment = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RoutineExercisesCompanion.insert(
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
            equipment: equipment,
            rowid: rowid,
          ),
        ));
}

class $$RoutineExercisesTableFilterComposer
    extends FilterComposer<_$GTDatabaseImpl, $RoutineExercisesTable> {
  $$RoutineExercisesTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnWithTypeConverterFilters<GTSetParameters?, GTSetParameters, String>
      get parameters => $state.composableBuilder(
          column: $state.table.parameters,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));

  ColumnWithTypeConverterFilters<List<GTSet>?, List<GTSet>, String> get sets =>
      $state.composableBuilder(
          column: $state.table.sets,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));

  ColumnWithTypeConverterFilters<GTMuscleGroup?, GTMuscleGroup, String>
      get primaryMuscleGroup => $state.composableBuilder(
          column: $state.table.primaryMuscleGroup,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));

  ColumnWithTypeConverterFilters<Set<GTMuscleGroup>?, Set<GTMuscleGroup>,
          String>
      get secondaryMuscleGroups => $state.composableBuilder(
          column: $state.table.secondaryMuscleGroups,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));

  ColumnFilters<int> get restTime => $state.composableBuilder(
      column: $state.table.restTime,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isCustom => $state.composableBuilder(
      column: $state.table.isCustom,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get libraryExerciseId => $state.composableBuilder(
      column: $state.table.libraryExerciseId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get notes => $state.composableBuilder(
      column: $state.table.notes,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isSuperset => $state.composableBuilder(
      column: $state.table.isSuperset,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isInSuperset => $state.composableBuilder(
      column: $state.table.isInSuperset,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get sortOrder => $state.composableBuilder(
      column: $state.table.sortOrder,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get rpe => $state.composableBuilder(
      column: $state.table.rpe,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnWithTypeConverterFilters<GTGymEquipment?, GTGymEquipment, String>
      get equipment => $state.composableBuilder(
          column: $state.table.equipment,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));

  $$RoutinesTableFilterComposer get routineId {
    final $$RoutinesTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.routineId,
        referencedTable: $state.db.routines,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$RoutinesTableFilterComposer(ComposerState(
                $state.db, $state.db.routines, joinBuilder, parentComposers)));
    return composer;
  }

  $$CustomExercisesTableFilterComposer get customExerciseId {
    final $$CustomExercisesTableFilterComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.customExerciseId,
            referencedTable: $state.db.customExercises,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder, parentComposers) =>
                $$CustomExercisesTableFilterComposer(ComposerState($state.db,
                    $state.db.customExercises, joinBuilder, parentComposers)));
    return composer;
  }

  $$RoutineExercisesTableFilterComposer get supersetId {
    final $$RoutineExercisesTableFilterComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.supersetId,
            referencedTable: $state.db.routineExercises,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder, parentComposers) =>
                $$RoutineExercisesTableFilterComposer(ComposerState($state.db,
                    $state.db.routineExercises, joinBuilder, parentComposers)));
    return composer;
  }

  $$RoutineExercisesTableFilterComposer get supersedesId {
    final $$RoutineExercisesTableFilterComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.supersedesId,
            referencedTable: $state.db.routineExercises,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder, parentComposers) =>
                $$RoutineExercisesTableFilterComposer(ComposerState($state.db,
                    $state.db.routineExercises, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$RoutineExercisesTableOrderingComposer
    extends OrderingComposer<_$GTDatabaseImpl, $RoutineExercisesTable> {
  $$RoutineExercisesTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get parameters => $state.composableBuilder(
      column: $state.table.parameters,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get sets => $state.composableBuilder(
      column: $state.table.sets,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get primaryMuscleGroup => $state.composableBuilder(
      column: $state.table.primaryMuscleGroup,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get secondaryMuscleGroups => $state.composableBuilder(
      column: $state.table.secondaryMuscleGroups,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get restTime => $state.composableBuilder(
      column: $state.table.restTime,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isCustom => $state.composableBuilder(
      column: $state.table.isCustom,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get libraryExerciseId => $state.composableBuilder(
      column: $state.table.libraryExerciseId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get notes => $state.composableBuilder(
      column: $state.table.notes,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isSuperset => $state.composableBuilder(
      column: $state.table.isSuperset,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isInSuperset => $state.composableBuilder(
      column: $state.table.isInSuperset,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get sortOrder => $state.composableBuilder(
      column: $state.table.sortOrder,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get rpe => $state.composableBuilder(
      column: $state.table.rpe,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get equipment => $state.composableBuilder(
      column: $state.table.equipment,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$RoutinesTableOrderingComposer get routineId {
    final $$RoutinesTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.routineId,
        referencedTable: $state.db.routines,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$RoutinesTableOrderingComposer(ComposerState(
                $state.db, $state.db.routines, joinBuilder, parentComposers)));
    return composer;
  }

  $$CustomExercisesTableOrderingComposer get customExerciseId {
    final $$CustomExercisesTableOrderingComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.customExerciseId,
            referencedTable: $state.db.customExercises,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder, parentComposers) =>
                $$CustomExercisesTableOrderingComposer(ComposerState($state.db,
                    $state.db.customExercises, joinBuilder, parentComposers)));
    return composer;
  }

  $$RoutineExercisesTableOrderingComposer get supersetId {
    final $$RoutineExercisesTableOrderingComposer composer = $state
        .composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.supersetId,
            referencedTable: $state.db.routineExercises,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder, parentComposers) =>
                $$RoutineExercisesTableOrderingComposer(ComposerState($state.db,
                    $state.db.routineExercises, joinBuilder, parentComposers)));
    return composer;
  }

  $$RoutineExercisesTableOrderingComposer get supersedesId {
    final $$RoutineExercisesTableOrderingComposer composer = $state
        .composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.supersedesId,
            referencedTable: $state.db.routineExercises,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder, parentComposers) =>
                $$RoutineExercisesTableOrderingComposer(ComposerState($state.db,
                    $state.db.routineExercises, joinBuilder, parentComposers)));
    return composer;
  }
}

typedef $$PreferencesTableCreateCompanionBuilder = PreferencesCompanion
    Function({
  required String data,
  Value<bool> onboardingComplete,
  Value<int> rowid,
});
typedef $$PreferencesTableUpdateCompanionBuilder = PreferencesCompanion
    Function({
  Value<String> data,
  Value<bool> onboardingComplete,
  Value<int> rowid,
});

class $$PreferencesTableTableManager extends RootTableManager<
    _$GTDatabaseImpl,
    $PreferencesTable,
    Preference,
    $$PreferencesTableFilterComposer,
    $$PreferencesTableOrderingComposer,
    $$PreferencesTableCreateCompanionBuilder,
    $$PreferencesTableUpdateCompanionBuilder> {
  $$PreferencesTableTableManager(_$GTDatabaseImpl db, $PreferencesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$PreferencesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$PreferencesTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> data = const Value.absent(),
            Value<bool> onboardingComplete = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PreferencesCompanion(
            data: data,
            onboardingComplete: onboardingComplete,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String data,
            Value<bool> onboardingComplete = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PreferencesCompanion.insert(
            data: data,
            onboardingComplete: onboardingComplete,
            rowid: rowid,
          ),
        ));
}

class $$PreferencesTableFilterComposer
    extends FilterComposer<_$GTDatabaseImpl, $PreferencesTable> {
  $$PreferencesTableFilterComposer(super.$state);
  ColumnFilters<String> get data => $state.composableBuilder(
      column: $state.table.data,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get onboardingComplete => $state.composableBuilder(
      column: $state.table.onboardingComplete,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$PreferencesTableOrderingComposer
    extends OrderingComposer<_$GTDatabaseImpl, $PreferencesTable> {
  $$PreferencesTableOrderingComposer(super.$state);
  ColumnOrderings<String> get data => $state.composableBuilder(
      column: $state.table.data,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get onboardingComplete => $state.composableBuilder(
      column: $state.table.onboardingComplete,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$OngoingDataTableCreateCompanionBuilder = OngoingDataCompanion
    Function({
  required String data,
  Value<int> rowid,
});
typedef $$OngoingDataTableUpdateCompanionBuilder = OngoingDataCompanion
    Function({
  Value<String> data,
  Value<int> rowid,
});

class $$OngoingDataTableTableManager extends RootTableManager<
    _$GTDatabaseImpl,
    $OngoingDataTable,
    OngoingDatum,
    $$OngoingDataTableFilterComposer,
    $$OngoingDataTableOrderingComposer,
    $$OngoingDataTableCreateCompanionBuilder,
    $$OngoingDataTableUpdateCompanionBuilder> {
  $$OngoingDataTableTableManager(_$GTDatabaseImpl db, $OngoingDataTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$OngoingDataTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$OngoingDataTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> data = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OngoingDataCompanion(
            data: data,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String data,
            Value<int> rowid = const Value.absent(),
          }) =>
              OngoingDataCompanion.insert(
            data: data,
            rowid: rowid,
          ),
        ));
}

class $$OngoingDataTableFilterComposer
    extends FilterComposer<_$GTDatabaseImpl, $OngoingDataTable> {
  $$OngoingDataTableFilterComposer(super.$state);
  ColumnFilters<String> get data => $state.composableBuilder(
      column: $state.table.data,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$OngoingDataTableOrderingComposer
    extends OrderingComposer<_$GTDatabaseImpl, $OngoingDataTable> {
  $$OngoingDataTableOrderingComposer(super.$state);
  ColumnOrderings<String> get data => $state.composableBuilder(
      column: $state.table.data,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$WeightMeasurementsTableCreateCompanionBuilder
    = WeightMeasurementsCompanion Function({
  Value<String> id,
  required double weight,
  required DateTime time,
  required Weights weightUnit,
  Value<int> rowid,
});
typedef $$WeightMeasurementsTableUpdateCompanionBuilder
    = WeightMeasurementsCompanion Function({
  Value<String> id,
  Value<double> weight,
  Value<DateTime> time,
  Value<Weights> weightUnit,
  Value<int> rowid,
});

class $$WeightMeasurementsTableTableManager extends RootTableManager<
    _$GTDatabaseImpl,
    $WeightMeasurementsTable,
    WeightMeasurement,
    $$WeightMeasurementsTableFilterComposer,
    $$WeightMeasurementsTableOrderingComposer,
    $$WeightMeasurementsTableCreateCompanionBuilder,
    $$WeightMeasurementsTableUpdateCompanionBuilder> {
  $$WeightMeasurementsTableTableManager(
      _$GTDatabaseImpl db, $WeightMeasurementsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$WeightMeasurementsTableFilterComposer(ComposerState(db, table)),
          orderingComposer: $$WeightMeasurementsTableOrderingComposer(
              ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<double> weight = const Value.absent(),
            Value<DateTime> time = const Value.absent(),
            Value<Weights> weightUnit = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WeightMeasurementsCompanion(
            id: id,
            weight: weight,
            time: time,
            weightUnit: weightUnit,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<String> id = const Value.absent(),
            required double weight,
            required DateTime time,
            required Weights weightUnit,
            Value<int> rowid = const Value.absent(),
          }) =>
              WeightMeasurementsCompanion.insert(
            id: id,
            weight: weight,
            time: time,
            weightUnit: weightUnit,
            rowid: rowid,
          ),
        ));
}

class $$WeightMeasurementsTableFilterComposer
    extends FilterComposer<_$GTDatabaseImpl, $WeightMeasurementsTable> {
  $$WeightMeasurementsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get weight => $state.composableBuilder(
      column: $state.table.weight,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get time => $state.composableBuilder(
      column: $state.table.time,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnWithTypeConverterFilters<Weights, Weights, String> get weightUnit =>
      $state.composableBuilder(
          column: $state.table.weightUnit,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));
}

class $$WeightMeasurementsTableOrderingComposer
    extends OrderingComposer<_$GTDatabaseImpl, $WeightMeasurementsTable> {
  $$WeightMeasurementsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get weight => $state.composableBuilder(
      column: $state.table.weight,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get time => $state.composableBuilder(
      column: $state.table.time,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get weightUnit => $state.composableBuilder(
      column: $state.table.weightUnit,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$BodyMeasurementsTableCreateCompanionBuilder
    = BodyMeasurementsCompanion Function({
  Value<String> id,
  required double value,
  required DateTime time,
  required BodyMeasurementPart type,
  Value<int> rowid,
});
typedef $$BodyMeasurementsTableUpdateCompanionBuilder
    = BodyMeasurementsCompanion Function({
  Value<String> id,
  Value<double> value,
  Value<DateTime> time,
  Value<BodyMeasurementPart> type,
  Value<int> rowid,
});

class $$BodyMeasurementsTableTableManager extends RootTableManager<
    _$GTDatabaseImpl,
    $BodyMeasurementsTable,
    BodyMeasurement,
    $$BodyMeasurementsTableFilterComposer,
    $$BodyMeasurementsTableOrderingComposer,
    $$BodyMeasurementsTableCreateCompanionBuilder,
    $$BodyMeasurementsTableUpdateCompanionBuilder> {
  $$BodyMeasurementsTableTableManager(
      _$GTDatabaseImpl db, $BodyMeasurementsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$BodyMeasurementsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$BodyMeasurementsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<double> value = const Value.absent(),
            Value<DateTime> time = const Value.absent(),
            Value<BodyMeasurementPart> type = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BodyMeasurementsCompanion(
            id: id,
            value: value,
            time: time,
            type: type,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<String> id = const Value.absent(),
            required double value,
            required DateTime time,
            required BodyMeasurementPart type,
            Value<int> rowid = const Value.absent(),
          }) =>
              BodyMeasurementsCompanion.insert(
            id: id,
            value: value,
            time: time,
            type: type,
            rowid: rowid,
          ),
        ));
}

class $$BodyMeasurementsTableFilterComposer
    extends FilterComposer<_$GTDatabaseImpl, $BodyMeasurementsTable> {
  $$BodyMeasurementsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get value => $state.composableBuilder(
      column: $state.table.value,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get time => $state.composableBuilder(
      column: $state.table.time,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnWithTypeConverterFilters<BodyMeasurementPart, BodyMeasurementPart,
          String>
      get type => $state.composableBuilder(
          column: $state.table.type,
          builder: (column, joinBuilders) => ColumnWithTypeConverterFilters(
              column,
              joinBuilders: joinBuilders));
}

class $$BodyMeasurementsTableOrderingComposer
    extends OrderingComposer<_$GTDatabaseImpl, $BodyMeasurementsTable> {
  $$BodyMeasurementsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get value => $state.composableBuilder(
      column: $state.table.value,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get time => $state.composableBuilder(
      column: $state.table.time,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get type => $state.composableBuilder(
      column: $state.table.type,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$FoodsTableCreateCompanionBuilder = FoodsCompanion Function({
  Value<String> id,
  required DateTime dateAdded,
  required DateTime referenceDate,
  required String jsonData,
  Value<int> rowid,
});
typedef $$FoodsTableUpdateCompanionBuilder = FoodsCompanion Function({
  Value<String> id,
  Value<DateTime> dateAdded,
  Value<DateTime> referenceDate,
  Value<String> jsonData,
  Value<int> rowid,
});

class $$FoodsTableTableManager extends RootTableManager<
    _$GTDatabaseImpl,
    $FoodsTable,
    DBFood,
    $$FoodsTableFilterComposer,
    $$FoodsTableOrderingComposer,
    $$FoodsTableCreateCompanionBuilder,
    $$FoodsTableUpdateCompanionBuilder> {
  $$FoodsTableTableManager(_$GTDatabaseImpl db, $FoodsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$FoodsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$FoodsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> dateAdded = const Value.absent(),
            Value<DateTime> referenceDate = const Value.absent(),
            Value<String> jsonData = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FoodsCompanion(
            id: id,
            dateAdded: dateAdded,
            referenceDate: referenceDate,
            jsonData: jsonData,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<String> id = const Value.absent(),
            required DateTime dateAdded,
            required DateTime referenceDate,
            required String jsonData,
            Value<int> rowid = const Value.absent(),
          }) =>
              FoodsCompanion.insert(
            id: id,
            dateAdded: dateAdded,
            referenceDate: referenceDate,
            jsonData: jsonData,
            rowid: rowid,
          ),
        ));
}

class $$FoodsTableFilterComposer
    extends FilterComposer<_$GTDatabaseImpl, $FoodsTable> {
  $$FoodsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get dateAdded => $state.composableBuilder(
      column: $state.table.dateAdded,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get referenceDate => $state.composableBuilder(
      column: $state.table.referenceDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get jsonData => $state.composableBuilder(
      column: $state.table.jsonData,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ComposableFilter favoriteFoodsRefs(
      ComposableFilter Function($$FavoriteFoodsTableFilterComposer f) f) {
    final $$FavoriteFoodsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.favoriteFoods,
        getReferencedColumn: (t) => t.foodId,
        builder: (joinBuilder, parentComposers) =>
            $$FavoriteFoodsTableFilterComposer(ComposerState($state.db,
                $state.db.favoriteFoods, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$FoodsTableOrderingComposer
    extends OrderingComposer<_$GTDatabaseImpl, $FoodsTable> {
  $$FoodsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get dateAdded => $state.composableBuilder(
      column: $state.table.dateAdded,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get referenceDate => $state.composableBuilder(
      column: $state.table.referenceDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get jsonData => $state.composableBuilder(
      column: $state.table.jsonData,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$NutritionGoalsTableCreateCompanionBuilder = NutritionGoalsCompanion
    Function({
  Value<String> id,
  required DateTime referenceDate,
  required double calories,
  required double fat,
  required double carbs,
  required double protein,
  Value<int> rowid,
});
typedef $$NutritionGoalsTableUpdateCompanionBuilder = NutritionGoalsCompanion
    Function({
  Value<String> id,
  Value<DateTime> referenceDate,
  Value<double> calories,
  Value<double> fat,
  Value<double> carbs,
  Value<double> protein,
  Value<int> rowid,
});

class $$NutritionGoalsTableTableManager extends RootTableManager<
    _$GTDatabaseImpl,
    $NutritionGoalsTable,
    DBNutritionGoal,
    $$NutritionGoalsTableFilterComposer,
    $$NutritionGoalsTableOrderingComposer,
    $$NutritionGoalsTableCreateCompanionBuilder,
    $$NutritionGoalsTableUpdateCompanionBuilder> {
  $$NutritionGoalsTableTableManager(
      _$GTDatabaseImpl db, $NutritionGoalsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$NutritionGoalsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$NutritionGoalsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> referenceDate = const Value.absent(),
            Value<double> calories = const Value.absent(),
            Value<double> fat = const Value.absent(),
            Value<double> carbs = const Value.absent(),
            Value<double> protein = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              NutritionGoalsCompanion(
            id: id,
            referenceDate: referenceDate,
            calories: calories,
            fat: fat,
            carbs: carbs,
            protein: protein,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<String> id = const Value.absent(),
            required DateTime referenceDate,
            required double calories,
            required double fat,
            required double carbs,
            required double protein,
            Value<int> rowid = const Value.absent(),
          }) =>
              NutritionGoalsCompanion.insert(
            id: id,
            referenceDate: referenceDate,
            calories: calories,
            fat: fat,
            carbs: carbs,
            protein: protein,
            rowid: rowid,
          ),
        ));
}

class $$NutritionGoalsTableFilterComposer
    extends FilterComposer<_$GTDatabaseImpl, $NutritionGoalsTable> {
  $$NutritionGoalsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get referenceDate => $state.composableBuilder(
      column: $state.table.referenceDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get calories => $state.composableBuilder(
      column: $state.table.calories,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get fat => $state.composableBuilder(
      column: $state.table.fat,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get carbs => $state.composableBuilder(
      column: $state.table.carbs,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get protein => $state.composableBuilder(
      column: $state.table.protein,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$NutritionGoalsTableOrderingComposer
    extends OrderingComposer<_$GTDatabaseImpl, $NutritionGoalsTable> {
  $$NutritionGoalsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get referenceDate => $state.composableBuilder(
      column: $state.table.referenceDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get calories => $state.composableBuilder(
      column: $state.table.calories,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get fat => $state.composableBuilder(
      column: $state.table.fat,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get carbs => $state.composableBuilder(
      column: $state.table.carbs,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get protein => $state.composableBuilder(
      column: $state.table.protein,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$CustomBarcodeFoodsTableCreateCompanionBuilder
    = CustomBarcodeFoodsCompanion Function({
  required String barcode,
  required String jsonData,
  Value<int> rowid,
});
typedef $$CustomBarcodeFoodsTableUpdateCompanionBuilder
    = CustomBarcodeFoodsCompanion Function({
  Value<String> barcode,
  Value<String> jsonData,
  Value<int> rowid,
});

class $$CustomBarcodeFoodsTableTableManager extends RootTableManager<
    _$GTDatabaseImpl,
    $CustomBarcodeFoodsTable,
    CustomBarcodeFood,
    $$CustomBarcodeFoodsTableFilterComposer,
    $$CustomBarcodeFoodsTableOrderingComposer,
    $$CustomBarcodeFoodsTableCreateCompanionBuilder,
    $$CustomBarcodeFoodsTableUpdateCompanionBuilder> {
  $$CustomBarcodeFoodsTableTableManager(
      _$GTDatabaseImpl db, $CustomBarcodeFoodsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$CustomBarcodeFoodsTableFilterComposer(ComposerState(db, table)),
          orderingComposer: $$CustomBarcodeFoodsTableOrderingComposer(
              ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> barcode = const Value.absent(),
            Value<String> jsonData = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CustomBarcodeFoodsCompanion(
            barcode: barcode,
            jsonData: jsonData,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String barcode,
            required String jsonData,
            Value<int> rowid = const Value.absent(),
          }) =>
              CustomBarcodeFoodsCompanion.insert(
            barcode: barcode,
            jsonData: jsonData,
            rowid: rowid,
          ),
        ));
}

class $$CustomBarcodeFoodsTableFilterComposer
    extends FilterComposer<_$GTDatabaseImpl, $CustomBarcodeFoodsTable> {
  $$CustomBarcodeFoodsTableFilterComposer(super.$state);
  ColumnFilters<String> get barcode => $state.composableBuilder(
      column: $state.table.barcode,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get jsonData => $state.composableBuilder(
      column: $state.table.jsonData,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$CustomBarcodeFoodsTableOrderingComposer
    extends OrderingComposer<_$GTDatabaseImpl, $CustomBarcodeFoodsTable> {
  $$CustomBarcodeFoodsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get barcode => $state.composableBuilder(
      column: $state.table.barcode,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get jsonData => $state.composableBuilder(
      column: $state.table.jsonData,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$FavoriteFoodsTableCreateCompanionBuilder = FavoriteFoodsCompanion
    Function({
  required String foodId,
  Value<int> rowid,
});
typedef $$FavoriteFoodsTableUpdateCompanionBuilder = FavoriteFoodsCompanion
    Function({
  Value<String> foodId,
  Value<int> rowid,
});

class $$FavoriteFoodsTableTableManager extends RootTableManager<
    _$GTDatabaseImpl,
    $FavoriteFoodsTable,
    FavoriteFood,
    $$FavoriteFoodsTableFilterComposer,
    $$FavoriteFoodsTableOrderingComposer,
    $$FavoriteFoodsTableCreateCompanionBuilder,
    $$FavoriteFoodsTableUpdateCompanionBuilder> {
  $$FavoriteFoodsTableTableManager(
      _$GTDatabaseImpl db, $FavoriteFoodsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$FavoriteFoodsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$FavoriteFoodsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> foodId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FavoriteFoodsCompanion(
            foodId: foodId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String foodId,
            Value<int> rowid = const Value.absent(),
          }) =>
              FavoriteFoodsCompanion.insert(
            foodId: foodId,
            rowid: rowid,
          ),
        ));
}

class $$FavoriteFoodsTableFilterComposer
    extends FilterComposer<_$GTDatabaseImpl, $FavoriteFoodsTable> {
  $$FavoriteFoodsTableFilterComposer(super.$state);
  $$FoodsTableFilterComposer get foodId {
    final $$FoodsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.foodId,
        referencedTable: $state.db.foods,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) => $$FoodsTableFilterComposer(
            ComposerState(
                $state.db, $state.db.foods, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$FavoriteFoodsTableOrderingComposer
    extends OrderingComposer<_$GTDatabaseImpl, $FavoriteFoodsTable> {
  $$FavoriteFoodsTableOrderingComposer(super.$state);
  $$FoodsTableOrderingComposer get foodId {
    final $$FoodsTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.foodId,
        referencedTable: $state.db.foods,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) => $$FoodsTableOrderingComposer(
            ComposerState(
                $state.db, $state.db.foods, joinBuilder, parentComposers)));
    return composer;
  }
}

typedef $$NutritionCategoriesTableCreateCompanionBuilder
    = NutritionCategoriesCompanion Function({
  required DateTime referenceDate,
  required String jsonData,
  Value<int> rowid,
});
typedef $$NutritionCategoriesTableUpdateCompanionBuilder
    = NutritionCategoriesCompanion Function({
  Value<DateTime> referenceDate,
  Value<String> jsonData,
  Value<int> rowid,
});

class $$NutritionCategoriesTableTableManager extends RootTableManager<
    _$GTDatabaseImpl,
    $NutritionCategoriesTable,
    DBNutritionCategory,
    $$NutritionCategoriesTableFilterComposer,
    $$NutritionCategoriesTableOrderingComposer,
    $$NutritionCategoriesTableCreateCompanionBuilder,
    $$NutritionCategoriesTableUpdateCompanionBuilder> {
  $$NutritionCategoriesTableTableManager(
      _$GTDatabaseImpl db, $NutritionCategoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$NutritionCategoriesTableFilterComposer(
              ComposerState(db, table)),
          orderingComposer: $$NutritionCategoriesTableOrderingComposer(
              ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<DateTime> referenceDate = const Value.absent(),
            Value<String> jsonData = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              NutritionCategoriesCompanion(
            referenceDate: referenceDate,
            jsonData: jsonData,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required DateTime referenceDate,
            required String jsonData,
            Value<int> rowid = const Value.absent(),
          }) =>
              NutritionCategoriesCompanion.insert(
            referenceDate: referenceDate,
            jsonData: jsonData,
            rowid: rowid,
          ),
        ));
}

class $$NutritionCategoriesTableFilterComposer
    extends FilterComposer<_$GTDatabaseImpl, $NutritionCategoriesTable> {
  $$NutritionCategoriesTableFilterComposer(super.$state);
  ColumnFilters<DateTime> get referenceDate => $state.composableBuilder(
      column: $state.table.referenceDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get jsonData => $state.composableBuilder(
      column: $state.table.jsonData,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$NutritionCategoriesTableOrderingComposer
    extends OrderingComposer<_$GTDatabaseImpl, $NutritionCategoriesTable> {
  $$NutritionCategoriesTableOrderingComposer(super.$state);
  ColumnOrderings<DateTime> get referenceDate => $state.composableBuilder(
      column: $state.table.referenceDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get jsonData => $state.composableBuilder(
      column: $state.table.jsonData,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$AchievementsTableCreateCompanionBuilder = AchievementsCompanion
    Function({
  required String achievementID,
  required int level,
  required DateTime completedAt,
  Value<int> rowid,
});
typedef $$AchievementsTableUpdateCompanionBuilder = AchievementsCompanion
    Function({
  Value<String> achievementID,
  Value<int> level,
  Value<DateTime> completedAt,
  Value<int> rowid,
});

class $$AchievementsTableTableManager extends RootTableManager<
    _$GTDatabaseImpl,
    $AchievementsTable,
    AchievementCompletion,
    $$AchievementsTableFilterComposer,
    $$AchievementsTableOrderingComposer,
    $$AchievementsTableCreateCompanionBuilder,
    $$AchievementsTableUpdateCompanionBuilder> {
  $$AchievementsTableTableManager(_$GTDatabaseImpl db, $AchievementsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$AchievementsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$AchievementsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> achievementID = const Value.absent(),
            Value<int> level = const Value.absent(),
            Value<DateTime> completedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AchievementsCompanion(
            achievementID: achievementID,
            level: level,
            completedAt: completedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String achievementID,
            required int level,
            required DateTime completedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              AchievementsCompanion.insert(
            achievementID: achievementID,
            level: level,
            completedAt: completedAt,
            rowid: rowid,
          ),
        ));
}

class $$AchievementsTableFilterComposer
    extends FilterComposer<_$GTDatabaseImpl, $AchievementsTable> {
  $$AchievementsTableFilterComposer(super.$state);
  ColumnFilters<String> get achievementID => $state.composableBuilder(
      column: $state.table.achievementID,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get level => $state.composableBuilder(
      column: $state.table.level,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get completedAt => $state.composableBuilder(
      column: $state.table.completedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$AchievementsTableOrderingComposer
    extends OrderingComposer<_$GTDatabaseImpl, $AchievementsTable> {
  $$AchievementsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get achievementID => $state.composableBuilder(
      column: $state.table.achievementID,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get level => $state.composableBuilder(
      column: $state.table.level,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get completedAt => $state.composableBuilder(
      column: $state.table.completedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

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
          _db, _db.historyWorkoutExercises);
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
}
