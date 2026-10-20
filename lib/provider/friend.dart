import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gymtracker/db/model/tables/exercise.dart';
import 'package:gymtracker/db/utils.dart';
import 'package:gymtracker/model/achievements.dart';
import 'package:gymtracker/model/friend.dart';
import 'package:gymtracker/model/history.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/struct/request_cache.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/service/database.dart';
import 'package:get/get.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'friend.g.dart';

class FriendState {
  final List<Friend> friends;
  final List<Friend> pendingReceived;
  final List<Friend> pendingSent;

  FriendState({
    required this.friends,
    required this.pendingReceived,
    required this.pendingSent,
  });

  FriendState copyWith({
    List<Friend>? friends,
    List<Friend>? pendingReceived,
    List<Friend>? pendingSent,
  }) {
    return FriendState(
      friends: friends ?? this.friends,
      pendingReceived: pendingReceived ?? this.pendingReceived,
      pendingSent: pendingSent ?? this.pendingSent,
    );
  }
}

@Riverpod(keepAlive: true)
class FriendNotifier extends _$FriendNotifier {
  final _identities = RequestCache<String, Friend>(const Duration(minutes: 30));
  final _profiles = RequestCache<String, FriendPublicData>(
    const Duration(minutes: 5),
  );
  final _search = RequestCache<String, List<Friend>>(
    const Duration(minutes: 1),
  );
  final _relations = RequestCache<String, FriendState>(
    const Duration(minutes: 5),
  );
  final _identityWaiters = <String, Completer<Friend>>{};
  int _generation = 0;
  bool _scheduled = false;
  bool _identityNotifyScheduled = false;

  @override
  FutureOr<FriendState> build() async {
    ref.watch(currentUserIdProvider);
    _generation++;
    _identities.clear();
    _profiles.clear();
    _search.clear();
    _relations.clear();
    ref.onDispose(() {
      _generation++;
    });
    final account = ref.read(onlineProvider).value;
    ref.listen(onlineProvider, (previous, next) {
      final before = previous?.value;
      final after = next.value;
      if (before == null || after == null || before.id != after.id) return;
      if (before.name != after.name ||
          before.fullName != after.fullName ||
          before.updatedAt != after.updatedAt) {
        invalidateProfile(after.id);
      }
    });
    if (account != null)
      seedIdentity(
        Friend(
          id: account.id,
          username: account.name,
          fullName: account.fullName,
          updatedAt: account.updatedAt,
        ),
      );
    // No authenticated session is a valid empty state; network errors are not.
    if (Supabase.instance.client.auth.currentUser == null)
      return FriendState(friends: [], pendingReceived: [], pendingSent: []);
    try {
      return await _fetchFriendState();
    } catch (_) {
      return _relations.peek('state') ??
          FriendState(friends: [], pendingReceived: [], pendingSent: []);
    }
  }

  void seedIdentity(Friend friend) {
    final previous = _identities.peek(friend.id);
    _identities.put(friend.id, friend);
    if (previous?.username == friend.username &&
        previous?.fullName == friend.fullName &&
        previous?.updatedAt == friend.updatedAt)
      return;
    if (!_identityNotifyScheduled) {
      _identityNotifyScheduled = true;
      scheduleMicrotask(() {
        _identityNotifyScheduled = false;
        if (ref.mounted) ref.read(identityEpochProvider.notifier).bump();
      });
    }
  }

  Future<Friend> getIdentity(String id) => _identities.get(id, () {
    final completer = Completer<Friend>();
    _identityWaiters[id] = completer;
    if (!_scheduled) {
      _scheduled = true;
      scheduleMicrotask(_flushIdentities);
    }
    return completer.future;
  });
  Future<void> _flushIdentities() async {
    _scheduled = false;
    final waiters = Map<String, Completer<Friend>>.from(_identityWaiters);
    _identityWaiters.clear();
    final generation = _generation;
    try {
      final rows = await Supabase.instance.client
          .from('profiles')
          .select('id,username,full_name,updated_at')
          .inFilter('id', waiters.keys.toList());
      if (generation != _generation) throw StateError('Account changed');
      final found = {
        for (final row in rows) row['id'] as String: Friend.fromJson(row),
      };
      for (final e in waiters.entries) {
        final friend = found[e.key];
        if (friend == null) {
          e.value.completeError(StateError('Profile not found'));
        } else {
          e.value.complete(friend);
        }
      }
    } catch (e, st) {
      for (final w in waiters.values) {
        if (!w.isCompleted) w.completeError(e, st);
      }
    }
  }

