// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routine.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GTRoutineCWProxy {
  GTRoutine id(int id);

  GTRoutine name(String name);

  GTRoutine notes(String notes);

  GTRoutine weightUnit(Weights weightUnit);

  GTRoutine distanceUnit(Distance distanceUnit);

  GTRoutine exercises(List<GTExerciseOrSuperset> exercises);

  GTRoutine sortOrder(int sortOrder);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GTRoutine(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GTRoutine(...).copyWith(id: 12, name: "My name")
  /// ````
  GTRoutine call({
    int? id,
    String? name,
    String? notes,
    Weights? weightUnit,
    Distance? distanceUnit,
    List<GTExerciseOrSuperset>? exercises,
    int? sortOrder,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGTRoutine.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGTRoutine.copyWith.fieldName(...)`
class _$GTRoutineCWProxyImpl implements _$GTRoutineCWProxy {
  const _$GTRoutineCWProxyImpl(this._value);

  final GTRoutine _value;

  @override
  GTRoutine id(int id) => this(id: id);

  @override
  GTRoutine name(String name) => this(name: name);

  @override
  GTRoutine notes(String notes) => this(notes: notes);

  @override
  GTRoutine weightUnit(Weights weightUnit) => this(weightUnit: weightUnit);

  @override
  GTRoutine distanceUnit(Distance distanceUnit) =>
      this(distanceUnit: distanceUnit);

  @override
  GTRoutine exercises(List<GTExerciseOrSuperset> exercises) =>
      this(exercises: exercises);

  @override
  GTRoutine sortOrder(int sortOrder) => this(sortOrder: sortOrder);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GTRoutine(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GTRoutine(...).copyWith(id: 12, name: "My name")
  /// ````
  GTRoutine call({
    Object? id = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? notes = const $CopyWithPlaceholder(),
    Object? weightUnit = const $CopyWithPlaceholder(),
    Object? distanceUnit = const $CopyWithPlaceholder(),
    Object? exercises = const $CopyWithPlaceholder(),
    Object? sortOrder = const $CopyWithPlaceholder(),
  }) {
    return GTRoutine(
      id: id == const $CopyWithPlaceholder() || id == null
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      name: name == const $CopyWithPlaceholder() || name == null
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      notes: notes == const $CopyWithPlaceholder() || notes == null
          ? _value.notes
          // ignore: cast_nullable_to_non_nullable
          : notes as String,
      weightUnit:
          weightUnit == const $CopyWithPlaceholder() || weightUnit == null
              ? _value.weightUnit
              // ignore: cast_nullable_to_non_nullable
              : weightUnit as Weights,
      distanceUnit:
          distanceUnit == const $CopyWithPlaceholder() || distanceUnit == null
              ? _value.distanceUnit
              // ignore: cast_nullable_to_non_nullable
              : distanceUnit as Distance,
      exercises: exercises == const $CopyWithPlaceholder() || exercises == null
          ? _value.exercises
          // ignore: cast_nullable_to_non_nullable
          : exercises as List<GTExerciseOrSuperset>,
      sortOrder: sortOrder == const $CopyWithPlaceholder() || sortOrder == null
          ? _value.sortOrder
          // ignore: cast_nullable_to_non_nullable
          : sortOrder as int,
    );
  }
}

extension $GTRoutineCopyWith on GTRoutine {
  /// Returns a callable class that can be used as follows: `instanceOfGTRoutine.copyWith(...)` or like so:`instanceOfGTRoutine.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GTRoutineCWProxy get copyWith => _$GTRoutineCWProxyImpl(this);
}

abstract class _$GTHistoryWorkoutCWProxy {
  GTHistoryWorkout id(int id);

  GTHistoryWorkout name(String name);

  GTHistoryWorkout notes(String notes);

  GTHistoryWorkout weightUnit(Weights weightUnit);

  GTHistoryWorkout distanceUnit(Distance distanceUnit);

  GTHistoryWorkout exercises(List<GTExerciseOrSuperset> exercises);

  GTHistoryWorkout sortOrder(int sortOrder);

  GTHistoryWorkout startingDate(DateTime startingDate);

  GTHistoryWorkout duration(Duration duration);

  GTHistoryWorkout parentID(int? parentID);

  GTHistoryWorkout completedByID(int? completedByID);

  GTHistoryWorkout completesID(int? completesID);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GTHistoryWorkout(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GTHistoryWorkout(...).copyWith(id: 12, name: "My name")
  /// ````
  GTHistoryWorkout call({
    int? id,
    String? name,
    String? notes,
    Weights? weightUnit,
    Distance? distanceUnit,
    List<GTExerciseOrSuperset>? exercises,
    int? sortOrder,
    DateTime? startingDate,
    Duration? duration,
    int? parentID,
    int? completedByID,
    int? completesID,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGTHistoryWorkout.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGTHistoryWorkout.copyWith.fieldName(...)`
class _$GTHistoryWorkoutCWProxyImpl implements _$GTHistoryWorkoutCWProxy {
  const _$GTHistoryWorkoutCWProxyImpl(this._value);

  final GTHistoryWorkout _value;

  @override
  GTHistoryWorkout id(int id) => this(id: id);

  @override
  GTHistoryWorkout name(String name) => this(name: name);

  @override
  GTHistoryWorkout notes(String notes) => this(notes: notes);

  @override
  GTHistoryWorkout weightUnit(Weights weightUnit) =>
      this(weightUnit: weightUnit);

  @override
  GTHistoryWorkout distanceUnit(Distance distanceUnit) =>
      this(distanceUnit: distanceUnit);

  @override
  GTHistoryWorkout exercises(List<GTExerciseOrSuperset> exercises) =>
      this(exercises: exercises);

  @override
  GTHistoryWorkout sortOrder(int sortOrder) => this(sortOrder: sortOrder);

  @override
  GTHistoryWorkout startingDate(DateTime startingDate) =>
      this(startingDate: startingDate);

  @override
  GTHistoryWorkout duration(Duration duration) => this(duration: duration);

  @override
  GTHistoryWorkout parentID(int? parentID) => this(parentID: parentID);

  @override
  GTHistoryWorkout completedByID(int? completedByID) =>
      this(completedByID: completedByID);

  @override
  GTHistoryWorkout completesID(int? completesID) =>
      this(completesID: completesID);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GTHistoryWorkout(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GTHistoryWorkout(...).copyWith(id: 12, name: "My name")
  /// ````
  GTHistoryWorkout call({
    Object? id = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? notes = const $CopyWithPlaceholder(),
    Object? weightUnit = const $CopyWithPlaceholder(),
    Object? distanceUnit = const $CopyWithPlaceholder(),
    Object? exercises = const $CopyWithPlaceholder(),
    Object? sortOrder = const $CopyWithPlaceholder(),
    Object? startingDate = const $CopyWithPlaceholder(),
    Object? duration = const $CopyWithPlaceholder(),
    Object? parentID = const $CopyWithPlaceholder(),
    Object? completedByID = const $CopyWithPlaceholder(),
    Object? completesID = const $CopyWithPlaceholder(),
  }) {
    return GTHistoryWorkout(
      id: id == const $CopyWithPlaceholder() || id == null
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      name: name == const $CopyWithPlaceholder() || name == null
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      notes: notes == const $CopyWithPlaceholder() || notes == null
          ? _value.notes
          // ignore: cast_nullable_to_non_nullable
          : notes as String,
      weightUnit:
          weightUnit == const $CopyWithPlaceholder() || weightUnit == null
              ? _value.weightUnit
              // ignore: cast_nullable_to_non_nullable
              : weightUnit as Weights,
      distanceUnit:
          distanceUnit == const $CopyWithPlaceholder() || distanceUnit == null
              ? _value.distanceUnit
              // ignore: cast_nullable_to_non_nullable
              : distanceUnit as Distance,
      exercises: exercises == const $CopyWithPlaceholder() || exercises == null
          ? _value.exercises
          // ignore: cast_nullable_to_non_nullable
          : exercises as List<GTExerciseOrSuperset>,
      sortOrder: sortOrder == const $CopyWithPlaceholder() || sortOrder == null
          ? _value.sortOrder
          // ignore: cast_nullable_to_non_nullable
          : sortOrder as int,
      startingDate:
          startingDate == const $CopyWithPlaceholder() || startingDate == null
              ? _value.startingDate
              // ignore: cast_nullable_to_non_nullable
              : startingDate as DateTime,
      duration: duration == const $CopyWithPlaceholder() || duration == null
          ? _value.duration
          // ignore: cast_nullable_to_non_nullable
          : duration as Duration,
      parentID: parentID == const $CopyWithPlaceholder()
          ? _value.parentID
          // ignore: cast_nullable_to_non_nullable
          : parentID as int?,
      completedByID: completedByID == const $CopyWithPlaceholder()
          ? _value.completedByID
          // ignore: cast_nullable_to_non_nullable
          : completedByID as int?,
      completesID: completesID == const $CopyWithPlaceholder()
          ? _value.completesID
          // ignore: cast_nullable_to_non_nullable
          : completesID as int?,
    );
  }
}

extension $GTHistoryWorkoutCopyWith on GTHistoryWorkout {
  /// Returns a callable class that can be used as follows: `instanceOfGTHistoryWorkout.copyWith(...)` or like so:`instanceOfGTHistoryWorkout.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GTHistoryWorkoutCWProxy get copyWith => _$GTHistoryWorkoutCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GTRoutine _$GTRoutineFromJson(Map<String, dynamic> json) => GTRoutine(
      id: json['id'] as int,
      name: json['name'] as String,
      notes: json['notes'] as String,
      weightUnit: $enumDecode(_$WeightsEnumMap, json['weightUnit']),
      distanceUnit: $enumDecode(_$DistanceEnumMap, json['distanceUnit']),
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) => GTExerciseOrSuperset.fromJson(e as Map<String, dynamic>))
          .toList(),
      sortOrder: json['sortOrder'] as int,
    );

Map<String, dynamic> _$GTRoutineToJson(GTRoutine instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'notes': instance.notes,
      'weightUnit': _$WeightsEnumMap[instance.weightUnit]!,
      'distanceUnit': _$DistanceEnumMap[instance.distanceUnit]!,
      'exercises': instance.exercises,
      'sortOrder': instance.sortOrder,
    };

const _$WeightsEnumMap = {
  Weights.kg: 'kg',
  Weights.lb: 'lb',
};

const _$DistanceEnumMap = {
  Distance.km: 'km',
  Distance.mi: 'mi',
};

GTHistoryWorkout _$GTHistoryWorkoutFromJson(Map<String, dynamic> json) =>
    GTHistoryWorkout(
      id: json['id'] as int,
      name: json['name'] as String,
      notes: json['notes'] as String,
      weightUnit: $enumDecode(_$WeightsEnumMap, json['weightUnit']),
      distanceUnit: $enumDecode(_$DistanceEnumMap, json['distanceUnit']),
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) => GTExerciseOrSuperset.fromJson(e as Map<String, dynamic>))
          .toList(),
      sortOrder: json['sortOrder'] as int,
      startingDate: DateTime.parse(json['startingDate'] as String),
      duration: Duration(microseconds: json['duration'] as int),
      parentID: json['parentID'] as int?,
      completedByID: json['completedByID'] as int?,
      completesID: json['completesID'] as int?,
    );

Map<String, dynamic> _$GTHistoryWorkoutToJson(GTHistoryWorkout instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'notes': instance.notes,
      'weightUnit': _$WeightsEnumMap[instance.weightUnit]!,
      'distanceUnit': _$DistanceEnumMap[instance.distanceUnit]!,
      'exercises': instance.exercises,
      'sortOrder': instance.sortOrder,
      'startingDate': instance.startingDate.toIso8601String(),
      'duration': instance.duration.inMicroseconds,
      'parentID': instance.parentID,
      'completedByID': instance.completedByID,
      'completesID': instance.completesID,
    };
