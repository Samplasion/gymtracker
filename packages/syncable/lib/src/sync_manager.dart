import 'dart:async';
import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:logging/logging.dart';
import 'package:supabase/supabase.dart';
import 'package:syncable/src/supabase_names.dart';
import 'package:syncable/src/sync_timestamp_storage.dart';
import 'package:syncable/src/syncable.dart';
import 'package:syncable/src/syncable_database.dart';
import 'package:syncable/src/syncable_table.dart';

/// Locally maintained syncable 1.0.3. See FORK.md for lifecycle guarantees.
class SyncManager<T extends SyncableDatabase> {
  SyncManager({
    required T localDatabase,
    required SupabaseClient supabaseClient,
    Duration syncInterval = const Duration(seconds: 1),
    int maxRows = 1000,
    SyncTimestampStorage? syncTimestampStorage,
    Duration otherDevicesConsideredInactiveAfter = const Duration(minutes: 2),
  })  : _localDb = localDatabase,
        _supabaseClient = supabaseClient,
        _syncInterval = syncInterval,
        _maxRows = maxRows,
        _syncTimestampStorage = syncTimestampStorage,
        _devicesConsideredInactiveAfter = otherDevicesConsideredInactiveAfter,
        assert(
          syncInterval.inMilliseconds > 0,
          'Sync interval must be positive',
        );

  final _logger = Logger('syncable');

  final T _localDb;
  final SupabaseClient _supabaseClient;
  final SyncTimestampStorage? _syncTimestampStorage;
  final Duration _syncInterval;
  final int _maxRows;
  final Duration _devicesConsideredInactiveAfter;

  bool _enabled = false;
  bool _disposed = false;
  bool _exclusive = false;
  int _generation = 0;
  String _userId = '';
  Timer? _timer;
  Future<void>? _activeWork;
  Future<void> _subscriptionCleanup = Future.value();
  bool _reconcileRequested = false;
  bool _pulling = false;
  bool _pushing = false;
  DateTime? _lastTimeOtherDeviceWasActive;
  final _syncables = <Type>[];
  final Map<Type, TableInfo<SyncableTable, Syncable>> _localTables = {};
  final Map<Type, String> _backendTables = {};
  final Map<Type, Syncable Function(Map<String, dynamic>)> _fromJsons = {};
  final Map<Type, CompanionConstructor> _companions = {};
  final Map<Type, Set<Syncable>> _inQueues = {};
  final Map<Type, Map<String, Syncable>> _outQueues = {};
  final Map<Type, Map<String, Syncable>> _knownItems = {};
  final Map<Type, StreamSubscription<List<Syncable>>> _localSubscriptions = {};
  RealtimeChannel? _backendSubscription;
  final Map<Type, int> _nSyncedToBackend = {};
  final Map<Type, int> _nSyncedFromBackend = {};
  int _nFullSyncs = 0;
  int _consecutiveFailures = 0;
  DateTime? _retryNotBefore;

  bool get syncingEnabled => _enabled;
  String get userId => _userId;
  List<Type> get syncables => List.unmodifiable(_syncables);
  bool get isSubscribedToBackend => _backendSubscription != null;
  bool get isSyncing => _activeWork != null;
  bool get isSyncingFromBackend =>
      _pulling || _inQueues.values.any((q) => q.isNotEmpty);
  bool get isSyncingToBackend =>
      _pushing || _outQueues.values.any((q) => q.isNotEmpty);
  int get nFullSyncs => _nFullSyncs;
  int nSyncedToBackend(Type type) => _nSyncedToBackend[type] ?? 0;
  int nSyncedFromBackend(Type type) => _nSyncedFromBackend[type] ?? 0;
  DateTime? get lastTimeOtherDeviceWasActive => _lastTimeOtherDeviceWasActive;
  bool get _canRun =>
      _enabled && !_disposed && !_exclusive && userId.isNotEmpty;
  bool _current(int generation, String owner) =>
      _canRun && _generation == generation && userId == owner;

  /// Hooks include automatic, manual and queue-only work. Errors in background
  /// work are observed here; manual callers also receive the failed Future.
  void onSyncStarted() {}
  void onSyncFinished({required bool success}) {}
  void onSyncError(Object error, StackTrace stack) {
    _logger.severe('Sync failed', error, stack);
  }

