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
}
