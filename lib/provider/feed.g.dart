// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(feedHistoryStream)
final feedHistoryStreamProvider = FeedHistoryStreamProvider._();

final class FeedHistoryStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Workout>>,
          List<Workout>,
          Stream<List<Workout>>
        >
    with $FutureModifier<List<Workout>>, $StreamProvider<List<Workout>> {
  FeedHistoryStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'feedHistoryStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$feedHistoryStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<Workout>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Workout>> create(Ref ref) {
    return feedHistoryStream(ref);
  }
}

String _$feedHistoryStreamHash() => r'df9a9d9c7e1ec38f2e7716709c2fc00360505c8e';

@ProviderFor(feedAchievementsStream)
final feedAchievementsStreamProvider = FeedAchievementsStreamProvider._();

final class FeedAchievementsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AchievementCompletion>>,
          List<AchievementCompletion>,
          Stream<List<AchievementCompletion>>
        >
    with
        $FutureModifier<List<AchievementCompletion>>,
        $StreamProvider<List<AchievementCompletion>> {
  FeedAchievementsStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'feedAchievementsStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$feedAchievementsStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<AchievementCompletion>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AchievementCompletion>> create(Ref ref) {
    return feedAchievementsStream(ref);
  }
}

String _$feedAchievementsStreamHash() =>
    r'e4b3b6e481e054cc5ba9fcb21a254eb453e77ec3';

@ProviderFor(Feed)
final feedProvider = FeedProvider._();

final class FeedProvider extends $AsyncNotifierProvider<Feed, List<FeedItem>> {
  FeedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'feedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$feedHash();

  @$internal
  @override
  Feed create() => Feed();
}

String _$feedHash() => r'22c79bbe11c532cce4273e4a970655bba7c5a8e1';

abstract class _$Feed extends $AsyncNotifier<List<FeedItem>> {
  FutureOr<List<FeedItem>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<FeedItem>>, List<FeedItem>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<FeedItem>>, List<FeedItem>>,
              AsyncValue<List<FeedItem>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
