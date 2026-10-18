import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/db/database.dart';

import 'support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const owner = 'A';
  const id = 'food';
  final revision = DateTime.utc(2026, 1, 2);
  late GTDatabaseImpl db;
  late Backend backend;
  late TestSyncManager manager;

  Future<void> insertFavorites() async {
    await db
        .into(db.foods)
        .insert(
          FoodsCompanion.insert(
            id: const Value(id),
            dateAdded: revision,
            referenceDate: revision,
            jsonData: '{}',
            userId: const Value(owner),
            updatedAt: Value(revision),
          ),
        );
    for (var i = 0; i < 2; i++) {
      await db
          .into(db.favoriteFoods)
          .insert(
            FavoriteFoodsCompanion.insert(
              id: id,
              userId: const Value(owner),
              updatedAt: Value(revision),
            ),
          );
    }
  }

  void enable() {
    manager.setLastTimeOtherDeviceWasActive(DateTime.utc(2000));
    manager.enableSync();
  }

  setUp(() {
    db = GTDatabaseImpl.withQueryExecutor(NativeDatabase.memory());
    backend = Backend();
    manager = TestSyncManager(db, backend.client);
    manager.registerSyncable<DBFavoriteFood>(
      backendTable: 'favorite_foods',
      fromJson: DBFavoriteFood.fromJson,
      companionConstructor: FavoriteFoodsCompanion.new,
    );
    manager.setUserId(owner);
  });
  tearDown(() async {
    await manager.close();
    await db.close();
    await backend.client.dispose();
  });

  test('duplicate local favorites do not fail an incoming update', () async {
    await insertFavorites();
    expect(await db.select(db.favoriteFoods).get(), hasLength(2));
    backend.rows['$owner/$id'] = {
      'id': id,
      'user_id': owner,
      'updated_at': revision.add(const Duration(seconds: 1)).toIso8601String(),
      'deleted': true,
    };
    enable();
    await manager.syncTables();
    final favorites = await db.select(db.favoriteFoods).get();
    expect(favorites, hasLength(2));
    expect(favorites.every((favorite) => favorite.deleted), isTrue);
    expect(manager.errors, isEmpty);
  });

  test(
    'duplicate local favorites reconcile once using latest revision',
    () async {
      await insertFavorites();
      await (db.update(
        db.favoriteFoods,
      )..where((row) => row.userId.equals(owner))).write(
        FavoriteFoodsCompanion(
          updatedAt: Value(revision.add(const Duration(seconds: 1))),
        ),
      );
      enable();
      await manager.syncTables();
      expect(
        backend.rows['$owner/$id']!['updated_at'],
        revision.add(const Duration(seconds: 1)).toIso8601String(),
      );
      expect(manager.errors, isEmpty);
    },
  );

  test('background failures back off instead of retrying every tick', () async {
    await manager.close();
    manager = TestSyncManager(
      db,
      backend.client,
      syncInterval: const Duration(milliseconds: 10),
    );
    manager.registerSyncable<DBFavoriteFood>(
      backendTable: 'favorite_foods',
      fromJson: DBFavoriteFood.fromJson,
      companionConstructor: FavoriteFoodsCompanion.new,
    );
    manager.setUserId(owner);
    var attempts = 0;
    backend.beforeRequest = (_) async {
      attempts++;
      throw StateError('temporary sync failure');
    };
    enable();
    await Future<void>.delayed(const Duration(milliseconds: 200));
    expect(attempts, 1);
    expect(manager.errors, hasLength(1));
    await expectLater(manager.syncTables(), throwsStateError);
    expect(attempts, 2);
  });

  test('a failed full reconciliation retries after the delay', () async {
    await manager.close();
    manager = TestSyncManager(
      db,
      backend.client,
      syncInterval: const Duration(milliseconds: 10),
    );
    manager.registerSyncable<DBFavoriteFood>(
      backendTable: 'favorite_foods',
      fromJson: DBFavoriteFood.fromJson,
      companionConstructor: FavoriteFoodsCompanion.new,
    );
    manager.setUserId(owner);
    var attempts = 0;
    backend.beforeRequest = (_) async {
      attempts++;
      if (attempts == 1) throw StateError('temporary sync failure');
    };
    enable();
    await Future<void>.delayed(const Duration(milliseconds: 1300));
    expect(attempts, 2);
    expect(manager.nFullSyncs, 1);
    expect(manager.errors, hasLength(1));
  });
}
