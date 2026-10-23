import 'dart:async';

import 'package:drift/drift.dart' show Variable;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/provider/db.dart';
import 'package:gymtracker/provider/feed.dart';
import 'package:gymtracker/provider/friend.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

typedef SocialSource = ({String owner, String source, String kind});
final socialClientProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);
final sourceSocialProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>?, SocialSource>((ref, source) async {
      ref.watch(sourcePublicationPendingProvider(source));
      final expiry = Timer(const Duration(minutes: 1), ref.invalidateSelf);
      ref.onDispose(expiry.cancel);
      if (ref.watch(currentUserIdProvider) == null) return null;
      final result = await ref
          .watch(socialClientProvider)
          .rpc(
            'get_source_social',
            params: {
              'owner': source.owner,
              'source': source.source,
              'source_kind': source.kind,
            },
          );
      return result == null ? null : Map<String, dynamic>.from(result as Map);
    });
final postContentProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, String>((ref, id) async {
      ref.watch(currentUserIdProvider);
      return Map<String, dynamic>.from(
        await ref
                .watch(socialClientProvider)
                .rpc('get_social_post', params: {'post': id})
            as Map,
      );
    });

/// Realtime is an invalidation signal. Read again under RLS instead of trusting
/// payloads cached before a friendship or block changed.
final socialNotificationsProvider =
    StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) async* {
      final owner = ref.watch(currentUserIdProvider);
      if (owner == null) {
        yield [];
        return;
      }
      final client = ref.watch(socialClientProvider);
      final signals = StreamController<void>();
      void refresh() {
        if (!signals.isClosed) signals.add(null);
      }

      final channel = client.channel('social-inbox-$owner')
        ..onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: owner,
          ),
          callback: (_) => refresh(),
        )
        ..onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'user_blocks',
          callback: (_) => refresh(),
        )
        ..subscribe();
      final timer = Timer.periodic(
        const Duration(minutes: 1),
        (_) => refresh(),
      );
      ref.onDispose(() {
        timer.cancel();
        unawaited(client.removeChannel(channel));
        unawaited(signals.close());
      });
      Future<List<Map<String, dynamic>>> load() async => await client
          .from('notifications')
          .select()
          .order('id', ascending: false)
          .limit(50);
      yield await load();
      await for (final _ in signals.stream) {
        try {
          yield await load();
        } catch (_) {
          /* Retry on the next signal, retaining the previous page. */
        }
      }
    });
final notificationSummaryProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
      ref.watch(socialNotificationsProvider);
      if (ref.watch(currentUserIdProvider) == null) {
        return {'unread': 0, 'through_id': 0};
      }
      return Map<String, dynamic>.from(
        await ref.watch(socialClientProvider).rpc('notification_summary')
            as Map,
      );
    });
final blockedUsersProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      if (ref.watch(currentUserIdProvider) == null) return [];
      return (await ref.watch(socialClientProvider).rpc('list_blocked_users')
              as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    });
final reportsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((
  ref,
) async {
  final owner = ref.watch(currentUserIdProvider);
  if (owner == null) return [];
  return await ref
      .watch(socialClientProvider)
      .from('reports')
      .select()
      .eq('reporter_id', owner)
      .order('created_at', ascending: false);
});

final socialAccessListenerProvider = Provider<void>((ref) {
  final owner = ref.watch(currentUserIdProvider);
  if (owner == null) return;
  final client = ref.watch(socialClientProvider);
  final channel = client.channel('social-access-$owner')
    ..onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'social_revisions',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'user_id',
        value: owner,
      ),
      callback: (_) {
        if (!ref.mounted) return;
        ref.invalidate(friendProvider);
        ref.invalidate(userSearchProvider);
        ref.invalidate(userIdentityProvider);
        ref.invalidate(userAvatarProvider);
        ref.invalidate(friendPublicDataProvider);
        ref.invalidate(feedProvider);
        ref.invalidate(sourceSocialProvider);
        ref.invalidate(postContentProvider);
        ref.invalidate(socialNotificationsProvider);
      },
    )
    ..subscribe();
  ref.onDispose(() => unawaited(client.removeChannel(channel)));
});

final sourcePublicationPendingProvider = StreamProvider.autoDispose
    .family<bool, SocialSource>((ref, source) {
      if (ref.watch(currentUserIdProvider) != source.owner) {
        return Stream.value(false);
      }
      final db = ref.watch(appDatabaseProvider);
      return db
          .customSelect(
            "SELECT EXISTS(SELECT 1 FROM sync_outbox WHERE owner=? AND ((entity=? AND record_id=?) OR (entity='history_workout_exercises' AND json_extract(payload,'\$.routine_id')=?))) AS pending",
            variables: [
              Variable(source.owner),
              Variable(
                source.kind == 'workout'
                    ? 'history_workouts'
                    : 'achievements_v2',
              ),
              Variable(source.source),
              Variable(source.kind == 'workout' ? source.source : ''),
            ],
            readsFrom: db.allTables.toSet(),
          )
          .watch()
          .map((rows) => rows.single.read<int>('pending') != 0);
    });

final markNotificationsReadProvider = Provider<Future<void> Function(int)>(
  (ref) => (throughId) async {
    await ref
        .read(socialClientProvider)
        .rpc('read_notifications', params: {'through_id': throughId});
  },
);
