import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/controller/workout_controller.dart';
import 'package:gymtracker/service/native.dart';
import 'package:mocktail/mocktail.dart';

import '../test_helpers/mock_services.dart';

class _Native extends Mock implements NativeService {
  final calls = <({bool active, String id, DateTime start, bool save})>[];

  @override
  void setIsWorkoutRunning(
    bool isWorkoutRunning, {
    required String workoutId,
    required DateTime start,
    bool save = true,
  }) {
    calls.add((
      active: isWorkoutRunning,
      id: workoutId,
      start: start,
      save: save,
    ));
  }
}

void main() {
  late ProviderContainer container;
  late _Native native;
  late WorkoutController controller;

  setUp(() {
    MockServices.setup();
    native = _Native();
    container = ProviderContainer(
      overrides: [
        ...MockServices.defaultOverrides,
        nativeServiceProvider.overrideWithValue(native),
      ],
    );
    controller = container.read(workoutControllerProvider.notifier);
  });
  tearDown(() {
    container.dispose();
    MockServices.tearDown();
  });

  test(
    'completion saves; cancellation discards and a new workout has a new ID',
    () async {
      controller.start('First', null, null, saveInitial: false);
      final first = native.calls.single;
      await controller.cancel(saveHealthWorkout: true);
      expect(native.calls.last, (
        active: false,
        id: first.id,
        start: first.start,
        save: true,
      ));
      controller.start('Second', null, null, saveInitial: false);
      expect(native.calls.last.id, isNot(first.id));
      final second = native.calls.last;
      await controller.cancel();
      expect(native.calls.last, (
        active: false,
        id: second.id,
        start: second.start,
        save: false,
      ));
    },
  );

  test(
    'persisted identity and start survive restore before native startup',
    () async {
      controller.start('Workout', null, null, saveInitial: false);
      await controller.persist(force: true);
      final data =
          verify(
                () => MockServices.databaseService.writeToOngoing(captureAny()),
              ).captured.single
              as Map<String, dynamic>;
      final first = native.calls.single;
      expect(data['nativeWorkoutId'], first.id);
      controller.restore(data);
      expect(native.calls.last.id, first.id);
      expect(
        native.calls.last.start.millisecondsSinceEpoch,
        first.start.millisecondsSinceEpoch,
      );
    },
  );

  test(
    'account suspension discards native collection and keeps app recovery',
    () async {
      controller.start('A', null, null, saveInitial: false);
      final id = native.calls.single.id;
      await controller.suspend();
      expect(native.calls.last.active, false);
      expect(native.calls.last.save, false);
      expect(native.calls.last.id, id);
      final data =
          verify(
                () => MockServices.databaseService.writeToOngoing(captureAny()),
              ).captured.single
              as Map<String, dynamic>;
      expect(data['nativeWorkoutId'], isNot(id));
      expect(container.read(workoutControllerProvider), isNull);
    },
  );

  test('legacy recovery receives a new stable native UUID', () async {
    controller.restore({'name': 'Legacy', 'exercises': [], 'time': 1234567});
    expect(native.calls.single.id, matches(RegExp(r'^[0-9a-f-]{36}$')));
    expect(native.calls.single.start.millisecondsSinceEpoch, 1234567);
    await controller.persist(force: true);
    final data =
        verify(
              () => MockServices.databaseService.writeToOngoing(captureAny()),
            ).captured.single
            as Map<String, dynamic>;
    expect(data['nativeWorkoutId'], native.calls.single.id);
  });
}
