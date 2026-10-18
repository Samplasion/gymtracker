import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/progression.dart';
import 'package:gymtracker/model/set.dart';

Exercise performed(List<int> reps, double weight, {bool skipLast = false}) =>
    Exercise.custom(
      name: 'Squat',
      parameters: GTSetParameters.repsWeight,
      sets: [
        for (var i = 0; i < reps.length; i++)
          GTSet(
            kind: GTSetKind.normal,
            parameters: GTSetParameters.repsWeight,
            reps: reps[i],
            weight: weight,
            done: !skipLast || i < reps.length - 1,
          ),
      ],
      primaryMuscleGroup: GTMuscleGroup.quadriceps,
      restTime: Duration.zero,
      notes: '',
      supersetID: null,
      workoutID: null,
      equipment: GTGymEquipment.barbell,
    );

void main() {
  test('cyclic linear goals return to a higher starting weight', () {
    var goal = const ExerciseProgression(
      mode: ProgressionMode.cyclicLinear,
      minReps: 8,
      maxReps: 12,
      repsPerStep: 2,
      setCount: 3,
      startingWeight: 40,
      weightPerStep: 5,
      weightPerCycle: 5,
    );
    for (final (weight, reps) in [(40.0, 12), (45.0, 10), (50.0, 8)]) {
      expect(goal.targetWeight, weight);
      expect(goal.repsFor(3), [reps, reps, reps]);
      expect(goal.reached(performed([reps, reps, reps], weight)), isTrue);
      goal = goal.advance(3);
    }
    expect(goal.cycle, 1);
    expect(goal.step, 0);
    expect(goal.targetWeight, 45);
    expect(goal.repsFor(3), [12, 12, 12]);
  });

  test('missing, unfinished or underweight working sets do not advance', () {
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
    expect(goal.reached(performed([12, 12], 40)), isFalse);
    expect(goal.reached(performed([12, 12, 12], 40, skipLast: true)), isFalse);
    expect(goal.reached(performed([12, 12, 12], 39.5)), isFalse);
    expect(goal.reached(performed([12, 12, 12, 5], 40)), isTrue);
    final withWarmup = performed([12, 12, 12], 40);
    final exercise = withWarmup.copyWith(
      sets: [
        GTSet(
          kind: GTSetKind.warmUp,
          parameters: GTSetParameters.repsWeight,
          reps: 5,
          weight: 20,
          done: true,
        ),
        ...withWarmup.sets,
      ],
    );
    expect(goal.reached(exercise), isTrue);
  });

  test('double progression adds one rep to the lowest working set', () {
    var goal = const ExerciseProgression(
      mode: ProgressionMode.doubleProgression,
      minReps: 8,
      maxReps: 10,
      repsPerStep: 1,
      setCount: 3,
      startingWeight: 40,
      weightPerStep: 2.5,
      weightPerCycle: 0,
    );
    goal = goal.advance(3);
    expect(goal.repsFor(3), [9, 8, 8]);
    expect(goal.reached(performed([9, 8, 8], 40)), isTrue);
    for (var i = 0; i < 5; i++) {
      goal = goal.advance(3);
    }
    expect(goal.repsFor(3), [10, 10, 10]);
    goal = goal.advance(3);
    expect(goal.targetWeight, 42.5);
    expect(goal.repsFor(3), [8, 8, 8]);
  });

  test('bodyweight progression holds at the top of its range', () {
    const goal = ExerciseProgression(
      mode: ProgressionMode.doubleProgression,
      minReps: 8,
      maxReps: 12,
      repsPerStep: 1,
      setCount: 3,
      startingWeight: 0,
      weightPerStep: 2.5,
      weightPerCycle: 0,
      targetReps: [12, 12, 12],
    );
    expect(goal.advance(3, hasWeight: false).sameAs(goal), isTrue);
  });

  test('editing routine sets preserves targets for remaining sets', () {
    const goal = ExerciseProgression(
      mode: ProgressionMode.doubleProgression,
      minReps: 8,
      maxReps: 12,
      repsPerStep: 1,
      setCount: 3,
      startingWeight: 40,
      weightPerStep: 2.5,
      weightPerCycle: 0,
      targetReps: [10, 9, 8],
    );
    final sets = performed([10, 9, 8], 40).sets;
    final shortened = goal.forRoutineSets(sets, [sets[0], sets[2]])!;
    expect(shortened.setCount, 2);
    expect(shortened.repsFor(2), [10, 8]);
    expect(shortened.reached(performed([10, 8], 40)), isTrue);

    final extended = shortened.forRoutineSets(
      [sets[0], sets[2]],
      [
        sets[2],
        sets[0],
        GTSet.empty(
          kind: GTSetKind.normal,
          parameters: GTSetParameters.repsWeight,
        ),
      ],
    )!;
    expect(extended.repsFor(3), [8, 10, 8]);
    expect(goal.forRoutineSets(sets, []), isNull);
  });

  test('warm-up changes leave cyclic goal unchanged', () {
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
      step: 1,
    );
    final sets = performed([10, 10, 10], 45).sets;
    final withWarmup = [
      GTSet.empty(
        kind: GTSetKind.warmUp,
        parameters: GTSetParameters.repsWeight,
      ),
      ...sets,
    ];
    expect(goal.forRoutineSets(sets, withWarmup)!.sameAs(goal), isTrue);
    final shortened = goal.forRoutineSets(sets, [sets[0], sets[2]])!;
    expect(shortened.setCount, 2);
    expect(shortened.cycle, 1);
    expect(shortened.step, 1);
    expect(shortened.reached(performed([10, 10], 50)), isTrue);
  });

  test(
    'old exercises load without progression and configured ones round-trip',
    () {
      final oldJson = performed([8, 8, 8], 40).toJson()..remove('progression');
      expect(Exercise.fromJson(oldJson).progression, isNull);
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
      final exercise = performed([12, 12, 12], 40).copyWith(progression: goal);
      final restored = Exercise.fromJson(exercise.toJson());
      expect(restored.progression?.toJson(), goal.toJson());
    },
  );
}
