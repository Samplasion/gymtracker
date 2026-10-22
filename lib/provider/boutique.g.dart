// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'boutique.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(boutiqueController)
final boutiqueControllerProvider = BoutiqueControllerProvider._();

final class BoutiqueControllerProvider
    extends
        $FunctionalProvider<
          BoutiqueController,
          BoutiqueController,
          BoutiqueController
        >
    with $Provider<BoutiqueController> {
  BoutiqueControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'boutiqueControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$boutiqueControllerHash();

  @$internal
  @override
  $ProviderElement<BoutiqueController> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BoutiqueController create(Ref ref) {
    return boutiqueController(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BoutiqueController value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BoutiqueController>(value),
    );
  }
}

String _$boutiqueControllerHash() =>
    r'3ecce90ef18c3e4ba39c7f10fdd7b91ad2f6b7dc';

@ProviderFor(boutiqueSettings)
final boutiqueSettingsProvider = BoutiqueSettingsProvider._();

final class BoutiqueSettingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<BoutiqueSettings>,
          BoutiqueSettings,
          FutureOr<BoutiqueSettings>
        >
    with $FutureModifier<BoutiqueSettings>, $FutureProvider<BoutiqueSettings> {
  BoutiqueSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'boutiqueSettingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$boutiqueSettingsHash();

  @$internal
  @override
  $FutureProviderElement<BoutiqueSettings> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<BoutiqueSettings> create(Ref ref) {
    return boutiqueSettings(ref);
  }
}

String _$boutiqueSettingsHash() => r'aa2faf67d4b153fd9a533d4cae0bf123f2b1ada6';

@ProviderFor(boutiqueCategories)
final boutiqueCategoriesProvider = BoutiqueCategoriesProvider._();

final class BoutiqueCategoriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<BoutiqueResponse<List<BoutiqueCategory>, BoutiqueError>>,
          BoutiqueResponse<List<BoutiqueCategory>, BoutiqueError>,
          FutureOr<BoutiqueResponse<List<BoutiqueCategory>, BoutiqueError>>
        >
    with
        $FutureModifier<
          BoutiqueResponse<List<BoutiqueCategory>, BoutiqueError>
        >,
        $FutureProvider<
          BoutiqueResponse<List<BoutiqueCategory>, BoutiqueError>
        > {
  BoutiqueCategoriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'boutiqueCategoriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$boutiqueCategoriesHash();

  @$internal
  @override
  $FutureProviderElement<
    BoutiqueResponse<List<BoutiqueCategory>, BoutiqueError>
  >
  $createElement($ProviderPointer pointer) => $FutureProviderElement(pointer);

  @override
  FutureOr<BoutiqueResponse<List<BoutiqueCategory>, BoutiqueError>> create(
    Ref ref,
  ) {
    return boutiqueCategories(ref);
  }
}

String _$boutiqueCategoriesHash() =>
    r'fdaa494962d5ad123246cccd9c6ff43508495435';

@ProviderFor(boutiquePackages)
final boutiquePackagesProvider = BoutiquePackagesFamily._();

final class BoutiquePackagesProvider
    extends
        $FunctionalProvider<
          AsyncValue<BoutiqueResponse<List<BoutiquePackage>, BoutiqueError>>,
          BoutiqueResponse<List<BoutiquePackage>, BoutiqueError>,
          FutureOr<BoutiqueResponse<List<BoutiquePackage>, BoutiqueError>>
        >
    with
        $FutureModifier<BoutiqueResponse<List<BoutiquePackage>, BoutiqueError>>,
        $FutureProvider<
          BoutiqueResponse<List<BoutiquePackage>, BoutiqueError>
        > {
  BoutiquePackagesProvider._({
    required BoutiquePackagesFamily super.from,
    required (String, {String language}) super.argument,
  }) : super(
         retry: null,
         name: r'boutiquePackagesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$boutiquePackagesHash();

  @override
  String toString() {
    return r'boutiquePackagesProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<BoutiqueResponse<List<BoutiquePackage>, BoutiqueError>>
  $createElement($ProviderPointer pointer) => $FutureProviderElement(pointer);

  @override
  FutureOr<BoutiqueResponse<List<BoutiquePackage>, BoutiqueError>> create(
    Ref ref,
  ) {
    final argument = this.argument as (String, {String language});
    return boutiquePackages(ref, argument.$1, language: argument.language);
  }

  @override
  bool operator ==(Object other) {
    return other is BoutiquePackagesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$boutiquePackagesHash() => r'006f46777d662ff75c6bb91fc65867281674bc2d';

final class BoutiquePackagesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<BoutiqueResponse<List<BoutiquePackage>, BoutiqueError>>,
          (String, {String language})
        > {
  BoutiquePackagesFamily._()
    : super(
        retry: null,
        name: r'boutiquePackagesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  BoutiquePackagesProvider call(
    String categoryId, {
    required String language,
  }) => BoutiquePackagesProvider._(
    argument: (categoryId, language: language),
    from: this,
  );

  @override
  String toString() => r'boutiquePackagesProvider';
}
