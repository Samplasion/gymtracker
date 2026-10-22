// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'measurements.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(weightMeasurements)
final weightMeasurementsProvider = WeightMeasurementsProvider._();

final class WeightMeasurementsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WeightMeasurement>>,
          List<WeightMeasurement>,
          Stream<List<WeightMeasurement>>
        >
    with
        $FutureModifier<List<WeightMeasurement>>,
        $StreamProvider<List<WeightMeasurement>> {
  WeightMeasurementsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'weightMeasurementsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$weightMeasurementsHash();

  @$internal
  @override
  $StreamProviderElement<List<WeightMeasurement>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<WeightMeasurement>> create(Ref ref) {
    return weightMeasurements(ref);
  }
}

String _$weightMeasurementsHash() =>
    r'6a300a2a643b8d37a1c04570c4787a03ddb1640b';

@ProviderFor(bodyMeasurements)
final bodyMeasurementsProvider = BodyMeasurementsProvider._();

final class BodyMeasurementsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BodyMeasurement>>,
          List<BodyMeasurement>,
          Stream<List<BodyMeasurement>>
        >
    with
        $FutureModifier<List<BodyMeasurement>>,
        $StreamProvider<List<BodyMeasurement>> {
  BodyMeasurementsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bodyMeasurementsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bodyMeasurementsHash();

  @$internal
  @override
  $StreamProviderElement<List<BodyMeasurement>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<BodyMeasurement>> create(Ref ref) {
    return bodyMeasurements(ref);
  }
}

String _$bodyMeasurementsHash() => r'31a7335f033402843b64a1380cc0c41bc7a4e034';

@ProviderFor(measurementWeightUnit)
final measurementWeightUnitProvider = MeasurementWeightUnitProvider._();

final class MeasurementWeightUnitProvider
    extends
        $FunctionalProvider<
          AsyncValue<Weights>,
          AsyncValue<Weights>,
          AsyncValue<Weights>
        >
    with $Provider<AsyncValue<Weights>> {
  MeasurementWeightUnitProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'measurementWeightUnitProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$measurementWeightUnitHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<Weights>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<Weights> create(Ref ref) {
    return measurementWeightUnit(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<Weights> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<Weights>>(value),
    );
  }
}

String _$measurementWeightUnitHash() =>
    r'dcda2403e41c412746d67d9733720450a4e3bc50';

@ProviderFor(predictedWeight)
final predictedWeightProvider = PredictedWeightProvider._();

final class PredictedWeightProvider
    extends
        $FunctionalProvider<
          PredictedWeightMeasurement?,
          PredictedWeightMeasurement?,
          PredictedWeightMeasurement?
        >
    with $Provider<PredictedWeightMeasurement?> {
  PredictedWeightProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'predictedWeightProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$predictedWeightHash();

  @$internal
  @override
  $ProviderElement<PredictedWeightMeasurement?> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PredictedWeightMeasurement? create(Ref ref) {
    return predictedWeight(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PredictedWeightMeasurement? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PredictedWeightMeasurement?>(value),
    );
  }
}

String _$predictedWeightHash() => r'7981e51b42f07ae86f699bdd99bfad7cabe4b422';
