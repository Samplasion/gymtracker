// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nutrition.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$FoodCWProxy {
  Food name(String name);

  Food brand(String? brand);

  Food nutritionalValuesPer100g(NutritionValues nutritionalValuesPer100g);

  Food amount(double amount);

  Food servingSizes(List<ServingSize> servingSizes);

  Food id(String? id);

  Food isDownloaded(bool isDownloaded);

  Food barcode(String? barcode);

  Food unit(NutritionUnit unit);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Food(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Food(...).copyWith(id: 12, name: "My name")
  /// ````
  Food call({
    String? name,
    String? brand,
    NutritionValues? nutritionalValuesPer100g,
    double? amount,
    List<ServingSize>? servingSizes,
    String? id,
    bool? isDownloaded,
    String? barcode,
    NutritionUnit? unit,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfFood.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfFood.copyWith.fieldName(...)`
class _$FoodCWProxyImpl implements _$FoodCWProxy {
  const _$FoodCWProxyImpl(this._value);

  final Food _value;

  @override
  Food name(String name) => this(name: name);

  @override
  Food brand(String? brand) => this(brand: brand);

  @override
  Food nutritionalValuesPer100g(NutritionValues nutritionalValuesPer100g) =>
      this(nutritionalValuesPer100g: nutritionalValuesPer100g);

  @override
  Food amount(double amount) => this(amount: amount);

  @override
  Food servingSizes(List<ServingSize> servingSizes) =>
      this(servingSizes: servingSizes);

  @override
  Food id(String? id) => this(id: id);

  @override
  Food isDownloaded(bool isDownloaded) => this(isDownloaded: isDownloaded);

  @override
  Food barcode(String? barcode) => this(barcode: barcode);

  @override
  Food unit(NutritionUnit unit) => this(unit: unit);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Food(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Food(...).copyWith(id: 12, name: "My name")
  /// ````
  Food call({
    Object? name = const $CopyWithPlaceholder(),
    Object? brand = const $CopyWithPlaceholder(),
    Object? nutritionalValuesPer100g = const $CopyWithPlaceholder(),
    Object? amount = const $CopyWithPlaceholder(),
    Object? servingSizes = const $CopyWithPlaceholder(),
    Object? id = const $CopyWithPlaceholder(),
    Object? isDownloaded = const $CopyWithPlaceholder(),
    Object? barcode = const $CopyWithPlaceholder(),
    Object? unit = const $CopyWithPlaceholder(),
  }) {
    return Food(
      name: name == const $CopyWithPlaceholder() || name == null
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      brand: brand == const $CopyWithPlaceholder()
          ? _value.brand
          // ignore: cast_nullable_to_non_nullable
          : brand as String?,
      nutritionalValuesPer100g:
          nutritionalValuesPer100g == const $CopyWithPlaceholder() ||
                  nutritionalValuesPer100g == null
              ? _value.nutritionalValuesPer100g
              // ignore: cast_nullable_to_non_nullable
              : nutritionalValuesPer100g as NutritionValues,
      amount: amount == const $CopyWithPlaceholder() || amount == null
          ? _value.amount
          // ignore: cast_nullable_to_non_nullable
          : amount as double,
      servingSizes:
          servingSizes == const $CopyWithPlaceholder() || servingSizes == null
              ? _value.servingSizes
              // ignore: cast_nullable_to_non_nullable
              : servingSizes as List<ServingSize>,
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String?,
      isDownloaded:
          isDownloaded == const $CopyWithPlaceholder() || isDownloaded == null
              ? _value.isDownloaded
              // ignore: cast_nullable_to_non_nullable
              : isDownloaded as bool,
      barcode: barcode == const $CopyWithPlaceholder()
          ? _value.barcode
          // ignore: cast_nullable_to_non_nullable
          : barcode as String?,
      unit: unit == const $CopyWithPlaceholder() || unit == null
          ? _value.unit
          // ignore: cast_nullable_to_non_nullable
          : unit as NutritionUnit,
    );
  }
}

extension $FoodCopyWith on Food {
  /// Returns a callable class that can be used as follows: `instanceOfFood.copyWith(...)` or like so:`instanceOfFood.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$FoodCWProxy get copyWith => _$FoodCWProxyImpl(this);
}
