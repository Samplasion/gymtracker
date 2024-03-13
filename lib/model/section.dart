import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:gymtracker/model/exercisable.dart';
import 'package:gymtracker/model/set.dart';
import 'package:uuid/uuid.dart';

part 'section.g.dart';

@CopyWith()
class Section extends WorkoutExercisable {
  @override
  final String id;

  @override
  final String notes;

  Section({
    String? id,
    required this.notes,
  }) : id = id ?? const Uuid().v4();

  factory Section.fromJson(json) => Section(
        id: json['id'],
        notes: json['notes'] ?? "",
      );

  @override
  Map<String, dynamic> toJson() => {
        'type': 'section',
        'id': id,
        'notes': notes,
      };

  @override
  Duration get restTime => Duration.zero;

  @override
  List<ExSet> get sets => [];

  Section instantiate() => Section(
        id: const Uuid().v4(),
        notes: notes,
      );
}
