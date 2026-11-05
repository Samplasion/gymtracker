import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/controller/achievements_controller.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/model/achievements.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/provider/achievement_state.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/service/online.dart';

class _Session extends TestOnlineServiceImpl {
  OnlineAccount? current = OnlineAccount(id: 'A', name: 'A');
  @override
  OnlineAccount? get account => current;
}

class _Online extends Online {
  _Online(_Session service) : super(service: service);
  @override
  OnlineAccount? build() => onlineService.account;
  @override
  bool get isSyncing => false;
}

void main() {
  test(
    'logout never awards guest achievements from the previous account',
    () async {
      final db = GTDatabaseImpl.withQueryExecutor(NativeDatabase.memory());
      db.setCurrentUserId('A');
      for (var i = 0; i < 3; i++) {
        await db.insertRoutine(
          Workout(name: 'Account routine $i', exercises: []),
        );
      }
      await db.insertRoutineFolder(
        GTRoutineFolder.generate(name: 'Account folder'),
      );
      final service = DatabaseService.withDatabase(db);
      final session = _Session();
      final container = ProviderContainer(
        overrides: [
          databaseServiceProvider.overrideWithValue(service),
          onlineProvider.overrideWith(() => _Online(session)),
        ],
      );
      final owner = container.listen(achievementsControllerProvider, (_, _) {});
      final controller = owner.read();
      final presented = <AchievementCompletion>[];
      final events = controller.unlocked.listen(
        (values) => presented.addAll(values.values.expand((rows) => rows)),
      );
      addTearDown(() async {
        await events.cancel();
        owner.close();
        container.dispose();
        service.dispose();
      });
      await container.read(achievementSnapshotProvider.future);
      expect(await db.watchAchievementCompletions().first, isEmpty);

      // Auth finishes logout before the database and its streams switch owners.
      session.current = null;
      expect(
        controller.maybeUnlockAchievements(AchievementTrigger.routines),
        isEmpty,
      );
      expect(await db.watchAchievementCompletions().first, isEmpty);

      final guestReady = Completer<void>();
      final snapshots = container.listen(achievementSnapshotProvider, (
        _,
        next,
      ) {
        if (next.asData?.value.owner == null &&
            next.hasValue &&
            !guestReady.isCompleted) {
          guestReady.complete();
        }
      });
      addTearDown(snapshots.close);
      await service.setCurrentUserId(null);
      await guestReady.future.timeout(const Duration(seconds: 5));
      await Future<void>.delayed(Duration.zero);
      expect(await db.watchAchievementCompletions().first, isEmpty);
      expect(presented, isEmpty);
      expect(
        container.read(achievementSnapshotProvider).requireValue.routines,
        isEmpty,
      );
      expect(
        container.read(achievementSnapshotProvider).requireValue.folders,
        isEmpty,
      );

      // Genuine guest activity still works immediately, without a timed cooldown.
      for (var i = 0; i < 3; i++) {
        await db.insertRoutine(
          Workout(name: 'Guest routine $i', exercises: []),
        );
      }
      final guestCompletions = await db
          .watchAchievementCompletions()
          .firstWhere(
            (rows) => rows.any((row) => row.achievementID == 'programPlanner'),
          )
          .timeout(const Duration(seconds: 5));
      expect(
        guestCompletions.every((completion) => completion.userId == null),
        isTrue,
      );
      expect(
        guestCompletions.any(
          (completion) => completion.achievementID == 'perfectPlanner',
        ),
        isFalse,
      );
      db.setCurrentUserId('A');
      expect(await db.watchAchievementCompletions().first, isEmpty);
    },
  );
}
