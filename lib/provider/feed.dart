import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/achievements_controller.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/provider/connectivity.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/model/achievements.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/service/feed.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/service/online.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'feed.g.dart';

@riverpod
Stream<List<Workout>> feedHistoryStream(Ref ref) {
  return Get.find<HistoryController>().history.stream;
}

@riverpod
Stream<List<AchievementCompletion>> feedAchievementsStream(Ref ref) {
  return Get.find<AchievementsController>().completionStream;
}

@riverpod
Stream<OnlineAccount?> feedUserStream(Ref ref) async* {
  yield ref.watch(onlineProvider).value;
}

@riverpod
class Feed extends _$Feed {
  DateTime _currentEndDate = DateTime.now();
  final List<FeedItem> _items = [];
  bool _hasMore = true;
  bool _isLoadingMore = false;

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  @override
  FutureOr<List<FeedItem>> build() async {
    // Listen to local & auth streams so that changes trigger feed invalidation
    ref.watch(feedHistoryStreamProvider);
    ref.watch(feedAchievementsStreamProvider);
    ref.watch(feedUserStreamProvider);
    final isConnected = ref.read(networkConnectivityProvider).value ?? false;

    _currentEndDate = DateTime.now();
    _items.clear();
    _hasMore = true;
    _isLoadingMore = false;

    return _fetchPage(isConnected);
  }

  Future<List<FeedItem>> _fetchPage(bool isConnected) async {
    final databaseService = Get.find<DatabaseService>();
    final onlineService = ref.read(onlineProvider.notifier).onlineService;

    final startDate = _currentEndDate.subtract(const Duration(days: 30));

    // Fetch local user's own items
    final feedService = FeedService(databaseService, onlineService);
    final localResult = await feedService.getFeedItems(
      sources: {FeedSource.ownHistory, FeedSource.ownAchievements},
      startDate: startDate,
      endDate: _currentEndDate,
    );

    // Fetch remote friends' items, catching errors to avoid crashing the feed on connection failure
    var remoteResult = (feed: <FeedItem>[], hasMore: false);
    if (isConnected) {
      try {
        remoteResult = await onlineService.getFriendsFeed(
          sources: {FeedSource.friendsHistory, FeedSource.friendsAchievements},
          startDate: startDate,
          endDate: _currentEndDate,
        );
      } catch (e) {
        // Log the exception but do not abort: only local items will be returned for this range
        logger.e("Failed to fetch friends' feed items: $e", error: e);
      }
    }

    final combinedFeed = [...localResult.feed, ...remoteResult.feed];

    _currentEndDate = startDate;
    _hasMore = localResult.hasMore || remoteResult.hasMore || !isConnected;

    final existingIds = _items.map(_getItemId).toSet();
    for (final item in combinedFeed) {
      if (!existingIds.contains(_getItemId(item))) {
        _items.add(item);
      }
    }

    _items.sort((a, b) {
      DateTime? aDate;
      DateTime? bDate;

      if (a is FeedItemWorkout) {
        aDate = a.workout.endingDate ?? a.workout.startingDate;
      } else if (a is FeedItemAchievement) {
        aDate = a.completion.completedAt;
      }

      if (b is FeedItemWorkout) {
        bDate = b.workout.endingDate ?? b.workout.startingDate;
      } else if (b is FeedItemAchievement) {
        bDate = b.completion.completedAt;
      }

      return (bDate ?? DateTime.fromMillisecondsSinceEpoch(0)).compareTo(
        aDate ?? DateTime.fromMillisecondsSinceEpoch(0),
      );
    });

    return _items;
  }

  String _getItemId(FeedItem item) {
    if (item is FeedItemWorkout) {
      return item.workout.id;
    } else if (item is FeedItemAchievement) {
      return item.completion.id;
    }
    return '';
  }

  Future<void> fetchMore() async {
    if (!_hasMore || _isLoadingMore) return;
    _isLoadingMore = true;
    final isConnected = (await ref.read(networkConnectivityProvider.future));
    if (!isConnected) {
      _isLoadingMore = false;
      _hasMore = false;
      return;
    }

    state = state;
    try {
      final updatedItems = await _fetchPage(isConnected);
      state = AsyncValue.data(List.from(updatedItems));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    } finally {
      _isLoadingMore = false;
    }
  }
}
