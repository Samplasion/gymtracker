import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/db/backup_restore.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/db/exports/v23.dart';
import 'package:gymtracker/repository/hydration.dart';
import 'package:gymtracker/service/hydration_sync.dart';
import 'package:gymtracker/struct/date_sequence.dart';
import 'package:gymtracker/struct/nutrition.dart';

// ignore: depend_on_referenced_packages

class FakeHydrationHealth implements HydrationHealth {
  @override
  bool supported = true;
  bool authorized = true;
  bool fail = false;
  HydrationPermission currentPermission = HydrationPermission.unknown;
  int authorizationRequests = 0;
  @override
  Future<HydrationPermission> permission() async =>
      supported ? currentPermission : HydrationPermission.unavailable;
  final calls = <(String, int, double)>[];
  final deleted = <String>[];
  final records = <String, double>{};
  @override
  Future<bool> authorize() async {
    authorizationRequests++;
    currentPermission = authorized
        ? HydrationPermission.granted
        : HydrationPermission.denied;
    return authorized;
  }

  @override
  Future<void> write(String id, int version, double ml, DateTime time) async {
    calls.add((id, version, ml));
    if (fail) throw StateError('Offline');
    records[id] = ml;
  }

  @override
  Future<void> remove(String id) async {
    if (fail) throw StateError('Offline');
    deleted.add(id);
    records.remove(id);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late GTDatabaseImpl db;
  late HydrationRepository repository;
  late FakeHydrationHealth health;
  late HydrationSync sync;
  final now = DateTime.now().subtract(const Duration(minutes: 5));
  setUp(() {
    db = GTDatabaseImpl.withQueryExecutor(NativeDatabase.memory());
    repository = HydrationRepository(db);
    health = FakeHydrationHealth();
    sync = HydrationSync(db, health: health);
  });
  tearDown(() async {
    sync.dispose();
    await db.close();
  });

  test('optional water scales with mass, volume and multiple portions', () {
    for (final unit in [NutritionUnit.G, NutritionUnit.MILLI_L]) {
      final food = Food(
        name: 'Test',
        unit: unit,
        nutritionalValuesPer100g: NutritionValues.fromJson({
          ...NutritionValues.zero.toJson(),
          'water': 90,
        }),
        amount: 150,
        pieces: 2,
      );
      expect(food.nutritionalValues.water, 270);
      expect(Food.fromJson(food.toJson()).nutritionalValues.water, 270);
    }
    expect(
      NutritionValues.fromJson(
        {...NutritionValues.zero.toJson()}..remove('water'),
      ).water,
      isNull,
    );
    expect((NutritionValues.zero + NutritionValues.zero).water, isNull);
    expect(
      (NutritionValues.fromJson({
                ...NutritionValues.zero.toJson(),
                'water': 0,
              }) +
              NutritionValues.zero)
          .water,
      0,
    );
  });

  test('water CRUD is isolated by account, including duplicate IDs', () async {
    await repository.save(milliliters: 250, time: now);
    final guest = (await repository.watch(null).first).single;
    db.setCurrentUserId('A');
    expect(await repository.watch('A').first, isEmpty);
    await repository.save(milliliters: 500, time: now);
    await repository.save(id: guest.id, milliliters: 1, time: now);
    expect((await repository.watch(null).first).single.milliliters, 250);
    final entry = (await repository.watch('A').first).single;
    await repository.save(id: entry.id, milliliters: 300, time: now);
    expect((await repository.watch('A').first).single.milliliters, 300);
    await repository.remove(guest.id);
    expect((await repository.watch(null).first).single.milliliters, 250);
    await repository.remove(entry.id);
    expect(await repository.watch('A').first, isEmpty);
    expect(
      (await db.select(db.waterLogs).get()).where((r) => r.deleted),
      hasLength(1),
    );
  });

  test('invalid and future amounts are rejected', () async {
    for (final amount in [0.0, -1.0, double.nan, double.infinity]) {
      await expectLater(
        repository.save(milliliters: amount, time: now),
        throwsArgumentError,
      );
    }
    await expectLater(
      repository.save(milliliters: 1, time: now.add(const Duration(days: 2))),
      throwsArgumentError,
    );
  });

  test('water goals persist and legacy goals have no default water', () async {
    final old = NutritionGoal.fromJson(
      NutritionGoal.defaultGoal.toJson()..remove('dailyWater'),
    );
    expect(old.dailyWater, isNull);
    final goal = NutritionGoal.fromPercentages(
      dailyCalories: 2000,
      fatPercentage: 30,
      carbsPercentage: 50,
      proteinPercentage: 20,
      dailyWater: 2100,
    );
    await db.updateNutritionGoal(DateTagged(date: now, value: goal));
    expect(
      (await db.watchNutritionGoals().first).single.value.dailyWater,
      2100,
    );
    await db.updateNutritionGoal(DateTagged(date: now, value: old));
    expect(
      (await db.watchNutritionGoals().first).single.value.dailyWater,
      isNull,
    );
  });

  test(
    'export is opt-in, updates without duplicates and removes own entry',
    () async {
      await repository.save(milliliters: 250, time: now);
      await sync.process();
      expect(health.calls, isEmpty);
      await sync.enable();
      expect(health.records.values, [250]);
      await sync.process();
      expect(health.calls, hasLength(1));
      final entry = (await repository.watch(null).first).single;
      await repository.save(id: entry.id, milliliters: 500, time: now);
      await sync.process();
      expect(health.records.values, [500]);
      expect(health.calls.last.$1, health.calls.first.$1);
      await repository.remove(entry.id);
      await sync.process();
      expect(health.records, isEmpty);
      expect(health.deleted, [health.calls.first.$1]);
    },
  );

  test(
    'failed writes survive restart and reuse identifier and version',
    () async {
      await repository.save(milliliters: 250, time: now);
      health.fail = true;
      await sync.enable();
      expect(sync.status.value, HydrationStatus.pending);
      final attempt = health.calls.single;
      sync.dispose();
      sync = HydrationSync(db, health: health);
      health.fail = false;
      await sync.process();
      expect(health.calls.last, attempt);
      expect(health.records, hasLength(1));
      expect(sync.status.value, HydrationStatus.synced);
    },
  );

  test('denial and opt-out keep diary data without exporting', () async {
    await repository.save(milliliters: 250, time: now);
    health.authorized = false;
    await sync.enable();
    expect(health.calls, isEmpty);
    health.authorized = true;
    await sync.enable();
    await sync.disable();
    await repository.save(milliliters: 500, time: now);
    await sync.process();
    expect(health.calls, hasLength(1));
    expect(await repository.watch(null).first, hasLength(2));
  });

  test(
    'food contributions use scaled portions and follow edits/deletions',
    () async {
      final food = Food(
        id: 'food',
        name: 'Cucumber',
        nutritionalValuesPer100g: NutritionValues.fromJson({
          ...NutritionValues.zero.toJson(),
          'water': 95,
        }),
        amount: 200,
        pieces: 2,
      );
      await db.insertFoods(DateTagged(date: now, value: food));
      await sync.enable();
      expect(health.records.values, [380]);
      await db.updateFoods(
        DateTagged(date: now, value: food.copyWith(amount: 100)),
      );
      await sync.process();
      expect(health.records.values, [190]);
      await db.deleteFoods('food');
      await sync.process();
      expect(health.records, isEmpty);
    },
  );

  test(
    'first connection excludes old diary days and another account',
    () async {
      await repository.save(
        milliliters: 250,
        time: now.subtract(const Duration(days: 3)),
      );
      db.setCurrentUserId('A');
      await repository.save(milliliters: 500, time: now);
      db.setCurrentUserId(null);
      await sync.enable();
      expect(health.calls, isEmpty);
      db.setCurrentUserId('A');
      await sync.process();
      expect(health.calls, isEmpty);
      await sync.enable();
      expect(health.records.values, [500]);
    },
  );

  test(
    'JSON export includes water entries and water goal without device settings',
    () async {
      await repository.save(milliliters: 350, time: now);
      await db.updateNutritionGoal(
        DateTagged(
          date: now,
          value: const NutritionGoal(
            dailyCalories: 2000,
            dailyFat: 60,
            dailyCarbs: 250,
            dailyProtein: 100,
            dailyWater: 2200,
          ),
        ),
      );
      await sync.enable();
      final json = await const VersionedJsonExportV23().export(db);
      expect(json['version'], 23);
      expect((json['waterLogs'] as List).single['milliliters'], 350);
      expect(
        (json['nutritionGoals'] as List).single['goal']['dailyWater'],
        2200,
      );
      expect(json.keys, isNot(contains('hydrationSettings')));
      expect(json.keys, isNot(contains('hydrationExports')));
    },
  );

  test('v22 migration adds hydration without changing existing data', () async {
    final schema = jsonDecode(
      File('drift_schemas/drift_schema_v22.json').readAsStringSync(),
    );
    final migrated = GTDatabaseImpl.withQueryExecutor(
      NativeDatabase.memory(
        setup: (raw) {
          for (final entry in schema['fixed_sql'] as List) {
            for (final statement in entry['sql'] as List) {
              if (statement['dialect'] == 'sqlite') {
                raw.execute(statement['sql'] as String);
              }
            }
          }
          raw.execute(
            "INSERT INTO nutrition_goals(id,reference_date,calories,fat,carbs,protein) VALUES('legacy',0,2000,60,250,100)",
          );
          raw.execute('PRAGMA user_version = 22');
        },
      ),
    );
    addTearDown(migrated.close);
    await migrated.validateDatabaseSchema();
    final goals = await migrated.select(migrated.nutritionGoals).get();
    expect(goals.single.calories, 2000);
    expect(goals.single.water, isNull);
    expect(await migrated.select(migrated.waterLogs).get(), isEmpty);
  });

  test(
    'backup restore includes water and goals but excludes device export state',
    () async {
      final dir = await Directory.systemTemp.createTemp('hydration-backup-');
      addTearDown(() => dir.delete(recursive: true));
      final file = File('${dir.path}/backup.sqlite');
      final source = GTDatabaseImpl.openBackup(file);
      final sourceRepo = HydrationRepository(source);
      await sourceRepo.save(milliliters: 350, time: now);
      await source
          .into(source.hydrationSettings)
          .insert(
            HydrationSettingsCompanion.insert(
              owner: 'guest',
              enabledSince: now,
            ),
          );
      await source.close();
      final prepared = await PreparedDatabaseRestore.load(file, null);
      expect(prepared.rows['water_logs'], hasLength(1));
      await prepared.apply(db);
      expect((await repository.watch(null).first).single.milliliters, 350);
      expect(prepared.rows.keys, isNot(contains('hydration_settings')));
      expect(prepared.rows.keys, isNot(contains('hydration_exports')));
    },
  );
}
