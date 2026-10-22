// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locale.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TranslationsNotifier)
final translationsProvider = TranslationsNotifierProvider._();

final class TranslationsNotifierProvider
    extends $NotifierProvider<TranslationsNotifier, Translations> {
  TranslationsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'translationsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$translationsNotifierHash();

  @$internal
  @override
  TranslationsNotifier create() => TranslationsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Translations value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Translations>(value),
    );
  }
}

String _$translationsNotifierHash() =>
    r'497f02191631106e0f4d17778b2221f52e48ddcc';

abstract class _$TranslationsNotifier extends $Notifier<Translations> {
  Translations build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Translations, Translations>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Translations, Translations>,
              Translations,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(exerciseExplanation)
final exerciseExplanationProvider = ExerciseExplanationFamily._();

final class ExerciseExplanationProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  ExerciseExplanationProvider._({
    required ExerciseExplanationFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'exerciseExplanationProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$exerciseExplanationHash();

  @override
  String toString() {
    return r'exerciseExplanationProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    final argument = this.argument as String;
    return exerciseExplanation(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ExerciseExplanationProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$exerciseExplanationHash() =>
    r'e559800f50f583bc2467d8a14bec2124838e3c60';

final class ExerciseExplanationFamily extends $Family
    with $FunctionalFamilyOverride<String?, String> {
  ExerciseExplanationFamily._()
    : super(
        retry: null,
        name: r'exerciseExplanationProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ExerciseExplanationProvider call(String exerciseID) =>
      ExerciseExplanationProvider._(argument: exerciseID, from: this);

  @override
  String toString() => r'exerciseExplanationProvider';
}
