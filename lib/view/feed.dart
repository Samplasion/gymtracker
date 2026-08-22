import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/model/friend.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/provider/connectivity.dart';
import 'package:gymtracker/provider/feed.dart';
import 'package:gymtracker/provider/friend.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/service/feed.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/utils/constants.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/utils/skeletons.dart';
import 'package:gymtracker/view/components/content_unavailable.dart';
import 'package:gymtracker/view/components/routines.dart';
import 'package:gymtracker/view/exercises.dart';
import 'package:gymtracker/view/friend_requests.dart';
import 'package:gymtracker/view/login.dart';
import 'package:gymtracker/view/skeleton.dart';
import 'package:gymtracker/view/user_profile.dart';
import 'package:gymtracker/view/utils/crossfade.dart';
import 'package:gymtracker/view/utils/feed_items.dart';
import 'package:gymtracker/view/utils/sliver_utils.dart';
import 'package:gymtracker/view/utils/social.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:sliver_tools/sliver_tools.dart';

class FeedView extends ConsumerStatefulWidget {
  final bool _skeleton;

  const FeedView({super.key}) : _skeleton = false;

  const FeedView.skeleton({super.key}) : _skeleton = true;

  @override
  ConsumerState<FeedView> createState() => _FeedViewState();
}

const _kFakeRoutineSeed = 2001;

class _FeedViewState extends ConsumerState<FeedView> {
  List<Workout> get fakeWorkouts =>
      List.generate(5, (i) => skeletonWorkout(_kFakeRoutineSeed + i));

