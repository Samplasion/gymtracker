import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/model/exercise.dart';

void expectAbstractExercise(Exercise result, Exercise expected) {
  expect(result.id, expected.id);
  expect(result.name, expected.name);
  expect(result.parameters, expected.parameters);
  expect(result.primaryMuscleGroup, expected.primaryMuscleGroup);
  expect(result.secondaryMuscleGroups, expected.secondaryMuscleGroups);
}

void expectExercise(
  Exercise result,
  Exercise expected, {
  bool checkWorkoutID = true,
  bool checkSupersetID = true,
}) {
  expectAbstractExercise(result, expected);
  expect(result.restTime, expected.restTime);
  expect(result.notes, expected.notes);
  if (checkWorkoutID) {
    expect(result.workoutID, expected.workoutID);
  }
  if (checkSupersetID) {
    expect(result.supersetID, expected.supersetID);
  }
  expect(result.sets.length, expected.sets.length);
  for (int i = 0; i < result.sets.length; i++) {
    expect(result.sets[i].kind, expected.sets[i].kind);
    expect(result.sets[i].parameters, expected.sets[i].parameters);
    expect(result.sets[i].reps, expected.sets[i].reps);
    expect(result.sets[i].weight, expected.sets[i].weight);
  }
}

void expectDouble(double actual, double expected, {double epsilon = 0.0001}) {
  expect((actual - expected).abs() < epsilon, true);
}
