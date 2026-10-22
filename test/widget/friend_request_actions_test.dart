import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/model/friend.dart';
import 'package:gymtracker/provider/connectivity.dart';
import 'package:gymtracker/provider/feed.dart';
import 'package:gymtracker/provider/friend.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/service/feed.dart';
import 'package:gymtracker/service/online.dart';
import 'package:gymtracker/view/feed.dart';
import 'package:gymtracker/view/user_profile.dart';
import 'package:mocktail/mocktail.dart';

import '../test_helpers/mock_services.dart';
import '../test_helpers/widget_test_app.dart';

final _friend = Friend(id: 'friend', username: 'friend');
final _profile = FriendPublicData(
  friend: _friend,
  achievements: [],
  workouts: [],
  friendCount: 0,
);

class _Friends extends FriendNotifier {
  _Friends({this.failCancellation = false});
  final bool failCancellation;
  int cancellations = 0;

  @override
  Future<FriendState> build() async =>
      FriendState(friends: [], pendingSent: [_friend], pendingReceived: []);

  @override
  Future<void> refresh({bool force = false}) async {}

  @override
  Future<FriendPublicData> getFriendPublicData(
    String id, {
    bool force = false,
  }) async => _profile;

  @override
  Future<void> cancelFriendRequest(String id) async {
    expect(id, _friend.id);
    cancellations++;
    if (failCancellation) throw StateError('Connection failed');
    state = AsyncData(state.requireValue.copyWith(pendingSent: []));
  }

  void receiveRequests(int count) {
    state = AsyncData(
      state.requireValue.copyWith(
        pendingReceived: List.generate(
          count,
          (index) => Friend(id: 'incoming-$index', username: 'incoming-$index'),
        ),
      ),
    );
  }
}

class _Online extends Online {
  @override
  OnlineAccount? build() => OnlineAccount(id: 'owner', name: 'Owner');
}

class _Connectivity extends NetworkConnectivityNotifier {
  @override
  Stream<bool> build() => Stream.value(true);
}

class _Feed extends Feed {
  @override
  Future<List<FeedItem>> build() async => [];
  @override
  bool get hasMore => false;
  @override
  void setVisible(bool visible) {}
  @override
  Future<void> refreshIfStale() async {}
}

void main() {
  setUp(() async {
    MockServices.setup();
    await initTestLocalizations();
    when(
      () => MockServices.routinesController.suggestions,
    ).thenReturn(<RoutineSuggestion>[]);
  });
  tearDown(MockServices.tearDown);

  Future<void> showPage(
    WidgetTester tester,
    _Friends friends,
    Widget page,
  ) async {
    final container = ProviderContainer(
      overrides: [
        friendProvider.overrideWith(() => friends),
        onlineProvider.overrideWith(_Online.new),
        currentUserIdProvider.overrideWithValue('owner'),
        networkConnectivityProvider.overrideWith(_Connectivity.new),
        friendPublicDataProvider(
          'friend',
        ).overrideWith((ref) async => _profile),
        userAvatarProvider('friend').overrideWith((ref) async => null),
        userAvatarProvider('owner').overrideWith((ref) async => null),
        feedProvider.overrideWith(_Feed.new),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: WidgetTestApp(child: page),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('sent request requires confirmation and can be kept', (
    tester,
  ) async {
    final friends = _Friends();
    await showPage(tester, friends, const UserProfilePage(userID: 'friend'));
    await tester.tap(find.text('Friend Request Sent'));
    await tester.pumpAndSettle();
    expect(find.text('Cancel friend request?'), findsOneWidget);
    expect(friends.cancellations, 0);

    await tester.tap(find.text('Keep request'));
    await tester.pumpAndSettle();
    expect(friends.cancellations, 0);
    expect(find.text('Friend Request Sent'), findsOneWidget);

    await tester.tap(find.text('Friend Request Sent'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel request'));
    await tester.pumpAndSettle();
    expect(friends.cancellations, 1);
    expect(find.text('Friend Request Sent'), findsNothing);
    expect(find.text('Add Friend'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('failed cancellation keeps the request and displays an error', (
    tester,
  ) async {
    final friends = _Friends(failCancellation: true);
    await showPage(tester, friends, const UserProfilePage(userID: 'friend'));
    await tester.tap(find.text('Friend Request Sent'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel request'));
    await tester.pumpAndSettle();
    expect(friends.cancellations, 1);
    expect(find.text('Friend Request Sent'), findsOneWidget);
    expect(
      find.text('Could not cancel the friend request. Please try again.'),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('feed badge counts incoming requests and hides when empty', (
    tester,
  ) async {
    final friends = _Friends();
    await showPage(tester, friends, const FeedView());
    Badge badge() => tester.widget<Badge>(find.byType(Badge));
    expect(badge().isLabelVisible, isFalse);

    friends.receiveRequests(2);
    await tester.pump();
    expect(badge().isLabelVisible, isTrue);
    expect((badge().label! as Text).data, '2');

    friends.receiveRequests(0);
    await tester.pump();
    expect(badge().isLabelVisible, isFalse);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