  void enableSync() {
    if (_disposed) throw StateError('Sync manager is disposed');
    if (_exclusive) throw StateError('Sync manager is paused for maintenance');
    if (_enabled) return;
    if (_syncables.isEmpty) throw StateError('No registered syncables');
    _enabled = true;
    _subscribe();
    _timer ??= Timer.periodic(_syncInterval, (_) => _backgroundSync());
    _backgroundSync(reconcile: true);
  }

  /// Stops scheduling immediately. Use suspend() before closing/replacing data.
  void disableSync() {
    _enabled = false;
    _generation++;
    _timer?.cancel();
    _timer = null;
    _cancelSubscriptions();
  }

  /// Returns only when requests, writes and subscription cleanup have finished.
  /// Timeout leaves syncing disabled and does not cancel an HTTP request.
  Future<void> suspend({Duration timeout = const Duration(seconds: 30)}) async {
    disableSync();
    await Future.wait([
      if (_activeWork case final work?) work.catchError((Object _) {}),
      _subscriptionCleanup,
    ]).timeout(timeout);
  }

  /// Exclusive barrier used by restore and account transitions. Queues are
  /// discarded only after a successful replacement. Failure preserves retries.
  Future<R> runPaused<R>(
    Future<R> Function() action, {
    bool discardPendingOnSuccess = false,
    bool resume = true,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    if (_exclusive)
      throw StateError('A sync transition is already in progress');
    final wasEnabled = _enabled;
    _exclusive = true;
    var drained = false;
    try {
      await suspend(timeout: timeout);
      drained = true;
      final result = await action();
      if (discardPendingOnSuccess) _clearQueues();
      return result;
    } finally {
      _exclusive = false;
      if (drained && resume && wasEnabled && !_disposed) enableSync();
    }
  }

  void setUserId(String value) {
    if (value == _userId) return;
    if (_activeWork != null) {
      throw StateError('Await suspend() before changing the sync account');
    }
    final wasEnabled = _enabled;
    disableSync();
    _userId = value;
    _lastTimeOtherDeviceWasActive = null;
    _clearQueues();
    if (wasEnabled && !_exclusive) enableSync();
  }

  void setLastTimeOtherDeviceWasActive(DateTime? value) {
    _lastTimeOtherDeviceWasActive = value;
    if (_canRun) {
      _generation++;
      _cancelSubscriptions();
      _subscribe();
      _backgroundSync(reconcile: true);
    }
  }

  void dispose() {
    _disposed = true;
    disableSync();
  }

  Future<void> close() async {
    dispose();
    await suspend();
  }

  void _clearQueues() {
    for (final type in _syncables) {
      _inQueues[type]!.clear();
      _outQueues[type]!.clear();
      _knownItems[type]!.clear();
    }
    _reconcileRequested = false;
    _consecutiveFailures = 0;
    _retryNotBefore = null;
  }

  /// Registers a syncable table with the sync manager.
  ///
  /// This method must be called before enabling syncing. It registers the
  /// table with the sync manager and sets up the necessary mappings for
  /// syncing data between the local database and the backend.
  ///
  /// The [backendTable] parameter specifies the name of the table on the
  /// backend. The [fromJson] parameter is used to convert the JSON data
  /// received from the backend into a [Syncable] object. The
  /// [companionConstructor] parameter is then used create a companion object
  /// from the [Syncable] object to write it to the local database.
  ///
  /// The generic type parameter must be provided and must be a  concrete
  /// subclass of [Syncable].
  void registerSyncable<S extends Syncable>({
    required String backendTable,
    required Syncable Function(Map<String, dynamic>) fromJson,
    required CompanionConstructor companionConstructor,
  }) {
    if (S == Syncable) {
      throw Exception(
        'Please provide the concrete type of your syncable class as a generic '
        'parameter. For example: `registerSyncable<MySyncable>(...)`',
      );
    }

    if (_timer != null || _activeWork != null) {
      throw Exception(
        'Cannot register syncables after the sync manager was started',
      );
    }

    if (_syncables.contains(S)) return;

    _syncables.add(S);
    _localTables[S] = _localDb.getTable<S>();
    _backendTables[S] = backendTable;
    _fromJsons[S] = fromJson;
    _companions[S] = companionConstructor;
    _inQueues[S] = {};
    _outQueues[S] = {};
    _knownItems[S] = {};
  }

  Future<void> fillMissingUserIdForLocalTables() async {
    if (_userId.isEmpty) return;
    final owner = _userId;
    final now = DateTime.now().toUtc();
    await _localDb.transaction(() async {
      for (final type in _syncables) {
        await (_localDb.update(_localTables[type]!)
              ..where((row) => row.userId.isNull()))
            .write(_companions[type]!(
                userId: Value(owner), updatedAt: Value(now)));
      }
      if (_userId != owner) throw StateError('Account changed during adoption');
    });
  }

  void _cancelSubscriptions() {
    final futures = <Future<void>>[
      _subscriptionCleanup,
      for (final sub in _localSubscriptions.values) sub.cancel(),
    ];
    _localSubscriptions.clear();
    final channel = _backendSubscription;
    _backendSubscription = null;
    if (channel != null) futures.add(channel.unsubscribe().then((_) {}));
    _subscriptionCleanup = Future.wait(futures).then((_) {});
    // Observe cleanup errors immediately, including callers of disableSync().
    unawaited(_subscriptionCleanup.catchError((Object e, StackTrace s) {
      onSyncError(e, s);
    }));
  }

  void _subscribe() {
    if (!_canRun) return;
    final owner = userId;
    final generation = _generation;
    for (final type in _syncables) {
      _localSubscriptions[type] = _localDb.subscribe(
        table: _localTables[type]!,
        filter: (row) => row.userId.equals(owner),
        onChange: (rows) {
          if (!_current(generation, owner)) return;
          for (final row in rows) {
            if (row.userId != owner) continue;
            final known = _knownItems[type]![row.id];
            if (known != null && _same(known, row)) continue;
            final queued = _outQueues[type]![row.id];
            if (queued == null || !row.updatedAt.isBefore(queued.updatedAt)) {
              _outQueues[type]![row.id] = row;
            }
          }
        },
      );
    }
    final lastActive = _lastTimeOtherDeviceWasActive;
    if (lastActive != null &&
        DateTime.now().difference(lastActive) > _devicesConsideredInactiveAfter)
      return;
    final channel = _supabaseClient.channel('backend_changes_$generation');
    _backendSubscription = channel;
    for (final type in _syncables) {
      channel.onPostgresChanges(
        schema: publicSchema,
        table: _backendTables[type],
        event: PostgresChangeEvent.all,
        filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq, column: userIdKey, value: owner),
        callback: (payload) {
          if (!_current(generation, owner) || payload.newRecord.isEmpty) return;
          try {
            final row = _fromJsons[type]!(payload.newRecord);
            if (row.userId == owner) _inQueues[type]!.add(row);
          } catch (e, s) {
            onSyncError(e, s);
          }
        },
      );
    }
    channel.subscribe((status, error) {
      if (_current(generation, owner) && error != null)
        onSyncError(error, StackTrace.current);
    });
  }

