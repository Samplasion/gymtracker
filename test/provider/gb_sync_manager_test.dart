import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/provider/events.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../test_helpers/mock_services.dart';

class MockGTDatabase extends Mock implements GTDatabase {}
class MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late EventBus eventBus;
  late MockGTDatabase mockDb;
  late MockSupabaseClient mockSupabase;

  setUp(() {
    MockServices.setup();
    eventBus = EventBus();
    mockDb = MockGTDatabase();
    mockSupabase = MockSupabaseClient();
  });

  tearDown(() {
    MockServices.tearDown();
  });

  group('GBSyncManager', () {
    test('initializes with default drainCheckInterval', () {
      final manager = GBSyncManager(
        localDatabase: mockDb,
        supabaseClient: mockSupabase,
        eventBus: eventBus,
      );
      expect(
        manager.drainCheckInterval,
        equals(const Duration(milliseconds: 100)),
      );
      expect(manager.isSyncingTables, isFalse);
      expect(manager.isSyncingAny, isFalse);
    });

    test('waitForAllTables completes when queues are empty', () async {
      final manager = GBSyncManager(
        localDatabase: mockDb,
        supabaseClient: mockSupabase,
        eventBus: eventBus,
        drainCheckInterval: const Duration(milliseconds: 10),
      );

      expect(manager.isSyncingFromBackend, isFalse);
      expect(manager.isSyncingToBackend, isFalse);

      await manager.waitForAllTables();
      expect(manager.isSyncingAny, isFalse);
    });

    test('syncTables emits GBSyncStartedEvent and GBSyncFinishedEvent with timestamp', () async {
      final manager = GBSyncManager(
        localDatabase: mockDb,
        supabaseClient: mockSupabase,
        eventBus: eventBus,
        drainCheckInterval: const Duration(milliseconds: 10),
      );

      final events = <GBEvent>[];
      eventBus.on<GBSyncStartedEvent>().listen(events.add);
      eventBus.on<GBSyncFinishedEvent>().listen(events.add);

      await manager.syncTables();
      await pumpEventQueue();

      expect(events.length, equals(2));
      expect(events[0], isA<GBSyncStartedEvent>());
      expect(events[1], isA<GBSyncFinishedEvent>());
      final finished = events[1] as GBSyncFinishedEvent;
      expect(finished.lastSync, isNotNull);
      expect(
        finished.lastSync!.isBefore(
          DateTime.now().add(const Duration(seconds: 1)),
        ),
        isTrue,
      );
    });

    test('syncTables does not start duplicate sync if already running', () async {
      final manager = GBSyncManager(
        localDatabase: mockDb,
        supabaseClient: mockSupabase,
        eventBus: eventBus,
        drainCheckInterval: const Duration(milliseconds: 10),
      );

      final events = <GBEvent>[];
      eventBus.on<GBSyncStartedEvent>().listen(events.add);
      eventBus.on<GBSyncFinishedEvent>().listen(events.add);

      // Run concurrent sync calls
      await Future.wait([manager.syncTables(), manager.syncTables()]);
      await pumpEventQueue();

      // Only one sync lifecycle should run
      expect(events.whereType<GBSyncStartedEvent>().length, equals(1));
      expect(events.whereType<GBSyncFinishedEvent>().length, equals(1));
    });

    test('automatic sync tracking emits start and finish events', () async {
      final manager = _TestGBSyncManager(
        localDatabase: mockDb,
        supabaseClient: mockSupabase,
        eventBus: eventBus,
        drainCheckInterval: const Duration(milliseconds: 10),
      );

      final events = <GBEvent>[];
      eventBus.on<GBSyncStartedEvent>().listen(events.add);
      eventBus.on<GBSyncFinishedEvent>().listen(events.add);

      manager.setUserId('user_123');
      manager.enableSync();

      await Future<void>.delayed(const Duration(milliseconds: 50));
      await pumpEventQueue();

      expect(events.any((e) => e is GBSyncStartedEvent), isTrue);
      expect(events.any((e) => e is GBSyncFinishedEvent), isTrue);
      final finishEvent = events.firstWhere((e) => e is GBSyncFinishedEvent) as GBSyncFinishedEvent;
      expect(finishEvent.lastSync, isNotNull);
    });

    test('syncTables emits GBSyncErrorEvent and GBSyncFinishedEvent with null lastSync on failure', () async {
      final manager = _FailingGBSyncManager(
        localDatabase: mockDb,
        supabaseClient: mockSupabase,
        eventBus: eventBus,
      );

      final events = <GBEvent>[];
      eventBus.on<GBSyncStartedEvent>().listen(events.add);
      eventBus.on<GBSyncErrorEvent>().listen(events.add);
      eventBus.on<GBSyncFinishedEvent>().listen(events.add);

      expect(() => manager.syncTables(), throwsException);
      await pumpEventQueue();

      expect(events.length, equals(3));
      expect(events[0], isA<GBSyncStartedEvent>());
      expect(events[1], isA<GBSyncErrorEvent>());
      expect(events[2], isA<GBSyncFinishedEvent>());
      final errorEvent = events[1] as GBSyncErrorEvent;
      expect(errorEvent.error.toString(), contains('Simulated network failure'));
      final finished = events[2] as GBSyncFinishedEvent;
      expect(finished.lastSync, isNull);
    });
  });
}

class _FailingGBSyncManager extends GBSyncManager {
  _FailingGBSyncManager({
    required super.localDatabase,
    required super.supabaseClient,
    required super.eventBus,
  });

  @override
  Future<void> waitForAllTables({Duration timeout = const Duration(seconds: 30)}) {
    throw Exception('Simulated network failure');
  }
}

class _TestGBSyncManager extends GBSyncManager {
  _TestGBSyncManager({
    required super.localDatabase,
    required super.supabaseClient,
    required super.eventBus,
    super.drainCheckInterval,
  });

  bool _syncingEnabled = false;
  String _testUserId = '';
  int _fakeFullSyncs = 0;

  @override
  int get nFullSyncs => _fakeFullSyncs;

  @override
  bool get syncingEnabled => _syncingEnabled;

  @override
  String get userId => _testUserId;

  @override
  void setUserId(String value) {
    if (_testUserId == value) return;
    final hadUser = _testUserId.isNotEmpty;
    _testUserId = value;
    final startSyncs = nFullSyncs;
    if (hadUser && _syncingEnabled && value.isNotEmpty) {
      trackAutomaticSync(startSyncs);
      _fakeFullSyncs++;
    }
  }

  @override
  void enableSync() {
    if (_syncingEnabled) return;
    _syncingEnabled = true;
    final startSyncs = nFullSyncs;
    if (_testUserId.isNotEmpty) {
      trackAutomaticSync(startSyncs);
      _fakeFullSyncs++;
    }
  }

  void triggerAutoSync() {
    final startSyncs = nFullSyncs;
    trackAutomaticSync(startSyncs);
    _fakeFullSyncs++;
  }
}
