import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/controller/exercises_controller.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/controller/workout_controller.dart';
import 'package:gymtracker/model/model.dart';
import 'package:gymtracker/provider/bootstrap.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers.dart';
import '../test_helpers/data_controllers.dart';
import '../test_helpers/mock_services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    registerFallbackValue(exerciseHelper('e', 'E'));
    registerFallbackValue(AchievementTrigger.workout);
  });
  setUp(MockServices.setup);
  tearDown(MockServices.tearDown);

  test(
    'routine folder moves preserve identity and root move is idempotent',
    () {
      final c = dataController(RoutinesController.new);
      const folder = GTRoutineFolder(
        id: 'f',
        name: 'F',
        sortOrder: 0,
        notes: '',
      );
      final routine = Workout(id: 'r', name: 'R', exercises: []);
      final writes = <Workout>[];
      when(() => MockServices.databaseService.setRoutine(any())).thenAnswer((
        inv,
      ) async {
        writes.add(inv.positionalArguments.single as Workout);
      });
      c.moveToFolder(routine, folder);
      c.moveToRoot(writes.single);
      c.moveToRoot(routine);
      expect(writes.map((w) => w.id), ['r', 'r']);
      expect(writes.first.folder, folder);
      expect(writes.last.folder, isNull);
      verify(() => MockServices.backupScheduler.schedule()).called(2);
    },
  );

  test(
    'routine import creates a new routine and preserves its exercise data',
    () {
      final c = dataController(RoutinesController.new);
      final workout = Workout(
        id: 'history',
        name: 'W',
        exercises: [exerciseHelper('e', 'E')],
        startingDate: DateTime(2026),
        duration: const Duration(minutes: 10),
      );
      when(
        () => MockServices.databaseService.setRoutine(any()),
      ).thenAnswer((_) async {});
      final id = c.importWorkout(workout);
      final saved =
          verify(
                () => MockServices.databaseService.setRoutine(captureAny()),
              ).captured.single
              as Workout;
      expect(id, saved.id);
      expect(saved.id, isNot(workout.id));
      expect(saved.isConcrete, isFalse);
      expect(saved.exercises.single.asExercise.name, 'E');
      verify(() => MockServices.backupScheduler.schedule()).called(1);
    },
  );

  test('root reorder keeps routines belonging to folders', () {
    final routines = <Workout>[];
    final c = dataController(RoutinesController.new, routines: routines);
    final a = Workout(id: 'a', name: 'A', exercises: []);
    final b = Workout(id: 'b', name: 'B', exercises: []);
    final nested = Workout(
      id: 'c',
      name: 'C',
      exercises: [],
      folder: const GTRoutineFolder(
        id: 'f',
        name: 'F',
        sortOrder: 0,
        notes: '',
      ),
    );
    routines.addAll([a, b, nested]);
    when(
      () => MockServices.databaseService.routines,
    ).thenReturn([a, b, nested]);
    when(() => MockServices.databaseService.setAllRoutines(any())).thenAnswer((
      invocation,
    ) async {
      final saved = invocation.positionalArguments.single as List<Workout>;
      routines
        ..clear()
        ..addAll(saved);
    });
    c.reorderRoot(0, 2);
    final saved =
        verify(
              () => MockServices.databaseService.setAllRoutines(captureAny()),
            ).captured.single
            as List<Workout>;
    expect(saved.map((w) => w.id), ['b', 'a', 'c']);
    expect(c.workouts.map((w) => w.id), ['b', 'a', 'c']);
  });

  test('history continuation binding and lookup retain both sides', () {
    final c = dataController(HistoryController.new);
    final original = Workout(
      id: 'o',
      name: 'Original',
      exercises: [exerciseHelper('e', 'E')],
      startingDate: DateTime(2026),
      duration: const Duration(minutes: 1),
    );
    final continuation = Workout(
      id: 'c',
      name: 'Continuation',
      exercises: [],
      completes: 'o',
      startingDate: DateTime(2026, 1, 2),
      duration: const Duration(minutes: 1),
    );
    when(
      () => MockServices.databaseService.workoutHistory,
    ).thenReturn([original, continuation]);
    when(
      () => MockServices.databaseService.setHistoryWorkout(any()),
    ).thenAnswer((_) async {});
    expect(c.getContinuation(incompleteWorkout: original), same(continuation));
    expect(
      c.getOriginalForContinuation(continuationWorkout: continuation),
      same(original),
    );
    c.bindContinuation(continuation: continuation);
    final saved =
        verify(
              () =>
                  MockServices.databaseService.setHistoryWorkout(captureAny()),
            ).captured.single
            as Workout;
    expect(saved.id, 'o');
    expect(saved.completedBy, 'c');
  });

  test('history detaches only workouts belonging to the deleted parent', () {
    final c = dataController(HistoryController.new);
    final a = Workout(id: 'a', name: 'A', exercises: [], parentID: 'r');
    final b = Workout(id: 'b', name: 'B', exercises: [], parentID: 'other');
    when(() => MockServices.databaseService.workoutHistory).thenReturn([a, b]);
    when(
      () => MockServices.databaseService.setHistoryWorkout(any()),
    ).thenAnswer((_) async {});
    c.unbindAllFromParent('r');
    final saved =
        verify(
              () =>
                  MockServices.databaseService.setHistoryWorkout(captureAny()),
            ).captured.single
            as Workout;
    expect(saved.id, 'a');
    expect(saved.parentID, isNull);
  });

  test(
    'exercise commands propagate changes only to areas using them',
    () async {
      final c = dataController(ExercisesController.new);
      final ex = exerciseHelper('e', 'E');
      when(
        () => MockServices.historyController.hasExercise(ex),
      ).thenReturn(true);
      when(
        () => MockServices.routinesController.hasExercise(ex),
      ).thenReturn(false);
      when(
        () => MockServices.historyController.applyExerciseModification(ex),
      ).thenAnswer((_) async {});
      expect(c.hasExerciseInUse(ex), isTrue);
      await c.applyExerciseModification(ex);
      verify(
        () => MockServices.historyController.applyExerciseModification(ex),
      ).called(1);
      verifyNever(
        () => MockServices.routinesController.applyExerciseModification(ex),
      );
    },
  );

  test(
    'coordinator restores the active account workout then persists before suspension',
    () async {
      final c = MockServices.container.read(accountWorkoutLifecycleProvider);
      MockServices.database.setCurrentUserId('A');
      final data = {
        'name': 'Saved',
        'parentID': null,
        'infobox': null,
        'time': DateTime(2026).millisecondsSinceEpoch,
        'exercises': <Map<String, dynamic>>[],
        'weightUnit': 'kg',
        'distanceUnit': 'km',
      };
      await MockServices.database.setOngoing(data);
      await c.restore();
      final workout = MockServices.container.read(
        workoutControllerProvider.notifier,
      );
      expect(workout.ownerId, 'A');
      expect(workout.name, 'Saved');
      await c.suspend();
      expect(
        MockServices.container.read(workoutControllerProvider) != null,
        isFalse,
      );
      verify(
        () => MockServices.databaseService.writeToOngoing(any()),
      ).called(1);
      expect(await MockServices.database.watchOngoing().first, isNotNull);
    },
  );

  test('paused workout restore uses nominal elapsed duration', () {
    final restored = MockServices.restoreWorkout({
      'name': 'Saved',
      'time': 0,
      'exercises': <dynamic>[],
      'globalStopwatch': 0,
      'globalStopwatchPaused': true,
      'globalStopwatchNominalDuration': 90000,
    });
    expect(restored.name, 'Saved');
    expect(
      MockServices.stopwatchController.globalStopwatch.currentDuration,
      const Duration(seconds: 90),
    );
    expect(MockServices.stopwatchController.globalStopwatch.isStopped, isTrue);
  });

  test('running workout restore includes time spent outside the app', () {
    MockServices.restoreWorkout({
      'name': 'Saved',
      'time': 0,
      'exercises': <dynamic>[],
      'globalStopwatch': DateTime.now()
          .subtract(const Duration(minutes: 2))
          .millisecondsSinceEpoch,
      'globalStopwatchPaused': false,
    });
    final watch = MockServices.stopwatchController.globalStopwatch;
    expect(watch.currentDuration.inSeconds, greaterThanOrEqualTo(120));
    expect(watch.isStopped, isFalse);
    watch.pause();
  });
}
