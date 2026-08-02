// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(feed)
final feedProvider = FeedProvider._();

final class FeedProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<FeedItem>>,
          List<FeedItem>,
          FutureOr<List<FeedItem>>
        >
    with $FutureModifier<List<FeedItem>>, $FutureProvider<List<FeedItem>> {
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
  $FutureProviderElement<List<FeedItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<FeedItem>> create(Ref ref) {
    return feed(ref);
  }
}

String _$feedHash() => r'86dd2768550858687dabc58bad47661f0e0520c7';
