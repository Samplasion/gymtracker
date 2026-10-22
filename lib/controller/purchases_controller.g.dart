// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchases_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(purchasesController)
final purchasesControllerProvider = PurchasesControllerProvider._();

final class PurchasesControllerProvider
    extends
        $FunctionalProvider<
          PurchasesController,
          PurchasesController,
          PurchasesController
        >
    with $Provider<PurchasesController> {
  PurchasesControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'purchasesControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$purchasesControllerHash();

  @$internal
  @override
  $ProviderElement<PurchasesController> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PurchasesController create(Ref ref) {
    return purchasesController(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PurchasesController value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PurchasesController>(value),
    );
  }
}

String _$purchasesControllerHash() =>
    r'fd6155551bcf4b3953269af9e85abe7dbdc40b92';

@ProviderFor(subscriptionInfo)
final subscriptionInfoProvider = SubscriptionInfoProvider._();

final class SubscriptionInfoProvider
    extends
        $FunctionalProvider<
          AsyncValue<SubscriptionInfo>,
          SubscriptionInfo,
          Stream<SubscriptionInfo>
        >
    with $FutureModifier<SubscriptionInfo>, $StreamProvider<SubscriptionInfo> {
  SubscriptionInfoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'subscriptionInfoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$subscriptionInfoHash();

  @$internal
  @override
  $StreamProviderElement<SubscriptionInfo> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<SubscriptionInfo> create(Ref ref) {
    return subscriptionInfo(ref);
  }
}

String _$subscriptionInfoHash() => r'baab4bfc686be7ab814e1cf1c780dcfe1be79de1';
