import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/model/superset.dart';
import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
abstract class WorkoutExercisable {
  static WorkoutExercisable fromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case 'exercise':
        return Exercise.fromJson(json);
      case 'superset':
        return Superset.fromJson(json);
      default:
        throw Exception('Invalid type');
    }
  }

  Map<String, dynamic> toJson();

  List<ExSet> get sets;
  Duration get restTime;
}
