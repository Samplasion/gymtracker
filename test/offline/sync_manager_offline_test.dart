import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/provider/events.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:http/http.dart';
import '../sync/support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'automatic and manual offline sync report errors without losing local data',
    () async {
      final db = GTDatabaseImpl.withQueryExecutor(NativeDatabase.memory());
      final backend = Backend();
      final bus = EventBus();
      final manager = GBSyncManager(
        localDatabase: db,
        supabaseClient: backend.client,
        eventBus: bus,
        syncInterval: const Duration(hours: 1),
      );
      final errors = <GBSyncErrorEvent>[];
      final sub = bus.on<GBSyncErrorEvent>().listen(errors.add);
      addTearDown(() async {
        await manager.close();
        await sub.cancel();
        await db.close();
        await backend.client.dispose();
      });
      manager.registerSyncable<DBCustomBarcodeFood>(
        backendTable: 'custom_barcode_foods',
        fromJson: DBCustomBarcodeFood.fromJson,
        companionConstructor: CustomBarcodeFoodsCompanion.new,
      );
      manager.setUserId('A');
      manager.setLastTimeOtherDeviceWasActive(DateTime.utc(2000));
      backend.beforeRequest = (_) async => throw ClientException('Offline');
      manager.enableSync();
      await manager.syncTables();
      await pumpEventQueue();
      expect(errors, hasLength(1));
      expect(errors.single.error, isA<ClientException>());
      expect(manager.successfulSyncs, 0);
      backend.beforeRequest = null;
      backend.put('A', 'recovered', 2);
      await manager.syncTables();
      expect(manager.successfulSyncs, 1);
      expect(await db.select(db.customBarcodeFoods).get(), hasLength(1));
    },
  );
}
