import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
// ignore: depend_on_referenced_packages
import 'package:drift_dev/api/migrations_native.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/db/model/tables/exercise.dart' show RoutineExercise;
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/progression.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

const goal = ExerciseProgression(
  mode: ProgressionMode.cyclicLinear,
  minReps: 8,
  maxReps: 12,
  repsPerStep: 2,
  setCount: 3,
  startingWeight: 40,
  weightPerStep: 5,
  weightPerCycle: 5,
  cycle: 1,
  step: 2,
);

Exercise exercise(String workoutId, {ExerciseProgression? progression}) =>
    Exercise.custom(
      id: 'exercise-$workoutId',
      name: 'Squat',
      parameters: GTSetParameters.repsWeight,
      sets: [
        GTSet(
          kind: GTSetKind.normal,
          parameters: GTSetParameters.repsWeight,
          reps: 8,
          weight: 50,
          done: true,
        ),
      ],
      primaryMuscleGroup: GTMuscleGroup.quadriceps,
      restTime: Duration.zero,
      parentID: 'library-squat',
      notes: '',
      supersetID: null,
      workoutID: workoutId,
      equipment: GTGymEquipment.barbell,
    ).copyWith(progression: progression);

void main() {
  test(
    'routine and workout history retain progression settings and state',
    () async {
      final db = GTDatabaseImpl.withQueryExecutor(NativeDatabase.memory());
      try {
        final routine = Workout(
          id: 'routine-1',
          name: 'Leg day',
          exercises: [exercise('routine-1', progression: goal)],
        );
        await db.insertRoutine(routine);
        final savedRoutine = await db.getRoutine(routine.id);
        expect(
          (savedRoutine.exercises.single as Exercise).progression?.toJson(),
          goal.toJson(),
        );
        final synced = RoutineExercise.fromJson(
          (await db.select(db.routineExercises).get()).single.toJson(),
        );
        expect(synced.progression?.toJson(), goal.toJson());

        final workout = Workout(
          id: 'workout-1',
          name: 'Leg day',
          exercises: [exercise('workout-1', progression: goal)],
          duration: const Duration(minutes: 30),
          startingDate: DateTime(2026, 10, 18),
          parentID: routine.id,
        );
        await db.insertHistoryWorkout(workout);
        final savedWorkout = await db.getHistoryWorkout(workout.id);
        expect(
          (savedWorkout.exercises.single as Exercise).progression?.toJson(),
          goal.toJson(),
        );
      } finally {
        await db.close();
      }
    },
  );

  test('version 18 data migrates with empty progression columns', () async {
    final raw = sqlite3.openInMemory();
    final schema =
        jsonDecode(
              File('drift_schemas/drift_schema_v18.json').readAsStringSync(),
            )
            as Map<String, dynamic>;
    for (final statement in schema['fixed_sql'] as List<dynamic>) {
      for (final sql
          in (statement as Map<String, dynamic>)['sql'] as List<dynamic>) {
        final entry = sql as Map<String, dynamic>;
        if (entry['dialect'] == 'sqlite') raw.execute(entry['sql'] as String);
      }
    }
    raw.execute('PRAGMA user_version = 18');
    raw.execute('''
      INSERT INTO routines (id, name, infobox, weight_unit, distance_unit, sort_order)
      VALUES ('old-routine', 'Old routine', '', 'kg', 'km', 0)
    ''');
    raw.execute('''
      INSERT INTO routine_exercises
        (id, routine_id, name, parameters, sets, primary_muscle_group,
         secondary_muscle_groups, rest_time, is_custom, library_exercise_id,
         is_superset, is_in_superset, sort_order)
      VALUES
        ('old-exercise', 'old-routine', 'Squat', 'repsWeight', '[]', 'quadriceps',
         '', 0, 0, 'library-squat', 0, 0, 0)
    ''');

    final db = GTDatabaseImpl.withQueryExecutor(NativeDatabase.opened(raw));
    try {
      final old = await db.getRoutine('old-routine');
      await db.validateDatabaseSchema();
      expect((old.exercises.single as Exercise).progression, isNull);
      expect(
        raw
            .select('PRAGMA table_info(routine_exercises)')
            .any((column) => column['name'] == 'progression'),
        isTrue,
      );
      expect(
        raw
            .select('PRAGMA table_info(history_workout_exercises)')
            .any((column) => column['name'] == 'progression'),
        isTrue,
      );
      expect(
        raw.select('PRAGMA user_version').single['user_version'],
        DATABASE_VERSION,
      );
    } finally {
      await db.close();
    }
  });
}
