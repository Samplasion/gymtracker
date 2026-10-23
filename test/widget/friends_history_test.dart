import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/controller/achievements_controller.dart';
import 'package:gymtracker/data/achievements.dart' as metadata;
import 'package:gymtracker/model/achievements.dart';
import 'package:gymtracker/model/friend.dart';
import 'package:gymtracker/provider/achievement_metadata.dart';
import 'package:gymtracker/provider/connectivity.dart';
import 'package:gymtracker/provider/feed.dart';
import 'package:gymtracker/provider/friend.dart';
import 'package:gymtracker/provider/friend_achievement_history.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/service/online.dart';
import 'package:gymtracker/view/achievements.dart';
import 'package:gymtracker/view/components/achievement_history_tile.dart';
import 'package:gymtracker/view/components/stats.dart';
import 'package:gymtracker/view/friend_achievement_history.dart';
import 'package:gymtracker/view/friends.dart';
import 'package:gymtracker/view/user_profile.dart';
import 'package:gymtracker/view/utils/achievements.dart';
import 'package:mocktail/mocktail.dart';

import '../test_helpers/mock_services.dart';
import '../test_helpers/widget_test_app.dart';

final alice = Friend(id: 'alice', username: 'alice', fullName: 'Alice');
final bob = Friend(id: 'bob', username: 'bob', fullName: 'Bob');

class Friends extends FriendNotifier {
  Friends({this.empty = false, this.fail = false});
  final bool empty;
  bool fail;
  @override
  Future<FriendState> build() async => FriendState(
    friends: empty ? [] : [bob, alice],
    pendingReceived: [Friend(id: 'pending', username: 'pending')],
    pendingSent: [],
  );
  @override
  Future<void> refresh({bool force = false}) async {
    if (fail) throw StateError('offline');
  }

  @override
  Future<FriendPublicData> getFriendPublicData(
    String id, {
    bool force = false,
  }) async => profile(id);
}

class OnlineAccountNotifier extends Online {
  @override
  OnlineAccount? build() => OnlineAccount(id: 'owner', name: 'Owner');
}

class Connectivity extends NetworkConnectivityNotifier {
  @override
  Stream<bool> build() => Stream.value(true);
}

FriendPublicData profile(String id) => FriendPublicData(
  friend: id == 'alice' ? alice : Friend(id: id, username: id),
  achievements: [],
  workouts: [],
  friendCount: 2,
);

void main() {
  setUp(() async {
    MockServices.setup();
    await initTestLocalizations();
  });
  tearDown(MockServices.tearDown);

  Future<void> show(
    WidgetTester tester,
    Widget child, {
    Friends? friends,
    AchievementPageLoader? loader,
  }) async {
    final container = ProviderContainer(
      overrides: [
        friendProvider.overrideWith(() => friends ?? Friends()),
        onlineProvider.overrideWith(OnlineAccountNotifier.new),
        currentUserIdProvider.overrideWithValue('owner'),
        networkConnectivityProvider.overrideWith(Connectivity.new),
        feedHistoryStreamProvider.overrideWith((ref) => Stream.value([])),
        feedAchievementsStreamProvider.overrideWith((ref) => Stream.value([])),
        achievementMetadataProvider.overrideWithValue(metadata.achievements),
        achievementsControllerProvider.overrideWithValue(
          MockServices.achievementsController,
        ),
        achievementPageLoaderProvider.overrideWithValue(
          loader ?? (_, _) async => const AchievementHistoryPage(items: []),
        ),
        for (final id in ['owner', 'alice', 'bob']) ...[
          friendPublicDataProvider(id).overrideWith((ref) async => profile(id)),
          userAvatarProvider(id).overrideWith((ref) async => null),
        ],
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: WidgetTestApp(child: child),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'own profile opens accepted friends, then profile, then history',
    (tester) async {
      await show(tester, const UserProfilePage(userID: 'owner'));
      final ownStats = tester.widgetList<Stats>(find.byType(Stats)).toList();
      expect(ownStats.first.onTap, isNotNull);
      expect(ownStats.last.onTap, isNull);
      await tester.tap(find.text('Friends'));
      await tester.pumpAndSettle();
      expect(find.byType(FriendsPage), findsOneWidget);
      expect(find.text('@pending'), findsNothing);
      expect(
        tester.getTopLeft(find.text('@alice')).dy,
        lessThan(tester.getTopLeft(find.text('@bob')).dy),
      );
      await tester.tap(find.text('@alice'));
      await tester.pumpAndSettle();
      final friendStats = tester.widgetList<Stats>(find.byType(Stats)).toList();
      expect(friendStats.first.onTap, isNull);
      expect(friendStats.last.onTap, isNotNull);
      await tester.tap(find.text('Achievements'));
      await tester.pumpAndSettle();
      expect(find.byType(FriendAchievementHistoryPage), findsOneWidget);
      expect(find.text('Alice’s achievements'), findsOneWidget);
      expect(find.text('No achievements yet'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('empty friends and refresh failure can retry', (tester) async {
    var friends = Friends(empty: true);
    await show(tester, const FriendsPage(), friends: friends);
    expect(find.text('No friends yet'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    friends = Friends(empty: true, fail: true);
    await show(tester, const FriendsPage(), friends: friends);
    expect(find.textContaining('offline'), findsOneWidget);
    friends.fail = false;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.text('No friends yet'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'unknown completion renders date without consulting own progress',
    (tester) async {
      await show(
        tester,
        Scaffold(
          body: AchievementHistoryTile(
            completion: AchievementCompletion(
              achievementID: 'future-achievement',
              level: 0,
              completedAt: DateTime(2026, 10, 22),
            ),
          ),
        ),
      );
      expect(find.text('Unknown achievement'), findsOneWidget);
      expect(find.textContaining('2026'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('history initial error offers retry', (tester) async {
    var fail = true;
    await show(
      tester,
      FriendAchievementHistoryPage(friend: alice),
      loader: (_, _) async {
        if (fail) throw StateError('offline');
        return const AchievementHistoryPage(items: []);
      },
    );
    expect(find.textContaining('offline'), findsOneWidget);
    fail = false;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.text('No achievements yet'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets('personal history uses the shared row for known completions', (
    tester,
  ) async {
    final achievement = metadata.achievements.values.first;
    final completion = AchievementCompletion(
      achievementID: achievement.id,
      level: 1,
      completedAt: DateTime(2026, 10, 22),
    );
    when(
      () => MockServices.achievementsController.completionStream,
    ).thenAnswer((_) => Stream.value([completion]));
    await show(tester, const AchievementHistoryScreen());
    expect(find.byType(AchievementHistoryTile), findsOneWidget);
    expect(find.byType(AchievementIcon), findsOneWidget);
    expect(find.text('Unknown achievement'), findsNothing);
    expect(find.textContaining('2026'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
