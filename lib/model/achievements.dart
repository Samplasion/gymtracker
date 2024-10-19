import 'package:flutter/material.dart';
import 'package:gymtracker/utils/extensions.dart';

enum AchievementTrigger {
  workout,
  food,
  weight,
  routines,
}

final class Achievement {
  final String id, nameKey, iconKey;
  final List<AchievementLevel> levels;
  final Color color;

  const Achievement({
    required this.id,
    required this.nameKey,
    required this.iconKey,
    required this.levels,
    this.color = Colors.amber,
  });

  AchievementLevel? nextLevel(AchievementCompletion completion) {
    if (completion.achievementID != id) {
      throw ArgumentError(
          "The completion given to this function is not for this achievement");
    }
    return levels.getAt(completion.level);
  }

  bool isCompleted(AchievementCompletion completion) {
    if (completion.achievementID != id) {
      throw ArgumentError(
          "The completion given to this function is not for this achievement");
    }
    return completion.achievementID == id && completion.level == levels.length;
  }

  AchievementLevel? getLevel(AchievementCompletion completion) {
    if (completion.achievementID != id) {
      throw ArgumentError(
          "The completion given to this function is not for this achievement");
    }
    return levels.getAt(completion.level - 1);
  }

  @override
  String toString() {
    return "Achievement{id: $id, nameKey: $nameKey, iconKey: $iconKey, levels: $levels}";
  }
}

final class AchievementLevel {
  final String achievementID;
  final int level;
  final String nameKey;
  final String descriptionKey;
  final AchievementTrigger trigger;
  final bool Function(double? progress) checkCompletion;
  final double Function()? progress;
  final String Function(double value)? progressText;
  final double Function()? progressMax;

  const AchievementLevel({
    required this.achievementID,
    required this.level,
    required this.nameKey,
    required this.descriptionKey,
    required this.trigger,
    required this.checkCompletion,
    this.progress,
    this.progressText,
    this.progressMax,
  })  : assert(progress == null || progressMax != null),
        assert(progressMax == null || progress != null),
        assert(progressText == null || progress != null);

  bool get canShowProgress => progress != null && progressMax != null;

  @override
  String toString() {
    return "AchievementLevel{achievementID: $achievementID, level: $level, descriptionKey: $descriptionKey, trigger: $trigger, checkCompletion: $checkCompletion, progress: $progress, progressText: $progressText, progressMax: $progressMax}";
  }
}

final class AchievementCompletion {
  final String achievementID;
  final int level;
  final DateTime completedAt;

  const AchievementCompletion({
    required this.achievementID,
    required this.level,
    required this.completedAt,
  });

  factory AchievementCompletion.fromJson(Map<String, dynamic> json) {
    return AchievementCompletion(
      achievementID: json['achievementID'] as String,
      level: json['level'] as int,
      completedAt: DateTime.parse(json['completedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'achievementID': achievementID,
        'level': level,
        'completedAt': completedAt.toIso8601String(),
      };
}
