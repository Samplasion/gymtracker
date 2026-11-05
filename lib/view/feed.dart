import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/model/friend.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/provider/connectivity.dart';
import 'package:gymtracker/provider/feed.dart';
import 'package:gymtracker/provider/friend.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/provider/social.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/utils/skeletons.dart';
import 'package:gymtracker/view/components/content_unavailable.dart';
import 'package:gymtracker/view/components/error_view.dart';
import 'package:gymtracker/view/components/icon_grid.dart';
import 'package:gymtracker/view/components/loading_indicator.dart';
import 'package:gymtracker/view/components/retry_view.dart';
import 'package:gymtracker/view/components/routines.dart';
import 'package:gymtracker/view/exercises.dart';
import 'package:gymtracker/view/login.dart';
import 'package:gymtracker/view/skeleton.dart';
import 'package:gymtracker/view/social_notifications.dart';
import 'package:gymtracker/view/user_profile.dart';
import 'package:gymtracker/view/utils/crossfade.dart';
import 'package:gymtracker/view/utils/feed_items.dart';
import 'package:gymtracker/view/utils/sliver_utils.dart';
import 'package:gymtracker/view/utils/social.dart';
import 'package:sliver_tools/sliver_tools.dart';

class FeedView extends ConsumerStatefulWidget {
  const FeedView({super.key});

  @override
  ConsumerState<FeedView> createState() => _FeedViewState();
}

const _kFakeRoutineSeed = 2001;

