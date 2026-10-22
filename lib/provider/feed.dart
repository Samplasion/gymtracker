import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/provider/achievement_metadata.dart';
import 'package:gymtracker/model/achievements.dart';
import 'package:gymtracker/model/friend.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/provider/connectivity.dart';
import 'package:gymtracker/provider/friend.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/service/feed.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'feed.g.dart';

@riverpod
Stream<List<Workout>> feedHistoryStream(Ref ref) =>
    ref.watch(databaseServiceProvider).history$.stream;
@riverpod
Stream<List<AchievementCompletion>> feedAchievementsStream(Ref ref) =>
    ref.watch(databaseServiceProvider).completions$.stream;

@Riverpod(keepAlive: true)
class Feed extends _$Feed {
  DateTime _end = DateTime.now(), _start = DateTime.now();
  DateTime? _previous, _fetchedAt;
  List<FeedItem> _remote = [];
  Future<void>? _work;
  int _generation = 0;
  bool _more = true;
  bool _visible = false;
  void setVisible(bool visible) {
    if (_visible == visible) return;
    _visible = visible;
    if (visible)
      scheduleMicrotask(() {
        if (ref.mounted && _visible) unawaited(refreshIfStale());
      });
  }

  bool get hasMore => _more;
  bool get isLoadingMore => _work != null;

  @override
  Future<List<FeedItem>> build() async {
    ref.watch(currentUserIdProvider);
    final generation = ++_generation;
    _end = DateTime.now();
    _start = _end.subtract(const Duration(days: 30));
    _remote = [];
    _more = true;
    _fetchedAt = null;
    _work = null;
    ref.listen(feedHistoryStreamProvider, (_, __) => _recompose());
    ref.listen(feedAchievementsStreamProvider, (_, __) => _recompose());
    ref.listen(achievementMetadataProvider, (_, _) => _recompose());
    ref.listen(friendshipChangesProvider, (_, accepted) {
      if (accepted != null) relationsChanged(accepted);
    });
    ref.listen(networkConnectivityProvider, (previous, next) {
      if (_visible && previous?.value != true && next.value == true)
        unawaited(refreshIfStale());
    });
    ref.onDispose(() => _generation++);
    try {
      await _serialized(() => _load(_start, _end, generation, replace: true));
    } catch (_) {
      await _publish();
    }
    if (!ref.mounted || generation != _generation) return [];
    return _compose();
  }

  List<FeedItem> _compose() {
    // getFeedItems performs only synchronous local reads before returning.
    final db = ref.read(databaseServiceProvider);
    final own = ref.read(currentUserIdProvider);
    final items = <FeedItem>[..._remote];
    for (final w in db.history$.value) {
      final d = w.endingDate ?? w.startingDate;
      if (d != null && !d.isBefore(_start) && d.isBefore(_end))
        items.add(
          FeedItemWorkout(
            workout: w,
            authorship: FeedAuthorshipOwn(userID: own),
          ),
        );
    }
    for (final c in db.completions$.value) {
      final d = c.completedAt;
      if (!d.isBefore(_start) && d.isBefore(_end)) {
        final a = ref.read(achievementMetadataProvider)[c.achievementID];
        if (a != null)
          items.add(
            FeedItemAchievement(
              achievement: a,
              completion: c,
              authorship: FeedAuthorshipOwn(userID: own),
            ),
          );
      }
    }
    return _merged(items);
  }

