import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:syncable/src/syncable_database.dart';
import 'package:syncable/src/syncable_table.dart';

/// SQLite triggers make domain changes and delivery records one atomic commit,
/// including writes issued outside a repository and during backup replacement.
class SyncV2Store {
  static Future<void> install(SyncableDatabase db) async {
    for (final sql in _schema) {
      await db.customStatement(sql);
    }
    await db.customStatement(
        'INSERT OR IGNORE INTO sync_context(id, receiving) VALUES(1, 0)');
    for (final table
        in db.allTables.where((t) => t.asDslTable is SyncableTable)) {
      final name = table.actualTableName;
      final id = (table.asDslTable as SyncableTable).id.name;
      final payload =
          "json_object(${table.$columns.map((c) => "'${c.name}', NEW.\"${c.name}\"").join(',')})";
      for (final event in ['INSERT', 'UPDATE']) {
        final changed = event == 'INSERT'
            ? '1'
            : table.$columns
                .where((c) => c.name != 'updated_at')
                .map((c) => 'NEW."${c.name}" IS NOT OLD."${c.name}"')
                .join(' OR ');
        final oldPayload =
            "json_object(${table.$columns.map((c) => "'${c.name}', OLD.\"${c.name}\"").join(',')})";
        final archive = event == 'UPDATE'
            ? "INSERT INTO sync_quarantine(owner,entity,payload,reason) SELECT OLD.user_id,'$name',$oldPayload,'Deleted locally on '||date('now') WHERE OLD.deleted=0 AND NEW.deleted=1;"
            : '';
        await db.customStatement(
            'DROP TRIGGER IF EXISTS sync_v2_${name}_${event.toLowerCase()}');
        await db.customStatement(
            '''CREATE TRIGGER IF NOT EXISTS sync_v2_${name}_${event.toLowerCase()}
          AFTER $event ON "$name"
          WHEN NEW.user_id IS NOT NULL AND NEW."$id" IS NOT NULL
            AND (SELECT receiving FROM sync_context WHERE id=1)=0 AND ($changed)
          BEGIN
            $archive
            INSERT INTO sync_quarantine(owner,entity,payload,reason)
              SELECT owner,entity,payload,'Failed operation superseded by a local edit: '||error FROM sync_outbox
              WHERE owner=NEW.user_id AND entity='$name' AND record_id=NEW."$id" AND error IS NOT NULL;
            DELETE FROM sync_outbox WHERE owner=NEW.user_id AND entity='$name' AND record_id=NEW."$id" AND error IS NOT NULL;
            INSERT INTO sync_outbox(operation_id, owner, entity, record_id, base_revision, payload)
            VALUES(lower(hex(randomblob(16))), NEW.user_id, '$name', NEW."$id",
              COALESCE((SELECT revision FROM sync_metadata WHERE owner=NEW.user_id AND entity='$name' AND record_id=NEW."$id"),0), $payload);
          END''');
      }
    }
    if (db.allTables.any((t) => t.actualTableName == 'nutrition_categories')) {
      await db.customStatement(
          """INSERT INTO sync_quarantine(owner,entity,payload,reason)
        SELECT user_id,'nutrition_categories',json_object('id',id,'user_id',user_id,'reference_date',reference_date,'json_data',json_data,'updated_at',updated_at,'deleted',deleted),'Missing category identity before repair'
        FROM nutrition_categories t WHERE id IS NULL AND NOT EXISTS(SELECT 1 FROM sync_quarantine q WHERE q.owner IS t.user_id AND q.entity='nutrition_categories' AND q.payload=json_object('id',t.id,'user_id',t.user_id,'reference_date',t.reference_date,'json_data',t.json_data,'updated_at',t.updated_at,'deleted',t.deleted))""");
      await db.customStatement(
          """UPDATE nutrition_categories AS t SET id=strftime('%Y-%m-%dT00:00:00.000Z',reference_date,'unixepoch') WHERE id IS NULL
        AND (SELECT count(*) FROM nutrition_categories same WHERE same.user_id IS t.user_id AND same.reference_date=t.reference_date)=1
        AND NOT EXISTS(SELECT 1 FROM nutrition_categories occupied WHERE occupied.user_id IS t.user_id AND occupied.id=strftime('%Y-%m-%dT00:00:00.000Z',t.reference_date,'unixepoch'))""");
    }
  }

  static Future<R> receiving<R>(
          SyncableDatabase db, Future<R> Function() body) =>
      db.transaction(() async {
        final previous = (await db
                .customSelect('SELECT receiving FROM sync_context WHERE id=1')
                .getSingle())
            .read<int>('receiving');
        await db
            .customStatement('UPDATE sync_context SET receiving=1 WHERE id=1');
        try {
          return await body();
        } finally {
          await db.customStatement(
              'UPDATE sync_context SET receiving=? WHERE id=1', [previous]);
          db.notifyUpdates(
              {for (final table in db.allTables) TableUpdate.onTable(table)});
        }
      });

  static Future<void> seed(SyncableDatabase db, String owner) async {
    await db.transaction(() async {
      for (final table
          in db.allTables.where((t) => t.asDslTable is SyncableTable)) {
        final name = table.actualTableName;
        final id = (table.asDslTable as SyncableTable).id.name;
        final payload =
            "json_object(${table.$columns.map((c) => "'${c.name}', t.\"${c.name}\"").join(',')})";
        await db.customStatement(
            """INSERT INTO sync_quarantine(owner,entity,payload,reason)
          SELECT user_id,'$name',$payload,'Missing identity; original preserved' FROM "$name" t
          WHERE user_id=? AND "$id" IS NULL AND NOT EXISTS(SELECT 1 FROM sync_quarantine q WHERE q.owner=t.user_id AND q.entity='$name' AND q.payload=$payload)""",
            [owner]);
        await db.customStatement(
            '''INSERT INTO sync_outbox(operation_id,owner,entity,record_id,payload)
          SELECT lower(hex(randomblob(16))), user_id, '$name', "$id", $payload FROM "$name" t
          WHERE user_id=? AND "$id" IS NOT NULL
          AND NOT EXISTS(SELECT 1 FROM sync_metadata m WHERE m.owner=t.user_id AND m.entity='$name' AND m.record_id=t."$id")
          AND NOT EXISTS(SELECT 1 FROM sync_outbox o WHERE o.owner=t.user_id AND o.entity='$name' AND o.record_id=t."$id")''',
            [owner]);
      }
    });
  }

  static Future<void> remember(SyncableDatabase db, String owner, String entity,
          String id, int revision, Map<String, dynamic> payload) =>
      db.customStatement(
          'INSERT OR REPLACE INTO sync_metadata(owner,entity,record_id,revision,payload) VALUES(?,?,?,?,?)',
          [owner, entity, id, revision, jsonEncode(payload)]);

  static Future<int> pending(SyncableDatabase db, String owner) async =>
      (await db.customSelect(
              'SELECT count(*) AS n FROM sync_outbox WHERE owner=?',
              variables: [Variable(owner)]).getSingle())
          .read<int>('n');

  static const _schema = [
    'CREATE TABLE IF NOT EXISTS sync_context(id INTEGER NOT NULL PRIMARY KEY, receiving INTEGER NOT NULL DEFAULT 0)',
    'CREATE TABLE IF NOT EXISTS sync_outbox(sequence INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, operation_id TEXT NOT NULL, owner TEXT NOT NULL, entity TEXT NOT NULL, record_id TEXT NOT NULL, base_revision INTEGER NOT NULL DEFAULT 0, payload TEXT NOT NULL, attempts INTEGER NOT NULL DEFAULT 0, error TEXT, blocked INTEGER NOT NULL DEFAULT 0)',
    'CREATE INDEX IF NOT EXISTS sync_outbox_owner ON sync_outbox(owner,entity,record_id,sequence)',
    'CREATE TABLE IF NOT EXISTS sync_metadata(owner TEXT NOT NULL, entity TEXT NOT NULL, record_id TEXT NOT NULL, revision INTEGER NOT NULL, payload TEXT NOT NULL, PRIMARY KEY(owner,entity,record_id))',
    'CREATE TABLE IF NOT EXISTS sync_cursors(owner TEXT NOT NULL PRIMARY KEY, cursor INTEGER NOT NULL DEFAULT 0, bootstrapped INTEGER NOT NULL DEFAULT 0, reconciled_at INTEGER, reconcile_cursor INTEGER NOT NULL DEFAULT 0,reconcile_horizon INTEGER)',
    'CREATE TABLE IF NOT EXISTS sync_conflicts(operation_id TEXT NOT NULL PRIMARY KEY,owner TEXT NOT NULL,entity TEXT NOT NULL,record_id TEXT NOT NULL,local_payload TEXT NOT NULL,server_payload TEXT NOT NULL,server_revision INTEGER NOT NULL,resolved INTEGER NOT NULL DEFAULT 0)',
    'CREATE TABLE IF NOT EXISTS sync_quarantine(id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,owner TEXT,entity TEXT NOT NULL,payload TEXT NOT NULL,reason TEXT NOT NULL)',
  ];
}

enum SyncOutcome { completed, partial, offline, timeout, disabled, cancelled }

class SyncResult {
  const SyncResult(this.outcome,
      {required this.userId,
      required this.cycleId,
      this.pending = 0,
      this.error});
  final SyncOutcome outcome;
  final String userId;
  final String cycleId;
  final int pending;
  final Object? error;
  bool get completed => outcome == SyncOutcome.completed;
}
