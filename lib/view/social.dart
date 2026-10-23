import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/db/model/tables/exercise.dart';
import 'package:gymtracker/db/utils.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/model/achievements.dart';
import 'package:gymtracker/model/history.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/provider/achievement_metadata.dart';
import 'package:gymtracker/provider/feed.dart';
import 'package:gymtracker/provider/friend.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/provider/social.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/service/feed.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/components/visible_data_refresh.dart';
import 'package:gymtracker/view/user_profile.dart';
import 'package:gymtracker/view/utils/feed_items.dart';
import 'package:gymtracker/view/utils/social.dart';

Future<void> socialAction(
  BuildContext context,
  Future<void> Function() action,
) async {
  try {
    await action();
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.t.social.error)));
    }
  }
}

Future<String?> socialText(
  BuildContext context,
  String title, {
  String initial = '',
}) async {
  final controller = TextEditingController(text: initial);
  final result = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        maxLength: 2000,
        minLines: 2,
        maxLines: 6,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.t.social.cancel),
        ),
        TextButton(
          onPressed: () {
            if (controller.text.trim().isNotEmpty) {
              Navigator.pop(context, controller.text.trim());
            }
          },
          child: Text(context.t.social.send),
        ),
      ],
    ),
  );
  controller.dispose();
  return result;
}

Future<String?> showCommentComposer(
  BuildContext context, {
  String initial = '',
  String? title,
}) => showModalBottomSheet<String>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  showDragHandle: true,
  builder: (_) => CommentComposer(initial: initial, title: title),
);

class CommentComposer extends StatefulWidget {
  const CommentComposer({super.key, this.initial = '', this.title});
  final String initial;
  final String? title;
  @override
  State<CommentComposer> createState() => _CommentComposerState();
}

