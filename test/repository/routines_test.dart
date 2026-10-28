import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/model/model.dart';
import 'package:gymtracker/repository/routines.dart';

import '../helpers.dart';

class _DelayedDatabase extends GTDatabaseImpl {
  _DelayedDatabase({this.delayWrite = false})
    : super.withQueryExecutor(NativeDatabase.memory());

  final bool delayWrite;

  final captured = Completer<void>();
  final release = Completer<void>();

  @override
  Future<List<Workout>> getAllRoutinesFuture() async {
    final snapshot = await super.getAllRoutinesFuture();
    if (!delayWrite && !captured.isCompleted) {
      captured.complete();
      await release.future;
    }
    return snapshot;
  }

  @override
  Future<void> updateRoutineSortOrders(
    List<String> ids, {
    required String? owner,
  }) async {
    await super.updateRoutineSortOrders(ids, owner: owner);
    if (delayWrite) {
      captured.complete();
      await release.future;
    }
  }
}

void main() {
  for (final source in <String?>['A', null]) {
    for (final returnsToSource in [false, true]) {
      for (final delayWrite in [false, true]) {
        test(
          'reorder started by $source cannot overwrite B after account switch (returns: $returnsToSource, during write: $delayWrite)',
          () async {
            final db = _DelayedDatabase(delayWrite: delayWrite);
            addTearDown(db.close);
            db.setCurrentUserId(source);
            await db.insertRoutine(
              Workout(id: 'a1', name: 'A1', exercises: []),
            );
            await db.insertRoutine(
              Workout(id: 'a2', name: 'A2', exercises: []),
            );
            db.setCurrentUserId('B');
            await db.insertRoutine(
              Workout(id: 'b1', name: 'B1', exercises: []),
            );
            db.setCurrentUserId(source);
            final reorder = RoutinesRepository(db).reorderFolder(null, 0, 1);
            final expectation = expectLater(reorder, throwsStateError);
            await db.captured.future;
            db.setCurrentUserId('B');
            db.release.complete();
            await expectation;
            expect((await db.getAllRoutinesFuture()).map((r) => r.id), ['b1']);
            db.setCurrentUserId(source);
            expect((await db.getAllRoutinesFuture()).map((r) => r.id), [
              'a1',
              'a2',
            ]);
          },
        );
      }
    }
  }

  for (final owner in <String?>['A', null]) {
    test('root and folder reorder preserve other routines for $owner', () async {
      final db = GTDatabaseImpl.withQueryExecutor(NativeDatabase.memory());
      addTearDown(db.close);
      db.setCurrentUserId(owner);
      const folder = GTRoutineFolder(
        id: 'folder',
        name: 'Folder',
        sortOrder: 0,
        notes: '',
      );
      await db.updateRoutineFolder(folder);
      for (final routine in [
        Workout(
          id: 'root1',
          name: 'Root1',
          exercises: [
            exerciseHelper(
              'exercise',
              'Bench',
              workoutID: 'root1',
            ).copyWith(parentID: 'custom-parent'),
          ],
          infobox: 'Preserve notes',
        ),
        Workout(id: 'root2', name: 'Root2', exercises: []),
        Workout(id: 'folder1', name: 'Folder1', exercises: [], folder: folder),
        Workout(id: 'folder2', name: 'Folder2', exercises: [], folder: folder),
      ]) {
        await db.insertRoutine(routine);
      }
      final exercisesBefore = await db
          .customSelect('SELECT * FROM routine_exercises')
          .get();
      final fieldsBefore = await db
          .customSelect(
            'SELECT id, name, infobox, weight_unit, distance_unit, folder_id, user_id, deleted FROM routines ORDER BY id',
          )
          .get();
      final repository = RoutinesRepository(db);
      await repository.reorderFolder(null, 0, 1);
      var routines = await db.getAllRoutinesFuture();
      expect(routines.where((r) => r.folder == null).map((r) => r.id), [
        'root2',
        'root1',
      ]);
      expect(routines.where((r) => r.folder != null).map((r) => r.id), [
        'folder1',
        'folder2',
      ]);
      await repository.reorderFolder(folder, 0, 1);
      routines = await db.getAllRoutinesFuture();
      expect(routines.where((r) => r.folder == null).map((r) => r.id), [
        'root2',
        'root1',
      ]);
      expect(routines.where((r) => r.folder != null).map((r) => r.id), [
        'folder2',
        'folder1',
      ]);
      expect(routines, hasLength(4));
      final exercisesAfter = await db
          .customSelect('SELECT * FROM routine_exercises')
          .get();
      final fieldsAfter = await db
          .customSelect(
            'SELECT id, name, infobox, weight_unit, distance_unit, folder_id, user_id, deleted FROM routines ORDER BY id',
          )
          .get();
      expect(
        exercisesAfter.map((row) => row.data),
        exercisesBefore.map((row) => row.data),
      );
      expect(
        fieldsAfter.map((row) => row.data),
        fieldsBefore.map((row) => row.data),
      );
    });
  }
}