  Future<void> refresh({bool force = false}) async {
    final generation = _generation;
    final previous =
        state.value?.friends.map((f) => f.id).toSet() ?? <String>{};
    final result = await _relations.get(
      'state',
      _loadFriendState,
      force: force,
    );
    if (generation == _generation && ref.mounted) {
      state = AsyncValue.data(result);
      final accepted = result.friends.map((f) => f.id).toSet();
      for (final changed in {
        ...previous.difference(accepted),
        ...accepted.difference(previous),
      }) {
        invalidateContents(changed);
      }
      if (previous.length != accepted.length ||
          !previous.containsAll(accepted)) {
        ref.read(friendshipChangesProvider.notifier).publish(accepted);
      }
    }
  }

  Future<FriendState> _fetchFriendState() =>
      _relations.get('state', _loadFriendState);
  Future<FriendState> _loadFriendState() async {
    final client = Supabase.instance.client;
    final currentUser = client.auth.currentUser;
    if (currentUser == null) {
      return FriendState(friends: [], pendingReceived: [], pendingSent: []);
    }

    final currentUserId = currentUser.id;

    // Fetch relations
    late final List<dynamic> relations;

    relations = await client
        .from('friends')
        .select()
        .or('sender_id.eq.$currentUserId,receiver_id.eq.$currentUserId');

    final friendIds = <String>{};
    final pendingReceivedIds = <String>{};
    final pendingSentIds = <String>{};

    for (final rel in relations) {
      final senderId = rel['sender_id'] as String;
      final receiverId = rel['receiver_id'] as String;
      final status = rel['status'] as String;

      if (status == 'accepted') {
        friendIds.add(senderId == currentUserId ? receiverId : senderId);
      } else if (status == 'pending') {
        if (senderId == currentUserId) {
          pendingSentIds.add(receiverId);
        } else {
          pendingReceivedIds.add(senderId);
        }
      }
    }

    final allIds = {...friendIds, ...pendingReceivedIds, ...pendingSentIds};
    if (allIds.isEmpty) {
      return FriendState(friends: [], pendingReceived: [], pendingSent: []);
    }

    // Fetch profiles of friends from the profiles table
    final List<dynamic> profilesRes = await client
        .from('profiles')
        .select()
        .inFilter('id', allIds.toList());

    final profilesMap = {
      for (final p in profilesRes)
        p['id'] as String: Friend.fromJson(p as Map<String, dynamic>),
    };

    for (final friend in profilesMap.values) {
      seedIdentity(friend);
    }

    final List<Friend> friends = [];
    final List<Friend> pendingReceived = [];
    final List<Friend> pendingSent = [];

    for (final id in friendIds) {
      if (profilesMap.containsKey(id)) {
        friends.add(profilesMap[id]!);
      }
    }

    for (final id in pendingReceivedIds) {
      if (profilesMap.containsKey(id)) {
        pendingReceived.add(profilesMap[id]!);
      }
    }

    for (final id in pendingSentIds) {
      if (profilesMap.containsKey(id)) {
        pendingSent.add(profilesMap[id]!);
      }
    }

    return FriendState(
      friends: friends,
      pendingReceived: pendingReceived,
      pendingSent: pendingSent,
    );
  }

