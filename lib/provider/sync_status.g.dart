// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_status.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SyncStatusNotifier)
final syncStatusProvider = SyncStatusNotifierProvider._();

final class SyncStatusNotifierProvider
    extends $NotifierProvider<SyncStatusNotifier, SyncStatus> {
  SyncStatusNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncStatusProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncStatusNotifierHash();

  @$internal
  @override
  SyncStatusNotifier create() => SyncStatusNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncStatus value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncStatus>(value),
    );
  }
}

String _$syncStatusNotifierHash() =>
    r'b1f0b54a5311a78935ff9cbfb0b406cd62fb9c13';

abstract class _$SyncStatusNotifier extends $Notifier<SyncStatus> {
  SyncStatus build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SyncStatus, SyncStatus>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SyncStatus, SyncStatus>,
              SyncStatus,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(deliveryStatus)
final deliveryStatusProvider = DeliveryStatusProvider._();

final class DeliveryStatusProvider
    extends
        $FunctionalProvider<
          AsyncValue<({int conflicts, int errors, int pending})>,
          ({int conflicts, int errors, int pending}),
          Stream<({int conflicts, int errors, int pending})>
        >
    with
        $FutureModifier<({int conflicts, int errors, int pending})>,
        $StreamProvider<({int conflicts, int errors, int pending})> {
  DeliveryStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deliveryStatusProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deliveryStatusHash();

  @$internal
  @override
  $StreamProviderElement<({int conflicts, int errors, int pending})>
  $createElement($ProviderPointer pointer) => $StreamProviderElement(pointer);

  @override
  Stream<({int conflicts, int errors, int pending})> create(Ref ref) {
    return deliveryStatus(ref);
  }
}

String _$deliveryStatusHash() => r'f80f320ca114f4d2ce0abb71bbbc5569ca53fb3c';

@ProviderFor(deletionAlert)
final deletionAlertProvider = DeletionAlertProvider._();

final class DeletionAlertProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  DeletionAlertProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deletionAlertProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deletionAlertHash();

  @$internal
  @override
  $StreamProviderElement<int> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int> create(Ref ref) {
    return deletionAlert(ref);
  }
}

String _$deletionAlertHash() => r'939863ed316b4142c1b84d689b1c50846e59517f';
