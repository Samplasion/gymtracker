// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'error_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(errorController)
final errorControllerProvider = ErrorControllerProvider._();

final class ErrorControllerProvider
    extends
        $FunctionalProvider<ErrorController, ErrorController, ErrorController>
    with $Provider<ErrorController> {
  ErrorControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'errorControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$errorControllerHash();

  @$internal
  @override
  $ProviderElement<ErrorController> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ErrorController create(Ref ref) {
    return errorController(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ErrorController value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ErrorController>(value),
    );
  }
}

String _$errorControllerHash() => r'fe2f261729802bffd343f86fcc56394a3a94a4f8';
