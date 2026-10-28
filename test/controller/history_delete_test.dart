import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/database.dart';

class _DeleteService extends DatabaseService {
  _DeleteService(super.db) : super.withDatabase();
  bool failChild = false;
  bool changeOwner = false;

  @override
  Future<void> removeHistoryWorkoutById(String id) async {
    if (id == 'child' && failChild) throw StateError('Delete failed');
    await super.removeHistoryWorkoutById(id);
    if (id == 'child' && changeOwner) db.setCurrentUserId('other');
  }
}

class _Controller extends HistoryController {
  _Controller(super.ref);
  int backups = 0;
  int achievements = 0;
  @override
  void scheduleBackup() => backups++;
  @override
  void unlockAchievements() => achievements++;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late GTDatabaseImpl db;
  late _DeleteService service;
  late ProviderContainer container;
  late _Controller controller;
  Workout workout(String id, {String? completedBy, String? completes}) =>
      Workout(
        id: id,
        name: id,
        exercises: [],
        duration: const Duration(minutes: 10),
        startingDate: DateTime(2026),
        completedBy: completedBy,
        completes: completes,
      );
  late Workout original;

  setUp(() async {
    db = GTDatabaseImpl.withQueryExecutor(NativeDatabase.memory());
    db.setCurrentUserId('owner');
    service = _DeleteService(db);
    container = ProviderContainer(
      overrides: [
        databaseServiceProvider.overrideWithValue(service),
        historyControllerProvider.overrideWith((ref) => _Controller(ref)),
      ],
    );
    controller = container.read(historyControllerProvider) as _Controller;
    original = workout('original', completedBy: 'child');
    await db.insertHistoryWorkout(original);
    await db.insertHistoryWorkout(workout('child', completes: 'original'));
  });
  tearDown(() async {
    container.dispose();
    service.dispose();
    await db.close();
  });

  test(
    'second deletion failure rolls back the original and side effects',
    () async {
      service.failChild = true;
      await expectLater(controller.deleteWorkout(original), throwsStateError);
      final saved = await db.getAllHistoryWorkoutsFuture();
      expect(saved.map((w) => w.id), unorderedEquals(['original', 'child']));
      expect(saved.singleWhere((w) => w.id == 'original').completedBy, 'child');
      expect(controller.backups, 0);
      expect(controller.achievements, 0);
    },
  );

  test(
    'successful deletion removes the pair and runs side effects once',
    () async {
      await controller.deleteWorkout(original);
      expect(await db.getAllHistoryWorkoutsFuture(), isEmpty);
      expect(controller.backups, 1);
      expect(controller.achievements, 1);
    },
  );

  test(
    'account change rolls back both deletions and skips side effects',
    () async {
      service.changeOwner = true;
      await expectLater(controller.deleteWorkout(original), throwsStateError);
      db.setCurrentUserId('owner');
      expect(
        (await db.getAllHistoryWorkoutsFuture()).map((w) => w.id),
        unorderedEquals(['original', 'child']),
      );
      expect(controller.backups, 0);
      expect(controller.achievements, 0);
    },
  );

  test('simple workout deletion preserves unrelated history', () async {
    final simple = workout('simple');
    await db.insertHistoryWorkout(simple);
    await controller.deleteWorkout(simple);
    expect(
      (await db.getAllHistoryWorkoutsFuture()).map((w) => w.id),
      unorderedEquals(['original', 'child']),
    );
    expect(controller.backups, 1);
    expect(controller.achievements, 1);
  });
}
