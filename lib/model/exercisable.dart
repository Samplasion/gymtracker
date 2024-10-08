import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/model/superset.dart';

abstract class WorkoutExercisable {
  WorkoutExercisable();

  factory WorkoutExercisable.fromJson(Map<String, dynamic> json) =>
      _internalFromJson(json);

  static WorkoutExercisable _internalFromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case 'exercise':
      case null:
        return Exercise.fromJson(json);
      case 'superset':
        return Superset.fromJson(json);
      default:
        throw Exception('Invalid type ${json["type"]}');
    }
  }

  Map<String, dynamic> toJson();

  String get id;
  String? get workoutID;
  List<GTSet> get sets;
  Duration get restTime;
  String get notes;

  /// If this exercise supersedes a previous version of itself (for example, in
  /// a continuation), this field should be set to the ID of the previous
  /// exercise.
  String? get supersedesID;

  bool get isSupersedence => supersedesID != null;

  when({
    void Function(Exercise)? exercise,
    void Function(Superset)? superset,
    void Function()? other,
  }) {
    assert([exercise, superset, other].any((el) => el != null),
        "At least one callback must be provided.");
    if (this is Exercise && exercise != null) {
      exercise(this as Exercise);
      return;
    } else if (this is Superset && superset != null) {
      superset(this as Superset);
      return;
    }
    other?.call();
  }

  T map<T>({
    required T Function(Exercise) exercise,
    required T Function(Superset) superset,
  }) {
    if (this is Exercise) {
      return exercise(this as Exercise);
    } else if (this is Superset) {
      return superset(this as Superset);
    }
    throw TypeError();
  }

  bool get isExercise => this is Exercise;
  bool get isSuperset => this is Superset;

  Exercise get asExercise => this as Exercise;
  Superset get asSuperset => this as Superset;

  WorkoutExercisable changeUnits({
    required Weights fromWeightUnit,
    required Weights toWeightUnit,
    required Distance fromDistanceUnit,
    required Distance toDistanceUnit,
  });

  WorkoutExercisable clone() => WorkoutExercisable.fromJson(toJson());

  static bool deepEquality(WorkoutExercisable a, WorkoutExercisable b) {
    if (a.runtimeType != b.runtimeType) return false;
    return switch (a) {
      Exercise() => Exercise.deepEquality(a, b as Exercise),
      Superset() => Superset.deepEquality(a, b as Superset),
      _ => throw TypeError(),
    };
  }
}
