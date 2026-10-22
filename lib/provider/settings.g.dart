// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appPreferences)
final appPreferencesProvider = AppPreferencesProvider._();

final class AppPreferencesProvider
    extends $FunctionalProvider<AsyncValue<Prefs>, Prefs, Stream<Prefs>>
    with $FutureModifier<Prefs>, $StreamProvider<Prefs> {
  AppPreferencesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appPreferencesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appPreferencesHash();

  @$internal
  @override
  $StreamProviderElement<Prefs> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Prefs> create(Ref ref) {
    return appPreferences(ref);
  }
}

String _$appPreferencesHash() => r'6e9a9a9f713b06c0cf6f0e800481c33dcfebc2fe';
