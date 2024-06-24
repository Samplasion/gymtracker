import 'dart:math';

import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:skeletonizer/skeletonizer.dart';

Workout skeletonWorkout() => Workout(
      name: BoneMock.words(Random().nextInt(2) + 1),
      duration: Duration(minutes: Random().nextInt(60)),
      startingDate: DateTime.now(),
      exercises: List.generate(
        Random().nextInt(3) + 3,
        (index) => skeletonExercise(
          id: BoneMock.chars(10),
          name: BoneMock.words(2),
          notes: BoneMock.words(10),
        ),
      ),
    );

Exercise skeletonExercise({
  required String id,
  required String name,
  required String notes,
}) =>
    Exercise.raw(
      standard: false,
      supersedesID: null,
      id: BoneMock.chars(10),
      name: BoneMock.words(2),
      parameters: GTSetParameters.repsWeight,
      primaryMuscleGroup: GTMuscleGroup.abs,
      restTime: Duration(seconds: Random().nextInt(120)),
      notes: BoneMock.words(10),
      supersetID: null,
      workoutID: null,
      sets: List.generate(
        3,
        (index) => GTSet(
          parameters: GTSetParameters.repsWeight,
          kind: GTSetKind.normal,
          reps: Random().nextInt(10) + 1,
          weight: Random().nextDouble() * 100,
        ),
      ),
      skeleton: true,
    );
