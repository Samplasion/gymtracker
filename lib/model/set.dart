import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'set.g.dart';

@JsonEnum()
enum SetKind {
  warmUp,
  normal,
  drop,
}

@JsonEnum()
enum SetParameters {
  repsWeight,
  timeWeight,
  freeBodyReps,
  time,
  distance,
}

@JsonSerializable()
@CopyWith()
class ExSet {
  String id;
  SetKind kind;
  final SetParameters parameters;

  int? reps;
  double? weight;
  Duration? time;
  double? distance;
  bool done;

  ExSet({
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
    required SetParameters parameters,
    required int? reps,
    required double? weight,
    required Duration? time,
    required double? distance,
  }) {
    switch (parameters) {
      case SetParameters.repsWeight:
        return reps != null && weight != null;
      case SetParameters.timeWeight:
        return time != null && weight != null;
      case SetParameters.freeBodyReps:
        return reps != null;
      case SetParameters.time:
        return time != null;
      case SetParameters.distance:
        return distance != null;
    }
  }

  factory ExSet.empty({
    required SetKind kind,
    required SetParameters parameters,
  }) {
    switch (parameters) {
      case SetParameters.repsWeight:
        return ExSet(
          kind: kind,
          parameters: parameters,
          reps: 0,
          weight: 0,
        );
      case SetParameters.timeWeight:
        return ExSet(
          kind: kind,
          parameters: parameters,
          time: Duration.zero,
          weight: 0,
        );
      case SetParameters.freeBodyReps:
        return ExSet(
          kind: kind,
          parameters: parameters,
          reps: 0,
        );
      case SetParameters.time:
        return ExSet(
          kind: kind,
          parameters: parameters,
          time: Duration.zero,
        );
      case SetParameters.distance:
        return ExSet(
          kind: kind,
          parameters: parameters,
          distance: 0,
        );
    }
  }

  factory ExSet.fromJson(Map<String, dynamic> json) => _$ExSetFromJson(json);

  Map<String, dynamic> toJson() => _$ExSetToJson(this);
}
