import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/db/model/tables/exercise.dart';
import 'package:gymtracker/model/routines.dart';
import 'package:gymtracker/provider/events.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/service/trainer.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncable/syncable.dart';

class _Backend {
  _Backend(this.interruption);
  final String interruption;
  bool accepted = false;
  bool interrupted = false;
  int acceptances = 0;
  final changes = <Map<String, dynamic>>[];
  late final client = SupabaseClient(
    'https://trainer.test',
    'key',
    httpClient: MockClient(handle),
  );

  void add(String entity, Map<String, dynamic> payload) {
    final revision = changes.length + 1;
    changes.add({
      'entity': entity,
      'revision': revision,
      'payload': {
        ...payload,
        'user_id': 'owner',
        'updated_at': '2026-10-31T12:00:00Z',
        'deleted': false,
        'revision': revision,
      },
    });
  }

  Future<http.Response> handle(http.Request request) async {
    final body = Map<String, dynamic>.from(jsonDecode(request.body) as Map);
    Object result;
    if (request.url.path.endsWith('/trainer-api')) {
      if (body['operation'] == 'accept') {
        acceptances++;
        if (!accepted) {
          accepted = true;
          add('routine_folders', {
            'id': 'folder',
            'name': 'Strength plan',
            'sort_order': 0,
            'notes': '',
          });
          add('custom_exercises', {
            'id': 'custom',
            'name': 'Custom press',
            'parameters': 'repsWeight',
            'primary_muscle_group': 'chest',
            'secondary_muscle_groups': [],
            'equipment': 'none',
          });
          add('routines', {
            'id': 'day',
            'name': 'Day A',
            'infobox': '',
            'weight_unit': 'kg',
            'distance_unit': 'km',
            'sort_order': 0,
            'folder_id': 'folder',
          });
          add('routine_exercises', {
            'id': 'row',
            'routine_id': 'day',
            'name': 'Custom press',
            'parameters': 'repsWeight',
            'primary_muscle_group': 'chest',
            'secondary_muscle_groups': [],
            'is_custom': true,
            'custom_exercise_id': 'custom',
            'is_superset': false,
            'is_in_superset': false,
            'superset_id': null,
            'sort_order': 0,
            'rest_time': 90,
            'notes': '',
            'equipment': 'none',
            'sets': [
              {
                'id': 'set',
                'kind': 'normal',
                'parameters': 'repsWeight',
                'reps': 8,
                'weight': 20,
                'time': 0,
                'distance': 0,
                'done': false,
                'rpe': null,
              },
            ],
          });
        }
        if (interruption == 'response' && !interrupted) {
          interrupted = true;
          throw http.ClientException('Acceptance response lost after commit');
        }
        result = {'accepted': true};
      } else {
        result = {
          'link': {'id': 'link'},
          'controls': accepted
              ? [
                  {'routine_id': 'day'},
                ]
              : [],
          'protected_exercises': accepted ? ['custom'] : [],
          'offers': accepted
              ? []
              : [
                  {'id': 'plan'},
                ],
        };
      }
    } else if (request.url.path.endsWith('/sync_push_v2')) {
      expect(
        body['operations'],
        isEmpty,
        reason: 'Imported rows must never become local pending edits',
      );
      result = [];
    } else {
      if (accepted && interruption == 'download' && !interrupted) {
        interrupted = true;
        throw http.ClientException('Download interrupted');
      }
      final cursor = body['cursor'] as int;
      final horizon = body['horizon'] as int? ?? changes.length;
      final rows = changes
          .where(
            (r) =>
                (r['revision'] as int) > cursor &&
                (r['revision'] as int) <= horizon,
          )
          .toList();
      result = {
        'changes': rows,
        'horizon': horizon,
        'cursor': rows.isEmpty ? cursor : rows.last['revision'],
        'has_more': false,
      };
    }
    return http.Response(
      jsonEncode(result),
      200,
      request: request,
      headers: {'content-type': 'application/json'},
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final interruption in ['response', 'download', 'conflicts']) {
    test(
      'accepted trainer plan reaches local storage after interrupted $interruption without accepting twice',
      () async {
        final db = GTDatabaseImpl.withQueryExecutor(NativeDatabase.memory());
        db.setCurrentUserId('owner');
        final backend = _Backend(interruption);
        await backend.client.auth.recoverSession(
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
        final manager = GBSyncManager(
          localDatabase: db,
          supabaseClient: backend.client,
          eventBus: EventBus(),
          useProtocolV2: true,
          syncInterval: const Duration(hours: 1),
        );
        manager.registerSyncable<RoutineFolder>(
          backendTable: 'routine_folders',
          fromJson: RoutineFolder.fromJson,
          companionConstructor: RoutineFoldersCompanion.new,
        );
        manager.registerSyncable<Routine>(
          backendTable: 'routines',
          fromJson: Routine.fromJson,
          companionConstructor: RoutinesCompanion.new,
        );
        manager.registerSyncable<CustomExercise>(
          backendTable: 'custom_exercises',
          fromJson: CustomExercise.fromJson,
          companionConstructor: CustomExercisesCompanion.new,
        );
        manager.registerSyncable<RoutineExercise>(
          backendTable: 'routine_exercises',
          fromJson: RoutineExercise.fromJson,
          companionConstructor: RoutineExercisesCompanion.new,
        );
        manager.setUserId('owner');
        manager.setLastTimeOtherDeviceWasActive(DateTime.utc(2000));
        addTearDown(() async {
          await manager.close();
          await db.close();
          await backend.client.dispose();
        });
        manager.enableSync();
        await manager.syncTables();
        if (interruption == 'conflicts') {
          await db.customStatement(
            '''INSERT INTO sync_outbox
            (operation_id,owner,entity,record_id,payload,blocked)
            VALUES ('existing-conflict','owner','routines','personal','{}',1)''',
          );
          await db.customStatement(
            '''INSERT INTO sync_conflicts
            (operation_id,owner,entity,record_id,local_payload,server_payload,server_revision)
            VALUES ('existing-conflict','owner','routines','personal','{}','{}',1)''',
          );
        }
        final service = TrainerService(db, backend.client);
        Future<SyncResult> synchronize() async {
          await manager.waitForAllTables();
          try {
            await manager.retryPending();
          } catch (_) {
            /* The result reports failed downloads. */
          }
          return manager.lastResult!;
        }

        await expectLater(
          service.performMutation('accept', {
            'plan_id': 'plan',
          }, synchronize: synchronize),
          throwsA(
            interruption == 'conflicts'
                ? isA<TrainerApiException>().having(
                    (e) => e.code,
                    'code',
                    'sync_pending',
                  )
                : isA<TrainerApiException>(),
          ),
        );
        expect(backend.acceptances, 1);
        expect(db.cachedTrainerState.offers, isEmpty);
        if (interruption == 'conflicts') {
          expect(await SyncV2Store.pending(db, 'owner'), 1);
          expect(
            (await db
                    .customSelect('SELECT resolved FROM sync_conflicts')
                    .getSingle())
                .read<int>('resolved'),
            0,
          );
        } else {
          expect(await db.getAllRoutinesFuture(), isEmpty);
          await service.refreshAndSync(synchronize);
        }
        final routines = await db.getAllRoutinesFuture();
        expect(routines, hasLength(1));
        expect(routines.single.name, 'Day A');
        expect(routines.single.folder?.name, 'Strength plan');
        expect(routines.single.exercises, hasLength(1));
        expect(await db.getAllCustomExercises().first, hasLength(1));
        expect(db.cachedTrainerState.controls, {'day'});
        if (interruption == 'conflicts') {
          await expectLater(
            service.refreshAndSync(synchronize),
            throwsA(
              isA<TrainerApiException>().having(
                (e) => e.code,
                'code',
                'sync_pending',
              ),
            ),
          );
        } else {
          await service.refreshAndSync(synchronize);
        }
        expect(backend.acceptances, 1);
        expect(await db.getAllRoutinesFuture(), hasLength(1));
        expect(await db.getAllCustomExercises().first, hasLength(1));
      },
    );
  }
}
