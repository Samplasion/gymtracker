import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/model/achievements.dart';
import 'package:gymtracker/provider/friend.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'friend_achievement_history.g.dart';

/// Preserve the server cursor verbatim, including timestamp precision.
typedef AchievementCursor = Map<String, dynamic>;

class AchievementHistoryPage {
  const AchievementHistoryPage({
    required this.items,
    this.nextCursor,
    this.loadingMore = false,
    this.pageError,
    this.retryRefresh = false,
    this.accessDenied = false,
  });
  final List<AchievementCompletion> items;
  final AchievementCursor? nextCursor;
  final bool loadingMore;
  final Object? pageError;
  final bool retryRefresh;
  final bool accessDenied;
}

typedef AchievementPageLoader =
    Future<AchievementHistoryPage> Function(
      String friendId,
      AchievementCursor? cursor,
    );

final achievementPageLoaderProvider = Provider<AchievementPageLoader>((ref) {
  return (friendId, cursor) async {
    final result = Map<String, dynamic>.from(
      await Supabase.instance.client.rpc(
            'get_achievement_history',
            params: {
              'profile_id': friendId,
              'before_completed_at': cursor?['completed_at'],
              'before_id': cursor?['id'],
            },
          )
          as Map,
    );
    return AchievementHistoryPage(
      items: (result['items'] as List)
          .map(
            (row) => AchievementCompletion.fromJson(
              Map<String, dynamic>.from(row as Map),
            ),
          )
          .toList(),
      nextCursor: result['next_cursor'] == null
          ? null
          : Map<String, dynamic>.from(result['next_cursor'] as Map),
    );
  };
});

class AchievementHistoryAccessDenied implements Exception {
  const AchievementHistoryAccessDenied();
}

@riverpod
class FriendAchievementHistory extends _$FriendAchievementHistory {
  int _generation = 0;
  bool _busy = false;
  DateTime? _fetchedAt;

  bool _isDenied(Object error) =>
      error is AchievementHistoryAccessDenied ||
      error is PostgrestException && error.code == '42501';

  void _deny() {
    _generation++;
    _busy = false;
    state = const AsyncData(
      AchievementHistoryPage(items: [], accessDenied: true),
    );
  }

  @override
  Future<AchievementHistoryPage> build(String friendId) async {
    final owner = ref.watch(currentUserIdProvider);
    final generation = ++_generation;
    _busy = false;
    _fetchedAt = null;
    ref.onDispose(() => _generation++);
    ref.listen(friendProvider, (_, next) {
      if (owner != friendId &&
          next.hasValue &&
          !next.requireValue.friends.any((f) => f.id == friendId)) {
        _deny();
      }
    });
    if (owner == null) {
      return const AchievementHistoryPage(items: [], accessDenied: true);
    }
    final friends = await ref.read(friendProvider.future);
    if (owner != friendId && !friends.friends.any((f) => f.id == friendId)) {
      return const AchievementHistoryPage(items: [], accessDenied: true);
    }
    if (!ref.mounted || generation != _generation) {
      return const AchievementHistoryPage(items: [], accessDenied: true);
    }
    try {
      final page = await ref.read(achievementPageLoaderProvider)(
        friendId,
        null,
      );
      if (!ref.mounted || generation != _generation) {
        return const AchievementHistoryPage(items: [], accessDenied: true);
      }
      _fetchedAt = DateTime.now();
      return page;
    } catch (error) {
      if (_isDenied(error)) {
        return const AchievementHistoryPage(items: [], accessDenied: true);
      }
      rethrow;
    }
  }

  Future<void> refreshIfStale() async {
    if (_fetchedAt != null &&
        DateTime.now().difference(_fetchedAt!) < const Duration(minutes: 5)) {
      return;
    }
    await refresh();
  }

  Future<void> refresh() async {
    if (_busy || state.isLoading) return;
    _busy = true;
    final generation = ++_generation;
    final previous = state.value;
    if (previous == null) state = const AsyncLoading();
    try {
      await ref.read(friendProvider.notifier).refresh(force: true);
      if (!ref.mounted || generation != _generation) return;
      final relations = ref.read(friendProvider).value;
      if (ref.read(currentUserIdProvider) != friendId &&
          !(relations?.friends.any((f) => f.id == friendId) ?? false)) {
        _deny();
        return;
      }
      final page = await ref.read(achievementPageLoaderProvider)(
        friendId,
        null,
      );
      if (!ref.mounted || generation != _generation) return;
      _fetchedAt = DateTime.now();
      state = AsyncData(page);
    } catch (error, stack) {
      if (!ref.mounted || generation != _generation) return;
      if (_isDenied(error)) {
        _deny();
      } else if (previous != null) {
        state = AsyncData(
          AchievementHistoryPage(
            items: previous.items,
            nextCursor: previous.nextCursor,
            pageError: error,
            retryRefresh: true,
          ),
        );
      } else {
        state = AsyncError(error, stack);
      }
    } finally {
      if (generation == _generation) _busy = false;
    }
  }

  Future<void> loadMore() async {
    final previous = state.value;
    if (_busy || previous == null || previous.nextCursor == null) return;
    _busy = true;
    final generation = _generation;
    state = AsyncData(
      AchievementHistoryPage(
        items: previous.items,
        nextCursor: previous.nextCursor,
        loadingMore: true,
      ),
    );
    try {
      final page = await ref.read(achievementPageLoaderProvider)(
        friendId,
        previous.nextCursor,
      );
      if (!ref.mounted || generation != _generation) return;
      final items = {
        for (final item in [...previous.items, ...page.items]) item.id: item,
      };
      state = AsyncData(
        AchievementHistoryPage(
          items: List.unmodifiable(items.values),
          nextCursor: page.nextCursor,
        ),
      );
    } catch (error) {
      if (!ref.mounted || generation != _generation) return;
      if (_isDenied(error)) {
        _deny();
      } else {
        state = AsyncData(
          AchievementHistoryPage(
            items: previous.items,
            nextCursor: previous.nextCursor,
            pageError: error,
          ),
        );
      }
    } finally {
      if (generation == _generation) _busy = false;
    }
  }
}
