import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/model/model.dart' as model;
import '../helpers.dart';

class _SwitchingDatabase extends GTDatabaseImpl {
  _SwitchingDatabase() : super.withQueryExecutor(NativeDatabase.memory());
  bool changeDuringBulk = false;
  @override
  String? get currentUserId {
    final owner = super.currentUserId;
    if (changeDuringBulk) {
      changeDuringBulk = false;
      setCurrentUserId('B');
    }
    return owner;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'bulk routine save keeps the captured owner after an account switch',
    () async {
      final db = _SwitchingDatabase();
      addTearDown(db.close);
      final a = model.Workout(
        id: 'a',
        name: 'A routine',
        exercises: [
          exerciseHelper(
            'custom-a',
            'A exercise',
          ).makeChild().copyWith(id: 'a-ex', workoutID: 'a'),
        ],
      );
      final b = model.Workout(
        id: 'b',
        name: 'B routine',
        exercises: [
          exerciseHelper(
            'custom-b',
            'B exercise',
          ).makeChild().copyWith(id: 'b-ex', workoutID: 'b'),
        ],
      );
      db.setCurrentUserId('A');
      await db.insertRoutine(a);
      db.setCurrentUserId('B');
      await db.insertRoutine(b);
      expect((await db.getAllRoutinesFuture()).single.exercises, hasLength(1));
      db.setCurrentUserId('A');
      db.changeDuringBulk = true;
      await db.writeAllRoutines([a]);
      expect(db.currentUserId, 'B');
      final current = await db.getAllRoutinesFuture();
      expect(current.single.id, 'b');
      expect(current.single.exercises.single.id, 'b-ex');
      final rows = await db.select(db.routineExercises).get();
      expect(rows.any((row) => row.userId == 'B' && row.id == 'a-ex'), isFalse);
      db.setCurrentUserId('A');
      expect(
        (await db.getAllRoutinesFuture()).single.exercises.single.id,
        'a-ex',
      );
    },
  );
}
