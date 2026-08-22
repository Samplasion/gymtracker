import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/data/achievements.dart' as achievements_data;
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/model/friend.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/provider/connectivity.dart';
import 'package:gymtracker/provider/friend.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/service/feed.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/service/online.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/components/badges.dart';
import 'package:gymtracker/view/components/content_unavailable.dart';
import 'package:gymtracker/view/components/error_view.dart';
import 'package:gymtracker/view/components/icon_grid.dart';
import 'package:gymtracker/view/components/stats.dart';
import 'package:gymtracker/view/utils/edit_profile.dart';
import 'package:gymtracker/view/utils/feed_items.dart';
import 'package:gymtracker/view/utils/sliver_utils.dart';
import 'package:gymtracker/view/utils/social.dart';
import 'package:skeletonizer/skeletonizer.dart';

class UserProfilePage extends ConsumerWidget {
  final String userID;

  const UserProfilePage({super.key, required this.userID});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendState = ref.watch(friendProvider);
    final friendObject = ref.watch(friendPublicDataProvider(userID));
    final online = ref.watch(onlineProvider);
    final connectivityStatus = ref.watch(networkConnectivityProvider).value;

    if (connectivityStatus != true) {
      return _buildErrorBody(
        context,
        ref,
        error: "userProfile.errors.noInternet".t,
      );
    }

    final fakeFriendData = FriendPublicData(
      friend: Friend(id: "", username: "Loading...", fullName: null),
      friendCount: 0,
      workouts: [for (int i = 0; i < 3; i++) Workout(name: '', exercises: [])],
      achievements: [],
    );
    final fakeFriendState = FriendState(
      friends: [],
      pendingSent: [],
      pendingReceived: [],
    );

