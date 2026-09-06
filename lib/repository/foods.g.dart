// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'foods.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(foodsRepository)
final foodsRepositoryProvider = FoodsRepositoryProvider._();

final class FoodsRepositoryProvider
    extends
        $FunctionalProvider<FoodsRepository, FoodsRepository, FoodsRepository>
    with $Provider<FoodsRepository> {
  FoodsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'foodsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$foodsRepositoryHash();

  @$internal
  @override
  $ProviderElement<FoodsRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FoodsRepository create(Ref ref) {
    return foodsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FoodsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FoodsRepository>(value),
    );
  }
}

String _$foodsRepositoryHash() => r'41d12f649c781443a139ea624edefc088b221c63';
