import 'dart:async';

import 'package:gymtracker/db/model/tables/exercise.dart';
import 'package:gymtracker/db/utils.dart';
import 'package:gymtracker/model/achievements.dart';
import 'package:gymtracker/model/friend.dart';
import 'package:gymtracker/model/history.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/struct/cache.dart';
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
  final Map<String, CachedData<String?>> _avatarCache = {};
  final Map<String, CachedData<FriendPublicData>> _friendPublicDataCache = {};

  @override
  FutureOr<FriendState> build() async {
    _avatarCache.clear();
    _friendPublicDataCache.clear();
    return _fetchFriendState();
  }

  Future<FriendState> _fetchFriendState() async {
    final client = Supabase.instance.client;
    final currentUser = client.auth.currentUser;
    if (currentUser == null) {
      return FriendState(friends: [], pendingReceived: [], pendingSent: []);
    }

    final currentUserId = currentUser.id;

    // Fetch relations
    final List<dynamic> relations = await client
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

  Future<void> sendFriendRequest(String receiverId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final client = Supabase.instance.client;
      final currentUserId = client.auth.currentUser?.id;
      if (currentUserId == null) throw Exception("User not logged in");

      if (currentUserId == receiverId) {
        throw Exception("Cannot send friend request to yourself");
      }

      // Check if a friend request already exists
      final existingRequest = await client
          .from('friends')
          .select()
          .or('sender_id.eq.$currentUserId,receiver_id.eq.$currentUserId')
          .or('sender_id.eq.$receiverId,receiver_id.eq.$receiverId');

      if (existingRequest.isNotEmpty) {
        throw Exception("Friend request already sent");
      }

      await client.from('friends').insert({
        'sender_id': currentUserId,
        'receiver_id': receiverId,
        'status': 'pending',
      });
      return _fetchFriendState();
    });
  }

  Future<void> acceptFriendRequest(String senderId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final client = Supabase.instance.client;
      final currentUserId = client.auth.currentUser?.id;
      if (currentUserId == null) throw Exception("User not logged in");

      await client
          .from('friends')
          .update({'status': 'accepted'})
          .eq('sender_id', senderId)
          .eq('receiver_id', currentUserId);
      return _fetchFriendState();
    });
  }

  Future<void> declineFriendRequest(String senderId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final client = Supabase.instance.client;
      final currentUserId = client.auth.currentUser?.id;
      if (currentUserId == null) throw Exception("User not logged in");

      await client
          .from('friends')
          .delete()
          .eq('sender_id', senderId)
          .eq('receiver_id', currentUserId);
      return _fetchFriendState();
    });
  }

  Future<void> unfriend(String friendId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final client = Supabase.instance.client;
      final currentUserId = client.auth.currentUser?.id;
      if (currentUserId == null) throw Exception("User not logged in");

      await client
          .from('friends')
          .delete()
          .eq('sender_id', currentUserId)
          .eq('receiver_id', friendId);

      await client
          .from('friends')
          .delete()
          .eq('sender_id', friendId)
          .eq('receiver_id', currentUserId);

      // Invalidate caches for the unfriended user.
      _avatarCache.remove(friendId);
      _friendPublicDataCache.remove(friendId);

      return _fetchFriendState();
    });
  }

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

  Future<List<Friend>> searchUsers(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];
    final client = Supabase.instance.client;
    try {
      final response = await client
          .rpc('search_users_weighted', params: {'search_query': trimmed})
          .limit(15);
      return (response as List)
          .map((json) => Friend.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (_) {
      try {
        final response = await client
            .from('profiles')
            .select()
            .ilike('username', '%$trimmed%')
            .limit(15);
        return (response as List)
            .map((json) => Friend.fromJson(json as Map<String, dynamic>))
            .toList();
      } catch (_) {
        return [];
      }
    }
  }

  Future<FriendPublicData> getFriendPublicData(String friendId) async {
    // Return a fresh cached entry if available.
    final cached = _friendPublicDataCache[friendId];
    if (cached != null && !cached.isExpired) {
      return cached.data;
    }

    final client = Supabase.instance.client;

    // 1. Fetch profile of the friend from the profiles table
    final profileRes = await client
        .from('profiles')
        .select()
        .eq('id', friendId)
        .single();
    final friend = Friend.fromJson(profileRes);

    // 2. Fetch public achievement completions (non-deleted)
    final achievementsRes = await client
        .from('achievements_v2')
        .select()
        .eq('user_id', friendId)
        .eq('deleted', false)
        .order('completed_at', ascending: false)
        .limit(100);
    final achievements = achievementsRes
        .map((json) => AchievementCompletion.fromJson(json))
        .toList();

    // 3. Fetch public workouts with their exercises
    final workoutsRes = await client
        .from('history_workouts')
        .select()
        .eq('user_id', friendId)
        .eq('deleted', false)
        .isFilter('completes', null)
        .order('starting_date', ascending: false)
        .limit(25);
    final historyWorkouts = workoutsRes
        .map((json) => HistoryWorkout.fromJson(json))
        .toList();

    final workoutIds = historyWorkouts.map((w) => w.id).toList();
    final exercisesResponse = workoutIds.isEmpty
        ? <dynamic>[]
        : await client
              .from('history_workout_exercises')
              .select()
              .inFilter('routine_id', workoutIds)
              .eq('deleted', false);

    final exercisesByWorkout = <String, List<ConcreteExercise>>{};
    for (final row in exercisesResponse) {
      final exercise = HistoryWorkoutExercise.fromJson(
        row as Map<String, dynamic>,
      );
      exercisesByWorkout
          .putIfAbsent(exercise.routineId, () => <ConcreteExercise>[])
          .add(exercise);
    }

    final workouts = <Workout>[
      for (final hw in historyWorkouts)
        historyWorkoutFromDatabase(
          hw,
          exercisesByWorkout[hw.id] ?? <ConcreteExercise>[],
        ).copyWith.parentID(null),
    ];

    final friendRelationsRes = await client
        .from('friends')
        .select()
        .or('sender_id.eq.$friendId,receiver_id.eq.$friendId')
        .eq('status', 'accepted');
    final friendCount = (friendRelationsRes as List).length;

    final result = FriendPublicData(
      friend: friend,
      achievements: achievements,
      workouts: workouts,
      friendCount: friendCount,
    );

    _friendPublicDataCache[friendId] = CachedData(DateTime.now(), result);
    return result;
  }

  Future<String?> getAvatar(String userID) async {
    // Return a fresh cached entry if available.
    final cached = _avatarCache[userID];
    if (cached != null && !cached.isExpired) {
      return cached.data;
    }

    final client = Supabase.instance.client;
    final link = client.storage.from('profile_pictures').getPublicUrl(userID);
    final cacheBusterLink = "$link?t=${DateTime.now().millisecondsSinceEpoch}";
    _avatarCache[userID] = CachedData(DateTime.now(), cacheBusterLink);
    return cacheBusterLink;
  }

  void invalidateAvatarCache(String userID) {
    _avatarCache.remove(userID);
    _friendPublicDataCache.remove(userID);
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
  final friendNotifier = ref.watch(friendProvider.notifier);
  return friendNotifier.getFriendPublicData(friendId);
}
