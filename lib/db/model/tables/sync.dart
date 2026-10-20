import 'package:drift/drift.dart';

class SyncOutbox extends Table {
  IntColumn get sequence => integer().autoIncrement()();
  TextColumn get operationId => text()();
  TextColumn get owner => text()();
  TextColumn get entity => text()();
  TextColumn get recordId => text()();
  IntColumn get baseRevision => integer().withDefault(const Constant(0))();
  TextColumn get payload => text()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get error => text().nullable()();
  BoolColumn get blocked => boolean().withDefault(const Constant(false))();
}

class SyncMetadata extends Table {
  TextColumn get owner => text()();
  TextColumn get entity => text()();
  TextColumn get recordId => text()();
  IntColumn get revision => integer()();
  TextColumn get payload => text()();
  @override
  Set<Column> get primaryKey => {owner, entity, recordId};
}

class SyncCursors extends Table {
  TextColumn get owner => text()();
  IntColumn get cursor => integer().withDefault(const Constant(0))();
  IntColumn get reconcileCursor => integer().withDefault(const Constant(0))();
  IntColumn get reconcileHorizon => integer().nullable()();
  BoolColumn get bootstrapped => boolean().withDefault(const Constant(false))();
  DateTimeColumn get reconciledAt => dateTime().nullable()();
  @override
  Set<Column> get primaryKey => {owner};
}

class SyncConflicts extends Table {
  TextColumn get operationId => text()();
  TextColumn get owner => text()();
  TextColumn get entity => text()();
  TextColumn get recordId => text()();
  TextColumn get localPayload => text()();
  TextColumn get serverPayload => text()();
  IntColumn get serverRevision => integer()();
  BoolColumn get resolved => boolean().withDefault(const Constant(false))();
  @override
  Set<Column> get primaryKey => {operationId};
}

class SyncContext extends Table {
  IntColumn get id => integer()();
  BoolColumn get receiving => boolean().withDefault(const Constant(false))();
  @override
  Set<Column> get primaryKey => {id};
}

class SyncQuarantine extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get owner => text().nullable()();
  TextColumn get entity => text()();
  TextColumn get payload => text()();
  TextColumn get reason => text()();
}
