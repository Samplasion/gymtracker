// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GTLibraryExerciseCWProxy {
  GTLibraryExercise id(int id);

  GTLibraryExercise name(String name);

  GTLibraryExercise parameters(GTSetParameters parameters);

  GTLibraryExercise primaryMuscleGroup(GTMuscleGroup primaryMuscleGroup);

  GTLibraryExercise secondaryMuscleGroups(
      Set<GTMuscleGroup> secondaryMuscleGroups);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GTLibraryExercise(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GTLibraryExercise(...).copyWith(id: 12, name: "My name")
  /// ````
  GTLibraryExercise call({
    int? id,
    String? name,
    GTSetParameters? parameters,
    GTMuscleGroup? primaryMuscleGroup,
    Set<GTMuscleGroup>? secondaryMuscleGroups,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGTLibraryExercise.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGTLibraryExercise.copyWith.fieldName(...)`
class _$GTLibraryExerciseCWProxyImpl implements _$GTLibraryExerciseCWProxy {
  const _$GTLibraryExerciseCWProxyImpl(this._value);

  final GTLibraryExercise _value;

  @override
  GTLibraryExercise id(int id) => this(id: id);

  @override
  GTLibraryExercise name(String name) => this(name: name);

  @override
  GTLibraryExercise parameters(GTSetParameters parameters) =>
      this(parameters: parameters);

  @override
  GTLibraryExercise primaryMuscleGroup(GTMuscleGroup primaryMuscleGroup) =>
      this(primaryMuscleGroup: primaryMuscleGroup);

  @override
  GTLibraryExercise secondaryMuscleGroups(
          Set<GTMuscleGroup> secondaryMuscleGroups) =>
      this(secondaryMuscleGroups: secondaryMuscleGroups);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GTLibraryExercise(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GTLibraryExercise(...).copyWith(id: 12, name: "My name")
  /// ````
  GTLibraryExercise call({
    Object? id = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? parameters = const $CopyWithPlaceholder(),
    Object? primaryMuscleGroup = const $CopyWithPlaceholder(),
    Object? secondaryMuscleGroups = const $CopyWithPlaceholder(),
  }) {
    return GTLibraryExercise(
      id: id == const $CopyWithPlaceholder() || id == null
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      name: name == const $CopyWithPlaceholder() || name == null
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      parameters:
          parameters == const $CopyWithPlaceholder() || parameters == null
              ? _value.parameters
              // ignore: cast_nullable_to_non_nullable
              : parameters as GTSetParameters,
      primaryMuscleGroup: primaryMuscleGroup == const $CopyWithPlaceholder() ||
              primaryMuscleGroup == null
          ? _value.primaryMuscleGroup
          // ignore: cast_nullable_to_non_nullable
          : primaryMuscleGroup as GTMuscleGroup,
      secondaryMuscleGroups:
          secondaryMuscleGroups == const $CopyWithPlaceholder() ||
                  secondaryMuscleGroups == null
              ? _value.secondaryMuscleGroups
              // ignore: cast_nullable_to_non_nullable
              : secondaryMuscleGroups as Set<GTMuscleGroup>,
    );
  }
}

extension $GTLibraryExerciseCopyWith on GTLibraryExercise {
  /// Returns a callable class that can be used as follows: `instanceOfGTLibraryExercise.copyWith(...)` or like so:`instanceOfGTLibraryExercise.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GTLibraryExerciseCWProxy get copyWith =>
      _$GTLibraryExerciseCWProxyImpl(this);
}

abstract class _$GTSupersetCWProxy {
  GTSuperset id(int id);

  GTSuperset parentID(int parentID);

  GTSuperset name(String name);

  GTSuperset restTime(Duration restTime);

  GTSuperset notes(String notes);

  GTSuperset sortOrder(int sortOrder);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GTSuperset(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GTSuperset(...).copyWith(id: 12, name: "My name")
  /// ````
  GTSuperset call({
    int? id,
    int? parentID,
    String? name,
    Duration? restTime,
    String? notes,
    int? sortOrder,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGTSuperset.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGTSuperset.copyWith.fieldName(...)`
class _$GTSupersetCWProxyImpl implements _$GTSupersetCWProxy {
  const _$GTSupersetCWProxyImpl(this._value);

  final GTSuperset _value;

  @override
  GTSuperset id(int id) => this(id: id);

  @override
  GTSuperset parentID(int parentID) => this(parentID: parentID);

  @override
  GTSuperset name(String name) => this(name: name);

  @override
  GTSuperset restTime(Duration restTime) => this(restTime: restTime);

  @override
  GTSuperset notes(String notes) => this(notes: notes);

  @override
  GTSuperset sortOrder(int sortOrder) => this(sortOrder: sortOrder);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GTSuperset(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GTSuperset(...).copyWith(id: 12, name: "My name")
  /// ````
  GTSuperset call({
    Object? id = const $CopyWithPlaceholder(),
    Object? parentID = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? restTime = const $CopyWithPlaceholder(),
    Object? notes = const $CopyWithPlaceholder(),
    Object? sortOrder = const $CopyWithPlaceholder(),
  }) {
    return GTSuperset(
      id: id == const $CopyWithPlaceholder() || id == null
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      parentID: parentID == const $CopyWithPlaceholder() || parentID == null
          ? _value.parentID
          // ignore: cast_nullable_to_non_nullable
          : parentID as int,
      name: name == const $CopyWithPlaceholder() || name == null
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      restTime: restTime == const $CopyWithPlaceholder() || restTime == null
          ? _value.restTime
          // ignore: cast_nullable_to_non_nullable
          : restTime as Duration,
      notes: notes == const $CopyWithPlaceholder() || notes == null
          ? _value.notes
          // ignore: cast_nullable_to_non_nullable
          : notes as String,
      sortOrder: sortOrder == const $CopyWithPlaceholder() || sortOrder == null
          ? _value.sortOrder
          // ignore: cast_nullable_to_non_nullable
          : sortOrder as int,
    );
  }
}

extension $GTSupersetCopyWith on GTSuperset {
  /// Returns a callable class that can be used as follows: `instanceOfGTSuperset.copyWith(...)` or like so:`instanceOfGTSuperset.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GTSupersetCWProxy get copyWith => _$GTSupersetCWProxyImpl(this);
}

abstract class _$GTExerciseCWProxy {
  GTExercise id(int id);

  GTExercise parentID(int parentID);

  GTExercise name(String name);

  GTExercise parameters(GTSetParameters parameters);

  GTExercise sets(List<GTSet> sets);

  GTExercise primaryMuscleGroup(GTMuscleGroup primaryMuscleGroup);

  GTExercise secondaryMuscleGroups(Set<GTMuscleGroup> secondaryMuscleGroups);

  GTExercise restTime(Duration? restTime);

  GTExercise libraryExerciseID(String? libraryExerciseID);

  GTExercise customExerciseID(int? customExerciseID);

  GTExercise isCustom(bool isCustom);

  GTExercise notes(String notes);

  GTExercise inSuperset(bool inSuperset);

  GTExercise supersetID(int? supersetID);

  GTExercise sortOrder(int sortOrder);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GTExercise(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GTExercise(...).copyWith(id: 12, name: "My name")
  /// ````
  GTExercise call({
    int? id,
    int? parentID,
    String? name,
    GTSetParameters? parameters,
    List<GTSet>? sets,
    GTMuscleGroup? primaryMuscleGroup,
    Set<GTMuscleGroup>? secondaryMuscleGroups,
    Duration? restTime,
    String? libraryExerciseID,
    int? customExerciseID,
    bool? isCustom,
    String? notes,
    bool? inSuperset,
    int? supersetID,
    int? sortOrder,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGTExercise.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGTExercise.copyWith.fieldName(...)`
class _$GTExerciseCWProxyImpl implements _$GTExerciseCWProxy {
  const _$GTExerciseCWProxyImpl(this._value);

  final GTExercise _value;

  @override
  GTExercise id(int id) => this(id: id);

  @override
  GTExercise parentID(int parentID) => this(parentID: parentID);

  @override
  GTExercise name(String name) => this(name: name);

  @override
  GTExercise parameters(GTSetParameters parameters) =>
      this(parameters: parameters);

  @override
  GTExercise sets(List<GTSet> sets) => this(sets: sets);

  @override
  GTExercise primaryMuscleGroup(GTMuscleGroup primaryMuscleGroup) =>
      this(primaryMuscleGroup: primaryMuscleGroup);

  @override
  GTExercise secondaryMuscleGroups(Set<GTMuscleGroup> secondaryMuscleGroups) =>
      this(secondaryMuscleGroups: secondaryMuscleGroups);

  @override
  GTExercise restTime(Duration? restTime) => this(restTime: restTime);

  @override
  GTExercise libraryExerciseID(String? libraryExerciseID) =>
      this(libraryExerciseID: libraryExerciseID);

  @override
  GTExercise customExerciseID(int? customExerciseID) =>
      this(customExerciseID: customExerciseID);

  @override
  GTExercise isCustom(bool isCustom) => this(isCustom: isCustom);

  @override
  GTExercise notes(String notes) => this(notes: notes);

  @override
  GTExercise inSuperset(bool inSuperset) => this(inSuperset: inSuperset);

  @override
  GTExercise supersetID(int? supersetID) => this(supersetID: supersetID);

  @override
  GTExercise sortOrder(int sortOrder) => this(sortOrder: sortOrder);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GTExercise(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GTExercise(...).copyWith(id: 12, name: "My name")
  /// ````
  GTExercise call({
    Object? id = const $CopyWithPlaceholder(),
    Object? parentID = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? parameters = const $CopyWithPlaceholder(),
    Object? sets = const $CopyWithPlaceholder(),
    Object? primaryMuscleGroup = const $CopyWithPlaceholder(),
    Object? secondaryMuscleGroups = const $CopyWithPlaceholder(),
    Object? restTime = const $CopyWithPlaceholder(),
    Object? libraryExerciseID = const $CopyWithPlaceholder(),
    Object? customExerciseID = const $CopyWithPlaceholder(),
    Object? isCustom = const $CopyWithPlaceholder(),
    Object? notes = const $CopyWithPlaceholder(),
    Object? inSuperset = const $CopyWithPlaceholder(),
    Object? supersetID = const $CopyWithPlaceholder(),
    Object? sortOrder = const $CopyWithPlaceholder(),
  }) {
    return GTExercise(
      id: id == const $CopyWithPlaceholder() || id == null
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      parentID: parentID == const $CopyWithPlaceholder() || parentID == null
          ? _value.parentID
          // ignore: cast_nullable_to_non_nullable
          : parentID as int,
      name: name == const $CopyWithPlaceholder() || name == null
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      parameters:
          parameters == const $CopyWithPlaceholder() || parameters == null
              ? _value.parameters
              // ignore: cast_nullable_to_non_nullable
              : parameters as GTSetParameters,
      sets: sets == const $CopyWithPlaceholder() || sets == null
          ? _value.sets
          // ignore: cast_nullable_to_non_nullable
          : sets as List<GTSet>,
      primaryMuscleGroup: primaryMuscleGroup == const $CopyWithPlaceholder() ||
              primaryMuscleGroup == null
          ? _value.primaryMuscleGroup
          // ignore: cast_nullable_to_non_nullable
          : primaryMuscleGroup as GTMuscleGroup,
      secondaryMuscleGroups:
          secondaryMuscleGroups == const $CopyWithPlaceholder() ||
                  secondaryMuscleGroups == null
              ? _value.secondaryMuscleGroups
              // ignore: cast_nullable_to_non_nullable
              : secondaryMuscleGroups as Set<GTMuscleGroup>,
      restTime: restTime == const $CopyWithPlaceholder()
          ? _value.restTime
          // ignore: cast_nullable_to_non_nullable
          : restTime as Duration?,
      libraryExerciseID: libraryExerciseID == const $CopyWithPlaceholder()
          ? _value.libraryExerciseID
          // ignore: cast_nullable_to_non_nullable
          : libraryExerciseID as String?,
      customExerciseID: customExerciseID == const $CopyWithPlaceholder()
          ? _value.customExerciseID
          // ignore: cast_nullable_to_non_nullable
          : customExerciseID as int?,
      isCustom: isCustom == const $CopyWithPlaceholder() || isCustom == null
          ? _value.isCustom
          // ignore: cast_nullable_to_non_nullable
          : isCustom as bool,
      notes: notes == const $CopyWithPlaceholder() || notes == null
          ? _value.notes
          // ignore: cast_nullable_to_non_nullable
          : notes as String,
      inSuperset:
          inSuperset == const $CopyWithPlaceholder() || inSuperset == null
              ? _value.inSuperset
              // ignore: cast_nullable_to_non_nullable
              : inSuperset as bool,
      supersetID: supersetID == const $CopyWithPlaceholder()
          ? _value.supersetID
          // ignore: cast_nullable_to_non_nullable
          : supersetID as int?,
      sortOrder: sortOrder == const $CopyWithPlaceholder() || sortOrder == null
          ? _value.sortOrder
          // ignore: cast_nullable_to_non_nullable
          : sortOrder as int,
    );
  }
}

extension $GTExerciseCopyWith on GTExercise {
  /// Returns a callable class that can be used as follows: `instanceOfGTExercise.copyWith(...)` or like so:`instanceOfGTExercise.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GTExerciseCWProxy get copyWith => _$GTExerciseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GTLibraryExercise _$GTLibraryExerciseFromJson(Map<String, dynamic> json) =>
    GTLibraryExercise(
      id: json['id'] as int,
      name: json['name'] as String,
      parameters: $enumDecode(_$GTSetParametersEnumMap, json['parameters']),
      primaryMuscleGroup:
          $enumDecode(_$GTMuscleGroupEnumMap, json['primaryMuscleGroup']),
      secondaryMuscleGroups: (json['secondaryMuscleGroups'] as List<dynamic>)
          .map((e) => $enumDecode(_$GTMuscleGroupEnumMap, e))
          .toSet(),
    );

Map<String, dynamic> _$GTLibraryExerciseToJson(GTLibraryExercise instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'parameters': _$GTSetParametersEnumMap[instance.parameters]!,
      'primaryMuscleGroup':
          _$GTMuscleGroupEnumMap[instance.primaryMuscleGroup]!,
      'secondaryMuscleGroups': instance.secondaryMuscleGroups
          .map((e) => _$GTMuscleGroupEnumMap[e]!)
          .toList(),
    };

const _$GTSetParametersEnumMap = {
  GTSetParameters.repsWeight: 'repsWeight',
  GTSetParameters.timeWeight: 'timeWeight',
  GTSetParameters.freeBodyReps: 'freeBodyReps',
  GTSetParameters.time: 'time',
  GTSetParameters.distance: 'distance',
};

const _$GTMuscleGroupEnumMap = {
  GTMuscleGroup.abductors: 'abductors',
  GTMuscleGroup.abs: 'abs',
  GTMuscleGroup.adductors: 'adductors',
  GTMuscleGroup.biceps: 'biceps',
  GTMuscleGroup.calves: 'calves',
  GTMuscleGroup.chest: 'chest',
  GTMuscleGroup.forearm: 'forearm',
  GTMuscleGroup.glutes: 'glutes',
  GTMuscleGroup.hamstrings: 'hamstrings',
  GTMuscleGroup.lats: 'lats',
  GTMuscleGroup.lowerBack: 'lowerBack',
  GTMuscleGroup.none: 'none',
  GTMuscleGroup.other: 'other',
  GTMuscleGroup.quadriceps: 'quadriceps',
  GTMuscleGroup.shoulders: 'shoulders',
  GTMuscleGroup.traps: 'traps',
  GTMuscleGroup.triceps: 'triceps',
  GTMuscleGroup.upperBack: 'upperBack',
};

GTSuperset _$GTSupersetFromJson(Map<String, dynamic> json) => GTSuperset(
      id: json['id'] as int,
      parentID: json['parentID'] as int,
      name: json['name'] as String,
      restTime: Duration(microseconds: json['restTime'] as int),
      notes: json['notes'] as String,
      sortOrder: json['sortOrder'] as int,
    );

Map<String, dynamic> _$GTSupersetToJson(GTSuperset instance) =>
    <String, dynamic>{
      'id': instance.id,
      'parentID': instance.parentID,
      'name': instance.name,
      'notes': instance.notes,
      'sortOrder': instance.sortOrder,
      'restTime': instance.restTime.inMicroseconds,
    };

GTExercise _$GTExerciseFromJson(Map<String, dynamic> json) => GTExercise(
      id: json['id'] as int,
      parentID: json['parentID'] as int,
      name: json['name'] as String,
      parameters: $enumDecode(_$GTSetParametersEnumMap, json['parameters']),
      sets: (json['sets'] as List<dynamic>)
          .map((e) => GTSet.fromJson(e as Map<String, dynamic>))
          .toList(),
      primaryMuscleGroup:
          $enumDecode(_$GTMuscleGroupEnumMap, json['primaryMuscleGroup']),
      secondaryMuscleGroups: (json['secondaryMuscleGroups'] as List<dynamic>)
          .map((e) => $enumDecode(_$GTMuscleGroupEnumMap, e))
          .toSet(),
      restTime: json['restTime'] == null
          ? null
          : Duration(microseconds: json['restTime'] as int),
      libraryExerciseID: json['libraryExerciseID'] as String?,
      customExerciseID: json['customExerciseID'] as int?,
      isCustom: json['isCustom'] as bool,
      notes: json['notes'] as String,
      inSuperset: json['inSuperset'] as bool,
      supersetID: json['supersetID'] as int?,
      sortOrder: json['sortOrder'] as int,
    );

Map<String, dynamic> _$GTExerciseToJson(GTExercise instance) =>
    <String, dynamic>{
      'id': instance.id,
      'parentID': instance.parentID,
      'name': instance.name,
      'restTime': instance.restTime?.inMicroseconds,
      'libraryExerciseID': instance.libraryExerciseID,
      'customExerciseID': instance.customExerciseID,
      'isCustom': instance.isCustom,
      'notes': instance.notes,
      'inSuperset': instance.inSuperset,
      'supersetID': instance.supersetID,
      'sortOrder': instance.sortOrder,
      'parameters': _$GTSetParametersEnumMap[instance.parameters]!,
      'sets': instance.sets,
      'primaryMuscleGroup':
          _$GTMuscleGroupEnumMap[instance.primaryMuscleGroup]!,
      'secondaryMuscleGroups': instance.secondaryMuscleGroups
          .map((e) => _$GTMuscleGroupEnumMap[e]!)
          .toList(),
    };
