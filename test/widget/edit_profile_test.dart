import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/model/friend.dart';
import 'package:gymtracker/provider/friend.dart';
import 'package:gymtracker/view/components/loading_indicator.dart';
import 'package:gymtracker/view/utils/edit_profile.dart';

void main() {
  testWidgets('profile editing stays visible during startup sync and reloads', (
    tester,
  ) async {
    var identity = Future.value(
      Friend(id: 'user', username: 'user', fullName: 'Original Name'),
    );
    var publicProfileReads = 0;
    final container = ProviderContainer(
      overrides: [
        userIdentityProvider('user').overrideWith((ref) {
          ref.watch(identityEpochProvider);
          return identity;
        }),
        userAvatarProvider('user').overrideWith((ref) async => null),
        friendPublicDataProvider('user').overrideWith((ref) {
          publicProfileReads++;
          return Completer<FriendPublicData>().future;
        }),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TranslationProvider(
          child: const MaterialApp(home: EditProfilePage(userID: 'user')),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Original Name'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'Unsaved Name');
    final fieldState = tester.state(find.byType(TextFormField));

    // Startup sync invalidates public contents repeatedly.
    container
        .read(userCacheRevisionProvider('user').notifier)
        .contentsChanged();
    await tester.pump();
    expect(publicProfileReads, 0);
    expect(find.text('Unsaved Name'), findsOneWidget);

    // Even an identity reload must preserve the mounted form and its draft.
    final reload = Completer<Friend>();
    identity = reload.future;
    container.read(identityEpochProvider.notifier).bump();
    await tester.pump();
    expect(find.byType(GBLoadingIndicator), findsNothing);
    expect(tester.state(find.byType(TextFormField)), same(fieldState));
    expect(find.text('Unsaved Name'), findsOneWidget);

    reload.complete(
      Friend(id: 'user', username: 'user', fullName: 'Updated Name'),
    );
    await tester.pumpAndSettle();
    expect(find.text('Unsaved Name'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
