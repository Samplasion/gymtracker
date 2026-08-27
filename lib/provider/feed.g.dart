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

String _$feedHistoryStreamHash() => r'054c36e52921af57f0cee90d2fed4fdea1831a55';

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
    r'a20aa0cb3faaeb47a7a65e75ccdb69635353f4b1';

@ProviderFor(feedUserStream)
final feedUserStreamProvider = FeedUserStreamProvider._();

final class FeedUserStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<OnlineAccount?>,
          OnlineAccount?,
          Stream<OnlineAccount?>
        >
    with $FutureModifier<OnlineAccount?>, $StreamProvider<OnlineAccount?> {
  FeedUserStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'feedUserStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$feedUserStreamHash();

  @$internal
  @override
  $StreamProviderElement<OnlineAccount?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<OnlineAccount?> create(Ref ref) {
    return feedUserStream(ref);
  }
}

String _$feedUserStreamHash() => r'0b46bdf08c83b49dd1bb6ee71878c1910e73a5c0';

@ProviderFor(Feed)
final feedProvider = FeedProvider._();

final class FeedProvider extends $AsyncNotifierProvider<Feed, List<FeedItem>> {
  FeedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'feedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$feedHash();

  @$internal
  @override
  Feed create() => Feed();
}

String _$feedHash() => r'f46c23432a554a51c916acb9c1622497d739ec1b';

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
