import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:gymtracker/db/database.dart';
import 'package:uuid/uuid.dart';

class WaterEntry {
  const WaterEntry({
    required this.id,
    required this.milliliters,
    required this.time,
  });
  final String id;
  final double milliliters;
  final DateTime time;

  factory WaterEntry.fromRow(DBWaterLog row) {
    final json = jsonDecode(row.jsonData) as Map<String, dynamic>;
    final milliliters = (json['milliliters'] as num).toDouble();
    if (!milliliters.isFinite || milliliters <= 0) {
      throw const FormatException('Invalid water quantity');
    }
    return WaterEntry(
      id: row.id,
      milliliters: milliliters,
      time: DateTime.parse(json['time'] as String).toLocal(),
    );
  }
}

class HydrationRepository {
  HydrationRepository(this.db);
  final GTDatabase db;

  Expression<bool> owned(TextColumn column, String? owner) =>
      owner == null ? column.isNull() : column.equals(owner);

  Stream<List<WaterEntry>> watch(String? owner) =>
      (db.select(db.waterLogs)
            ..where((t) => owned(t.userId, owner) & t.deleted.equals(false))
            ..orderBy([(t) => OrderingTerm.asc(t.dateAdded)]))
          .watch()
          .map((rows) => rows.map(WaterEntry.fromRow).toList());

  Future<void> save({
    required double milliliters,
    required DateTime time,
    String? id,
  }) async {
    if (!milliliters.isFinite ||
        milliliters <= 0 ||
        time.isAfter(DateTime.now())) {
      throw ArgumentError('Invalid water entry');
    }
    final owner = db.currentUserId;
    final entryId = id ?? const Uuid().v4();
    final value = WaterLogsCompanion(
      id: Value(entryId),
      userId: Value(owner),
      dateAdded: Value(time.toUtc()),
      referenceDate: Value(DateTime.utc(time.year, time.month, time.day)),
      jsonData: Value(
        jsonEncode({
          'milliliters': milliliters,
          'time': time.toUtc().toIso8601String(),
        }),
      ),
      updatedAt: Value(DateTime.now().toUtc()),
      deleted: const Value(false),
    );
    await db.transaction(() async {
      if (db.currentUserId != owner) throw StateError('Account changed');
      if (id == null) {
        await db.into(db.waterLogs).insert(value);
      } else {
        await (db.update(db.waterLogs)
              ..where((t) => owned(t.userId, owner) & t.id.equals(entryId)))
            .write(value);
      }
    });
  }

  Future<void> remove(String id) {
    final owner = db.currentUserId;
    return (db.update(
      db.waterLogs,
    )..where((t) => owned(t.userId, owner) & t.id.equals(id))).write(
      WaterLogsCompanion(
        deleted: const Value(true),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }
}
