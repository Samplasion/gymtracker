import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/model/boutique.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/progression.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/model/superset.dart';

void main() {
  test('boutique routines retain progression after installation', () async {
    const goal = ExerciseProgression(
      mode: ProgressionMode.cyclicLinear,
      minReps: 8,
      maxReps: 12,
      repsPerStep: 2,
      setCount: 3,
      startingWeight: 40,
      weightPerStep: 5,
      weightPerCycle: 5,
    );
    final set = GTSet.empty(
      kind: GTSetKind.normal,
      parameters: GTSetParameters.repsWeight,
    );
    Map<String, dynamic> exercise(String id, {Object? progression}) => {
      'id': id,
      'routine_id': 'boutique-routine',
      'name': jsonEncode({'en': 'Squat', 'it': 'Squat IT'}),
      'parameters': 'repsWeight',
      'sets': [
        set.toJson(),
        set.copyWith(id: 'second').toJson(),
        set.copyWith(id: 'third').toJson(),
      ],
      'primary_muscle_group': GTMuscleGroup.quadriceps.name,
      'secondary_muscle_groups': <String>[],
      'rest_time': 60,
      'is_custom': false,
      'is_superset': false,
      'is_in_superset': false,
      'sort_order': id == 'configured' ? 0 : 1,
      'library_exercise_id': 'library-squat',
      'equipment': GTGymEquipment.barbell.name,
      'progression': progression,
    };
    final package = BoutiquePackage.fromJson({
      'id': 'package',
      'name': {'en': 'Program', 'it': 'Programma'},
      'description': {'en': '', 'it': ''},
      'boutique_routines': [
        {
          'id': 'boutique-routine',
          'name': jsonEncode({'en': 'Leg day', 'it': 'Gambe'}),
          'infobox': jsonEncode({'en': '', 'it': ''}),
          'weight_unit': 'lb',
          'distance_unit': 'mi',
          'boutique_routine_exercises': [
            exercise('configured', progression: jsonEncode(goal.toJson())),
            exercise('legacy')..remove('progression'),
            {
              'id': 'superset',
              'routine_id': 'boutique-routine',
              'name': '{}',
              'sets': <Object>[],
              'secondary_muscle_groups': <String>[],
              'rest_time': 60,
              'is_custom': false,
              'is_superset': true,
              'is_in_superset': false,
              'sort_order': 2,
            },
            {
              ...exercise('superset-child', progression: goal.toJson()),
              'is_in_superset': true,
              'superset_id': 'superset',
              'sort_order': 0,
            },
          ],
        },
      ],
    }, 'it');

    final exercises = package.routines.single.exercises;
    expect(package.name, 'Programma');
    expect(package.routines.single.name, 'Gambe');
    expect(package.routines.single.weightUnit.name, 'lb');
    expect(package.routines.single.distanceUnit.name, 'mi');
    expect((exercises[0] as Exercise).name, 'Squat IT');
    expect((exercises[0] as Exercise).progression?.toJson(), goal.toJson());
    expect((exercises[1] as Exercise).progression, isNull);
    expect(
      (exercises[2] as Superset).exercises.single.progression?.toJson(),
      goal.toJson(),
    );

    final database = GTDatabaseImpl.withQueryExecutor(NativeDatabase.memory());
    try {
      await database.insertRoutine(package.routines.single);
      final installed = await database.getRoutine('boutique-routine');
      expect(
        (installed.exercises[0] as Exercise).progression?.toJson(),
        goal.toJson(),
      );
      expect(
        (installed.exercises[2] as Superset).exercises.single.progression
            ?.toJson(),
        goal.toJson(),
      );
    } finally {
      await database.close();
    }
  });
}
