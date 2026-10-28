import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/struct/nutrition.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final owner in <String?>['owner', null]) {
    group('custom barcode foods for ${owner ?? 'guest'}', () {
      late GTDatabaseImpl database;
      const barcode = '12345678';
      Food food(String name) => Food(
        name: name,
        amount: 100,
        nutritionalValuesPer100g: NutritionValues.zero,
      );

      setUp(() {
        database = GTDatabaseImpl.withQueryExecutor(NativeDatabase.memory());
        database.setCurrentUserId(owner);
      });
      tearDown(() => database.close());

      test('saving the same barcode updates its existing row', () async {
        await database.insertCustomBarcodeFood(barcode, food('Original'));
        await database.insertCustomBarcodeFood(barcode, food('Updated'));

        final rows = await database.select(database.customBarcodeFoods).get();
        expect(rows, hasLength(1));
        expect(Food.fromJson(jsonDecode(rows.single.jsonData)).name, 'Updated');
        expect(rows.single.deleted, isFalse);
      });

      test('saving a deleted barcode reactivates its existing row', () async {
        await database.insertCustomBarcodeFood(barcode, food('Original'));
        await database.deleteCustomBarcodeFood(barcode);
        await database.insertCustomBarcodeFood(barcode, food('Restored'));

        final rows = await database.select(database.customBarcodeFoods).get();
        expect(rows, hasLength(1));
        expect(rows.single.deleted, isFalse);
        expect(
          Food.fromJson(jsonDecode(rows.single.jsonData)).name,
          'Restored',
        );
      });

      test(
        'updating a barcode preserves another account and its tombstone',
        () async {
          database.setCurrentUserId('other');
          await database.insertCustomBarcodeFood(barcode, food('Other'));
          await database.deleteCustomBarcodeFood(barcode);
          final otherBefore =
              (await database.select(database.customBarcodeFoods).get()).single;

          database.setCurrentUserId(owner);
          await database.insertCustomBarcodeFood(barcode, food('Original'));
          await database.insertCustomBarcodeFood(barcode, food('Updated'));

          final rows = await database.select(database.customBarcodeFoods).get();
          expect(rows, hasLength(2));
          final otherAfter = rows.singleWhere((row) => row.userId == 'other');
          expect(otherAfter.jsonData, otherBefore.jsonData);
          expect(otherAfter.deleted, isTrue);
          expect(otherAfter.updatedAt, otherBefore.updatedAt);
          final ownRow = rows.singleWhere((row) => row.userId == owner);
          expect(Food.fromJson(jsonDecode(ownRow.jsonData)).name, 'Updated');
        },
      );
    });
  }
}
