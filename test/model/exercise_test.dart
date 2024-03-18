import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/set.dart';
import 'package:test/test.dart';

void expectExercise(Exercise result, Exercise expected) {
  expect(result.name, expected.name);
  expect(result.parameters, expected.parameters);
  expect(result.primaryMuscleGroup, expected.primaryMuscleGroup);
  expect(result.secondaryMuscleGroups, expected.secondaryMuscleGroups);
  expect(result.restTime, expected.restTime);
  expect(result.notes, expected.notes);
  expect(result.sets.length, expected.sets.length);
  for (int i = 0; i < result.sets.length; i++) {
    expect(result.sets[i].kind, expected.sets[i].kind);
    expect(result.sets[i].parameters, expected.sets[i].parameters);
    expect(result.sets[i].reps, expected.sets[i].reps);
    expect(result.sets[i].weight, expected.sets[i].weight);
  }
}

void main() {
  group('Exercise model', () {
    group("replaced(from:to:) static method", () {
      test("computes with the same parameters", () {
        final sets = [
          for (int i = 0; i < SetKind.values.length; i++)
            ExSet(
              kind: SetKind.values[i],
              parameters: SetParameters.repsWeight,
              reps: 10,
              weight: i * 10,
            ),
        ];
        final from = Exercise.custom(
          id: "",
          parentID: "",
          name: "From",
          parameters: SetParameters.repsWeight,
          primaryMuscleGroup: MuscleGroup.abductors,
          secondaryMuscleGroups: {MuscleGroup.abs, MuscleGroup.adductors},
          restTime: const Duration(minutes: 1),
          notes: "From notes",
          sets: sets,
        );
        final to = Exercise.custom(
          id: "",
          parentID: "",
          name: "To",
          parameters: SetParameters.repsWeight,
          primaryMuscleGroup: MuscleGroup.shoulders,
          secondaryMuscleGroups: {MuscleGroup.traps, MuscleGroup.triceps},
          restTime: const Duration(minutes: 2),
          notes: "To notes",
          sets: [],
        );

        final result = Exercise.replaced(from: from, to: to);
        final expected = Exercise.custom(
          id: "",
          parentID: "",
          name: "To",
          parameters: SetParameters.repsWeight,
          primaryMuscleGroup: MuscleGroup.shoulders,
          secondaryMuscleGroups: {MuscleGroup.traps, MuscleGroup.triceps},
          restTime: const Duration(minutes: 1),
          notes: "From notes",
          sets: sets,
        );
        expectExercise(result, expected);
      });

      test("computes with different parameters", () {
        const params = SetParameters.repsWeight;
        final from = Exercise.custom(
          id: "",
          parentID: "",
          name: "From",
          parameters: params,
          primaryMuscleGroup: MuscleGroup.abductors,
          secondaryMuscleGroups: {MuscleGroup.abs, MuscleGroup.adductors},
          restTime: const Duration(minutes: 1),
          notes: "From notes",
          sets: [
            for (int i = 0; i < SetKind.values.length; i++)
              ExSet(
                kind: SetKind.values[i],
                parameters: params,
                reps: 10,
                weight: i * 10,
              ),
          ],
        );

        final otherParameters =
            SetParameters.values.where((element) => element != params);

        for (final params in otherParameters) {
          final to = Exercise.custom(
            id: "",
            parentID: "",
            name: "To",
            parameters: params,
            primaryMuscleGroup: MuscleGroup.shoulders,
            secondaryMuscleGroups: {MuscleGroup.traps, MuscleGroup.triceps},
            restTime: const Duration(minutes: 2),
            notes: "To notes",
            sets: [],
          );

          final result = Exercise.replaced(from: from, to: to);
          final expected = Exercise.custom(
            id: "",
            parentID: "",
            name: "To",
            parameters: params,
            primaryMuscleGroup: MuscleGroup.shoulders,
            secondaryMuscleGroups: {MuscleGroup.traps, MuscleGroup.triceps},
            restTime: const Duration(minutes: 1),
            notes: "From notes",
            sets: [
              for (final set in from.sets)
                ExSet(
                  kind: set.kind,
                  parameters: params,
                  reps: 0,
                  weight: 0,
                  time: Duration.zero,
                  distance: 0,
                ),
            ],
          );

          expectExercise(result, expected);
        }
      });

      test("guarantees copyWith compatibility", () {
        const params = SetParameters.repsWeight;
        final base = Exercise.custom(
          id: "",
          parentID: "",
          name: "To",
          parameters: params,
          primaryMuscleGroup: MuscleGroup.shoulders,
          secondaryMuscleGroups: {MuscleGroup.traps, MuscleGroup.triceps},
          restTime: const Duration(minutes: 2),
          notes: "To notes",
          sets: [],
        );

        final result = base.copyWith(
          name: "Copied",
          parameters: params,
          primaryMuscleGroup: MuscleGroup.abductors,
          secondaryMuscleGroups: {},
          sets: base.sets,
        );
        final expected = Exercise.replaced(
          from: base,
          to: base.copyWith(
            name: "Copied",
            parameters: params,
            primaryMuscleGroup: MuscleGroup.abductors,
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
          parameters: SetParameters.repsWeight,
          primaryMuscleGroup: MuscleGroup.shoulders,
          secondaryMuscleGroups: {MuscleGroup.traps, MuscleGroup.triceps},
          restTime: const Duration(minutes: 2),
          notes: "To notes",
          sets: [],
        );
        final result = Exercise.replaced(from: base, to: base);

        expect(result.id, base.id);
        expectExercise(result, base);
      });
    });
  });
}
