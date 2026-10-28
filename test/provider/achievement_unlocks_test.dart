import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/controller/achievements_controller.dart';
import 'package:gymtracker/data/achievements.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/model/achievements.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/provider/routines.dart';
import 'package:gymtracker/provider/training_data.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/service/online.dart';

class _GuestOnline extends Online {
  _GuestOnline() : super(service: TestOnlineServiceImpl());
  @override
  OnlineAccount? build() => null;
  @override
  bool get isSyncing => false;
}

void main() {
  test(
    'committed workouts, routines and folders unlock without manual triggers',
    () async {
      final db = GTDatabaseImpl.withQueryExecutor(NativeDatabase.memory());
      await db.insertHistoryWorkout(
        Workout(
          name: 'Existing',
          exercises: [],
          startingDate: DateTime(2026),
          duration: const Duration(minutes: 10),
        ),
      );
      for (var i = 0; i < 2; i++) {
        await db.insertRoutine(Workout(name: 'Existing $i', exercises: []));
      }
      final service = DatabaseService.withDatabase(db);
      final container = ProviderContainer(
        overrides: [
          databaseServiceProvider.overrideWithValue(service),
          onlineProvider.overrideWith(_GuestOnline.new),
          achievementCatalogProvider.overrideWith(
            (ref) => AchievementRules(
              history: () => ref.read(historyWorkoutsProvider).value ?? [],
              routines: () => ref.read(routinesStreamProvider).value ?? [],
              hasFolders: () =>
                  ref.read(foldersStreamProvider).value?.isNotEmpty ?? false,
            ).catalog,
          ),
        ],
      );
      final completions = db.watchAchievementCompletions().listen(
        service.completions$.add,
      );
      // Match the application lifecycle, without any achievement screen open.
      final owner = container.listen(achievementsControllerProvider, (_, _) {});
      final controller = owner.read();
      final presented = <AchievementCompletion>[];
      final notifications = controller.unlocked.listen((unlocked) {
        presented.addAll(unlocked.values.expand((values) => values));
      });
      addTearDown(() async {
        await notifications.cancel();
        await completions.cancel();
        owner.close();
        container.dispose();
        service.dispose();
      });

      await Future.wait([
        container.read(historyWorkoutsProvider.future),
        container.read(routinesStreamProvider.future),
        container.read(foldersStreamProvider.future),
      ]);
      expect(await db.watchAchievementCompletions().first, isEmpty);

      Future<List<AchievementCompletion>> unlocked(String id) => db
          .watchAchievementCompletions()
          .firstWhere((rows) => rows.any((row) => row.achievementID == id))
          .timeout(const Duration(seconds: 5));

      await db.insertHistoryWorkout(
        Workout(
          name: 'Completed',
          exercises: [],
          startingDate: DateTime.now(),
          duration: const Duration(minutes: 10),
        ),
      );
      await unlocked('firstSteps');

      await db.insertRoutine(Workout(name: 'Third routine', exercises: []));
      await unlocked('programPlanner');

      await db.insertRoutineFolder(GTRoutineFolder.generate(name: 'Folder'));
      final rows = await unlocked('perfectPlanner');
      expect(
        rows.map((row) => row.achievementID),
        containsAll(['firstSteps', 'programPlanner', 'perfectPlanner']),
      );
      await Future<void>.delayed(Duration.zero);
      expect(
        presented.map((row) => row.achievementID),
        containsAll(['firstSteps', 'programPlanner', 'perfectPlanner']),
      );
    },
  );
}
