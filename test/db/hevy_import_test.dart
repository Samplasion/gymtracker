import 'package:csv/csv.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/model/measurements.dart';
import 'package:gymtracker/provider/db.dart';
import 'package:gymtracker/service/database.dart';

import '../helpers.dart';

class _FailingBodyImport extends DatabaseService {
  _FailingBodyImport(super.db) : super.withDatabase();

  @override
  Future<void> addBodyMeasurements(List<BodyMeasurement> measurements) async {
    throw StateError('Simulated second-phase failure');
  }
}

void main() {
  late GTDatabaseImpl db;
  late SettingsController controller;
  late ProviderContainer container;
  void useService(DatabaseService service) {
    container = ProviderContainer(
      overrides: [
        databaseServiceProvider.overrideWithValue(service),
        appDatabaseProvider.overrideWithValue(db),
      ],
    );
    controller = container.read(settingsControllerProvider);
  }

  final day = DateTime(2026, 10, 18, 9);
  final measurementCsv = const CsvEncoder().convert([
    [
      'date',
      'weight_kg',
      'fat_percent',
      ...List.generate(14, (i) => 'measurement_$i'),
    ],
    [
      '18 Oct 2026, 09:00',
      70,
      15,
      35,
      110,
      100,
      30,
      31,
      25,
      26,
      80,
      79,
      90,
      55,
      56,
      35,
      36,
    ],
  ]);
  final workoutCsv = const CsvEncoder().convert([
    List.generate(14, (i) => 'column_$i'),
    [
      'Workout',
      '18 Oct 2026, 09:00',
      '18 Oct 2026, 10:00',
      '',
      'Imported exercise',
      '',
      '',
      0,
      'normal',
      20,
      10,
      '',
      '',
      '',
    ],
  ]);

  setUp(() {
    db = GTDatabaseImpl.withQueryExecutor(NativeDatabase.memory());
  });
  tearDown(() async {
    container.dispose();
    await db.close();
  });

  for (final user in [null, 'A']) {
    test(
      'repeated measurement and workout import preserves existing data for $user',
      () async {
        db.setCurrentUserId(user);
        useService(DatabaseService.withDatabase(db));
        await db.insertWeightMeasurement(
          WeightMeasurement(
            id: 'existing',
            weight: 65,
            time: day,
            weightUnit: .kg,
          ),
        );
        await db.insertCustomExercise(
          exerciseHelper('existing', 'Existing exercise'),
        );
        for (var i = 0; i < 2; i++) {
          await controller.importHevy(measurementCsv);
          await controller.importHevy(workoutCsv);
        }
        expect((await db.watchWeightMeasurements().first).length, 2);
        expect(
          (await db.watchBodyMeasurements().first)
              .map((m) => m.type)
              .toSet()
              .length,
          15,
        );
        expect((await db.watchBodyMeasurements().first).length, 15);
        expect((await db.getAllCustomExercises().first).length, 2);
        expect((await db.getAllHistoryWorkoutsFuture()).length, 1);
      },
    );
  }

  test(
    'failure in the second import phase rolls back the first phase',
    () async {
      db.setCurrentUserId('A');
      useService(_FailingBodyImport(db));
      await expectLater(
        controller.importHevy(measurementCsv),
        throwsStateError,
      );
      expect(await db.watchWeightMeasurements().first, isEmpty);
      expect(await db.watchBodyMeasurements().first, isEmpty);
    },
  );
}