  Future<void> _mutate(String id, String action) async {
    await refresh();
    final old = state.value!;
    final generation = _generation;
    final client = Supabase.instance.client;
    final owner = client.auth.currentUser?.id;
    if (owner == null || owner == id)
      throw StateError('Invalid friend request');
    final identity = await getIdentity(id);
    if (action == 'send') {
      if ([
        ...old.friends,
        ...old.pendingReceived,
        ...old.pendingSent,
      ].any((f) => f.id == id))
        throw StateError('Friend request already exists');
      await client.from('friends').insert({
        'sender_id': owner,
        'receiver_id': id,
        'status': 'pending',
      }).select();
    } else if (action == 'accept') {
      final rows = await client
          .from('friends')
          .update({'status': 'accepted'})
          .eq('sender_id', id)
          .eq('receiver_id', owner)
          .select();
      if (rows.isEmpty) throw StateError('Friend request no longer exists');
    } else if (action == 'cancel') {
      await client
          .from('friends')
          .delete()
          .eq('sender_id', owner)
          .eq('receiver_id', id)
          .eq('status', 'pending')
          .select();
    } else {
      await client
          .from('friends')
          .delete()
          .or(
            'and(sender_id.eq.$owner,receiver_id.eq.$id),and(sender_id.eq.$id,receiver_id.eq.$owner)',
          )
          .select();
    }
    if (generation != _generation || !ref.mounted) return;
    final result = FriendState(
      friends: [
        ...old.friends.where((f) => action == 'cancel' || f.id != id),
        if (action == 'accept') identity,
      ],
      pendingReceived: old.pendingReceived
          .where((f) => action == 'cancel' || f.id != id)
          .toList(),
      pendingSent: [
        ...old.pendingSent.where((f) => f.id != id),
        if (action == 'send') identity,
      ],
    );
    _relations.put('state', result);
    state = AsyncValue.data(result);
    invalidateContents(id);
    if (action == 'accept' || action == 'remove') {
      ref
          .read(friendshipChangesProvider.notifier)
          .publish(result.friends.map((friend) => friend.id).toSet());
    }
  }

  Future<void> sendFriendRequest(String id) => _mutate(id, 'send');
  Future<void> cancelFriendRequest(String id) => _mutate(id, 'cancel');
  Future<void> acceptFriendRequest(String id) => _mutate(id, 'accept');
  Future<void> declineFriendRequest(String id) => _mutate(id, 'decline');
  Future<void> unfriend(String id) => _mutate(id, 'remove');

  Future<Friend?> searchUserByUsername(String username) async {
    try {
      final client = Supabase.instance.client;
      final response = await client
          .from('profiles')
          .select()
          .eq('username', username)
          .maybeSingle();
      if (response == null) return null;
      return Friend.fromJson(response);
    } catch (_) {
      return null;
    }
  }

  Future<List<Friend>> searchUsers(String query) {
    final key = query.trim().toLowerCase();
    if (key.isEmpty) return Future.value([]);
    return _search.get(key, () async {
      final client = Supabase.instance.client;
      List<dynamic> rows;
      try {
        rows =
            await client
                    .rpc('search_users_weighted', params: {'search_query': key})
                    .limit(15)
                as List;
      } on PostgrestException catch (e) {
        if (e.code != 'PGRST202' && e.code != '42883') rethrow;
        rows = await client
            .from('profiles')
            .select('id,username,full_name,updated_at')
            .ilike('username', '%$key%')
            .limit(15);
      }
      final friends = rows
          .map((r) => Friend.fromJson(Map<String, dynamic>.from(r as Map)))
          .toList();
      for (final f in friends) {
        seedIdentity(f);
      }
      return friends;
    });
  }

  Future<FriendPublicData> getFriendPublicData(
    String id, {
    bool force = false,
  }) => _profiles.get(id, () async {
    final friend = await getIdentity(id);
    final self = id == ref.read(currentUserIdProvider);
    if (!self) await refresh();
    final relations =
        state.value ??
        FriendState(friends: [], pendingReceived: [], pendingSent: []);
    if (self) {
      final db = Get.find<DatabaseService>();
      return FriendPublicData(
        friend: friend,
        achievements:
            (db.completions$.value.toList()
                  ..sort((a, b) => b.completedAt.compareTo(a.completedAt)))
                .take(100)
                .toList(),
        workouts:
            (db.history$.value.toList()..sort(
                  (a, b) => (b.startingDate ?? DateTime(1970)).compareTo(
                    a.startingDate ?? DateTime(1970),
                  ),
                ))
                .take(25)
                .toList(),
        friendCount: relations.friends.length,
      );
    }
    if (!relations.friends.any((f) => f.id == id))
      return FriendPublicData(
        friend: friend,
        achievements: [],
        workouts: [],
        friendCount: 0,
      );
    final result = Map<String, dynamic>.from(
      await Supabase.instance.client.rpc(
            'get_public_profile_v2',
            params: {'profile_id': id},
          )
          as Map,
    );
    final exercises = <String, List<ConcreteExercise>>{};
    for (final row in result['exercises'] as List) {
      final ex = HistoryWorkoutExercise.fromJson(
        Map<String, dynamic>.from(row as Map),
      );
      exercises.putIfAbsent(ex.routineId, () => []).add(ex);
    }
    return FriendPublicData(
      friend: friend,
      achievements: (result['achievements'] as List)
          .map(
            (r) => AchievementCompletion.fromJson(
              Map<String, dynamic>.from(r as Map),
            ),
          )
          .toList(),
      workouts: (result['workouts'] as List).map((r) {
        final w = HistoryWorkout.fromJson(Map<String, dynamic>.from(r as Map));
        return historyWorkoutFromDatabase(
          w,
          exercises[w.id] ?? [],
        ).copyWith.parentID(null);
      }).toList(),
      friendCount: (result['friend_count'] as num).toInt(),
    );
  }, force: force || id == ref.read(currentUserIdProvider));

