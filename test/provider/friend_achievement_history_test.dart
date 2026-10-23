import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/model/achievements.dart';
import 'package:gymtracker/model/friend.dart';
import 'package:gymtracker/provider/friend.dart';
import 'package:gymtracker/provider/friend_achievement_history.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final friend = Friend(id: 'friend', username: 'friend');

class Friends extends FriendNotifier {
  @override
  Future<FriendState> build() async =>
      FriendState(friends: [friend], pendingReceived: [], pendingSent: []);
  @override
  Future<void> refresh({bool force = false}) async {}
  void remove() => state = AsyncData(
    FriendState(friends: [], pendingReceived: [], pendingSent: []),
  );
}

void main() {
  final provider = friendAchievementHistoryProvider('friend');
  late ProviderContainer container;
  late Friends friends;
  late AchievementPageLoader loader;
  late List<AchievementCursor?> cursors;
  late String? owner;
  final date = DateTime.utc(2026, 10, 22);
  AchievementCompletion item(int i) => AchievementCompletion(
    id: '$i',
    achievementID: 'unknown',
    level: 1,
    completedAt: date,
  );
  setUp(() {
    friends = Friends();
    owner = 'owner';
    cursors = [];
    loader = (_, cursor) async {
      cursors.add(cursor);
      final start = cursor == null ? 0 : int.parse(cursor['id'] as String);
      final end = (start + 50).clamp(0, 125);
      return AchievementHistoryPage(
        items: [for (var i = start; i < end; i++) item(i)],
        nextCursor: end == 125
            ? null
            : {'id': '$end', 'completed_at': date.toIso8601String()},
      );
    };
    container = ProviderContainer(
      overrides: [
        friendProvider.overrideWith(() => friends),
        currentUserIdProvider.overrideWith((ref) => owner),
        achievementPageLoaderProvider.overrideWith(
          (ref) =>
              (id, cursor) => loader(id, cursor),
        ),
      ],
    );
    container.listen(provider, (_, _) {});
  });
  tearDown(() => container.dispose());

  test(
    'loads all 125 items with server cursors, including equal dates',
    () async {
      await container.read(provider.future);
      final notifier = container.read(provider.notifier);
      await notifier.loadMore();
      await notifier.loadMore();
      expect(container.read(provider).requireValue.items.length, 125);
      expect(container.read(provider).requireValue.nextCursor, isNull);
      expect(cursors.map((c) => c?['id']), [null, '50', '100']);
      await notifier.loadMore();
      expect(cursors.length, 3);
      await notifier.refresh();
      expect(container.read(provider).requireValue.items.length, 50);
      expect(cursors.last, isNull);
    },
  );

  test('serializes loads and deduplicates overlapping IDs', () async {
    await container.read(provider.future);
    final completer = Completer<AchievementHistoryPage>();
    var calls = 0;
    loader = (_, _) {
      calls++;
      return completer.future;
    };
    final notifier = container.read(provider.notifier);
    final work = notifier.loadMore();
    await notifier.loadMore();
    expect(calls, 1);
    completer.complete(AchievementHistoryPage(items: [item(49), item(50)]));
    await work;
    expect(container.read(provider).requireValue.items.length, 51);
  });

  test('page failure preserves rows and retries the same cursor', () async {
    await container.read(provider.future);
    final normal = loader;
    loader = (_, _) async => throw StateError('offline');
    final notifier = container.read(provider.notifier);
    await notifier.loadMore();
    expect(container.read(provider).requireValue.items.length, 50);
    expect(container.read(provider).requireValue.pageError, isNotNull);
    loader = normal;
    await notifier.loadMore();
    expect(container.read(provider).requireValue.items.length, 100);
    expect(container.read(provider).requireValue.pageError, isNull);
  });

  test('revocation clears rows and ignores an in-flight page', () async {
    await container.read(provider.future);
    final completer = Completer<AchievementHistoryPage>();
    loader = (_, _) => completer.future;
    final work = container.read(provider.notifier).loadMore();
    friends.remove();
    await container.pump();
    expect(container.read(provider).requireValue.accessDenied, isTrue);
    expect(container.read(provider).requireValue.items, isEmpty);
    completer.complete(AchievementHistoryPage(items: [item(50)]));
    await work;
    expect(container.read(provider).requireValue.items, isEmpty);
  });

  test('server permission denial clears loaded rows', () async {
    await container.read(provider.future);
    loader = (_, _) async =>
        throw const PostgrestException(message: 'denied', code: '42501');
    await container.read(provider.notifier).loadMore();
    expect(container.read(provider).requireValue.accessDenied, isTrue);
    expect(container.read(provider).requireValue.items, isEmpty);
  });

  test('account change discards previous account history', () async {
    await container.read(provider.future);
    owner = null;
    container.invalidate(currentUserIdProvider);
    final page = await container.read(provider.future);
    expect(page.accessDenied, isTrue);
    expect(container.read(provider).requireValue.items, isEmpty);
  });
  test(
    'failed refresh retains items and retries from the first page',
    () async {
      await container.read(provider.future);
      final normal = loader;
      loader = (_, _) async => throw StateError('offline');
      final notifier = container.read(provider.notifier);
      await notifier.refresh();
      final failed = container.read(provider).requireValue;
      expect(failed.items.length, 50);
      expect(failed.retryRefresh, isTrue);
      loader = normal;
      await notifier.refresh();
      expect(cursors.last, isNull);
      expect(container.read(provider).requireValue.pageError, isNull);
    },
  );

  test('account switch ignores the old account’s in-flight page', () async {
    await container.read(provider.future);
    final normal = loader;
    final completer = Completer<AchievementHistoryPage>();
    loader = (_, _) => completer.future;
    final work = container.read(provider.notifier).loadMore();
    loader = normal;
    owner = 'another-owner';
    container.invalidate(currentUserIdProvider);
    await container.read(provider.future);
    completer.complete(AchievementHistoryPage(items: [item(999)]));
    await work;
    expect(
      container
          .read(provider)
          .requireValue
          .items
          .any((item) => item.id == '999'),
      isFalse,
    );
    expect(container.read(provider).requireValue.items.length, 50);
  });
}