  void _backgroundSync({bool reconcile = false}) {
    if (!_canRun) return;
    final retryNotBefore = _retryNotBefore;
    if (retryNotBefore != null && DateTime.now().isBefore(retryNotBefore))
      return;
    unawaited(_requestSync(reconcile: reconcile).catchError((Object _) {}));
  }

  Future<void> syncTables() => _requestSync(reconcile: true);

  Future<void> _requestSync({required bool reconcile}) {
    if (!_canRun) return Future.value();
    _reconcileRequested |= reconcile;
    if (_activeWork case final work?) return work;
    if (!_reconcileRequested && !isSyncingFromBackend && !isSyncingToBackend)
      return Future.value();
    final generation = _generation;
    final owner = userId;
    final completion = Completer<void>();
    _activeWork = completion.future;
    () async {
      var success = false;
      Object? failure;
      StackTrace? failureStack;
      onSyncStarted();
      try {
        await _subscriptionCleanup;
        do {
          final full = _reconcileRequested;
          _reconcileRequested = false;
          for (final type in _syncables) {
            if (!_current(generation, owner)) break;
            if (full) await _reconcile(type, generation, owner);
            if (!_current(generation, owner)) break;
            await _processIncoming(type, generation, owner);
            if (!_current(generation, owner)) break;
            await _processOutgoing(type, generation, owner);
          }
          if (full && _current(generation, owner)) _nFullSyncs++;
        } while (_current(generation, owner) &&
            (_reconcileRequested ||
                isSyncingFromBackend ||
                isSyncingToBackend));
        success = _current(generation, owner);
        if (success) {
          _consecutiveFailures = 0;
          _retryNotBefore = null;
        }
      } catch (e, s) {
        failure = e;
        failureStack = s;
        onSyncError(e, s);
        if (_current(generation, owner)) {
          _reconcileRequested = true;
          _consecutiveFailures++;
          final exponent =
              _consecutiveFailures > 7 ? 6 : _consecutiveFailures - 1;
          final seconds = 1 << exponent;
          _retryNotBefore = DateTime.now().add(Duration(seconds: seconds));
        }
      } finally {
        _pulling = false;
        _pushing = false;
        _activeWork = null;
        onSyncFinished(success: success);
        if (failure != null) {
          completion.completeError(failure, failureStack);
        } else {
          completion.complete();
        }
        // A new generation may have been enabled while the old one drained.
        if (_canRun && _generation != generation)
          _backgroundSync(reconcile: true);
      }
    }();
    return completion.future;
  }

