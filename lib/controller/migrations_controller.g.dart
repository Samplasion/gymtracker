// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'migrations_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(migrationsController)
final migrationsControllerProvider = MigrationsControllerProvider._();

final class MigrationsControllerProvider
    extends
        $FunctionalProvider<
          MigrationsController,
          MigrationsController,
          MigrationsController
        >
    with $Provider<MigrationsController> {
  MigrationsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'migrationsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$migrationsControllerHash();

  @$internal
  @override
  $ProviderElement<MigrationsController> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MigrationsController create(Ref ref) {
    return migrationsController(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MigrationsController value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MigrationsController>(value),
    );
  }
}

String _$migrationsControllerHash() =>
    r'ea84978255180c6e3591e8b62255868332c5892b';
