import 'package:gymtracker/view/trainer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/provider/friend.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/provider/social.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/components/visible_data_refresh.dart';
import 'package:gymtracker/view/social.dart';
import 'package:gymtracker/view/user_profile.dart';
import 'package:gymtracker/view/utils/social.dart';

String socialNotificationText(
  BuildContext context,
  Map<String, dynamic> n,
) => switch (n['kind']) {
  'trainer_plan' => context.t.social.trainerPlan,
  'friend_request' => context.t.social.friendRequest,
  'friend_accepted' => context.t.social.friendAccepted,
  'like' => context.t.social.likedPost,
  'comment' => context.t.social.commentedPost,
  'achievement' => context.t.social.achievementUnlocked,
  'report_status' =>
    '${context.t.social.reportUpdated}: ${reportStatus(context, (n['params'] as Map)['status'] as String)}',
  _ => context.t.social.notifications,
};

class SocialNotificationsPage extends ConsumerStatefulWidget {
  const SocialNotificationsPage({super.key});
  @override
  ConsumerState<SocialNotificationsPage> createState() =>
      _SocialNotificationsPageState();
}

class _SocialNotificationsPageState
    extends ConsumerState<SocialNotificationsPage> {
  String? markedOwner;
  final List<Map<String, dynamic>> older = [];
  bool loading = false, more = true;
  Future<void> refresh() async {
    ref.invalidate(socialNotificationsProvider);
    ref.invalidate(notificationSummaryProvider);
    await ref.read(friendProvider.notifier).refresh(force: true);
  }

  @override
  Widget build(BuildContext context) {
    final owner = ref.watch(currentUserIdProvider);
    if (owner == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(context.t.social.signIn)),
      );
    }
    final rows = ref.watch(socialNotificationsProvider);
    void mark(List<Map<String, dynamic>>? items) {
      if (items == null || markedOwner == owner) return;
      markedOwner = owner;
      if (items.isEmpty) return;
      final watermark = items.first['id'];
      Future.microtask(() async {
        if (!mounted || ref.read(currentUserIdProvider) != owner) return;
        await socialAction(context, () async {
          await ref.read(markNotificationsReadProvider)(watermark as int);
          ref.invalidate(notificationSummaryProvider);
        });
      });
    }

    ref.listen(socialNotificationsProvider, (_, next) {
      older.clear();
      mark(next.value);
    });
    mark(rows.value);
    return VisibleDataRefresh(
      refresh: refresh,
      child: Scaffold(
        appBar: AppBar(title: Text(context.t.social.notifications)),
        body: RefreshIndicator(
          onRefresh: refresh,
          child: rows.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => ListView(
              children: [
                TextButton(
                  onPressed: refresh,
                  child: Text(context.t.social.error),
                ),
              ],
            ),
            data: (latest) {
              final all =
                  {
                    for (final n in [...older, ...latest]) n['id']: n,
                  }.values.toList()..sort(
                    (a, b) => (b['id'] as int).compareTo(a['id'] as int),
                  );
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  if (all.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(context.t.social.empty),
                    ),
                  for (final n in all)
                    ListTile(
                      leading: n['actor_id'] == null
                          ? const Icon(Icons.notifications_outlined)
                          : UserAccountIcon(id: n['actor_id'] as String),
                      title: n['actor_id'] == null
                          ? Text(context.t.social.notifications)
                          : UserNameText(id: n['actor_id'] as String),
                      subtitle: Text(socialNotificationText(context, n)),
                      onTap: () => socialAction(context, () async {
                        if (n['post_id'] != null) {
                          await ref
                              .read(socialClientProvider)
                              .rpc(
                                'get_social_post',
                                params: {'post': n['post_id']},
                              );
                          if (context.mounted) {
                            Go.to(
                              () => SocialPostPage(
                                postId: n['post_id'] as String,
                              ),
                            );
                          }
                        } else if (n['kind'] == 'trainer_plan') {
                          Go.to(() => const TrainerView());
                        } else if (n['report_id'] != null) {
                          Go.to(() => const SocialSettingsPage(reports: true));
                        } else if (n['actor_id'] != null) {
                          Go.to(
                            () => UserProfilePage(
                              userID: n['actor_id'] as String,
                            ),
                          );
                        }
                      }),
                      trailing: n['kind'] == 'friend_request'
                          ? Wrap(
                              spacing: 8,
                              children: [
                                FilledButton(
                                  onPressed: () =>
                                      socialAction(context, () async {
                                        await ref
                                            .read(friendProvider.notifier)
                                            .acceptFriendRequest(
                                              n['actor_id'] as String,
                                            );
                                        await refresh();
                                      }),
                                  child: Text(context.t.social.accept),
                                ),
                                OutlinedButton(
                                  onPressed: () =>
                                      socialAction(context, () async {
                                        await ref
                                            .read(friendProvider.notifier)
                                            .declineFriendRequest(
                                              n['actor_id'] as String,
                                            );
                                        await refresh();
                                      }),
                                  child: Text(context.t.social.reject),
                                ),
                              ],
                            )
                          : n['read_at'] == null
                          ? const Icon(Icons.circle, size: 8)
                          : null,
                    ),
                  if (loading) const Center(child: CircularProgressIndicator()),
                  if (more && all.isNotEmpty && !loading)
                    TextButton(
                      onPressed: () async {
                        setState(() => loading = true);
                        await socialAction(context, () async {
                          final next = await ref
                              .read(socialClientProvider)
                              .from('notifications')
                              .select()
                              .lt('id', all.last['id'] as int)
                              .order('id', ascending: false)
                              .limit(50);
                          if (mounted &&
                              ref.read(currentUserIdProvider) == owner) {
                            setState(() {
                              older.addAll(next);
                              more = next.length == 50;
                            });
                          }
                        });
                        if (mounted) setState(() => loading = false);
                      },
                      child: Text(context.t.social.more),
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
