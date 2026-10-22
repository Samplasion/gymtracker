import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/model/measurements.dart';
import 'package:gymtracker/provider/db.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'measurements.g.dart';

class MeasurementsRepository {
  MeasurementsRepository(this._db);
  final GTDatabase _db;

  Stream<List<WeightMeasurement>> watchWeight() =>
      _db.watchWeightMeasurements();
  Stream<List<BodyMeasurement>> watchBody() => _db.watchBodyMeasurements();

  Future<void> saveWeight(WeightMeasurement measurement) async {
    final owner = _db.currentUserId;
    final rows = await _db.watchWeightMeasurements().first;
    if (owner != _db.currentUserId) {
      throw StateError('Account changed while saving weight');
    }
    if (rows.any((row) => row.id == measurement.id)) {
      await _db.updateWeightMeasurement(measurement);
    } else {
      await _db.insertWeightMeasurement(measurement);
    }
  }

  Future<void> deleteWeight(String id) => _db.deleteWeightMeasurement(id);

  Future<void> saveBody(BodyMeasurement measurement) async {
    final owner = _db.currentUserId;
    final rows = await _db.watchBodyMeasurements().first;
    if (owner != _db.currentUserId) {
      throw StateError('Account changed while saving body measurement');
    }
    if (rows.any((row) => row.id == measurement.id)) {
      await _db.updateBodyMeasurement(measurement);
    } else {
      await _db.insertBodyMeasurement(measurement);
    }
  }

  Future<void> deleteBody(String id) => _db.deleteBodyMeasurement(id);
}

@Riverpod(keepAlive: true)
MeasurementsRepository measurementsRepository(Ref ref) =>
    MeasurementsRepository(ref.watch(appDatabaseProvider));
