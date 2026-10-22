// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(healthPlugin)
final healthPluginProvider = HealthPluginProvider._();

final class HealthPluginProvider
    extends $FunctionalProvider<Health, Health, Health>
    with $Provider<Health> {
  HealthPluginProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'healthPluginProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$healthPluginHash();

  @$internal
  @override
  $ProviderElement<Health> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Health create(Ref ref) {
    return healthPlugin(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Health value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Health>(value),
    );
  }
}

String _$healthPluginHash() => r'e370d700f4f79b9769e3ce868b2ff24d657ef4a0';

@ProviderFor(healthController)
final healthControllerProvider = HealthControllerProvider._();

final class HealthControllerProvider
    extends
        $FunctionalProvider<
          HealthController,
          HealthController,
          HealthController
        >
    with $Provider<HealthController> {
  HealthControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'healthControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$healthControllerHash();

  @$internal
  @override
  $ProviderElement<HealthController> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  HealthController create(Ref ref) {
    return healthController(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HealthController value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HealthController>(value),
    );
  }
}

String _$healthControllerHash() => r'3077e08e7ed9bd543285029bcb181280ad8fd4bd';

@ProviderFor(healthPermission)
final healthPermissionProvider = HealthPermissionProvider._();

final class HealthPermissionProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  HealthPermissionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'healthPermissionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$healthPermissionHash();

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    return healthPermission(ref);
  }
}

String _$healthPermissionHash() => r'707e302c23481c37298cffd9f26e990d1ce6c09a';

@ProviderFor(healthEnergy)
final healthEnergyProvider = HealthEnergyProvider._();

final class HealthEnergyProvider
    extends $FunctionalProvider<AsyncValue<double?>, double?, Stream<double?>>
    with $FutureModifier<double?>, $StreamProvider<double?> {
  HealthEnergyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'healthEnergyProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$healthEnergyHash();

  @$internal
  @override
  $StreamProviderElement<double?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<double?> create(Ref ref) {
    return healthEnergy(ref);
  }
}

String _$healthEnergyHash() => r'2ad10ddcf1a362e4d39510825c7d1452aec80c41';

@ProviderFor(healthHeartRate)
final healthHeartRateProvider = HealthHeartRateProvider._();

final class HealthHeartRateProvider
    extends $FunctionalProvider<AsyncValue<double?>, double?, Stream<double?>>
    with $FutureModifier<double?>, $StreamProvider<double?> {
  HealthHeartRateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'healthHeartRateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$healthHeartRateHash();

  @$internal
  @override
  $StreamProviderElement<double?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<double?> create(Ref ref) {
    return healthHeartRate(ref);
  }
}

String _$healthHeartRateHash() => r'98eed6fbb7173c7a7bbd782bb259d289ba18bb58';
