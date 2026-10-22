// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routines_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(routinesController)
final routinesControllerProvider = RoutinesControllerProvider._();

final class RoutinesControllerProvider
    extends
        $FunctionalProvider<
          RoutinesController,
          RoutinesController,
          RoutinesController
        >
    with $Provider<RoutinesController> {
  RoutinesControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'routinesControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$routinesControllerHash();

  @$internal
  @override
  $ProviderElement<RoutinesController> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RoutinesController create(Ref ref) {
    return routinesController(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RoutinesController value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RoutinesController>(value),
    );
  }
}

String _$routinesControllerHash() =>
    r'cec8dce74b625d3acff1091a4fa735bd081bfc7b';
