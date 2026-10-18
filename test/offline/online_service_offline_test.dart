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
