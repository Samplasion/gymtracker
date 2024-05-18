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
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, parameters, primaryMuscleGroup, secondaryMuscleGroups];
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
}

class CustomExercise extends DataClass implements Insertable<CustomExercise> {
  final String id;
  final String name;
  final GTSetParameters parameters;
  final GTMuscleGroup primaryMuscleGroup;
  final Set<GTMuscleGroup> secondaryMuscleGroups;
  const CustomExercise(
      {required this.id,
      required this.name,
      required this.parameters,
      required this.primaryMuscleGroup,
      required this.secondaryMuscleGroups});
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
    return map;
  }

  CustomExercisesCompanion toCompanion(bool nullToAbsent) {
    return CustomExercisesCompanion(
      id: Value(id),
      name: Value(name),
      parameters: Value(parameters),
      primaryMuscleGroup: Value(primaryMuscleGroup),
      secondaryMuscleGroups: Value(secondaryMuscleGroups),
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
    };
  }

  CustomExercise copyWith(
          {String? id,
          String? name,
          GTSetParameters? parameters,
          GTMuscleGroup? primaryMuscleGroup,
          Set<GTMuscleGroup>? secondaryMuscleGroups}) =>
      CustomExercise(
        id: id ?? this.id,
        name: name ?? this.name,
        parameters: parameters ?? this.parameters,
        primaryMuscleGroup: primaryMuscleGroup ?? this.primaryMuscleGroup,
        secondaryMuscleGroups:
            secondaryMuscleGroups ?? this.secondaryMuscleGroups,
      );
  @override
  String toString() {
    return (StringBuffer('CustomExercise(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('parameters: $parameters, ')
          ..write('primaryMuscleGroup: $primaryMuscleGroup, ')
          ..write('secondaryMuscleGroups: $secondaryMuscleGroups')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, name, parameters, primaryMuscleGroup, secondaryMuscleGroups);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomExercise &&
          other.id == this.id &&
          other.name == this.name &&
          other.parameters == this.parameters &&
          other.primaryMuscleGroup == this.primaryMuscleGroup &&
          other.secondaryMuscleGroups == this.secondaryMuscleGroups);
}

class CustomExercisesCompanion extends UpdateCompanion<CustomExercise> {
  final Value<String> id;
  final Value<String> name;
  final Value<GTSetParameters> parameters;
  final Value<GTMuscleGroup> primaryMuscleGroup;
  final Value<Set<GTMuscleGroup>> secondaryMuscleGroups;
  final Value<int> rowid;
  const CustomExercisesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.parameters = const Value.absent(),
    this.primaryMuscleGroup = const Value.absent(),
    this.secondaryMuscleGroups = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomExercisesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required GTSetParameters parameters,
    required GTMuscleGroup primaryMuscleGroup,
    required Set<GTMuscleGroup> secondaryMuscleGroups,
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
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomExercisesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<GTSetParameters>? parameters,
      Value<GTMuscleGroup>? primaryMuscleGroup,
      Value<Set<GTMuscleGroup>>? secondaryMuscleGroups,
      Value<int>? rowid}) {
    return CustomExercisesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      parameters: parameters ?? this.parameters,
      primaryMuscleGroup: primaryMuscleGroup ?? this.primaryMuscleGroup,
      secondaryMuscleGroups:
          secondaryMuscleGroups ?? this.secondaryMuscleGroups,
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
        supersedesId
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
        supersedesId
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
  @override
  List<GeneratedColumn> get $columns => [data];
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
    );
  }

  @override
  $PreferencesTable createAlias(String alias) {
    return $PreferencesTable(attachedDatabase, alias);
  }
}

class Preference extends DataClass implements Insertable<Preference> {
  final String data;
  const Preference({required this.data});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['data'] = Variable<String>(data);
    return map;
  }

  PreferencesCompanion toCompanion(bool nullToAbsent) {
    return PreferencesCompanion(
      data: Value(data),
    );
  }

  factory Preference.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Preference(
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

  Preference copyWith({String? data}) => Preference(
        data: data ?? this.data,
      );
  @override
  String toString() {
    return (StringBuffer('Preference(')
          ..write('data: $data')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => data.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Preference && other.data == this.data);
}

class PreferencesCompanion extends UpdateCompanion<Preference> {
  final Value<String> data;
  final Value<int> rowid;
  const PreferencesCompanion({
    this.data = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PreferencesCompanion.insert({
    required String data,
    this.rowid = const Value.absent(),
  }) : data = Value(data);
  static Insertable<Preference> custom({
    Expression<String>? data,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (data != null) 'data': data,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PreferencesCompanion copyWith({Value<String>? data, Value<int>? rowid}) {
    return PreferencesCompanion(
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
    return (StringBuffer('PreferencesCompanion(')
          ..write('data: $data, ')
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

abstract class _$GTDatabase extends GeneratedDatabase {
  _$GTDatabase(QueryExecutor e) : super(e);
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
        weightMeasurements
      ];
}
