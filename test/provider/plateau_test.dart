import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/provider/db.dart';
import 'package:gymtracker/provider/plateau.dart';
import 'package:gymtracker/provider/training_data.dart';
import 'package:gymtracker/service/plateau_analysis.dart';
import '../service/plateau_analysis_test.dart' as fixture;

void main() {
  test('persisted results follow account ownership', () async {
    final db = GTDatabaseImpl.withQueryExecutor(NativeDatabase.memory());
    final scope = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        trainingClockProvider.overrideWithValue(() => fixture.now),
      ],
    );
    final sub = scope.listen(plateauAnalysisProvider, (_, _) {});
    addTearDown(() async {
      sub.close();
      scope.dispose();
      await db.close();
    });
    Future<List<PlateauResult>> waitFor(
      bool Function(List<PlateauResult>) predicate,
    ) async {
      final done = Completer<List<PlateauResult>>();
      final listener = scope.listen(plateauAnalysisProvider, (_, next) {
        if (next.value case final data?) {
          if (predicate(data) && !done.isCompleted) done.complete(data);
        }
      }, fireImmediately: true);
      try {
        return await done.future.timeout(const Duration(seconds: 5));
      } finally {
        listener.close();
      }
    }

    await scope.read(historyWorkoutsProvider.future);
    for (final workout in fixture.history()) {
      await db.insertHistoryWorkout(workout);
    }
    expect(
      (await waitFor(
        (r) => r.any((e) => e.status == PlateauStatus.possiblePlateau),
      )).single.status,
      PlateauStatus.possiblePlateau,
    );
    db.setCurrentUserId('another-owner');
    expect(await waitFor((r) => r.isEmpty), isEmpty);
    db.setCurrentUserId(null);
    expect(
      (await waitFor((r) => r.isNotEmpty)).single.status,
      PlateauStatus.possiblePlateau,
    );
  });

  test(
    'reacts to history additions, edits, removal and account reset',
    () async {
      final source = StreamController<List<Workout>>();
      final scope = ProviderContainer(
        overrides: [
          historyWorkoutsProvider.overrideWith((ref) => source.stream),
          trainingClockProvider.overrideWithValue(() => fixture.now),
        ],
      );
      final sub = scope.listen(plateauAnalysisProvider, (_, _) {});
      addTearDown(() async {
        sub.close();
        scope.dispose();
        await source.close();
      });
      expect(scope.read(plateauAnalysisProvider).isLoading, isTrue);
      Future<void> emit(List<Workout> h) async {
        source.add(h);
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }

      await emit(fixture.history());
      expect(
        scope.read(plateauAnalysisProvider).requireValue.single.status,
        PlateauStatus.possiblePlateau,
      );
      await emit(
        fixture.changeLast(fixture.history(), (s) => s.copyWith(reps: 11)),
      );
      expect(
        scope.read(plateauAnalysisProvider).requireValue.single.status,
        PlateauStatus.progressing,
      );
      await emit(fixture.history().take(5).toList());
      expect(
        scope.read(plateauAnalysisProvider).requireValue.single.status,
        PlateauStatus.insufficientData,
      );
      await emit([]);
      expect(scope.read(plateauAnalysisProvider).requireValue, isEmpty);
      source.addError(StateError('offline'));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(scope.read(plateauAnalysisProvider).hasError, isTrue);
    },
  );
}
