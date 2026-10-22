import 'dart:math';
import 'package:gymtracker/view/components/visible_data_refresh.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/provider/achievement_metadata.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/model/friend.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/provider/connectivity.dart';
import 'package:gymtracker/provider/friend.dart';
import 'package:gymtracker/provider/feed.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/service/feed.dart';
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
    if (online.value?.id == userID) {
      ref.listen(feedHistoryStreamProvider, (_, __) {
        ref.read(friendProvider.notifier).invalidateContents(userID);
      });
      ref.listen(feedAchievementsStreamProvider, (_, __) {
        ref.read(friendProvider.notifier).invalidateContents(userID);
      });
    }
    final connectivityStatus = ref.watch(networkConnectivityProvider).value;

    if (connectivityStatus != true &&
        online.value?.id != userID &&
        !friendObject.hasValue) {
      return _buildErrorBody(
        context,
        ref,
        error: context.t.userProfile.errors.noInternet,
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

    return VisibleDataRefresh(
      refresh: () async {
        await ref.read(friendProvider.notifier).refresh();
        await ref.read(friendProvider.notifier).getFriendPublicData(userID);
        if (context.mounted) ref.invalidate(friendPublicDataProvider(userID));
      },
      child: Scaffold(
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
                error: (error, _) =>
                    _buildErrorBody(context, ref, error: error),
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
            title: Text(friend.fullName ?? context.t.userProfile.title),
            pinned: true,
            actions: [
              if (isSelf)
                IconButton(
                  tooltip: context.t.userProfile.edit.tooltip,
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
                await ref.read(friendProvider.notifier).refresh(force: true);
                if (!context.mounted) return;
                await ref
                    .read(friendProvider.notifier)
                    .getFriendPublicData(friend.id, force: true);
                if (!context.mounted) return;
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
                                    child: GTBadge(content: context.t.you),
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
                                label: context.t.userProfile.stats.friends,
                              ),
                              Stats(
                                value: "${friendData.workouts.length}",
                                label: context.t.userProfile.stats.workouts,
                              ),
                              Stats(
                                value: "${friendData.achievements.length}",
                                label: context.t.userProfile.stats.achievements,
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
                          title: Text(
                            context.t.userProfile.feed.unavailable.title,
                          ),
                          description: Text(
                            context.t.userProfile.feed.unavailable.description,
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
      appBar: AppBar(title: Text(context.t.userProfile.title)),
      body: Center(
        child: ErrorViewComponent(
          error: error,
          retryCallback: () async {
            await ref.read(friendProvider.notifier).refresh(force: true);
            if (!context.mounted) return;
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

class _FriendActionButtons extends ConsumerStatefulWidget {
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
  ConsumerState<_FriendActionButtons> createState() =>
      _FriendActionButtonsState();
}

class _FriendActionButtonsState extends ConsumerState<_FriendActionButtons> {
  bool _cancellingRequest = false;

  @override
  Widget build(BuildContext context) {
    final friend = widget.friend;
    final notifier = ref.read(friendProvider.notifier);

    if (widget.isFriend) {
      return OutlinedButton.icon(
        onPressed: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              icon: const Icon(GTIcons.profile),
              title: Text(
                context.t.userProfile.unfriendConfirmation.title(
                  name: friend.fullName ?? friend.username,
                ),
              ),
              content: Text(
                context.t.userProfile.unfriendConfirmation.subtitle,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: Text(
                    context.t.userProfile.unfriendConfirmation.cancel,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: Text(
                    context.t.userProfile.unfriendConfirmation.confirm,
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
        label: Text(context.t.userProfile.unfriend),
      );
    }

    if (widget.isPendingSent) {
      return FilledButton.tonal(
        onPressed: _cancellingRequest
            ? null
            : () async {
                setState(() => _cancellingRequest = true);
                try {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(
                        context.t.userProfile.cancelRequestConfirmation.title,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: Text(
                            context
                                .t
                                .userProfile
                                .cancelRequestConfirmation
                                .keep,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: Text(
                            context
                                .t
                                .userProfile
                                .cancelRequestConfirmation
                                .confirm,
                            style: TextStyle(
                              color: Theme.of(ctx).colorScheme.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true && mounted) {
                    await notifier.cancelFriendRequest(friend.id);
                  }
                } catch (_) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          context.t.userProfile.cancelRequestConfirmation.error,
                        ),
                      ),
                    );
                  }
                } finally {
                  if (mounted) setState(() => _cancellingRequest = false);
                }
              },
        child: Text(context.t.userProfile.requestSent),
      );
    }

    if (widget.isPendingReceived) {
      return Row(
        children: [
          FilledButton(
            onPressed: () async {
              await notifier.acceptFriendRequest(friend.id);
            },
            child: Text(context.t.userProfile.accept),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: () async {
              await notifier.declineFriendRequest(friend.id);
            },
            child: Text(context.t.userProfile.reject),
          ),
        ],
      );
    }

    return FilledButton.icon(
      onPressed: () async {
        await notifier.sendFriendRequest(friend.id);
      },
      icon: const Icon(GTIcons.profile),
      label: Text(context.t.userProfile.addFriend),
    );
  }
}

class _UserFeedSliver extends ConsumerWidget {
  final String friendId;

  const _UserFeedSliver({required this.friendId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(friendPublicDataProvider(friendId));
    final achievementCatalog = ref.watch(achievementMetadataProvider);

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
            if (achievementCatalog[completion.achievementID] != null)
              FeedItemAchievement(
                achievement: achievementCatalog[completion.achievementID]!,
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
                title: Text(context.t.feed.empty.title),
                description: Text(context.t.feed.empty.text),
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
