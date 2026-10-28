import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/model/friend.dart';
import 'package:gymtracker/provider/friend.dart';

class _Friends extends FriendNotifier {
  int requests = 0;

  @override
  FriendState build() =>
      FriendState(friends: [], pendingReceived: [], pendingSent: []);

  @override
  Future<String?> getAvatar(String id) async =>
      'https://example.com/$id?token=${++requests}';
}

void main() {
  testWidgets(
    'avatar URL survives switching screens and renews before expiry',
    (tester) async {
      final friends = _Friends();
      final identity = Completer<Friend>();
      final container = ProviderContainer(
        overrides: [
          friendProvider.overrideWith(() => friends),
          userIdentityProvider('user').overrideWith((ref) => identity.future),
        ],
      );
      addTearDown(container.dispose);
      final provider = userAvatarProvider('user');
      var subscription = container.listen(provider, (_, _) {});
      await tester.pump();
      expect(friends.requests, 0);
      identity.complete(Friend(id: 'user', username: 'User'));
      await tester.pump();
      expect(container.read(provider).requireValue, contains('token=1'));
      expect(friends.requests, 1);

      subscription.close();
      await tester.pump(const Duration(seconds: 1));
      subscription = container.listen(provider, (_, _) {});
      await tester.pump();
      expect(container.read(provider).requireValue, contains('token=1'));
      expect(friends.requests, 1);

      await tester.pump(const Duration(seconds: 45));
      await tester.pump();
      expect(container.read(provider).requireValue, contains('token=2'));
      expect(friends.requests, 2);
      subscription.close();
      container.dispose();
    },
  );

  testWidgets('profile changes refresh an already cached avatar', (
    tester,
  ) async {
    final friends = _Friends();
    final container = ProviderContainer(
      overrides: [
        friendProvider.overrideWith(() => friends),
        userIdentityProvider(
          'user',
        ).overrideWith((ref) async => Friend(id: 'user', username: 'User')),
      ],
    );
    addTearDown(container.dispose);
    final provider = userAvatarProvider('user');
    container.listen(provider, (_, _) {});
    await tester.pump();
    expect(friends.requests, 1);
    container.invalidate(userIdentityProvider('user'));
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump();
    expect(container.read(provider).requireValue, contains('token=2'));
    expect(friends.requests, 2);
    container.dispose();
  });
}
