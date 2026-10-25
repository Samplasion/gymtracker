import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/utils/extensions.dart';

import '../helpers.dart';

void main() {
  GTSet negative({double weight = 5, bool done = true}) => GTSet(
    kind: GTSetKind.normal,
    parameters: GTSetParameters.repsNegWeight,
    reps: 10,
    weight: weight,
    done: done,
  );

  test('negative volume retains positive stored input and survives JSON', () {
    final set = negative();
    expect(set.weight, 5);
    expect(set.effectiveWeight, -5);
    expect(set.liftedWeight, -50);
    expect(negative(weight: 0).liftedWeight, 0);
    expect(set.parameters.hasWeight, isTrue);
    expect(set.parameters.hasReps, isTrue);
    expect(set.parameters.hidden, isFalse);
    final json = set.toJson();
    expect(json['parameters'], 'repsNegWeight');
    expect(json['weight'], 5);
    final restored = GTSet.fromJson(json);
    expect(restored.liftedWeight, -50);
    expect(restored.weight, 5);
    expect(() => restored.oneRepMax, throwsA(isA<SetParametersError>()));
    expect(
      GTSet.empty(
        kind: GTSetKind.normal,
        parameters: set.parameters,
      ).liftedWeight,
      0,
    );
  });

  test(
    'only completed sets contribute to exercise and mixed workout totals',
    () {
      final exercise = exerciseHelper(
        'negative',
        'Assisted',
        sets: [negative(), negative(done: false)],
      );
      expect(exercise.liftedWeight, -50);
      expect(exercise.reps, 10);
      final workout = Workout(
        name: 'Mixed',
        exercises: [
          exercise,
          exerciseHelper(
            'positive',
            'Regular',
            sets: [
              GTSet(
                kind: GTSetKind.normal,
                parameters: GTSetParameters.repsWeight,
                reps: 10,
                weight: 20,
                done: true,
              ),
            ],
          ),
        ],
      );
      expect(workout.liftedWeight, 150);
      final restored = Workout.fromJson(workout.toJson());
      expect(restored.liftedWeight, 150);
      expect(
        restored.exercises.first.asExercise.parameters,
        GTSetParameters.repsNegWeight,
      );
    },
  );

  test('descriptions display the effective weight after unit conversion', () {
    final set = negative();
    String description(Weights unit) => set.getHumanReadableDescription(
      targetWeightUnit: unit,
      targetDistanceUnit: Distance.km,
      t: AppLocale.en.buildSync(),
      weightUnit: Weights.kg,
      distanceUnit: Distance.km,
    );
    expect(description(Weights.kg), contains('-5'));
    expect(description(Weights.lb), contains('-11'));
    expect(set.weight, 5);
  });

  test(
    'database round trip preserves negative parameter and positive input',
    () async {
      final db = GTDatabaseImpl.withQueryExecutor(NativeDatabase.memory());
      addTearDown(db.close);
      final workout = Workout(
        id: 'negative-routine',
        name: 'Negative',
        exercises: [
          exerciseHelper(
            'negative',
            'Assisted',
            workoutID: 'negative-routine',
            sets: [negative()],
          ).copyWith(parentID: 'custom-parent'),
        ],
      );
      await db.insertRoutine(workout);
      final restored = await db.getRoutine(workout.id);
      final set = restored.exercises.single.sets.single;
      expect(set.parameters, GTSetParameters.repsNegWeight);
      expect(set.weight, 5);
      expect(set.liftedWeight, -50);
    },
  );
}
