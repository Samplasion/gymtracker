// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appDatabase)
final appDatabaseProvider = AppDatabaseProvider._();

final class AppDatabaseProvider
    extends $FunctionalProvider<GTDatabase, GTDatabase, GTDatabase>
    with $Provider<GTDatabase> {
  AppDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appDatabaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appDatabaseHash();

  @$internal
  @override
  $ProviderElement<GTDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GTDatabase create(Ref ref) {
    return appDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GTDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GTDatabase>(value),
    );
  }
}

String _$appDatabaseHash() => r'08f3d781260413ff760c3e90799506620e36008b';
