import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/provider/friend.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    // Return 503 immediately simulating backend unreachable when offline
    final offlineHttpClient = MockClient((request) async {
      return Response(
        jsonEncode({'message': 'Network unreachable: offline'}),
        503,
        headers: {'content-type': 'application/json'},
      );
    });

    try {
      await Supabase.initialize(
        url: 'https://test.supabase.co',
        anonKey: 'fake-anon-key',
        httpClient: offlineHttpClient,
      );
    } catch (_) {
      // Already initialized
    }

    final fakeSession = jsonEncode({
      'access_token': 'fake-token',
      'token_type': 'bearer',
      'user': {
        'id': 'user-123',
        'app_metadata': {},
        'user_metadata': {},
        'aud': 'authenticated',
        'created_at': '2026-01-01T00:00:00Z',
      },
    });

    try {
      await Supabase.instance.client.auth.recoverSession(fakeSession);
    } catch (_) {}
  });

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  test(
    'FriendNotifier should provide cached or empty FriendState when offline instead of throwing PostgrestException',
    () async {
      await expectLater(
        container.read(friendProvider.future),
        completes,
        reason:
            'FriendNotifier crashes when device is offline instead of returning cached/fallback state',
      );
    },
  );
}
