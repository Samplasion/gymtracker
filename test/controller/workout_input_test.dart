import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/workout_controller.dart';
import 'package:gymtracker/main.dart' show globalContainer;
import 'package:gymtracker/model/model.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers.dart';
import '../test_helpers/mock_services.dart';
import '../test_helpers/widget_test_app.dart';

void main() {
  late WorkoutController controller;

  setUp(() {
    MockServices.setup();
    when(
      () => MockServices.routinesController.hasOngoingWorkout,
    ).thenReturn(true.obs);
    controller = WorkoutController('Workout', null, null);
    controller.exercises.add(exerciseHelper('ex1', 'Bench Press'));
  });

  tearDown(MockServices.tearDown);

  Future<void> runInputTest(
    WidgetTester tester,
    Future<void> Function() body,
  ) async {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpWidget(const WidgetTestApp(child: SizedBox()));
    Get.put(controller);
    await tester.pump();
    await tester.pump();
    clearInteractions(MockServices.databaseService);
    try {
      await body();
    } finally {
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      Get.delete<WorkoutController>();
      await tester.pump();
      await tester.pumpWidget(const SizedBox());
      globalContainer.dispose();
    }
  }

  void typeWeight(double weight) {
    controller.callbacks.onSetValueChange(
      (exerciseIndex: 0, supersetIndex: null),
      0,
      controller.exercises.first.asExercise.sets.first.copyWith(weight: weight),
    );
  }

  testWidgets(
    'typing notifies once and batches saves with the latest value',
    (tester) async => runInputTest(tester, () async {
      var notifications = 0;
      final subscription = controller.exercises.listen((_) => notifications++);
      typeWeight(4);
      await tester.pump(const Duration(milliseconds: 100));
      typeWeight(42);
      await tester.pump(const Duration(milliseconds: 100));
      expect(notifications, 2);
      verifyNever(() => MockServices.databaseService.writeToOngoing(any()));

      await tester.pump(const Duration(milliseconds: 250));
      final saved =
          verify(
                () => MockServices.databaseService.writeToOngoing(captureAny()),
              ).captured.single
              as Map<String, dynamic>;
      final exercises = saved['exercises'] as List;
      expect(exercises.single['sets'][0]['weight'], 42);
      await subscription.cancel();
    }),
  );

  testWidgets(
    'explicit persistence flushes and cancels a pending input save',
    (tester) async => runInputTest(tester, () async {
      typeWeight(42);
      await controller.persist(force: true);
      verify(
        () => MockServices.databaseService.writeToOngoing(any()),
      ).called(1);
      await tester.pump(const Duration(seconds: 1));
      verifyNever(() => MockServices.databaseService.writeToOngoing(any()));
    }),
  );

  testWidgets(
    'backgrounding flushes pending input immediately',
    (tester) async => runInputTest(tester, () async {
      typeWeight(42);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      verify(
        () => MockServices.databaseService.writeToOngoing(any()),
      ).called(1);
      await tester.pump(const Duration(seconds: 1));
      verifyNever(() => MockServices.databaseService.writeToOngoing(any()));
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    }),
  );

  testWidgets(
    'pending input never saves into a different account',
    (tester) async => runInputTest(tester, () async {
      typeWeight(42);
      MockServices.database.setCurrentUserId('another-user');
      await tester.pump(const Duration(seconds: 1));
      verifyNever(() => MockServices.databaseService.writeToOngoing(any()));
    }),
  );
}
