import 'package:gymtracker/data/achievements.dart';
import 'package:gymtracker/model/achievements.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/database.dart';

enum FeedSource { ownHistory, ownAchievements }

sealed class FeedAuthorship {}

class FeedAuthorshipOwn extends FeedAuthorship {}

class FeedAuthorshipFriend extends FeedAuthorship {
  final String friendID;

  FeedAuthorshipFriend({required this.friendID});
}

sealed class FeedItem {
  final FeedAuthorship authorship;

  FeedItem({required this.authorship});
}

class FeedItemWorkout extends FeedItem {
  final Workout workout;

  FeedItemWorkout({required this.workout, required super.authorship});
}

class FeedItemAchievement extends FeedItem {
  final Achievement achievement;
  final AchievementCompletion completion;

  FeedItemAchievement({
    required this.achievement,
    required this.completion,
    required super.authorship,
  });
}

class FeedService {
  final DatabaseService _databaseService;

  FeedService(this._databaseService);

  Future<({List<FeedItem> feed, bool hasMore})> getFeedItems({
    required Set<FeedSource> sources,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final feedItems = <FeedItem>[];
    bool hasMore = false;

    for (final source in sources) {
      switch (source) {
        case FeedSource.ownHistory:
          final workouts = _databaseService.history$.value
              .where(
                (workout) =>
                    (workout.endingDate ?? workout.startingDate)?.isAfter(
                      startDate,
                    ) ??
                    false,
              )
              .toList();
          feedItems.addAll(
            workouts.map(
              (workout) => FeedItemWorkout(
                workout: workout,
                authorship: FeedAuthorshipOwn(),
              ),
            ),
          );
          hasMore =
              hasMore ||
              _databaseService.history$.value.length > workouts.length;
          break;
        case FeedSource.ownAchievements:
          final fetchedAchievements = _databaseService.completions$.value
              .where((completion) => completion.completedAt.isAfter(startDate))
              .map(
                (completion) =>
                    (achievements[completion.achievementID], completion),
              )
              .where((tuple) => tuple.$1 != null)
              .toList();
          feedItems.addAll(
            fetchedAchievements.map(
              (tuple) => FeedItemAchievement(
                achievement: tuple.$1!,
                completion: tuple.$2,
                authorship: FeedAuthorshipOwn(),
              ),
            ),
          );
          hasMore =
              hasMore ||
              _databaseService.completions$.value.length >
                  fetchedAchievements.length;
          break;
      }
    }

    feedItems.sort((a, b) {
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

    return (feed: feedItems, hasMore: hasMore);
  }
}
