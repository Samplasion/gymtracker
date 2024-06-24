import 'dart:math';

import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:skeletonizer/skeletonizer.dart';

GTRoutineFolder skeletonFolder([int? seed]) => GTRoutineFolder.generate(
      name: BoneMock.words(Random(seed).nextInt(3) + 1),
    );

Workout skeletonWorkout([int? seed]) => Workout(
      name: BoneMock.words(Random(seed).nextInt(2) + 1),
      duration: Duration(minutes: Random(seed).nextInt(60)),
      startingDate: DateTime.now(),
      exercises: List.generate(
        Random(seed).nextInt(3) + 3,
        (index) => skeletonExercise(
          id: BoneMock.chars(10),
          name: BoneMock.words(2),
          notes: BoneMock.words(10),
          seed: seed,
        ),
      ),
    );

Exercise skeletonExercise({
  required String id,
  required String name,
  required String notes,
  int? seed,
}) =>
    Exercise.raw(
      standard: false,
      supersedesID: null,
      id: BoneMock.chars(10),
      name: BoneMock.words(2),
      parameters: GTSetParameters.repsWeight,
      primaryMuscleGroup: GTMuscleGroup.abs,
      restTime: Duration(seconds: Random(seed).nextInt(120)),
      notes: BoneMock.words(10),
      supersetID: null,
      workoutID: null,
      sets: List.generate(
        3,
        (index) => GTSet(
          parameters: GTSetParameters.repsWeight,
          kind: GTSetKind.normal,
          reps: Random(seed).nextInt(10) + 1,
          weight: Random(seed).nextDouble() * 100,
        ),
      ),
      skeleton: true,
    );
