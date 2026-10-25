import 'dart:async';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/repository/food_catalog.dart';
import 'package:gymtracker/service/catalog_delivery.dart';
import 'package:gymtracker/struct/nutrition.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const sample = Food(
  name: 'Milk',
  brand: 'Brand',
  barcode: '00123456',
  amount: 150,
  pieces: 2,
  category: 'Private breakfast',
  nutritionalValuesPer100g: NutritionValues.zero,
  servingSizes: [ServingSize(name: 'Glass', amount: 200)],
  unit: NutritionUnit.MILLI_L,
);

void main() {
  late GTDatabaseImpl db;
  late CatalogOutbox outbox;
  var now = DateTime.now();
  String? owner;
  setUp(() {
    db = GTDatabaseImpl.withQueryExecutor(NativeDatabase.memory());
    db.setCurrentUserId('A');
    outbox = CatalogOutbox(db);
    owner = 'A';
    now = DateTime.now().add(const Duration(minutes: 1));
  });
  tearDown(() => db.close());

  CatalogDelivery delivery(
    Future<Map<String, dynamic>> Function(String, String, Map<String, dynamic>)
    submit,
  ) => CatalogDelivery(
    outbox: outbox,
    activeOwner: () => owner,
    submit: submit,
    now: () => now,
  );

  test(
    'snapshot excludes diary identity and never enters sync outbox',
    () async {
      await outbox.enqueue('A', sample);
      final row = (await outbox.watch('A').first).single;
      expect(row.definition.keys, isNot(contains('amount')));
      expect(row.definition.keys, isNot(contains('category')));
      expect(row.definition.keys, isNot(contains('id')));
      expect(row.definition['servingSizes'], [
        {'name': 'Glass', 'amount': 200.0},
      ]);
      expect(await db.select(db.syncOutbox).get(), isEmpty);
      expect(await db.watchFoods().first, isEmpty);
    },
  );

  for (final unit in [NutritionUnit.G, NutritionUnit.MILLI_L]) {
    test(
      'submission stays per 100 ${unit.name} regardless of diary portions',
      () async {
        final food = Food(
          name: 'Normalized food',
          amount: 37.5,
          pieces: 3,
          unit: unit,
          nutritionalValuesPer100g: const NutritionValues(
            calories: 120,
            fat: 3,
            saturatedFat: 1,
            carbs: 15,
            sugar: 4,
            protein: 7,
            calcium: 120,
            fiber: 2,
          ),
          servingSizes: const [ServingSize(name: 'Portion', amount: 200)],
        );
        expect(food.nutritionalValues.calories, 135);
        await outbox.enqueue('A', food);
        await outbox.enqueue('A', food.copyWith(amount: 400, pieces: 2));
        final rows = await outbox.watch('A').first;
        expect(rows, hasLength(2));
        expect(rows.first.definition, rows.last.definition);
        expect(
          rows.first.definition['unit'],
          unit == NutritionUnit.G ? 'g' : 'ml',
        );
        expect(
          rows.first.definition['nutritionalValuesPer100g'],
          containsPair('calories', 120.0),
        );
        expect(
          rows.first.definition['nutritionalValuesPer100g'],
          containsPair('protein', 7.0),
        );
        expect(
          rows.first.definition['nutritionalValuesPer100g'],
          containsPair('calcium', 120.0),
        );
        expect(rows.first.definition.keys, isNot(contains('amount')));
        expect(rows.first.definition.keys, isNot(contains('pieces')));
        expect(rows.first.definition['servingSizes'], [
          {'name': 'Portion', 'amount': 200.0},
        ]);
      },
    );
  }

  test(
    'lost response retries immutable operation and product only once',
    () async {
      final id = await outbox.enqueue('A', sample);
      final receipts = <String, Map<String, dynamic>>{};
      var requests = 0;
      final worker = delivery((_, operation, definition) async {
        requests++;
        final result = receipts.putIfAbsent(
          operation,
          () => {'outcome': 'published', 'food_id': 'server-id'},
        );
        if (requests == 1) throw StateError('Response lost');
        return result;
      });
      await worker.process();
      expect((await outbox.watch('A').first).single.status, 'pending');
      now = now.add(const Duration(minutes: 10));
      await worker.process();
      expect(requests, 2);
      expect(receipts.keys.single, id);
      expect((await outbox.watch('A').first).single.status, 'published');
    },
  );

  test(
    'logout pauses; another account never receives pending submissions',
    () async {
      await outbox.enqueue('A', sample);
      var calls = 0;
      final worker = delivery((_, _, _) async {
        calls++;
        return {'outcome': 'published'};
      });
      owner = null;
      await worker.process();
      owner = 'B';
      db.setCurrentUserId('B');
      await worker.process();
      expect(calls, 0);
      owner = 'A';
      db.setCurrentUserId('A');
      await worker.process();
      expect(calls, 1);
    },
  );

  test(
    'cancel pending submissions, but not requests already in flight',
    () async {
      final cancelled = await outbox.enqueue('A', sample);
      await outbox.cancel('A', cancelled);
      final inFlight = await outbox.enqueue('A', sample);
      final gate = Completer<Map<String, dynamic>>();
      var calls = 0;
      final worker = delivery((_, _, _) {
        calls++;
        return gate.future;
      });
      final running = worker.process();
      await pumpEventQueue();
      await outbox.cancel('A', inFlight);
      await worker.process();
      expect(calls, 1);
      gate.complete({'outcome': 'correction'});
      await running;
      expect(
        (await outbox.watch('A').first).map((r) => r.status),
        containsAll(['cancelled', 'correction']),
      );
    },
  );

  test(
    'permanent errors stay visible; manual retry preserves operation ID',
    () async {
      final id = await outbox.enqueue('A', sample);
      final worker = delivery(
        (_, _, _) async => throw const PostgrestException(
          message: 'Invalid food',
          code: '22023',
        ),
      );
      await worker.process();
      expect((await outbox.watch('A').first).single.status, 'failed');
      await outbox.retry('A', id);
      final successful = delivery((_, operation, _) async {
        expect(operation, id);
        return {'outcome': 'duplicate'};
      });
      await successful.process();
      expect((await outbox.watch('A').first).single.status, 'duplicate');
    },
  );

  test(
    'clearing account data deletes pending requests, not another account',
    () async {
      await outbox.enqueue('A', sample);
      db.setCurrentUserId('B');
      await outbox.enqueue('B', sample);
      await db.clearUserData('A');
      expect(await outbox.watch('A').first, isEmpty);
      expect(await outbox.watch('B').first, hasLength(1));
    },
  );

  test(
    'persistent outbox survives restart and recovers interrupted delivery',
    () async {
      final dir = await Directory.systemTemp.createTemp('catalog-outbox-');
      final file = File('${dir.path}/db.sqlite');
      var persistent = GTDatabaseImpl.withQueryExecutor(NativeDatabase(file));
      persistent.setCurrentUserId('A');
      var store = CatalogOutbox(persistent);
      final id = await store.enqueue('A', sample);
      await store.claim((await store.watch('A').first).single);
      await persistent.close();
      persistent = GTDatabaseImpl.withQueryExecutor(NativeDatabase(file));
      persistent.setCurrentUserId('A');
      store = CatalogOutbox(persistent);
      try {
        final worker = CatalogDelivery(
          outbox: store,
          activeOwner: () => 'A',
          submit: (_, operation, _) async {
            expect(operation, id);
            return {'outcome': 'published'};
          },
        );
        await worker.process();
        expect((await store.watch('A').first).single.status, 'published');
      } finally {
        await persistent.close();
        await dir.delete(recursive: true);
      }
    },
  );
  test(
    'cancelling retries after an uncertain response does not promise withdrawal',
    () async {
      final id = await outbox.enqueue('A', sample);
      final worker = delivery(
        (_, _, _) async => throw TimeoutException('Response lost'),
      );
      await worker.process();
      await outbox.cancel('A', id);
      expect(
        (await outbox.watch('A').first).single.status,
        'cancelled_unknown',
      );
      now = now.add(const Duration(days: 1));
      var called = false;
      await delivery((_, _, _) async {
        called = true;
        return {'outcome': 'published'};
      }).process();
      expect(called, isFalse);
    },
  );
}
