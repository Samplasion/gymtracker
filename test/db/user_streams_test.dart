import 'dart:async';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/model/workout.dart';

void main() {
  late GTDatabaseImpl db;

  setUp(() async {
    db = GTDatabaseImpl.withQueryExecutor(NativeDatabase.memory());
    await db.delete(db.nutritionGoals).go();
    for (final user in ['A', 'B']) {
      db.setCurrentUserId(user);
      await db.insertRoutine(Workout(id: user, name: user, exercises: []));
      await db
          .into(db.nutritionGoals)
          .insert(
            NutritionGoalsCompanion(
              id: Value(user),
              userId: Value(user),
              referenceDate: Value(DateTime(2026)),
              calories: Value(user == 'A' ? 1000.0 : 3000.0),
              fat: const Value(50),
              carbs: const Value(250),
              protein: const Value(100),
            ),
          );
    }
    db.setCurrentUserId('A');
  });

  tearDown(() => db.close());

  test('open streams follow A, guest, B and A without resubscribing', () async {
    final routines = StreamIterator(db.getAllRoutines());
    final goals = StreamIterator(db.watchNutritionGoals());
    addTearDown(routines.cancel);
    addTearDown(goals.cancel);

    for (final user in ['A', null, 'B', 'A']) {
      db.setCurrentUserId(user);
      await routines.moveNext().timeout(const Duration(seconds: 2));
      await goals.moveNext().timeout(const Duration(seconds: 2));
      expect(routines.current.map((r) => r.id), user == null ? [] : [user]);
      expect(
        goals.current.map((g) => g.value.dailyCalories),
        user == null ? [] : [user == 'A' ? 1000.0 : 3000.0],
      );
    }
  });

  test('rapid identity changes do not emit another account data', () async {
    final routines = StreamIterator(db.getAllRoutines());
    addTearDown(routines.cancel);
    await routines.moveNext();
    db.setCurrentUserId(null);
    db.setCurrentUserId('B');
    await routines.moveNext().timeout(const Duration(seconds: 2));
    expect(routines.current.map((r) => r.id), ['B']);

    // Changes to the old account must not cause its data to reappear.
    await (db.update(db.routines)..where((r) => r.userId.equals('A'))).write(
      const RoutinesCompanion(name: Value('Changed A')),
    );
    await routines.moveNext().timeout(const Duration(seconds: 2));
    expect(routines.current.map((r) => r.id), ['B']);
  });
}
