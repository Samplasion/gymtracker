import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/controller/countdown_controller.dart';
import 'package:gymtracker/controller/debug_controller.dart';
import 'package:gymtracker/controller/error_controller.dart';
import 'package:gymtracker/controller/exercises_controller.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/controller/intents_controller.dart';
import 'package:gymtracker/controller/logger_controller.dart';
import 'package:gymtracker/controller/me_controller.dart';
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/controller/stopwatch_controller.dart';
import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/model/model.dart';
import 'package:gymtracker/provider/db.dart';
import 'package:gymtracker/provider/settings.dart';
import 'package:gymtracker/repository/measurements.dart';
import 'package:gymtracker/struct/data_migration.dart';
import 'package:logging/logging.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxdart/rxdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../helpers.dart';
import '../test_helpers/data_controllers.dart';
import '../test_helpers/mock_services.dart';

class _Measurements extends Mock implements MeasurementsRepository {}

class _PreferenceDatabase extends Mock implements GTDatabase {}

SettingsController realSettings(Prefs initial) {
  final container = ProviderContainer(
    parent: MockServices.container,
    overrides: [
      appPreferencesProvider.overrideWithValue(AsyncData(initial)),
      settingsControllerProvider.overrideWith(
        (ref) => SettingsController(ref: ref),
      ),
    ],
  );
  addTearDown(container.dispose);
  return container.read(settingsControllerProvider);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    registerFallbackValue(exerciseHelper('fallback', 'Fallback'));
    registerFallbackValue(Prefs.defaultValue);
    registerFallbackValue(AchievementTrigger.workout);
    registerFallbackValue(DateTime(2026));
  });
  setUp(MockServices.setup);
  tearDown(MockServices.tearDown);

  group('Exercises behavior', () {
    test('creation retains parameters and rejects duplicate names', () {
      final exercises = <Exercise>[];
      final c = dataController(ExercisesController.new, exercises: exercises);
      final ex = c.generateEmpty(
        name: 'New',
        parameters: GTSetParameters.freeBodyReps,
        primaryMuscleGroup: GTMuscleGroup.chest,
        secondaryMuscleGroups: {},
        restTime: const Duration(seconds: 45),
      );
      expect(ex.parameters, GTSetParameters.freeBodyReps);
      expect(ex.restTime, const Duration(seconds: 45));
      expect(ex.isCustom, isTrue);
      exercises.add(ex);
      expect(c.isNameValid('New'), isFalse);
      expect(c.isNameValid('Other'), isTrue);
      expect(c.getExerciseByID(ex.id), same(ex));
      expect(c.getExerciseByID('missing'), isNull);
    });
    test(
      'add edit delete and weight transformations persist intended values',
      () async {
        final c = dataController(ExercisesController.new);
        final ex = exerciseHelper(
          'ex',
          'Bench',
          sets: [
            GTSet.empty(
              parameters: GTSetParameters.repsWeight,
              kind: GTSetKind.normal,
            ).copyWith(weight: 20),
          ],
        );
        final writes = <Exercise>[];
        when(() => MockServices.databaseService.setExercise(any())).thenAnswer((
          inv,
        ) async {
          writes.add(inv.positionalArguments.single as Exercise);
        });
        when(
          () => MockServices.databaseService.removeExercise(any()),
        ).thenAnswer((_) async {});
        c.addExercise(ex);
        await c.saveEdit(ex.copyWith(name: 'Edited'));
        c.applyWeightMultiplier(ex, 2);
        c.removeWeightFromExercise(ex);
        c.deleteExercise(ex);
        expect(writes.map((e) => e.name), [
          'Bench',
          'Edited',
          'Bench',
          'Bench',
        ]);
        expect(writes[2].sets.single.weight, 40);
        expect(writes[3].parameters, GTSetParameters.freeBodyReps);
        expect(writes[3].sets.single.parameters, GTSetParameters.freeBodyReps);
        expect(writes[3].sets.single.id, ex.sets.single.id);
        expect(writes[3].sets.single.reps, ex.sets.single.reps);
        verify(() => MockServices.databaseService.removeExercise(ex)).called(1);
      },
    );
  });

  group('Routines and history behavior', () {
    test(
      'routine generation and edit preserve identity and settings units',
      () {
        final c = dataController(RoutinesController.new);
        final routine = c.generate(
          name: 'R',
          exercises: [exerciseHelper('e', 'E')],
          id: 'r',
          infobox: 'Notes',
        );
        expect(routine.id, 'r');
        expect(routine.weightUnit, Weights.kg);
        expect(routine.infobox, 'Notes');
        when(
          () => MockServices.databaseService.hasRoutine('r'),
        ).thenReturn(true);
        when(
          () => MockServices.databaseService.setRoutine(any()),
        ).thenAnswer((_) async {});
        c.editRoutine(routine);
        verify(
          () => MockServices.databaseService.setRoutine(routine),
        ).called(1);
        verify(() => MockServices.backupScheduler.schedule()).called(1);
      },
    );
    test('deleting routine also detaches its history', () {
      final c = dataController(RoutinesController.new);
      final routine = Workout(id: 'r', name: 'R', exercises: []);
      when(
        () => MockServices.databaseService.removeRoutine(any()),
      ).thenAnswer((_) async {});
      c.deleteWorkout(routine);
      verify(
        () => MockServices.databaseService.removeRoutine(routine),
      ).called(1);
      verify(
        () => MockServices.historyController.unbindAllFromParent('r'),
      ).called(1);
    });
    test(
      'history deletion removes continuation and schedules backup',
      () async {
        final c = dataController(HistoryController.new);
        final workout = Workout(
          id: 'w',
          name: 'W',
          exercises: [],
          completedBy: 'continuation',
        );
        when(
          () => MockServices.databaseService.removeHistoryWorkoutById(any()),
        ).thenAnswer((_) async {});
        when(
          () => MockServices.achievementsController.maybeUnlockAchievements(
            any(),
          ),
        ).thenReturn({});
        await c.deleteWorkout(workout);
        verify(
          () => MockServices.databaseService.removeHistoryWorkoutById('w'),
        ).called(1);
        verify(
          () => MockServices.databaseService.removeHistoryWorkoutById(
            'continuation',
          ),
        ).called(1);
        verify(() => MockServices.backupScheduler.schedule()).called(1);
      },
    );
    test('rename only persists a workout already present in history', () {
      final c = dataController(HistoryController.new);
      final w = Workout(id: 'w', name: 'Before', exercises: []);
      when(
        () => MockServices.databaseService.hasHistoryWorkout('w'),
      ).thenReturn(true);
      when(
        () => MockServices.databaseService.setHistoryWorkout(any()),
      ).thenAnswer((_) async {});
      expect(c.rename(w, newName: 'After').name, 'After');
      expect(c.rename(w), same(w));
      verify(
        () => MockServices.databaseService.setHistoryWorkout(any()),
      ).called(1);
    });
    test('exercise usage includes a child inside a superset', () {
      final history = <Workout>[];
      final c = dataController(HistoryController.new, history: history);
      final parent = exerciseHelper('parent', 'Parent');
      history.add(
        Workout(
          name: 'W',
          exercises: [
            supersetHelper(
              's',
              exercises: [parent.copyWith(id: 'child', parentID: 'parent')],
            ),
          ],
        ),
      );
      expect(c.hasExercise(parent), isTrue);
      expect(c.hasExercise(exerciseHelper('other', 'Other')), isFalse);
    });
  });

  group('Measurements behavior', () {
    test('prediction handles insufficient data and sorts observations', () {
      final c = MockServices.container.read(meControllerProvider);
      WeightMeasurement point(String id, int day, double weight) =>
          WeightMeasurement(
            id: id,
            weight: weight,
            time: DateTime(2026, 1, day),
            weightUnit: Weights.kg,
          );
      final a = point('a', 1, 80), b = point('b', 3, 78);
      expect(c.predictNextWeight([], Weights.kg), isNull);
      expect(c.predictNextWeight([a], Weights.kg), isNull);
      final prediction = c.predictNextWeight([b, a], Weights.kg)!;
      // Characterize the current calculation, including its averaging divisor.
      expect(prediction.weight, 77);
      expect(prediction.time, DateTime(2026, 1, 4));
      expect(prediction.weightUnit, Weights.kg);
    });
    test('weight and body operations persist the supplied measurements', () {
      final repository = _Measurements();
      final container = ProviderContainer(
        overrides: [
          ...MockServices.defaultOverrides,
          measurementsRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);
      final c = container.read(meControllerProvider);
      final w = WeightMeasurement(
        id: 'w',
        weight: 80,
        time: DateTime(2026),
        weightUnit: Weights.kg,
      );
      final b = BodyMeasurement(
        id: 'b',
        value: 90,
        time: DateTime(2026),
        type: BodyMeasurementPart.waist,
      );
      when(
        () =>
            MockServices.achievementsController.maybeUnlockAchievements(any()),
      ).thenReturn({});
      when(() => repository.saveWeight(w)).thenAnswer((_) async {});
      when(() => repository.deleteWeight('w')).thenAnswer((_) async {});
      when(() => repository.saveBody(b)).thenAnswer((_) async {});
      when(() => repository.deleteBody('b')).thenAnswer((_) async {});
      c.addWeightMeasurement(w);
      c.removeWeightMeasurement(w);
      c.addBodyMeasurement(b);
      c.removeBodyMeasurement(b);
      verify(() => repository.saveWeight(w)).called(1);
      verify(() => repository.deleteWeight('w')).called(1);
      verify(() => repository.saveBody(b)).called(1);
      verify(() => repository.deleteBody('b')).called(1);
    });
  });

  group('Preferences behavior', () {
    test('each setting writes a copy without losing other preferences', () {
      final initial = Prefs.defaultValue.copyWith(
        color: Colors.red,
        showSuggestedRoutines: false,
      );
      final subject = BehaviorSubject<Prefs>.seeded(initial);
      addTearDown(subject.close);
      when(
        () => MockServices.databaseService.prefs$,
      ).thenAnswer((_) => subject);
      final writes = <Prefs>[];
      when(() => MockServices.databaseService.writeSettings(any())).thenAnswer((
        inv,
      ) async {
        writes.add(inv.positionalArguments.single as Prefs);
      });
      final c = realSettings(initial);
      c.setUsesDynamicColor(false);
      c.setColor(Colors.green);
      c.setWeightUnit(Weights.lb);
      c.setDistanceUnit(Distance.mi);
      c.setShowSuggestedRoutines(true);
      c.setThemeMode(ThemeMode.dark);
      c.setTintExercises(true);
      c.setDefaultToSimpleWorkoutView(true);
      expect(writes, hasLength(8));
      expect(writes[0].usesDynamicColor, isFalse);
      expect(writes[1].color, Colors.green);
      expect(writes[2].weightUnit, Weights.lb);
      expect(writes[3].distanceUnit, Distance.mi);
      expect(writes[4].showSuggestedRoutines, isTrue);
      expect(writes[5].themeMode, ThemeMode.dark);
      expect(writes[6].tintExercises, isTrue);
      expect(writes[7].defaultToSimpleWorkoutView, isTrue);
      expect(writes[2].color, Colors.red);
      expect(writes[2].showSuggestedRoutines, isFalse);
    });
    test('initialization returns immediately when already loaded', () async {
      final subject = BehaviorSubject<Prefs>.seeded(Prefs.defaultValue);
      addTearDown(subject.close);
      when(
        () => MockServices.databaseService.prefs$,
      ).thenAnswer((_) => subject);
      final c = realSettings(Prefs.defaultValue);
      await c.awaitInitialized();
      expect(c.hasInitialized, isTrue);
    });
  });

  group('Timers behavior', () {
    test(
      'countdown reschedules on adjustments and clears state on removal',
      () {
        // Notification effects use the injected test service in MockServices.
        final c = MockServices.container.read(
          countdownControllerProvider.notifier,
        );
        expect(c.isActive, isFalse);
        expect(c.progress, 0);
        c.setCountdown(const Duration(minutes: 1));
        final target = c.targetTime!;
        expect(c.isActive, isTrue);
        c.add15Seconds();
        expect(c.targetTime, target.add(const Duration(seconds: 15)));
        c.subtract15Seconds();
        expect(c.targetTime, target);
        c.removeCountdown();
        expect(c.isActive, isFalse);
        expect(c.targetTime, isNull);
        expect(c.startingTime, isNull);
        // Scheduling is covered with the notification plugin contract tests.
      },
    );
    test(
      'global stopwatch supports pause start and reset without a field binding',
      () {
        final ticks = <Duration>[];
        final c = GlobalStopwatch(onTick: ticks.add);
        expect(c.isStopped, isTrue);
        c.start();
        expect(c.isStopped, isFalse);
        c.pause();
        expect(c.isStopped, isTrue);
        c.reset();
        expect(c.currentDuration, Duration.zero);
        expect(ticks, [Duration.zero]);
      },
    );
    testWidgets('field stopwatch ticks, rebinds and stops after removal', (
      tester,
    ) async {
      final c = MockServices.container.read(
        stopwatchControllerProvider.notifier,
      );
      final ticks = <String>[];
      final s = TimeFieldStopwatch(
        setID: 'set',
        getCurrentTime: () => '00:10',
        onTick: (_, _, text) => ticks.add(text),
      );
      c.addStopwatch(s);
      expect(c.isRunning('set'), isTrue);
      await tester.pump(const Duration(seconds: 1));
      expect(ticks, ['00:11']);
      final rebound = <String>[];
      c.updateBinding('set', (_, _, text) => rebound.add(text));
      await tester.pump(const Duration(seconds: 1));
      expect(rebound, ['00:12']);
      c.removeStopwatch('set');
      expect(c.isRunning('set'), isFalse);
      final count = rebound.length;
      await tester.pump(const Duration(seconds: 2));
      expect(rebound, hasLength(count));
      c.removeStopwatch('global');
      expect(c.globalStopwatch, isNotNull);
    });
  });

  group('Diagnostics and migration behavior', () {
    test('logger retains newest logs, filters by level and clears', () {
      final c = LoggerController();
      for (var i = 0; i < LoggerController.keptLogs + 2; i++) {
        c.addLog(
          Log(
            message: '$i',
            timestamp: DateTime(2026),
            level: i.isEven ? Level.INFO : Level.SEVERE,
            loggerName: 'test',
          ),
        );
      }
      expect(c.logs, hasLength(LoggerController.keptLogs));
      expect(c.logs.first.message, '2');
      c.level = Level.SEVERE;
      expect(c.filteredLogs.every((l) => l.level == Level.SEVERE), isTrue);
      c.clearLogs();
      expect(c.logs, isEmpty);
    });
    test(
      'error filtering suppresses known connectivity and rebuild errors only',
      () {
        final c = ErrorController();
        expect(
          c.ignoreError(
            AuthRetryableFetchException(
              message: 'ClientException with SocketException',
            ),
          ),
          isTrue,
        );
        expect(
          c.ignoreError(
            StateError('setState() or markNeedsBuild() called during build'),
          ),
          isTrue,
        );
        expect(c.ignoreError(StateError('lost data')), isFalse);
      },
    );
    testWidgets('debug toggles simulator and deduplicates missing keys', (
      tester,
    ) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final c = container.read(debugControllerProvider.notifier);
      c.toggleSimulator();
      expect(container.read(debugControllerProvider).showSimulator, isTrue);
      c.setShowSimulator(false);
      expect(container.read(debugControllerProvider).showSimulator, isFalse);
      await tester.pumpWidget(const SizedBox());
      c.addMissingKey('key');
      c.addMissingKey('key');
      tester.binding.scheduleFrame();
      await tester.pump();
      expect(container.read(debugControllerProvider).missingKeys.toList(), [
        'key',
      ]);
    });
    test(
      'unused exercise migration previews and deletes only unused templates',
      () {
        final unused = exerciseHelper('unused', 'Unused');
        final used = exerciseHelper('used', 'Used');
        when(
          () => MockServices.exercisesController.exercises,
        ).thenReturn([unused, used]);
        when(() => MockServices.routinesController.workouts).thenReturn([
          Workout(
            name: 'R',
            exercises: [used.copyWith(id: 'child', parentID: 'used')],
          ),
        ]);
        final m = RemoveUnusedExercisesMigration(
          exercisesController: MockServices.exercisesController,
          routinesController: MockServices.routinesController,
          historyController: MockServices.historyController,
        );
        expect(m.affectedExercises, [unused]);
        m.apply();
        verify(
          () => MockServices.exercisesController.deleteExercise(unused),
        ).called(1);
        verifyNever(
          () => MockServices.exercisesController.deleteExercise(used),
        );
      },
    );
    test(
      'weight multiplier migration updates template, routines and history',
      () {
        final ex = exerciseHelper('e', 'E');
        final m = GenericMultiplyWeightInExerciseMigration(
          ex,
          2,
          exercisesController: MockServices.exercisesController,
          routinesController: MockServices.routinesController,
          historyController: MockServices.historyController,
        );
        m.apply();
        verify(
          () => MockServices.exercisesController.applyWeightMultiplier(ex, 2),
        ).called(1);
        verify(
          () => MockServices.routinesController.applyWeightMultiplier(ex, 2),
        ).called(1);
        verify(
          () => MockServices.historyController.applyWeightMultiplier(ex, 2),
        ).called(1);
      },
    );
    test(
      'provider lifecycle attaches and detaches its database subscription',
      () async {
        final database = _PreferenceDatabase();
        var listeners = 0;
        final source = StreamController<Prefs>.broadcast(
          onListen: () => listeners++,
          onCancel: () => listeners--,
        );
        when(
          () => database.watchPreferences(),
        ).thenAnswer((_) => source.stream);
        final container = ProviderContainer(
          overrides: [appDatabaseProvider.overrideWithValue(database)],
        );
        container.listen(appPreferencesProvider, (_, _) {});
        await Future<void>.delayed(Duration.zero);
        expect(listeners, 1);
        source.add(Prefs.defaultValue);
        await container.read(appPreferencesProvider.future);
        container.dispose();
        await Future<void>.delayed(Duration.zero);
        expect(listeners, 0);
        await source.close();
      },
    );
    test('unsupported Siri donation is harmless', () async {
      expect(IntentsController.isSupported, isFalse);
      IntentsController.initialize(start: (_, _) {});
      await IntentsController.donateRoutineStarted(
        routineId: 'r',
        routineDisplayName: 'R',
      );
    });
  });
}
