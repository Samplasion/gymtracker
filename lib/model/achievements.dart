import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:syncable/syncable.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

enum AchievementTrigger { workout, food, weight, routines }

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
        "The completion given to this function is not for this achievement",
      );
    }
    return levels.getAt(completion.level);
  }

  bool isCompleted(AchievementCompletion completion) {
    if (completion.achievementID != id) {
      throw ArgumentError(
        "The completion given to this function is not for this achievement",
      );
    }
    return completion.achievementID == id && completion.level == levels.length;
  }

  AchievementLevel? getLevel(AchievementCompletion completion) {
    if (completion.achievementID != id) {
      throw ArgumentError(
        "The completion given to this function is not for this achievement",
      );
    }
    return levels.getAt(completion.level - 1);
  }

  @override
  String toString() {
    return "Achievement{id: $id, nameKey: $nameKey, iconKey: $iconKey, levels: $levels}";
  }
}

Map<String, String> _defaultParameters() => {};

final class AchievementLevel {
  final String achievementID;
  final int level;
  final String nameKey;
  final String descriptionKey;
  final Map<String, String> Function() descriptionParameters;
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
    this.descriptionParameters = _defaultParameters,
    required this.trigger,
    required this.checkCompletion,
    this.progress,
    this.progressText,
    this.progressMax,
  }) : assert(progress == null || progressMax != null),
       assert(progressMax == null || progress != null),
       assert(progressText == null || progress != null);

  bool get canShowProgress => progress != null && progressMax != null;

  @override
  String toString() {
    return "AchievementLevel{achievementID: $achievementID, level: $level, descriptionKey: $descriptionKey, trigger: $trigger, checkCompletion: $checkCompletion, progress: $progress, progressText: $progressText, progressMax: $progressMax}";
  }
}

final class AchievementCompletion implements Syncable {
  final String achievementID;
  final int level;
  final DateTime completedAt;
  @override
  final String id;
  @override
  final DateTime updatedAt;
  @override
  final bool deleted;
  @override
  final String? userId;

  AchievementCompletion({
    required this.achievementID,
    required this.level,
    required this.completedAt,
    String? id,
    DateTime? updatedAt,
    bool? deleted,
    this.userId,
  }) : id = id ?? _uuid.v4(),
       updatedAt = updatedAt ?? completedAt.toUtc(),
       deleted = deleted ?? false;

  factory AchievementCompletion.fromJson(Map<String, dynamic> json) {
    return AchievementCompletion(
      achievementID:
          json['achievement_id'] as String? ?? json['achievementID'] as String,
      level: json['level'] as int,
      completedAt: DateTime.parse(
        json['completed_at'] as String? ??
            json['completedAt'] as String? ??
            DateTime(2000).toIso8601String(),
      ),
      id: json['id'] as String?,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      deleted: json['deleted'] as bool?,
      userId: json['user_id'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'achievement_id': achievementID,
    'level': level,
    'completed_at': completedAt.toUtc().toIso8601String(),
    'id': id,
    'updated_at': updatedAt.toUtc().toIso8601String(),
    'deleted': deleted,
    'user_id': userId,
  };

  @override
  UpdateCompanion<Syncable> toCompanion() {
    return AchievementsCompanion.insert(
      achievementID: Value(achievementID),
      level: level,
      completedAt: completedAt,
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      userId: Value(userId),
    );
  }
}
