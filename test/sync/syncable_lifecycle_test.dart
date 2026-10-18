import 'dart:async';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/db/database.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'support.dart';

void main() {
  late GTDatabaseImpl db;
  late Backend backend;
  late TestSyncManager manager;

  Future<void> local(
    String owner,
    String id,
    int revision, {
    String value = '{}',
  }) async {
    await db
        .into(db.customBarcodeFoods)
        .insertOnConflictUpdate(
          CustomBarcodeFoodsCompanion(
            id: Value(id),
            userId: Value(owner),
            jsonData: Value(value),
            updatedAt: Value(DateTime.utc(2026, 1, revision)),
            deleted: const Value(false),
          ),
        );
  }

  void enable() {
    manager.setLastTimeOtherDeviceWasActive(DateTime.utc(2000));
    manager.enableSync();
  }

  setUp(() {
    db = GTDatabaseImpl.withQueryExecutor(NativeDatabase.memory());
    backend = Backend();
    manager = TestSyncManager(db, backend.client);
    manager.registerSyncable<DBCustomBarcodeFood>(
      backendTable: 'custom_barcode_foods',
      fromJson: DBCustomBarcodeFood.fromJson,
      companionConstructor: CustomBarcodeFoodsCompanion.new,
    );
    manager.setUserId('A');
  });
  tearDown(() async {
    await manager.close();
    await db.close();
    await backend.client.dispose();
  });

  test(
    'same IDs belonging to another account never suppress downloads',
    () async {
      await local('B', 'shared', 30);
      backend.put('A', 'shared', 2);
      enable();
      await manager.syncTables();
      final rows = await db.select(db.customBarcodeFoods).get();
      expect(rows.map((r) => r.userId), containsAll(['A', 'B']));
      expect(
        rows.singleWhere((r) => r.userId == 'B').updatedAt.toUtc(),
        DateTime.utc(2026, 1, 30),
      );
    },
  );

  test('pagination and concurrent sync requests use a single worker', () async {
    for (var i = 0; i < 5; i++) {
      backend.put('A', '$i', 2);
    }
    enable();
    manager.enableSync();
    await Future.wait([manager.syncTables(), manager.syncTables()]);
    expect(await db.select(db.customBarcodeFoods).get(), hasLength(5));
    expect(backend.maxRequestsInFlight, 1);
    expect(manager.isSyncing, isFalse);
  });

  test(
    'pause waits for an upload and prevents the action until it settles',
    () async {
      await local('A', 'pending', 2);
      final started = Completer<void>();
      final release = Completer<void>();
      backend.beforeRequest = (request) async {
        if (request.method == 'POST') {
          started.complete();
          await release.future;
        }
      };
      enable();
      final sync = manager.syncTables();
      await started.future;
      expect(manager.isSyncingToBackend, isTrue);
      var ran = false;
      final paused = manager.runPaused(() async {
        ran = true;
      }, resume: false);
      await pumpEventQueue();
      expect(ran, isFalse);
      expect(manager.isSyncing, isTrue);
      release.complete();
      await sync;
      await paused;
      expect(ran, isTrue);
      expect(manager.syncingEnabled, isFalse);
      expect(backend.rows, contains('A/pending'));
      expect(manager.finishes.last, isFalse);
    },
  );

  test(
    'pause timeout leaves data untouched and late download cannot write',
    () async {
      backend.put('A', 'remote', 2);
      final started = Completer<void>();
      final release = Completer<void>();
      backend.beforeRequest = (_) async {
        if (!started.isCompleted) started.complete();
        await release.future;
      };
      enable();
      final sync = manager.syncTables();
      await started.future;
      var ran = false;
      await expectLater(
        manager.runPaused(() async {
          ran = true;
        }, timeout: const Duration(milliseconds: 10)),
        throwsA(isA<TimeoutException>()),
      );
      expect(ran, isFalse);
      expect(manager.syncingEnabled, isFalse);
      expect(() => manager.setUserId('B'), throwsStateError);
      release.complete();
      await sync;
      expect(await db.select(db.customBarcodeFoods).get(), isEmpty);
      await manager.suspend();
      manager.setUserId('B');
      expect(manager.userId, 'B');
    },
  );

  test(
    'failed upload stays pending and a retry confirms both old and new edits',
    () async {
      await local('A', 'first', 2);
      backend.failUploads = 1;
      enable();
      await expectLater(
        manager.syncTables(),
        throwsA(isA<PostgrestException>()),
      );
      expect(manager.isSyncingToBackend, isTrue);
      await local('A', 'second', 3);
      await manager.syncTables();
      expect(backend.rows.keys, containsAll(['A/first', 'A/second']));
      expect(manager.isSyncingToBackend, isFalse);
    },
  );

  test(
    'a newer local edit during upload is not acknowledged by an older reply',
    () async {
      await local('A', 'same', 2);
      final started = Completer<void>();
      final release = Completer<void>();
      backend.beforeRequest = (request) async {
        if (request.method == 'POST' && !started.isCompleted) {
          started.complete();
          await release.future;
        }
      };
      enable();
      final sync = manager.syncTables();
      await started.future;
      await local('A', 'same', 3, value: '{"new":true}');
      await pumpEventQueue();
      release.complete();
      await sync;
      await manager.syncTables();
      expect(backend.rows['A/same']!['json_data'], '{"new":true}');
    },
  );

  test('failed incoming transaction is retained and retried', () async {
    await db.customStatement(
      'CREATE TRIGGER reject_sync BEFORE INSERT ON custom_barcode_foods BEGIN SELECT RAISE(ABORT, "test failure"); END',
    );
    backend.put('A', 'remote', 2);
    enable();
    await expectLater(manager.syncTables(), throwsA(isA<Exception>()));
    expect(manager.isSyncingFromBackend, isTrue);
    await db.customStatement('DROP TRIGGER reject_sync');
    await manager.syncTables();
    expect(await db.select(db.customBarcodeFoods).get(), hasLength(1));
    expect(manager.isSyncingFromBackend, isFalse);
  });

  test(
    'failed maintenance preserves pending work and refuses reentrant enable',
    () async {
      await local('A', 'pending', 2);
      backend.failUploads = 1;
      enable();
      await expectLater(
        manager.syncTables(),
        throwsA(isA<PostgrestException>()),
      );
      await expectLater(
        manager.runPaused(
          () async {
            expect(() => manager.enableSync(), throwsStateError);
            throw StateError('restore failed');
          },
          discardPendingOnSuccess: true,
          resume: false,
        ),
        throwsStateError,
      );
      expect(manager.isSyncingToBackend, isTrue);
      enable();
      await manager.syncTables();
      expect(backend.rows, contains('A/pending'));
    },
  );
}
