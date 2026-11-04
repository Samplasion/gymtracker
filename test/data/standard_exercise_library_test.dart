import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/data/exercises.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/set.dart';

void main() {
  test('saved library children resolve metadata without a routine ID', () {
    for (final original in exerciseStandardLibraryAsList) {
      for (final workoutID in <String?>[null, 'routine-id']) {
        final saved = Exercise.fromJson(
          original
              .makeChild()
              .copyWith(name: original.id, workoutID: workoutID)
              .toJson()
            ..['equipment'] = 'none',
        );
        expect(saved.isStandardLibraryExercise, isTrue, reason: original.id);
        expect(saved.category, original.category, reason: original.id);
        expect(saved.gymEquipment, original.gymEquipment, reason: original.id);
        for (final locale in AppLocale.values) {
          final translations = locale.buildSync();
          expect(
            saved.getDisplayName(translations),
            original.getDisplayName(translations),
            reason: '${original.id}: ${locale.name}',
          );
        }
      }
    }
  });

  test(
    'renaming preserves all existing IDs except the authorized reverse curl',
    () {
      final preserved =
          (jsonDecode(
                    File(
                      'test/fixtures/standard_exercise_ids.json',
                    ).readAsStringSync(),
                  )
                  as List)
              .cast<String>();
      final ids = exerciseStandardLibraryAsList.map((e) => e.id).toList();
      expect(ids.toSet().length, ids.length);
      expect(ids, containsAll(preserved));
      expect(
        ids,
        isNot(contains('library.forearms.exercises.cableSingleArmReverseCurl')),
      );
    },
  );

  test(
    'every imported source entry resolves to a bilingual library exercise',
    () {
      final audit =
          jsonDecode(
                File(
                  'test/fixtures/imported_exercise_resolutions.json',
                ).readAsStringSync(),
              )
              as Map<String, dynamic>;
      final rows = (audit['resolutions'] as List).cast<Map<String, dynamic>>();
      expect(audit['sourceCount'], 1324);
      expect(rows, hasLength(audit['sourceCount'] as int));
      expect(
        rows.map((row) => row['sourceId']).toSet(),
        hasLength(rows.length),
      );
      final translations = {
        for (final locale in AppLocale.values) locale: locale.buildSync(),
      };
      for (final row in rows) {
        final id = row['exerciseId'] as String;
        final exercise = getStandardExerciseByID(id);
        expect(exercise, isNotNull, reason: 'Source ${row['sourceId']}: $id');
        expect(exercise!.category, isNotNull, reason: id);
        for (final entry in translations.entries) {
          final name = exercise.getDisplayName(entry.value);
          expect(name.trim(), isNotEmpty, reason: '$id: ${entry.key.name}');
          expect(name, isNot(id), reason: '$id: ${entry.key.name}');
          expect(name, isNot('UNKNOWN'), reason: '$id: ${entry.key.name}');
        }
      }
    },
  );

  test('ambiguous source names resolve by movement and preserve equipment', () {
    final audit =
        jsonDecode(
              File(
                'test/fixtures/imported_exercise_resolutions.json',
              ).readAsStringSync(),
            )
            as Map<String, dynamic>;
    final ids = {
      for (final row in audit['resolutions'] as List)
        row['sourceId'] as String: row['exerciseId'] as String,
    };
    Exercise source(String id) => getStandardExerciseByID(ids[id]!)!;
    // The source calls bicycle crunches "air bike" and a squat "quads".
    expect(ids['0003'], 'library.abs.exercises.bicycleCrunches');
    expect(ids['3533'], 'library.quadriceps.exercises.bodyweightSquats');
    expect(ids['0316'], 'library.chest.exercises.dumbbellBenchPressIncline');
    // Band and cable resistance, and bodyweight and loaded variants, differ.
    expect(source('0979').gymEquipment, GTGymEquipment.resistanceBand);
    expect(source('0979').id, isNot('library.abs.exercises.pallofPress'));
    expect(source('1373').gymEquipment, GTGymEquipment.none);
    expect(source('0070').gymEquipment, GTGymEquipment.barbell);
    expect(source('0372').gymEquipment, GTGymEquipment.dumbbell);
    expect(source('0811').gymEquipment, GTGymEquipment.barbell);
    expect(source('0451').primaryMuscleGroup, GTMuscleGroup.biceps);
    expect(source('1437').primaryMuscleGroup, GTMuscleGroup.forearms);
    expect(source('3299').parameters, GTSetParameters.time);
    expect(source('1511').parameters, GTSetParameters.time);
    // Camera angles and equivalent source spellings must not add duplicates.
    expect(ids['0739'], ids['1463']);
    expect(ids['0739'], ids['1464']);
    expect(ids['0432'], ids['0434']);
    expect(ids['0287'], ids['2137']);
  });

  test('dynamic and static dead bugs remain distinct in both languages', () {
    final dynamic = getStandardExerciseByID(
      'library.abs.exercises.deadBugHold',
    )!;
    final timed = getStandardExerciseByID(
      'library.abs.exercises.deadBugHoldCardio',
    )!;
    final hold = getStandardExerciseByID(
      'library.abs.exercises.deadBugHoldStatic',
    )!;
    expect(dynamic.parameters, GTSetParameters.freeBodyReps);
    expect(timed.parameters, GTSetParameters.time);
    expect(hold.parameters, GTSetParameters.time);
    for (final locale in AppLocale.values) {
      final t = locale.buildSync();
      expect(dynamic.getDisplayName(t), 'Dead bugs');
      expect(timed.getDisplayName(t), isNot(contains('hold')));
      expect(hold.getDisplayName(t), contains('hold'));
      expect({
        dynamic.getDisplayName(t),
        timed.getDisplayName(t),
        hold.getDisplayName(t),
      }, hasLength(3));
    }
  });

  test('single-arm reverse curls have separate IDs and matching equipment', () {
    final dumbbell = getStandardExerciseByID(
      'library.forearms.exercises.dumbbellSingleArmReverseCurl',
    )!;
    final cable = getStandardExerciseByID(
      'library.forearms.exercises.singleArmCableReverseCurl',
    )!;
    expect(dumbbell.gymEquipment, GTGymEquipment.dumbbell);
    expect(cable.gymEquipment, GTGymEquipment.cable);
    for (final locale in AppLocale.values) {
      final t = locale.buildSync();
      expect(
        dumbbell.getDisplayName(t).toLowerCase(),
        contains(locale == AppLocale.it ? 'manubrio' : 'dumbbell'),
      );
      expect(
        cable.getDisplayName(t).toLowerCase(),
        contains(locale == AppLocale.it ? 'cavo' : 'cable'),
      );
    }
  });
}
