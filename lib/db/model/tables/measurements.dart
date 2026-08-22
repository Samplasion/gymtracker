import 'package:drift/drift.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/model/measurements.dart';
import 'package:syncable/syncable.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

@UseRowClass(WeightMeasurement)
class WeightMeasurements extends Table implements SyncableTable {
  @override
  Set<Column<Object>> get primaryKey => {id, userId};

  @override
  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  RealColumn get weight => real()();
  Column<DateTime> get time => dateTime()();
  TextColumn get weightUnit => textEnum<Weights>()();
  @override
  DateTimeColumn get updatedAt => dateTime().withDefault(
    Constant(DateTime.fromMicrosecondsSinceEpoch(0, isUtc: true)),
  )();
  @override
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  @override
  TextColumn get userId => text().nullable()();
}

@UseRowClass(BodyMeasurement)
class BodyMeasurements extends Table implements SyncableTable {
  @override
  Set<Column<Object>> get primaryKey => {id, userId};

  @override
  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  RealColumn get value => real()();
  Column<DateTime> get time => dateTime()();
  TextColumn get type => textEnum<BodyMeasurementPart>()();
  @override
  DateTimeColumn get updatedAt => dateTime().withDefault(
    Constant(DateTime.fromMicrosecondsSinceEpoch(0, isUtc: true)),
  )();
  @override
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  @override
  TextColumn get userId => text().nullable()();
}
