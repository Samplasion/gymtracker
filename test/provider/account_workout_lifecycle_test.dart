import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/controller/exercises_controller.dart';
import 'package:gymtracker/controller/workout_controller.dart';
import 'package:gymtracker/provider/bootstrap.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers.dart';
import '../test_helpers/data_controllers.dart';
import '../test_helpers/mock_services.dart';

void main() {
  setUp(MockServices.setup);
  tearDown(MockServices.tearDown);

  testWidgets('cancelled backup cannot write after the owner changes', (
    tester,
  ) async {
    when(
      () => MockServices.databaseService.createBackup(),
    ).thenAnswer((_) async {});
    final scheduler = BackupScheduler(MockServices.databaseService);
    scheduler.schedule();
    await tester.pump(const Duration(seconds: 30));
    scheduler.cancel();
    MockServices.database.setCurrentUserId('next-owner');
    await tester.pump(const Duration(minutes: 2));
    verifyNever(() => MockServices.databaseService.createBackup());
    scheduler.schedule();
    await tester.pump(const Duration(minutes: 1));
    verify(() => MockServices.databaseService.createBackup()).called(1);
    scheduler.dispose();
  });

  test(
    'account suspension cancels deferred backup before saving the workout',
    () async {
      MockServices.database.setCurrentUserId('owner');
      MockServices.createWorkout('Current workout', null, null);
      final lifecycle = MockServices.container.read(
        Provider((ref) => AccountWorkoutLifecycle(ref)),
      );
      await lifecycle.suspend();
      verifyInOrder([
        () => MockServices.backupScheduler.cancel(),
        () => MockServices.databaseService.writeToOngoing(any()),
      ]);
      expect(MockServices.container.read(workoutControllerProvider), isNull);
    },
  );

  test(
    'exercise edits cannot propagate into another account after awaiting a write',
    () async {
      final exercise = exerciseHelper('parent', 'Parent');
      registerFallbackValue(exercise);
      final pending = Completer<void>();
      MockServices.database.setCurrentUserId('owner');
      when(
        () => MockServices.routinesController.hasExercise(any()),
      ).thenReturn(true);
      when(
        () => MockServices.historyController.hasExercise(any()),
      ).thenReturn(true);
      when(
        () => MockServices.routinesController.applyExerciseModification(any()),
      ).thenAnswer((_) async {});
      when(
        () => MockServices.historyController.applyExerciseModification(any()),
      ).thenAnswer((_) => pending.future);
      final controller = dataController(ExercisesController.new);
      final result = controller.applyExerciseModification(exercise);
      MockServices.database.setCurrentUserId('next-owner');
      pending.complete();
      await result;
      verifyNever(
        () => MockServices.routinesController.applyExerciseModification(any()),
      );
    },
  );
}
