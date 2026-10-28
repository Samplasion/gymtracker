import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/data/achievements.dart';
import 'package:gymtracker/model/achievements.dart';
import 'package:mocktail/mocktail.dart';

import 'fixtures.dart';
import 'harness.dart';
import 'scenarios.dart';

void expectRule(
  AchievementScenario scenario,
  AchievementFixture fixture,
  bool earned, {
  double? progress,
}) {
  final level = fixture.rules.catalog[scenario.id]!.levels[scenario.level - 1];
  final actualProgress = level.progress?.call();
  if (progress != null) expect(actualProgress, closeTo(progress, 0.000001));
  expect(level.checkCompletion(actualProgress), earned);
}

void main() {
  setUpAll(() => registerFallbackValue(<AchievementCompletion>[]));
  final scenarios = achievementScenarios();

  test('every catalog achievement and level has exactly one scenario', () {
    final expected = [
      for (final achievement in AchievementRules().catalog.values)
        for (final level in achievement.levels)
          '${achievement.id}/${level.level}',
    ];
    final actual = scenarios.map((scenario) => scenario.key).toList();
    expect(actual.toSet().length, actual.length, reason: 'Duplicate scenarios');
    expect(
      actual,
      unorderedEquals(expected),
      reason:
          'Add a scenario for each new achievement/level; remove obsolete scenarios.',
    );
  });

  for (final scenario in scenarios) {
    group(scenario.key, () {
      AchievementHarness harness(
        AchievementFixture fixture, {
        int? completedLevel,
      }) {
        final result = AchievementHarness(
          scenario,
          fixture,
          completedLevel: completedLevel,
        );
        addTearDown(result.dispose);
        return result;
      }

      test('metadata matches the level contract', () {
        final achievement = scenario.earned.rules.catalog[scenario.id]!;
        final level = achievement.levels[scenario.level - 1];
        expect(achievement.id, scenario.id);
        expect(level.achievementID, scenario.id);
        expect(level.level, scenario.level);
        expect(level.trigger, scenario.trigger);
        expect(level.progressMax?.call(), scenario.progressMax);
      });

      test('empty data does not meet the rule', () {
        expectRule(scenario, AchievementFixture(), false);
      });

      test('insufficient data neither unlocks nor persists', () {
        expectRule(
          scenario,
          scenario.locked,
          false,
          progress: scenario.lockedProgress,
        );
        final run = harness(scenario.locked);
        expect(
          run.controller.maybeUnlockAchievements(scenario.trigger),
          isEmpty,
        );
        expect(run.writes, isEmpty);
        expect(run.presented, isEmpty);
      });

      test('qualifying data meets the real rule and expected progress', () {
        expectRule(
          scenario,
          scenario.earned,
          true,
          progress: scenario.earnedProgress,
        );
      });

      test('other triggers cannot unlock the next level', () {
        final run = harness(scenario.earned);
        for (final trigger in AchievementTrigger.values.where(
          (value) => value != scenario.trigger,
        )) {
          expect(
            run.controller.maybeUnlockAchievements(trigger),
            isEmpty,
            reason: '$trigger',
          );
        }
        expect(run.writes, isEmpty);
        expect(run.presented, isEmpty);
      });

      test(
        'correct trigger persists and presents once, even before stream delivery',
        () {
          final run = harness(scenario.earned);
          final unlocked = run.controller.maybeUnlockAchievements(
            scenario.trigger,
          );
          expect(unlocked.keys, [run.achievement]);
          final completion = unlocked[run.achievement]!.single;
          expect(completion.achievementID, scenario.id);
          expect(completion.level, scenario.level);
          expect(completion.userId, 'test-owner');
          expect(run.writes, [completion]);
          expect(run.presented, [completion]);
          expect(
            run.controller.maybeUnlockAchievements(scenario.trigger),
            isEmpty,
          );

          run.publishWrites();
          expect(
            run.controller.isUnlocked(
              run.achievement,
              run.achievement.levels[scenario.level - 1],
            ),
            isTrue,
          );
          expect(
            run.controller.maybeUnlockAchievements(scenario.trigger),
            isEmpty,
          );
          expect(run.writes, [completion]);
          expect(run.presented, [completion]);
        },
      );

      test('already earned levels are never awarded again', () {
        final run = harness(
          scenario.earned,
          completedLevel:
              scenario.earned.rules.catalog[scenario.id]!.levels.length,
        );
        expect(
          run.controller.maybeUnlockAchievements(scenario.trigger),
          isEmpty,
        );
        expect(run.writes, isEmpty);
        expect(run.presented, isEmpty);
      });

      for (final entry in scenario.alsoLocked.entries) {
        test(entry.key, () => expectRule(scenario, entry.value, false));
      }
      for (final entry in scenario.alsoEarned.entries) {
        test(entry.key, () => expectRule(scenario, entry.value, true));
      }
    });
  }
}
