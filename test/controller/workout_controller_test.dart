import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/controller/workout_controller.dart';
import 'package:gymtracker/model/model.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers.dart';
import '../test_helpers/mock_services.dart';
import '../test_helpers/widget_test_app.dart';

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    MockServices.setup();
    await initTestLocalizations();
  });

  tearDown(() {
    MockServices.tearDown();
  });

  group('WorkoutController -', () {
    test('finish metadata stays private until persistence succeeds', () async {
      final controller = MockServices.createWorkout(
        'Original',
        'routine',
        'Original notes',
      );
      final originalDate = controller.time;
      final pending = Completer<void>();
      when(
        () => MockServices.historyController.addNewWorkout(any()),
      ).thenAnswer((_) => pending.future);
      final date = DateTime(2026, 1, 1);
      final result = controller.submit(
        'Edited',
        const Duration(minutes: 20),
        details: WorkoutFinishDetails(
          startingTime: date,
          parentID: null,
          infobox: 'New notes',
        ),
      );
      await Future<void>.delayed(Duration.zero);
      expect(controller.time, originalDate);
      expect(controller.parentID, 'routine');
      expect(controller.infobox, 'Original notes');
      pending.complete();
      final workout = await result;
      expect(workout.startingDate, date);
      expect(workout.parentID, isNull);
      expect(workout.infobox, 'New notes');
      expect(workout.name, 'Edited');
      expect(controller.time, date);
      expect(controller.parentID, isNull);
    });

    test('failed submission does not apply finish metadata', () async {
      final controller = MockServices.createWorkout(
        'Original',
        'routine',
        'Notes',
      );
      final originalDate = controller.time;
      when(
        () => MockServices.historyController.addNewWorkout(any()),
      ).thenAnswer((_) async => throw StateError('Write failed'));
      await expectLater(
        controller.submit(
          'Edited',
          const Duration(minutes: 20),
          details: WorkoutFinishDetails(
            startingTime: DateTime(2026, 1, 1),
            parentID: null,
            infobox: null,
          ),
        ),
        throwsStateError,
      );
      expect(controller.time, originalDate);
      expect(controller.parentID, 'routine');
      expect(controller.infobox, 'Notes');
      expect(controller.name, 'Original');
    });

    test('concurrent submits write once and return the same workout', () async {
      final controller = MockServices.createWorkout('Workout', null, null);
      controller.exercises.add(exerciseHelper('ex1', 'Bench Press'));
      final pending = Completer<void>();
      final writes = <Workout>[];
      when(
        () => MockServices.historyController.addNewWorkout(any()),
      ).thenAnswer((invocation) {
        writes.add(invocation.positionalArguments.first as Workout);
        return pending.future;
      });
      final first = controller.submit('First', const Duration(minutes: 10));
      final second = controller.submit('Second', const Duration(minutes: 20));
      await Future<void>.delayed(Duration.zero);
      final count = writes.length;
      pending.complete();
      final results = await Future.wait([first, second]);
      expect(count, 1);
      expect(identical(results[0], results[1]), isTrue);
      expect(results.first.name, 'First');
    });

    test('submission error releases lock and allows retry', () async {
      final controller = MockServices.createWorkout('Workout', null, null);
      final pending = Completer<void>();
      when(
        () => MockServices.historyController.addNewWorkout(any()),
      ).thenAnswer((_) => pending.future);
      final first = controller.submit('Workout', const Duration(minutes: 10));
      final second = controller.submit('Ignored', Duration.zero);
      expect(controller.isSubmitting, isTrue);
      controller.publishExercises();
      expect(
        MockServices.container.read(workoutControllerProvider)!.isSubmitting,
        isTrue,
      );
      final expectations = Future.wait([
        expectLater(first, throwsStateError),
        expectLater(second, throwsStateError),
      ]);
      pending.completeError(StateError('Write failed'));
      await expectations;
      expect(controller.isSubmitting, isFalse);
      expect(
        MockServices.container.read(workoutControllerProvider)!.isSubmitting,
        isFalse,
      );
      when(
        () => MockServices.historyController.addNewWorkout(any()),
      ).thenAnswer((_) async {});
      await controller.submit('Retry', const Duration(minutes: 10));
      verify(
        () => MockServices.historyController.addNewWorkout(any()),
      ).called(2);
    });

    test(
      'late completion does not unlock a newer session submission',
      () async {
        final controller = MockServices.createWorkout('Old', null, null);
        final oldWrite = Completer<void>();
        final newWrite = Completer<void>();
        var writes = 0;
        when(
          () => MockServices.historyController.addNewWorkout(any()),
        ).thenAnswer((_) => ++writes == 1 ? oldWrite.future : newWrite.future);
        final old = controller.submit('Old', Duration.zero);
        await Future<void>.delayed(Duration.zero);
        MockServices.database.setCurrentUserId('new-owner');
        controller.start('New', null, null, saveInitial: false);
        expect(controller.isSubmitting, isFalse);
        final current = controller.submit('New', Duration.zero);
        await Future<void>.delayed(Duration.zero);
        oldWrite.complete();
        await old;
        expect(controller.isSubmitting, isTrue);
        expect(
          MockServices.container.read(workoutControllerProvider)!.isSubmitting,
          isTrue,
        );
        final duplicate = controller.submit('Ignored', Duration.zero);
        newWrite.complete();
        final results = await Future.wait([current, duplicate]);
        expect(results[0], same(results[1]));
        expect(writes, 2);
        expect(controller.isSubmitting, isFalse);
      },
    );

    test(
      'computed properties (progress, reps, liftedWeight) work correctly',
      () {
        final controller = MockServices.createWorkout(
          "Test Workout",
          null,
          null,
        );
        controller.exercises.addAll([
          exerciseHelper(
            "ex1",
            "Bench Press",
            sets: [
              GTSet(
                reps: 10,
                weight: 100,
                time: Duration.zero,
                parameters: GTSetParameters.repsWeight,
                kind: GTSetKind.normal,
                done: true,
              ),
              GTSet(
                reps: 8,
                weight: 110,
                time: Duration.zero,
                parameters: GTSetParameters.repsWeight,
                kind: GTSetKind.normal,
                done: false, // undone set
              ),
            ],
          ),
        ]);

        expect(controller.progress, 0.5); // 1 done, 1 undone
        expect(controller.reps, 10); // only done sets count
        expect(controller.liftedWeight, 1000.0); // 10 reps * 100 kg
      },
    );

    test('hasExercise & applyExerciseModification work correctly', () {
      final controller = MockServices.createWorkout("Test Workout", null, null);
      final template = exerciseHelper("ex1", "Bench Press");
      final concrete = template.copyWith(id: "concrete1", parentID: "ex1");
      controller.exercises.add(concrete);

      expect(controller.hasExercise(template), true);

      // Modify the exercise name on the template
      final modifiedTemplate = template.copyWith(name: "New Name");
      controller.applyExerciseModification(modifiedTemplate);

      expect(controller.exercises.first.asExercise.name, "New Name");
    });

    test('generateNameIfEmpty works correctly', () {
      final controller = MockServices.createWorkout("", null, null);
      controller.exercises.add(exerciseHelper("ex1", "Bench Press"));
      controller.generateNameIfEmpty();

      expect(controller.name.isNotEmpty, true);
      expect(controller.name.contains('Chest'), true);
    });

    test(
      'serialization & deserialization (save/fromSavedData) work correctly',
      () {
        final controller = MockServices.createWorkout(
          "Saved Workout",
          "parent123",
          "Some info",
        );
        controller.exercises.add(exerciseHelper("ex1", "Bench Press"));

        // Stub routinesController to return true for hasOngoingWorkout
        when(
          () => MockServices.routinesController.hasOngoingWorkout,
        ).thenReturn(true);

        controller.save();

        // Verify that databaseService.writeToOngoing was called
        verify(
          () => MockServices.databaseService.writeToOngoing(any()),
        ).called(1);

        // Deserialization
        final data = {
          'name': 'Saved Workout',
          'parentID': 'parent123',
          'infobox': 'Some info',
          'time': DateTime.now().millisecondsSinceEpoch,
          'isContinuation': false,
          'weightUnit': 'kg',
          'distanceUnit': 'km',
          'exercises': controller.exercises.map((e) => e.toJson()).toList(),
        };

        final restored = MockServices.restoreWorkout(data);
        expect(restored.name, 'Saved Workout');
        expect(restored.parentID, 'parent123');
        expect(restored.infobox, 'Some info');
        expect(restored.exercises.length, 1);
        expect(restored.exercises[0].id, 'ex1');
      },
    );

    test('cursor navigation works correctly', () {
      final controller = MockServices.createWorkout("Cursor Test", null, null);
      controller.exercises.addAll([
        exerciseHelper(
          "ex1",
          "Bench Press",
          sets: [
            GTSet(
              reps: 10,
              weight: 100,
              time: Duration.zero,
              parameters: GTSetParameters.repsWeight,
              kind: GTSetKind.normal,
              done: false,
            ),
            GTSet(
              reps: 8,
              weight: 110,
              time: Duration.zero,
              parameters: GTSetParameters.repsWeight,
              kind: GTSetKind.normal,
              done: false,
            ),
          ],
        ),
      ]);

      // Initial cursor should be at first set
      expect(controller.currentSetCursor, isNotNull);
      expect(controller.currentSetCursor!.setIndex, 0);

      // Move to next set cursor
      final moved = controller.moveSetCursorToNext();
      expect(moved, true);
      expect(controller.currentSetCursor!.setIndex, 1);

      // Move previous
      final movedBack = controller.moveSetCursorToPrevious();
      expect(movedBack, true);
      expect(controller.currentSetCursor!.setIndex, 0);
    });
  });
}