class _CommentComposerState extends State<CommentComposer> {
  late final controller = TextEditingController(text: widget.initial);
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = controller.text.trim();
    return AnimatedPadding(
      duration: const Duration(milliseconds: 150),
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.title ?? context.t.social.comment,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                maxLength: 2000,
                minLines: 3,
                maxLines: 8,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(context.t.social.cancel),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: text.isEmpty || text.runes.length > 2000
                        ? null
                        : () => Navigator.pop(context, text),
                    icon: const Icon(Icons.send),
                    label: Text(context.t.social.send),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> changeWorkoutVisibility(
  BuildContext context,
  WidgetRef ref,
  Workout workout,
) async {
  final database = ref.read(databaseServiceProvider);
  final owner = database.db.currentUserId;
  final current = database.getHistoryWorkout(workout.id);
  if (current == null || !current.isConcrete) return;
  final visibility = await showDialog<String>(
    context: context,
    builder: (_) => WorkoutVisibilityDialog(visibility: current.visibility),
  );
  if (visibility == null ||
      !context.mounted ||
      database.db.currentUserId != owner) {
    return;
  }
  final latest = database.getHistoryWorkout(workout.id);
  if (latest == null || latest.visibility == visibility) return;
  await socialAction(context, () async {
    await database.setHistoryWorkout(latest.copyWith(visibility: visibility));
    if (context.mounted) ref.invalidate(sourceSocialProvider);
  });
}

class WorkoutVisibilityDialog extends StatefulWidget {
  const WorkoutVisibilityDialog({super.key, required this.visibility});
  final String visibility;
  @override
  State<WorkoutVisibilityDialog> createState() =>
      _WorkoutVisibilityDialogState();
}

class _WorkoutVisibilityDialogState extends State<WorkoutVisibilityDialog> {
  late String visibility = widget.visibility;
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(context.t.social.visibility),
    content: RadioGroup<String>(
      groupValue: visibility,
      onChanged: (value) {
        if (value != null) setState(() => visibility = value);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RadioListTile<String>(
            value: 'private',
            title: Text(context.t.social.private),
            contentPadding: EdgeInsets.zero,
          ),
          RadioListTile<String>(
            value: 'friends',
            title: Text(context.t.social.friends),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(context.t.social.cancel),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(context, visibility),
        child: Text(context.t.social.save),
      ),
    ],
  );
}

class WorkoutVisibilityMenu extends ConsumerWidget {
  const WorkoutVisibilityMenu({super.key, required this.workout});
  final Workout workout;
  @override
  Widget build(BuildContext context, WidgetRef ref) => PopupMenuButton<String>(
    tooltip: context.t.social.visibility,
    onSelected: (_) => changeWorkoutVisibility(context, ref, workout),
    itemBuilder: (_) => [
      PopupMenuItem(
        value: 'visibility',
        child: Text(context.t.social.visibility),
      ),
    ],
  );
}

class PostActions extends ConsumerStatefulWidget {
  const PostActions({super.key, required this.source, this.workout});
  final SocialSource source;
  final Workout? workout;
  @override
  ConsumerState<PostActions> createState() => _PostActionsState();
}

class _PostActionsState extends ConsumerState<PostActions> {
  bool busy = false;
  @override
  Widget build(BuildContext context) {
    final owner = ref.watch(currentUserIdProvider);
    if (owner == null) return const SizedBox.shrink();
    final social = ref.watch(sourceSocialProvider(widget.source));
    final own = owner == widget.source.owner;
    final local = widget.workout;
    final private = local?.visibility == 'private';
    final data = social.value;
    final post = data?['post'] as Map?;
    final active = post?['active'] == true && !private;
    final pending =
        own &&
        (ref.watch(sourcePublicationPendingProvider(widget.source)).value ??
            false);
    final mismatch =
        own &&
        (social.hasValue && (post == null || post['active'] != !private));
    return Column(
      children: [
        if (mismatch || pending)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              private ? context.t.social.pending : context.t.social.unpublished,
            ),
          ),
        if (social.hasError)
          TextButton(
            onPressed: () =>
                ref.invalidate(sourceSocialProvider(widget.source)),
            child: Text(context.t.social.error),
          ),
        if (active)
          Row(
            children: [
              TextButton.icon(
                onPressed: busy
                    ? null
                    : () async {
                        setState(() => busy = true);
                        await socialAction(context, () async {
                          final client = ref.read(socialClientProvider);
                          if (data!['liked'] == true) {
                            await client
                                .from('likes')
                                .delete()
                                .eq('post_id', post!['id'] as String)
                                .eq('user_id', owner);
                          } else {
                            await client.from('likes').insert({
                              'post_id': post!['id'],
                              'user_id': owner,
                            });
                          }
                          ref.invalidate(sourceSocialProvider(widget.source));
                        });
                        if (mounted) setState(() => busy = false);
                      },
                icon: Icon(
                  data?['liked'] == true
                      ? Icons.favorite
                      : Icons.favorite_border,
                ),
                label: Text('${data?["likes"] ?? 0}'),
              ),
              TextButton.icon(
                onPressed: () =>
                    Go.to(() => SocialPostPage(postId: post!['id'] as String)),
                icon: const Icon(Icons.comment_outlined),
                label: Text('${data?["comments"] ?? 0}'),
              ),
            ],
          ),
      ],
    );
  }
}

class SocialPostPage extends ConsumerStatefulWidget {
  const SocialPostPage({super.key, required this.postId});
  final String postId;
  @override
  ConsumerState<SocialPostPage> createState() => _SocialPostPageState();
}

class _SocialPostPageState extends ConsumerState<SocialPostPage> {
  final List<Map<String, dynamic>> comments = [];
  bool loading = false, more = true;
  int commentGeneration = 0;
  Object? error;
  @override
  void initState() {
    super.initState();
    Future.microtask(() => load(reset: true));
  }

