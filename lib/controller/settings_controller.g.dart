// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(settingsControllerInstance)
final settingsControllerInstanceProvider =
    SettingsControllerInstanceProvider._();

final class SettingsControllerInstanceProvider
    extends
        $FunctionalProvider<
          SettingsController,
          SettingsController,
          SettingsController
        >
    with $Provider<SettingsController> {
  SettingsControllerInstanceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsControllerInstanceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsControllerInstanceHash();

  @$internal
  @override
  $ProviderElement<SettingsController> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SettingsController create(Ref ref) {
    return settingsControllerInstance(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettingsController value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettingsController>(value),
    );
  }
}

String _$settingsControllerInstanceHash() =>
    r'14f28729363f1389a3a753549e0a6dd426316507';
