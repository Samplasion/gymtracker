import 'dart:convert';
import 'dart:io';
import 'package:sqlite3/sqlite3.dart' as sqlite;
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:gymtracker/db/database.dart';
import 'package:syncable/syncable.dart';

class GuestImportPreview {
  GuestImportPreview(this.rows, this.collisions);
  final Map<String, List<Map<String, Object?>>> rows;
  final int collisions;
  int get count => rows.values.fold(0, (n, r) => n + r.length);
  static Future<GuestImportPreview> load(GTDatabase db, String owner) async {
    final rows = <String, List<Map<String, Object?>>>{};
    var collisions = 0;
    await db.transaction(() async {
      for (final t in db.allTables.where(
        (t) => t.asDslTable is SyncableTable,
      )) {
        final id = (t.asDslTable as SyncableTable).id.name;
        rows[t.actualTableName] =
            (await db
                    .customSelect(
                      'SELECT * FROM "${t.actualTableName}" WHERE user_id IS NULL',
                    )
                    .get())
                .map((r) => r.data)
                .toList();
        collisions +=
            (await db
                    .customSelect(
                      'SELECT count(*) AS n FROM "${t.actualTableName}" g WHERE g.user_id IS NULL AND EXISTS(SELECT 1 FROM "${t.actualTableName}" u WHERE u.user_id=? AND u."$id" IS g."$id")',
                      variables: [Variable(owner)],
                    )
                    .getSingle())
                .read<int>('n');
      }
    });
    return GuestImportPreview(rows, collisions);
  }

  Future<void> apply(GTDatabase db, String owner) => db.transaction(() async {
    if (db.currentUserId != owner) throw StateError('Account changed');
    for (final t in db.allTables.where((t) => t.asDslTable is SyncableTable)) {
      final id = (t.asDslTable as SyncableTable).id.name;
      for (final row in rows[t.actualTableName] ?? <Map<String, Object?>>[]) {
        final current = await db
            .customSelect(
              'SELECT * FROM "${t.actualTableName}" WHERE user_id IS NULL AND "$id" IS ?',
              variables: [Variable(row[id])],
            )
            .get();
        if (current.length > 1) {
          for (final duplicate in current) {
            await db.customStatement(
              'INSERT INTO sync_quarantine(owner,entity,payload,reason) SELECT ?,?,?,? WHERE NOT EXISTS(SELECT 1 FROM sync_quarantine WHERE owner=? AND entity=? AND payload=?)',
              [
                owner,
                t.actualTableName,
                jsonEncode(duplicate.data),
                'Ambiguous guest identity; original preserved',
                owner,
                t.actualTableName,
                jsonEncode(duplicate.data),
              ],
            );
          }
          continue;
        }
        if (current.length != 1 ||
            jsonEncode(current.single.data) != jsonEncode(row))
          throw StateError('Guest data changed; reopen the preview');
        final occupied = await db
            .customSelect(
              'SELECT 1 FROM "${t.actualTableName}" WHERE user_id=? AND "$id" IS ?',
              variables: [Variable(owner), Variable(row[id])],
            )
            .get();
        if (occupied.isNotEmpty || row[id] == null) {
          await db.customStatement(
            'INSERT INTO sync_quarantine(owner,entity,payload,reason) VALUES(?,?,?,?)',
            [
              owner,
              t.actualTableName,
              jsonEncode(row),
              'Guest collision: original retained in guest account',
            ],
          );
          continue;
        }
        await db.customStatement(
          'UPDATE "${t.actualTableName}" SET user_id=? WHERE user_id IS NULL AND "$id"=?',
          [owner, row[id]],
        );
        db.notifyUpdates({TableUpdate.onTable(t)});
      }
    }
  });
}

