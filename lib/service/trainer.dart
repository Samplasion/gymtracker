import 'dart:async';

import 'package:drift/drift.dart' show Variable;
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/utils/utils.dart' show isNetworkError;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncable/syncable.dart';

class TrainerApiException implements Exception {
  final String code;
  const TrainerApiException(this.code);
  @override
  String toString() => code;
}

class TrainerService {
  static final _attempts =
      Expando<({String owner, DateTime at, bool failed})>();
  static final _heartbeats = Expando<({String owner, DateTime at})>();
  // Shared across service instances used by the page and background sync.
  static final _refreshGenerations = Expando<int>();
  final Duration requestTimeout;
  final Duration acceptanceTimeout;
  final GTDatabase db;
  final SupabaseClient client;
  TrainerService(
    this.db,
    this.client, {
    this.requestTimeout = const Duration(seconds: 8),
    // Billing may make two sequential requests with 15-second timeouts.
    this.acceptanceTimeout = const Duration(seconds: 45),
  });

  int _invalidateRefreshes() =>
      _refreshGenerations[db] = (_refreshGenerations[db] ?? 0) + 1;

  Future<dynamic> execute(
    String operation, [
    Map<String, dynamic> payload = const {},
  ]) async {
    final owner = db.currentUserId;
    if (owner == null || client.auth.currentUser?.id != owner) {
      throw const TrainerApiException('sign_in_required');
    }
    try {
      final response = await client.functions
          .invoke(
            'trainer-api',
            body: {...payload, 'operation': operation, 'protocol_version': 1},
          )
          .timeout(operation == 'accept' ? acceptanceTimeout : requestTimeout);
      if (db.currentUserId != owner) {
        throw const TrainerApiException('account_changed');
      }
      return response.data;
    } on FunctionException catch (error) {
      globalLogger.warning(
        'Trainer request $operation failed (HTTP ${error.status}).',
      );
      final details = error.details;
      throw TrainerApiException(
        details is Map
            ? details['error'] as String? ?? 'temporarily_unavailable'
            : 'temporarily_unavailable',
      );
    } on TimeoutException {
      throw const TrainerApiException('request_timeout');
    } catch (error) {
      if (isNetworkError(error)) {
        throw const TrainerApiException('network_unavailable');
      }
      rethrow;
    }
  }

  Future<void> refresh() async {
    final owner = db.currentUserId;
    if (owner == null) return;
    final generation = _invalidateRefreshes();
    final data = Map<String, dynamic>.from(await execute('session') as Map);
    if (_refreshGenerations[db] != generation || db.currentUserId != owner) {
      return;
    }
    await db.cacheTrainerState(owner, data);
  }

  Future<void> _synchronize(
    Future<SyncResult> Function() synchronize, {
    required String owner,
    required String failureCode,
  }) async {
    final result = await synchronize();
    if (db.currentUserId != owner || result.userId != owner) {
      throw const TrainerApiException('account_changed');
    }
    if (!result.completed) {
      final conflicts = await _logIncompleteSync(
        result,
        owner: owner,
        stage: failureCode,
      );
      if (failureCode == 'sync_required' && conflicts > 0) {
        throw const TrainerApiException('sync_conflicts');
      }
      // A finished cycle can still have blocked outgoing edits after its pull
      // succeeded. This does not prove that the imported plan failed to download.
      if (failureCode == 'download_pending' &&
          result.outcome == SyncOutcome.partial &&
          result.error == null &&
          result.pending > 0) {
        throw const TrainerApiException('sync_pending');
      }
      throw TrainerApiException(failureCode);
    }
  }

