import 'package:gymtracker/model/achievements.dart';

final Map<String, Achievement> achievements = {
  "firstSteps": Achievement(
    id: "firstSteps",
    nameKey: "achievements.firstSteps.title",
    iconKey: "firstSteps",
    levels: [
      AchievementLevel(
        level: 1,
        nameKey: "achievements.firstSteps.title",
        descriptionKey: "achievements.firstSteps.description.1",
        trigger: AchievementTrigger.workout,
        checkCompletion: () => true,
      ),
      AchievementLevel(
        level: 2,
        nameKey: "achievements.firstSteps.title",
        descriptionKey: "achievements.firstSteps.description.2",
        trigger: AchievementTrigger.food,
        checkCompletion: () => true,
      ),
      AchievementLevel(
        level: 3,
        nameKey: "achievements.firstSteps.title",
        descriptionKey: "achievements.firstSteps.description.3",
        trigger: AchievementTrigger.weight,
        checkCompletion: () => true,
      ),
    ],
  ),
};
