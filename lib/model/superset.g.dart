// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'superset.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SupersetCWProxy {
  Superset id(String? id);

  Superset exercises(List<Exercise> exercises);

  Superset restTime(Duration restTime);

  Superset notes(String notes);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Superset(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Superset(...).copyWith(id: 12, name: "My name")
  /// ````
  Superset call({
    String? id,
    List<Exercise>? exercises,
    Duration? restTime,
    String? notes,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSuperset.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSuperset.copyWith.fieldName(...)`
class _$SupersetCWProxyImpl implements _$SupersetCWProxy {
  const _$SupersetCWProxyImpl(this._value);

  final Superset _value;

  @override
  Superset id(String? id) => this(id: id);

  @override
  Superset exercises(List<Exercise> exercises) => this(exercises: exercises);

  @override
  Superset restTime(Duration restTime) => this(restTime: restTime);

  @override
  Superset notes(String notes) => this(notes: notes);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Superset(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Superset(...).copyWith(id: 12, name: "My name")
  /// ````
  Superset call({
    Object? id = const $CopyWithPlaceholder(),
    Object? exercises = const $CopyWithPlaceholder(),
    Object? restTime = const $CopyWithPlaceholder(),
    Object? notes = const $CopyWithPlaceholder(),
  }) {
    return Superset(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String?,
      exercises: exercises == const $CopyWithPlaceholder() || exercises == null
          ? _value.exercises
          // ignore: cast_nullable_to_non_nullable
          : exercises as List<Exercise>,
      restTime: restTime == const $CopyWithPlaceholder() || restTime == null
          ? _value.restTime
          // ignore: cast_nullable_to_non_nullable
          : restTime as Duration,
      notes: notes == const $CopyWithPlaceholder() || notes == null
          ? _value.notes
          // ignore: cast_nullable_to_non_nullable
          : notes as String,
    );
  }
}

extension $SupersetCopyWith on Superset {
  /// Returns a callable class that can be used as follows: `instanceOfSuperset.copyWith(...)` or like so:`instanceOfSuperset.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SupersetCWProxy get copyWith => _$SupersetCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Superset _$SupersetFromJson(Map<String, dynamic> json) => Superset(
      id: json['id'] as String?,
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
          .toList(),
      restTime: Duration(microseconds: json['restTime'] as int),
      notes: json['notes'] as String? ?? '',
    );

Map<String, dynamic> _$SupersetToJson(Superset instance) => <String, dynamic>{
      'id': instance.id,
      'exercises': instance.exercises,
      'restTime': instance.restTime.inMicroseconds,
      'notes': instance.notes,
    };
