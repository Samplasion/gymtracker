import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/provider/social.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  var contents = 0;
  Completer<void>? sourceResponse;
  late SupabaseClient client;
  setUp(() {
    contents = 0;
    sourceResponse = null;
    client = SupabaseClient(
      'https://social.test',
      'key',
      authOptions: const AuthClientOptions(autoRefreshToken: false),
      httpClient: MockClient((request) async {
        expect(request.url.path, endsWith('/rpc/get_source_social'));
        contents++;
        await sourceResponse?.future;
        return Response(
          jsonEncode({
            'post': {'id': 'post', 'active': true},
            'likes': contents,
            'comments': 2,
            'liked': false,
          }),
          200,
          request: request,
          headers: {'content-type': 'application/json'},
        );
      }),
    );
  });
  tearDown(() => client.dispose());

  const source = (owner: 'friend', source: 'workout', kind: 'workout');
  ProviderContainer socialContainer() => ProviderContainer(
    overrides: [
      socialClientProvider.overrideWithValue(client),
      sourcePublicationPendingProvider(
        source,
      ).overrideWith((ref) => Stream.value(false)),
      currentUserIdProvider.overrideWithValue('owner'),
    ],
  );

  test(
    'scrolling away and back reuses counts; explicit refresh reloads',
    () async {
      final c = socialContainer();
      addTearDown(c.dispose);
      final provider = sourceSocialProvider(source);
      final first = c.listen(provider, (_, _) {});
      final counts = await c.read(provider.future);
      expect(contents, 1);
      first.close();
      await c.pump();
      final second = c.listen(provider, (_, _) {});
      expect(c.read(provider).value, same(counts));
      expect(await c.read(provider.future), same(counts));
      expect(contents, 1);
      c.invalidate(provider);
      expect((await c.read(provider.future))?['likes'], 2);
      expect(contents, 2);
      second.close();
    },
  );

  test('scrolling during a request does not start a second request', () async {
    sourceResponse = Completer<void>();
    final c = socialContainer();
    addTearDown(c.dispose);
    final provider = sourceSocialProvider(source);
    final first = c.listen(provider, (_, _) {});
    await pumpEventQueue();
    expect(contents, 1);
    first.close();
    await c.pump();
    final second = c.listen(provider, (_, _) {});
    sourceResponse!.complete();
    expect((await c.read(provider.future))?['comments'], 2);
    expect(contents, 1);
    second.close();
  });

  test(
    'cached offscreen counts are discarded when the account changes',
    () async {
      final c = socialContainer();
      addTearDown(c.dispose);
      final provider = sourceSocialProvider(source);
      final first = c.listen(provider, (_, _) {});
      await c.read(provider.future);
      first.close();
      await c.pump();
      c.updateOverrides([
        socialClientProvider.overrideWithValue(client),
        sourcePublicationPendingProvider(
          source,
        ).overrideWith((ref) => Stream.value(false)),
        currentUserIdProvider.overrideWithValue(null),
      ]);
      await c.pump();
      expect(await c.read(provider.future), isNull);
      c.updateOverrides([
        socialClientProvider.overrideWithValue(client),
        sourcePublicationPendingProvider(
          source,
        ).overrideWith((ref) => Stream.value(false)),
        currentUserIdProvider.overrideWithValue('other'),
      ]);
      final second = c.listen(provider, (_, _) {});
      expect((await c.read(provider.future))?['likes'], 2);
      expect(contents, 2);
      second.close();
    },
  );
}
