import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/model/measurements.dart';

void main() {
  late GTDatabaseImpl db;
  BodyMeasurement measurement(double value) => BodyMeasurement(
    id: 'shared-id',
    value: value,
    time: DateTime(2026),
    type: BodyMeasurementPart.waist,
  );
  setUp(() {
    db = GTDatabaseImpl.withQueryExecutor(NativeDatabase.memory());
  });
  tearDown(() => db.close());

  test(
    'guest and account updates affect only the current owner with the same ID',
    () async {
      for (final owner in [null, 'A', 'B']) {
        db.setCurrentUserId(owner);
        await db.insertBodyMeasurement(measurement(90));
      }
      db.setCurrentUserId(null);
      await db.updateBodyMeasurement(measurement(88));
      db.setCurrentUserId('A');
      await db.updateBodyMeasurement(measurement(87));
      db.setCurrentUserId('B');
      await db.updateBodyMeasurement(measurement(86));
      final rows = await db.select(db.bodyMeasurements).get();
      expect(
        {for (final row in rows) row.userId: row.value},
        {null: 88, 'A': 87, 'B': 86},
      );
    },
  );

  test(
    'updating an ID absent from the current account cannot alter another account',
    () async {
      db.setCurrentUserId('A');
      await db.insertBodyMeasurement(measurement(90));
      db.setCurrentUserId('B');
      await db.updateBodyMeasurement(measurement(80));
      expect(await db.watchBodyMeasurements().first, isEmpty);
      db.setCurrentUserId('A');
      expect((await db.watchBodyMeasurements().first).single.value, 90);
    },
  );
}
