import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/database.dart';

class _FailingService extends DatabaseService {
  _FailingService(super.database) : super.withDatabase();

  bool failContinuation = false;
  bool failOriginal = false;

  @override
  Future<void> setHistoryWorkout(Workout workout) async {
    if (failContinuation && workout.completes != null) {
      throw StateError('Continuation insert failed');
    }
    if (failOriginal && workout.completedBy != null) {
      throw StateError('Original update failed');
    }
    await super.setHistoryWorkout(workout);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final collision in [false, true]) {
    test('continuation links atomically (collision: $collision)', () async {
      final db = GTDatabaseImpl.withQueryExecutor(NativeDatabase.memory());
      db.setCurrentUserId('owner');
      final service = _FailingService(db);
      final original = Workout(
        id: 'original',
        name: 'Original',
        exercises: [],
        startingDate: DateTime(2026),
        duration: Duration.zero,
      );
      final existing = Workout(
        id: 'existing',
        name: 'Existing',
        exercises: [],
        startingDate: DateTime(2026),
        duration: Duration.zero,
      );
      await db.insertHistoryWorkout(original);
      if (collision) await db.insertHistoryWorkout(existing);
      service.history$.add([original, if (collision) existing]);
      final container = ProviderContainer(
        overrides: [databaseServiceProvider.overrideWithValue(service)],
      );
      addTearDown(() async {
        container.dispose();
        service.dispose();
        await db.close();
      });
      final controller = container.read(historyControllerProvider);
      final continuation = Workout(
        id: collision ? existing.id : 'continuation',
        name: 'Continuation',
        startingDate: DateTime(2026),
        duration: Duration.zero,
        exercises: [],
        completes: original.id,
      );
      service.failContinuation = true;
      await expectLater(
        controller.addNewWorkout(continuation),
        throwsStateError,
      );
      var saved = await db.getAllHistoryWorkoutsFuture();
      expect(saved.firstWhere((w) => w.id == original.id).completedBy, isNull);
      expect(saved.length, collision ? 2 : 1);

      service.failContinuation = false;
      service.failOriginal = true;
      await expectLater(
        controller.addNewWorkout(continuation),
        throwsStateError,
      );
      saved = await db.getAllHistoryWorkoutsFuture();
      expect(saved.firstWhere((w) => w.id == original.id).completedBy, isNull);
      expect(saved.length, collision ? 2 : 1);

      service.failOriginal = false;
      await controller.addNewWorkout(continuation);
      saved = await db.getAllHistoryWorkoutsFuture();
      final child = saved.singleWhere((w) => w.completes == original.id);
      expect(
        saved.firstWhere((w) => w.id == original.id).completedBy,
        child.id,
      );
      if (collision) expect(child.id, isNot(existing.id));
    });
  }
}
