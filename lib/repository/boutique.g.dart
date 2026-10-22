// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'boutique.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(boutiqueRepository)
final boutiqueRepositoryProvider = BoutiqueRepositoryProvider._();

final class BoutiqueRepositoryProvider
    extends
        $FunctionalProvider<
          BoutiqueRepository,
          BoutiqueRepository,
          BoutiqueRepository
        >
    with $Provider<BoutiqueRepository> {
  BoutiqueRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'boutiqueRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$boutiqueRepositoryHash();

  @$internal
  @override
  $ProviderElement<BoutiqueRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BoutiqueRepository create(Ref ref) {
    return boutiqueRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BoutiqueRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BoutiqueRepository>(value),
    );
  }
}

String _$boutiqueRepositoryHash() =>
    r'a55182a1fdf80834e0a0418c58c7c432d982c84d';
