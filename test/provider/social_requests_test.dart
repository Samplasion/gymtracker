import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/provider/friend.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/service/online.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../test_helpers/mock_services.dart';

class _Online extends Online {
  @override
  OnlineAccount? build() => OnlineAccount(id: 'owner', name: 'Owner');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  var profiles = 0, contents = 0;
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'https://social.test',
      anonKey: 'key',
      httpClient: MockClient((r) async {
        Object response = [];
        if (r.url.path.endsWith('/profiles')) {
          profiles++;
          response = [
            for (final id in ['a', 'b', 'c'])
              {
                'id': id,
                'username': 'User $id',
                'full_name': 'Name $id',
                'updated_at': '2026-10-20T00:00:00Z',
              },
          ];
        } else if (r.url.path.contains('/rpc/')) {
          contents++;
        }
        return Response(
          jsonEncode(response),
          200,
          request: r,
          headers: {'content-type': 'application/json'},
        );
      }),
    );
    await Supabase.instance.client.auth.recoverSession(
      jsonEncode({
        'access_token': 'fake',
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
  });
  setUp(() {
    MockServices.setup();
    profiles = 0;
    contents = 0;
  });
  tearDown(() => MockServices.tearDown());
  test('names share a batch and never fetch public content', () async {
    final c = ProviderContainer(
      overrides: [
        onlineProvider.overrideWith(_Online.new),
        currentUserIdProvider.overrideWithValue('owner'),
      ],
    );
    addTearDown(c.dispose);
    await c.read(friendProvider.future);
    final social = c.read(friendProvider.notifier);
    final names = await Future.wait([
      social.getIdentity('a'),
      social.getIdentity('a'),
      social.getIdentity('b'),
      social.getIdentity('c'),
    ]);
    expect(names.map((n) => n.fullName), [
      'Name a',
      'Name a',
      'Name b',
      'Name c',
    ]);
    expect(profiles, 1);
    expect(contents, 0);
    await social.getIdentity('a');
    expect(profiles, 1);
    final first = await social.getAvatar('a');
    final second = await social.getAvatar('a');
    expect(first, second);
    expect(first, contains('v='));
    expect(profiles, 1);
    expect(contents, 0);
  });
}