  Future<void> load({bool reset = false}) async {
    if (loading && !reset) return;
    final generation = ++commentGeneration;
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final owner = ref.read(currentUserIdProvider);
      final last = reset || comments.isEmpty ? null : comments.last;
      final rows =
          await ref
                  .read(socialClientProvider)
                  .rpc(
                    'list_post_comments',
                    params: {
                      'post': widget.postId,
                      'after_at': last?['created_at'],
                      'after_id': last?['id'],
                    },
                  )
              as List;
      if (!mounted ||
          generation != commentGeneration ||
          owner != ref.read(currentUserIdProvider)) {
        return;
      }
      setState(() {
        if (reset) comments.clear();
        comments.addAll(rows.map((e) => Map<String, dynamic>.from(e as Map)));
        more = rows.length == 50;
      });
    } catch (e) {
      if (mounted && generation == commentGeneration) setState(() => error = e);
    } finally {
      if (mounted && generation == commentGeneration) {
        setState(() => loading = false);
      }
    }
  }

  FeedItem? item(Map<String, dynamic> data) {
    final p = data['post'] as Map;
    final content = Map<String, dynamic>.from(data['content'] as Map);
    final authorship = p['user_id'] == ref.read(currentUserIdProvider)
        ? FeedAuthorshipOwn(userID: p['user_id'] as String)
        : FeedAuthorshipFriend(userID: p['user_id'] as String);
    if (p['kind'] == 'workout') {
      return FeedItemWorkout(
        workout: historyWorkoutFromDatabase(
          HistoryWorkout.fromJson(content),
          (data['exercises'] as List)
              .map(
                (e) => HistoryWorkoutExercise.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList(),
        ),
        authorship: authorship,
      );
    }
    final completion = AchievementCompletion.fromJson(content);
    final achievement = ref.read(
      achievementMetadataProvider,
    )[completion.achievementID];
    return achievement == null
        ? null
        : FeedItemAchievement(
            achievement: achievement,
            completion: completion,
            authorship: authorship,
          );
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
    final data = ref.watch(postContentProvider(widget.postId));
    ref.listen(postContentProvider(widget.postId), (_, next) {
      if (next.isLoading) {
        commentGeneration++;
        comments.clear();
        loading = false;
      }
      if (next.hasValue && !next.isLoading) {
        load(reset: true);
      }
    });
    return Scaffold(
      appBar: AppBar(title: Text(context.t.social.post)),
      body: data.when(
        skipLoadingOnRefresh: false,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text(context.t.social.unavailable)),
        data: (data) {
          final feedItem = item(data);
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(postContentProvider(widget.postId));
              await load(reset: true);
            },
            child: ListView(
              children: [
                if (feedItem != null) FeedItemCard(item: feedItem),
                ListTile(
                  title: Text(context.t.social.comments),
                  trailing: IconButton(
                    icon: const Icon(Icons.add_comment_outlined),
                    onPressed: (data['post'] as Map)['active'] != true
                        ? null
                        : () async {
                            final text = await showCommentComposer(context);
                            if (text == null || !context.mounted) return;
                            await socialAction(context, () async {
                              await ref
                                  .read(socialClientProvider)
                                  .from('comments')
                                  .insert({
                                    'post_id': widget.postId,
                                    'body': text,
                                    'user_id': owner,
                                  });
                              ref.invalidate(sourceSocialProvider);
                              await load(reset: true);
                            });
                          },
                  ),
                ),
                for (final c in comments)
                  ListTile(
                    leading: GestureDetector(
                      onTap: () => Go.to(
                        () => UserProfilePage(userID: c['user_id'] as String),
                      ),
                      child: UserAccountIcon(id: c['user_id'] as String),
                    ),
                    title: UserNameText(id: c['user_id'] as String),
                    subtitle: Text(c['body'] as String),
                    trailing:
                        c['user_id'] == owner ||
                            (data['post'] as Map)['user_id'] == owner
                        ? PopupMenuButton<String>(
                            itemBuilder: (_) => [
                              if (c['user_id'] == owner)
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Text(context.t.social.edit),
                                ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text(context.t.social.delete),
                              ),
                            ],
                            onSelected: (action) async {
                              String? text;
                              if (action == 'edit') {
                                text = await showCommentComposer(
                                  context,
                                  title: context.t.social.edit,
                                  initial: c['body'] as String,
                                );
                                if (text == null) return;
                              }
                              if (!context.mounted) return;
                              await socialAction(context, () async {
                                final query = ref
                                    .read(socialClientProvider)
                                    .from('comments');
                                if (action == 'delete') {
                                  await query.delete().eq(
                                    'id',
                                    c['id'] as String,
                                  );
                                } else {
                                  await query
                                      .update({'body': text})
                                      .eq('id', c['id'] as String);
                                }
                                ref.invalidate(sourceSocialProvider);
                                await load(reset: true);
                              });
                            },
                          )
                        : null,
                  ),
                if (error != null)
                  TextButton(
                    onPressed: () => load(reset: comments.isEmpty),
                    child: Text(context.t.social.error),
                  ),
                if (loading) const Center(child: CircularProgressIndicator()),
                if (more && !loading)
                  TextButton(
                    onPressed: () => load(),
                    child: Text(context.t.social.more),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

Future<void> blockUser(
  BuildContext context,
  WidgetRef ref,
  String target, {
  bool blocked = true,
}) async {
  if (blocked) {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(context.t.social.blockConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.t.social.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.t.social.confirm),
          ),
        ],
      ),
    );
    if (accepted != true) return;
  }
  if (!context.mounted) return;
  await socialAction(context, () async {
    await ref
        .read(socialClientProvider)
        .rpc('set_user_block', params: {'target': target, 'blocked': blocked});
    ref.invalidate(friendProvider);
    ref.invalidate(userSearchProvider);
    ref.invalidate(userIdentityProvider);
    ref.invalidate(userAvatarProvider);
    ref.invalidate(friendPublicDataProvider);
    ref.invalidate(feedProvider);
    ref.invalidate(sourceSocialProvider);
    ref.invalidate(postContentProvider);
    ref.invalidate(blockedUsersProvider);
    ref.invalidate(socialNotificationsProvider);
    if (blocked && context.mounted) Navigator.maybePop(context);
  });
}

Future<void> reportUser(
  BuildContext context,
  WidgetRef ref,
  String target,
) async {
  final reason = await socialText(context, context.t.social.reason);
  if (reason == null || !context.mounted) return;
  await socialAction(context, () async {
    await ref
        .read(socialClientProvider)
        .rpc('submit_report', params: {'target': target, 'reason': reason});
    ref.invalidate(reportsProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.t.social.reportSent)));
    }
  });
}

