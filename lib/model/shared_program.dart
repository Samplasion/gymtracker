import 'dart:convert';

import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/model/exercisable.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/superset.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:uuid/uuid.dart';

/// Versioned portable prescription shared by the app, web and Edge API.
class SharedProgramV1 {
  final Map<String, dynamic> document;
  SharedProgramV1.fromJson(this.document) {
    if (document['version'] != 1) {
      throw const FormatException('unsupported_version');
    }
    if (document['title'] is! String ||
        document['routines'] is! List ||
        (document['routines'] as List).isEmpty) {
      throw const FormatException('invalid_program');
    }
    // Decode before presenting or writing anything to the local database.
    try {
      materialize();
    } on FormatException {
      rethrow;
    } catch (_) {
      throw const FormatException('invalid_program');
    }
  }
  String get title => document['title'] as String;
  String get notes => document['notes'] as String? ?? '';
  factory SharedProgramV1.fromWorkouts(
    String title,
    List<Workout> workouts, {
    GTRoutineFolder? folder,
  }) {
    Map<String, dynamic> row(
      WorkoutExercisable entry,
      int order, {
      String? group,
    }) => entry.map(
      superset: (s) => {
        'id': s.id,
        'name': 'Superset',
        'is_superset': true,
        'is_custom': false,
        'is_in_superset': false,
        'superset_id': null,
        'sort_order': order,
        'rest_time': s.restTime.inSeconds,
        'notes': s.notes,
        'sets': <dynamic>[],
      },
      exercise: (e) => {
        'id': e.id,
        'name': e.name,
        'parameters': e.parameters.name,
        'primary_muscle_group': e.primaryMuscleGroup.name,
        'secondary_muscle_groups': e.secondaryMuscleGroups
            .map((m) => m.name)
            .toList(),
        'equipment': e.equipment.name,
        'is_superset': false,
        'is_custom': !e.standard,
        'library_exercise_id': e.standard ? e.parentID : null,
        'custom_exercise_id': e.standard ? null : e.parentID ?? e.id,
        'is_in_superset': group != null,
        'superset_id': group,
        'sort_order': order,
        'rest_time': e.restTime.inSeconds,
        'notes': e.notes,
        'progression': e.progression == null
            ? null
            : jsonEncode(e.progression!.toJson()),
        'sets': [
          for (final s in e.sets) {...s.toJson(), 'done': false},
        ],
      },
    );
    final routines = <Map<String, dynamic>>[];
    for (final w in workouts) {
      final rows = <Map<String, dynamic>>[];
      for (final e in w.exercises) {
        rows.add(row(e, rows.length));
        if (e is Superset) {
          for (final member in e.exercises) {
            rows.add(row(member, rows.length, group: e.id));
          }
        }
      }
      routines.add({
        'id': w.id,
        'name': w.name,
        'infobox': w.infobox ?? '',
        'weight_unit': w.weightUnit.name,
        'distance_unit': w.distanceUnit.name,
        'exercises': rows,
      });
    }
    return SharedProgramV1.fromJson({
      'version': 1,
      'title': title,
      'notes': folder?.notes ?? '',
      'kind': folder == null ? 'routine' : 'program',
      'routines': routines,
    });
  }

  /// All local identifiers are new, including sets nested inside supersets.
  ({
    List<Workout> routines,
    List<Exercise> customExercises,
    GTRoutineFolder? folder,
  })
  materialize() {
    const uuid = Uuid();
    final folder = document['kind'] == 'program'
        ? GTRoutineFolder(
            id: uuid.v4(),
            name: title,
            sortOrder: 9999999,
            notes: notes,
          )
        : null;
    final customs = <String, Exercise>{};
    final routines = <Workout>[];
    for (final raw in document['routines'] as List) {
      final r = Map<String, dynamic>.from(raw as Map);
      final workoutId = uuid.v4();
      final rows = (r['exercises'] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      final result = <WorkoutExercisable>[];
      final groups = <String, Superset>{};
      String? currentGroup;
      for (final e in rows) {
        final original = e['id'] as String;
        if (e['is_superset'] == true) {
          final group = Superset(
            id: uuid.v4(),
            exercises: [],
            restTime: Duration(seconds: (e['rest_time'] as num? ?? 0).toInt()),
            notes: e['notes'] as String? ?? '',
            workoutID: workoutId,
          );
          groups[original] = group;
          currentGroup = original;
          result.add(group);
          continue;
        }
        final custom = e['is_custom'] == true;
        String? parent =
            e[custom ? 'custom_exercise_id' : 'library_exercise_id'] as String?;
        final customKey = parent ?? original;
        if (custom) {
          parent = customs[customKey]?.id ?? uuid.v4();
        }
        dynamic progression = e['progression'];
        if (progression is String && progression.isNotEmpty) {
          progression = jsonDecode(progression);
        }
        final exercise = Exercise.fromJson({
          'id': uuid.v4(),
          'name': e['name'],
          'parameters': e['parameters'],
          'primaryMuscleGroup': e['primary_muscle_group'] ?? 'none',
          'secondaryMuscleGroups': e['secondary_muscle_groups'] ?? [],
          'equipment': e['equipment'] ?? 'none',
          'restTime': ((e['rest_time'] as num? ?? 0) * 1000000).toInt(),
          'parentID': parent,
          'notes': e['notes'] ?? '',
          'standard': !custom,
          'workoutID': workoutId,
          'progression': progression,
          'sets': [
            for (final rawSet in e['sets'] as List? ?? [])
              {
                ...Map<String, dynamic>.from(rawSet as Map),
                'id': uuid.v4(),
                'done': false,
              },
          ],
        });
        if (!custom && parent == null) {
          throw const FormatException('invalid_program');
        }
        if (custom) {
          customs.putIfAbsent(
            customKey,
            () => exercise.copyWith(
              id: parent!,
              parentID: null,
              workoutID: null,
              supersetID: null,
              sets: [],
            ),
          );
        }
        final groupId = e['superset_id'] as String?;
        if (e['is_in_superset'] == true || groupId != null) {
          if (groupId == null ||
              currentGroup != groupId ||
              !groups.containsKey(groupId)) {
            throw const FormatException('invalid_program');
          }
          groups[groupId]!.exercises.add(
            exercise.copyWith(supersetID: groups[groupId]!.id),
          );
        } else {
          currentGroup = null;
          result.add(exercise);
        }
      }
      routines.add(
        Workout(
          id: workoutId,
          name: r['name'] as String,
          exercises: result,
          infobox: r['infobox'] as String?,
          weightUnit: Weights.values.byName(r['weight_unit'] as String),
          distanceUnit: Distance.values.byName(r['distance_unit'] as String),
          folder: folder,
        ),
      );
    }
    return (
      routines: routines,
      customExercises: customs.values.toList(),
      folder: folder,
    );
  }
}
