import 'package:drift/native.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:test/test.dart';

import '../expectations.dart';

void main() {
  late GTDatabase database;
  setUp(() async {
    database = GTDatabaseImpl.withQueryExecutor(
      NativeDatabase.memory(logStatements: true),
    );
  });

  tearDown(() async {
    await database.close();
  });

  group("routine methods", () {
    test("insertRoutine(Workout)", () async {
      expect(await database.getAllRoutinesFuture(), isEmpty);

      var workoutID = "1";
      var workout = Workout(
        name: "Test Workout",
        id: workoutID,
        exercises: [
          Exercise.custom(
            name: "Test Exercise",
            parameters: .repsWeight,
            sets: [
              for (final kind in GTSetKind.values)
                GTSet(kind: kind, parameters: .repsWeight, reps: 0, weight: 0),
            ],
            primaryMuscleGroup: .abs,
            restTime: const Duration(seconds: 10),
            notes: "Test notes.",
            supersetID: null,
            workoutID: workoutID,
            equipment: .cable,
            parentID: "parent-id",
          ),
        ],
      );
      await database.insertRoutine(workout);

      expectWorkout(await database.getRoutine(workout.id), workout);
    });
    test("getAllRoutines() emits", () async {
      var workoutID = "1";
      var workout = Workout(
        name: "Test Workout",
        id: workoutID,
        exercises: [
          Exercise.custom(
            name: "Test Exercise",
            parameters: .repsWeight,
            sets: [
              for (final kind in GTSetKind.values)
                GTSet(kind: kind, parameters: .repsWeight, reps: 0, weight: 0),
            ],
            primaryMuscleGroup: .abs,
            restTime: const Duration(seconds: 10),
            notes: "Test notes.",
            supersetID: null,
            workoutID: workoutID,
            equipment: .cable,
            parentID: "parent-id",
          ),
        ],
      );

      final stream = database.getAllRoutines();
      stream.listen(
        expectAsync1((event) {
          expect(event.length, 1);
          expectWorkout(event.first, workout);
        }),
      );
      await database.insertRoutine(workout);
    });
    test("updateRoutine(Workout)", () async {
      var workoutID = "1";
      var workout = Workout(
        name: "Test Workout",
        id: workoutID,
        exercises: [
          Exercise.custom(
            name: "Test Exercise",
            parameters: .repsWeight,
            sets: [
              for (final kind in GTSetKind.values)
                GTSet(kind: kind, parameters: .repsWeight, reps: 0, weight: 0),
            ],
            primaryMuscleGroup: .abs,
            restTime: const Duration(seconds: 10),
            notes: "Test notes.",
            supersetID: null,
            workoutID: workoutID,
            equipment: .cable,
            parentID: "parent-id",
          ),
        ],
      );
      await database.insertRoutine(workout);
      expectWorkout(await database.getRoutine(workout.id), workout);

      final workout2 = workout.copyWith(
        name: "Updated Workout",
        exercises: [
          Exercise.custom(
            name: "Updated Exercise",
            parameters: .repsWeight,
            sets: [
              for (final kind in GTSetKind.values)
                GTSet(kind: kind, parameters: .repsWeight, reps: 0, weight: 0),
            ],
            primaryMuscleGroup: .abs,
            restTime: const Duration(seconds: 10),
            notes: "Updated notes.",
            supersetID: null,
            workoutID: workoutID,
            equipment: .cable,
            parentID: "parent-id",
          ),
        ],
      );
      await database.updateRoutine(workout2);
      expectWorkout(await database.getRoutine(workout.id), workout2);

      expect(
        () async => await database.updateRoutine(workout.copyWith(id: "")),
        throwsA(isA<ArgumentError>()),
      );
    });
    group("writeAllRoutines(List<Workout>)", () {
      test("writes all routines to the database", () async {
        final routines = [
          Workout(name: "Routine 1", id: "1", exercises: []),
          Workout(name: "Routine 2", id: "2", exercises: []),
        ];
        await database.writeAllRoutines(routines);
        final fetchedRoutines = await database.getAllRoutinesFuture();
        expect(fetchedRoutines.length, routines.length);
        for (int i = 0; i < routines.length; i++) {
          expectWorkout(fetchedRoutines[i], routines[i]);
        }
      });
      test("overwrites previous routines", () async {
        final routines = [
          Workout(
            name: "Routine 1",
            id: "1",
            exercises: [
              Exercise.custom(
                name: "Updated Exercise",
                parameters: .repsWeight,
                sets: [
                  for (final kind in GTSetKind.values)
                    GTSet(
                      kind: kind,
                      parameters: .repsWeight,
                      reps: 0,
                      weight: 0,
                    ),
                ],
                primaryMuscleGroup: .abs,
                restTime: const Duration(seconds: 10),
                notes: "Updated notes.",
                supersetID: null,
                workoutID: "1",
                equipment: .cable,
                parentID: "parent-id",
              ),
            ],
          ),
          Workout(name: "Routine 2", id: "2", exercises: []),
        ];
        await database.writeAllRoutines(routines);

        final newRoutines = [
          Workout(
            name: "Routine 3",
            id: "3",
            exercises: [
              Exercise.custom(
                name: "Updated Exercise",
                parameters: .repsWeight,
                sets: [
                  for (final kind in GTSetKind.values)
                    GTSet(
                      kind: kind,
                      parameters: .repsWeight,
                      reps: 0,
                      weight: 0,
                    ),
                ],
                primaryMuscleGroup: .abs,
                restTime: const Duration(seconds: 10),
                notes: "Updated notes.",
                supersetID: null,
                workoutID: "3",
                equipment: .cable,
                parentID: "parent-id",
              ),
            ],
          ),
        ];
        await database.writeAllRoutines(newRoutines);

        final fetchedRoutines = await database.getAllRoutinesFuture();
        expect(fetchedRoutines.length, newRoutines.length);
        for (int i = 0; i < newRoutines.length; i++) {
          expectWorkout(fetchedRoutines[i], newRoutines[i]);
        }
      });
    });
    test(
      "overwriteAllRoutineExercises(List<model.WorkoutExercisable>) overwrites all exercises",
      () async {
        final routines = [
          Workout(
            name: "Routine 1",
            id: "1",
            exercises: [
              Exercise.custom(
                name: "Exercise",
                parameters: .repsWeight,
                sets: [
                  for (final kind in GTSetKind.values)
                    GTSet(
                      kind: kind,
                      parameters: .repsWeight,
                      reps: 0,
                      weight: 0,
                    ),
                ],
                primaryMuscleGroup: .abs,
                restTime: const Duration(seconds: 10),
                notes: "notes.",
                supersetID: null,
                workoutID: "1",
                equipment: .cable,
                parentID: "parent-id",
              ),
            ],
          ),
          Workout(name: "Routine 2", id: "2", exercises: []),
        ];
        await database.writeAllRoutines(routines);

        var exercise = Exercise.custom(
          name: "Updated Exercise",
          parameters: .repsWeight,
          sets: [
            for (final kind in GTSetKind.values)
              GTSet(kind: kind, parameters: .repsWeight, reps: 0, weight: 0),
          ],
          primaryMuscleGroup: .abs,
          restTime: const Duration(seconds: 10),
          notes: "Updated notes.",
          supersetID: null,
          workoutID: "2",
          equipment: .cable,
          parentID: "parent-id",
        );
        await database.overwriteAllRoutineExercises([exercise]);

        final result = await database.getAllRoutinesFuture();
        expect(result.length, 2);
        expect(result[0].exercises.length, 0);
        expect(result[1].exercises.length, 1);
        expect(result[1].exercises[0].runtimeType, Exercise);
        expectExercise(result[1].exercises[0].asExercise, exercise);
      },
    );
    test("deleteRoutine(String)", () async {
      final routine = Workout(name: "Routine 1", id: "1", exercises: []);
      await database.writeAllRoutines([routine]);
      expect(await database.getAllRoutinesFuture(), isNotEmpty);

      await database.deleteRoutine(routine.id);
      expect(await database.getAllRoutinesFuture(), isEmpty);
    });
  });

  group("history methods", () {
    // Stream<List<model.Workout>> getAllHistoryWorkouts();
    // Future<List<model.Workout>> getAllHistoryWorkoutsFuture();
    // Future<model.Workout> getHistoryWorkout(String id);
    // Future<void> insertHistoryWorkout(model.Workout workout);
    // Future<void> deleteHistoryWorkout(String id);
    // Future<void> updateHistoryWorkout(model.Workout workout);
    // Future<void> writeAllHistoryWorkouts(List<model.Workout> routines);
    // Future<void> overwriteAllHistoryWorkoutExercises(
    //   List<model.WorkoutExercisable> historyWorkoutExercises,
    // );

    test("insertHistoryWorkout(Workout)", () async {
      expect(await database.getAllHistoryWorkoutsFuture(), isEmpty);

      var workoutID = "1";
      var workout = Workout(
        name: "Test Workout",
        id: workoutID,
        startingDate: DateTime(2026, 08, 22, 12, 0, 0),
        duration: const Duration(minutes: 30),
        exercises: [
          Exercise.custom(
            name: "Test Exercise",
            parameters: .repsWeight,
            sets: [
              for (final kind in GTSetKind.values)
                GTSet(kind: kind, parameters: .repsWeight, reps: 0, weight: 0),
            ],
            primaryMuscleGroup: .abs,
            restTime: const Duration(seconds: 10),
            notes: "Test notes.",
            supersetID: null,
            workoutID: workoutID,
            equipment: .cable,
            parentID: "parent-id",
          ),
        ],
      );
      await database.insertHistoryWorkout(workout);

      expectWorkout(await database.getHistoryWorkout(workout.id), workout);
    });
    test("getAllHistoryWorkouts() emits", () async {
      var workoutID = "1";
      var workout = Workout(
        name: "Test Workout",
        id: workoutID,
        startingDate: DateTime(2026, 08, 22, 12, 0, 0),
        duration: const Duration(minutes: 30),
        exercises: [
          Exercise.custom(
            name: "Test Exercise",
            parameters: .repsWeight,
            sets: [
              for (final kind in GTSetKind.values)
                GTSet(kind: kind, parameters: .repsWeight, reps: 0, weight: 0),
            ],
            primaryMuscleGroup: .abs,
            restTime: const Duration(seconds: 10),
            notes: "Test notes.",
            supersetID: null,
            workoutID: workoutID,
            equipment: .cable,
            parentID: "parent-id",
          ),
        ],
      );

      final stream = database.getAllHistoryWorkouts();
      stream.listen(
        expectAsync1((event) {
          expect(event.length, 1);
          expectWorkout(event.first, workout);
        }),
      );
      await database.insertHistoryWorkout(workout);
    });
    test("updateHistoryWorkout(Workout)", () async {
      var workoutID = "1";
      var workout = Workout(
        name: "Test Workout",
        id: workoutID,
        startingDate: DateTime(2026, 08, 22, 12, 0, 0),
        duration: const Duration(minutes: 30),
        exercises: [
          Exercise.custom(
            name: "Test Exercise",
            parameters: .repsWeight,
            sets: [
              for (final kind in GTSetKind.values)
                GTSet(kind: kind, parameters: .repsWeight, reps: 0, weight: 0),
            ],
            primaryMuscleGroup: .abs,
            restTime: const Duration(seconds: 10),
            notes: "Test notes.",
            supersetID: null,
            workoutID: workoutID,
            equipment: .cable,
            parentID: "parent-id",
          ),
        ],
      );
      await database.insertHistoryWorkout(workout);
      expectWorkout(await database.getHistoryWorkout(workout.id), workout);

      final workout2 = workout.copyWith(
        name: "Updated Workout",
        exercises: [
          Exercise.custom(
            name: "Updated Exercise",
            parameters: .repsWeight,
            sets: [
              for (final kind in GTSetKind.values)
                GTSet(kind: kind, parameters: .repsWeight, reps: 0, weight: 0),
            ],
            primaryMuscleGroup: .abs,
            restTime: const Duration(seconds: 10),
            notes: "Updated notes.",
            supersetID: null,
            workoutID: workoutID,
            equipment: .cable,
            parentID: "parent-id",
          ),
        ],
      );
      await database.updateHistoryWorkout(workout2);
      expectWorkout(await database.getHistoryWorkout(workout.id), workout2);

      expect(
        () async =>
            await database.updateHistoryWorkout(workout.copyWith(id: "")),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () async => await database.updateHistoryWorkout(
          workout.copyWith.duration(null),
        ),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () async => await database.updateHistoryWorkout(
          workout.copyWith.startingDate(null),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
    group("writeAllHistoryWorkouts(List<Workout>)", () {
      test("writes all history workouts to the database", () async {
        final routines = [
          Workout(
            name: "Routine 1",
            id: "1",
            exercises: [],
            startingDate: DateTime(2026, 08, 22, 12, 0, 0),
            duration: const Duration(minutes: 30),
          ),
          Workout(
            name: "Routine 2",
            id: "2",
            exercises: [],
            startingDate: DateTime(2026, 08, 22, 12, 0, 0),
            duration: const Duration(minutes: 30),
          ),
        ];
        await database.writeAllHistoryWorkouts(routines);
        final fetchedRoutines = await database.getAllHistoryWorkoutsFuture();
        expect(fetchedRoutines.length, routines.length);
        for (int i = 0; i < routines.length; i++) {
          expectWorkout(fetchedRoutines[i], routines[i]);
        }
      });
      test("overwrites previous workouts", () async {
        final routines = [
          Workout(
            name: "Routine 1",
            id: "1",
            startingDate: DateTime(2026, 08, 22, 12, 0, 0),
            duration: const Duration(minutes: 30),
            exercises: [
              Exercise.custom(
                name: "Updated Exercise",
                parameters: .repsWeight,
                sets: [
                  for (final kind in GTSetKind.values)
                    GTSet(
                      kind: kind,
                      parameters: .repsWeight,
                      reps: 0,
                      weight: 0,
                    ),
                ],
                primaryMuscleGroup: .abs,
                restTime: const Duration(seconds: 10),
                notes: "Updated notes.",
                supersetID: null,
                workoutID: "1",
                equipment: .cable,
                parentID: "parent-id",
              ),
            ],
          ),
          Workout(
            name: "Routine 2",
            id: "2",
            exercises: [],
            startingDate: DateTime(2026, 08, 22, 12, 0, 0),
            duration: const Duration(minutes: 30),
          ),
        ];
        await database.writeAllHistoryWorkouts(routines);

        final newRoutines = [
          Workout(
            name: "Routine 3",
            id: "3",
            startingDate: DateTime(2026, 08, 22, 12, 0, 0),
            duration: const Duration(minutes: 30),
            exercises: [
              Exercise.custom(
                name: "Updated Exercise",
                parameters: .repsWeight,
                sets: [
                  for (final kind in GTSetKind.values)
                    GTSet(
                      kind: kind,
                      parameters: .repsWeight,
                      reps: 0,
                      weight: 0,
                    ),
                ],
                primaryMuscleGroup: .abs,
                restTime: const Duration(seconds: 10),
                notes: "Updated notes.",
                supersetID: null,
                workoutID: "3",
                equipment: .cable,
                parentID: "parent-id",
              ),
            ],
          ),
        ];
        await database.writeAllHistoryWorkouts(newRoutines);

        final fetchedRoutines = await database.getAllHistoryWorkoutsFuture();
        expect(fetchedRoutines.length, newRoutines.length);
        for (int i = 0; i < newRoutines.length; i++) {
          expectWorkout(fetchedRoutines[i], newRoutines[i]);
        }
      });
    });
    test(
      "overwriteAllHistoryWorkoutExercises(List<model.WorkoutExercisable>) overwrites all exercises",
      () async {
        final routines = [
          Workout(
            name: "Routine 1",
            id: "1",
            startingDate: DateTime(2026, 08, 22, 12, 0, 0),
            duration: const Duration(minutes: 30),
            exercises: [
              Exercise.custom(
                name: "Exercise",
                parameters: .repsWeight,
                sets: [
                  for (final kind in GTSetKind.values)
                    GTSet(
                      kind: kind,
                      parameters: .repsWeight,
                      reps: 0,
                      weight: 0,
                    ),
                ],
                primaryMuscleGroup: .abs,
                restTime: const Duration(seconds: 10),
                notes: "notes.",
                supersetID: null,
                workoutID: "1",
                equipment: .cable,
                parentID: "parent-id",
              ),
            ],
          ),
          Workout(
            name: "Routine 2",
            id: "2",
            exercises: [],
            startingDate: DateTime(2026, 08, 22, 12, 0, 0),
            duration: const Duration(minutes: 30),
          ),
        ];
        await database.writeAllHistoryWorkouts(routines);

        var exercise = Exercise.custom(
          name: "Updated Exercise",
          parameters: .repsWeight,
          sets: [
            for (final kind in GTSetKind.values)
              GTSet(kind: kind, parameters: .repsWeight, reps: 0, weight: 0),
          ],
          primaryMuscleGroup: .abs,
          restTime: const Duration(seconds: 10),
          notes: "Updated notes.",
          supersetID: null,
          workoutID: "2",
          equipment: .cable,
          parentID: "parent-id",
        );
        await database.overwriteAllHistoryWorkoutExercises([exercise]);

        final result = await database.getAllHistoryWorkoutsFuture();
        expect(result.length, 2);
        expect(result[0].exercises.length, 0);
        expect(result[1].exercises.length, 1);
        expect(result[1].exercises[0].runtimeType, Exercise);
        expectExercise(result[1].exercises[0].asExercise, exercise);
      },
    );
    test("deleteHistoryWorkout(String)", () async {
      final routine = Workout(
        name: "Routine 1",
        id: "1",
        exercises: [],
        startingDate: DateTime(2026, 08, 22, 12, 0, 0),
        duration: const Duration(minutes: 30),
      );
      await database.writeAllHistoryWorkouts([routine]);
      expect(await database.getAllHistoryWorkoutsFuture(), isNotEmpty);

      await database.deleteHistoryWorkout(routine.id);
      expect(await database.getAllHistoryWorkoutsFuture(), isEmpty);
    });
  });
}