  Future<String?> getAvatar(String id) async {
    final identity = await getIdentity(id);
    final url = Supabase.instance.client.storage
        .from('profile_pictures')
        .getPublicUrl(id);
    return identity.updatedAt == null
        ? url
        : '$url?v=${Uri.encodeComponent(identity.updatedAt!)}';
  }

  void invalidateAvatarCache(String id) {
    final account = ref.read(onlineProvider).value;
    if (account?.id == id) {
      seedIdentity(
        Friend(
          id: id,
          username: account!.name,
          fullName: account.fullName,
          updatedAt: account.updatedAt,
        ),
      );
    } else {
      _identities.invalidate(id);
    }
    ref.read(userCacheRevisionProvider(id).notifier).identityChanged();
  }

  void invalidateContents(String id) {
    _profiles.invalidate(id);
    ref.read(userCacheRevisionProvider(id).notifier).contentsChanged();
  }

  void invalidateProfile(String id) {
    invalidateAvatarCache(id);
    invalidateContents(id);
  }
}

@riverpod
Future<FriendPublicData> friendPublicData(Ref ref, String friendId) async {
  if (friendId.isEmpty) {
    return FriendPublicData(
      friend: Friend(id: "", username: "Loading...", fullName: null),
      achievements: [],
      workouts: [],
      friendCount: 0,
    );
  }
  final current = ref.watch(currentUserIdProvider);
  ref.watch(
    userCacheRevisionProvider(friendId).select((value) => value.contents),
  );
  if (current == friendId) ref.watch(friendProvider);
  final friendNotifier = ref.watch(friendProvider.notifier);
  return friendNotifier.getFriendPublicData(friendId);
}

@riverpod
Future<Friend> userIdentity(Ref ref, String id) {
  final expiry = Timer(const Duration(minutes: 30), () => ref.invalidateSelf());
  ref.onDispose(expiry.cancel);
  ref.watch(currentUserIdProvider);
  ref.watch(identityEpochProvider);
  ref.watch(userCacheRevisionProvider(id).select((value) => value.identity));
  return ref.watch(friendProvider.notifier).getIdentity(id);
}

@riverpod
Future<String?> userAvatar(Ref ref, String id) {
  ref.watch(userIdentityProvider(id));
  return ref.watch(friendProvider.notifier).getAvatar(id);
}

@riverpod
Future<List<Friend>> userSearch(Ref ref, String query) async {
  ref.watch(currentUserIdProvider);
  var cancelled = false;
  ref.onDispose(() => cancelled = true);
  await Future<void>.delayed(const Duration(milliseconds: 300));
  if (cancelled) return [];
  return ref.read(friendProvider.notifier).searchUsers(query);
}

@Riverpod(keepAlive: true)
class IdentityEpoch extends _$IdentityEpoch {
  @override
  int build() => 0;
  void bump() => state++;
}

/// Independent signals keep cache writers from depending on their consumers.
/// Each signal lives only while the corresponding user is observed.
@riverpod
class UserCacheRevision extends _$UserCacheRevision {
  @override
  ({int identity, int contents}) build(String id) => (identity: 0, contents: 0);

  void identityChanged() =>
      state = (identity: state.identity + 1, contents: state.contents);

  void contentsChanged() =>
      state = (identity: state.identity, contents: state.contents + 1);
}

/// Feed observers receive mutations without starting a separate relation read.
@Riverpod(keepAlive: true)
class FriendshipChanges extends _$FriendshipChanges {
  @override
  Set<String>? build() {
    ref.watch(currentUserIdProvider);
    return null;
  }

  void publish(Set<String> accepted) => state = Set.unmodifiable(accepted);
}
