import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/controller/stopwatch_controller.dart';
import 'package:gymtracker/controller/workout_controller.dart';
import 'package:gymtracker/db/wearable_training_store.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/wearable_training.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/wearable/apple_watch_training_transport.dart';
import 'package:gymtracker/service/wearable/training_transport.dart';
import 'package:gymtracker/service/wearable_training.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/workout.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers.dart';
import '../test_helpers/data_controllers.dart';
import '../test_helpers/mock_services.dart';

class _CompanionTransport extends UnsupportedTrainingTransport {
  TrainingReceiver? receiver;
  final exchanges = <TrainingDocument>[];
  final adoptions = <TrainingDocument>[];
  @override
  bool get isSupported => true;
  @override
  void setReceiver(TrainingReceiver value) => receiver = value;
  @override
  Future<List<TrainingDocument>> exchange(TrainingDocument state) async {
    exchanges.add(state);
    return [];
  }

  @override
  Future<void> adoptSensors(TrainingDocument session) async {
    adoptions.add(session);
  }

  @override
  void dispose() => receiver = null;
}

Map<String, dynamic> session({String status = 'completed'}) => {
  'version': 1,
  'id': 'watch-session',
  'nativeWorkoutId': 'watch-session',
  'ownerScope': 'guest',
  'status': status,
  'name': 'Watch workout',
  'time': 1700000000000,
  'end': 1700000060000,
  'weightUnit': 'kg',
  'distanceUnit': 'km',
  'parentID': null,
  'infobox': null,
  'exercises': [
    exerciseHelper(
      'watch-exercise',
      'Bench',
    ).copyWith(workoutID: 'watch-session', parentID: 'source').toJson(),
  ],
};
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() async {
    MockServices.setup();
    await MockServices.database.insertCustomExercise(
      exerciseHelper('source', 'Bench'),
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          AppleWatchTrainingTransport.channel,
          (_) async => null,
        );
    when(
      () =>
          MockServices.routinesController.advanceProgressionsFromWorkout(any()),
    ).thenAnswer((_) async {});
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(AppleWatchTrainingTransport.channel, null);
    MockServices.tearDown();
  });
  for (final status in ['active', 'completed', 'discarded']) {
    test(
      'donates the first $status routine sync once with original time',
      () async {
        final donations = <Map<String, dynamic>>[];
        final service = dataController(
          (ref) => WearableTrainingService(
            ref,
            transport: _CompanionTransport(),
            donateRoutineStarted:
                ({
                  required String routineId,
                  required String routineDisplayName,
                  DateTime? timestamp,
                }) async {
                  donations.add({
                    'id': routineId,
                    'name': routineDisplayName,
                    'time': timestamp,
                  });
                },
          ),
        );
        final document = session(status: status)..['parentID'] = 'routine';
        expect((await service.receive(document))['accepted'], true);
        expect((await service.receive(document))['accepted'], true);
        expect(donations, [
          {
            'id': 'routine',
            'name': 'Watch workout',
            'time': DateTime.fromMillisecondsSinceEpoch(1700000000000),
          },
        ]);
      },
    );
  }
  test(
    'another companion adapter reuses catalog and session adoption without iOS channels',
    () async {
      final transport = _CompanionTransport();
      final service = dataController(
        (ref) => WearableTrainingService(ref, transport: transport),
      );
      service.start();
      try {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        expect(transport.exchanges.single['catalog'], isNotNull);
        final response = await transport.receiver!(session(status: 'active'));
        expect(response['accepted'], true);
        expect(transport.adoptions.single['id'], 'watch-session');
        final parameters = transport.adoptions.single['parameters'] as Map;
        expect(parameters['hasExercise'], true);
        expect(parameters['exerciseName'], 'Bench');
        expect(parameters['set'], isNotNull);
        expect((parameters['set'] as Map)['id'], isNotEmpty);
        expect(
          MockServices.container.read(workoutControllerProvider),
          isNotNull,
        );
      } finally {
        service.dispose();
      }
      expect(transport.receiver, isNull);
    },
  );

  testWidgets('discard from companion exits the open phone workout', (
    tester,
  ) async {
    final service = dataController(
      (ref) => WearableTrainingService(ref, transport: _CompanionTransport()),
    );
    final controller = MockServices.container.read(
      workoutControllerProvider.notifier,
    );
    controller.start('Phone', null, null, saveInitial: false);
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: Go.navigatorKey,
        home: const Scaffold(body: Text('Home marker')),
        routes: {
          WorkoutView.routeName: (_) =>
              const Scaffold(body: Text('Workout marker')),
        },
      ),
    );
    Go.navigator.pushNamed(WorkoutView.routeName);
    await tester.pumpAndSettle();
    expect(find.text('Workout marker'), findsOneWidget);
    await tester.runAsync(
      () => service.receive({
        ...session(status: 'discarded'),
        'id': controller.nativeWorkoutId,
        'nativeWorkoutId': controller.nativeWorkoutId,
        'time': controller.time.millisecondsSinceEpoch,
        'end': controller.time
            .add(const Duration(minutes: 1))
            .millisecondsSinceEpoch,
      }),
    );
    await tester.pumpAndSettle();
    expect(controller.isActive, false);
    expect(find.text('Home marker'), findsOneWidget);
    expect(find.text('Workout marker'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  test('Watch set edits remain importable after phone takeover', () async {
    final service = dataController(
      (ref) => WearableTrainingService(ref, transport: _CompanionTransport()),
    );
    final response = await service.receive(session(status: 'active'));
    final adopted = WearableTrainingDocument.copy(response['document'] as Map);
    final exercise = (adopted['exercises'] as List).first as Map;
    final set = (exercise['sets'] as List).first as Map;
    set['done'] = true;
    final now = DateTime.now().millisecondsSinceEpoch + 1000;
    adopted['modified'] = now;
    adopted['sequence'] = (adopted['sequence'] as int? ?? 0) + 1;
    adopted['stamps'] = {
      set['id']: {
        'time': now,
        'device': 'watch',
        'sequence': adopted['sequence'],
      },
    };
    expect((await service.receive(adopted))['accepted'], true);
    final controller = MockServices.container.read(
      workoutControllerProvider.notifier,
    );
    final exported = controller.exportWearableSession();
    expect(
      (((exported['exercises'] as List).first as Map)['sets'] as List)
          .first['done'],
      true,
    );
    expect((exported['exercises'] as List).first['wearableColor'], isA<int>());
  });

  test(
    'offline edits survive phone service restart and subsequent discard',
    () async {
      when(() => MockServices.databaseService.writeToOngoing(any())).thenAnswer(
        (invocation) => MockServices.database.setOngoing(
          invocation.positionalArguments.single as Map<String, dynamic>,
        ),
      );
      final transport = _CompanionTransport();
      final service = dataController(
        (ref) => WearableTrainingService(ref, transport: transport),
      );
      final source = WearableTrainingDocument.copy(session(status: 'active'));
      final sourceSets = source['exercises'][0]['sets'] as List;
      sourceSets.add({...sourceSets.first as Map, 'id': 'next-set'});
      source['cursor'] = sourceSets.first['id'];
      final initial = await service.receive(source);
      expect((initial['document'] as Map)['structures'], isNotEmpty);
      final offline = WearableTrainingDocument.copy(initial['document'] as Map);
      final sets = (offline['exercises'][0]['sets'] as List);
      final first = sets.first as Map;
      final changedAt = DateTime.now().millisecondsSinceEpoch;
      first['done'] = true;
      first['weight'] = 73.0;
      offline['sequence'] = (offline['sequence'] as int? ?? 0) + 1;
      offline['modified'] = changedAt;
      offline['cursor'] = 'next-set';
      offline['restStart'] = changedAt;
      offline['restEnd'] = changedAt + 120000;
      offline['stamps'] = {
        first['id']: {
          'time': changedAt,
          'device': 'watch',
          'sequence': offline['sequence'],
        },
      };
      // The phone restarts later with its old ongoing and journal. Its startup
      // capture must not invent newer set edits or a new structural version.
      await Future<void>.delayed(const Duration(milliseconds: 20));
      final controller = MockServices.container.read(
        workoutControllerProvider.notifier,
      );
      await controller.persist();
      final saved = await MockServices.database.watchOngoing().first;
      controller.restore(saved!, notifyNative: false);
      final restarted = dataController(
        (ref) => WearableTrainingService(ref, transport: _CompanionTransport()),
      );
      restarted.start();
      try {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        // Match the real iOS platform codec: every nested map has Object? keys,
        // even though the outer document is converted with Map.from.
        const codec = StandardMessageCodec();
        final native = Map<String, dynamic>.from(
          codec.decodeMessage(codec.encodeMessage(offline)) as Map,
        );
        final response = await restarted.receive(native);
        expect(response['accepted'], true);
        final merged = response['document'] as Map;
        expect(merged['exercises'][0]['sets'][0]['done'], true);
        expect(merged['exercises'][0]['sets'][0]['weight'], 73.0);
        expect(merged['cursor'], 'next-set');
        expect(merged['restEnd'], offline['restEnd']);
        offline['status'] = 'discarded';
        offline['end'] = DateTime.now().millisecondsSinceEpoch;
        expect((await restarted.receive(offline))['terminal'], true);
        expect(MockServices.container.read(workoutControllerProvider), isNull);
        expect(
          await WearableTrainingStore(
            MockServices.database,
          ).processed('guest', 'watch-session'),
          true,
        );
      } finally {
        restarted.dispose();
      }
    },
  );

  test(
    'native inbox merges offline Watch sets with a later phone set edit',
    () async {
      final service = dataController(
        (ref) => WearableTrainingService(
          ref,
          transport: AppleWatchTrainingTransport(),
        ),
      );
      final source = WearableTrainingDocument.copy(session(status: 'active'));
      final sets = source['exercises'][0]['sets'] as List;
      sets.add({...sets.first as Map, 'id': 'phone-set'});
      source['cursor'] = sets.first['id'];
      final adopted = await service.receive(source);
      final offline = WearableTrainingDocument.copy(adopted['document'] as Map);
      offline['exercises'][0]['sets'][0]['done'] = true;
      offline['exercises'][0]['sets'][0]['weight'] = 73.0;
      offline['sequence'] = (offline['sequence'] as int) + 1;
      offline['modified'] = DateTime.now().millisecondsSinceEpoch;
      offline['stamps'][sets.first['id']] = {
        'time': offline['modified'],
        'device': 'watch',
        'sequence': offline['sequence'],
      };
      final controller = MockServices.container.read(
        workoutControllerProvider.notifier,
      );
      expect(controller.moveSetCursorToNext(), true);
      controller.updateSetParameters(91.0, null, 8, null);
      final acknowledged = Completer<Map>();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(AppleWatchTrainingTransport.channel, (
            call,
          ) async {
            if (call.method == 'exchange') return [offline];
            if (call.method == 'acknowledge' && !acknowledged.isCompleted) {
              acknowledged.complete((call.arguments as Map)['response'] as Map);
            }
            return null;
          });
      service.start();
      try {
        final response = await acknowledged.future.timeout(
          const Duration(seconds: 2),
        );
        expect(response['accepted'], true);
        final exported = controller.exportWearableSession();
        expect(exported['exercises'][0]['sets'][0]['done'], true);
        expect(exported['exercises'][0]['sets'][0]['weight'], 73.0);
        expect(exported['exercises'][0]['sets'][1]['weight'], 91.0);
      } finally {
        service.dispose();
      }
    },
  );

  test(
    'failed model adoption does not publish an unadopted journal state',
    () async {
      final service = dataController(
        (ref) => WearableTrainingService(ref, transport: _CompanionTransport()),
      );
      final response = await service.receive(session(status: 'active'));
      final before = WearableTrainingDocument.copy(response['document'] as Map);
      final invalid = WearableTrainingDocument.copy(before);
      final set = invalid['exercises'][0]['sets'][0] as Map;
      set['weight'] = 'invalid-native-parameter';
      invalid['stamps'][set['id']] = {
        'time': DateTime.now().millisecondsSinceEpoch + 1000,
        'device': 'watch',
        'sequence': 2,
      };
      await expectLater(service.receive(invalid), throwsA(isA<TypeError>()));
      final stored = await WearableTrainingStore(
        MockServices.database,
      ).read('guest', 'watch-session');
      expect(
        WearableTrainingDocument.canonical(stored),
        WearableTrainingDocument.canonical(before),
      );
      final controller = MockServices.container.read(
        workoutControllerProvider.notifier,
      );
      expect(
        controller.exportWearableSession()['exercises'][0]['sets'][0]['weight'],
        0.0,
      );
    },
  );

  test('resuming the phone immediately drains the companion inbox', () async {
    final transport = _CompanionTransport();
    final service = dataController(
      (ref) => WearableTrainingService(ref, transport: transport),
    );
    service.start();
    try {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final before = transport.exchanges.length;
      for (final state in [
        AppLifecycleState.inactive,
        AppLifecycleState.hidden,
        AppLifecycleState.paused,
        AppLifecycleState.hidden,
        AppLifecycleState.inactive,
        AppLifecycleState.resumed,
      ]) {
        TestWidgetsFlutterBinding.instance.handleAppLifecycleStateChanged(
          state,
        );
      }
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(transport.exchanges.length, greaterThan(before));
    } finally {
      service.dispose();
    }
  });

  test('Android and macOS never contact the Watch channel', () async {
    var calls = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(AppleWatchTrainingTransport.channel, (
          _,
        ) async {
          calls++;
          throw MissingPluginException();
        });
    final service = dataController(
      (ref) => WearableTrainingService(
        ref,
        transport: const UnsupportedTrainingTransport(),
      ),
    );
    service.start();
    await Future<void>.delayed(const Duration(milliseconds: 20));
    service.dispose();
    expect(calls, 0);
  });

  for (final unavailable in [false, true]) {
    test(
      'iPhone without Watch tolerates ${unavailable ? "missing channel" : "empty inbox"}',
      () async {
        var calls = 0;
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(AppleWatchTrainingTransport.channel, (
              _,
            ) async {
              calls++;
              if (unavailable) throw MissingPluginException();
              return <dynamic>[];
            });
        final service = dataController(
          (ref) => WearableTrainingService(
            ref,
            transport: AppleWatchTrainingTransport(),
          ),
        );
        service.start();
        try {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          expect(calls, 1);
          expect(
            MockServices.container.read(workoutControllerProvider),
            isNull,
          );
        } finally {
          service.dispose();
        }
      },
    );
  }

  test('unresponsive exchange times out and permits a retry', () async {
    var calls = 0;
    final pending = Completer<dynamic>();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(AppleWatchTrainingTransport.channel, (_) {
          calls++;
          return calls == 1
              ? pending.future
              : Future<dynamic>.value(<dynamic>[]);
        });
    final service = dataController(
      (ref) => WearableTrainingService(
        ref,
        transport: AppleWatchTrainingTransport(),
      ),
    );
    service.start();
    try {
      await Future<void>.delayed(const Duration(milliseconds: 6300));
      expect(calls, greaterThanOrEqualTo(2));
      expect(MockServices.container.read(workoutControllerProvider), isNull);
    } finally {
      service.dispose();
      pending.complete(<dynamic>[]);
    }
  });

  test(
    'offline Watch completion preserves the phone workout name over its stale title',
    () async {
      final service = dataController(
        (ref) => WearableTrainingService(ref, transport: _CompanionTransport()),
      );
      final adopted = await service.receive(session(status: 'active'));
      final offline = WearableTrainingDocument.copy(adopted['document'] as Map);
      final controller = MockServices.container.read(
        workoutControllerProvider.notifier,
      );
      controller.setName('Allenamento rinominato sul telefono');
      // The disconnected Watch still carries the title received at adoption.
      expect(offline['name'], 'Watch workout');
      offline['status'] = 'completed';
      offline['end'] = (offline['time'] as int) + 60000;
      offline['modified'] = DateTime.now().millisecondsSinceEpoch + 1000;
      await service.receive(offline);
      await service.receive(offline);
      final history = await MockServices.database.getAllHistoryWorkoutsFuture();
      expect(history, hasLength(1));
      expect(history.single.name, 'Allenamento rinominato sul telefono');
    },
  );

  test(
    'unnamed phone workout completed offline gets the normal generated title',
    () async {
      final service = dataController(
        (ref) => WearableTrainingService(ref, transport: _CompanionTransport()),
      );
      final source = session(status: 'active')..['name'] = '';
      final adopted = await service.receive(source);
      final offline = WearableTrainingDocument.copy(adopted['document'] as Map);
      offline['status'] = 'completed';
      offline['end'] = (offline['time'] as int) + 60000;
      final response = await service.receive(offline);
      expect((response['document'] as Map)['name'], 'Chest Workout');
      await service.receive(offline);
      final history = await MockServices.database.getAllHistoryWorkoutsFuture();
      expect(history, hasLength(1));
      expect(history.single.name, 'Chest Workout');
    },
  );

  test(
    'unnamed workout with no exercises receives the generic localized title',
    () async {
      final service = dataController(
        (ref) => WearableTrainingService(ref, transport: _CompanionTransport()),
      );
      final source = session()
        ..['name'] = '   '
        ..['exercises'] = <dynamic>[];
      await service.receive(source);
      final history = await MockServices.database.getAllHistoryWorkoutsFuture();
      expect(history.single.name, 'Workout');
      expect(history.single.exercises, isEmpty);
    },
  );

  test(
    'unnamed Watch workout derives its title from superset exercises too',
    () async {
      final service = dataController(
        (ref) => WearableTrainingService(ref, transport: _CompanionTransport()),
      );
      final source = session()..['name'] = '';
      final shoulders = exerciseHelper(
        'shoulder-source',
        'Press',
      ).copyWith(primaryMuscleGroup: GTMuscleGroup.shoulders);
      await MockServices.database.insertCustomExercise(shoulders);
      source['exercises'] = [
        supersetHelper(
          'superset',
          exercises: [
            exerciseHelper('chest', 'Bench').copyWith(parentID: 'source'),
            shoulders.copyWith(id: 'shoulders', parentID: 'shoulder-source'),
          ],
        ).toJson(),
      ];
      await service.receive(source);
      final history = await MockServices.database.getAllHistoryWorkoutsFuture();
      expect(history.single.name, 'Chest and Shoulders Workout');
    },
  );

  test(
    'completed offline workout imports once without starting an ongoing',
    () async {
      final service = dataController(
        (ref) => WearableTrainingService(
          ref,
          transport: AppleWatchTrainingTransport(),
        ),
      );
      final document = WearableTrainingDocument.copy(session());
      expect((await service.receive(document))['accepted'], true);
      expect((await service.receive(document))['accepted'], true);
      final history = await MockServices.database.getAllHistoryWorkoutsFuture();
      expect(history, hasLength(1));
      expect(history.single.id, 'watch-session');
      expect(history.single.duration, const Duration(minutes: 1));
      expect(MockServices.container.read(workoutControllerProvider), isNull);
      verify(
        () => MockServices.routinesController.advanceProgressionsFromWorkout(
          any(),
        ),
      ).called(1);
    },
  );
  test(
    'Watch completion after phone takeover keeps runtime with stopped stopwatch',
    () async {
      final service = dataController(
        (ref) => WearableTrainingService(ref, transport: _CompanionTransport()),
      );
      final adopted = await service.receive(session(status: 'active'));
      final completed = WearableTrainingDocument.copy(
        adopted['document'] as Map,
      );
      expect(completed['globalStopwatchPaused'], true);
      expect(completed['globalStopwatchNominalDuration'], 0);
      completed['status'] = 'completed';
      completed['end'] = (completed['time'] as int) + 60_000;
      // Compatibility with the zero duration emitted by previous Watch builds.
      completed['duration'] = 0;
      await service.receive(completed);
      await service.receive(completed);
      final history = await MockServices.database.getAllHistoryWorkoutsFuture();
      expect(history.single.duration, const Duration(minutes: 1));
      final journal = await WearableTrainingStore(
        MockServices.database,
      ).read('guest', 'watch-session');
      expect(journal!['duration'], 60_000_000);
      verify(
        () => MockServices.routinesController.advanceProgressionsFromWorkout(
          any(),
        ),
      ).called(1);
    },
  );

  test(
    'late set reconciliation preserves saved duration instead of recalculating it',
    () async {
      final service = dataController(
        (ref) => WearableTrainingService(ref, transport: _CompanionTransport()),
      );
      final source = session()..['duration'] = 45_000_000;
      final response = await service.receive(source);
      final late = WearableTrainingDocument.copy(response['document'] as Map);
      late['status'] = 'active';
      final changed = late['exercises'][0]['sets'][0] as Map;
      changed['weight'] = 73.0;
      late['stamps'][changed['id']] = {
        'time': (source['end'] as int) - 1,
        'device': 'watch',
        'sequence': 2,
      };
      await service.receive(late);
      final history = await MockServices.database.getAllHistoryWorkoutsFuture();
      expect(history.single.duration, const Duration(seconds: 45));
      expect(history.single.exercises.first.sets.first.weight, 73.0);
      verify(
        () => MockServices.routinesController.advanceProgressionsFromWorkout(
          any(),
        ),
      ).called(1);
    },
  );

  test(
    'redelivery repairs a previously imported zero runtime without reapplying progression',
    () async {
      final service = dataController(
        (ref) => WearableTrainingService(ref, transport: _CompanionTransport()),
      );
      final response = await service.receive(session());
      final legacy = WearableTrainingDocument.copy(response['document'] as Map)
        ..['duration'] = 0;
      final history = await MockServices.database.getAllHistoryWorkoutsFuture();
      await MockServices.database.updateHistoryWorkout(
        history.single.copyWith(duration: Duration.zero),
      );
      await WearableTrainingStore(
        MockServices.database,
      ).write(legacy, processed: true);
      await service.receive(legacy);
      final repaired = await MockServices.database
          .getAllHistoryWorkoutsFuture();
      expect(repaired.single.duration, const Duration(minutes: 1));
      verify(
        () => MockServices.routinesController.advanceProgressionsFromWorkout(
          any(),
        ),
      ).called(1);
    },
  );

  test(
    'failed progression rolls back history and permits a clean retry',
    () async {
      final service = dataController(
        (ref) => WearableTrainingService(
          ref,
          transport: AppleWatchTrainingTransport(),
        ),
      );
      when(
        () => MockServices.routinesController.advanceProgressionsFromWorkout(
          any(),
        ),
      ).thenThrow(StateError('interrupted'));
      await expectLater(
        service.receive(WearableTrainingDocument.copy(session())),
        throwsStateError,
      );
      expect(
        await MockServices.database.getAllHistoryWorkoutsFuture(),
        isEmpty,
      );
      when(
        () => MockServices.routinesController.advanceProgressionsFromWorkout(
          any(),
        ),
      ).thenAnswer((_) async {});
      expect(
        (await service.receive(
          WearableTrainingDocument.copy(session()),
        ))['accepted'],
        true,
      );
      expect(
        await MockServices.database.getAllHistoryWorkoutsFuture(),
        hasLength(1),
      );
    },
  );
  test(
    'a different phone ongoing is preserved until a conflict is resolved',
    () async {
      final service = dataController(
        (ref) => WearableTrainingService(
          ref,
          transport: AppleWatchTrainingTransport(),
        ),
      );
      final controller = MockServices.container.read(
        workoutControllerProvider.notifier,
      );
      controller.start('Phone', null, null, saveInitial: false);
      final phoneID = controller.nativeWorkoutId;
      final response = await service.receive(
        WearableTrainingDocument.copy(session(status: 'active')),
      );
      expect(response['conflict'], true);
      expect(controller.nativeWorkoutId, phoneID);
      expect(controller.isActive, true);
    },
  );
  test('other account and unsupported protocol cannot import', () async {
    final service = dataController(
      (ref) => WearableTrainingService(
        ref,
        transport: AppleWatchTrainingTransport(),
      ),
    );
    expect(
      (await service.receive({
        ...session(),
        'ownerScope': 'user:other',
      }))['accepted'],
      false,
    );
    expect(
      (await service.receive({...session(), 'version': 99}))['accepted'],
      false,
    );
    expect(await MockServices.database.getAllHistoryWorkoutsFuture(), isEmpty);
  });
  test('discard is durable and never becomes a history workout', () async {
    final service = dataController(
      (ref) => WearableTrainingService(
        ref,
        transport: AppleWatchTrainingTransport(),
      ),
    );
    expect(
      (await service.receive(
        WearableTrainingDocument.copy(session(status: 'discarded')),
      ))['terminal'],
      true,
    );
    expect(
      (await service.receive(
        WearableTrainingDocument.copy(session()),
      ))['terminal'],
      true,
    );
    expect(await MockServices.database.getAllHistoryWorkoutsFuture(), isEmpty);
    verifyNever(
      () =>
          MockServices.routinesController.advanceProgressionsFromWorkout(any()),
    );
  });
  test(
    'takeover preserves identity and start; completion clears adopted ongoing',
    () async {
      final service = dataController(
        (ref) => WearableTrainingService(
          ref,
          transport: AppleWatchTrainingTransport(),
        ),
      );
      final active = WearableTrainingDocument.copy(session(status: 'active'));
      final response = await service.receive(active);
      expect(response['accepted'], true);
      final controller = MockServices.container.read(
        workoutControllerProvider.notifier,
      );
      expect(controller.nativeWorkoutId, 'watch-session');
      expect(controller.time.millisecondsSinceEpoch, active['time']);
      expect(
        MockServices.container
            .read(stopwatchControllerProvider.notifier)
            .globalStopwatch
            .isStopped,
        true,
      );
      expect(
        (await service.receive(
          WearableTrainingDocument.copy(session()),
        ))['terminal'],
        true,
      );
      expect(controller.isActive, false);
    },
  );
}
