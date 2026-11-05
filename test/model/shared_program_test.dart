import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/model/model.dart';
import 'package:gymtracker/model/shared_program.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/service/shared_program.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../helpers.dart';

class _Service extends SharedProgramService {
  final SharedProgramV1 program;
  bool revoked = false;
  int reads = 0;
  _Service(super.client, super.db, this.program);
  @override
  Future<SharedProgramV1> read(String token) async {
    reads++;
    if (revoked) throw const FormatException('not_found');
    return program;
  }
}

class _FailingDatabase extends GTDatabaseImpl {
  _FailingDatabase() : super.withQueryExecutor(NativeDatabase.memory());
  int writes = 0;
  @override
  Future<void> insertRoutine(Workout routine) async {
    if (++writes == 2) throw StateError('test failure');
    await super.insertRoutine(routine);
  }
}

SharedProgramV1 example() {
  final custom = exerciseHelper(
    'source-custom',
    'Custom press',
    sets: [
      GTSet(
        id: 'source-set',
        kind: GTSetKind.normal,
        parameters: GTSetParameters.repsWeight,
        reps: 8,
        weight: 40,
        done: true,
      ),
    ],
  ).copyWith(parentID: 'source-definition', notes: 'Exercise notes');
  final folder = GTRoutineFolder.generate(
    name: 'Plan',
  ).copyWith(notes: 'Folder notes');
  final superSet = Superset(
    id: 'source-group',
    exercises: [custom],
    restTime: const Duration(seconds: 60),
    workoutID: 'source-routine',
    notes: 'Group notes',
  );
  return SharedProgramV1.fromWorkouts('Plan', [
    Workout(
      id: 'source-routine',
      name: 'Day 1',
      infobox: 'Day notes',
      exercises: [superSet],
      folder: folder,
    ),
    Workout(
      id: 'source-day2',
      name: 'Day 2',
      exercises: [custom],
      folder: folder,
    ),
  ], folder: folder);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'roundtrip preserves notes and supersets and regenerates all identities',
    () {
      final program = example();
      final a = program.materialize();
      final b = program.materialize();
      expect(a.folder!.notes, 'Folder notes');
      expect(a.routines.map((r) => r.name), ['Day 1', 'Day 2']);
      final group = a.routines.first.exercises.single.asSuperset;
      final exercise = group.exercises.single;
      expect(group.notes, 'Group notes');
      expect(exercise.notes, 'Exercise notes');
      expect(exercise.supersetID, group.id);
      expect(exercise.workoutID, a.routines.first.id);
      expect(exercise.parentID, a.customExercises.single.id);
      expect(
        a.routines.last.exercises.single.asExercise.parentID,
        a.customExercises.single.id,
      );
      expect(exercise.sets.single.done, false);
      expect(exercise.sets.single.id, isNot('source-set'));
      expect(a.routines.first.id, isNot(b.routines.first.id));
      expect(a.folder!.id, isNot(b.folder!.id));
    },
  );
  test('malformed prescriptions are reported as invalid programs', () {
    expect(
      () => SharedProgramV1.fromJson({
        'version': 1,
        'title': 'Invalid',
        'routines': [{}],
      }),
      throwsFormatException,
    );
  });
  test('future versions are rejected', () {
    expect(
      () => SharedProgramV1.fromJson({'version': 2}),
      throwsFormatException,
    );
  });
  test(
    'complete program imports atomically with custom definitions and folder',
    () async {
      final db = GTDatabaseImpl.withQueryExecutor(NativeDatabase.memory());
      addTearDown(db.close);
      db.setCurrentUserId('A');
      final database = DatabaseService.withDatabase(db);
      final client = SupabaseClient('http://localhost', 'test');
      addTearDown(client.dispose);
      final service = _Service(client, db, example());
      await service.import('token', database);
      final rows = await db.getAllRoutinesFuture();
      expect(rows.map((r) => r.name), ['Day 1', 'Day 2']);
      expect(rows.first.folder!.id, rows.last.folder!.id);
      expect(await db.getAllCustomExercises().first, hasLength(1));
      expect(service.reads, 1);
      service.revoked = true;
      await expectLater(
        service.import('token', database),
        throwsFormatException,
      );
      expect(await db.getAllRoutinesFuture(), hasLength(2));
    },
  );
  test(
    'failed second day rolls back folder, custom definitions and first day',
    () async {
      final db = _FailingDatabase();
      addTearDown(db.close);
      db.setCurrentUserId('A');
      final database = DatabaseService.withDatabase(db);
      final client = SupabaseClient('http://localhost', 'test');
      addTearDown(client.dispose);
      await expectLater(
        _Service(client, db, example()).import('token', database),
        throwsStateError,
      );
      expect(await db.getAllRoutinesFuture(), isEmpty);
      expect(await db.select(db.routineFolders).get(), isEmpty);
      expect(await db.getAllCustomExercises().first, isEmpty);
    },
  );
}
