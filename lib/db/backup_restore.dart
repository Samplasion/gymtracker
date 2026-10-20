import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

import 'package:drift/drift.dart';
import 'package:gymtracker/db/database.dart';
import 'package:syncable/syncable.dart';

enum RestoreMode { merge, replace }

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
    final manifest = File('${file.path}.json');
    if (await manifest.exists()) {
      final metadata =
          jsonDecode(await manifest.readAsString()) as Map<String, dynamic>;
      final digest = (await sha256.bind(file.openRead()).first).toString();
      if (metadata['sha256'] != digest)
        throw StateError('Backup checksum mismatch');
    }
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
  int get count => rows.values.fold(0, (n, r) => n + r.length);
  Future<void> apply(
    GTDatabase db, {
    RestoreMode mode = RestoreMode.replace,
  }) => db.transaction(() async {
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
      if (mode == RestoreMode.replace) {
        final retained = rows[name]!
            .map((r) => r[(table.asDslTable as SyncableTable).id.name])
            .toSet();
        final current = await db
            .customSelect(
              'SELECT * FROM "$name" WHERE user_id IS ?',
              variables: [Variable(owner)],
            )
            .get();
        for (final row in current) {
          final idColumn = (table.asDslTable as SyncableTable).id.name;
          if (!retained.contains(row.data[idColumn]) &&
              row.data['deleted'] != 1) {
            await db.customStatement(
              'UPDATE "$name" SET deleted=1,updated_at=? WHERE user_id IS ? AND "$idColumn" IS ?',
              [revision, owner, row.data[idColumn]],
            );
          }
        }
      }
      for (final original in rows[name]!) {
        if (original['user_id'] != owner) {
          throw StateError('Unexpected backup owner');
        }
        final row = {...original, 'updated_at': revision};
        // Some local identity columns use barcode / food_id instead of id.
        final idColumn = (table.asDslTable as SyncableTable).id.name;
        final present = await db
            .customSelect(
              'SELECT * FROM "$name" WHERE "$idColumn" IS ? AND user_id IS ? LIMIT 1',
              variables: [Variable(row[idColumn]), Variable(owner)],
            )
            .get();
        if (present.isEmpty) {
          await _insert(db, name, row);
        } else {
          if (mode == RestoreMode.merge) {
            final existing = Map<String, Object?>.from(present.single.data)
              ..remove('updated_at');
            final restored = Map<String, Object?>.from(row)
              ..remove('updated_at');
            if (jsonEncode(existing) != jsonEncode(restored)) {
              await db.customStatement(
                'INSERT INTO sync_quarantine(owner,entity,payload,reason) VALUES(?,?,?,?)',
                [
                  owner,
                  name,
                  jsonEncode(original),
                  'Backup merge collision; current value preserved',
                ],
              );
            }
            continue;
          }
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
    if (mode == RestoreMode.replace)
      await db.customStatement('DELETE FROM ongoing_data WHERE owner = ?', [
        ongoingOwner,
      ]);
    for (final row
        in mode == RestoreMode.replace ? ongoing : <Map<String, Object?>>[]) {
      await _insert(db, 'ongoing_data', row);
    }
    if (mode == RestoreMode.replace && preferences.isNotEmpty) {
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
