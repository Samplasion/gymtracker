import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:gymtracker/controller/boutique_controller.dart';
import 'package:gymtracker/model/model.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/utils/boutique_debug_converter.dart';
import 'package:uuid/uuid.dart';

extension BoutiquePresentation on BoutiqueController {
  void routineConverter(String categoryID) async {
    final packages = (await getPackages(categoryID, language: 'en')).success!;
    Go.to(
      () => BoutiqueDebugConverter(
        packages: packages,
        onPicked: (routine, package) {
          final packageID = package.id;
          final sql = _boutiqueSql(routine, packageID);
          Clipboard.setData(ClipboardData(text: sql));
        },
      ),
    );
  }

  String _boutiqueSql(Workout routine, String packageID) {
    String _generateUUID() {
      return const Uuid().v4();
    }

    final routineID = _generateUUID();

    String result = '';
    result +=
        """
INSERT INTO
  boutique_routines (
    id,
    name,
    infobox,
    weight_unit,
    distance_unit,
    sort_order,
    package_id
  )
values
  (
    '$routineID',
    '{"en":"${routine.name}"}',
    '{"en":${routine.infobox == null ? '""' : jsonEncode(routine.infobox)}}',
    '${routine.weightUnit.name}',
    '${routine.distanceUnit.name}',
    0,
    '$packageID'
  );
  """;

    void _handleExercise(Exercise exercise, Superset? superset, int sortOrder) {
      result +=
          """
INSERT INTO boutique_routine_exercises (
  id,
  routine_id,
  name,
  parameters,
  sets,
  primary_muscle_group,
  secondary_muscle_groups,
  rest_time,
  is_custom,
  library_exercise_id,
  notes,
  is_superset,
  is_in_superset,
  superset_id,
  sort_order,
  supersedes_id,
  rpe,
  progression,
  equipment
) values (
  '${_generateUUID()}',
  '$routineID',
  '{"en":"${exercise.name}"}',
  '${exercise.parameters.name}',
  '${jsonEncode(exercise.sets.map((s) => s.copyWith(id: _generateUUID(), weight: 0)).toList())}',
  '${exercise.primaryMuscleGroup.name}',
  '${jsonEncode(exercise.secondaryMuscleGroups.map((e) => e.name).toList())}',
  ${exercise.restTime.inSeconds},
  0,
  '${exercise.parentID!}',
  '${exercise.notes.isEmpty ? "{}" : exercise.notes}',
  0,
  ${superset == null ? 0 : 1},
  ${superset == null ? 'NULL' : "'${superset.id}'"},
  $sortOrder,
  NULL,
  NULL,
  ${exercise.progression == null ? 'NULL' : "'${jsonEncode(exercise.progression!.toJson())}'"},
  '${exercise.gymEquipment.name}'
);\n\n""";
    }

    final flattened = routine.exercises;

    for (int i = 0; i < flattened.length; i++) {
      final exercise = flattened[i];
      if (exercise is Exercise) {
        _handleExercise(exercise, null, i);
      } else {
        final superset = exercise as Superset;
        final supersetID = _generateUUID();
        result +=
            """
INSERT INTO boutique_routine_exercises (
  id,
  routine_id,
  name,
  parameters,
  sets,
  primary_muscle_group,
  secondary_muscle_groups,
  rest_time,
  is_custom,
  library_exercise_id,
  notes,
  is_superset,
  is_in_superset,
  superset_id,
  sort_order,
  supersedes_id,
  rpe,
  progression,
  equipment
) values (
  '$supersetID',
  '$routineID',
  '{}',
  'repsWeight',
  '[]',
  '',
  '[]',
  ${superset.restTime.inSeconds},
  0,
  NULL,
  '${superset.notes.isEmpty ? "{}" : superset.notes}',
  1,
  0,
  NULL,
  $i,
  NULL,
  NULL,
  NULL,
  NULL
);\n\n""";

        for (int j = 0; j < superset.exercises.length; j++) {
          _handleExercise(
            superset.exercises[j],
            superset.copyWith.id(supersetID),
            j,
          );
        }
      }
    }

    return result;
  }
}
