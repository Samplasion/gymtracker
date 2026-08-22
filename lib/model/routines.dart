import 'package:drift/drift.dart';
import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:syncable/syncable.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

final class RoutineFolder implements Syncable {
  @override
  final String id;
  final String name;
  final int sortOrder;
  @override
  final DateTime updatedAt;
  @override
  final bool deleted;
  @override
  final String? userId;

  RoutineFolder({
    required this.id,
    required this.name,
    required this.sortOrder,
    DateTime? updatedAt,
    bool? deleted,
    this.userId,
  }) : updatedAt = updatedAt ?? DateTime.now().toUtc(),
       deleted = deleted ?? false;

  factory RoutineFolder.fromJson(Map<String, dynamic> json) {
    return RoutineFolder(
      id: json['id'] as String? ?? _uuid.v4(),
      name: json['name'] as String,
      sortOrder: json['sort_order'] as int? ?? json['sortOrder'] as int? ?? 0,
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
    'sort_order': sortOrder,
    'updated_at': updatedAt.toUtc().toIso8601String(),
    'deleted': deleted,
    'user_id': userId,
  };

  @override
  UpdateCompanion<Syncable> toCompanion() {
    return RoutineFoldersCompanion.insert(
      id: Value(id),
      name: name,
      sortOrder: sortOrder,
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      userId: Value(userId),
    );
  }
}

/// This class represents a routine for the purpose of syncing.
/// For any other purpose, use the [Workout] class.
final class Routine implements Syncable {
  @override
  final String id;
  final String name;
  final String infobox;
  final Weights weightUnit;
  final Distance distanceUnit;
  final int sortOrder;
  final String? folderId;
  @override
  final DateTime updatedAt;
  @override
  final bool deleted;
  @override
  final String? userId;

  Routine({
    required this.id,
    required this.name,
    required this.infobox,
    required this.weightUnit,
    required this.distanceUnit,
    required this.sortOrder,
    this.folderId,
    DateTime? updatedAt,
    bool? deleted,
    this.userId,
  }) : updatedAt = updatedAt ?? DateTime.now().toUtc(),
       deleted = deleted ?? false;

  factory Routine.fromJson(Map<String, dynamic> json) {
    return Routine(
      id: json['id'] as String? ?? _uuid.v4(),
      name: json['name'] as String,
      infobox: json['infobox'] as String? ?? '',
      weightUnit: Weights.values.byName(
        json['weight_unit'] as String? ?? json['weightUnit'] as String,
      ),
      distanceUnit: Distance.values.byName(
        json['distance_unit'] as String? ?? json['distanceUnit'] as String,
      ),
      sortOrder: json['sort_order'] as int? ?? json['sortOrder'] as int? ?? 0,
      folderId: json['folder_id'] as String? ?? json['folderId'] as String?,
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
    'weight_unit': weightUnit.name,
    'distance_unit': distanceUnit.name,
    'sort_order': sortOrder,
    'folder_id': folderId,
    'updated_at': updatedAt.toUtc().toIso8601String(),
    'deleted': deleted,
    'user_id': userId,
  };

  @override
  UpdateCompanion<Syncable> toCompanion() {
    return RoutinesCompanion.insert(
      id: Value(id),
      name: name,
      infobox: infobox,
      weightUnit: weightUnit,
      distanceUnit: distanceUnit,
      sortOrder: sortOrder,
      folderId: Value(folderId),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      userId: Value(userId),
    );
  }
}
