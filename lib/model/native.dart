import 'dart:ui';

import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/utils/extensions.dart';

class NativeWorkoutStateMessage {
  final bool hasExercise;
  final String exerciseName;
  final Color exerciseColor;
  final String exerciseParameters;
  final DateTime startingTime;
  final DateTime? restTimeStart;
  final DateTime? restTimeEnd;
  final double percentageDone;
  final GTSet? set;

  NativeWorkoutStateMessage({
    required this.hasExercise,
    required this.exerciseName,
    required this.exerciseColor,
    required this.exerciseParameters,
    required this.startingTime,
    this.restTimeStart,
    this.restTimeEnd,
    required this.percentageDone,
    required this.set,
  });

  Map<String, dynamic> toJson() {
    return {
      'hasExercise': hasExercise,
      'exerciseName': exerciseName,
      'exerciseColor': exerciseColor.hexValue,
      'exerciseParameters': exerciseParameters,
      'startingTime': startingTime.millisecondsSinceEpoch,
      'restTimeStart': restTimeStart?.millisecondsSinceEpoch,
      'restTimeEnd': restTimeEnd?.millisecondsSinceEpoch,
      'percentageDone': percentageDone,
      'set': set?.toJson(),
    };
  }
}

class NativeFoodCategory {
  final String name;
  final String emoji;
  final NativeFoodNutritionSplit nutritionSplit;

  NativeFoodCategory({
    required this.name,
    required this.emoji,
    required this.nutritionSplit,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'emoji': emoji,
      'nutritionSplit': nutritionSplit.toJson(),
    };
  }
}

class NativeFoodNutritionSplit {
  final double protein;
  final double proteinGoal;
  final double carbs;
  final double carbsGoal;
  final double fats;
  final double fatsGoal;

  NativeFoodNutritionSplit({
    required this.protein,
    required this.proteinGoal,
    required this.carbs,
    required this.carbsGoal,
    required this.fats,
    required this.fatsGoal,
  });

  Map<String, dynamic> toJson() {
    return {
      'protein': protein,
      'proteinGoal': proteinGoal,
      'carbs': carbs,
      'carbsGoal': carbsGoal,
      'fats': fats,
      'fatsGoal': fatsGoal,
    };
  }
}

class NativeFoodStateMessage {
  final double calorieGoal;
  final double calorieIntake;
  final List<NativeFoodCategory> categories;
  final NativeFoodNutritionSplit totalNutritionSplit;

  NativeFoodStateMessage({
    required this.calorieGoal,
    required this.calorieIntake,
    required this.categories,
    required this.totalNutritionSplit,
  });

  Map<String, dynamic> toJson() {
    return {
      'calorieGoal': calorieGoal,
      'calorieIntake': calorieIntake,
      'categories': categories.map((category) => category.toJson()).toList(),
      'totalNutritionSplit': totalNutritionSplit.toJson(),
    };
  }
}
