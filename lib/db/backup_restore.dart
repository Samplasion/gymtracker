import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:gymtracker/db/database.dart';
import 'package:syncable/syncable.dart';

/// Validates/migrates a disposable copy. Never opens the original for writing.
class PreparedDatabaseRestore {
  PreparedDatabaseRestore(
    this.owner,
    this.rows,
    this.ongoing,
    this.preferences,
  );

  final String? owner;
  final Map<String, List<Map<String, Object?>>> rows;
  final List<Map<String, Object?>> ongoing;
  final List<Map<String, Object?>> preferences;

  static Future<PreparedDatabaseRestore> load(File file, String? owner) async {
    if (!await file.exists()) throw StateError('Backup does not exist');
    final temp = await Directory.systemTemp.createTemp('gymtracker-restore-');
    GTDatabaseImpl? source;
    try {
      final copy = await file.copy('${temp.path}/backup.sqlite');
      source = GTDatabaseImpl.openBackup(copy);
      final integrity = await source
          .customSelect('PRAGMA integrity_check')
          .get();
      if (integrity.length != 1 ||
          integrity.single.data.values.single != 'ok') {
        throw StateError('Backup integrity check failed');
      }
      source.setCurrentUserId(owner);
      final rows = <String, List<Map<String, Object?>>>{};
      var hasSelectedOwner = false;
      var hasOtherOwner = false;
      for (final table in source.allTables) {
        if (table.asDslTable is! SyncableTable) continue;
        final selected = await source
            .customSelect(
              'SELECT * FROM "${table.actualTableName}" WHERE user_id IS ?',
              variables: [Variable(owner)],
            )
            .get();
        rows[table.actualTableName] = selected
            .map((row) => Map<String, Object?>.from(row.data))
            .toList();
        hasSelectedOwner |= selected.isNotEmpty;
        final other = await source
            .customSelect(
              'SELECT 1 FROM "${table.actualTableName}" WHERE user_id IS NOT ? LIMIT 1',
              variables: [Variable(owner)],
            )
            .get();
        hasOtherOwner |= other.isNotEmpty;
      }
      if (!hasSelectedOwner && hasOtherOwner) {
        throw StateError('This backup has no data for the current account');
      }
      // Exercise domain decoders before touching the live database.
      await source.watchFoods().first;
      await source.watchNutritionCategories().first;
      await source.watchCustomBarcodeFoods().first;
      await source.watchNutritionGoals().first;
      final ongoing =
          (await source
                  .customSelect(
                    'SELECT * FROM ongoing_data WHERE owner = ?',
                    variables: [
                      Variable(owner == null ? 'guest' : 'user:$owner'),
                    ],
                  )
                  .get())
              .map((row) => Map<String, Object?>.from(row.data))
              .toList();
      for (final row in ongoing) {
        jsonDecode(row['data'] as String) as Map<String, dynamic>;
      }
      final preferences =
          (await source.customSelect('SELECT * FROM preferences').get())
              .map((row) => Map<String, Object?>.from(row.data))
              .toList();
      await source.watchPreferences().first;
      return PreparedDatabaseRestore(owner, rows, ongoing, preferences);
    } finally {
      await source?.close();
      await temp.delete(recursive: true);
    }
  }

  /// Replace the current owner's snapshot without changing database identity.
  /// Missing local records become tombstones so known deletions reach the cloud.
  Future<void> apply(GTDatabase db) => db.transaction(() async {
    if (db.currentUserId != owner) {
      throw StateError('Account changed before restore');
    }
    var newest = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    for (final table in db.allTables) {
      if (table.asDslTable is! SyncableTable) continue;
      final current = await db
          .customSelect(
            'SELECT MAX(updated_at) AS newest FROM "${table.actualTableName}" WHERE user_id IS ?',
            variables: [Variable(owner)],
          )
          .getSingle();
      final stamp = current.data['newest'] as int?;
      if (stamp != null && stamp > newest) newest = stamp;
      for (final row in rows[table.actualTableName]!) {
        final stamp = row['updated_at'] as int;
        if (stamp > newest) newest = stamp;
      }
    }
    final revision = newest + 1;
    for (final table in db.allTables) {
      if (table.asDslTable is! SyncableTable) continue;
      final name = table.actualTableName;
      await db.customStatement(
        'UPDATE "$name" SET deleted = 1, updated_at = ? WHERE user_id IS ?',
        [revision, owner],
      );
      for (final original in rows[name]!) {
        if (original['user_id'] != owner) {
          throw StateError('Unexpected backup owner');
        }
        final row = {...original, 'updated_at': revision};
        // Some local identity columns use barcode / food_id instead of id.
        final idColumn = (table.asDslTable as SyncableTable).id.name;
        final present = await db
            .customSelect(
              'SELECT 1 FROM "$name" WHERE "$idColumn" IS ? AND user_id IS ? LIMIT 1',
              variables: [Variable(row[idColumn]), Variable(owner)],
            )
            .get();
        if (present.isEmpty) {
          await _insert(db, name, row);
        } else {
          final columns = row.keys.toList();
          await db.customStatement(
            'UPDATE "$name" SET ${columns.map((c) => '"$c" = ?').join(', ')} WHERE "$idColumn" IS ? AND user_id IS ?',
            [...columns.map((c) => row[c]), row[idColumn], owner],
          );
        }
      }
      db.notifyUpdates({TableUpdate.onTable(table)});
    }
    final ongoingOwner = owner == null ? 'guest' : 'user:$owner';
    await db.customStatement('DELETE FROM ongoing_data WHERE owner = ?', [
      ongoingOwner,
    ]);
    for (final row in ongoing) {
      await _insert(db, 'ongoing_data', row);
    }
    if (preferences.isNotEmpty) {
      await db.customStatement('DELETE FROM preferences');
      for (final row in preferences) {
        await _insert(db, 'preferences', row);
      }
    }
    db.notifyUpdates({
      for (final table in db.allTables) TableUpdate.onTable(table),
    });
    if (db.currentUserId != owner) {
      throw StateError('Account changed during restore');
    }
  });

  static Future<void> _insert(
    GTDatabase db,
    String name,
    Map<String, Object?> row,
  ) => db.customStatement(
    'INSERT INTO "$name" (${row.keys.map((c) => '"$c"').join(', ')}) VALUES (${row.keys.map((_) => '?').join(', ')})',
    row.values.toList(),
  );
}
