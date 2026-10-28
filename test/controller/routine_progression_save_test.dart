import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/progression.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/database.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers.dart';
import '../test_helpers/data_controllers.dart';
import '../test_helpers/mock_services.dart';

const _goal = ExerciseProgression(
  mode: ProgressionMode.doubleProgression,
  minReps: 8,
  maxReps: 12,
  repsPerStep: 1,
  setCount: 1,
  startingWeight: 40,
  weightPerStep: 2,
  weightPerCycle: 2,
  targetReps: [8],
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(MockServices.setup);
  tearDown(MockServices.tearDown);

  for (final reachedGoal in [true, false]) {
    test('routine edits survive a stale cache when progression goal is '
        '${reachedGoal ? 'reached' : 'unreached'}', () async {
      final db = MockServices.database;
      final planned = exerciseHelper(
        'planned',
        'Bench',
        workoutID: 'routine',
        sets: [
          GTSet(
            kind: GTSetKind.normal,
            parameters: GTSetParameters.repsWeight,
            reps: 8,
            weight: 40,
          ),
        ],
      ).copyWith(progression: _goal, parentID: 'custom-bench');
      final routine = Workout(
        id: 'routine',
        name: 'Routine',
        exercises: [planned],
      );
      await db.insertRoutine(routine);
      // Keep the stream snapshot stale throughout both writes, independently
      // of how quickly the database would normally deliver its next event.
      when(() => MockServices.databaseService.routines).thenReturn([routine]);
      when(() => MockServices.databaseService.setRoutine(any())).thenAnswer(
        (invocation) => db.updateRoutine(
          fixWorkout(invocation.positionalArguments.single as Workout),
        ),
      );
      final controller = dataController(RoutinesController.new);
      final reps = reachedGoal ? 10 : 6;
      final performed = planned.copyWith(
        id: 'performed',
        workoutID: 'workout',
        supersedesID: planned.id,
        notes: 'Updated notes',
        sets: [planned.sets.single.copyWith(reps: reps, done: true)],
      );
      final workout = Workout(
        id: 'workout',
        name: 'Routine',
        parentID: routine.id,
        duration: const Duration(minutes: 30),
        startingDate: DateTime(2026),
        exercises: [performed],
      );

      await controller.updateRoutineFromWorkout(routine.id, workout);
      await controller.advanceProgressionsFromWorkout(workout);

      final saved = await db.getRoutine(routine.id);
      final exercise = saved.exercises.single as Exercise;
      expect(exercise.notes, 'Updated notes');
      expect(exercise.sets.single.reps, reps);
      expect(exercise.sets.single.done, isFalse);
      expect(exercise.progression!.repsFor(1), [reachedGoal ? 9 : 8]);
      verify(
        () => MockServices.databaseService.setRoutine(any()),
      ).called(reachedGoal ? 2 : 1);
    });
  }

  test(
    'a deleted routine is not restored by progression advancement',
    () async {
      final planned = exerciseHelper(
        'planned',
        'Bench',
      ).copyWith(progression: _goal);
      final routine = Workout(
        id: 'deleted',
        name: 'Deleted',
        exercises: [planned],
      );
      when(() => MockServices.databaseService.routines).thenReturn([routine]);
      final controller = dataController(RoutinesController.new);

      await controller.advanceProgressionsFromWorkout(
        Workout(
          name: 'Workout',
          parentID: routine.id,
          exercises: [
            planned.copyWith(
              id: 'performed',
              supersedesID: planned.id,
              sets: [
                planned.sets.single.copyWith(reps: 10, weight: 40, done: true),
              ],
            ),
          ],
        ),
      );

      verifyNever(() => MockServices.databaseService.setRoutine(any()));
    },
  );
}
