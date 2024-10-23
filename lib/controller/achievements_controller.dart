import 'package:get/get.dart';
import 'package:gymtracker/controller/serviceable_controller.dart';
import 'package:gymtracker/data/achievements.dart';
import 'package:gymtracker/model/achievements.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/service/test.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/utils/achievements.dart';
import 'package:rxdart/rxdart.dart';

class AchievementsController extends GetxController with ServiceableController {
  BehaviorSubject<List<AchievementCompletion>> get _completions$ =>
      service.completions$;

  Stream<List<AchievementCompletion>> get completionStream =>
      _completions$.stream.map((completions) => completions.toList()
        ..sort((a, b) {
          final date = b.completedAt.compareTo(a.completedAt);
          final level = b.level.compareTo(a.level);
          return date == 0 ? level : date;
        }));

  Map<Achievement, List<AchievementCompletion>> maybeUnlockAchievements(
      AchievementTrigger trigger) {
    // Achievements slow tests down too much
    if (TestService().isTest) return {};

    final unlocked = <Achievement, List<AchievementCompletion>>{};

    for (final MapEntry(key: id, value: achievement) in achievements.entries) {
      var completion = _getHighestLevelCompletionFor(achievement.id);
      AchievementLevel? nextLevel;

      bool isFirstTime = true;

      innerLoop:
      do {
        nextLevel = completion == null
            ? achievement.levels.first
            : achievement.nextLevel(completion);

        if (nextLevel == null) {
          break innerLoop;
        }

        if (nextLevel.trigger != trigger && isFirstTime) {
          break innerLoop;
        }

        final hasJustUnlocked =
            nextLevel.checkCompletion(nextLevel.progress?.call());

        logger.d((id, nextLevel.level, hasJustUnlocked));

        if (hasJustUnlocked) {
          unlocked.putIfAbsent(achievement, () => []);
          final c = AchievementCompletion(
            achievementID: id,
            level: nextLevel.level,
            completedAt: DateTime.now(),
          );
          unlocked[achievement]!.add(c);
          completion = c;
        } else {
          break innerLoop;
        }

        isFirstTime = false;
      } while (true);
    }

    _markUnlockAchievements(unlocked);
    _showUnlockAchievements(unlocked);

    return unlocked;
  }

  void _markUnlockAchievements(
      Map<Achievement, List<AchievementCompletion>> unlocked) {
    service.insertAchievementCompletions(
        unlocked.values.expand((e) => e).toList());
  }

  void _showUnlockAchievements(
      Map<Achievement, List<AchievementCompletion>> unlocked) {
    for (final MapEntry(key: achievement, value: completions)
        in unlocked.entries) {
      for (final completion in completions) {
        logger.i(
            "Unlocked achievement: ${achievement.id} at level ${completion.level}");
        Go.customSnack(AchievementSnackBar(
          achievement: achievement,
          completion: completion,
        ));
      }
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

  Achievement getAchievement(String achievementID) {
    return achievements[achievementID]!;
  }

  AchievementLevel? getLevel(Achievement achievement, int level) {
    return achievement.levels.firstWhereOrNull((l) => l.level == level);
  }

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
