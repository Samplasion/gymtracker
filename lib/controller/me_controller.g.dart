// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'me_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Supplied by the application lifecycle; retained separately from measurement data.

@ProviderFor(weightChanged)
final weightChangedProvider = WeightChangedProvider._();

/// Supplied by the application lifecycle; retained separately from measurement data.

final class WeightChangedProvider
    extends
        $FunctionalProvider<void Function(), void Function(), void Function()>
    with $Provider<void Function()> {
  /// Supplied by the application lifecycle; retained separately from measurement data.
  WeightChangedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'weightChangedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$weightChangedHash();

  @$internal
  @override
  $ProviderElement<void Function()> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  void Function() create(Ref ref) {
    return weightChanged(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void Function() value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void Function()>(value),
    );
  }
}

String _$weightChangedHash() => r'47719fd3af5747fbbe9a5ece476ab76236e3b421';

@ProviderFor(meController)
final meControllerProvider = MeControllerProvider._();

final class MeControllerProvider
    extends $FunctionalProvider<MeController, MeController, MeController>
    with $Provider<MeController> {
  MeControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'meControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$meControllerHash();

  @$internal
  @override
  $ProviderElement<MeController> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MeController create(Ref ref) {
    return meController(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MeController value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MeController>(value),
    );
  }
}

String _$meControllerHash() => r'a485f1e21c96855b9af7a0be916ac0742bfccdb1';
