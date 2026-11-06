import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderListenable;
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/provider/db.dart';
import 'package:gymtracker/provider/routines.dart';
import 'package:gymtracker/provider/training_data.dart';

import '../helpers.dart';

Future<T> waitFor<T>(
  ProviderContainer container,
  ProviderListenable<AsyncValue<T>> source,
  bool Function(T) matches,
) {
  final done = Completer<T>();
  final subscription = container.listen(source, (_, next) {
    if (next.hasError && !done.isCompleted) {
      done.completeError(next.error!, next.stackTrace);
    }
    if (next.value case final value?) {
      if (matches(value) && !done.isCompleted) done.complete(value);
    }
  }, fireImmediately: true);
  return done.future.whenComplete(subscription.close);
}

void main() {
  late GTDatabase db;
  late ProviderContainer container;
  setUp(() {
    db = GTDatabaseImpl.withQueryExecutor(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        trainingClockProvider.overrideWithValue(() => DateTime(2026, 1, 5)),
      ],
    );
    container.listen(historyWorkoutsProvider, (_, _) {});
    container.listen(customExercisesProvider, (_, _) {});
    container.listen(routinesStreamProvider, (_, _) {});
  });
  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Workout performed(String id, int day) => Workout(
    id: id,
    name: id,
    exercises: [],
    startingDate: DateTime(2026, 1, day),
    duration: const Duration(minutes: 30),
  );

  test(
    'history observes persisted insert, edit and delete in chronological order',
    () async {
      await container.read(historyWorkoutsProvider.future);
      await db.insertHistoryWorkout(performed('later', 5));
      await db.insertHistoryWorkout(performed('earlier', 1));
      final sorted = await waitFor(
        container,
        historyWorkoutsProvider,
        (values) => values.length == 2,
      );
      expect(sorted.map((w) => w.id), ['earlier', 'later']);
      expect(() => sorted.clear(), throwsUnsupportedError);
      await db.updateHistoryWorkout(performed('earlier', 7));
      final edited = await waitFor(
        container,
        historyWorkoutsProvider,
        (values) => values.first.id == 'later',
      );
      expect(edited.last.startingDate, DateTime(2026, 1, 7));
      await db.deleteHistoryWorkout('later');
      final deleted = await waitFor(
        container,
        historyWorkoutsProvider,
        (values) => values.length == 1,
      );
      expect(deleted.single.id, 'earlier');
    },
  );

  test(
    'history resumes with current persisted data after a period without listeners',
    () async {
      final scope = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );
      addTearDown(scope.dispose);
      final initial = scope.listen(historyWorkoutsProvider, (_, _) {});
      await scope.read(historyWorkoutsProvider.future);
      initial.close();
      await scope.pump();
      await db.insertHistoryWorkout(performed('background', 2));
      final current = await waitFor(
        scope,
        historyWorkoutsProvider,
        (values) => values.any((w) => w.id == 'background'),
      ).timeout(const Duration(seconds: 5));
      expect(current.single.id, 'background');
    },
  );

  test(
    'exercise stream follows writes and isolates owners across switches',
    () async {
      await container.read(customExercisesProvider.future);
      await db.insertCustomExercise(exerciseHelper('guest', 'Guest'));
      expect(
        (await waitFor(
          container,
          customExercisesProvider,
          (v) => v.length == 1,
        )).single.id,
        'guest',
      );
      db.setCurrentUserId('account');
      await waitFor(container, customExercisesProvider, (v) => v.isEmpty);
      await db.insertCustomExercise(exerciseHelper('owned', 'Owned'));
      expect(
        (await waitFor(
          container,
          customExercisesProvider,
          (v) => v.length == 1,
        )).single.id,
        'owned',
      );
      db.setCurrentUserId(null);
      expect(
        (await waitFor(
          container,
          customExercisesProvider,
          (v) => v.any((e) => e.id == 'guest'),
        )).map((e) => e.id),
        ['guest'],
      );
    },
  );

  test(
    'suggestions derive from both persisted sources with an injectable clock',
    () async {
      container.listen(routineSuggestionsProvider, (_, _) {});
      await db.insertRoutine(Workout(id: 'r', name: 'Routine', exercises: []));
      await db.insertHistoryWorkout(performed('w', 5).copyWith(parentID: 'r'));
      await waitFor(container, routinesStreamProvider, (v) => v.length == 1);
      await waitFor(container, historyWorkoutsProvider, (v) => v.length == 1);
      final result = container.read(routineSuggestionsProvider);
      expect(result.single.routine.id, 'r');
      expect(result.single.score, 1);
    },
  );

  test(
    'suggestions preserve persisted folders and follow folder changes',
    () async {
      container.listen(routineSuggestionsProvider, (_, _) {});
      const folder = GTRoutineFolder(
        id: 'folder',
        name: 'Strength',
        sortOrder: 0,
        notes: '',
      );
      await db.insertRoutineFolder(folder);
      await db.insertRoutine(
        Workout(id: 'r', name: 'Routine', exercises: [], folder: folder),
      );
      await db.insertHistoryWorkout(performed('w', 5).copyWith(parentID: 'r'));
      await waitFor(container, routinesStreamProvider, (v) => v.length == 1);
      await waitFor(container, historyWorkoutsProvider, (v) => v.length == 1);
      expect(
        container.read(routineSuggestionsProvider).single.routine.folder,
        folder,
      );

      await db.updateRoutineFolder(folder.copyWith(name: 'Renamed'));
      await waitFor(
        container,
        routinesStreamProvider,
        (v) => v.single.folder?.name == 'Renamed',
      );
      expect(
        container.read(routineSuggestionsProvider).single.routine.folder?.name,
        'Renamed',
      );
    },
  );

  test(
    'disposing and recreating a scope reloads persisted data independently',
    () async {
      await db.insertHistoryWorkout(performed('w', 1));
      await waitFor(container, historyWorkoutsProvider, (v) => v.length == 1);
      container.dispose();
      container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          trainingClockProvider.overrideWithValue(() => DateTime(2026, 1, 5)),
        ],
      );
      container.listen(historyWorkoutsProvider, (_, _) {});
      final reloaded = await container.read(historyWorkoutsProvider.future);
      expect(reloaded.single.id, 'w');
    },
  );
}
