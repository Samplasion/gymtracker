// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stats.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(workoutsStream)
final workoutsStreamProvider = WorkoutsStreamProvider._();

final class WorkoutsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Workout>>,
          List<Workout>,
          Stream<List<Workout>>
        >
    with $FutureModifier<List<Workout>>, $StreamProvider<List<Workout>> {
  WorkoutsStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'workoutsStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$workoutsStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<Workout>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Workout>> create(Ref ref) {
    return workoutsStream(ref);
  }
}

String _$workoutsStreamHash() => r'd47f6c531a077e446f19b74e9e07d5784dd3625c';

@ProviderFor(exerciseDataStream)
final exerciseDataStreamProvider = ExerciseDataStreamFamily._();

final class ExerciseDataStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<DateTime, List<GTSet>>>,
          Map<DateTime, List<GTSet>>,
          FutureOr<Map<DateTime, List<GTSet>>>
        >
    with
        $FutureModifier<Map<DateTime, List<GTSet>>>,
        $FutureProvider<Map<DateTime, List<GTSet>>> {
  ExerciseDataStreamProvider._({
    required ExerciseDataStreamFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'exerciseDataStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$exerciseDataStreamHash();

  @override
  String toString() {
    return r'exerciseDataStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Map<DateTime, List<GTSet>>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<DateTime, List<GTSet>>> create(Ref ref) {
    final argument = this.argument as String;
    return exerciseDataStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ExerciseDataStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$exerciseDataStreamHash() =>
    r'b5833accf19975dbc7a71eeaa36d634b1782b239';

final class ExerciseDataStreamFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<Map<DateTime, List<GTSet>>>,
          String
        > {
  ExerciseDataStreamFamily._()
    : super(
        retry: null,
        name: r'exerciseDataStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ExerciseDataStreamProvider call(String exerciseID) =>
      ExerciseDataStreamProvider._(argument: exerciseID, from: this);

  @override
  String toString() => r'exerciseDataStreamProvider';
}

/// Returns a stream of the 1RM data for each of the three main exercises (bench
/// press, squat, deadlift) over time. The stream emits a list of tuples, where
/// each tuple contains a [DateTime] representing the week and a map of
/// [MajorLiftType] to the corresponding 1RM value.

@ProviderFor(majorThreeDataStream)
final majorThreeDataStreamProvider = MajorThreeDataStreamProvider._();

/// Returns a stream of the 1RM data for each of the three main exercises (bench
/// press, squat, deadlift) over time. The stream emits a list of tuples, where
/// each tuple contains a [DateTime] representing the week and a map of
/// [MajorLiftType] to the corresponding 1RM value.

final class MajorThreeDataStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<DateTime, Map<MajorLiftType, double>>>,
          Map<DateTime, Map<MajorLiftType, double>>,
          FutureOr<Map<DateTime, Map<MajorLiftType, double>>>
        >
    with
        $FutureModifier<Map<DateTime, Map<MajorLiftType, double>>>,
        $FutureProvider<Map<DateTime, Map<MajorLiftType, double>>> {
  /// Returns a stream of the 1RM data for each of the three main exercises (bench
  /// press, squat, deadlift) over time. The stream emits a list of tuples, where
  /// each tuple contains a [DateTime] representing the week and a map of
  /// [MajorLiftType] to the corresponding 1RM value.
  MajorThreeDataStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'majorThreeDataStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$majorThreeDataStreamHash();

  @$internal
  @override
  $FutureProviderElement<Map<DateTime, Map<MajorLiftType, double>>>
  $createElement($ProviderPointer pointer) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<DateTime, Map<MajorLiftType, double>>> create(Ref ref) {
    return majorThreeDataStream(ref);
  }
}

String _$majorThreeDataStreamHash() =>
    r'f28cb5378c1456345c7d807815618ff40a9721f4';

@ProviderFor(majorThreeChartData)
final majorThreeChartDataProvider = MajorThreeChartDataFamily._();

final class MajorThreeChartDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<MajorLiftType, Map<DateTime, double>>>,
          Map<MajorLiftType, Map<DateTime, double>>,
          FutureOr<Map<MajorLiftType, Map<DateTime, double>>>
        >
    with
        $FutureModifier<Map<MajorLiftType, Map<DateTime, double>>>,
        $FutureProvider<Map<MajorLiftType, Map<DateTime, double>>> {
  MajorThreeChartDataProvider._({
    required MajorThreeChartDataFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'majorThreeChartDataProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$majorThreeChartDataHash();

  @override
  String toString() {
    return r'majorThreeChartDataProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Map<MajorLiftType, Map<DateTime, double>>>
  $createElement($ProviderPointer pointer) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<MajorLiftType, Map<DateTime, double>>> create(Ref ref) {
    final argument = this.argument as int;
    return majorThreeChartData(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MajorThreeChartDataProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$majorThreeChartDataHash() =>
    r'a7c700f3c5a455f795de19978d4227539fe6c687';

final class MajorThreeChartDataFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<Map<MajorLiftType, Map<DateTime, double>>>,
          int
        > {
  MajorThreeChartDataFamily._()
    : super(
        retry: null,
        name: r'majorThreeChartDataProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MajorThreeChartDataProvider call(int firstDayOfWeek) =>
      MajorThreeChartDataProvider._(argument: firstDayOfWeek, from: this);

  @override
  String toString() => r'majorThreeChartDataProvider';
}
