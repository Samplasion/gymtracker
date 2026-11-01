import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:gymtracker/db/database.dart';

/// Local-only protocol journal, installed like SyncV2Store. This auxiliary table
/// is intentionally excluded from cloud sync and portable workout backups.
// Retain the legacy SQL table name so existing installations need no migration.
class WearableTrainingStore {
  final GTDatabase db;
  WearableTrainingStore(this.db);
  static Future<void> install(GeneratedDatabase db) => db.customStatement('''
    CREATE TABLE IF NOT EXISTS watch_training_journal (
      owner TEXT NOT NULL, id TEXT NOT NULL, document TEXT NOT NULL,
      processed INTEGER NOT NULL DEFAULT 0, PRIMARY KEY(owner, id)
    )
  ''');
  Future<Map<String, dynamic>?> read(String owner, String id) async {
    final row = await db
        .customSelect(
          'SELECT document FROM watch_training_journal WHERE owner = ? AND id = ?',
          variables: [Variable(owner), Variable(id)],
        )
        .getSingleOrNull();
    return row == null
        ? null
        : jsonDecode(row.read<String>('document')) as Map<String, dynamic>;
  }

  Future<bool> processed(String owner, String id) async {
    final row = await db
        .customSelect(
          'SELECT processed FROM watch_training_journal WHERE owner = ? AND id = ?',
          variables: [Variable(owner), Variable(id)],
        )
        .getSingleOrNull();
    return row?.read<int>('processed') == 1;
  }

  Future<void> write(Map<String, dynamic> document, {bool processed = false}) =>
      db.customStatement(
        '''
    INSERT INTO watch_training_journal(owner, id, document, processed) VALUES (?, ?, ?, ?)
    ON CONFLICT(owner, id) DO UPDATE SET document = excluded.document,
      processed = MAX(watch_training_journal.processed, excluded.processed)
    WHERE watch_training_journal.processed = 0 OR excluded.processed = 1
  ''',
        [
          document['ownerScope'],
          document['id'],
          jsonEncode(document),
          processed ? 1 : 0,
        ],
      );
}
