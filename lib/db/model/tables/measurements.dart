import 'package:drift/drift.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/model/measurements.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

@UseRowClass(WeightMeasurement)
class WeightMeasurements extends Table {
  @override
  Set<Column<Object>> get primaryKey => {id};

  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  RealColumn get weight => real()();
  Column<DateTime> get time => dateTime()();
  TextColumn get weightUnit => textEnum<Weights>()();
}
