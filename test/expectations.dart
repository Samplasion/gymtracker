import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/superset.dart';
import 'package:gymtracker/model/workout.dart';

void expectWorkout(Workout result, Workout expected) {
  expect(result.id, expected.id);
  expect(result.name, expected.name);
  expect(result.exercises.length, expected.exercises.length);
  expect(result.duration, expected.duration);
  expect(result.startingDate, expected.startingDate);
  // The conversion roundtrip coalesces null infoboxes to the empty string
  expect(result.infobox ?? '', expected.infobox ?? '');
  expect(result.parentID, expected.parentID);
  expect(result.weightUnit, expected.weightUnit);
  expect(result.distanceUnit, expected.distanceUnit);
  expect(result.completedBy, expected.completedBy);
  expect(result.completes, expected.completes);
  expect(result.folder, expected.folder);
  for (int i = 0; i < result.exercises.length; i++) {
    expect(result.exercises[i].runtimeType, expected.exercises[i].runtimeType);
    if (result.exercises[i] is Exercise) {
      expectExercise(
        result.exercises[i] as Exercise,
        expected.exercises[i] as Exercise,
      );
    } else if (result.exercises[i] is Superset) {
      // expectSuperset(result.exercises[i] as Superset, expected.exercises[i] as Superset);
    }
  }
}

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
  expect(result.supersedesID, expected.supersedesID);
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
