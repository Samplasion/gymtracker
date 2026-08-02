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

  Workout folder(GTRoutineFolder? folder);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `Workout(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// Workout(...).copyWith(id: 12, name: "My name")
  /// ```
  Workout call({
    String? id,
    String name,
    List<WorkoutExercisable> exercises,
    Duration? duration,
    DateTime? startingDate,
    String? parentID,
    String? infobox,
    String? completedBy,
    String? completes,
    Weights weightUnit,
    Distance distanceUnit,
    GTRoutineFolder? folder,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfWorkout.copyWith(...)` or call `instanceOfWorkout.copyWith.fieldName(value)` for a single field.
class _$WorkoutCWProxyImpl implements _$WorkoutCWProxy {
  const _$WorkoutCWProxyImpl(this._value);

  final Workout _value;

  @override
  Workout id(String? id) => call(id: id);

  @override
  Workout name(String name) => call(name: name);

  @override
  Workout exercises(List<WorkoutExercisable> exercises) =>
      call(exercises: exercises);

  @override
  Workout duration(Duration? duration) => call(duration: duration);

  @override
  Workout startingDate(DateTime? startingDate) =>
      call(startingDate: startingDate);

  @override
  Workout parentID(String? parentID) => call(parentID: parentID);

  @override
  Workout infobox(String? infobox) => call(infobox: infobox);

  @override
  Workout completedBy(String? completedBy) => call(completedBy: completedBy);

  @override
  Workout completes(String? completes) => call(completes: completes);

  @override
  Workout weightUnit(Weights weightUnit) => call(weightUnit: weightUnit);

  @override
  Workout distanceUnit(Distance distanceUnit) =>
      call(distanceUnit: distanceUnit);

  @override
  Workout folder(GTRoutineFolder? folder) => call(folder: folder);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `Workout(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// Workout(...).copyWith(id: 12, name: "My name")
  /// ```
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
    Object? folder = const $CopyWithPlaceholder(),
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
      folder: folder == const $CopyWithPlaceholder()
          ? _value.folder
          // ignore: cast_nullable_to_non_nullable
          : folder as GTRoutineFolder?,
    );
  }
}

extension $WorkoutCopyWith on Workout {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfWorkout.copyWith(...)` or `instanceOfWorkout.copyWith.fieldName(...)`.
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
      : Duration(microseconds: (json['duration'] as num).toInt()),
  startingDate: json['startingDate'] == null
      ? null
      : DateTime.parse(json['startingDate'] as String),
  parentID: json['parentID'] as String?,
  infobox: json['infobox'] as String?,
  completedBy: json['completedBy'] as String?,
  completes: json['completes'] as String?,
  weightUnit:
      $enumDecodeNullable(_$WeightsEnumMap, json['weightUnit']) ?? Weights.kg,
  distanceUnit:
      $enumDecodeNullable(_$DistanceEnumMap, json['distanceUnit']) ??
      Distance.km,
  folder: json['folder'] == null
      ? null
      : GTRoutineFolder.fromJson(json['folder'] as Map<String, dynamic>),
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
  'folder': instance.folder,
};

const _$WeightsEnumMap = {Weights.kg: 'kg', Weights.lb: 'lb'};

const _$DistanceEnumMap = {Distance.km: 'km', Distance.mi: 'mi'};