  bool _same(Syncable a, Syncable b) =>
      const DeepCollectionEquality().equals(a.toJson(), b.toJson());

  Future<void> _reconcile(Type type, int generation, String owner) async {
    _pulling = true;
    try {
      final table = _localTables[type]!;
      final local = await (_localDb.select(table)
            ..where((row) => row.userId.equals(owner)))
          .get();
      if (!_current(generation, owner)) return;
      final remote = <String, DateTime>{};
      var offset = 0;
      while (_current(generation, owner)) {
        final batch = await _supabaseClient
            .from(_backendTables[type]!)
            .select('$idKey,$updatedAtKey')
            .eq(userIdKey, owner)
            .order(idKey)
            .range(offset, offset + _maxRows - 1);
        if (!_current(generation, owner)) return;
        for (final row in batch) {
          remote[row[idKey] as String] =
              DateTime.parse(row[updatedAtKey] as String);
        }
        if (batch.length < _maxRows) break;
        offset += batch.length;
      }
      final localById = <String, Syncable>{};
      for (final row in local) {
        final previous = localById[row.id];
        if (previous == null || row.updatedAt.isAfter(previous.updatedAt)) {
          localById[row.id] = row;
        }
      }
      for (final row in localById.values) {
        final date = remote[row.id];
        if (date == null || row.updatedAt.isAfter(date)) {
          final queued = _outQueues[type]![row.id];
          if (queued == null || !row.updatedAt.isBefore(queued.updatedAt))
            _outQueues[type]![row.id] = row;
        }
      }
      final toPull = remote.entries
          .where((entry) =>
              localById[entry.key] == null ||
              !entry.value.isBefore(localById[entry.key]!.updatedAt))
          .map((e) => e.key)
          .toList();
      for (final ids in toPull.slices(100)) {
        final data = await _supabaseClient
            .from(_backendTables[type]!)
            .select()
            .eq(userIdKey, owner)
            .inFilter(idKey, ids);
        if (!_current(generation, owner)) return;
        final rows = data.map(_fromJsons[type]!).toList();
        if (rows.any((row) => row.userId != owner))
          throw StateError('Unexpected sync owner');
        _inQueues[type]!.addAll(rows);
      }
      await _processIncoming(type, generation, owner);
      if (_current(generation, owner)) {
        await _setTimestamp(type, TimestampType.lastSyncFromBackend, owner,
            DateTime.now().toUtc());
      }
    } finally {
      _pulling = false;
    }
  }