  /// Diagnostics must never contain payloads, record IDs or server messages.
  Future<int> _logIncompleteSync(
    SyncResult result, {
    required String owner,
    required String stage,
  }) async {
    String safeCode(String? code) =>
        code != null &&
            (RegExp(r'^[A-Z0-9]{5}$').hasMatch(code) ||
                code == 'invalid_payload')
        ? code
        : 'unknown';
    final error = result.error;
    final cause = error == null
        ? 'none'
        : error is PostgrestException
        ? 'PostgrestException:${safeCode(error.code)}'
        : error.runtimeType.toString();
    var queue = 'queue=unavailable';
    var conflicts = 0;
    try {
      final counts = await db
          .customSelect(
            '''SELECT count(*) AS pending,
          coalesce(sum(blocked),0) AS blocked,
          coalesce(sum(CASE WHEN error IS NOT NULL THEN 1 ELSE 0 END),0) AS rejected,
          (SELECT count(*) FROM sync_conflicts WHERE owner=? AND resolved=0) AS conflicts
          FROM sync_outbox WHERE owner=?''',
            variables: [Variable(owner), Variable(owner)],
          )
          .getSingle();
      conflicts = counts.read<int>('conflicts');
      final rejections = await db
          .customSelect(
            '''SELECT entity,error,count(*) AS n FROM sync_outbox
          WHERE owner=? AND error IS NOT NULL
          GROUP BY entity,error ORDER BY count(*) DESC LIMIT 8''',
            variables: [Variable(owner)],
          )
          .get();
      final entities = db.allTables
          .map((table) => table.actualTableName)
          .toSet();
      final codes = rejections
          .map((row) {
            final entity = row.read<String>('entity');
            return '${entities.contains(entity) ? entity : 'unknown'}:'
                '${safeCode(row.read<String>('error'))}:${row.read<int>('n')}';
          })
          .join(',');
      queue =
          'pending=${counts.read<int>('pending')}, '
          'blocked=${counts.read<int>('blocked')}, '
          'rejected=${counts.read<int>('rejected')}, '
          'conflicts=${counts.read<int>('conflicts')}, codes=[$codes]';
    } catch (_) {
      // Diagnostic queries must not replace the original sync failure.
    }
    globalLogger.warning(
      'Trainer synchronization incomplete (${result.outcome.name}); '
      'stage=$stage, reportedPending=${result.pending}, $queue, cause=$cause.',
    );
    return conflicts;
  }

  /// A page refresh also resumes downloads committed before a lost response or
  /// an interrupted sync. Content continues to arrive through normal sync.
  Future<void> refreshAndSync(Future<SyncResult> Function() synchronize) async {
    final owner = db.currentUserId;
    if (owner == null) return;
    final hadControls = db.cachedTrainerState.controls.isNotEmpty;
    await refresh();
    if (db.currentUserId != owner) {
      throw const TrainerApiException('account_changed');
    }
    if (hadControls || db.cachedTrainerState.controls.isNotEmpty) {
      await _synchronize(
        synchronize,
        owner: owner,
        failureCode: 'download_pending',
      );
    }
  }

  Future<void> performMutation(
    String operation,
    Map<String, dynamic> payload, {
    Future<SyncResult> Function()? synchronize,
  }) async {
    final owner = db.currentUserId;
    if (owner == null) throw const TrainerApiException('sign_in_required');
    // Acceptance checks the server's current counts (soft limits). Unrelated
    // local conflicts must not prevent the remote import; sync afterwards.
    if (synchronize != null && operation != 'accept') {
      await _synchronize(
        synchronize,
        owner: owner,
        failureCode: 'sync_required',
      );
    }
    if (db.currentUserId != owner) {
      throw const TrainerApiException('account_changed');
    }
    var committed = false;
    _invalidateRefreshes();
    try {
      await execute(operation, payload);
      committed = true;
      _invalidateRefreshes();
      await refresh();
      if (synchronize != null) {
        await _synchronize(
          synchronize,
          owner: owner,
          failureCode: operation == 'accept'
              ? 'download_pending'
              : 'sync_pending',
        );
      }
    } catch (error, stack) {
      _invalidateRefreshes();
      // A failed response does not prove the transaction failed. Re-read the
      // authoritative session, keeping confirmed offline controls on failure.
      if (db.currentUserId == owner) {
        try {
          await refresh();
        } catch (_) {
          /* Retry from the refresh action or a later sync. */
        }
      }
      if (committed && synchronize != null && db.currentUserId == owner) {
        if (error is TrainerApiException && error.code == 'sync_pending') {
          Error.throwWithStackTrace(error, stack);
        }
        throw TrainerApiException(
          operation == 'accept' ? 'download_pending' : 'sync_pending',
        );
      }
      Error.throwWithStackTrace(error, stack);
    }
  }

  /// Network failure never means the relationship ended. Keep the last snapshot.
  Future<void> refreshIfAvailable({bool synced = false}) async {
    final owner = db.currentUserId;
    if (owner == null) return;
    final now = DateTime.now();
    if (synced) {
      final last = _heartbeats[db];
      if (last?.owner == owner &&
          now.difference(last!.at) < const Duration(minutes: 1)) {
        return;
      }
      _heartbeats[db] = (owner: owner, at: now);
      try {
        await execute('synced');
      } catch (_) {
        /* Retry on a later successful cycle. */
      }
      return;
    }
    final previous = _attempts[db];
    final interval =
        previous?.failed == true || db.cachedTrainerState.controls.isEmpty
        ? const Duration(minutes: 1)
        : const Duration(seconds: 2);
    if (previous?.owner == owner && now.difference(previous!.at) < interval) {
      return;
    }
    _attempts[db] = (owner: owner, at: now, failed: false);
    try {
      await refresh();
    } catch (_) {
      _attempts[db] = (owner: owner, at: now, failed: true);
      // A failed request is never interpreted as a terminated relationship.
    }
  }
}
