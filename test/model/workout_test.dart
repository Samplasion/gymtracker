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
  final workout = Workout(
    id: "1",
    name: 'Test Workout',
    exercises: [
      Exercise.custom(
        id: "1",
        name: 'Test Exercise',
        parameters: GTSetParameters.repsWeight,
        sets: [
          GTSet(
            reps: 10,
            weight: 100,
            time: const Duration(seconds: 60),
            parameters: GTSetParameters.repsWeight,
            kind: GTSetKind.normal,
          ),
          GTSet(
            reps: 10,
            weight: 100,
            time: const Duration(seconds: 60),
            parameters: GTSetParameters.repsWeight,
            kind: GTSetKind.normal,
          ),
        ],
        primaryMuscleGroup: GTMuscleGroup.abs,
        secondaryMuscleGroups: {GTMuscleGroup.lowerBack},
        restTime: const Duration(seconds: 60),
        parentID: null,
        notes: 'Test Notes',
        workoutID: null,
        supersetID: null,
      ),
      Exercise.custom(
        id: "2",
        name: 'Test Exercise 2',
        parameters: GTSetParameters.repsWeight,
        sets: [
          GTSet(
            reps: 10,
            weight: 100,
            time: const Duration(seconds: 60),
            parameters: GTSetParameters.repsWeight,
            kind: GTSetKind.normal,
          ),
          GTSet(
            reps: 10,
            weight: 100,
            time: const Duration(seconds: 60),
            parameters: GTSetParameters.repsWeight,
            kind: GTSetKind.normal,
          ),
        ],
        primaryMuscleGroup: GTMuscleGroup.abs,
        secondaryMuscleGroups: {GTMuscleGroup.lowerBack},
        restTime: const Duration(seconds: 60),
        parentID: null,
        notes: 'Test Notes',
        workoutID: null,
        supersetID: null,
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
      parameters: GTSetParameters.repsWeight,
      sets: [
        GTSet(
          reps: 10,
          weight: 100,
          time: const Duration(seconds: 60),
          parameters: GTSetParameters.repsWeight,
          kind: GTSetKind.normal,
        ),
        GTSet(
          reps: 10,
          weight: 100,
          time: const Duration(seconds: 60),
          parameters: GTSetParameters.repsWeight,
          kind: GTSetKind.normal,
        ),
      ],
      primaryMuscleGroup: GTMuscleGroup.abs,
      secondaryMuscleGroups: {GTMuscleGroup.lowerBack},
      restTime: const Duration(seconds: 60),
      parentID: null,
      notes: 'Test Notes $number',
      workoutID: null,
      supersetID: null,
    );
  }

  group('Workout model -', () {
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
          workout2.exercises[0].sets.add(GTSet(
            reps: 10,
            weight: 100,
            time: const Duration(seconds: 60),
            parameters: GTSetParameters.repsWeight,
            kind: GTSetKind.normal,
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
          workout2.exercises[0].sets[0] = workout2.exercises[0].sets[0].copyWith
              .kind(GTSetKind.failureStripping);
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
          workout2.exercises[0].sets[0] =
              workout2.exercises[0].sets[0].copyWith.weight(200);
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
          workout2.exercises[0].sets[0] =
              workout2.exercises[0].sets[0].copyWith.weight(200);
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
          for (final kind in GTSetKind.values
              .where((kind) => !kind.shouldKeepInRoutine)) ...[
            Exercise.custom(
              name: "Test Exercise $kind",
              parameters: GTSetParameters.repsWeight,
              sets: [
                GTSet(
                  reps: 10,
                  weight: 100,
                  time: const Duration(seconds: 60),
                  parameters: GTSetParameters.repsWeight,
                  kind: kind,
                ),
              ],
              primaryMuscleGroup: GTMuscleGroup.abs,
              secondaryMuscleGroups: {GTMuscleGroup.lowerBack},
              restTime: const Duration(seconds: 60),
              parentID: null,
              notes: 'Test Notes',
              workoutID: null,
              supersetID: null,
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
          workoutID: null,
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
        workout4.exercises[0] =
            (workout4.exercises[0] as Superset).copyWith.notes("Changed notes");
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
        workout5.exercises[0] = (workout5.exercises[0] as Superset)
            .copyWith
            .restTime(const Duration(seconds: 120));
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
              parameters: GTSetParameters.repsWeight,
              sets: [
                GTSet(
                  reps: 10,
                  weight: 100,
                  time: const Duration(seconds: 60),
                  parameters: GTSetParameters.repsWeight,
                  kind: GTSetKind.normal,
                ),
                GTSet(
                  reps: 10,
                  weight: 100,
                  time: const Duration(seconds: 60),
                  parameters: GTSetParameters.repsWeight,
                  kind: GTSetKind.normal,
                ),
              ],
              primaryMuscleGroup: GTMuscleGroup.abs,
              secondaryMuscleGroups: {GTMuscleGroup.lowerBack},
              restTime: const Duration(seconds: 60),
              parentID: null,
              notes: 'Test Notes',
              workoutID: null,
              supersetID: null,
            ),
            Exercise.custom(
              id: "2",
              name: 'Test Exercise 2',
              parameters: GTSetParameters.repsWeight,
              sets: [
                GTSet(
                  reps: 10,
                  weight: 100,
                  time: const Duration(seconds: 60),
                  parameters: GTSetParameters.repsWeight,
                  kind: GTSetKind.normal,
                ),
                GTSet(
                  reps: 10,
                  weight: 100,
                  time: const Duration(seconds: 60),
                  parameters: GTSetParameters.repsWeight,
                  kind: GTSetKind.normal,
                ),
              ],
              primaryMuscleGroup: GTMuscleGroup.abs,
              secondaryMuscleGroups: {GTMuscleGroup.lowerBack},
              restTime: const Duration(seconds: 60),
              parentID: null,
              notes: 'Test Notes',
              workoutID: null,
              supersetID: null,
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
                parameters: GTSetParameters.repsWeight,
                sets: [
                  GTSet(
                    reps: 10,
                    weight: 100,
                    time: const Duration(seconds: 60),
                    parameters: GTSetParameters.repsWeight,
                    kind: GTSetKind.normal,
                  ),
                ],
                primaryMuscleGroup: GTMuscleGroup.abs,
                secondaryMuscleGroups: {GTMuscleGroup.lowerBack},
                restTime: const Duration(seconds: 60),
                parentID: null,
                notes: 'Test Notes',
                workoutID: null,
                supersetID: null,
              ),
              Exercise.custom(
                id: "2",
                name: 'Test Exercise 2',
                parameters: GTSetParameters.distance,
                sets: [
                  GTSet(
                    distance: 10,
                    time: const Duration(seconds: 60),
                    parameters: GTSetParameters.distance,
                    kind: GTSetKind.normal,
                  ),
                ],
                primaryMuscleGroup: GTMuscleGroup.abs,
                secondaryMuscleGroups: {GTMuscleGroup.lowerBack},
                restTime: const Duration(seconds: 60),
                parentID: null,
                notes: 'Test Notes',
                workoutID: null,
                supersetID: null,
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
  group('SynthesizedWorkout class -', () {
    final routine1 = Workout(
      id: "r1",
      name: "R1",
      exercises: [
        newExercise().copyWith.workoutID("r2"),
      ],
    );
    final routine2 = Workout(
      id: "r2",
      name: "R2",
      exercises: [
        Superset(
          id: "s1",
          exercises: [newExercise().copyWith.workoutID("r2")],
          restTime: Duration.zero,
          workoutID: "r2",
        ),
      ],
    );

    final workout1 = routine1.copyWith(
      startingDate: DateTime.now(),
      duration: Duration.zero,
    );
    final workout2 = routine2.copyWith(
      startingDate: DateTime.now(),
      duration: Duration.zero,
    );

    group("constructor should assert", () {
      test("if the component list is empty", () {
        expect(() => SynthesizedWorkout([]), throwsA(isA<AssertionError>()));
      });
      test("if we're nesting synthesized workouts", () {
        expect(
            () => SynthesizedWorkout([
                  routine1,
                  SynthesizedWorkout([routine2])
                ]),
            throwsA(isA<AssertionError>()));
      });
      test("if the workouts aren't all concrete or not concrete", () {
        expect(() => SynthesizedWorkout([routine1, workout2]),
            throwsA(isA<AssertionError>()));
      });
    });

    final synthesizedRoutine = SynthesizedWorkout([routine1, routine2]);
    final synthesizedWorkout = SynthesizedWorkout([workout1, workout2]);

    group("synthesized routine -", () {
      test("values are relayed correctly", () {
        expect(synthesizedRoutine.isConcrete, false);
        expect(synthesizedRoutine.id, routine1.id);
        expect(synthesizedRoutine.name, routine1.name);
        expect(synthesizedRoutine.allSets, routine1.allSets + routine2.allSets);
        expect(synthesizedRoutine.exercises.length,
            (routine1.exercises + routine2.exercises).length);
        for (int i = 0; i < synthesizedWorkout.exercises.length; i++) {
          if (synthesizedWorkout.exercises[i] is Superset) continue;
          expectExercise(synthesizedWorkout.exercises[i] as Exercise,
              (routine1.exercises + routine2.exercises)[i] as Exercise);
        }
        expect(synthesizedRoutine.displayExerciseCount,
            routine1.displayExerciseCount + routine2.displayExerciseCount);
        expect(synthesizedRoutine.progress,
            (routine1.progress + routine2.progress) / 2);
        expect(synthesizedRoutine.liftedWeight,
            routine1.liftedWeight + routine2.liftedWeight);
        expect(synthesizedRoutine.distanceRun,
            routine1.distanceRun + routine2.distanceRun);
      });

      test("methods should throw", () {
        expect(() => synthesizedRoutine.clone(),
            throwsA(isA<SynthesizedWorkoutMethodException>()));
        expect(() => synthesizedRoutine.regenerateID(),
            throwsA(isA<SynthesizedWorkoutMethodException>()));
        expect(() => synthesizedRoutine.toRoutine(),
            throwsA(isA<SynthesizedWorkoutMethodException>()));
        expect(() => synthesizedRoutine.withFilters(),
            throwsA(isA<SynthesizedWorkoutMethodException>()));
        expect(() => synthesizedRoutine.withRegeneratedExerciseIDs(),
            throwsA(isA<SynthesizedWorkoutMethodException>()));
      });
    });
    group("synthesized workout -", () {
      test("values are relayed correctly", () {
        expect(synthesizedWorkout.isConcrete, true);
        expect(synthesizedWorkout.id, workout1.id);
        expect(synthesizedWorkout.name, workout1.name);
        expect(synthesizedWorkout.allSets, workout1.allSets + workout2.allSets);
        expect(synthesizedWorkout.exercises.length,
            (workout1.exercises + workout2.exercises).length);
        for (int i = 0; i < synthesizedWorkout.exercises.length; i++) {
          if (synthesizedWorkout.exercises[i] is Superset) continue;
          expectExercise(synthesizedWorkout.exercises[i] as Exercise,
              (workout1.exercises + workout2.exercises)[i] as Exercise);
        }
        expect(synthesizedWorkout.displayExerciseCount,
            workout1.displayExerciseCount + workout2.displayExerciseCount);
        expect(synthesizedWorkout.progress,
            (workout1.progress + workout2.progress) / 2);
        expect(synthesizedWorkout.liftedWeight,
            workout1.liftedWeight + workout2.liftedWeight);
        expect(synthesizedWorkout.distanceRun,
            workout1.distanceRun + workout2.distanceRun);
        expect(synthesizedWorkout.startingDate, workout1.startingDate);
        expect(synthesizedWorkout.duration,
            workout1.duration! + workout2.duration!);
      });

      test("methods should throw", () {
        expect(() => synthesizedWorkout.clone(),
            throwsA(isA<SynthesizedWorkoutMethodException>()));
        expect(() => synthesizedWorkout.regenerateID(),
            throwsA(isA<SynthesizedWorkoutMethodException>()));
        expect(() => synthesizedWorkout.toRoutine(),
            throwsA(isA<SynthesizedWorkoutMethodException>()));
        expect(() => synthesizedWorkout.withFilters(),
            throwsA(isA<SynthesizedWorkoutMethodException>()));
        expect(() => synthesizedWorkout.withRegeneratedExerciseIDs(),
            throwsA(isA<SynthesizedWorkoutMethodException>()));
      });
    });
  });
}