class SyncDiagnostics {
  static Future<void> recover(
    GTDatabase db,
    int quarantineId,
  ) => db.transaction(() async {
    final owner = db.currentUserId;
    final saved = await db
        .customSelect(
          'SELECT * FROM sync_quarantine WHERE id=? AND owner IS ?',
          variables: [Variable(quarantineId), Variable(owner)],
        )
        .getSingle();
    final table = db.allTables
        .where((t) => t.asDslTable is SyncableTable)
        .singleWhere((t) => t.actualTableName == saved.read<String>('entity'));
    final payload = Map<String, dynamic>.from(
      jsonDecode(saved.read<String>('payload')) as Map,
    );
    final id = (table.asDslTable as SyncableTable).id.name;
    if (payload[id] == null &&
        table.actualTableName == 'nutrition_categories' &&
        payload['reference_date'] is int) {
      final date = DateTime.fromMillisecondsSinceEpoch(
        (payload['reference_date'] as int) * 1000,
        isUtc: true,
      );
      payload[id] = DateTime.utc(
        date.year,
        date.month,
        date.day,
      ).toIso8601String();
    }
    if (payload[id] == null)
      throw StateError('An identity must be repaired before recovery');
    if (payload['user_id'] != null && payload['user_id'] != owner)
      throw StateError('Unexpected recovery owner');
    final current = await db
        .customSelect(
          'SELECT * FROM "${table.actualTableName}" WHERE user_id IS ? AND "$id" IS ?',
          variables: [Variable(owner), Variable(payload[id])],
        )
        .get();
    for (final row in current) {
      await db.customStatement(
        'INSERT INTO sync_quarantine(owner,entity,payload,reason) VALUES(?,?,?,?)',
        [
          owner,
          table.actualTableName,
          jsonEncode(row.data),
          'Value before explicit recovery',
        ],
      );
    }
    payload['user_id'] = owner;
    payload['updated_at'] = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final columns = table.$columns.map((c) => c.name).toSet();
    if (payload.keys.any((k) => !columns.contains(k)))
      throw StateError('Unknown recovery fields');
    if (current.isEmpty) {
      await db.customStatement(
        'INSERT INTO "${table.actualTableName}" (${payload.keys.map((c) => '"$c"').join(',')}) VALUES(${payload.keys.map((_) => '?').join(',')})',
        payload.values.toList(),
      );
    } else {
      await db.customStatement(
        'UPDATE "${table.actualTableName}" SET ${payload.keys.map((c) => '"$c"=?').join(',')} WHERE user_id IS ? AND "$id" IS ?',
        [...payload.values, owner, payload[id]],
      );
    }
    db.notifyUpdates({TableUpdate.onTable(table)});
  });

  static Future<Map<String, dynamic>> counts(GTDatabase db) async {
    final counts = <String, dynamic>{};
    for (final t in db.allTables.where((t) => t.asDslTable is SyncableTable)) {
      counts[t.actualTableName] =
          (await db
                  .customSelect(
                    'SELECT user_id,deleted,count(*) AS count,min(updated_at) AS oldest,max(updated_at) AS newest FROM "${t.actualTableName}" GROUP BY user_id,deleted',
                  )
                  .get())
              .map((r) => r.data)
              .toList();
    }
    return counts;
  }

  static Map<String, dynamic> fileCounts(File file, GTDatabase db) {
    final snapshot = sqlite.sqlite3.open(
      file.path,
      mode: sqlite.OpenMode.readOnly,
    );
    try {
      if (snapshot.select('PRAGMA integrity_check').single.values.single !=
          'ok')
        throw StateError('Invalid diagnostic snapshot');
      return {
        for (final t in db.allTables.where(
          (t) => t.asDslTable is SyncableTable,
        ))
          t.actualTableName: snapshot
              .select(
                'SELECT user_id,deleted,count(*) AS count,min(updated_at) AS oldest,max(updated_at) AS newest FROM "${t.actualTableName}" GROUP BY user_id,deleted',
              )
              .map((r) => Map<String, Object?>.from(r))
              .toList(),
      };
    } finally {
      snapshot.close();
    }
  }

  /// Explicit user export; the database includes tombstones and recovery data.
  static Future<File> export(GTDatabase db, Directory directory) async {
    await directory.create(recursive: true);
    final file = File(
      '${directory.path}/diagnostic-${DateTime.now().microsecondsSinceEpoch}.sqlite',
    );
    await db.customStatement('VACUUM INTO ?', [file.path]);
    final manifest = {
      'schema': db.schemaVersion,
      'owner': db.currentUserId,
      'created_at': DateTime.now().toUtc().toIso8601String(),
      'sha256': (await sha256.bind(file.openRead()).first).toString(),
      'counts': fileCounts(file, db),
      'incident_status':
          'Unclassified: compare this snapshot with server and prior backups before attempting recovery.',
    };
    await File('${file.path}.json').writeAsString(jsonEncode(manifest));
    return file;
  }
}
