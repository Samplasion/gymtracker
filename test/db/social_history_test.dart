import 'dart:convert';
import 'dart:io';
import 'package:drift/native.dart';
// ignore: depend_on_referenced_packages
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/model/history.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/set.dart';

void main() {
  test(
    'v20 migration preserves history and defaults visibility to friends',
    () async {
      final schema = jsonDecode(
        File('drift_schemas/drift_schema_v20.json').readAsStringSync(),
      );
      final db = GTDatabaseImpl.withQueryExecutor(
        NativeDatabase.memory(
          setup: (raw) {
            for (final entry in schema['fixed_sql'] as List) {
              for (final statement in entry['sql'] as List) {
                if (statement['dialect'] == 'sqlite')
                  raw.execute(statement['sql'] as String);
              }
            }
            raw.execute(
              "INSERT INTO history_workouts(id,user_id,name,duration,starting_date,weight_unit,distance_unit) VALUES('old','A','Existing',1800,1760000000,'kg','km')",
            );
            raw.execute('PRAGMA user_version=20');
          },
        ),
      );
      addTearDown(db.close);
      await db.validateDatabaseSchema();
      final row = await db.select(db.historyWorkouts).getSingle();
      expect(row.name, 'Existing');
      expect(row.visibility, 'friends');
      expect(row.publicationManifest, isNull);
      expect(await db.select(db.syncOutbox).get(), isEmpty);
    },
  );
  test(
    'individual and bulk saves retain private visibility and publication barrier',
    () async {
      final db = GTDatabaseImpl.withQueryExecutor(NativeDatabase.memory());
      addTearDown(db.close);
      db.setCurrentUserId('A');
      final workout = Workout(
        id: 'private',
        name: 'Private',
        exercises: [
          Exercise.custom(
            id: 'exercise',
            name: 'Exercise',
            parameters: GTSetParameters.repsWeight,
            sets: [],
            primaryMuscleGroup: GTMuscleGroup.abs,
            secondaryMuscleGroups: {},
            restTime: Duration.zero,
            parentID: 'custom-parent',
            notes: '',
            workoutID: 'private',
            supersetID: null,
            equipment: GTGymEquipment.none,
          ),
        ],
        duration: const Duration(minutes: 30),
        startingDate: DateTime.utc(2026, 10, 22),
        visibility: 'private',
      );
      await db.insertHistoryWorkout(workout);
      var row = await db.select(db.historyWorkouts).getSingle();
      expect(row.visibility, 'private');
      expect(jsonDecode(row.publicationManifest!)['ids'], ['exercise']);
      expect(
        (await db.select(db.historyWorkoutExercises).getSingle())
            .publicationVersion,
        jsonDecode(row.publicationManifest!)['version'],
      );
      final firstVersion = jsonDecode(row.publicationManifest!)['version'];
      await db.updateHistoryWorkout(workout.copyWith(name: 'Edited'));
      row = await db.select(db.historyWorkouts).getSingle();
      expect(row.visibility, 'private');
      expect(
        jsonDecode(row.publicationManifest!)['version'],
        isNot(firstVersion),
      );
      await db.writeAllHistoryWorkouts([workout]);
      row = await db.select(db.historyWorkouts).getSingle();
      expect(row.visibility, 'private');
      expect(row.publicationManifest, isNotNull);
      expect(
        (await db.select(db.historyWorkoutExercises).getSingle())
            .publicationVersion,
        jsonDecode(row.publicationManifest!)['version'],
      );
      expect(Workout.fromJson(workout.toJson()).visibility, 'private');
      final legacy = Map<String, dynamic>.from(workout.toJson())
        ..remove('visibility');
      expect(Workout.fromJson(legacy).visibility, 'friends');
      expect(workout.toRoutine().visibility, 'friends');
      final payload = row.toJson();
      expect(HistoryWorkout.fromJson(payload).visibility, 'private');
    },
  );
}