  Future<void> _processOutgoing(Type type, int generation, String owner) async {
    final queue = _outQueues[type]!;
    final outgoing = queue.values.where((row) => row.userId == owner).toList();
    for (final batch in outgoing.slices(100)) {
      if (!_current(generation, owner)) return;
      _pushing = true;
      try {
        await _supabaseClient.from(_backendTables[type]!).upsert(
            batch.map((row) => row.toJson()).toList(),
            onConflict: '$idKey,$userIdKey');
        // Read back: an UPDATE trigger can silently discard a successful HTTP write.
        if (!_current(generation, owner)) return;
        final data = await _supabaseClient
            .from(_backendTables[type]!)
            .select()
            .eq(userIdKey, owner)
            .inFilter(idKey, batch.map((row) => row.id).toList());
        if (!_current(generation, owner)) return;
        final confirmed = {
          for (final json in data)
            json[idKey] as String: _fromJsons[type]!(json)
        };
        for (final row in batch) {
          final server = confirmed[row.id];
          if (server == null ||
              server.userId != owner ||
              server.updatedAt.isBefore(row.updatedAt)) {
            throw StateError(
                'Upload was not confirmed for ${_backendTables[type]}/${row.id}');
          }
          if (identical(queue[row.id], row)) queue.remove(row.id);
          _knownItems[type]![row.id] = server;
          // Equal timestamps are possible with SQLite's second precision.
          // The server is the deterministic winner when contents differ.
          if (server.updatedAt.isAfter(row.updatedAt) || !_same(server, row))
            _inQueues[type]!.add(server);
        }
        _nSyncedToBackend[type] = nSyncedToBackend(type) + batch.length;
        await _setTimestamp(type, TimestampType.lastSyncToBackend, owner,
            batch.map((row) => row.updatedAt).max);
        await _processIncoming(type, generation, owner);
      } finally {
        _pushing = false;
      }
    }
  }

  Future<void> _processIncoming(Type type, int generation, String owner) async {
    if (!_current(generation, owner)) return;
    final queue = _inQueues[type]!;
    if (queue.isEmpty) return;
    final snapshot = Set<Syncable>.of(queue);
    final latest = <String, Syncable>{};
    for (final row in snapshot) {
      if (row.userId != owner) throw StateError('Unexpected sync owner');
      final old = latest[row.id];
      // When two server events share a timestamp, the latest observed value wins.
      if (old == null || !row.updatedAt.isBefore(old.updatedAt))
        latest[row.id] = row;
    }
    final table = _localTables[type]!;
    await _localDb.transaction(() async {
      for (final row in latest.values) {
        if (!_current(generation, owner)) throw const _SyncInterrupted();
        final existingRows = await (_localDb.select(table)
              ..where((r) => r.userId.equals(owner) & r.id.equals(row.id)))
            .get();
        if (!_current(generation, owner)) throw const _SyncInterrupted();
        if (existingRows.isEmpty) {
          await _localDb.into(table).insert(row.toCompanion());
        } else {
          final newest = existingRows.map((existing) => existing.updatedAt).max;
          if (row.updatedAt.isAfter(newest) ||
              (row.updatedAt.isAtSameMomentAs(newest) &&
                  existingRows.any((existing) => !_same(row, existing)))) {
            await (_localDb.update(table)
                  ..where((r) => r.userId.equals(owner) & r.id.equals(row.id)))
                .write(row.toCompanion());
          }
        }
      }
      if (!_current(generation, owner)) throw const _SyncInterrupted();
    });
    for (final row in latest.values) {
      _knownItems[type]![row.id] = row;
      final outgoing = _outQueues[type]![row.id];
      if (outgoing != null && !outgoing.updatedAt.isAfter(row.updatedAt))
        _outQueues[type]!.remove(row.id);
    }
    queue.removeAll(snapshot);
    _nSyncedFromBackend[type] = nSyncedFromBackend(type) + latest.length;
  }

  Future<void> _setTimestamp(
      Type type, TimestampType direction, String owner, DateTime value) async {
    await _syncTimestampStorage?.setSyncTimestamp(
        'syncable_${owner}_${direction.name}_${_localTables[type]!.actualTableName}',
        value);
  }
}

class _SyncInterrupted implements Exception {
  const _SyncInterrupted();
}

typedef CompanionConstructor = UpdateCompanion<Syncable> Function({
  Value<String> id,
  Value<String?> userId,
  Value<DateTime> updatedAt,
  Value<bool> deleted,
});

enum TimestampType { lastSyncToBackend, lastSyncFromBackend }
