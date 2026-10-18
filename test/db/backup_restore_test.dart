import 'dart:async';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/db/backup_restore.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/repository/foods.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/struct/date_sequence.dart';
import 'package:gymtracker/struct/nutrition.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import '../sync/support.dart';

class _Paths extends PathProviderPlatform {
  _Paths(this.path);
  final String path;
  @override
  Future<String?> getApplicationDocumentsPath() async => path;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory temp;
  late GTDatabaseImpl db;
  late GTDatabaseImpl source;
  late DatabaseService service;
  late PathProviderPlatform originalPaths;
  final day = DateTime(2026, 10, 18);
  final food = Food(
    id: 'food',
    name: 'Backup meal',
    amount: 100,
    nutritionalValuesPer100g: const NutritionValues(
      calories: 100,
      fat: 2,
      saturatedFat: 0,
      carbs: 10,
      sugar: 0,
      protein: 5,
    ),
  );

  Future<DatabaseBackup> snapshot() async {
    final file = File(
      '${temp.path}/source-${DateTime.now().microsecondsSinceEpoch}.db',
    );
    await source.customStatement('VACUUM INTO ?', [file.path]);
    return DatabaseBackup(DateTime.now(), file);
  }

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('backup-restore-test-');
    originalPaths = PathProviderPlatform.instance;
    PathProviderPlatform.instance = _Paths(temp.path);
    db = GTDatabaseImpl.withQueryExecutor(NativeDatabase.memory());
    source = GTDatabaseImpl.withQueryExecutor(NativeDatabase.memory());
    db.setCurrentUserId('A');
    source.setCurrentUserId('A');
    await source.insertFoods(DateTagged(date: day, value: food));
    await source.insertCustomBarcodeFood('barcode', food);
    await source.insertFavoriteFood('food');
    await source.setOngoing({'name': 'Restored workout'});
    service = DatabaseService.withDatabase(db);
    service.runWithSyncPaused = (action) => action();
    await service.backups.init();
  });
  tearDown(() async {
    await source.close();
    await db.close();
    PathProviderPlatform.instance = originalPaths;
    await temp.delete(recursive: true);
  });

  test(
    'restore drains in-flight uploads and reconciles restored values',
    () async {
      await db.insertCustomBarcodeFood(
        'barcode',
        food.copyWith.name('Old meal'),
      );
      final backend = Backend();
      final manager = TestSyncManager(db, backend.client);
      manager.registerSyncable<DBCustomBarcodeFood>(
        backendTable: 'custom_barcode_foods',
        fromJson: DBCustomBarcodeFood.fromJson,
        companionConstructor: CustomBarcodeFoodsCompanion.new,
      );
      manager.setUserId('A');
      manager.setLastTimeOtherDeviceWasActive(DateTime.utc(2000));
      final started = Completer<void>();
      final release = Completer<void>();
      backend.beforeRequest = (request) async {
        if (request.method == 'POST' && !started.isCompleted) {
          started.complete();
          await release.future;
        }
      };
      service.runWithSyncPaused = (action) =>
          manager.runPaused(action, discardPendingOnSuccess: true);
      try {
        final backup = await snapshot();
        manager.enableSync();
        await started.future;
        final restoring = service.restoreBackup(backup);
        await pumpEventQueue();
        expect(backend.requestsInFlight, 1);
        release.complete();
        await restoring;
        await manager.syncTables();
        expect(
          backend.rows['A/barcode']!['json_data'],
          contains('Backup meal'),
        );
        expect(backend.maxRequestsInFlight, 1);
        expect(manager.errors, isEmpty);
      } finally {
        if (!release.isCompleted) release.complete();
        await manager.close();
        await backend.client.dispose();
      }
    },
  );

  test(
    'restore keeps live repositories, account and other owners; known omissions become tombstones',
    () async {
      await db.insertFoods(
        DateTagged(date: day, value: food.copyWith.name('Local meal')),
      );
      await db.insertFoods(
        DateTagged(date: day, value: food.copyWith.id('omitted')),
      );
      db.setCurrentUserId('B');
      await db.insertFoods(
        DateTagged(date: day, value: food.copyWith.name('B meal')),
      );
      db.setCurrentUserId('A');
      final repository = FoodsRepository(db);
      final observed = <List<DateTagged<Food>>>[];
      final sub = repository.watchFoods().listen(observed.add);
      addTearDown(sub.cancel);
      var paused = false;
      service.runWithSyncPaused = (action) async {
        paused = true;
        await action();
      };
      await service.restoreBackup(await snapshot());
      await pumpEventQueue();
      expect(paused, isTrue);
      expect(identical(service.db, db), isTrue);
      expect(db.currentUserId, 'A');
      expect(observed.last.single.value.name, 'Backup meal');
      final rows = await db.select(db.foods).get();
      expect(rows.singleWhere((r) => r.id == 'omitted').deleted, isTrue);
      expect(
        rows.singleWhere((r) => r.userId == 'B').jsonData,
        contains('B meal'),
      );
      expect((await db.watchOngoing().first)!['name'], 'Restored workout');
      await repository.addFood(
        DateTagged(date: day, value: food.copyWith.id('after')),
      );
      expect(await repository.watchFoods().first, hasLength(2));
      expect(service.backups.list(), hasLength(1));
    },
  );

  test(
    'invalid backup and missing sync barrier preserve the live data',
    () async {
      await db.insertFoods(DateTagged(date: day, value: food));
      final invalid = File('${temp.path}/invalid.db');
      await invalid.writeAsString('not a database');
      var entered = false;
      service.runWithSyncPaused = (action) async {
        entered = true;
        await action();
      };
      await expectLater(
        service.restoreBackup(DatabaseBackup(DateTime.now(), invalid)),
        throwsA(anything),
      );
      expect(entered, isFalse);
      expect(await db.watchFoods().first, hasLength(1));
      service.runWithSyncPaused = null;
      await expectLater(
        service.restoreBackup(await snapshot()),
        throwsStateError,
      );
      expect(await db.watchFoods().first, hasLength(1));
    },
  );

  test(
    'failure midway rolls back all tables and retains a safety backup',
    () async {
      await db.insertFoods(
        DateTagged(date: day, value: food.copyWith.name('Keep me')),
      );
      await db.customStatement(
        'CREATE TRIGGER fail_restore BEFORE INSERT ON custom_barcode_foods BEGIN SELECT RAISE(ABORT, "failed restore"); END',
      );
      final before = (await db.select(db.foods).get())
          .map((row) => row.toJson())
          .toList();
      var resumed = false;
      service.afterUserChange = () async {
        resumed = true;
      };
      await expectLater(
        service.restoreBackup(await snapshot()),
        throwsA(anything),
      );
      expect(
        (await db.select(db.foods).get()).map((row) => row.toJson()).toList(),
        before,
      );
      expect(resumed, isTrue);
      expect(service.backups.list(), hasLength(1));
    },
  );

  test('a backup for another owner cannot erase the current account', () async {
    db.setCurrentUserId('B');
    await db.insertFoods(
      DateTagged(date: day, value: food.copyWith.name('B meal')),
    );
    await expectLater(
      service.restoreBackup(await snapshot()),
      throwsStateError,
    );
    expect((await db.watchFoods().first).single.value.name, 'B meal');
  });

  test('pause timeout never starts writes or a safety backup', () async {
    await db.insertFoods(
      DateTagged(date: day, value: food.copyWith.name('Keep me')),
    );
    service.runWithSyncPaused = (_) =>
        Future.error(TimeoutException('Still uploading'));
    await expectLater(
      service.restoreBackup(await snapshot()),
      throwsA(isA<TimeoutException>()),
    );
    expect((await db.watchFoods().first).single.value.name, 'Keep me');
    expect(service.backups.list(), isEmpty);
  });

  test(
    'copy validation rejects future schemas without changing the source',
    () async {
      final backup = await snapshot();
      final futureDb = GTDatabaseImpl.withQueryExecutor(
        NativeDatabase(backup.file),
      );
      await futureDb.customStatement('PRAGMA user_version = 999');
      await futureDb.close();
      final before = await backup.file.readAsBytes();
      await expectLater(
        PreparedDatabaseRestore.load(backup.file, 'A'),
        throwsA(anything),
      );
      expect(await backup.file.readAsBytes(), before);
    },
  );

  test('safety snapshots include committed WAL pages', () async {
    final file = File('${temp.path}/live.db');
    final live = GTDatabaseImpl.withQueryExecutor(NativeDatabase(file));
    try {
      await live.customStatement('PRAGMA journal_mode = WAL');
      await live.customStatement('PRAGMA wal_autocheckpoint = 0');
      live.setCurrentUserId('A');
      await live.insertFoods(DateTagged(date: day, value: food));
      final liveService = DatabaseService.withDatabase(live);
      await liveService.backups.init();
      await liveService.createBackup();
      final saved = liveService.backups.list().first;
      final prepared = await PreparedDatabaseRestore.load(saved.file, 'A');
      expect(prepared.rows['foods'], hasLength(1));
      expect(await File('${file.path}-wal').exists(), isTrue);
    } finally {
      await live.close();
    }
  });
}
