import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/struct/date_sequence.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/utils.dart';
import 'package:openfoodfacts/openfoodfacts.dart' hide Unit;

part 'nutrition.categories.dart';
part 'nutrition.g.dart';
part 'nutrition.int.dart';
part 'nutrition.values.dart';

typedef TaggedNutritionGoal = DateTagged<NutritionGoal>;

class NutritionGoal {
  final double dailyCalories;
  final double dailyFat;
  final double dailyCarbs;
  final double dailyProtein;

  const NutritionGoal({
    required this.dailyCalories,
    required this.dailyFat,
    required this.dailyCarbs,
    required this.dailyProtein,
  });

  factory NutritionGoal.fromJson(Map<String, dynamic> json) {
    return NutritionGoal(
      dailyCalories: json['dailyCalories'],
      dailyFat: json['dailyFat'],
      dailyCarbs: json['dailyCarbs'],
      dailyProtein: json['dailyProtein'],
    );
  }

  factory NutritionGoal.fromPercentages({
    required double dailyCalories,
    required double fatPercentage,
    required double carbsPercentage,
    required double proteinPercentage,
  }) {
    final fat = dailyCalories * fatPercentage / 100 / 9;
    final carbs = dailyCalories * carbsPercentage / 100 / 4;
    final protein = dailyCalories * proteinPercentage / 100 / 4;
    return NutritionGoal(
      dailyCalories: dailyCalories,
      dailyFat: fat,
      dailyCarbs: carbs,
      dailyProtein: protein,
    );
  }

  double get fatPercentage => dailyFat * 9 / dailyCalories * 100;
  double get carbsPercentage => dailyCarbs * 4 / dailyCalories * 100;
  double get proteinPercentage => dailyProtein * 4 / dailyCalories * 100;

  // 50-30-20 split
  static const defaultGoal = NutritionGoal(
    dailyCalories: 2000,
    dailyFat: 66.66666666666667,
    dailyCarbs: 250,
    dailyProtein: 100,
  );

  Map<String, dynamic> toJson() {
    return {
      'dailyCalories': dailyCalories,
      'dailyFat': dailyFat,
      'dailyCarbs': dailyCarbs,
      'dailyProtein': dailyProtein,
    };
  }

  @override
  String toString() {
    return 'NutritionGoal{dailyCalories: $dailyCalories, dailyFat: $dailyFat, dailyCarbs: $dailyCarbs, dailyProtein: $dailyProtein}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    // We use a custom double equality function to compare the doubles
    // (with a pretty high epsilon, at that) because we don't want to burden
    // the user with having to input the exact same values to get a match.
    bool doubleEq(double a, double b) => doubleEquality(a, b, epsilon: 0.1);
    return other is NutritionGoal &&
        doubleEq(other.dailyCalories, dailyCalories) &&
        doubleEq(other.dailyFat, dailyFat) &&
        doubleEq(other.dailyCarbs, dailyCarbs) &&
        doubleEq(other.dailyProtein, dailyProtein);
  }

  @override
  int get hashCode {
    return dailyCalories.hashCode ^
        dailyFat.hashCode ^
        dailyCarbs.hashCode ^
        dailyProtein.hashCode;
  }
}

class ServingSize {
  final String? name;
  final double amount;

  const ServingSize({
    this.name,
    required this.amount,
  });

  factory ServingSize.fromJson(Map<String, dynamic> json) {
    return ServingSize(
      name: json['name'],
      amount: json['amount'],
    );
  }

  @override
  String toString() => 'ServingSize(name: $name, amount: $amount)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ServingSize && other.name == name && other.amount == amount;
  }

  @override
  int get hashCode => name.hashCode ^ amount.hashCode;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'amount': amount,
    };
  }
}

class VagueFood {
  final String name;
  final String? brand;
  final NutritionValues nutritionalValuesPer100g;
  final List<ServingSize> servingSizes;
  final bool isDownloaded;
  final String? barcode;
  final NutritionUnit unit;

  const VagueFood({
    required this.name,
    this.brand,
    required this.nutritionalValuesPer100g,
    this.servingSizes = const [],
    this.isDownloaded = false,
    this.barcode,
    this.unit = NutritionUnit.G,
  }) : assert(unit == NutritionUnit.G || unit == NutritionUnit.MILLI_L,
            'Invalid unit $unit (only G and MILLI_L are allowed)');

