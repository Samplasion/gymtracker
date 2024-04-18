import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:test/test.dart';

import '../expectations.dart';

void main() {
  group('Exercise model', () {
    group("instantiate(workout:)", () {
      final base = Exercise.custom(
        name: "Exercise",
        parameters: GTSetParameters.distance,
        sets: [],
        primaryMuscleGroup: GTMuscleGroup.abductors,
        restTime: Duration.zero,
        notes: "Notes",
        workoutID: null,
        supersetID: null,
      );
      test("instantiates a child of the exercise in a routine", () {
        final workout = Workout(
          name: "Workout",
          exercises: [],
        );

        final instantiated = base.instantiate(workout: workout);
        expectExercise(
          instantiated,
          Exercise.custom(
            // We don't care about the ID
            id: instantiated.id,
            name: "Exercise",
            parameters: GTSetParameters.distance,
            sets: [],
            primaryMuscleGroup: GTMuscleGroup.abductors,
            restTime: Duration.zero,
            notes: "Notes",
            workoutID: workout.id,
            supersetID: null,
          ),
        );
      });
      test("instantiates a child of the exercise in a concrete workout", () {
        final workout = Workout(
          name: "Workout",
          exercises: [],
          duration: const Duration(minutes: 1),
          startingDate: DateTime.now(),
        );

        final instantiated = base.instantiate(workout: workout);
        expectExercise(
          instantiated,
          Exercise.custom(
            // We don't care about the ID
            id: instantiated.id,
            name: "Exercise",
            parentID: base.id,
            parameters: GTSetParameters.distance,
            sets: [],
            primaryMuscleGroup: GTMuscleGroup.abductors,
            restTime: Duration.zero,
            notes: "Notes",
            workoutID: workout.id,
            supersetID: null,
          ),
        );
      });
    });

    group("replaced(from:to:) static method", () {
      test("computes with the same parameters", () {
        final sets = [
          for (int i = 0; i < GTSetKind.values.length; i++)
            GTSet(
              kind: GTSetKind.values[i],
              parameters: GTSetParameters.repsWeight,
              reps: 10,
              weight: i * 10,
            ),
        ];
        final from = Exercise.custom(
          id: "",
          parentID: "",
          name: "From",
          parameters: GTSetParameters.repsWeight,
          primaryMuscleGroup: GTMuscleGroup.abductors,
          secondaryMuscleGroups: {GTMuscleGroup.abs, GTMuscleGroup.adductors},
          restTime: const Duration(minutes: 1),
          notes: "From notes",
          sets: sets,
          workoutID: null,
          supersetID: null,
        );
        final to = Exercise.custom(
          id: "",
          parentID: "",
          name: "To",
          parameters: GTSetParameters.repsWeight,
          primaryMuscleGroup: GTMuscleGroup.shoulders,
          secondaryMuscleGroups: {GTMuscleGroup.traps, GTMuscleGroup.triceps},
          restTime: const Duration(minutes: 2),
          notes: "To notes",
          sets: [],
          workoutID: null,
          supersetID: null,
        );

        final result = Exercise.replaced(from: from, to: to);
        final expected = Exercise.custom(
          id: "",
          parentID: "",
          name: "To",
          parameters: GTSetParameters.repsWeight,
          primaryMuscleGroup: GTMuscleGroup.shoulders,
          secondaryMuscleGroups: {GTMuscleGroup.traps, GTMuscleGroup.triceps},
          restTime: const Duration(minutes: 1),
          notes: "From notes",
          sets: sets,
          workoutID: null,
          supersetID: null,
        );
        expectExercise(result, expected);
      });

      test("computes with different parameters", () {
        const params = GTSetParameters.repsWeight;
        final from = Exercise.custom(
          id: "",
          parentID: "",
          name: "From",
          parameters: params,
          primaryMuscleGroup: GTMuscleGroup.abductors,
          secondaryMuscleGroups: {GTMuscleGroup.abs, GTMuscleGroup.adductors},
          restTime: const Duration(minutes: 1),
          notes: "From notes",
          sets: [
            for (int i = 0; i < GTSetKind.values.length; i++)
              GTSet(
                kind: GTSetKind.values[i],
                parameters: params,
                reps: 10,
                weight: i * 10,
              ),
          ],
          workoutID: null,
          supersetID: null,
        );

        final otherParameters =
            GTSetParameters.values.where((element) => element != params);

        for (final params in otherParameters) {
          final to = Exercise.custom(
            id: "",
            parentID: "",
            name: "To",
            parameters: params,
            primaryMuscleGroup: GTMuscleGroup.shoulders,
            secondaryMuscleGroups: {GTMuscleGroup.traps, GTMuscleGroup.triceps},
            restTime: const Duration(minutes: 2),
            notes: "To notes",
            sets: [],
            workoutID: null,
            supersetID: null,
          );

          final result = Exercise.replaced(from: from, to: to);
          final expected = Exercise.custom(
            id: "",
            parentID: "",
            name: "To",
            parameters: params,
            primaryMuscleGroup: GTMuscleGroup.shoulders,
            secondaryMuscleGroups: {GTMuscleGroup.traps, GTMuscleGroup.triceps},
            restTime: const Duration(minutes: 1),
            notes: "From notes",
            sets: [
              for (final set in from.sets)
                GTSet(
                  kind: set.kind,
                  parameters: params,
                  reps: 0,
                  weight: 0,
                  time: Duration.zero,
                  distance: 0,
                ),
            ],
            workoutID: null,
            supersetID: null,
          );

          expectExercise(result, expected);
        }
      });

      test("guarantees copyWith compatibility", () {
        const params = GTSetParameters.repsWeight;
        final base = Exercise.custom(
          id: "",
          parentID: "",
          name: "To",
          parameters: params,
          primaryMuscleGroup: GTMuscleGroup.shoulders,
          secondaryMuscleGroups: {GTMuscleGroup.traps, GTMuscleGroup.triceps},
          restTime: const Duration(minutes: 2),
          notes: "To notes",
          sets: [],
          workoutID: null,
          supersetID: null,
        );

        final result = base.copyWith(
          name: "Copied",
          parameters: params,
          primaryMuscleGroup: GTMuscleGroup.abductors,
          secondaryMuscleGroups: {},
          sets: base.sets,
        );
        final expected = Exercise.replaced(
          from: base,
          to: base.copyWith(
            name: "Copied",
            parameters: params,
            primaryMuscleGroup: GTMuscleGroup.abductors,
            secondaryMuscleGroups: {},
            sets: base.sets,
          ),
        );

        expectExercise(result, expected);
      });

      test("is idempotent", () {
        final base = Exercise.custom(
          id: "",
          parentID: "",
          name: "To",
          parameters: GTSetParameters.repsWeight,
          primaryMuscleGroup: GTMuscleGroup.shoulders,
          secondaryMuscleGroups: {GTMuscleGroup.traps, GTMuscleGroup.triceps},
          restTime: const Duration(minutes: 2),
          notes: "To notes",
          sets: [],
          workoutID: null,
          supersetID: null,
        );
        final result = Exercise.replaced(from: base, to: base);

        expect(result.id, base.id);
        expectExercise(result, base);
      });
    });
  });
}
