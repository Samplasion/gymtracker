import 'dart:math';

import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:test/test.dart';

void main() {
  group('Workout model', () {
    final workout = Workout(
      id: "1",
      name: 'Test Workout',
      exercises: [
        Exercise.custom(
          id: "1",
          name: 'Test Exercise',
          parameters: SetParameters.repsWeight,
          sets: [
            ExSet(
              reps: 10,
              weight: 100,
              time: const Duration(seconds: 60),
              parameters: SetParameters.repsWeight,
              kind: SetKind.normal,
            ),
            ExSet(
              reps: 10,
              weight: 100,
              time: const Duration(seconds: 60),
              parameters: SetParameters.repsWeight,
              kind: SetKind.normal,
            ),
          ],
          primaryMuscleGroup: MuscleGroup.abs,
          secondaryMuscleGroups: {MuscleGroup.lowerBack},
          restTime: const Duration(seconds: 60),
          parentID: null,
          notes: 'Test Notes',
        ),
        Exercise.custom(
          id: "2",
          name: 'Test Exercise 2',
          parameters: SetParameters.repsWeight,
          sets: [
            ExSet(
              reps: 10,
              weight: 100,
              time: const Duration(seconds: 60),
              parameters: SetParameters.repsWeight,
              kind: SetKind.normal,
            ),
            ExSet(
              reps: 10,
              weight: 100,
              time: const Duration(seconds: 60),
              parameters: SetParameters.repsWeight,
              kind: SetKind.normal,
            ),
          ],
          primaryMuscleGroup: MuscleGroup.abs,
          secondaryMuscleGroups: {MuscleGroup.lowerBack},
          restTime: const Duration(seconds: 60),
          parentID: null,
          notes: 'Test Notes',
        ),
      ],
      duration: const Duration(seconds: 60),
      startingDate: DateTime.now(),
      parentID: null,
      infobox: 'Test Infobox',
      completedBy: null,
      completes: null,
    );
    Exercise newExercise() {
      final id = Random().nextInt(100).toString();
      return Exercise.custom(
        id: id,
        name: 'Test Exercise $id',
        parameters: SetParameters.repsWeight,
        sets: [
          ExSet(
            reps: 10,
            weight: 100,
            time: const Duration(seconds: 60),
            parameters: SetParameters.repsWeight,
            kind: SetKind.normal,
          ),
          ExSet(
            reps: 10,
            weight: 100,
            time: const Duration(seconds: 60),
            parameters: SetParameters.repsWeight,
            kind: SetKind.normal,
          ),
        ],
        primaryMuscleGroup: MuscleGroup.abs,
        secondaryMuscleGroups: {MuscleGroup.lowerBack},
        restTime: const Duration(seconds: 60),
        parentID: null,
        notes: 'Test Notes',
      );
    }

    test('difference should be correctly calculated (added exercise)', () {
      final workout2 = workout.clone();
      workout2.exercises.add(newExercise());
      expect(
        WorkoutDifference.fromWorkouts(
          oldWorkout: workout,
          newWorkout: workout2,
        ),
        const WorkoutDifference.raw(
          addedExercises: 1,
          removedExercises: 0,
          changedExercises: 0,
        ),
      );
    });

    test('difference should be correctly calculated (removed exercise)', () {
      final workout2 = workout.clone();
      workout2.exercises.clear();
      expect(
        WorkoutDifference.fromWorkouts(
          oldWorkout: workout,
          newWorkout: workout2,
        ),
        const WorkoutDifference.raw(
          addedExercises: 0,
          removedExercises: 2,
          changedExercises: 0,
        ),
      );
    });

    group("difference should be correctly calculated (changed exercises)", () {
      test('with an added set', () {
        final workout2 = workout.clone();
        workout2.exercises[0].sets.add(ExSet(
          reps: 10,
          weight: 100,
          time: const Duration(seconds: 60),
          parameters: SetParameters.repsWeight,
          kind: SetKind.normal,
        ));
        expect(
          WorkoutDifference.fromWorkouts(
            oldWorkout: workout,
            newWorkout: workout2,
          ),
          const WorkoutDifference.raw(
            addedExercises: 0,
            removedExercises: 0,
            changedExercises: 1,
          ),
        );
      });
      test('with a removed set', () {
        final workout2 = workout.clone();
        workout2.exercises[0].sets.removeLast();
        expect(
          WorkoutDifference.fromWorkouts(
            oldWorkout: workout,
            newWorkout: workout2,
          ),
          const WorkoutDifference.raw(
            addedExercises: 0,
            removedExercises: 0,
            changedExercises: 1,
          ),
        );
      });
      test('with a changed set kind', () {
        final workout2 = workout.clone();
        workout2.exercises[0].sets[0].kind = SetKind.failureStripping;
        expect(
          WorkoutDifference.fromWorkouts(
            oldWorkout: workout,
            newWorkout: workout2,
          ),
          const WorkoutDifference.raw(
            addedExercises: 0,
            removedExercises: 0,
            changedExercises: 1,
          ),
        );
      });
      test('with a different set weight', () {
        final workout2 = workout.clone();
        workout2.exercises[0].sets[0].weight = 200;
        expect(
          WorkoutDifference.fromWorkouts(
            oldWorkout: workout,
            newWorkout: workout2,
          ),
          const WorkoutDifference.raw(
            addedExercises: 0,
            removedExercises: 0,
            changedExercises: 1,
          ),
        );
      });
      test('with different reps weight', () {
        final workout2 = workout.clone();
        workout2.exercises[0].sets[0].weight = 200;
        expect(
          WorkoutDifference.fromWorkouts(
            oldWorkout: workout,
            newWorkout: workout2,
          ),
          const WorkoutDifference.raw(
            addedExercises: 0,
            removedExercises: 0,
            changedExercises: 1,
          ),
        );
      });
    });
  });
}
