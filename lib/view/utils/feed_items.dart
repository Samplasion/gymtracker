import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/service/feed.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/exercises.dart';
import 'package:gymtracker/view/utils/achievements.dart';
import 'package:gymtracker/view/utils/history_workout.dart';
import 'package:gymtracker/view/utils/social.dart';
import 'package:relative_time/relative_time.dart';

/// A card displaying a [FeedItemWorkout]. Used on both the Feed screen and
/// user profile screens.
class FeedItemWorkoutCard extends ConsumerWidget {
  final FeedItemWorkout item;
  final void Function(String? userID)? onUserPressed;

  const FeedItemWorkoutCard({
    super.key,
    required this.item,
    this.onUserPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(onlineProvider).value;
    return Card.outlined(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            leading: GestureDetector(
              onTap: onUserPressed != null
                  ? () => onUserPressed!(item.authorship.userID)
                  : null,
              child: UserAccountIcon(id: item.authorship.userID),
            ),
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: switch (item.authorship) {
                    FeedAuthorshipOwn() => Text("feed.workout.title.you".t),
                    FeedAuthorshipFriend(:final String userID) => UserNameText(
                      id: userID,
                    ),
                    FeedAuthorship() => Text("feed.workout.title.unknown".t),
                  },
                ),
                if (item.workout.endingDate != null)
                  Text(
                    RelativeTime.locale(
                      context.locale,
                    ).format(item.workout.endingDate!),
                    textAlign: TextAlign.end,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
            subtitle: switch (item.authorship) {
              FeedAuthorshipOwn() => Text("feed.workout.subtitle.you".t),
              FeedAuthorshipFriend() => Text("feed.workout.subtitle.friend".t),
            },
          ),
          HistoryWorkout.naked(
            workout: item.workout,
            showExercises: 3,
            withStats: true,
            headerBuilder: (context, workout) => Text(
              workout.name,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.start,
            ),
            onTap: () {
              Go.to(
                () => ExercisesView(
                  workout: item.workout,
                  isOwned:
                      item.authorship is FeedAuthorshipOwn ||
                      item.authorship.userID == account?.id,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// A card displaying a [FeedItemAchievement]. Used on both the Feed screen and
/// user profile screens.
class FeedItemAchievementCard extends StatelessWidget {
  final FeedItemAchievement item;
  final void Function(String? userID)? onUserPressed;

  const FeedItemAchievementCard({
    super.key,
    required this.item,
    this.onUserPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          ListTile(
            leading: GestureDetector(
              onTap: onUserPressed != null
                  ? () => onUserPressed!(item.authorship.userID)
                  : null,
              child: UserAccountIcon(id: item.authorship.userID),
            ),
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: switch (item.authorship) {
                    FeedAuthorshipOwn() => Text("feed.achievement.title.you".t),
                    FeedAuthorshipFriend(:final String userID) => UserNameText(
                      id: userID,
                    ),
                    FeedAuthorship() => Text("feed.workout.title.unknown".t),
                  },
                ),
                Text(
                  RelativeTime.locale(
                    context.locale,
                  ).format(item.completion.completedAt),
                  textAlign: TextAlign.end,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            subtitle: switch (item.authorship) {
              FeedAuthorshipOwn() => Text("feed.achievement.subtitle.you".t),
              FeedAuthorshipFriend() => Text(
                "feed.achievement.subtitle.friend".t,
              ),
            },
          ),
          Card(
            margin: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ).copyWith(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: AchievementSnackBar(
                achievement: item.achievement,
                completion: item.completion,
                inverted: false,
              ).content,
            ),
          ),
        ],
      ),
    );
  }
}

/// Convenience widget that dispatches to [FeedItemWorkoutCard] or
/// [FeedItemAchievementCard] based on the runtime type of [item].
class FeedItemCard extends StatelessWidget {
  final FeedItem item;
  final void Function(String? userID)? onUserPressed;

  const FeedItemCard({super.key, required this.item, this.onUserPressed});

  @override
  Widget build(BuildContext context) {
    final i = item;
    if (i is FeedItemWorkout) {
      return FeedItemWorkoutCard(item: i, onUserPressed: onUserPressed);
    } else if (i is FeedItemAchievement) {
      return FeedItemAchievementCard(item: i, onUserPressed: onUserPressed);
    }
    return const SizedBox.shrink();
  }
}
