import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/provider/friend.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/components/content_unavailable.dart';
import 'package:gymtracker/view/components/error_view.dart';
import 'package:gymtracker/view/components/loading_indicator.dart';
import 'package:gymtracker/view/components/visible_data_refresh.dart';
import 'package:gymtracker/view/user_profile.dart';
import 'package:gymtracker/view/utils/social.dart';

class FriendsPage extends ConsumerStatefulWidget {
  const FriendsPage({super.key});

  @override
  ConsumerState<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends ConsumerState<FriendsPage> {
  Object? _refreshError;

  Future<void> _refresh({bool force = false}) async {
    try {
      await ref.read(friendProvider.notifier).refresh(force: force);
      if (mounted) setState(() => _refreshError = null);
    } catch (error) {
      if (mounted) setState(() => _refreshError = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    Future<void> refresh() => _refresh(force: true);
    final friends = ref.watch(friendProvider);
    return VisibleDataRefresh(
      refresh: () => _refresh(force: _refreshError != null),
      child: Scaffold(
        appBar: AppBar(title: Text(context.t.friendsList.title)),
        body: RefreshIndicator(
          onRefresh: refresh,
          child: friends.when(
            loading: () => const Center(child: GBLoadingIndicator()),
            error: (error, _) => ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                ErrorViewComponent(error: error, retryCallback: refresh),
              ],
            ),
            data: (state) {
              final sorted = [...state.friends]
                ..sort((a, b) {
                  final name = (a.fullName ?? a.username)
                      .toLowerCase()
                      .compareTo((b.fullName ?? b.username).toLowerCase());
                  return name != 0 ? name : a.username.compareTo(b.username);
                });
              return CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  if (_refreshError != null)
                    SliverToBoxAdapter(
                      child: ErrorViewComponent(
                        error: _refreshError,
                        retryCallback: refresh,
                      ),
                    ),
                  if (sorted.isEmpty && _refreshError == null)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: ContentUnavailableView(
                        icon: const Icon(Icons.people_outline),
                        title: Text(context.t.friendsList.empty),
                        description: Text(
                          context.t.friendsList.emptyDescription,
                        ),
                      ),
                    )
                  else
                    SliverList.builder(
                      itemCount: sorted.length,
                      itemBuilder: (context, index) {
                        final friend = sorted[index];
                        return ListTile(
                          leading: UserAccountIcon(id: friend.id),
                          title: Text(friend.fullName ?? friend.username),
                          subtitle: Text('@${friend.username}'),
                          onTap: () =>
                              Go.to(() => UserProfilePage(userID: friend.id)),
                        );
                      },
                    ),
                  const SliverToBoxAdapter(
                    child: SafeArea(top: false, child: SizedBox(height: 8)),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
