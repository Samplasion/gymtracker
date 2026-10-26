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
