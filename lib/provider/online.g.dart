// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'online.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(currentUserId)
final currentUserIdProvider = CurrentUserIdProvider._();

final class CurrentUserIdProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  CurrentUserIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentUserIdProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentUserIdHash();

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    return currentUserId(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$currentUserIdHash() => r'9b7330105949c6819901461698c03c619088baff';

@ProviderFor(Online)
final onlineProvider = OnlineProvider._();

final class OnlineProvider
    extends $AsyncNotifierProvider<Online, OnlineAccount?> {
  OnlineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onlineProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onlineHash();

  @$internal
  @override
  Online create() => Online();
}

String _$onlineHash() => r'88b6ac3585064f28fa87ce281be8caed1bd6d2e0';

abstract class _$Online extends $AsyncNotifier<OnlineAccount?> {
  FutureOr<OnlineAccount?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<OnlineAccount?>, OnlineAccount?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<OnlineAccount?>, OnlineAccount?>,
              AsyncValue<OnlineAccount?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