class _FeedViewState extends ConsumerState<FeedView>
    with WidgetsBindingObserver {
  Timer? _refreshTimer;
  late Feed _feedNotifier;
  bool _foreground = true;
  @override
  void initState() {
    super.initState();
    _feedNotifier = ref.read(feedProvider.notifier);
    WidgetsBinding.instance.addObserver(this);
    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      if (mounted &&
          _foreground &&
          ModalRoute.of(context)?.isCurrent != false) {
        unawaited(_feedNotifier.refreshIfStale());
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_feedNotifier.refreshIfStale());
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (mounted && _foreground && ModalRoute.of(context)?.isCurrent != false) {
      unawaited(_feedNotifier.refreshIfStale());
      ref.invalidate(socialNotificationsProvider);
      ref.invalidate(sourceSocialProvider);
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _feedNotifier.setVisible(false);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  List<Workout> get fakeWorkouts =>
      List.generate(5, (i) => skeletonWorkout(_kFakeRoutineSeed + i));

  @override
  Widget build(BuildContext context) {
    final feed = ref.watch(feedProvider);
    final feedNotifier = ref.watch(feedProvider.notifier);
    _feedNotifier = feedNotifier;
    feedNotifier.setVisible(ModalRoute.of(context)?.isCurrent ?? true);
    final routinesController = ref.watch(routinesControllerProvider);
    final List<RoutineSuggestion> suggested = routinesController.suggestions
        .take(3)
        .toList();
    final account = ref.watch(onlineProvider);
    final pendingRequestCount = account.value == null
        ? 0
        : (ref.watch(notificationSummaryProvider).value?['unread'] as int? ??
              0);
    final mediaQuery = MediaQuery.of(context);
    // Scaffold's floating FAB accounts for viewPadding, but Skeleton adds
    // the bottom navigation and ongoing workout bar to padding only.
    final bottomBarPadding =
        (mediaQuery.padding.bottom - mediaQuery.viewPadding.bottom).clamp(
          0.0,
          double.infinity,
        );

    return Scaffold(
      floatingActionButtonLocation: .endFloat,
      floatingActionButton: account.value == null
          ? null
          : Padding(
              padding: EdgeInsets.only(bottom: bottomBarPadding),
              child: FloatingActionButton(
                onPressed: () {
                  showSearch(
                    context: context,
                    delegate: ProfileSearchDelegate(
                      ref: ref,
                      searchFieldLabel: context.t.profileSearch.searchHint,
                    ),
                  );
                },
                child: const Icon(GTIcons.search),
              ),
            ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(sourceSocialProvider);
          ref.invalidate(socialNotificationsProvider);
          await Future.wait([
            ref.read(feedProvider.notifier).refresh(),
            if (account.value != null)
              ref.read(friendProvider.notifier).refresh(force: true),
          ]);
        },
        child: CustomScrollView(
          key: const PageStorageKey('feed-scroll'),
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar.large(
              title: Text(context.t.feed.title),
              leading: SkeletonDrawerButton(),
              actions: [
                IconButton(
                  tooltip: context.t.social.notifications,
                  icon: Badge.count(
                    count: pendingRequestCount,
                    isLabelVisible: pendingRequestCount > 0,
                    child: const Icon(GTIcons.notifications),
                  ),
                  onPressed: account.value == null
                      ? null
                      : () {
                          Go.to(() => const SocialNotificationsPage());
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
                    tooltip: context.t.feed.userButton.error,
                    onPressed: () {
                      globalLogger.e(
                        'Unable to load profile',
                        error: error,
                        stackTrace: stackTrace,
                      );
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(context.t.feed.userButton.error),
                          content: Text(context.t.feed.loadError.text),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                unawaited(
                                  ref
                                      .read(onlineProvider.notifier)
                                      .retryAccount(),
                                );
                              },
                              child: Text(context.t.error.retry),
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
                          content: Text(context.t.feed.userButton.loading),
                          showCloseIcon: true,
                        ),
                      );
                    },
                    icon: SizedBox(
                      width: 24.0,
                      height: 24.0,
                      child: GBLoadingIndicator(),
                    ),
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(
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
                    label: Text(context.t.feed.startWorkout),
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
                sliver: SliverStack(
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
                              context.t.feed.suggestedRoutines,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final (routine: workout, score: _) =
                                suggested[index];
                            return Material(
                              type: MaterialType.transparency,
                              key: ValueKey(workout.id),
                              child: ListTile(
                                leading: WorkoutIcon(workout: workout),
                                title: Text(workout.name),
                                subtitle: Text(
                                  context.t.general.exercises(
                                    n: workout.displayExerciseCount,
                                  ),
                                ),
                                onTap: () {
                                  Go.to(() => ExercisesView(workout: workout));
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
            ],
            SliverToBoxAdapter(child: _NoSyncCard()),
            feed.when(
              data: (feedItems) {
                if (feedItems.isEmpty) {
                  return SliverFillRemaining(
                    fillOverscroll: true,
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
                    final item = feedItems[index];
                    return SafeArea(
                      top: false,
                      bottom: false,
                      child: FeedItemCard(
                        item: item,
                        onUserPressed: (id) {
                          if (id != null) {
                            Go.to(() => UserProfilePage(userID: id));
                          }
                        },
                      ),
                    );
                  }, childCount: feedItems.length),
                );
              },
              loading: () => SliverFillRemaining(
                child: Center(child: GBLoadingIndicator()),
              ),
              error: (error, stackTrace) {
                globalLogger.e(
                  'Unable to load feed',
                  error: error,
                  stackTrace: stackTrace,
                );
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: RetryView(
                      title: context.t.feed.loadError.title,
                      description: context.t.feed.loadError.text,
                      onRetry: () async {
                        try {
                          await feedNotifier.refresh();
                        } catch (error, stackTrace) {
                          globalLogger.e(
                            'Unable to refresh feed',
                            error: error,
                            stackTrace: stackTrace,
                          );
                        }
                      },
                    ),
                  ),
                );
              },
            ),
            if (feedNotifier.isLoadingMore) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(child: GBLoadingIndicator()),
                ),
              ),
            ],
            if (feedNotifier.hasMore) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: FilledButton(
                    onPressed: feedNotifier.isLoadingMore
                        ? null
                        : () {
                            feedNotifier.fetchMore();
                            // Due to how we've implemented the load more
                            // mechanism, we need to call setState here to
                            // trigger a rebuild in order to show the
                            // loading indicator while the fetch is in
                            // progress, without hiding the data.
                            setState(() {});
                          },
                    child: Text(context.t.feed.loadMore),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              const SliverBottomSafeArea(),
            ] else ...[
              SliverFillRemaining(
                hasScrollBody: false,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom:
                          MediaQuery.of(context).padding.bottom -
                          MediaQuery.of(context).viewPadding.bottom,
                    ),
                    child: SizedBox(
                      height: 150,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context).scaffoldBackgroundColor,
                                    Theme.of(context)
                                        .colorScheme
                                        .secondaryContainer
                                        .withAlpha(192),
                                  ],
                                  stops: const [0.2, 1],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              child: SizedBox.expand(),
                            ),
                          ),
                          Positioned.fill(
                            child: IconGrid(
                              bigScale: 2,
                              child: CircleAvatar(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.outlineVariant,
                                foregroundColor: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                                child: const Icon(GTIcons.app_icon),
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context).scaffoldBackgroundColor,
                                    Theme.of(context)
                                        .colorScheme
                                        .secondaryContainer
                                        .withAlpha(128),
                                    Theme.of(context)
                                        .colorScheme
                                        .secondaryContainer
                                        .withAlpha(192),
                                  ],
                                  stops: const [0, 0.7, 1],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              child: SizedBox.expand(),
                            ),
                          ),
                          SizedBox(
                            height: 150,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Center(
                                child: Text(
                                  context.t.feed.noMoreData,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSecondaryContainer,
                                      ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ProfileSearchDelegate extends SearchDelegate<Friend?> {
  final WidgetRef ref;

  ProfileSearchDelegate({required this.ref, required super.searchFieldLabel});

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

    return Consumer(
      builder: (context, ref, _) => ref
          .watch(userSearchProvider(query.trim().toLowerCase()))
          .when(
            loading: () => const Center(child: GBLoadingIndicator()),
            error: (error, _) => SingleChildScrollView(
              child: ErrorViewComponent(
                error: error,
                retryCallback: () => ref.invalidate(
                  userSearchProvider(query.trim().toLowerCase()),
                ),
              ),
            ),
            data: (results) {
              if (results.isEmpty) {
                return Center(
                  child: ContentUnavailableView(
                    icon: const Icon(GTIcons.search),
                    title: Text(context.t.profileSearch.noResults.title),
                    description: Text(context.t.profileSearch.noResults.text),
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
          ),
    );
  }
}

class _NoSyncCard extends ConsumerWidget {
  const _NoSyncCard();

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
                  context.t.feed.noSync.text,
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
