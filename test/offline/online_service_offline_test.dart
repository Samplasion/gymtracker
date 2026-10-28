import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/service/online.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../test_helpers/mock_services.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class MockPostgrestFilterBuilder extends Mock
    implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {}

class MockPostgrestTransformBuilder extends Mock
    implements PostgrestTransformBuilder<List<Map<String, dynamic>>> {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockSupabaseClient mockSupabase;
  late MockGoTrueClient mockAuth;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late MockPostgrestFilterBuilder mockFilterBuilder;
  late MockPostgrestTransformBuilder mockTransformBuilder;

  setUp(() {
    MockServices.setup();
    mockSupabase = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    mockFilterBuilder = MockPostgrestFilterBuilder();
    mockTransformBuilder = MockPostgrestTransformBuilder();

    when(() => mockSupabase.auth).thenReturn(mockAuth);
    when(
      () => mockAuth.onAuthStateChange,
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => mockSupabase.from('profiles'),
    ).thenAnswer((_) => mockQueryBuilder);
    when(() => mockQueryBuilder.select()).thenAnswer((_) => mockFilterBuilder);
    when(
      () => mockFilterBuilder.eq('id', any()),
    ).thenAnswer((_) => mockFilterBuilder);
    when(
      () => mockFilterBuilder.limit(1),
    ).thenAnswer((_) => mockTransformBuilder);

    // Simulate network error on profiles query
    when(
      () => mockTransformBuilder.then<dynamic>(
        any(),
        onError: any(named: 'onError'),
      ),
    ).thenAnswer((invocation) {
      final onValue = invocation.positionalArguments[0];
      final onError = invocation.namedArguments[#onError] as Function?;
      return Future<List<Map<String, dynamic>>>.error(
        ClientException('Connection refused: Failed to connect to host'),
      ).then((val) => onValue(val), onError: onError);
    });
  });

  tearDown(() {
    MockServices.tearDown();
  });

  test(
    'disposing the service removes its auth listener and ignores later events',
    () async {
      final authEvents = StreamController<AuthState>.broadcast(sync: true);
      when(
        () => mockAuth.onAuthStateChange,
      ).thenAnswer((_) => authEvents.stream);
      final service = OnlineServiceImpl(mockSupabase);
      service.account = OnlineAccount(id: 'first', name: 'First');
      var changes = 0;
      service.addListener(() => changes++);
      expect(authEvents.hasListener, isTrue);
      authEvents.add(AuthState(AuthChangeEvent.signedOut, null));
      expect(service.account, isNull);
      expect(changes, 1);
      service.account = OnlineAccount(id: 'retained', name: 'Retained');
      service.dispose();
      service.dispose();
      await Future<void>.delayed(Duration.zero);
      expect(authEvents.hasListener, isFalse);
      authEvents.add(AuthState(AuthChangeEvent.signedOut, null));
      expect(service.account?.id, 'retained');
      expect(changes, 1);
      await authEvents.close();
    },
  );

  test(
    'retryable auth errors retain the account and allow later auth events',
    () async {
      final authEvents = StreamController<AuthState>.broadcast(sync: true);
      addTearDown(authEvents.close);
      when(
        () => mockAuth.onAuthStateChange,
      ).thenAnswer((_) => authEvents.stream);
      final service = OnlineServiceImpl(mockSupabase);
      addTearDown(service.dispose);
      final account = OnlineAccount(id: 'retained', name: 'Retained');
      service.account = account;
      var changes = 0;
      service.addListener(() => changes++);

      authEvents.addError(
        AuthRetryableFetchException(
          message: 'ClientException: Bad file descriptor',
        ),
        StackTrace.current,
      );
      await Future<void>.delayed(Duration.zero);

      expect(service.account, same(account));
      expect(changes, 0);
      expect(authEvents.hasListener, isTrue);

      authEvents.add(AuthState(AuthChangeEvent.signedOut, null));
      expect(service.account, isNull);
      expect(changes, 1);
    },
  );

  for (final replacement in <String?>[null, 'B', 'A', 'B-pending', 'refresh']) {
    for (final fails in [false, true]) {
      test(
        'late profile ${fails ? 'failure' : 'success'} preserves session after A switches to $replacement',
        () async {
          User user(String id) => User(
            id: id,
            appMetadata: {},
            userMetadata: {'username': id},
            aud: 'authenticated',
            createdAt: '2026-01-01',
          );
          User? current = user('A');
          final events = StreamController<AuthState>.broadcast(sync: true);
          final pending = Completer<List<Map<String, dynamic>>>();
          when(() => mockAuth.currentUser).thenAnswer((_) => current);
          when(
            () => mockAuth.onAuthStateChange,
          ).thenAnswer((_) => events.stream);
          when(
            () => mockTransformBuilder.then<dynamic>(
              any(),
              onError: any(named: 'onError'),
            ),
          ).thenAnswer((invocation) {
            final onValue = invocation.positionalArguments[0];
            final onError = invocation.namedArguments[#onError] as Function?;
            return pending.future.then(
              (value) => onValue(value),
              onError: onError,
            );
          });
          final service = OnlineServiceImpl(mockSupabase);
          addTearDown(() async {
            service.dispose();
            await events.close();
          });
          final original = OnlineAccount(id: 'A', name: 'A');
          service.account = original;
          final request = service.getAccount();
          await Future<void>.delayed(Duration.zero);
          final unpopulated = replacement == 'B-pending';
          final refresh = replacement == 'refresh';
          current = replacement == null
              ? null
              : user(
                  unpopulated
                      ? 'B'
                      : refresh
                      ? 'A'
                      : replacement,
                );
          if (unpopulated || refresh) {
            events.add(
              AuthState(
                refresh
                    ? AuthChangeEvent.tokenRefreshed
                    : AuthChangeEvent.signedIn,
                Session(
                  accessToken: 'token',
                  tokenType: 'bearer',
                  user: current!,
                ),
              ),
            );
          } else {
            events.add(AuthState(AuthChangeEvent.signedOut, null));
          }
          final expected = unpopulated || refresh
              ? original
              : replacement == null
              ? null
              : OnlineAccount(id: replacement, name: replacement);
          service.account = expected;
          var changes = 0;
          service.addListener(() => changes++);
          if (fails) {
            pending.completeError(ClientException('Connection refused'));
          } else {
            pending.complete([
              {'username': 'A'},
            ]);
          }
          final result = await request;
          if (refresh && !fails) {
            expect(result?.id, 'A');
            expect(result, isNot(same(original)));
            expect(service.account, same(result));
            expect(changes, 1);
          } else {
            expect(result, unpopulated ? isNull : same(expected));
            expect(service.account, same(expected));
            expect(changes, 0);
          }
        },
      );
    }
  }

  group('OnlineServiceImpl Offline Behavior Tests', () {
    test(
      'getAccount() should catch ClientException and return cached _account when offline',
      () async {
        final dummyUser = User(
          id: 'user_123',
          appMetadata: {},
          userMetadata: {'username': 'testuser'},
          aud: 'authenticated',
          createdAt: '2026-01-01',
        );
        when(() => mockAuth.currentUser).thenReturn(dummyUser);

        final service = OnlineServiceImpl(mockSupabase);

        // Populate in-memory account as if logged in previously
        final cachedAccount = OnlineAccount(
          id: dummyUser.id,
          email: 'test@example.com',
          name: 'testuser',
          fullName: 'Test User',
        );
        service.account = cachedAccount;

        expect(
          service.getAccount(),
          completion(equals(cachedAccount)),
          reason:
              'getAccount() rethrows ClientException instead of returning cached account',
        );
      },
    );

    test(
      'getAccount() should not return null or rethrow when cold-booting offline with valid session',
      () async {
        final dummyUser = User(
          id: 'user_cold_boot',
          appMetadata: {},
          userMetadata: {
            'username': 'offline_user',
            'full_name': 'Offline Hero',
          },
          aud: 'authenticated',
          createdAt: '2026-01-01',
        );
        when(() => mockAuth.currentUser).thenReturn(dummyUser);

        // Cold boot: service has no cached in-memory account yet
        final service = OnlineServiceImpl(mockSupabase);
        expect(service.account, isNull);

        expect(
          service.getAccount(),
          completion(isNotNull),
          reason:
              'getAccount() rethrows ClientException on cold boot offline instead of synthesizing fallback',
        );
      },
    );
  });
}
