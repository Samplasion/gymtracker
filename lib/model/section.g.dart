// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'section.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SectionCWProxy {
  Section id(String? id);

  Section notes(String notes);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Section(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Section(...).copyWith(id: 12, name: "My name")
  /// ````
  Section call({
    String? id,
    String? notes,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSection.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSection.copyWith.fieldName(...)`
class _$SectionCWProxyImpl implements _$SectionCWProxy {
  const _$SectionCWProxyImpl(this._value);

  final Section _value;

  @override
  Section id(String? id) => this(id: id);

  @override
  Section notes(String notes) => this(notes: notes);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Section(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Section(...).copyWith(id: 12, name: "My name")
  /// ````
  Section call({
    Object? id = const $CopyWithPlaceholder(),
    Object? notes = const $CopyWithPlaceholder(),
  }) {
    return Section(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String?,
      notes: notes == const $CopyWithPlaceholder() || notes == null
          ? _value.notes
          // ignore: cast_nullable_to_non_nullable
          : notes as String,
    );
  }
}

extension $SectionCopyWith on Section {
  /// Returns a callable class that can be used as follows: `instanceOfSection.copyWith(...)` or like so:`instanceOfSection.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SectionCWProxy get copyWith => _$SectionCWProxyImpl(this);
}
