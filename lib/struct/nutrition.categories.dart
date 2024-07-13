part of 'nutrition.dart';

class NutritionCategory {
  final String name;
  final int dailyPercentage; // 1-100%
  final NutritionCategoryIcon icon;

  const NutritionCategory({
    required this.name,
    required this.dailyPercentage,
    required this.icon,
  });

  factory NutritionCategory.fromJson(Map<String, dynamic> json) {
    return NutritionCategory(
      name: json['name'],
      dailyPercentage: json['dailyPercentage'],
      icon: NutritionCategoryIcon.fromString(json['icon']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dailyPercentage': dailyPercentage,
      'icon': icon.name,
    };
  }

  @override
  String toString() {
    return 'NutritionCategory{name: $name, dailyPercentage: $dailyPercentage, icon: $icon}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NutritionCategory &&
        other.name == name &&
        other.dailyPercentage == dailyPercentage &&
        other.icon == icon;
  }

  @override
  int get hashCode {
    return name.hashCode ^ dailyPercentage.hashCode ^ icon.hashCode;
  }
}

enum NutritionCategoryIcon {
  fork_and_spoon(Icons.local_dining_rounded),
  water(Icons.local_drink_rounded),
  fruit(Icons.eco_rounded),
  pizza(Icons.local_pizza_rounded),
  hamburger(Icons.fastfood_rounded),
  ice_cream(Icons.icecream_rounded),
  cake(Icons.cake_rounded),
  coffee(Icons.coffee_rounded),
  wine(Icons.local_bar_rounded);

  const NutritionCategoryIcon(this.iconData);

  final IconData iconData;

  static NutritionCategoryIcon fromString(String value) {
    return NutritionCategoryIcon.values.firstWhere(
      (e) => e.name == value,
      orElse: () => NutritionCategoryIcon.fork_and_spoon,
    );
  }
}
