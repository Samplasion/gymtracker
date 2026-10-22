// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'measurements.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(measurementsRepository)
final measurementsRepositoryProvider = MeasurementsRepositoryProvider._();

final class MeasurementsRepositoryProvider
    extends
        $FunctionalProvider<
          MeasurementsRepository,
          MeasurementsRepository,
          MeasurementsRepository
        >
    with $Provider<MeasurementsRepository> {
  MeasurementsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'measurementsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$measurementsRepositoryHash();

  @$internal
  @override
  $ProviderElement<MeasurementsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MeasurementsRepository create(Ref ref) {
    return measurementsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MeasurementsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MeasurementsRepository>(value),
    );
  }
}

String _$measurementsRepositoryHash() =>
    r'aae6a76443d479312b227f1cfe1a361bc7f8c18e';
