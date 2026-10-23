import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/db/model/tables/exercise.dart';
import 'package:gymtracker/db/utils.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/routines.dart';
import 'package:gymtracker/model/set.dart';

void main() {
  test('Postgres MCP program is consumable by the existing Flutter models', () {
    final json =
        jsonDecode(File('test/fixtures/mcp_program.json').readAsStringSync())
            as Map<String, dynamic>;
    final folder = RoutineFolder.fromJson(
      (json['folder'] as Map).cast<String, dynamic>(),
    );
    final routine = Routine.fromJson(
      (json['routine'] as Map).cast<String, dynamic>(),
    );
    final rows = (json['exercises'] as List)
        .map(
          (e) => RoutineExercise.fromJson((e as Map).cast<String, dynamic>()),
        )
        .toList();
    final exercise = exerciseFromDatabaseExercise(rows.single) as Exercise;
    expect(routine.folderId, folder.id);
    expect(routine.weightUnit.name, 'kg');
    expect(routine.distanceUnit.name, 'km');
    expect(exercise.parentID, 'library.chest.exercises.barbellBenchPressFlat');
    expect(exercise.standard, isTrue);
    expect(exercise.workoutID, routine.id);
    expect(exercise.sets.single.parameters, GTSetParameters.repsWeight);
    expect(exercise.sets.single.reps, 8);
    expect(exercise.sets.single.weight, 0);
    expect(exercise.sets.single.done, isFalse);
    expect(exercise.restTime, Duration.zero);
    expect(exercise.getDisplayName(AppLocale.en.buildSync()), isNotEmpty);
  });
}
