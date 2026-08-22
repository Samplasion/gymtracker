import 'package:drift/drift.dart';
import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/db/database.dart';
import 'package:syncable/syncable.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

final class HistoryWorkout implements Syncable {
  @override
  final String id;
  final String name;
  final String? infobox;
  final int duration;
  final DateTime startingDate;
  final String? parentId;
  final String? completedBy;
  final String? completes;
  final Weights weightUnit;
  final Distance distanceUnit;
  @override
  final DateTime updatedAt;
  @override
  final bool deleted;
  @override
  final String? userId;

  HistoryWorkout({
    required this.id,
    required this.name,
    this.infobox,
    required this.duration,
    required this.startingDate,
    this.parentId,
    this.completedBy,
    this.completes,
    required this.weightUnit,
    required this.distanceUnit,
    DateTime? updatedAt,
    bool? deleted,
    this.userId,
  })  : updatedAt = updatedAt ?? DateTime.now().toUtc(),
        deleted = deleted ?? false;

  factory HistoryWorkout.fromJson(Map<String, dynamic> json) {
    return HistoryWorkout(
      id: json['id'] as String? ?? _uuid.v4(),
      name: json['name'] as String,
      infobox: json['infobox'] as String?,
      duration: json['duration'] as int,
      startingDate: DateTime.parse(
        json['starting_date'] as String? ?? json['startingDate'] as String,
      ),
      parentId: json['parent_id'] as String? ?? json['parentId'] as String?,
      completedBy:
          json['completed_by'] as String? ?? json['completedBy'] as String?,
      completes: json['completes'] as String?,
      weightUnit: Weights.values.byName(
        json['weight_unit'] as String? ?? json['weightUnit'] as String,
      ),
      distanceUnit: Distance.values.byName(
        json['distance_unit'] as String? ?? json['distanceUnit'] as String,
      ),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'] as String)
              : null,
      deleted: json['deleted'] as bool? ?? false,
      userId: json['user_id'] as String? ?? json['userId'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'infobox': infobox,
        'duration': duration,
        'starting_date': startingDate.toUtc().toIso8601String(),
        'parent_id': parentId,
        'completed_by': completedBy,
        'completes': completes,
        'weight_unit': weightUnit.name,
        'distance_unit': distanceUnit.name,
        'updated_at': updatedAt.toUtc().toIso8601String(),
        'deleted': deleted,
        'user_id': userId,
      };

  @override
  UpdateCompanion<Syncable> toCompanion() {
    return HistoryWorkoutsCompanion.insert(
      id: Value(id),
      name: name,
      infobox: Value(infobox),
      duration: duration,
      startingDate: startingDate,
      parentId: Value(parentId),
      completedBy: Value(completedBy),
      completes: Value(completes),
      weightUnit: weightUnit,
      distanceUnit: distanceUnit,
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      userId: Value(userId),
    );
  }
}
