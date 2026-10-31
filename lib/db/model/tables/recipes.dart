import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:gymtracker/db/database.dart';
import 'package:syncable/syncable.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

String _forceJsonString(dynamic value) {
  if (value is String) {
    return value;
  } else if (value is Map || value is List) {
    return jsonEncode(value);
  } else {
    throw ArgumentError('Invalid jsonData type: ${value.runtimeType}');
  }
}

@UseRowClass(DBRecipe)
class Recipes extends Table implements SyncableTable {
  @override
  Set<Column<Object>> get primaryKey => {id, userId};

  @override
  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get jsonData => text()();
  @override
  DateTimeColumn get updatedAt => dateTime().withDefault(
    Constant(DateTime.fromMicrosecondsSinceEpoch(0, isUtc: true)),
  )();
  @override
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  @override
  TextColumn get userId => text().nullable()();
}

class DBRecipe implements Insertable<DBRecipe>, Syncable {
  @override
  final String id;
  final String jsonData;
  @override
  final DateTime updatedAt;
  @override
  final bool deleted;
  @override
  final String? userId;

  DBRecipe({
    required this.id,
    required this.jsonData,
    required this.updatedAt,
    required this.deleted,
    this.userId,
  });

  factory DBRecipe.fromJson(Map<String, dynamic> json) {
    return DBRecipe(
      id: json['id'] as String,
      jsonData: _forceJsonString(json['json_data'] ?? json['jsonData']),
      updatedAt: DateTime.parse(
        json['updated_at'] as String? ??
            json['updatedAt'] as String? ??
            DateTime(2000).toIso8601String(),
      ),
      deleted: json['deleted'] as bool? ?? false,
      userId: json['user_id'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'json_data': jsonData,
    'updated_at': updatedAt.toUtc().toIso8601String(),
    'deleted': deleted,
    'user_id': userId,
  };

  @override
  Map<String, Expression<Object>> toColumns(bool nullToAbsent) {
    return RecipesCompanion(
      id: Value(id),
      jsonData: Value(jsonData),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
    ).toColumns(nullToAbsent);
  }

  @override
  UpdateCompanion<DBRecipe> toCompanion() {
    return RecipesCompanion(
      id: Value(id),
      jsonData: Value(jsonData),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      userId: Value(userId),
    );
  }
}
