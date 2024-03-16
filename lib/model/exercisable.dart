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
  List<ExSet> get sets;
  Duration get restTime;
  String get notes;

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
}