    return Scaffold(
      body: online.when(
        data: (onlineAccount) {
          return friendState.when(
            data: (state) => friendObject.when(
              data: (friend) =>
                  _buildBody(context, ref, friend, onlineAccount, state),
              loading: () => _buildBody(
                context,
                ref,
                fakeFriendData,
                onlineAccount,
                fakeFriendState,
                isLoading: true,
              ),
              error: (error, _) => _buildErrorBody(context, ref, error: error),
            ),
            loading: () => _buildBody(
              context,
              ref,
              fakeFriendData,
              onlineAccount,
              fakeFriendState,
              isLoading: true,
            ),
            error: (error, _) => _buildErrorBody(context, ref, error: error),
          );
        },
        loading: () => _buildBody(
          context,
          ref,
          fakeFriendData,
          null,
          fakeFriendState,
          isLoading: true,
        ),
        error: (error, _) => _buildErrorBody(context, ref, error: error),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    FriendPublicData friendData,
    OnlineAccount? account,
    FriendState friendState, {
    bool isLoading = false,
  }) {
    final friend = friendData.friend;
    final isSelf = account?.id == friend.id;
    final isFriend = friendState.friends.any((f) => f.id == userID);
    final isPendingSent = friendState.pendingSent.any((f) => f.id == userID);
    final isPendingReceived = friendState.pendingReceived.any(
      (f) => f.id == userID,
    );

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            title: Text(friend.fullName ?? "userProfile.title".t),
            pinned: true,
            actions: [
              if (isSelf)
                IconButton(
                  tooltip: "userProfile.edit.tooltip".t,
                  icon: const Icon(GTIcons.edit_profile),
                  onPressed: () {
                    Go.to(() => EditProfilePage(userID: friend.id));
                  },
                ),
            ],
          ),
        ],
        body: Skeletonizer(
          enabled: isLoading,
          child: Builder(
            builder: (context) => RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(friendProvider);
                ref.invalidate(friendPublicDataProvider(friend.id));
              },
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _UserProfileHeader(friend: friend)),
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text.rich(
                            TextSpan(
                              text: friend.fullName ?? friend.username,
                              children: [
                                if (isSelf) ...[
                                  const TextSpan(text: "  "),
                                  WidgetSpan(
                                    child: GTBadge(content: "you".t),
                                    alignment: .middle,
                                  ),
                                ],
                              ],
                            ),
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "@${friend.username}",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                          if (!isSelf) ...[
                            const SizedBox(height: 16),
                            _FriendActionButtons(
                              friend: friend,
                              isFriend: isFriend,
                              isPendingSent: isPendingSent,
                              isPendingReceived: isPendingReceived,
                            ),
                          ],
                          const SizedBox(height: 16),
                          StatsRow(
                            stats: [
                              Stats(
                                value: "${friendData.friendCount}",
                                label: "userProfile.stats.friends".t,
                              ),
                              Stats(
                                value: "${friendData.workouts.length}",
                                label: "userProfile.stats.workouts".t,
                              ),
                              Stats(
                                value: "${friendData.achievements.length}",
                                label: "userProfile.stats.achievements".t,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!isFriend && !isSelf) ...[
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: ContentUnavailableView(
                          icon: const Icon(GTIcons.profile),
                          title: Text("userProfile.feed.unavailable.title".t),
                          description: Text(
                            "userProfile.feed.unavailable.description".t,
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    _UserFeedSliver(friendId: friend.id),
                    const SliverToBoxAdapter(child: SizedBox(height: 8)),
                    const SliverBottomSafeArea(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBody(BuildContext context, WidgetRef ref, {Object? error}) {
    return Scaffold(
      appBar: AppBar(title: Text("userProfile.title".t)),
      body: Center(
        child: ErrorViewComponent(
          error: error,
          retryCallback: () {
            ref.invalidate(friendProvider);
            ref.invalidate(friendPublicDataProvider(userID));
          },
        ),
      ),
    );
  }
}

class _UserProfileHeader extends StatelessWidget {
  final Friend friend;

  const _UserProfileHeader({required this.friend});

  @override
  Widget build(BuildContext context) {
    const height = 300.0;
    return SizedBox(
      height: height,
      child: Stack(
        children: [
          SizedBox(
            height: height - 48,
            child: IconGrid(
              bigScale: 2,
              child: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.outlineVariant,
                foregroundColor: Theme.of(context).colorScheme.onSurface,
                child: const Icon(GTIcons.app_icon),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 32,
            child: Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: UserAccountIcon(id: friend.id, radius: 48),
            ),
          ),
        ],
      ),
    );
  }
}

class _FriendActionButtons extends ConsumerWidget {
  final Friend friend;
  final bool isFriend;
  final bool isPendingSent;
  final bool isPendingReceived;

  const _FriendActionButtons({
    required this.friend,
    required this.isFriend,
    required this.isPendingSent,
    required this.isPendingReceived,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(friendProvider.notifier);

    if (isFriend) {
      return OutlinedButton.icon(
        onPressed: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              icon: const Icon(GTIcons.profile),
              title: Text(
                "userProfile.unfriendConfirmation.title".tParams({
                  "name": friend.fullName ?? friend.username,
                }),
              ),
              content: Text("userProfile.unfriendConfirmation.subtitle".t),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: Text("userProfile.unfriendConfirmation.cancel".t),
                ),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: Text(
                    "userProfile.unfriendConfirmation.confirm".t,
                    style: TextStyle(color: Theme.of(ctx).colorScheme.error),
                  ),
                ),
              ],
            ),
          );
          if (confirmed == true) {
            await notifier.unfriend(friend.id);
          }
        },
        icon: const Icon(GTIcons.profile),
        label: Text("userProfile.unfriend".t),
      );
    }

    if (isPendingSent) {
      return FilledButton.tonal(
        onPressed: null,
        child: Text("userProfile.requestSent".t),
      );
    }

    if (isPendingReceived) {
      return Row(
        children: [
          FilledButton(
            onPressed: () async {
              await notifier.acceptFriendRequest(friend.id);
            },
            child: Text("userProfile.accept".t),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: () async {
              await notifier.declineFriendRequest(friend.id);
            },
            child: Text("userProfile.reject".t),
          ),
        ],
      );
    }

    return FilledButton.icon(
      onPressed: () async {
        await notifier.sendFriendRequest(friend.id);
      },
      icon: const Icon(GTIcons.profile),
      label: Text("userProfile.addFriend".t),
    );
  }
}

class _UserFeedSliver extends ConsumerWidget {
  final String friendId;

  const _UserFeedSliver({required this.friendId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(friendPublicDataProvider(friendId));

    return dataAsync.when(
      loading: () => SliverSkeletonizer(
        child: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => FeedItemWorkoutCard(
              item: FeedItemWorkout(
                workout: Workout(
                  name: BoneMock.chars(Random().nextInt(10) + 5),
                  exercises: [],
                ),
                authorship: FeedAuthorshipFriend(userID: ''),
              ),
            ),
            childCount: 3,
          ),
        ),
      ),
      error: (error, _) =>
          SliverFillRemaining(child: Center(child: Text("Error: $error"))),
      data: (data) {
        final authorship = FeedAuthorshipFriend(userID: friendId);
        final List<FeedItem> items = [
          for (final w in data.workouts)
            FeedItemWorkout(workout: w, authorship: authorship),
          for (final completion in data.achievements)
            if (achievements_data.achievements[completion.achievementID] !=
                null)
              FeedItemAchievement(
                achievement:
                    achievements_data.achievements[completion.achievementID]!,
                completion: completion,
                authorship: authorship,
              ),
        ];

        items.sort((a, b) {
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

        if (items.isEmpty) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: ContentUnavailableView(
                icon: const Icon(Icons.feed_outlined),
                title: Text("feed.empty.title".t),
                description: Text("feed.empty.text".t),
              ),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final item = items[index];
            return SafeArea(
              top: false,
              bottom: false,
              child: FeedItemCard(item: item),
            );
          }, childCount: items.length),
        );
      },
    );
  }
}
