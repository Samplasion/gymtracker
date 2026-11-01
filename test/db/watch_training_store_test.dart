import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/db/wearable_training_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'receipt and database changes roll back together; owners remain isolated',
    () async {
      final db = GTDatabaseImpl.withQueryExecutor(NativeDatabase.memory());
      addTearDown(db.close);
      final store = WearableTrainingStore(db);
      final document = <String, dynamic>{
        'id': 'session',
        'ownerScope': 'guest',
        'status': 'active',
      };
      await store.write(document);
      await expectLater(
        db.transaction(() async {
          await store.write({
            ...document,
            'status': 'completed',
          }, processed: true);
          throw StateError('interrupted before commit');
        }),
        throwsStateError,
      );
      expect(await store.processed('guest', 'session'), isFalse);
      expect((await store.read('guest', 'session'))!['status'], 'active');
      await store.write({...document, 'status': 'completed'}, processed: true);
      await store.write(document);
      expect(await store.processed('guest', 'session'), isTrue);
      expect(await store.processed('user:other', 'session'), isFalse);
      expect(await store.read('user:other', 'session'), isNull);
    },
  );
}
