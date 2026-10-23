import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/model/friend.dart';
import 'package:gymtracker/provider/friend_achievement_history.dart';
import 'package:gymtracker/view/components/achievement_history_tile.dart';
import 'package:gymtracker/view/components/content_unavailable.dart';
import 'package:gymtracker/view/components/error_view.dart';
import 'package:gymtracker/view/components/loading_indicator.dart';
import 'package:gymtracker/view/components/visible_data_refresh.dart';

class FriendAchievementHistoryPage extends ConsumerWidget {
  const FriendAchievementHistoryPage({super.key, required this.friend});
  final Friend friend;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = friendAchievementHistoryProvider(friend.id);
    final history = ref.watch(provider);
    final notifier = ref.read(provider.notifier);
    return VisibleDataRefresh(
      refresh: notifier.refreshIfStale,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            context.t.friendsList.historyTitle(
              name: friend.fullName ?? friend.username,
            ),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: notifier.refresh,
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              final page = history.value;
              if (notification.metrics.extentAfter < 300 &&
                  page != null &&
                  !page.accessDenied &&
                  page.pageError == null) {
                unawaited(notifier.loadMore());
              }
              return false;
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: history.when(
                loading: () => [
                  const SliverFillRemaining(
                    child: Center(child: GBLoadingIndicator()),
                  ),
                ],
                error: (error, _) => [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: ErrorViewComponent(
                        error: error is AchievementHistoryAccessDenied
                            ? context.t.friendsList.accessDenied
                            : error,
                        retryCallback: notifier.refresh,
                      ),
                    ),
                  ),
                ],
                data: (page) => [
                  if (page.accessDenied)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: ErrorViewComponent(
                          error: context.t.friendsList.accessDenied,
                          retryCallback: notifier.refresh,
                        ),
                      ),
                    )
                  else if (page.items.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: ContentUnavailableView(
                        icon: const Icon(Icons.emoji_events_outlined),
                        title: Text(context.t.friendsList.historyEmpty),
                        description: Text(
                          context.t.friendsList.historyEmptyDescription,
                        ),
                      ),
                    )
                  else
                    SliverList.builder(
                      itemCount: page.items.length,
                      itemBuilder: (context, index) =>
                          AchievementHistoryTile(completion: page.items[index]),
                    ),
                  if (page.pageError != null)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(context.t.error.title),
                            TextButton(
                              onPressed:
                                  page.retryRefresh || page.nextCursor == null
                                  ? notifier.refresh
                                  : notifier.loadMore,
                              child: Text(context.t.error.retry),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (page.nextCursor != null)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: page.loadingMore
                              ? const GBLoadingIndicator()
                              : TextButton(
                                  onPressed: notifier.loadMore,
                                  child: Text(context.t.friendsList.loadMore),
                                ),
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(
                    child: SafeArea(top: false, child: SizedBox(height: 8)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