class SocialSettingsPage extends ConsumerWidget {
  const SocialSettingsPage({super.key, this.reports = false});
  final bool reports;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final owner = ref.watch(currentUserIdProvider);
    if (owner == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(context.t.social.signIn)),
      );
    }
    final data = reports
        ? ref.watch(reportsProvider)
        : ref.watch(blockedUsersProvider);
    return VisibleDataRefresh(
      refresh: () async {
        ref.invalidate(reports ? reportsProvider : blockedUsersProvider);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            reports ? context.t.social.reports : context.t.social.blockedUsers,
          ),
        ),
        body: data.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => Center(child: Text(context.t.social.error)),
          data: (rows) => rows.isEmpty
              ? Center(child: Text(context.t.social.empty))
              : ListView(
                  children: [
                    for (final row in rows)
                      ListTile(
                        title: Text(
                          reports
                              ? row['reason'] as String
                              : row['username'] as String,
                        ),
                        subtitle: reports
                            ? Text(
                                reportStatus(context, row['status'] as String),
                              )
                            : null,
                        trailing: reports
                            ? null
                            : TextButton(
                                onPressed: () => blockUser(
                                  context,
                                  ref,
                                  row['id'] as String,
                                  blocked: false,
                                ),
                                child: Text(context.t.social.unblock),
                              ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}

String reportStatus(BuildContext context, String status) => switch (status) {
  'received' => context.t.social.received,
  'reviewing' => context.t.social.reviewing,
  'resolved' => context.t.social.resolved,
  'dismissed' => context.t.social.dismissed,
  _ => context.t.social.unavailable,
};
