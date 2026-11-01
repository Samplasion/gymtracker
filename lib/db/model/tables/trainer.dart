import 'package:drift/drift.dart';

/// Read-only server authorization snapshot. Never exported or restored as authority.
class TrainerCaches extends Table {
  TextColumn get owner => text()();
  TextColumn get payload => text()();
  DateTimeColumn get checkedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {owner};
}
