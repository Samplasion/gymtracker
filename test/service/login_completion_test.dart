import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/service/online.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MemoryStorage extends GotrueAsyncStorage {
  final values = <String, String>{};
  @override
  Future<String?> getItem({required String key}) async => values[key];
  @override
  Future<void> setItem({required String key, required String value}) async {
    values[key] = value;
  }

  @override
  Future<void> removeItem({required String key}) async {
    values.remove(key);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final operation in ['login', 'register']) {
    for (final profile in [
      'ready',
      'offline',
      if (operation == 'register') 'confirmation',
    ]) {
      test(
        '$operation completes with profile $profile using the real auth SDK',
        () async {
          final user = {
            'id': 'user-a',
            'aud': 'authenticated',
            'email': 'me@example.com',
            'created_at': '2026-01-01T00:00:00Z',
            'app_metadata': <String, dynamic>{},
            'user_metadata': {'username': 'mario'},
          };
          final client = SupabaseClient(
            'https://example.supabase.co',
            'test-anon-key',
            authOptions: AuthClientOptions(
              autoRefreshToken: false,
              pkceAsyncStorage: _MemoryStorage(),
            ),
            httpClient: MockClient((request) async {
              if (request.url.path == '/auth/v1/token' ||
                  request.url.path == '/auth/v1/signup') {
                if (profile == 'confirmation') {
                  return http.Response(
                    jsonEncode(user),
                    200,
                    request: request,
                    headers: {'content-type': 'application/json'},
                  );
                }
                return http.Response(
                  jsonEncode({
                    'access_token': 'test-access-token',
                    'refresh_token': 'test-refresh-token',
                    'token_type': 'bearer',
                    'expires_in': 3600,
                    'user': user,
                  }),
                  200,
                  request: request,
                  headers: {'content-type': 'application/json'},
                );
              }
              if (request.url.path == '/rest/v1/profiles') {
                if (request.url.queryParameters.containsKey('username')) {
                  return http.Response(
                    'null',
                    200,
                    request: request,
                    headers: {'content-type': 'application/json'},
                  );
                }
                if (profile == 'offline') {
                  throw http.ClientException('offline');
                }
                return http.Response(
                  jsonEncode([
                    {'id': 'user-a', 'username': 'mario'},
                  ]),
                  200,
                  request: request,
                  headers: {'content-type': 'application/json'},
                );
              }
              fail('Unexpected request: ${request.url.path}');
            }),
          );
          final service = OnlineServiceImpl.withAchievementCatalog(
            client: client,
            achievementCatalog: () => {},
          );
          addTearDown(() async {
            service.dispose();
            await client.dispose();
          });
          if (operation == 'login') {
            await service.login(
              email: 'me@example.com',
              password: 'Password123!',
            );
          } else {
            await service.register(
              email: 'me@example.com',
              password: 'Password123!',
              username: 'mario',
            );
          }
          expect(
            client.auth.currentUser?.id,
            profile == 'confirmation' ? null : 'user-a',
          );
          expect(
            service.account?.id,
            profile == 'confirmation' ? null : 'user-a',
          );
        },
      );
    }
  }
}
