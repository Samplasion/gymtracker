import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/provider/feed.dart';
import 'package:gymtracker/service/feed.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/utils/skeletons.dart';
import 'package:gymtracker/view/components/content_unavailable.dart';
import 'package:gymtracker/view/components/routines.dart';
import 'package:gymtracker/view/exercises.dart';
import 'package:gymtracker/view/skeleton.dart';
import 'package:gymtracker/view/utils/achievements.dart';
import 'package:gymtracker/view/utils/history_workout.dart';
import 'package:gymtracker/view/utils/sliver_utils.dart';
import 'package:gymtracker/view/utils/social.dart';
import 'package:intl/intl.dart';
import 'package:relative_time/relative_time.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:sliver_tools/sliver_tools.dart';

class FeedView extends StatefulWidget {
  final bool _skeleton;

  const FeedView({super.key}) : _skeleton = false;

  const FeedView.skeleton({super.key}) : _skeleton = true;

  @override
  State<FeedView> createState() => _FeedViewState();
}

const _kFakeRoutineSeed = 2001;

class _FeedViewState extends State<FeedView> {
  List<Workout> get fakeWorkouts =>
      List.generate(5, (i) => skeletonWorkout(_kFakeRoutineSeed + i));

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final isLoading = widget._skeleton || ref.watch(feedProvider).isLoading;
        final routinesController = Get.find<RoutinesController>();
        final List<RoutineSuggestion> suggested = isLoading
            ? fakeWorkouts.map((w) => (routine: w, occurrences: 0)).toList()
            : routinesController.suggestions.take(3).toList();
        final feed = ref.watch(feedProvider);
        return NestedScrollView(
          physics: widget._skeleton
              ? const NeverScrollableScrollPhysics()
              : null,
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar.large(
              title: Text("feed.title".t),
              leading: SkeletonDrawerButton(),
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
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
                    ],
                    SliverSkeletonizer(
                      enabled: feed.isLoading || widget._skeleton,
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
                                  child: _FeedItemWorkoutWidget(
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
                                      child: switch (item) {
                                        FeedItemWorkout() =>
                                          _FeedItemWorkoutWidget(item: item),
                                        FeedItemAchievement() =>
                                          _FeedItemAchievementWidget(
                                            item: item,
                                          ),
                                        // ignore: unreachable_switch_case
                                        _ =>
                                          kDebugMode
                                              ? ListTile(
                                                  title: Text(
                                                    "Unknown item $item",
                                                  ),
                                                )
                                              : const SizedBox.shrink(),
                                      },
                                    );
                                  }, childCount: feedItems.length),
                                );
                              },
                              loading: () => SliverFillRemaining(
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              error: (error, stackTrace) => SliverFillRemaining(
                                child: Center(
                                  child: Text("Error loading feed"),
                                ),
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
        );
      },
    );
  }
}

class _FeedItemWorkoutWidget extends StatelessWidget {
  final FeedItemWorkout item;

  const _FeedItemWorkoutWidget({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          ListTile(
            leading: UserAccountIcon(),
            title: Row(
              crossAxisAlignment: .center,
              children: [
                Expanded(
                  child: switch (item.authorship) {
                    FeedAuthorshipOwn() => Text("feed.workout.title.you".t),
                    FeedAuthorshipFriend(:String friendID) => Text(friendID),
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
              textAlign: .start,
            ),
            onTap: () {
              Go.to(() => ExercisesView(workout: item.workout));
            },
          ),
        ],
      ),
    );
  }
}

class _FeedItemAchievementWidget extends StatelessWidget {
  final FeedItemAchievement item;

  const _FeedItemAchievementWidget({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          ListTile(
            leading: UserAccountIcon(),
            title: Row(
              crossAxisAlignment: .center,
              children: [
                Expanded(
                  child: switch (item.authorship) {
                    FeedAuthorshipOwn() => Text("feed.achievement.title.you".t),
                    FeedAuthorshipFriend(:String friendID) => Text(friendID),
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
              padding: const EdgeInsets.all(8.0),
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
