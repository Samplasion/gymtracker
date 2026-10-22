import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/controller/countdown_controller.dart';
import 'package:gymtracker/controller/stopwatch_controller.dart';
import 'package:gymtracker/controller/workout_controller.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/struct/stopwatch_extended.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers.dart';
import '../test_helpers/mock_services.dart';

void main() {
  setUp(MockServices.setup);
  tearDown(MockServices.tearDown);

  testWidgets(
    'published workouts are immutable snapshots across subsequent edits',
    (tester) async {
      final controller = MockServices.createWorkout('Workout', null, null);
      controller.setExercises([exerciseHelper('exercise', 'Bench Press')]);
      final before = MockServices.container.read(workoutControllerProvider)!;
      final previousWeight =
          before.workout.exercises.first.asExercise.sets.first.weight;
      controller.onSetValueChange(
        (exerciseIndex: 0, supersetIndex: null),
        0,
        controller.exercises.first.asExercise.sets.first.copyWith(weight: 42),
      );
      expect(
        before.workout.exercises.first.asExercise.sets.first.weight,
        previousWeight,
      );
      expect(
        MockServices.container
            .read(workoutControllerProvider)!
            .workout
            .exercises
            .first
            .asExercise
            .sets
            .first
            .weight,
        42,
      );
      expect(() => before.workout.exercises.clear(), throwsUnsupportedError);
      expect(
        () => before.workout.exercises.first.asExercise.sets.clear(),
        throwsUnsupportedError,
      );
      await controller.persist(force: true);
      await tester.pump();
    },
  );

  testWidgets(
    'closing a provider cancels pending input without saving or deleting',
    (tester) async {
      final controller = MockServices.createWorkout('Workout', null, null);
      controller.setExercises([exerciseHelper('exercise', 'Bench Press')]);
      controller.onSetValueChange(
        (exerciseIndex: 0, supersetIndex: null),
        0,
        controller.exercises.first.asExercise.sets.first.copyWith(weight: 42),
      );
      await tester.runAsync(
        () => MockServices.database.setOngoing({'name': 'persisted'}),
      );
      clearInteractions(MockServices.databaseService);
      MockServices.container.dispose();
      await tester.pump(const Duration(seconds: 1));
      verifyNever(() => MockServices.databaseService.writeToOngoing(any()));
      final persisted = await tester.runAsync(
        () => MockServices.database.watchOngoing().first,
      );
      expect(persisted, {'name': 'persisted'});
      // Leave a fresh container for the shared teardown, which also closes the database.
      MockServices.container = ProviderContainer();
    },
  );

  testWidgets('countdown expiration clears both timestamps', (tester) async {
    final countdown = MockServices.countdownController;
    countdown.setCountdown(const Duration(seconds: 2));
    expect(countdown.isActive, isTrue);
    await tester.pump(const Duration(seconds: 2));
    expect(countdown.isActive, isFalse);
    expect(countdown.targetTime, isNull);
    expect(countdown.startingTime, isNull);
  });

  testWidgets(
    'timer disposal cancels field ticks without flushing its binding',
    (tester) async {
      final ticks = <String>[];
      final controller = MockServices.stopwatchController;
      controller.addStopwatch(
        TimeFieldStopwatch(
          setID: 'set',
          getCurrentTime: () => '00:10',
          onTick: (_, _, text) => ticks.add(text),
        ),
      );
      await tester.pump(const Duration(seconds: 1));
      expect(ticks, ['00:11']);
      MockServices.container.dispose();
      await tester.pump(const Duration(seconds: 2));
      expect(ticks, ['00:11']);
      MockServices.container = ProviderContainer();
    },
  );

  testWidgets(
    'suspension flushes pending input and clears active state before account switch',
    (tester) async {
      final controller = MockServices.createWorkout('Workout', null, null);
      controller.setExercises([exerciseHelper('exercise', 'Bench Press')]);
      controller.onSetValueChange(
        (exerciseIndex: 0, supersetIndex: null),
        0,
        controller.exercises.first.asExercise.sets.first.copyWith(weight: 42),
      );
      await controller.suspend();
      expect(MockServices.container.read(workoutControllerProvider), isNull);
      final saved =
          verify(
                () => MockServices.databaseService.writeToOngoing(captureAny()),
              ).captured.single
              as Map<String, dynamic>;
      expect(saved['exercises'][0]['sets'][0]['weight'], 42);
      await tester.pump(const Duration(seconds: 1));
      verifyNever(() => MockServices.databaseService.writeToOngoing(any()));
    },
  );

  test(
    'restoring a paused stopwatch preserves its nominal elapsed duration',
    () {
      MockServices.stopwatchController.globalStopwatch.start();
      MockServices.restoreWorkout({
        'name': 'Restored',
        'parentID': null,
        'infobox': null,
        'exercises': [],
        'globalStopwatch': DateTime.now().millisecondsSinceEpoch - 5000,
        'globalStopwatchPaused': true,
        'globalStopwatchNominalDuration': 5000,
      });
      final stopwatch = MockServices.stopwatchController.globalStopwatch;
      expect(stopwatch.isStopped, isTrue);
      expect(stopwatch.currentDuration, const Duration(seconds: 5));
    },
  );

  testWidgets(
    'global elapsed snapshots follow injected time and freeze on pause',
    (tester) async {
      var now = DateTime(2026, 10, 21);
      final container = ProviderContainer(
        overrides: [
          workoutClockProvider.overrideWithValue(_TestClock(() => now)),
          workoutStopwatchFactoryProvider.overrideWithValue(
            (elapsed) => _TestStopwatch(() => now, elapsed),
          ),
        ],
      );
      addTearDown(container.dispose);
      final controller = container.read(stopwatchControllerProvider.notifier);
      controller.globalStopwatch.start();
      now = now.add(const Duration(seconds: 2));
      await tester.pump(const Duration(milliseconds: 200));
      expect(
        container.read(stopwatchControllerProvider).elapsed,
        const Duration(seconds: 2),
      );
      controller.globalStopwatch.pause();
      now = now.add(const Duration(seconds: 5));
      await tester.pump(const Duration(seconds: 1));
      expect(
        container.read(stopwatchControllerProvider).elapsed,
        const Duration(seconds: 2),
      );
      controller.globalStopwatch.reset();
      expect(
        container.read(stopwatchControllerProvider).elapsed,
        Duration.zero,
      );
    },
  );

  test('global stopwatch publishes immutable running state', () {
    final controller = MockServices.stopwatchController;
    final before = MockServices.container.read(stopwatchControllerProvider);
    controller.globalStopwatch.start();
    expect(before.running['global'], isFalse);
    expect(
      MockServices.container
          .read(stopwatchControllerProvider)
          .running['global'],
      isTrue,
    );
    controller.globalStopwatch.pause();
    expect(
      MockServices.container
          .read(stopwatchControllerProvider)
          .running['global'],
      isFalse,
    );
  });
}

class _TestClock extends WorkoutClock {
  const _TestClock(this.currentTime);
  final DateTime Function() currentTime;
  @override
  DateTime now() => currentTime();
}

class _TestStopwatch extends StopwatchEx {
  _TestStopwatch(this.now, int elapsed)
    : _elapsed = Duration(milliseconds: elapsed);
  final DateTime Function() now;
  Duration _elapsed;
  DateTime? _started;
  @override
  Duration get elapsed =>
      _elapsed +
      (_started == null ? Duration.zero : now().difference(_started!));
  @override
  void start() {
    _started ??= now();
  }

  @override
  void stop() {
    _elapsed = elapsed;
    _started = null;
  }

  @override
  void reset() {
    _elapsed = Duration.zero;
    if (_started != null) _started = now();
  }
}
