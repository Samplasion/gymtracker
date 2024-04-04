import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:gymtracker/db/model/tables/set.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

export 'package:gymtracker/db/model/tables/set.dart'
    show GTSetKind, GTSetParameters;

part 'set.g.dart';

@JsonSerializable()
@CopyWith()
class GTSet {
  String id;
  GTSetKind kind;
  final GTSetParameters parameters;

  int? reps;
  double? weight;
  Duration? time;
  double? distance;
  bool done;

  GTSet({
    String? id,
    required this.kind,
    required this.parameters,
    this.reps,
    this.weight,
    this.time,
    this.distance,
    this.done = false,
  })  : id = id ?? const Uuid().v4(),
        assert(_validateParameters(
          parameters: parameters,
          reps: reps,
          weight: weight,
          time: time,
          distance: distance,
        ));

  static bool _validateParameters({
    required GTSetParameters parameters,
    required int? reps,
    required double? weight,
    required Duration? time,
    required double? distance,
  }) {
    switch (parameters) {
      case GTSetParameters.repsWeight:
        return reps != null && weight != null;
      case GTSetParameters.timeWeight:
        return time != null && weight != null;
      case GTSetParameters.freeBodyReps:
        return reps != null;
      case GTSetParameters.time:
        return time != null;
      case GTSetParameters.distance:
        return distance != null;
    }
  }

  factory GTSet.empty({
    required GTSetKind kind,
    required GTSetParameters parameters,
  }) {
    switch (parameters) {
      case GTSetParameters.repsWeight:
        return GTSet(
          kind: kind,
          parameters: parameters,
          reps: 0,
          weight: 0,
        );
      case GTSetParameters.timeWeight:
        return GTSet(
          kind: kind,
          parameters: parameters,
          time: Duration.zero,
          weight: 0,
        );
      case GTSetParameters.freeBodyReps:
        return GTSet(
          kind: kind,
          parameters: parameters,
          reps: 0,
        );
      case GTSetParameters.time:
        return GTSet(
          kind: kind,
          parameters: parameters,
          time: Duration.zero,
        );
      case GTSetParameters.distance:
        return GTSet(
          kind: kind,
          parameters: parameters,
          distance: 0,
        );
    }
  }

  factory GTSet.fromJson(Map<String, dynamic> json) => _$GTSetFromJson(json);

  Map<String, dynamic> toJson() => _$GTSetToJson(this);

  /// Calculates the one-rep max for this set
  ///
  /// The one-rep max is calculated using the Brzycki formula:
  /// `1rm = w / (1.0278 - (0.0278 * r))`.
  double? get oneRepMax {
    if (parameters != GTSetParameters.repsWeight) {
      throw GTSetParametersError(
        parameters,
        expectedParameters: GTSetParameters.repsWeight,
      );
    }
    if (reps == null || weight == null) {
      throw Exception("Reps and weight must be defined to calculate 1RM");
    }
    if (reps == 0) return null;
    return weight! / (1.0278 - (0.0278 * reps!));
  }
}

class GTSetParametersError extends Error {
  final GTSetParameters parameters;
  final GTSetParameters expectedParameters;

  GTSetParametersError(
    this.parameters, {
    required this.expectedParameters,
  });

  @override
  String toString() {
    return "Invalid parameters for set: $parameters instead of $expectedParameters";
  }
}
