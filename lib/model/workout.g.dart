// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WorkoutCWProxy {
  Workout id(String? id);

  Workout name(String name);

  Workout exercises(List<WorkoutExercisable> exercises);

  Workout duration(Duration? duration);

  Workout startingDate(DateTime? startingDate);

  Workout parentID(String? parentID);

  Workout infobox(String? infobox);

  Workout completedBy(String? completedBy);

  Workout completes(String? completes);

  Workout weightUnit(Weights weightUnit);

  Workout distanceUnit(Distance distanceUnit);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Workout(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Workout(...).copyWith(id: 12, name: "My name")
  /// ````
  Workout call({
    String? id,
    String? name,
    List<WorkoutExercisable>? exercises,
    Duration? duration,
    DateTime? startingDate,
    String? parentID,
    String? infobox,
    String? completedBy,
    String? completes,
    Weights? weightUnit,
    Distance? distanceUnit,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWorkout.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWorkout.copyWith.fieldName(...)`
class _$WorkoutCWProxyImpl implements _$WorkoutCWProxy {
  const _$WorkoutCWProxyImpl(this._value);

  final Workout _value;

  @override
  Workout id(String? id) => this(id: id);

  @override
  Workout name(String name) => this(name: name);

  @override
  Workout exercises(List<WorkoutExercisable> exercises) =>
      this(exercises: exercises);

  @override
  Workout duration(Duration? duration) => this(duration: duration);

  @override
  Workout startingDate(DateTime? startingDate) =>
      this(startingDate: startingDate);

  @override
  Workout parentID(String? parentID) => this(parentID: parentID);

  @override
  Workout infobox(String? infobox) => this(infobox: infobox);

  @override
  Workout completedBy(String? completedBy) => this(completedBy: completedBy);

  @override
  Workout completes(String? completes) => this(completes: completes);

  @override
  Workout weightUnit(Weights weightUnit) => this(weightUnit: weightUnit);

  @override
  Workout distanceUnit(Distance distanceUnit) =>
      this(distanceUnit: distanceUnit);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Workout(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Workout(...).copyWith(id: 12, name: "My name")
  /// ````
  Workout call({
    Object? id = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? exercises = const $CopyWithPlaceholder(),
    Object? duration = const $CopyWithPlaceholder(),
    Object? startingDate = const $CopyWithPlaceholder(),
    Object? parentID = const $CopyWithPlaceholder(),
    Object? infobox = const $CopyWithPlaceholder(),
    Object? completedBy = const $CopyWithPlaceholder(),
    Object? completes = const $CopyWithPlaceholder(),
    Object? weightUnit = const $CopyWithPlaceholder(),
    Object? distanceUnit = const $CopyWithPlaceholder(),
  }) {
    return Workout(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String?,
      name: name == const $CopyWithPlaceholder() || name == null
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      exercises: exercises == const $CopyWithPlaceholder() || exercises == null
          ? _value.exercises
          // ignore: cast_nullable_to_non_nullable
          : exercises as List<WorkoutExercisable>,
      duration: duration == const $CopyWithPlaceholder()
          ? _value.duration
          // ignore: cast_nullable_to_non_nullable
          : duration as Duration?,
      startingDate: startingDate == const $CopyWithPlaceholder()
          ? _value.startingDate
          // ignore: cast_nullable_to_non_nullable
          : startingDate as DateTime?,
      parentID: parentID == const $CopyWithPlaceholder()
          ? _value.parentID
          // ignore: cast_nullable_to_non_nullable
          : parentID as String?,
      infobox: infobox == const $CopyWithPlaceholder()
          ? _value.infobox
          // ignore: cast_nullable_to_non_nullable
          : infobox as String?,
      completedBy: completedBy == const $CopyWithPlaceholder()
          ? _value.completedBy
          // ignore: cast_nullable_to_non_nullable
          : completedBy as String?,
      completes: completes == const $CopyWithPlaceholder()
          ? _value.completes
          // ignore: cast_nullable_to_non_nullable
          : completes as String?,
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
    );
  }
}

extension $WorkoutCopyWith on Workout {
  /// Returns a callable class that can be used as follows: `instanceOfWorkout.copyWith(...)` or like so:`instanceOfWorkout.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WorkoutCWProxy get copyWith => _$WorkoutCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Workout _$WorkoutFromJson(Map<String, dynamic> json) => Workout(
      id: json['id'] as String?,
      name: json['name'] as String,
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) => WorkoutExercisable.fromJson(e as Map<String, dynamic>))
          .toList(),
      duration: json['duration'] == null
          ? null
          : Duration(microseconds: json['duration'] as int),
      startingDate: json['startingDate'] == null
          ? null
          : DateTime.parse(json['startingDate'] as String),
      parentID: json['parentID'] as String?,
      infobox: json['infobox'] as String?,
      completedBy: json['completedBy'] as String?,
      completes: json['completes'] as String?,
      weightUnit: $enumDecodeNullable(_$WeightsEnumMap, json['weightUnit']) ??
          Weights.kg,
      distanceUnit:
          $enumDecodeNullable(_$DistanceEnumMap, json['distanceUnit']) ??
              Distance.km,
    );

Map<String, dynamic> _$WorkoutToJson(Workout instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'exercises': instance.exercises,
      'duration': instance.duration?.inMicroseconds,
      'startingDate': instance.startingDate?.toIso8601String(),
      'infobox': instance.infobox,
      'parentID': instance.parentID,
      'weightUnit': _$WeightsEnumMap[instance.weightUnit]!,
      'distanceUnit': _$DistanceEnumMap[instance.distanceUnit]!,
      'completedBy': instance.completedBy,
      'completes': instance.completes,
    };

const _$WeightsEnumMap = {
  Weights.kg: 'kg',
  Weights.lb: 'lb',
};

const _$DistanceEnumMap = {
  Distance.km: 'km',
  Distance.mi: 'mi',
};
