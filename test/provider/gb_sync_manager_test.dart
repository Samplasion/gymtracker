import 'dart:async';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/provider/events.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../sync/support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late GTDatabaseImpl db;
  late Backend backend;
  late GBSyncManager manager;
  late EventBus bus;
  late List<GBEvent> events;
  late List<StreamSubscription> subscriptions;
  setUp(() {
    db = GTDatabaseImpl.withQueryExecutor(NativeDatabase.memory());
    backend = Backend();
    bus = EventBus();
    events = [];
    subscriptions = [
      bus.on<GBSyncStartedEvent>().listen(events.add),
      bus.on<GBSyncFinishedEvent>().listen(events.add),
      bus.on<GBSyncErrorEvent>().listen(events.add),
    ];
    manager = GBSyncManager(
      localDatabase: db,
      supabaseClient: backend.client,
      eventBus: bus,
      syncInterval: const Duration(hours: 1),
    );
    manager.registerSyncable<DBCustomBarcodeFood>(
      backendTable: 'custom_barcode_foods',
      fromJson: DBCustomBarcodeFood.fromJson,
      companionConstructor: CustomBarcodeFoodsCompanion.new,
    );
    manager.setUserId('A');
    manager.setLastTimeOtherDeviceWasActive(DateTime.utc(2000));
  });
  tearDown(() async {
    await manager.close();
    for (final sub in subscriptions) {
      await sub.cancel();
    }
    await db.close();
    await backend.client.dispose();
  });

  test('disabled sync does not report a successful lifecycle', () async {
    await manager.syncTables();
    await pumpEventQueue();
    expect(events, isEmpty);
    expect(manager.successfulSyncs, 0);
  });

  test('automatic and manual requests share a verified completion', () async {
    backend.put('A', 'row', 2);
    manager.enableSync();
    await Future.wait([manager.syncTables(), manager.syncTables()]);
    expect(manager.successfulSyncs, 1);
    await pumpEventQueue();
    expect(events.whereType<GBSyncStartedEvent>(), hasLength(1));
    final finish = events.whereType<GBSyncFinishedEvent>().single;
    expect(finish.lastSync, isNotNull);
    expect(finish.userId, 'A');
    expect(manager.successfulSyncs, 1);
    expect(manager.isSyncingAny, isFalse);
    expect(await db.select(db.customBarcodeFoods).get(), hasLength(1));
  });

  test('upload failure emits error and never records success', () async {
    backend.beforeRequest = (_) async =>
        throw const PostgrestException(message: 'failure');
    manager.enableSync();
    await expectLater(manager.syncTables(), throwsA(isA<PostgrestException>()));
    await pumpEventQueue();
    expect(events.whereType<GBSyncErrorEvent>(), hasLength(1));
    expect(events.whereType<GBSyncFinishedEvent>().single.lastSync, isNull);
    expect(manager.successfulSyncs, 0);
  });

  test('drain timeout includes in-flight HTTP work', () async {
    final started = Completer<void>();
    final release = Completer<void>();
    backend.beforeRequest = (_) async {
      if (!started.isCompleted) started.complete();
      await release.future;
    };
    manager.enableSync();
    final sync = manager.syncTables();
    await started.future;
    await expectLater(
      manager.waitForAllTables(timeout: Duration.zero),
      throwsA(isA<TimeoutException>()),
    );
    expect(manager.successfulSyncs, 0);
    final suspension = manager.suspend();
    release.complete();
    await sync;
    await suspension;
    await pumpEventQueue();
    expect(events.whereType<GBSyncFinishedEvent>().single.lastSync, isNull);
  });
}
