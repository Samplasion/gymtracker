import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/model/model.dart';
import '../helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final owner in [null, 'registered-without-trainer']) {
    test(
      'personal routines, folders, exercises and history stay editable for $owner',
      () async {
        final db = GTDatabaseImpl.withQueryExecutor(NativeDatabase.memory());
        addTearDown(db.close);
        db.setCurrentUserId(owner);
        final custom = exerciseHelper('custom', 'Custom');
        await db.insertCustomExercise(custom);
        await db.updateCustomExercise(custom.copyWith(name: 'Edited custom'));
        final folder = GTRoutineFolder.generate(name: 'Folder');
        await db.insertRoutineFolder(folder);
        final routine = Workout(
          id: 'r',
          name: 'Routine',
          exercises: [custom.makeChild().copyWith(workoutID: 'r')],
          folder: folder,
        );
        await db.insertRoutine(routine);
        await db.updateRoutine(routine.copyWith(name: 'Edited routine'));
        final session = Workout(
          id: 'w',
          name: 'Session',
          exercises: [],
          parentID: 'r',
          duration: const Duration(minutes: 20),
          startingDate: DateTime.utc(2026),
        );
        await db.insertHistoryWorkout(session);
        await db.updateHistoryWorkout(
          session.copyWith(parentID: null, startingDate: DateTime.utc(2026, 2)),
        );
        expect((await db.getHistoryWorkout('w')).parentID, isNull);
        expect(
          (await db.getHistoryWorkout(
            'w',
          )).startingDate!.isAtSameMomentAs(DateTime.utc(2026, 2)),
          true,
        );
        final imported = session.toRoutine();
        await db.insertRoutine(imported);
        expect((await db.getAllRoutinesFuture()), hasLength(2));
        await db.deleteRoutineFolder(folder.id);
        await db.deleteRoutine('r');
        await db.deleteCustomExercise(custom.id);
        expect(await db.getAllCustomExercises().first, isEmpty);
        expect((await db.getAllHistoryWorkoutsFuture()), hasLength(1));
        expect(db.cachedTrainerState.controls, isEmpty);
      },
    );
  }
}
