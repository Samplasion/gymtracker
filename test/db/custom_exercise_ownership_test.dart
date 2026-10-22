import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/db/database.dart';

import '../helpers.dart';

void main() {
  late GTDatabaseImpl db;
  setUp(() => db = GTDatabaseImpl.withQueryExecutor(NativeDatabase.memory()));
  tearDown(() => db.close());

  test(
    'custom exercise updates isolate guest and account rows sharing an ID',
    () async {
      for (final owner in [null, 'A', 'B']) {
        db.setCurrentUserId(owner);
        await db.insertCustomExercise(exerciseHelper('shared', 'Initial'));
      }
      for (final owner in [null, 'A', 'B']) {
        db.setCurrentUserId(owner);
        await db.updateCustomExercise(
          exerciseHelper('shared', owner ?? 'Guest'),
        );
      }
      final rows = await db.select(db.customExercises).get();
      expect(
        {for (final row in rows) row.userId: row.name},
        {null: 'Guest', 'A': 'A', 'B': 'B'},
      );
    },
  );

  test(
    'updating a missing owned exercise cannot change another account',
    () async {
      db.setCurrentUserId('A');
      await db.insertCustomExercise(exerciseHelper('shared', 'Original'));
      db.setCurrentUserId('B');
      await db.updateCustomExercise(exerciseHelper('shared', 'Changed'));
      expect(await db.getAllCustomExercises().first, isEmpty);
      db.setCurrentUserId('A');
      expect((await db.getAllCustomExercises().first).single.name, 'Original');
    },
  );
}
