import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/repository/hydration.dart';

void main() {
  late GTDatabaseImpl db;
  late HydrationRepository repository;
  const id = '095dc29b-020c-44b3-ad16-1279f08ef234';
  final yesterday = DateTime.now().subtract(const Duration(days: 1));

  setUp(() {
    db = GTDatabaseImpl.withQueryExecutor(NativeDatabase.memory());
    repository = HydrationRepository(db);
  });
  tearDown(() => db.close());

  Future<bool> import({
    String scope = 'guest',
    double amount = 250,
    DateTime? time,
  }) => repository.importWatchEntry(
    id: id,
    milliliters: amount,
    time: time ?? yesterday,
    ownerScope: scope,
  );

  test(
    'concurrent guest retries insert exactly one entry with its original date',
    () async {
      expect(
        await Future.wait(List.generate(5, (_) => import())),
        everyElement(isTrue),
      );
      final rows = await db.select(db.waterLogs).get();
      expect(rows, hasLength(1));
      final entry = WaterEntry.fromRow(rows.single);
      expect(entry.milliliters, 250);
      expect(
        entry.time.millisecondsSinceEpoch,
        yesterday.millisecondsSinceEpoch,
      );
      expect(
        rows.single.referenceDate.toUtc(),
        DateTime.utc(yesterday.year, yesterday.month, yesterday.day),
      );
    },
  );

  test('replay preserves edits and tombstones', () async {
    await import();
    await repository.save(id: id, milliliters: 500, time: yesterday);
    await import();
    expect(
      WaterEntry.fromRow(
        (await db.select(db.waterLogs).get()).single,
      ).milliliters,
      500,
    );
    await repository.remove(id);
    await import();
    expect((await db.select(db.waterLogs).get()).single.deleted, isTrue);
  });

  test(
    'account mismatch stays pending and same ID remains isolated by owner',
    () async {
      db.setCurrentUserId('original');
      expect(await import(), isFalse);
      expect(await import(scope: 'user:original'), isTrue);
      db.setCurrentUserId('other');
      expect(await import(scope: 'user:original'), isFalse);
      expect(await import(scope: 'user:other', amount: 500), isTrue);
      final rows = await db.select(db.waterLogs).get();
      expect(rows, hasLength(2));
      expect(rows.map((e) => e.userId), containsAll(['original', 'other']));
    },
  );

  test('invalid amounts and future timestamps never enter the diary', () async {
    for (final amount in [double.nan, double.infinity, -1.0, 0.0]) {
      await expectLater(import(amount: amount), throwsArgumentError);
    }
    await expectLater(
      import(time: DateTime.now().add(const Duration(days: 1))),
      throwsArgumentError,
    );
    await expectLater(
      repository.importWatchEntry(
        id: 'bad',
        milliliters: 250,
        time: yesterday,
        ownerScope: 'guest',
      ),
      throwsArgumentError,
    );
    expect(await db.select(db.waterLogs).get(), isEmpty);
  });
}