  factory VagueFood.fromJson(Map<String, dynamic> json) {
    return VagueFood(
      name: json['name'],
      brand: json['brand'],
      nutritionalValuesPer100g:
          NutritionValues.fromJson(json['nutritionalValuesPer100g']),
      servingSizes: (json['servingSizes'] as List)
          .map((e) => ServingSize.fromJson(e))
          .toList(),
      isDownloaded: json['isDownloaded'] ?? false,
      barcode: json['barcode'],
      unit: deserializeUnit(json['unit'] ?? 'g'),
    );
  }

  @override
  String toString() {
    return 'VagueFood(name: $name, brand: $brand, nutritionalValuesPer100g: $nutritionalValuesPer100g, servingSizes: $servingSizes, isDownloaded: $isDownloaded, barcode: $barcode, unit: $unit)';
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'brand': brand,
      'nutritionalValuesPer100g': nutritionalValuesPer100g.toJson(),
      'servingSizes': servingSizes.map((e) => e.toJson()).toList(),
      'isDownloaded': isDownloaded,
      'barcode': barcode,
      'unit': serializeUnit(unit),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is VagueFood &&
        other.name == name &&
        other.brand == brand &&
        other.nutritionalValuesPer100g == nutritionalValuesPer100g &&
        listEquals(other.servingSizes, servingSizes) &&
        other.isDownloaded == isDownloaded &&
        other.barcode == barcode &&
        other.unit == unit;
  }

  @override
  int get hashCode =>
      name.hashCode ^
      brand.hashCode ^
      nutritionalValuesPer100g.hashCode ^
      servingSizes.hashCode ^
      isDownloaded.hashCode ^
      barcode.hashCode ^
      unit.hashCode;

  String? get url => barcode == null || !isDownloaded
      ? null
      : "https://world.openfoodfacts.org/product/$barcode/";
}

typedef TaggedFood = DateTagged<Food>;

@CopyWith()
class Food extends VagueFood {
  final String? id;
  final double amount;
  final int pieces;
  final String? category;

  const Food({
    required super.name,
    super.brand,
    required super.nutritionalValuesPer100g,
    required this.amount,
    super.servingSizes,
    this.id,
    super.isDownloaded,
    super.barcode,
    super.unit,
    this.pieces = 1,
    this.category,
  });

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      id: json['id'],
      name: json['name'],
      brand: json['brand'],
      nutritionalValuesPer100g:
          NutritionValues.fromJson(json['nutritionalValuesPer100g']),
      servingSizes: (json['servingSizes'] as List)
          .map((e) => ServingSize.fromJson(e))
          .toList(),
      amount: json['amount'],
      isDownloaded: json['isDownloaded'] ?? false,
      barcode: json['barcode'],
      unit: deserializeUnit(json['unit'] ?? 'g'),
      pieces: (json['pieces'] as int?) ?? 1,
      category: json['category'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'pieces': pieces,
      'category': category,
      ...super.toJson(),
    };
  }

  @override
  String toString() {
    return 'Food(id: $id, name: $name, brand: $brand, nutritionalValuesPer100g: $nutritionalValuesPer100g, amount: $amount, servingSizes: $servingSizes, isDownloaded: $isDownloaded, barcode: $barcode, unit: $unit, pieces: $pieces, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Food &&
        other.id == id &&
        other.name == name &&
        other.brand == brand &&
        other.nutritionalValuesPer100g == nutritionalValuesPer100g &&
        other.amount == amount &&
        listEquals(other.servingSizes, servingSizes) &&
        other.isDownloaded == isDownloaded &&
        other.barcode == barcode &&
        other.unit == unit &&
        other.pieces == pieces &&
        other.category == category;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      brand.hashCode ^
      nutritionalValuesPer100g.hashCode ^
      amount.hashCode ^
      servingSizes.hashCode ^
      isDownloaded.hashCode ^
      barcode.hashCode ^
      unit.hashCode ^
      pieces.hashCode ^
      category.hashCode;

  int get hashCodeForSearch => Object.hash(
        name,
        brand,
        nutritionalValuesPer100g,
        Object.hashAll(servingSizes),
        barcode,
        unit,
      );

  bool equalsForSearch(Food other) =>
      other.name == name &&
      other.brand == brand &&
      other.nutritionalValuesPer100g == nutritionalValuesPer100g &&
      listEquals(other.servingSizes, servingSizes) &&
      other.barcode == barcode &&
      other.unit == unit;

  NutritionValues get nutritionalValues =>
      nutritionalValuesPer100g / 100 * amount * pieces.toDouble();
}
