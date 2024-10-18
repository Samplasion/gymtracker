import 'package:get/get.dart';
import 'package:gymtracker/controller/serviceable_controller.dart';
import 'package:gymtracker/data/achievements.dart';
import 'package:gymtracker/model/achievements.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/utils/achievements.dart';
import 'package:rxdart/rxdart.dart';

class AchievementsController extends GetxController with ServiceableController {
  BehaviorSubject<List<AchievementCompletion>> get _completions$ =>
      service.completions$;

  Map<Achievement, AchievementCompletion> maybeUnlockAchievements(
      AchievementTrigger trigger) {
    final unlocked = <Achievement, AchievementCompletion>{};

    for (final MapEntry(key: id, value: achievement) in achievements.entries) {
      final completion = _getHighestLevelCompletionFor(achievement.id);
      final nextLevel = completion == null
          ? achievement.levels.first
          : achievement.nextLevel(completion);

      if (nextLevel == null) {
        continue;
      }

      if (nextLevel.trigger != trigger) {
        continue;
      }

      final hasJustUnlocked =
          nextLevel.checkCompletion(nextLevel.progress?.call());

      logger.d((id, nextLevel.level, hasJustUnlocked));

      if (hasJustUnlocked) {
        unlocked[achievement] = AchievementCompletion(
          achievementID: id,
          level: nextLevel.level,
          completedAt: DateTime.now(),
        );
      }
    }

    _markUnlockAchievements(unlocked);
    _showUnlockAchievements(unlocked);

    return unlocked;
  }

  void _markUnlockAchievements(
      Map<Achievement, AchievementCompletion> unlocked) {
    service.insertAchievementCompletions(unlocked.values.toList());
  }

  void _showUnlockAchievements(
      Map<Achievement, AchievementCompletion> unlocked) {
    for (final MapEntry(key: achievement, value: completion)
        in unlocked.entries) {
      logger.i(
          "Unlocked achievement: ${achievement.id} at level ${completion.level}");
      Go.customSnack(AchievementSnackBar(
        achievement: achievement,
        completion: completion,
      ));
    }
  }

  AchievementCompletion? _getHighestLevelCompletionFor(String achievementID) {
    final completions = _completions$.value
        .where((completion) => completion.achievementID == achievementID)
        .toList();
    if (completions.isEmpty) return null;
    completions.sort((a, b) => a.level.compareTo(b.level));
    return completions.last;
  }

  AchievementCompletion? getCompletion(
          Achievement achievement, AchievementLevel level) =>
      _getCompletionInternal(achievement.id, level.level);

  bool isUnlocked(Achievement achievement, AchievementLevel level) =>
      getCompletion(achievement, level) != null;

  AchievementCompletion? _getCompletionInternal(
          String achievementID, int level) =>
      _completions$.value.firstWhereOrNull((completion) =>
          completion.achievementID == achievementID &&
          completion.level == level);

  @override
  void onServiceChange() {}
}

extension AchievementLevelDescription on Achievement {
  bool shouldShowDescriptionFor(int level) {
    if (level == 1) return true;

    final controller = Get.find<AchievementsController>();
    final completion = controller._getHighestLevelCompletionFor(id);
    return completion != null && completion.level + 1 >= level;
  }
}
