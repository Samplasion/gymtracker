import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderListenable;
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/controller/me_controller.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/model/measurements.dart';
import 'package:gymtracker/provider/db.dart';
import 'package:gymtracker/provider/measurements.dart';
import 'package:gymtracker/repository/measurements.dart';

Future<T> _until<T>(
  ProviderContainer container,
  ProviderListenable<AsyncValue<T>> provider,
  bool Function(T) matches,
) {
  final done = Completer<T>();
  final sub = container.listen(provider, (_, next) {
    if (next.hasError && !done.isCompleted) {
      done.completeError(next.error!, next.stackTrace);
    }
    if (next.value case final value?) {
      if (matches(value) && !done.isCompleted) done.complete(value);
    }
  }, fireImmediately: true);
  return done.future.whenComplete(sub.close);
}

class _DelayedMeasurements extends MeasurementsRepository {
  _DelayedMeasurements(super.db);
  final write = Completer<void>();
  @override
  Future<void> saveWeight(WeightMeasurement measurement) => write.future;
}

void main() {
  late GTDatabase db;
  late ProviderContainer container;
  var unlocks = 0;
  final observedAtUnlock = <List<WeightMeasurement>>[];
  WeightMeasurement weight(String id, double value) => WeightMeasurement(
    id: id,
    weight: value,
    time: DateTime(2026, 1, 1),
    weightUnit: Weights.kg,
  );

  setUp(() async {
    unlocks = 0;
    observedAtUnlock.clear();
    db = GTDatabaseImpl.withQueryExecutor(NativeDatabase.memory());
    container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        weightChangedProvider.overrideWithValue(() {
          unlocks++;
          observedAtUnlock.add(
            List.of(container.read(weightMeasurementsProvider).requireValue),
          );
        }),
      ],
    );
    container.listen(weightMeasurementsProvider, (_, _) {});
    container.listen(bodyMeasurementsProvider, (_, _) {});
  });
  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test(
    'commands create update delete and publish weight without a controller cache',
    () async {
      final commands = container.read(meControllerProvider);
      await container.read(weightMeasurementsProvider.future);
      await commands.addWeightMeasurement(
        weight('w', 80).copyWith(time: DateTime(2026, 1, 1, 0, 0, 0, 123, 456)),
      );
      await _until(
        container,
        weightMeasurementsProvider,
        (rows) => rows.length == 1,
      );
      expect(commands.latestWeightMeasurement!.weight, 80);
      await commands.addWeightMeasurement(weight('w', 79));
      await _until(
        container,
        weightMeasurementsProvider,
        (rows) => rows.single.weight == 79,
      );
      expect(commands.getWeightMeasurementByID('w')!.weight, 79);
      await commands.removeWeightMeasurement(weight('w', 79));
      await _until(
        container,
        weightMeasurementsProvider,
        (rows) => rows.isEmpty,
      );
      expect(commands.latestWeightMeasurement, isNull);
      expect(unlocks, 3);
      // The trigger must see the committed value through the canonical source.
      expect(
        observedAtUnlock.map((rows) => rows.map((m) => m.weight).toList()),
        [
          [80.0],
          [79.0],
          <double>[],
        ],
      );
      expect(await db.watchWeightMeasurements().first, isEmpty);
    },
  );

  test('failed and late weight writes do not check achievements', () async {
    final repository = _DelayedMeasurements(db);
    final scope = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        measurementsRepositoryProvider.overrideWithValue(repository),
        weightChangedProvider.overrideWithValue(() => unlocks++),
      ],
    );
    final commands = scope.read(meControllerProvider);
    final result = commands.addWeightMeasurement(weight('w', 80));
    final failure = expectLater(result, throwsStateError);
    repository.write.completeError(StateError('write failed'));
    await failure;
    expect(unlocks, 0);
    scope.dispose();

    final lateRepository = _DelayedMeasurements(db);
    final lateScope = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        measurementsRepositoryProvider.overrideWithValue(lateRepository),
        weightChangedProvider.overrideWithValue(() => unlocks++),
      ],
    );
    final lateWrite = lateScope
        .read(meControllerProvider)
        .addWeightMeasurement(weight('late', 80));
    lateScope.dispose();
    lateRepository.write.complete();
    await lateWrite;
    expect(unlocks, 0);
  });

  test(
    'an old owner weight write cannot trigger achievements for a new owner',
    () async {
      db.setCurrentUserId('A');
      final repository = _DelayedMeasurements(db);
      final scope = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          measurementsRepositoryProvider.overrideWithValue(repository),
          weightChangedProvider.overrideWithValue(() => unlocks++),
        ],
      );
      final write = scope
          .read(meControllerProvider)
          .addWeightMeasurement(weight('w', 80));
      db.setCurrentUserId('B');
      repository.write.complete();
      await write;
      expect(unlocks, 0);
      scope.dispose();
    },
  );

  test('body commands update the same row and remove it', () async {
    final commands = container.read(meControllerProvider);
    final measurement = BodyMeasurement(
      id: 'b',
      value: 90,
      time: DateTime(2026),
      type: BodyMeasurementPart.waist,
    );
    await commands.addBodyMeasurement(measurement);
    await _until(
      container,
      bodyMeasurementsProvider,
      (rows) => rows.length == 1,
    );
    expect(commands.getBodyMeasurementByID('b')!.value, 90);
    await commands.addBodyMeasurement(
      BodyMeasurement(
        id: 'b',
        value: 89,
        time: measurement.time,
        type: measurement.type,
      ),
    );
    await _until(
      container,
      bodyMeasurementsProvider,
      (rows) => rows.single.value == 89,
    );
    await commands.removeBodyMeasurement(measurement);
    await _until(container, bodyMeasurementsProvider, (rows) => rows.isEmpty);
    expect(unlocks, 0);
  });

  test(
    'account changes replace stream contents and restore the matching measurements',
    () async {
      final commands = container.read(meControllerProvider);
      db.setCurrentUserId('A');
      await commands.addWeightMeasurement(weight('a', 80));
      await _until(
        container,
        weightMeasurementsProvider,
        (rows) => rows.any((r) => r.id == 'a'),
      );
      db.setCurrentUserId('B');
      await _until(
        container,
        weightMeasurementsProvider,
        (rows) => rows.isEmpty,
      );
      await commands.addWeightMeasurement(weight('b', 70));
      await _until(
        container,
        weightMeasurementsProvider,
        (rows) => rows.any((r) => r.id == 'b'),
      );
      expect(commands.weightMeasurements.map((m) => m.id), ['b']);
      db.setCurrentUserId('A');
      await _until(
        container,
        weightMeasurementsProvider,
        (rows) => rows.any((r) => r.id == 'a'),
      );
      expect(commands.weightMeasurements.map((m) => m.id), ['a']);
    },
  );

  test(
    'prediction keeps existing averaging and converts input units explicitly',
    () async {
      expect(predictNextWeight([], Weights.kg), isNull);
      final a = weight('a', 80);
      final b = WeightMeasurement(
        id: 'b',
        weight: 78,
        time: DateTime(2026, 1, 3),
        weightUnit: Weights.kg,
      );
      final prediction = predictNextWeight([b, a], Weights.lb)!;
      expect(
        prediction.weight,
        closeTo(
          Weights.convert(value: 77, from: Weights.kg, to: Weights.lb),
          0.001,
        ),
      );
      expect(prediction.time, DateTime(2026, 1, 4));
    },
  );

  test('separate containers cannot share measurement state', () async {
    await container
        .read(meControllerProvider)
        .addWeightMeasurement(weight('a', 80));
    final otherDb = GTDatabaseImpl.withQueryExecutor(NativeDatabase.memory());
    final other = ProviderContainer(
      retry: (_, _) => null,
      overrides: [appDatabaseProvider.overrideWithValue(otherDb)],
    );
    other.listen(weightMeasurementsProvider, (_, _) {});
    try {
      expect(await other.read(weightMeasurementsProvider.future), isEmpty);
      expect(
        (await container.read(weightMeasurementsProvider.future)).single.id,
        'a',
      );
    } finally {
      other.dispose();
      await otherDb.close();
    }
  });
}
