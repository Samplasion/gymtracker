import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/provider/friend.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/provider/feed.dart';
import 'package:gymtracker/provider/connectivity.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/model/achievements.dart';
import 'package:gymtracker/service/online.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../test_helpers/mock_services.dart';

class _Online extends Online {
  @override
  OnlineService get onlineService => TestOnlineServiceImpl();
  @override
  OnlineAccount? build() => OnlineAccount(id: 'owner', name: 'Owner');

  void updateIdentity() => state = AsyncData(
    OnlineAccount(
      id: 'owner',
      name: 'Updated owner',
      fullName: 'Updated name',
      updatedAt: 'new',
    ),
  );
}

class _Connectivity extends NetworkConnectivityNotifier {
  @override
  Stream<bool> build() => Stream.value(false);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  var profiles = 0, contents = 0;
  var relationReads = 0, mutations = 0;
  Uri? lastDelete;
  final relations = <Map<String, dynamic>>[];
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'https://social.test',
      anonKey: 'key',
      httpClient: MockClient((r) async {
        Object response = [];
        if (r.url.path.endsWith('/friends')) {
          if (r.method == 'GET') {
            relationReads++;
            response = relations;
          } else {
            mutations++;
            if (r.method == 'POST') {
              relations.add(
                Map<String, dynamic>.from(jsonDecode(r.body) as Map),
              );
            } else if (r.method == 'PATCH') {
              for (final relation in relations) {
                relation['status'] = 'accepted';
              }
            } else if (r.method == 'DELETE') {
              lastDelete = r.url;
              relations.clear();
            }
            response = r.method == 'DELETE' ? [] : relations;
          }
        } else if (r.url.path.endsWith('/profiles')) {
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
          response = {
            'achievements': [],
            'workouts': [],
            'exercises': [],
            'friend_count': 1,
          };
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
    relationReads = 0;
    mutations = 0;
    lastDelete = null;
    relations.clear();
  });
  tearDown(() => MockServices.tearDown());
  test(
    'feed observes relationship changes without fetching relationships on startup',
    () async {
      final history = BehaviorSubject<List<Workout>>.seeded([]);
      final completions = BehaviorSubject<List<AchievementCompletion>>.seeded(
        [],
      );
      addTearDown(history.close);
      addTearDown(completions.close);
      when(
        () => MockServices.databaseService.history$,
      ).thenAnswer((_) => history);
      when(
        () => MockServices.databaseService.completions$,
      ).thenAnswer((_) => completions);
      when(
        () => MockServices.achievementsController.completionStream,
      ).thenAnswer((_) => completions.stream);
      final c = ProviderContainer(
        overrides: [
          onlineProvider.overrideWith(_Online.new),
          currentUserIdProvider.overrideWithValue('owner'),
          networkConnectivityProvider.overrideWith(_Connectivity.new),
        ],
      );
      addTearDown(c.dispose);
      c.listen(feedProvider, (_, _) {});
      await c.read(feedProvider.future);
      expect(relationReads, 0);
      c.read(friendshipChangesProvider.notifier).publish({});
      await c.pump();
      expect(c.read(feedProvider).hasError, isFalse);
      expect(relationReads, 0);
    },
  );
  for (final action in ['send', 'accept', 'decline', 'remove', 'cancel']) {
    test(
      'active profile updates without circular dependencies after $action',
      () async {
        if (action != 'send') {
          relations.add({
            'sender_id': action == 'cancel' ? 'owner' : 'a',
            'receiver_id': action == 'cancel' ? 'a' : 'owner',
            'status': action == 'remove' ? 'accepted' : 'pending',
          });
        }
        final c = ProviderContainer(
          overrides: [
            onlineProvider.overrideWith(_Online.new),
            currentUserIdProvider.overrideWithValue('owner'),
          ],
        );
        addTearDown(c.dispose);
        c.listen(friendPublicDataProvider('a'), (_, _) {});
        c.listen(friendPublicDataProvider('c'), (_, _) {});
        await c.read(friendProvider.future);
        await c.read(friendPublicDataProvider('a').future);
        final other = await c.read(friendPublicDataProvider('c').future);
        final reads = relationReads;
        final social = c.read(friendProvider.notifier);
        switch (action) {
          case 'send':
            await social.sendFriendRequest('a');
          case 'accept':
            await social.acceptFriendRequest('a');
          case 'decline':
            await social.declineFriendRequest('a');
          case 'remove':
            await social.unfriend('a');
          case 'cancel':
            await social.cancelFriendRequest('a');
            expect(lastDelete!.queryParameters['sender_id'], 'eq.owner');
            expect(lastDelete!.queryParameters['receiver_id'], 'eq.a');
            expect(lastDelete!.queryParameters['status'], 'eq.pending');
        }
        await c.pump();
        final updated = await c.read(friendPublicDataProvider('a').future);
        expect(updated.friend.id, 'a');
        expect(await c.read(friendPublicDataProvider('c').future), same(other));
        final state = c.read(friendProvider).requireValue;
        expect(
          state.friends.map((friend) => friend.id),
          action == 'accept' ? ['a'] : isEmpty,
        );
        expect(
          state.pendingSent.map((friend) => friend.id),
          action == 'send' ? ['a'] : isEmpty,
        );
        expect(state.pendingReceived, isEmpty);
        expect(mutations, 1);
        expect(relationReads, reads);
      },
    );
  }

  test(
    'identity and avatar invalidation notify only the affected user',
    () async {
      final c = ProviderContainer(
        overrides: [
          onlineProvider.overrideWith(_Online.new),
          currentUserIdProvider.overrideWithValue('owner'),
        ],
      );
      addTearDown(c.dispose);
      c.listen(userAvatarProvider('a'), (_, _) {});
      c.listen(userIdentityProvider('c'), (_, _) {});
      await c.read(friendProvider.future);
      await c.read(userAvatarProvider('a').future);
      final other = await c.read(userIdentityProvider('c').future);
      c.read(friendProvider.notifier).invalidateAvatarCache('a');
      await c.pump();
      expect(await c.read(userAvatarProvider('a').future), contains('v='));
      expect(await c.read(userIdentityProvider('c').future), same(other));
    },
  );

  test(
    'account identity changes propagate to active names without a cycle',
    () async {
      final c = ProviderContainer(
        overrides: [
          onlineProvider.overrideWith(_Online.new),
          currentUserIdProvider.overrideWithValue('owner'),
        ],
      );
      addTearDown(c.dispose);
      c.listen(userIdentityProvider('owner'), (_, _) {});
      await c.read(friendProvider.future);
      expect(
        (await c.read(userIdentityProvider('owner').future)).username,
        'Owner',
      );
      (c.read(onlineProvider.notifier) as _Online).updateIdentity();
      await c.pump();
      final updated = await c.read(userIdentityProvider('owner').future);
      expect(updated.username, 'Updated owner');
      expect(updated.fullName, 'Updated name');
      expect(profiles, 0);
      expect(contents, 0);
    },
  );
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
