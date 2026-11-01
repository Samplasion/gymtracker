import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/model/workout.dart';
import '../helpers.dart';

void main() {
  test('replacement with equal set values is not mistaken for no change', () {
    final a = exerciseHelper('a', 'A');
    final b = exerciseHelper('b', 'B');
    final diff = WorkoutDifference.fromWorkouts(
      oldWorkout: Workout(name: 'Plan', exercises: [a]),
      newWorkout: Workout(name: 'Plan', exercises: [b]),
    );
    expect(diff.addedExercises, 1);
    expect(diff.removedExercises, 1);
    expect(diff.isEmpty, false);
  });
  test('reordering is separate from content changes', () {
    final a = exerciseHelper('a', 'A');
    final b = exerciseHelper('b', 'B');
    final diff = WorkoutDifference.fromWorkouts(
      oldWorkout: Workout(name: 'Plan', exercises: [a, b]),
      newWorkout: Workout(name: 'Plan', exercises: [b, a]),
    );
    expect(diff.changedExercises, 0);
    expect(diff.reorderedExercises, 2);
    expect(diff.isEmpty, false);
  });
  test('session children retain the routine identity', () {
    final a = exerciseHelper('a', 'A');
    final routine = Workout(name: 'Plan', exercises: [a]);
    final session = routine.withRegeneratedExerciseIDs(superseding: true);
    expect(
      WorkoutDifference.fromWorkouts(
        oldWorkout: routine,
        newWorkout: session,
      ).isEmpty,
      true,
    );
  });
  test('metadata-only changes remain visible', () {
    final a = Workout(name: 'A', exercises: []);
    final b = a.copyWith(name: 'B', infobox: 'Notes');
    final diff = WorkoutDifference.fromWorkouts(oldWorkout: a, newWorkout: b);
    expect(diff.metadataChanged, true);
    expect(diff.isEmpty, false);
  });
}
