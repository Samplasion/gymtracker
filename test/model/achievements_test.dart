import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/model/achievements.dart';

void main() {
  group("Achievements model tests", () {
    final level1 = AchievementLevel(
      achievementID: "test_ach",
      level: 1,
      nameKey: "name_1",
      descriptionKey: "desc_1",
      trigger: AchievementTrigger.workout,
      checkCompletion: (progress) => progress != null && progress >= 1.0,
      progress: () => 1.0,
      progressMax: () => 1.0,
    );

    final level2 = AchievementLevel(
      achievementID: "test_ach",
      level: 2,
      nameKey: "name_2",
      descriptionKey: "desc_2",
      trigger: AchievementTrigger.workout,
      checkCompletion: (progress) => progress != null && progress >= 5.0,
      progress: () => 5.0,
      progressMax: () => 5.0,
    );

    final achievement = Achievement(
      id: "test_ach",
      nameKey: "title",
      iconKey: "icon",
      levels: [level1, level2],
    );

    test("nextLevel", () {
      final comp1 = AchievementCompletion(
        achievementID: "test_ach",
        level: 1,
        completedAt: DateTime.utc(2026, 1, 1),
        id: "completion_1",
        updatedAt: DateTime.utc(2026, 1, 1),
        deleted: false,
        userId: "user_1",
      );
      final comp2 = AchievementCompletion(
        achievementID: "test_ach",
        level: 2,
        completedAt: DateTime.utc(2026, 1, 2),
        id: "completion_2",
        updatedAt: DateTime.utc(2026, 1, 2),
        deleted: false,
        userId: "user_1",
      );

      expect(achievement.nextLevel(comp1), level2);
      expect(achievement.nextLevel(comp2), null);

      final compDiff = AchievementCompletion(
        achievementID: "different_ach",
        level: 1,
        completedAt: DateTime.utc(2026, 1, 3),
        id: "completion_3",
        updatedAt: DateTime.utc(2026, 1, 3),
        deleted: false,
        userId: "user_1",
      );
      expect(() => achievement.nextLevel(compDiff), throwsArgumentError);
    });

    test("isCompleted", () {
      final comp1 = AchievementCompletion(
        achievementID: "test_ach",
        level: 1,
        completedAt: DateTime.utc(2026, 1, 1),
        id: "completion_4",
        updatedAt: DateTime.utc(2026, 1, 1),
        deleted: false,
        userId: "user_1",
      );
      final comp2 = AchievementCompletion(
        achievementID: "test_ach",
        level: 2,
        completedAt: DateTime.utc(2026, 1, 2),
        id: "completion_5",
        updatedAt: DateTime.utc(2026, 1, 2),
        deleted: false,
        userId: "user_1",
      );

      expect(achievement.isCompleted(comp1), false);
      expect(achievement.isCompleted(comp2), true);
    });

    test("getLevel", () {
      final comp1 = AchievementCompletion(
        achievementID: "test_ach",
        level: 1,
        completedAt: DateTime.utc(2026, 1, 1),
        id: "completion_6",
        updatedAt: DateTime.utc(2026, 1, 1),
        deleted: false,
        userId: "user_1",
      );
      final comp2 = AchievementCompletion(
        achievementID: "test_ach",
        level: 2,
        completedAt: DateTime.utc(2026, 1, 2),
        id: "completion_7",
        updatedAt: DateTime.utc(2026, 1, 2),
        deleted: false,
        userId: "user_1",
      );

      expect(achievement.getLevel(comp1), level1);
      expect(achievement.getLevel(comp2), level2);
    });

    test("AchievementCompletion serialization", () {
      final comp = AchievementCompletion(
        achievementID: "ach_id",
        level: 3,
        completedAt: DateTime.utc(2026, 1, 1, 12, 0, 0),
        id: "completion_8",
        updatedAt: DateTime.utc(2026, 1, 1, 12, 0, 0),
        deleted: false,
        userId: "user_1",
      );

      final json = comp.toJson();
      expect(json["achievement_id"], "ach_id");
      expect(json["level"], 3);
      expect(json["completed_at"], "2026-01-01T12:00:00.000Z");
      expect(json["id"], "completion_8");
      expect(json["updated_at"], "2026-01-01T12:00:00.000Z");
      expect(json["deleted"], false);
      expect(json["user_id"], "user_1");

      final deserialized = AchievementCompletion.fromJson(json);
      expect(deserialized.achievementID, "ach_id");
      expect(deserialized.level, 3);
      expect(
        deserialized.completedAt.toIso8601String(),
        "2026-01-01T12:00:00.000Z",
      );
      expect(deserialized.id, "completion_8");
      expect(
        deserialized.updatedAt.toIso8601String(),
        "2026-01-01T12:00:00.000Z",
      );
      expect(deserialized.deleted, false);
      expect(deserialized.userId, "user_1");
    });
  });
}