  DateTime _date(FeedItem item) => switch (item) {
    FeedItemWorkout(:final workout) =>
      workout.endingDate ?? workout.startingDate ?? DateTime(1970),
    FeedItemAchievement(:final completion) => completion.completedAt,
  };
  String _id(FeedItem i) =>
      '${i.runtimeType}/${i.authorship.userID}/${switch (i) {
        FeedItemWorkout(:final workout) => workout.id,
        FeedItemAchievement(:final completion) => completion.id,
      }}';
  List<FeedItem> _merged(List<FeedItem> items) {
    final catalog = ref.read(achievementMetadataProvider);
    final map = {
      for (final item in items)
        _id(item): item is FeedItemAchievement
            ? FeedItemAchievement(
                achievement:
                    catalog[item.completion.achievementID] ?? item.achievement,
                completion: item.completion,
                authorship: item.authorship,
              )
            : item,
    };
    return List.unmodifiable(
      map.values.toList()..sort((a, b) => _date(b).compareTo(_date(a))),
    );
  }

  void _recompose() {
    if (ref.mounted && state.hasValue) unawaited(_publish());
  }

  Future<void> _publish() async {
    if (!ref.mounted) return;
    final generation = _generation;
    final service = FeedService(
      ref.read(databaseServiceProvider),
      ref.read(onlineProvider.notifier).onlineService,
      achievementCatalog: ref.read(achievementMetadataProvider),
    );
    final local = await service.getFeedItems(
      sources: {FeedSource.ownHistory, FeedSource.ownAchievements},
      startDate: _start,
      endDate: _end,
    );
    if (generation != _generation || !ref.mounted) return;
    _previous = _latest(
      service.previousAt,
      ref.read(onlineProvider.notifier).onlineService.nextFriendsFeedDate,
    );
    _more = _previous != null;
    if (ref.mounted)
      state = AsyncValue.data(_merged([...local.feed, ..._remote]));
  }

  DateTime? _latest(DateTime? a, DateTime? b) => a == null
      ? b
      : b == null
      ? a
      : a.isAfter(b)
      ? a
      : b;

  Future<void> _load(
    DateTime start,
    DateTime end,
    int generation, {
    required bool replace,
  }) async {
    if (!ref.mounted || generation != _generation) return;
    final connected = await ref.read(networkConnectivityProvider.future);
    if (generation != _generation || !ref.mounted) return;
    if (connected && ref.read(currentUserIdProvider) != null) {
      final online = ref.read(onlineProvider.notifier).onlineService;
      final result = await online.getFriendsFeed(
        sources: {FeedSource.friendsHistory, FeedSource.friendsAchievements},
        startDate: start,
        endDate: end,
      );
      if (generation != _generation || !ref.mounted) return;
      for (final p in online.feedProfiles) {
        ref.read(friendProvider.notifier).seedIdentity(Friend.fromJson(p));
      }
      _remote = replace ? result.feed : _merged([..._remote, ...result.feed]);
      _fetchedAt = DateTime.now();
    }
    await _publish();
  }

  Future<void> refreshIfStale() async {
    if (_fetchedAt != null &&
        DateTime.now().difference(_fetchedAt!) < const Duration(minutes: 5))
      return;
    try {
      await refresh();
    } catch (_) {
      /* Existing feed remains visible. */
    }
  }

  Future<void> refresh() => _serialized(() async {
    _end = DateTime.now();
    await _load(_start, _end, _generation, replace: true);
  });
  Future<void> fetchMore() => _serialized(() async {
    if (!_more || _previous == null) return;
    final end = _previous!.add(const Duration(microseconds: 1));
    final start = end.subtract(const Duration(days: 30));
    final previousStart = _start;
    _start = start;
    try {
      await _load(start, end, _generation, replace: false);
    } catch (_) {
      _start = previousStart;
      rethrow;
    }
    await _publish();
  });
  Future<void> _serialized(Future<void> Function() body) {
    if (_work != null) return _work!;
    final generation = _generation;
    final future = Future<void>.sync(body).whenComplete(() {
      if (generation == _generation) {
        _work = null;
        if (ref.mounted && state.hasValue)
          state = AsyncValue.data(List.unmodifiable(state.value!));
      }
    });
    _work = future;
    return future;
  }

  void relationsChanged(Set<String> accepted) {
    _remote = _remote
        .where((i) => accepted.contains(i.authorship.userID))
        .toList();
    _fetchedAt = null;
    _recompose();
    if (_visible) unawaited(refreshIfStale());
  }
}
