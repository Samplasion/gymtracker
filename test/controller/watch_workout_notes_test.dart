import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/controller/workout_controller.dart';
import 'package:gymtracker/model/model.dart';
import 'package:gymtracker/model/native.dart';
import 'package:gymtracker/service/native.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers.dart';
import '../test_helpers/mock_services.dart';
import '../test_helpers/widget_test_app.dart';

class _Native extends Mock implements NativeService {
  NativeWorkoutStateMessage? latest;
  @override
  void setExerciseParameters(NativeWorkoutStateMessage parameters) {
    latest = parameters;
  }
}

void main() {
  late ProviderContainer container;
  late WorkoutController workout;
  late _Native native;
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    MockServices.setup();
    await initTestLocalizations();
    native = _Native();
    container = ProviderContainer(
      overrides: [
        ...MockServices.defaultOverrides,
        nativeServiceProvider.overrideWithValue(native),
      ],
    );
    workout = container.read(workoutControllerProvider.notifier);
    workout.start('Workout', null, null, saveInitial: false);
  });
  tearDown(() {
    container.dispose();
    MockServices.tearDown();
  });

  test(
    'Watch snapshot retains Quill notes and app-specific highlighted attributes',
    () {
      const delta =
          '[{"insert":"Controlla la discesa","attributes":{"bold":true,"highlighted":"primary"}},{"insert":"\\n"}]';
      final exercise = exerciseHelper('bench', 'Bench').copyWith(notes: delta);
      workout.setExercises([exercise]);
      workout.refreshWearableData();
      expect(native.latest!.exerciseID, exercise.id);
      expect(native.latest!.exerciseNotes, delta);
      expect(native.latest!.supersetNotes, isEmpty);
      expect(native.latest!.toJson()['exerciseNotes'], delta);
    },
  );

  test(
    'cursor carries its own exercise notes and its parent superset notes',
    () {
      final first = exerciseHelper(
        'first',
        'First',
      ).copyWith(notes: 'First note');
      final second = exerciseHelper(
        'second',
        'Second',
      ).copyWith(notes: 'Second note');
      workout.setExercises([
        supersetHelper(
          'group',
          exercises: [first, second],
        ).copyWith(notes: ' Alternate without rest '),
      ]);
      workout.refreshWearableData();
      expect(native.latest!.exerciseNotes, 'First note');
      expect(native.latest!.supersetNotes, 'Alternate without rest');
      workout.moveSetCursorToNext();
      workout.refreshWearableData();
      expect(native.latest!.exerciseID, second.id);
      expect(native.latest!.exerciseNotes, 'Second note');
      expect(native.latest!.supersetNotes, 'Alternate without rest');
      workout.setExercises([
        exerciseHelper('single', 'Single').copyWith(notes: '  '),
      ]);
      workout.refreshWearableData();
      expect(native.latest!.exerciseNotes, isEmpty);
      expect(native.latest!.supersetNotes, isEmpty);
    },
  );
}
