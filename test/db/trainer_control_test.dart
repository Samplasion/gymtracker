import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/model/trainer.dart';
import 'package:gymtracker/model/workout.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late GTDatabaseImpl db;
  setUp(() {
    db = GTDatabaseImpl.withQueryExecutor(NativeDatabase.memory());
    db.setCurrentUserId('A');
  });
  tearDown(() => db.close());
  test('guest and missing snapshots never crash a control check', () async {
    db.setCurrentUserId(null);
    expect(db.cachedTrainerState.controls, isEmpty);
    expect((await db.trainerState()).controls, isEmpty);
    expect(await db.isTrainerRoutine('anything'), false);
  });
  test(
    'active controls protect routine writes; termination keeps contents and releases writes',
    () async {
      final routine = Workout(id: 'r', name: 'Assigned', exercises: []);
      await db.insertRoutine(routine);
      await db.cacheTrainerState('A', {
        'link': {'id': 'link'},
        'controls': [
          {'routine_id': 'r'},
        ],
      });
      expect(db.cachedTrainerState.controls, contains('r'));
      await expectLater(
        db.updateRoutine(routine.copyWith(name: 'Changed')),
        throwsA(isA<TrainerControlledException>()),
      );
      await expectLater(
        db.deleteRoutine('r'),
        throwsA(isA<TrainerControlledException>()),
      );
      await db.cacheTrainerState('A', {'link': null, 'controls': []});
      await db.updateRoutine(routine.copyWith(name: 'Personal'));
      expect((await db.getRoutine('r')).name, 'Personal');
    },
  );
  test('account switch never exposes previous owner controls', () async {
    await db.cacheTrainerState('A', {
      'controls': [
        {'routine_id': 'r'},
      ],
    });
    db.setCurrentUserId('B');
    expect(db.cachedTrainerState.controls, isEmpty);
    expect((await db.trainerState()).controls, isEmpty);
    db.setCurrentUserId('A');
    expect((await db.trainerState()).controls, contains('r'));
    await db.cacheTrainerState('B', {'controls': []});
    expect((await db.trainerState()).controls, contains('r'));
  });
  test(
    'controlled workout date and parent cannot be edited but its content can',
    () async {
      await db.insertRoutine(Workout(id: 'r', name: 'Routine', exercises: []));
      final w = Workout(
        id: 'w',
        name: 'Session',
        exercises: [],
        parentID: 'r',
        duration: const Duration(minutes: 10),
        startingDate: DateTime.utc(2026),
      );
      await db.insertHistoryWorkout(w);
      await db.cacheTrainerState('A', {
        'controls': [
          {'routine_id': 'r'},
        ],
      });
      await db.updateHistoryWorkout(w.copyWith(name: 'Adapted'));
      await expectLater(
        db.updateHistoryWorkout(w.copyWith(parentID: null)),
        throwsA(isA<TrainerControlledException>()),
      );
      await expectLater(
        db.updateHistoryWorkout(
          w.copyWith(startingDate: DateTime.utc(2026, 2)),
        ),
        throwsA(isA<TrainerControlledException>()),
      );
      await db.cacheTrainerState('A', {'controls': []});
      await db.updateHistoryWorkout(
        w.copyWith(parentID: null, startingDate: DateTime.utc(2026, 2)),
      );
      expect((await db.getHistoryWorkout('w')).parentID, isNull);
    },
  );
  test(
    'imported copies do not retain parent or continuation relationships',
    () {
      final source = Workout(
        name: 'Source',
        exercises: [],
        parentID: 'old',
        completes: 'previous',
        duration: const Duration(minutes: 1),
      );
      final copy = source.toRoutine();
      expect(copy.id, isNot(source.id));
      expect(copy.parentID, isNull);
      expect(copy.completes, isNull);
    },
  );
}
