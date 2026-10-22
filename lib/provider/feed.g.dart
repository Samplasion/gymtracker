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

String _$feedHistoryStreamHash() => r'9878b381a0329582597dac2a826d667166e9ff76';

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
    r'96322f32145d1a05c39600b2abacab7f531771ce';

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

String _$feedHash() => r'95d4a4f3115a03277c5aab3136aad59dcd97531f';

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
