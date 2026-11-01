import 'package:drift/drift.dart';
import 'package:gymtracker/db/database.dart';
import 'package:syncable/syncable.dart';

/// Apply the user's explicit bulk choice through the existing resolver.
/// One outer transaction keeps this batch atomic and retains recovery history.
Future<int> resolveSelectedSyncConflicts({
  required GTDatabase db,
  required SyncManager<GTDatabase> manager,
  required String owner,
  required Set<String> operationIds,
  required bool useLocal,
  void Function(int completed, int total)? onProgress,
}) async {
  void checkOwner() {
    if (db.currentUserId != owner || manager.userId != owner) {
      throw StateError('Account changed');
    }
  }

  checkOwner();
  final wasEnabled = manager.syncingEnabled;
  var drained = false;
  try {
    await manager.suspend();
    drained = true;
    checkOwner();
    return await db.transaction(() async {
      final rows = await db
          .customSelect(
            'SELECT operation_id,entity,record_id FROM sync_conflicts WHERE owner=? AND resolved=0',
            variables: [Variable(owner)],
          )
          .get();
      final selected = <(String, String), String>{};
      for (final row in rows) {
        final id = row.read<String>('operation_id');
        if (operationIds.contains(id)) {
          selected[(
                row.read<String>('entity'),
                row.read<String>('record_id'),
              )] =
              id;
        }
      }
      var completed = 0;
      for (final id in selected.values) {
        checkOwner();
        await manager.resolveConflict(id, useLocal: useLocal);
        onProgress?.call(++completed, selected.length);
      }
      checkOwner();
      return completed;
    });
  } finally {
    if (drained &&
        wasEnabled &&
        db.currentUserId == owner &&
        manager.userId == owner) {
      manager.enableSync();
    }
  }
}
