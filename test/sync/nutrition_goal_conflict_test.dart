import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/db/database.dart';

import 'support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const owner = 'A';
  const id = '2024-07-02T00:00:00.000';
  final referenceDate = DateTime.utc(2024, 7, 2);
  final revision = DateTime.utc(2026, 1, 2);
  late GTDatabaseImpl db;
  late Backend backend;
  late TestSyncManager manager;

  Map<String, dynamic> serverGoal(double calories, DateTime timestamp) => {
    'id': id,
    'user_id': owner,
    'reference_date': referenceDate.toIso8601String(),
    'calories': calories,
    'fat': 10.0,
    'carbs': 20.0,
    'protein': 30.0,
    'updated_at': timestamp.toIso8601String(),
    'deleted': false,
  };

  Future<void> localGoal(double calories, DateTime timestamp) => db
      .into(db.nutritionGoals)
      .insertOnConflictUpdate(
        NutritionGoalsCompanion(
          id: const Value(id),
          userId: const Value(owner),
          referenceDate: Value(referenceDate),
          calories: Value(calories),
          fat: const Value(10),
          carbs: const Value(20),
          protein: const Value(30),
          updatedAt: Value(timestamp),
          deleted: const Value(false),
        ),
      )
      .then((_) {});

  void enable() {
    manager.setLastTimeOtherDeviceWasActive(DateTime.utc(2000));
    manager.enableSync();
  }

  setUp(() {
    db = GTDatabaseImpl.withQueryExecutor(NativeDatabase.memory());
    backend = Backend();
    manager = TestSyncManager(db, backend.client);
    manager.registerSyncable<DBNutritionGoal>(
      backendTable: 'nutrition_goals',
      fromJson: DBNutritionGoal.fromJson,
      companionConstructor: NutritionGoalsCompanion.new,
    );
    manager.setUserId(owner);
  });
  tearDown(() async {
    await manager.close();
    await db.close();
    await backend.client.dispose();
  });

  test('full reconciliation uses server values when timestamps tie', () async {
    await localGoal(1800, revision);
    backend.rows['$owner/$id'] = serverGoal(2000, revision);
    enable();
    await manager.syncTables();
    final goal = (await db.select(db.nutritionGoals).get()).singleWhere(
      (row) => row.userId == owner,
    );
    expect(goal.calories, 2000);
    expect(manager.errors, isEmpty);
    expect(manager.isSyncingToBackend, isFalse);
  });

  test('upload readback accepts server winner at equal revision', () async {
    await localGoal(1800, revision);
    backend.beforeRequest = (request) async {
      if (request.method == 'POST') {
        backend.rows['$owner/$id'] = serverGoal(2000, revision);
      }
    };
    enable();
    await manager.syncTables();
    final goal = (await db.select(db.nutritionGoals).get()).singleWhere(
      (row) => row.userId == owner,
    );
    expect(backend.uploads, greaterThan(0));
    expect(goal.calories, 2000);
    expect(manager.errors, isEmpty);
    expect(manager.isSyncingToBackend, isFalse);
  });

  test('later modification wins regardless of side', () async {
    await localGoal(1800, revision);
    backend.rows['$owner/$id'] = serverGoal(
      2000,
      revision.subtract(const Duration(seconds: 1)),
    );
    enable();
    await manager.syncTables();
    expect(backend.rows['$owner/$id']!['calories'], 1800);
    backend.rows['$owner/$id'] = serverGoal(
      2200,
      revision.add(const Duration(seconds: 1)),
    );
    await manager.syncTables();
    final goal = (await db.select(db.nutritionGoals).get()).singleWhere(
      (row) => row.userId == owner,
    );
    expect(goal.calories, 2200);
    expect(manager.errors, isEmpty);
  });
}
