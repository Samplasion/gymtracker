import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:gymtracker/utils/parsing.dart';
import 'package:syncable/syncable.dart';
import 'package:gymtracker/db/database.dart';

@UseRowClass(DBNutritionCategory)
class NutritionCategories extends Table implements SyncableTable {
  @override
  Set<Column<Object>> get primaryKey => {userId, id};

  DateTimeColumn get referenceDate => dateTime()();
  TextColumn get jsonData => text()();
  @override
  TextColumn get id => text().nullable()();
  @override
  DateTimeColumn get updatedAt => dateTime().withDefault(
    Constant(DateTime.fromMicrosecondsSinceEpoch(0, isUtc: true)),
  )();
  @override
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  @override
  TextColumn get userId => text().nullable()();
}

class DBNutritionCategory implements Insertable<DBNutritionCategory>, Syncable {
  @override
  final String id;
  final DateTime referenceDate;
  final String jsonData;
  @override
  final DateTime updatedAt;
  @override
  final bool deleted;
  @override
  final String? userId;

  DBNutritionCategory({
    String? id,
    required DateTime referenceDate,
    required this.jsonData,
    required this.updatedAt,
    required this.deleted,
    this.userId,
  }) : referenceDate = DateTime.utc(
         referenceDate.year,
         referenceDate.month,
         referenceDate.day,
       ),
       id =
           id ??
           DateTime.utc(
             referenceDate.year,
             referenceDate.month,
             referenceDate.day,
           ).toIso8601String();

  factory DBNutritionCategory.fromJson(Map<String, dynamic> json) {
    return DBNutritionCategory(
      id: json['id'] as String?,
      referenceDate: DateTime.parse(
        json['reference_date'] as String? ?? json['referenceDate'] as String,
      ),
      jsonData: jsonEncode(
        maybeJsonString(json['json_data'] ?? json['jsonData']),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] as String? ??
            json['updatedAt'] as String? ??
            DateTime(2000).toIso8601String(),
      ),
      deleted: json['deleted'] as bool? ?? false,
      userId: json['user_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'reference_date': referenceDate.toUtc().toIso8601String(),
    'json_data': jsonData,
    'updated_at': updatedAt.toUtc().toIso8601String(),
    'deleted': deleted,
    'user_id': userId,
  };

  @override
  Map<String, Expression<Object>> toColumns(bool nullToAbsent) {
    return NutritionCategoriesCompanion(
      id: Value(id),
      referenceDate: Value(referenceDate),
      jsonData: Value(jsonData),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
    ).toColumns(nullToAbsent);
  }

  @override
  UpdateCompanion<DBNutritionCategory> toCompanion() {
    return NutritionCategoriesCompanion(
      id: Value(id),
      referenceDate: Value(referenceDate),
      jsonData: Value(jsonData),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      userId: Value(userId),
    );
  }
}
