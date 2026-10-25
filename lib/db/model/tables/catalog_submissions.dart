import 'package:drift/drift.dart';

/// Explicit publication requests; deliberately not a SyncableTable.
class CatalogSubmissions extends Table {
  TextColumn get operationId => text()();
  TextColumn get owner => text()();
  TextColumn get definition => text()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  TextColumn get result => text().nullable()();
  TextColumn get error => text().nullable()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  DateTimeColumn get nextAttempt => dateTime()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {operationId};
}