  @override
  Widget build(BuildContext context) {
    final feed = ref.watch(feedProvider);
    final isLoading = widget._skeleton || feed.isLoading;
    final routinesController = Get.find<RoutinesController>();
    final List<RoutineSuggestion> suggested = isLoading
        ? fakeWorkouts.map((w) => (routine: w, occurrences: 0)).toList()
        : routinesController.suggestions.take(3).toList();
    final account = ref.watch(onlineProvider);

    return Scaffold(
      floatingActionButtonLocation: .endDocked,
      floatingActionButton: account.value == null
          ? null
          : Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom == kNavBarHeight
                    ? kNavBarHeight + kFloatingActionButtonMargin
                    : max(
                        MediaQuery.of(context).padding.bottom -
                            kFloatingActionButtonMargin,
                        kFloatingActionButtonMargin,
                      ),
              ),
              child: FloatingActionButton(
                onPressed: () {
                  showSearch(
                    context: context,
                    delegate: ProfileSearchDelegate(ref: ref),
                  );
                },
                child: const Icon(GTIcons.search),
              ),
            ),
      body: NestedScrollView(
        physics: widget._skeleton ? const NeverScrollableScrollPhysics() : null,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar.large(
            title: Text("feed.title".t),
            leading: SkeletonDrawerButton(),
            actions: [
              IconButton(
                icon: const Icon(GTIcons.friend_requests),
                onPressed: account.value == null
                    ? null
                    : () {
                        Go.to(() => const FriendRequestsPage());
                      },
              ),
              account.when(
                data: (account) => IconButton(
                  icon: UserAccountIcon(id: account?.id),
                  onPressed: () {
                    if (account?.id != null) {
                      Go.to(() => UserProfilePage(userID: account!.id));
                    } else {
                      Go.to(() => const AuthScreen());
                    }
                  },
                ),
                error: (error, stackTrace) => IconButton(
                  icon: const Icon(Icons.error, color: Colors.redAccent),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("Error"),
                        content: Text(error.toString()),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text("OK"),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                loading: () => IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('feed.userButton.loading'.t),
                        showCloseIcon: true,
                      ),
                    );
                  },
                  icon: SizedBox(
                    width: 24.0,
                    height: 24.0,
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
            ],
          ),
        ],
        body: Builder(
          builder: (context) {
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(feedProvider);
                return ref.read(feedProvider.future);
              },
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Skeleton.ignore(
                      ignore: !widget._skeleton,
                      child: SafeArea(
                        top: false,
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: FilledButton.icon(
                            onPressed: () {
                              SkeletonView.of(context)?.goToRoutines();
                            },
                            icon: const Icon(GTIcons.workout),
                            label: Text("feed.startWorkout".t),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (suggested.isNotEmpty) ...[
                    SliverToBoxAdapter(child: SizedBox(height: 4)),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      sliver: SliverSkeletonizer(
                        enabled: isLoading,
                        child: SliverStack(
                          children: [
                            SliverPositioned.fill(
                              child: Card.outlined(
                                clipBehavior: Clip.none,
                                margin: EdgeInsets.zero,
                              ),
                            ),
                            MultiSliver(
                              children: [
                                SliverToBoxAdapter(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ).copyWith(bottom: 8),
                                    child: Text(
                                      "routines.quickWorkout.title".t,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                  ),
                                ),
                                SliverList(
                                  delegate: SliverChildBuilderDelegate((
                                    context,
                                    index,
                                  ) {
                                    final (
                                      routine: workout,
                                      occurrences: frequency,
                                    ) = suggested[index];
                                    return Material(
                                      type: MaterialType.transparency,
                                      key: ValueKey(workout.id),
                                      child: ListTile(
                                        leading: WorkoutIcon(workout: workout),
                                        title: Text(workout.name),
                                        subtitle: Text(
                                          "general.exercises".plural(
                                            workout.displayExerciseCount,
                                          ),
                                        ),
                                        onTap: () {
                                          Go.to(
                                            () =>
                                                ExercisesView(workout: workout),
                                          );
                                        },
                                      ),
                                    );
                                  }, childCount: suggested.length),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  SliverToBoxAdapter(child: _NoSyncCard()),
                  SliverSkeletonizer(
                    enabled: isLoading,
                    child: widget._skeleton
                        ? SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final item = fakeWorkouts[index];
                              return SafeArea(
                                top: false,
                                bottom: false,
                                child: FeedItemWorkoutCard(
                                  item: FeedItemWorkout(
                                    workout: item,
                                    authorship: FeedAuthorshipOwn(),
                                  ),
                                ),
                              );
                            }, childCount: fakeWorkouts.length),
                          )
                        : feed.when(
                            data: (feedItems) {
                              if (feedItems.isEmpty) {
                                return SliverFillRemaining(
                                  fillOverscroll: true,
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
                                delegate: SliverChildBuilderDelegate((
                                  context,
                                  index,
                                ) {
                                  final item = feedItems[index];
                                  return SafeArea(
                                    top: false,
                                    bottom: false,
                                    child: FeedItemCard(
                                      item: item,
                                      onUserPressed: (id) {
                                        if (id != null) {
                                          Go.to(
                                            () => UserProfilePage(userID: id),
                                          );
                                        }
                                      },
                                    ),
                                  );
                                }, childCount: feedItems.length),
                              );
                            },
                            loading: () => SliverFillRemaining(
                              child: Center(child: CircularProgressIndicator()),
                            ),
                            error: (error, stackTrace) => SliverFillRemaining(
                              child: Center(child: Text("Error loading feed")),
                            ),
                          ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 8)),
                  const SliverBottomSafeArea(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class ProfileSearchDelegate extends SearchDelegate<Friend?> {
  final WidgetRef ref;

  ProfileSearchDelegate({required this.ref});

  @override
  String? get searchFieldLabel => "profileSearch.searchHint".t;

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(GTIcons.clear),
          onPressed: () {
            query = '';
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(GTIcons.previousDay),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    if (query.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<List<Friend>>(
      future: ref.read(friendProvider.notifier).searchUsers(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        final results = snapshot.data ?? [];
        if (results.isEmpty) {
          return Center(
            child: ContentUnavailableView(
              icon: const Icon(GTIcons.search),
              title: Text("profileSearch.noResults.title".t),
              description: Text("profileSearch.noResults.text".t),
            ),
          );
        }
        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final friend = results[index];
            return ListTile(
              leading: UserAccountIcon(id: friend.id),
              title: Text(friend.fullName ?? friend.username),
              subtitle: Text("@${friend.username}"),
              onTap: () {
                close(context, friend);
                Go.to(() => UserProfilePage(userID: friend.id));
              },
            );
          },
        );
      },
    );
  }
}

class _NoSyncCard extends ConsumerWidget {
  const _NoSyncCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isConnected = ref.watch(networkConnectivityProvider).value ?? false;
    if (isConnected) {
      return const SizedBox.shrink();
    }

    return Crossfade(
      firstChild: const SizedBox.shrink(),
      secondChild: Card.outlined(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Icon(Icons.wifi_off, color: Colors.redAccent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "feed.noSync.text".t,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.redAccent),
                ),
              ),
            ],
          ),
        ),
      ),
      showSecond: isConnected,
    );
  }
}
