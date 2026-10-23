import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/data/configuration.dart';
import 'package:gymtracker/db/model/tables/exercise.dart';
import 'package:gymtracker/db/model/tables/foods.dart';
import 'package:gymtracker/db/utils.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/progression.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/model/superset.dart';
import 'package:gymtracker/struct/nutrition.dart';

void main() {
  final fixture =
      jsonDecode(File('test/fixtures/mcp_expanded.json').readAsStringSync())
          as Map<String, dynamic>;
  test(
    'MCP supersets and progressions round-trip through actual database mappers',
    () {
      final rows = (fixture['exercises'] as List)
          .map(
            (e) => RoutineExercise.fromJson((e as Map).cast<String, dynamic>()),
          )
          .toList();
      final entries = databaseExercisesToExercises(rows);
      expect(entries, hasLength(1));
      final group = entries.single as Superset;
      expect(group.restTime, const Duration(seconds: 120));
      expect(group.exercises, hasLength(2));
      final exercise = group.exercises.firstWhere((e) => e.progression != null);
      expect(exercise.rpe, 8);
      expect(exercise.sets.first.rpe, 8.5);
      expect(exercise.progression!.isValid, isTrue);
      expect(exercise.progression!.setCount, 2);
      expect(exercise.progression!.mode, ProgressionMode.doubleProgression);
      expect(exercise.progression!.repsFor(2), [8, 8]);
      final completed = exercise.copyWith(
        sets: [for (final set in exercise.sets) set.copyWith(done: true)],
      );
      expect(exercise.progression!.reached(completed), isTrue);
      expect(exercise.progression!.advance(2).targetReps, [9, 8]);
      expect(group.exercises.every((e) => e.supersetID == group.id), isTrue);
      expect(
        group.exercises.every(
          (e) => e.sets.every((s) => s.parameters == e.parameters),
        ),
        isTrue,
      );
    },
  );
  test(
    'MCP food snapshot is compatible with app amounts, dates and nutritional arithmetic',
    () {
      final row = DBFood.fromJson(
        (fixture['food'] as Map).cast<String, dynamic>(),
      );
      final food = Food.fromJson(
        (jsonDecode(row.jsonData) as Map).cast<String, dynamic>(),
      );
      expect(row.referenceDate.isUtc, isTrue);
      expect(row.referenceDate.hour, 0);
      expect(food.category, 'Lunch');
      expect(food.amount, 50);
      expect(food.pieces, 2);
      expect(food.nutritionalValues.calories, 200);
      expect(food.nutritionalValues.protein, 10);
      expect(food.nutritionalValues.fiber, isNull);
    },
  );
  test('Backend Free caps remain aligned with the app configuration', () {
    final migration = File(
      'supabase/migrations/20261023110000_mcp_capabilities.sql',
    ).readAsStringSync();
    expect(Configuration.trialRoutineLimit, 4);
    expect(Configuration.trialCustomExerciseLimit, 10);
    expect(migration, contains('count_new>${Configuration.trialRoutineLimit}'));
    expect(
      migration,
      contains(
        "request->'exercises')>${Configuration.trialCustomExerciseLimit}",
      ),
    );
  });
}
