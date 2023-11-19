import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:gymtracker/model/exercisable.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/set.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'superset.g.dart';

@JsonSerializable()
@CopyWith()
class Superset extends WorkoutExercisable {
  String id;
  final List<Exercise> exercises;
  @override
  Duration restTime;

  Superset({
    String? id,
    required this.exercises,
    required this.restTime,
  }) : id = id ?? const Uuid().v4();

  factory Superset.empty() {
    return Superset(
      exercises: [],
      restTime: const Duration(seconds: 0),
    );
  }

  factory Superset.fromJson(Map<String, dynamic> json) =>
      _$SupersetFromJson(json);

  @override
  List<ExSet> get sets => [
        for (final ex in exercises) ...ex.sets,
      ];

  @override
  Map<String, dynamic> toJson() => {
        ..._$SupersetToJson(this),
        'type': 'superset',
      };

  Superset clone() => Superset.fromJson(toJson());

  void regenerateID() => id = const Uuid().v4();
}
