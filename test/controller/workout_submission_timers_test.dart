import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/controller/stopwatch_controller.dart';
import 'package:gymtracker/controller/workout_controller.dart';
import 'package:gymtracker/model/model.dart';
import 'package:gymtracker/struct/stopwatch_extended.dart';
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
  tearDown(MockServices.tearDown);

  late String setId;
  void startTimers() {
    final controller = MockServices.container.read(
      workoutControllerProvider.notifier,
    );
    final exercise = exerciseHelper(
      'timed-exercise',
      'Plank',
      parameters: GTSetParameters.time,
    );
    controller.exercises.add(exercise);
    setId = exercise.sets.single.id;
    final stopwatch = MockServices.stopwatchController.globalStopwatch;
    stopwatch.stopwatch = StopwatchEx.fromMilliseconds(600000);
    stopwatch.start();
    MockServices.countdownController.setCountdown(const Duration(minutes: 5));
    MockServices.stopwatchController.addStopwatch(
      TimeFieldStopwatch(
        setID: setId,
        getCurrentTime: () => '00:10',
        onTick: (_, _, _) {},
      ),
    );
  }

  void expectTimersPreserved() {
    expect(MockServices.countdownController.isActive, isTrue);
    expect(MockServices.stopwatchController.globalStopwatch.isStopped, isFalse);
    expect(
      MockServices.stopwatchController.globalStopwatch.currentDuration,
      greaterThanOrEqualTo(const Duration(minutes: 10)),
    );
    expect(MockServices.stopwatchController.isRunning(setId), isTrue);
  }

  test('failed submission preserves workout timers for retry', () async {
    final controller = MockServices.createWorkout('Workout', null, null);
    startTimers();
    when(
      () => MockServices.historyController.addNewWorkout(any()),
    ).thenAnswer((_) async => throw StateError('Write failed'));

    await expectLater(
      controller.submit('Workout', const Duration(minutes: 10)),
      throwsStateError,
    );

    expectTimersPreserved();
  });

  test('timers stay active until successful persistence', () async {
    final controller = MockServices.createWorkout('Workout', null, null);
    startTimers();
    final write = Completer<void>();
    when(
      () => MockServices.historyController.addNewWorkout(any()),
    ).thenAnswer((_) => write.future);
    final submission = controller.submit(
      'Workout',
      const Duration(minutes: 10),
    );
    await Future<void>.delayed(Duration.zero);
    // Complete before asserting so a failing test leaves no pending submission.
    final countdownWasActive = MockServices.countdownController.isActive;
    final stopwatchWasRunning =
        !MockServices.stopwatchController.globalStopwatch.isStopped;
    write.complete();
    await submission;

    expect(countdownWasActive, isTrue);
    expect(stopwatchWasRunning, isTrue);
    expect(MockServices.countdownController.isActive, isFalse);
    expect(MockServices.stopwatchController.isRunning(setId), isFalse);
    expect(
      MockServices.stopwatchController.globalStopwatch.currentDuration,
      Duration.zero,
    );
  });

  test('late submission does not reset timers of a newer session', () async {
    final controller = MockServices.createWorkout('Old', null, null);
    final write = Completer<void>();
    when(
      () => MockServices.historyController.addNewWorkout(any()),
    ).thenAnswer((_) => write.future);
    final submission = controller.submit('Old', Duration.zero);
    await Future<void>.delayed(Duration.zero);
    controller.start('New', null, null, saveInitial: false);
    startTimers();

    write.complete();
    await submission;

    expectTimersPreserved();
  });
}
