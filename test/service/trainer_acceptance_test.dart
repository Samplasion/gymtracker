import 'dart:async';
import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/service/trainer.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncable/syncable.dart';

class _ScriptedService extends TrainerService {
  _ScriptedService(super.db, super.client, this.handle);
  final Future<dynamic> Function(String) handle;
  @override
  Future<dynamic> execute(
    String operation, [
    Map<String, dynamic> payload = const {},
  ]) => handle(operation);
}

const accepted = <String, dynamic>{
  'link': {'id': 'link'},
  'controls': [
    {'routine_id': 'assigned'},
  ],
  'offers': [],
};
const pending = <String, dynamic>{
  'link': {'id': 'link'},
  'controls': [],
  'offers': [
    {'id': 'plan'},
  ],
};
const completed = SyncResult(
  SyncOutcome.completed,
  userId: 'owner',
  cycleId: 'cycle',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late GTDatabaseImpl db;
  late SupabaseClient client;
  setUp(() {
    db = GTDatabaseImpl.withQueryExecutor(NativeDatabase.memory());
    db.setCurrentUserId('owner');
    client = SupabaseClient('https://trainer.test', 'key');
  });
  tearDown(() async {
    await db.close();
    await client.dispose();
  });

  test(
    'partial sync logs isolated queue counts and safe rejection codes',
    () async {
      final messages = <String>[];
      final subscription = globalLogger.onRecord.listen(
        (record) => messages.add(record.message),
      );
      addTearDown(subscription.cancel);
      await db.customStatement(
        '''INSERT INTO sync_outbox
      (operation_id,owner,entity,record_id,payload,blocked,error) VALUES
      ('one','owner','routines','private-id','private-payload',1,NULL),
      ('two','owner','routine_exercises','private-id','private-payload',0,'23514'),
      ('three','owner','private-entity','private-id','private-payload',0,'private-error'),
      ('four','another-owner','routines','private-id','private-payload',1,'42501')''',
      );
      await db.customStatement(
        '''INSERT INTO sync_conflicts
      (operation_id,owner,entity,record_id,local_payload,server_payload,server_revision)
      VALUES ('one','owner','routines','private-id','private-payload','private-payload',1)''',
      );
      var mutations = 0;
      final service = _ScriptedService(db, client, (_) async {
        mutations++;
        return {};
      });
      await expectLater(
        service.performMutation(
          'share',
          {},
          synchronize: () async => const SyncResult(
            SyncOutcome.partial,
            userId: 'owner',
            cycleId: 'cycle',
            pending: 3,
          ),
        ),
        throwsA(
          isA<TrainerApiException>().having(
            (e) => e.code,
            'code',
            'sync_conflicts',
          ),
        ),
      );
      final message = messages.singleWhere(
        (m) => m.startsWith('Trainer synchronization incomplete'),
      );
      expect(
        message,
        contains('pending=3, blocked=1, rejected=2, conflicts=1'),
      );
      expect(message, contains('routine_exercises:23514:1'));
      expect(message, contains('unknown:unknown:1'));
      expect(message, contains('stage=sync_required'));
      expect(message, contains('cause=none'));
      expect(message, isNot(contains('private')));
      expect(message, isNot(contains('42501')));
      expect(mutations, 0);
    },
  );

  test(
    'partial sync logs the server code without the error contents',
    () async {
      final messages = <String>[];
      final subscription = globalLogger.onRecord.listen(
        (record) => messages.add(record.message),
      );
      addTearDown(subscription.cancel);
      final service = _ScriptedService(db, client, (_) async => {});
      await expectLater(
        service.performMutation(
          'share',
          {},
          synchronize: () async => const SyncResult(
            SyncOutcome.partial,
            userId: 'owner',
            cycleId: 'cycle',
            error: PostgrestException(
              message: 'private workout data',
              code: '42501',
              details: 'private details',
            ),
          ),
        ),
        throwsA(isA<TrainerApiException>()),
      );
      final message = messages.singleWhere(
        (m) => m.startsWith('Trainer synchronization incomplete'),
      );
      expect(message, contains('cause=PostgrestException:42501'));
      expect(
        message,
        contains('pending=0, blocked=0, rejected=0, conflicts=0'),
      );
      expect(message, isNot(contains('private')));
    },
  );

  test(
    'acceptance imports remotely before refreshing and synchronizing once',
    () async {
      final events = <String>[];
      final service = _ScriptedService(db, client, (operation) async {
        events.add(operation);
        return operation == 'session' ? accepted : {'accepted': true};
      });
      await db.cacheTrainerState('owner', pending);
      await service.performMutation(
        'accept',
        {},
        synchronize: () async {
          events.add('sync');
          return completed;
        },
      );
      expect(events, ['accept', 'session', 'sync']);
      expect(db.cachedTrainerState.offers, isEmpty);
      expect(db.cachedTrainerState.controls, {'assigned'});
    },
  );

  test(
    'a failed download is never reported as a successful completed import',
    () async {
      final service = _ScriptedService(
        db,
        client,
        (operation) async =>
            operation == 'session' ? accepted : {'accepted': true},
      );
      await expectLater(
        service.performMutation(
          'accept',
          {},
          synchronize: () async => const SyncResult(
            SyncOutcome.offline,
            userId: 'owner',
            cycleId: 'download',
          ),
        ),
        throwsA(
          isA<TrainerApiException>().having(
            (e) => e.code,
            'code',
            'download_pending',
          ),
        ),
      );
      expect(db.cachedTrainerState.offers, isEmpty);
      var downloads = 0;
      await service.refreshAndSync(() async {
        downloads++;
        return completed;
      });
      expect(
        downloads,
        1,
        reason: 'Refresh resumes a committed import without another acceptance',
      );
    },
  );

  test(
    'local conflicts do not prevent acceptance and remain preserved after partial sync',
    () async {
      final events = <String>[];
      await db.cacheTrainerState('owner', pending);
      await db.customStatement(
        """INSERT INTO sync_outbox
        (operation_id,owner,entity,record_id,payload,blocked)
        VALUES ('blocked','owner','routines','personal','preserved-local-data',1)""",
      );
      final service = _ScriptedService(db, client, (operation) async {
        events.add(operation);
        return operation == 'session' ? accepted : {'accepted': true};
      });
      await expectLater(
        service.performMutation(
          'accept',
          {},
          synchronize: () async {
            events.add('sync');
            return const SyncResult(
              SyncOutcome.partial,
              userId: 'owner',
              cycleId: 'conflict',
              pending: 1,
            );
          },
        ),
        throwsA(
          isA<TrainerApiException>().having(
            (e) => e.code,
            'code',
            'sync_pending',
          ),
        ),
      );
      expect(events, ['accept', 'session', 'sync', 'session']);
      expect(db.cachedTrainerState.offers, isEmpty);
      expect(db.cachedTrainerState.controls, {'assigned'});
      final op = await db.customSelect('SELECT * FROM sync_outbox').getSingle();
      expect(op.read<String>('payload'), 'preserved-local-data');
      expect(op.read<int>('blocked'), 1);
    },
  );

  test('a rejected acceptance does not start a download', () async {
    var syncs = 0;
    final service = _ScriptedService(db, client, (operation) async {
      if (operation == 'accept') {
        throw const TrainerApiException('routine_slots_exhausted');
      }
      return pending;
    });
    await expectLater(
      service.performMutation(
        'accept',
        {},
        synchronize: () async {
          syncs++;
          return completed;
        },
      ),
      throwsA(
        isA<TrainerApiException>().having(
          (e) => e.code,
          'code',
          'routine_slots_exhausted',
        ),
      ),
    );
    expect(syncs, 0);
    expect(db.cachedTrainerState.offers, isNotEmpty);
  });

  test(
    'a lost acceptance response is reconciled instead of keeping a stale prompt',
    () async {
      await db.cacheTrainerState('owner', pending);
      final service = _ScriptedService(db, client, (operation) async {
        if (operation == 'accept') {
          throw const TrainerApiException('request_timeout');
        }
        return accepted; // The remote transaction committed before losing its response.
      });
      await expectLater(
        service.performMutation(
          'accept',
          {},
          synchronize: () async => completed,
        ),
        throwsA(isA<TrainerApiException>()),
      );
      expect(db.cachedTrainerState.offers, isEmpty);
      await service.refreshAndSync(() async => completed);
      expect(db.cachedTrainerState.controls, {'assigned'});
    },
  );

  test(
    'an older background snapshot cannot restore an already accepted offer',
    () async {
      final oldResponse = Completer<dynamic>();
      var requests = 0;
      final oldService = _ScriptedService(
        db,
        client,
        (_) => ++requests == 1 ? oldResponse.future : Future.value(accepted),
      );
      final oldRefresh = oldService.refresh();
      await pumpEventQueue();
      final pageService = _ScriptedService(db, client, (_) async => accepted);
      await pageService.refresh();
      oldResponse.complete(pending);
      await oldRefresh;
      expect(db.cachedTrainerState.offers, isEmpty);
      expect(db.cachedTrainerState.controls, {'assigned'});
    },
  );

  test(
    'an account change cannot complete an acceptance or download for the old owner',
    () async {
      final service = _ScriptedService(db, client, (_) async => accepted);
      await expectLater(
        service.performMutation(
          'accept',
          {},
          synchronize: () async {
            db.setCurrentUserId('other');
            return completed;
          },
        ),
        throwsA(
          isA<TrainerApiException>().having(
            (e) => e.code,
            'code',
            'account_changed',
          ),
        ),
      );
      expect(db.cachedTrainerState.controls, isEmpty);
    },
  );

  test(
    'acceptance has a longer timeout than ordinary reads and still sends protocol version',
    () async {
      await client.dispose();
      final bodies = <Map<String, dynamic>>[];
      client = SupabaseClient(
        'https://trainer.test',
        'key',
        httpClient: MockClient((request) async {
          bodies.add(
            Map<String, dynamic>.from(jsonDecode(request.body) as Map),
          );
          await Future<void>.delayed(const Duration(milliseconds: 30));
          return http.Response(
            '{"accepted":true}',
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
      );
      await client.auth.recoverSession(
        jsonEncode({
          'access_token': 'test-token',
          'token_type': 'bearer',
          'user': {
            'id': 'owner',
            'app_metadata': {},
            'user_metadata': {},
            'aud': 'authenticated',
            'created_at': '2026-01-01T00:00:00Z',
          },
        }),
      );
      final service = TrainerService(
        db,
        client,
        requestTimeout: const Duration(milliseconds: 1),
        acceptanceTimeout: const Duration(seconds: 1),
      );
      expect(await service.execute('accept', {'plan_id': 'plan'}), {
        'accepted': true,
      });
      expect(bodies.single['protocol_version'], 1);
      await expectLater(
        service.execute('session'),
        throwsA(
          isA<TrainerApiException>().having(
            (e) => e.code,
            'code',
            'request_timeout',
          ),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 40));
    },
  );
}
