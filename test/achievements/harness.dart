import 'package:gymtracker/controller/achievements_controller.dart';
import 'package:gymtracker/model/achievements.dart';
import 'package:gymtracker/provider/events.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/service/online.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxdart/rxdart.dart';

import 'fixtures.dart';
import 'scenarios.dart';

class _Database extends Mock implements DatabaseService {}

class _Online extends Mock implements OnlineService {}

/// Runs the real controller with only its persistence/online edges replaced.
/// Writes remain pending until [publishWrites], exercising both deduplication
/// before the database stream catches up and after it delivers the rows.
class AchievementHarness {
  AchievementHarness(
    AchievementScenario scenario,
    AchievementFixture fixture, {
    int? completedLevel,
  }) {
    achievement = fixture.rules.catalog[scenario.id]!;
    final completed = completedLevel ?? scenario.level - 1;
    initial = [
      for (var level = 1; level <= completed; level++)
        AchievementCompletion(
          id: '${scenario.id}-$level',
          achievementID: scenario.id,
          level: level,
          completedAt: fixture.now,
          userId: 'test-owner',
        ),
    ];
    completions = BehaviorSubject.seeded(initial);
    final database = _Database();
    final online = _Online();
    when(
      () => online.account,
    ).thenReturn(OnlineAccount(id: 'test-owner', name: 'Test'));
    when(() => database.completions$).thenAnswer((_) => completions);
    when(() => database.insertAchievementCompletions(any())).thenAnswer((
      invocation,
    ) async {
      writes.addAll(
        invocation.positionalArguments.single as List<AchievementCompletion>,
      );
    });
    controller = AchievementsController(
      online,
      service: database,
      events: events,
      isSyncing: () => false,
      catalog: {achievement.id: achievement},
      unlocksEnabled: () => true,
      present: (unlocked) =>
          presented.addAll(unlocked.values.expand((rows) => rows)),
    );
  }

  late final Achievement achievement;
  late final AchievementsController controller;
  late final BehaviorSubject<List<AchievementCompletion>> completions;
  late final List<AchievementCompletion> initial;
  final events = EventBus();
  final writes = <AchievementCompletion>[];
  final presented = <AchievementCompletion>[];

  void publishWrites() => completions.add([...initial, ...writes]);

  Future<void> dispose() async {
    controller.dispose();
    events.dispose();
    await completions.close();
  }
}
