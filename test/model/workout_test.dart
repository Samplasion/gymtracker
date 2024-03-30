import 'dart:math';

import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/model/superset.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:test/test.dart';

import '../expectations.dart';

void main() {
  group('Workout model -', () {
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
      startingDate: DateTime.now().subtract(const Duration(minutes: 1)),
      parentID: null,
      infobox: 'Test Infobox',
      completedBy: null,
      completes: null,
    );
    Exercise newExercise() {
      final number = Random().nextInt(100).toString();
      return Exercise.custom(
        name: 'Test Exercise $number',
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
        notes: 'Test Notes $number',
      );
    }

    group("WorkoutDifference class -", () {
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

      group("difference should be correctly calculated (changed exercises)",
          () {
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
        test('with changed notes', () {
          final workout2 = workout.clone();
          workout2.exercises[0] = (workout2.exercises[0] as Exercise)
              .copyWith(notes: "These notes have been changed");
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

        test("with reordered exercises", () {
          final workout1 = workout.clone();
          workout1.exercises.add(newExercise());
          final workout2 = workout1.clone();
          final exs = workout2.exercises.reversed.toList();
          workout2.exercises
            ..clear()
            ..addAll(exs);
          expect(
            WorkoutDifference.fromWorkouts(
              oldWorkout: workout1,
              newWorkout: workout2,
            ),
            const WorkoutDifference.raw(
              addedExercises: 0,
              removedExercises: 0,
              changedExercises: 2,
            ),
          );
        });
      });

      test("with failure and stripping sets", () {
        final workout1 = workout.copyWith(exercises: [
          for (final kind
              in SetKind.values.where((kind) => !kind.shouldKeepInRoutine)) ...[
            Exercise.custom(
              name: "Test Exercise $kind",
              parameters: SetParameters.repsWeight,
              sets: [
                ExSet(
                  reps: 10,
                  weight: 100,
                  time: const Duration(seconds: 60),
                  parameters: SetParameters.repsWeight,
                  kind: kind,
                ),
              ],
              primaryMuscleGroup: MuscleGroup.abs,
              secondaryMuscleGroups: {MuscleGroup.lowerBack},
              restTime: const Duration(seconds: 60),
              parentID: null,
              notes: 'Test Notes',
            ),
          ]
        ]);
        final workout2 = workout1.copyWith(exercises: [
          for (final ex in workout1.exercises.whereType<Exercise>()) ...[
            ex.copyWith(
              sets: [
                for (final set in ex.sets) ...[
                  set.copyWith(
                    reps: 20,
                  ),
                ],
              ],
            ),
          ],
        ]);

        expect(
          WorkoutDifference.fromWorkouts(
            oldWorkout: workout1,
            newWorkout: workout2,
          ),
          const WorkoutDifference.raw(
            addedExercises: 0,
            removedExercises: 0,
            changedExercises: 0,
          ),
        );
      });

      test('difference should be correctly calculated (with supersets)', () {
        final workout2 = workout.clone();
        workout2.exercises[0] = Superset(
          restTime: const Duration(seconds: 60),
          exercises: [
            workout2.exercises[0] as Exercise,
            newExercise(),
          ],
          notes: "Superset notes",
        );
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

        final workout3 = workout2.clone();
        (workout3.exercises[0] as Superset).exercises
          ..add(newExercise())
          ..add(
            newExercise(),
          );
        expect(
          WorkoutDifference.fromWorkouts(
            oldWorkout: workout2,
            newWorkout: workout3,
          ),
          const WorkoutDifference.raw(
            addedExercises: 0,
            removedExercises: 0,
            changedExercises: 1,
          ),
        );

        final workout4 = workout3.clone();
        (workout4.exercises[0] as Superset).notes = "Changed notes";
        expect(
          WorkoutDifference.fromWorkouts(
            oldWorkout: workout3,
            newWorkout: workout4,
          ),
          const WorkoutDifference.raw(
            addedExercises: 0,
            removedExercises: 0,
            changedExercises: 1,
          ),
        );

        final workout5 = workout4.clone();
        (workout5.exercises[0] as Superset).restTime =
            const Duration(seconds: 120);
        expect(
          WorkoutDifference.fromWorkouts(
            oldWorkout: workout4,
            newWorkout: workout5,
          ),
          const WorkoutDifference.raw(
            addedExercises: 0,
            removedExercises: 0,
            changedExercises: 1,
          ),
        );

        final workout6 = workout5.clone();
        (workout6.exercises[0] as Superset).exercises
          ..clear()
          ..addAll(workout5.exercises.reversed.whereType<Exercise>().toList());
        expect(
          WorkoutDifference.fromWorkouts(
            oldWorkout: workout5,
            newWorkout: workout6,
          ),
          const WorkoutDifference.raw(
            addedExercises: 0,
            removedExercises: 0,
            changedExercises: 1,
          ),
        );

        final workout7 = workout6.clone();
        workout7.exercises.insert(0, newExercise());
        (workout7.exercises[1] as Superset).exercises
          ..clear()
          ..addAll(
              (workout6.exercises[0] as Superset).exercises.reversed.toList());
        expect(
          WorkoutDifference.fromWorkouts(
            // S, E
            oldWorkout: workout6,
            // E, S, E
            newWorkout: workout7,
          ),
          const WorkoutDifference.raw(
            addedExercises: 1,
            removedExercises: 0,
            changedExercises: 2,
          ),
        );
      });
    });

    group("shouldShowAsInfobox(text) -", () {
      test("returns false for empty strings",
          () => expect(Workout.shouldShowAsInfobox(""), false));
      test("returns false for newline strings",
          () => expect(Workout.shouldShowAsInfobox("\n"), false));
      test(
          "returns false for empty rich texts",
          () => expect(
              Workout.shouldShowAsInfobox('[{"insert": "\\n"}]'), false));
      test("returns true for everything else", () {
        expect(Workout.shouldShowAsInfobox('hello'), true);
        expect(
            Workout.shouldShowAsInfobox(
                '[{"insert":"Mitochondria is the "},{"insert":"powerhouse","attributes":{"bold":true}},{"insert":" of the "},{"insert":"cell","attributes":{"italic":true}},{"insert":".\\n"}]'),
            true);
      });
    });

    group("workout combination -", () {
      test("should combine two workouts", () {
        final workout1 = workout.copyWith(completedBy: "2");
        final workout2 = Workout(
          id: "2",
          name: 'Test Workout 2',
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
          completes: "1",
        );

        final combined = Workout.combine(workout1, workout2);

        expect(Workout.canCombine(workout1, workout2), true);
        expect(combined.exercises.length, 4);
        expect(combined.exercises[0].id, "1");
        expect(combined.exercises[1].id, "2");
        expect(combined.exercises[2].id, "1");
        expect(combined.exercises[3].id, "2");
        expect(combined.startingDate, workout.startingDate);
        expect(combined.duration, const Duration(minutes: 2));
        expect(
          combined.infobox!.asQuillDocument().toPlainText(),
          "Test Infobox\nTest Infobox\n",
        );
        expect(combined.weightUnit, Weights.kg);
        expect(combined.distanceUnit, Distance.km);
        expect(combined.completes, null);
        expect(combined.completedBy, null);
      });

      test(
        "should convert weights and distances to the unit defined by the first workout",
        () {
          final workout1 = workout.copyWith(completedBy: "2");
          final workout2 = Workout(
            id: "2",
            name: 'Test Workout 2',
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
                parameters: SetParameters.distance,
                sets: [
                  ExSet(
                    distance: 10,
                    time: const Duration(seconds: 60),
                    parameters: SetParameters.distance,
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
            completes: "1",
            weightUnit: Weights.lb,
            distanceUnit: Distance.mi,
          );

          final combined = Workout.combine(
            workout1.copyWith(exercises: []),
            workout2,
          );

          expect(Workout.canCombine(workout1.copyWith(exercises: []), workout2),
              true);
          expect(combined.weightUnit, Weights.kg);
          expect(combined.distanceUnit, Distance.km);
          expectDouble(combined.exercises[0].sets[0].weight!, 45.359237);
          expectDouble(combined.exercises[1].sets[0].distance!, 16.09344);
        },
      );

      test("asserts if the second workout comes before the first", () {
        final workout1 = workout.copyWith(completedBy: "2");
        final workout2 = Workout(
          id: "2",
          name: 'Test Workout 2',
          exercises: [],
          duration: const Duration(seconds: 60),
          startingDate: DateTime.now().subtract(const Duration(minutes: 10)),
          parentID: null,
          infobox: 'Test Infobox',
          completedBy: null,
          completes: "1",
        );

        expect(Workout.canCombine(workout1, workout2), false);
        expect(() => Workout.combine(workout1, workout2),
            throwsA(isA<AssertionError>()));
      });

      // test("asserts if any of the workouts is not concrete", () {
      //   final workout1 = workout.copyWith(completedBy: "2");
      //   final workout2 = Workout(
      //     id: "2",
      //     name: 'Test Workout 2',
      //     exercises: [],
      //     startingDate: DateTime.now(),
      //   );

      //   expect(Workout.canCombine(workout1, workout2), false);
      //   expect(() => Workout.combine(workout1, workout2),
      //       throwsA(isA<AssertionError>()));
      //   expect(
      //     Workout.canCombine(
      //       workout2.copyWith(
      //         // Avoid previously tested assertion
      //         startingDate:
      //             DateTime.now().subtract(const Duration(minutes: 10)),
      //         duration: const Duration(seconds: 60),
      //       ),
      //       workout1.copyWith.duration(null),
      //     ),
      //     false,
      //   );
      //   expect(
      //       () => Workout.combine(
      //             workout2.copyWith(
      //               // Avoid previously tested assertion
      //               startingDate:
      //                   DateTime.now().subtract(const Duration(minutes: 10)),
      //               duration: const Duration(seconds: 60),
      //             ),
      //             workout1.copyWith.duration(null),
      //           ),
      //       throwsA(isA<AssertionError>()));
      // });

      test("asserts if the first workout isn't a continuation of the second",
          () {
        final workout2 = Workout(
          id: "2",
          name: 'Test Workout 2',
          exercises: [],
          startingDate: DateTime.now(),
          duration: const Duration(minutes: 1),
        );

        expect(
          Workout.canCombine(
              workout,
              workout2.copyWith(
                completes: "fake id",
              )),
          false,
        );
        expect(
            () => Workout.combine(
                  workout,
                  workout2.copyWith(
                    completes: "fake id",
                  ),
                ),
            throwsA(isA<AssertionError>()));

        expect(
          Workout.canCombine(
            workout2.copyWith(
              // Avoid previously tested assertion
              startingDate:
                  DateTime.now().subtract(const Duration(minutes: 10)),
              completes: "fake id",
            ),
            workout.copyWith.completes("fake id"),
          ),
          false,
        );
        expect(
            () => Workout.combine(
                  workout2.copyWith(
                    // Avoid previously tested assertion
                    startingDate:
                        DateTime.now().subtract(const Duration(minutes: 10)),
                    completes: "fake id",
                  ),
                  workout.copyWith.completes("fake id"),
                ),
            throwsA(isA<AssertionError>()));
      });
    });
  });
}
