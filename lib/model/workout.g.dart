// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WorkoutCWProxy {
  Workout id(String? id);

  Workout name(String name);

  Workout exercises(List<Exercise> exercises);

  Workout duration(Duration? duration);

  Workout startingDate(DateTime? startingDate);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Workout(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Workout(...).copyWith(id: 12, name: "My name")
  /// ````
  Workout call({
    String? id,
    String? name,
    List<Exercise>? exercises,
    Duration? duration,
    DateTime? startingDate,
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
  Workout exercises(List<Exercise> exercises) => this(exercises: exercises);

  @override
  Workout duration(Duration? duration) => this(duration: duration);

  @override
  Workout startingDate(DateTime? startingDate) =>
      this(startingDate: startingDate);

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
  }) {
    return Workout(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String?,
      name: name == const $CopyWithPlaceholder() || name == null
          // ignore: unnecessary_non_null_assertion
          ? _value.name!
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      exercises: exercises == const $CopyWithPlaceholder() || exercises == null
          // ignore: unnecessary_non_null_assertion
          ? _value.exercises!
          // ignore: cast_nullable_to_non_nullable
          : exercises as List<Exercise>,
      duration: duration == const $CopyWithPlaceholder()
          ? _value.duration
          // ignore: cast_nullable_to_non_nullable
          : duration as Duration?,
      startingDate: startingDate == const $CopyWithPlaceholder()
          ? _value.startingDate
          // ignore: cast_nullable_to_non_nullable
          : startingDate as DateTime?,
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
          .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
          .toList(),
      duration: json['duration'] == null
          ? null
          : Duration(microseconds: json['duration'] as int),
      startingDate: json['startingDate'] == null
          ? null
          : DateTime.parse(json['startingDate'] as String),
    );

Map<String, dynamic> _$WorkoutToJson(Workout instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'exercises': instance.exercises,
      'duration': instance.duration?.inMicroseconds,
      'startingDate': instance.startingDate?.toIso8601String(),
    };
