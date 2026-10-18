import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/model/routines.dart';
import 'package:gymtracker/provider/events.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../test_helpers/mock_services.dart';

class MockGTDatabase extends Mock implements GTDatabase {}

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class MockPostgrestFilterBuilder extends Mock
    implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {}

class MockPostgrestTransformBuilder extends Mock
    implements PostgrestTransformBuilder<List<Map<String, dynamic>>> {}

class MockRealtimeChannel extends Mock implements RealtimeChannel {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(PostgresChangeEvent.all);
    registerFallbackValue(
      PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'user_id',
        value: '',
      ),
    );
    registerFallbackValue((PostgresChangePayload payload) {});
  });

  late EventBus eventBus;
  late MockSupabaseClient mockSupabase;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late MockPostgrestFilterBuilder mockFilterBuilder;
  late MockPostgrestTransformBuilder mockTransformBuilder;
  late MockRealtimeChannel mockChannel;

  setUp(() {
    MockServices.setup();
    eventBus = EventBus();
    mockSupabase = MockSupabaseClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    mockFilterBuilder = MockPostgrestFilterBuilder();
    mockTransformBuilder = MockPostgrestTransformBuilder();
    mockChannel = MockRealtimeChannel();

    when(() => mockSupabase.from(any())).thenAnswer((_) => mockQueryBuilder);
    when(() => mockSupabase.channel(any())).thenReturn(mockChannel);
    when(
      () => mockChannel.onPostgresChanges(
        event: any(named: 'event'),
        schema: any(named: 'schema'),
        table: any(named: 'table'),
        filter: any(named: 'filter'),
        callback: any(named: 'callback'),
      ),
    ).thenReturn(mockChannel);
    when(() => mockChannel.subscribe(any(), any())).thenReturn(mockChannel);

    when(
      () => mockQueryBuilder.select(any()),
    ).thenAnswer((_) => mockFilterBuilder);
    when(
      () => mockFilterBuilder.eq(any(), any()),
    ).thenAnswer((_) => mockFilterBuilder);
    when(
      () => mockFilterBuilder.range(any(), any()),
    ).thenAnswer((_) => mockFilterBuilder);
    when(
      () => mockFilterBuilder.order(
        any(),
        ascending: any(named: 'ascending'),
        nullsFirst: any(named: 'nullsFirst'),
        referencedTable: any(named: 'referencedTable'),
      ),
    ).thenAnswer((_) => mockTransformBuilder);

    // When transform builder is awaited, it throws ClientException simulating no internet
    when(
      () => mockTransformBuilder.then<dynamic>(
        any(),
        onError: any(named: 'onError'),
      ),
    ).thenAnswer((invocation) {
      final onValue = invocation.positionalArguments[0];
      final onError = invocation.namedArguments[#onError] as Function?;
      return Future<List<Map<String, dynamic>>>.error(
        ClientException('No internet connection'),
      ).then((val) => onValue(val), onError: onError);
    });
  });

  tearDown(() {
    MockServices.tearDown();
  });

  group('SyncManager Offline Behavior Tests', () {
    test(
      'enableSync() should handle offline without escaping unhandled errors into Zone',
      () async {
        final manager = GBSyncManager(
          localDatabase: MockServices.database,
          supabaseClient: mockSupabase,
          eventBus: eventBus,
        );

        manager.registerSyncable<RoutineFolder>(
          backendTable: 'routine_folders',
          fromJson: RoutineFolder.fromJson,
          companionConstructor: RoutineFoldersCompanion.new,
        );
        manager.setUserId('user_123');

        Object? uncaughtZoneError;
        final completer = Completer<void>();

        runZonedGuarded(
          () {
            // Expected behavior: enableSync() should handle offline states without leaking
            // unhandled asynchronous exceptions into the ambient zone.
            manager.enableSync();

            Future.delayed(const Duration(milliseconds: 100), () {
              if (!completer.isCompleted) completer.complete();
            });
          },
          (error, stack) {
            uncaughtZoneError = error;
            if (!completer.isCompleted) completer.complete();
          },
        );

        await completer.future;

        // CURRENTLY FAILS: SyncManager._onDependenciesChanged is unawaited and
        // has no try/catch, so it escapes as an uncaught ClientException into the Zone.
        expect(
          uncaughtZoneError,
          isNull,
          reason:
              'enableSync() leaked an unhandled asynchronous error into the Zone when offline: $uncaughtZoneError',
        );
      },
    );

    test(
      'enableSync reports an offline error without throwing to the caller',
      () async {
        final manager = GBSyncManager(
          localDatabase: MockServices.database,
          supabaseClient: mockSupabase,
          eventBus: eventBus,
        );

        manager.registerSyncable<RoutineFolder>(
          backendTable: 'routine_folders',
          fromJson: RoutineFolder.fromJson,
          companionConstructor: RoutineFoldersCompanion.new,
        );
        manager.setUserId('user_123');

        final errors = <GBSyncErrorEvent>[];
        final errorSub = eventBus.on<GBSyncErrorEvent>().listen(errors.add);
        addTearDown(errorSub.cancel);
        Object? caughtInTryCatch;
        Object? leakedToZone;
        final completer = Completer<void>();

        runZonedGuarded(
          () {
            try {
              // Caller attempts to protect app with try/catch
              manager.enableSync();
            } catch (e) {
              caughtInTryCatch = e;
            }

            Future.delayed(const Duration(milliseconds: 100), () {
              if (!completer.isCompleted) completer.complete();
            });
          },
          (error, stack) {
            leakedToZone = error;
            if (!completer.isCompleted) completer.complete();
          },
        );

        await completer.future;

        expect(
          caughtInTryCatch,
          isNull,
          reason: 'Offline errors must be reported without crashing the caller',
        );
        expect(leakedToZone, isNull);
        expect(errors, isNotEmpty);
        expect(errors.first.error, isA<ClientException>());
      },
    );

    test(
      'setUserId() should not leak unhandled asynchronous errors into Zone when offline',
      () async {
        final manager = GBSyncManager(
          localDatabase: MockServices.database,
          supabaseClient: mockSupabase,
          eventBus: eventBus,
        );

        manager.registerSyncable<RoutineFolder>(
          backendTable: 'routine_folders',
          fromJson: RoutineFolder.fromJson,
          companionConstructor: RoutineFoldersCompanion.new,
        );

        Object? uncaughtZoneError;
        final completer = Completer<void>();

        runZonedGuarded(
          () {
            manager.enableSync();
            // Setting user ID when syncing is enabled triggers _onDependenciesChanged
            manager.setUserId('user_456');

            Future.delayed(const Duration(milliseconds: 100), () {
              if (!completer.isCompleted) completer.complete();
            });
          },
          (error, stack) {
            uncaughtZoneError = error;
            if (!completer.isCompleted) completer.complete();
          },
        );

        await completer.future;

        // CURRENTLY FAILS: setUserId triggers unawaited _onDependenciesChanged
        // which throws uncaught ClientException into the Zone.
        expect(
          uncaughtZoneError,
          isNull,
          reason:
              'setUserId() leaked an unhandled error into the Zone when offline: $uncaughtZoneError',
        );
      },
    );

    test(
      'syncTables() should not rethrow network errors to caller when offline',
      () async {
        final manager = _FailingSyncGBSyncManager(
          localDatabase: MockServices.database,
          supabaseClient: mockSupabase,
          eventBus: eventBus,
        );
        manager.setUserId('user_123');

        // Resilient offline sync should absorb or report the error safely
        // CURRENTLY FAILS: GBSyncManager.syncTables explicitly rethrows network exceptions
        expect(
          manager.syncTables(),
          completes,
          reason:
              'syncTables() rethrows network exceptions directly to callers',
        );
      },
    );
  });
}

class _FailingSyncGBSyncManager extends GBSyncManager {
  _FailingSyncGBSyncManager({
    required super.localDatabase,
    required super.supabaseClient,
    required super.eventBus,
  });

  @override
  Future<void> waitForAllTables({
    Duration timeout = const Duration(seconds: 30),
  }) async {
    throw ClientException('Connection refused');
  }
}
