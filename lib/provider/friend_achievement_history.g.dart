// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friend_achievement_history.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FriendAchievementHistory)
final friendAchievementHistoryProvider = FriendAchievementHistoryFamily._();

final class FriendAchievementHistoryProvider
    extends
        $AsyncNotifierProvider<
          FriendAchievementHistory,
          AchievementHistoryPage
        > {
  FriendAchievementHistoryProvider._({
    required FriendAchievementHistoryFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'friendAchievementHistoryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$friendAchievementHistoryHash();

  @override
  String toString() {
    return r'friendAchievementHistoryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  FriendAchievementHistory create() => FriendAchievementHistory();

  @override
  bool operator ==(Object other) {
    return other is FriendAchievementHistoryProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$friendAchievementHistoryHash() =>
    r'bec5a7f96d41da36a430b8fc67fb378b30872e67';

final class FriendAchievementHistoryFamily extends $Family
    with
        $ClassFamilyOverride<
          FriendAchievementHistory,
          AsyncValue<AchievementHistoryPage>,
          AchievementHistoryPage,
          FutureOr<AchievementHistoryPage>,
          String
        > {
  FriendAchievementHistoryFamily._()
    : super(
        retry: null,
        name: r'friendAchievementHistoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FriendAchievementHistoryProvider call(String friendId) =>
      FriendAchievementHistoryProvider._(argument: friendId, from: this);

  @override
  String toString() => r'friendAchievementHistoryProvider';
}

abstract class _$FriendAchievementHistory
    extends $AsyncNotifier<AchievementHistoryPage> {
  late final _$args = ref.$arg as String;
  String get friendId => _$args;

  FutureOr<AchievementHistoryPage> build(String friendId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<AchievementHistoryPage>, AchievementHistoryPage>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<AchievementHistoryPage>,
                AchievementHistoryPage
              >,
              AsyncValue<AchievementHistoryPage>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
