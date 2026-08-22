import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:syncable/syncable.dart';
import 'package:uuid/uuid.dart';
import 'package:gymtracker/db/database.dart';

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

@UseRowClass(DBFood)
class Foods extends Table implements SyncableTable {
  @override
  Set<Column<Object>> get primaryKey => {id, userId};

  @override
  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  DateTimeColumn get dateAdded => dateTime()();
  DateTimeColumn get referenceDate => dateTime()();
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

@UseRowClass(DBCustomBarcodeFood)
class CustomBarcodeFoods extends Table implements SyncableTable {
  @override
  Set<Column<Object>> get primaryKey => {id, userId};

  @override
  TextColumn get id => text().named('barcode')();
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

@UseRowClass(DBFavoriteFood)
class FavoriteFoods extends Table implements SyncableTable {
  @override
  TextColumn get id => text().named('food_id').references(Foods, #id)();
  @override
  DateTimeColumn get updatedAt => dateTime().withDefault(
    Constant(DateTime.fromMicrosecondsSinceEpoch(0, isUtc: true)),
  )();
  @override
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  @override
  TextColumn get userId => text().nullable()();
}

class DBFood implements Insertable<DBFood>, Syncable {
  @override
  final String id;
  final DateTime dateAdded;
  final DateTime referenceDate;
  final String jsonData;
  @override
  final DateTime updatedAt;
  @override
  final bool deleted;
  @override
  final String? userId;

  DBFood({
    required this.id,
    required this.dateAdded,
    required this.referenceDate,
    required this.jsonData,
    required this.updatedAt,
    required this.deleted,
    this.userId,
  });

  factory DBFood.fromJson(Map<String, dynamic> json) {
    return DBFood(
      id: json['id'] as String,
      dateAdded: DateTime.parse(
        json['date_added'] as String? ?? json['dateAdded'] as String,
      ),
      referenceDate: DateTime.parse(
        json['reference_date'] as String? ?? json['referenceDate'] as String,
      ),
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'date_added': dateAdded.toUtc().toIso8601String(),
    'reference_date': referenceDate.toUtc().toIso8601String(),
    'json_data': jsonData,
    'updated_at': updatedAt.toUtc().toIso8601String(),
    'deleted': deleted,
    'user_id': userId,
  };

  @override
  Map<String, Expression<Object>> toColumns(bool nullToAbsent) {
    return FoodsCompanion(
      id: Value(id),
      dateAdded: Value(dateAdded),
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
  UpdateCompanion<DBFood> toCompanion() {
    return FoodsCompanion(
      id: Value(id),
      dateAdded: Value(dateAdded),
      referenceDate: Value(referenceDate),
      jsonData: Value(jsonData),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      userId: Value(userId),
    );
  }
}

class DBCustomBarcodeFood implements Insertable<DBCustomBarcodeFood>, Syncable {
  @override
  final String id;
  final String jsonData;
  @override
  final DateTime updatedAt;
  @override
  final bool deleted;
  @override
  final String? userId;

  DBCustomBarcodeFood({
    required this.id,
    required this.jsonData,
    required this.updatedAt,
    required this.deleted,
    this.userId,
  });

  factory DBCustomBarcodeFood.fromJson(Map<String, dynamic> json) {
    return DBCustomBarcodeFood(
      id: json['id'] as String? ?? json['barcode'] as String,
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'json_data': jsonData,
    'updated_at': updatedAt.toUtc().toIso8601String(),
    'deleted': deleted,
    'user_id': userId,
  };

  @override
  Map<String, Expression<Object>> toColumns(bool nullToAbsent) {
    return CustomBarcodeFoodsCompanion(
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
  UpdateCompanion<DBCustomBarcodeFood> toCompanion() {
    return CustomBarcodeFoodsCompanion(
      id: Value(id),
      jsonData: Value(jsonData),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      userId: Value(userId),
    );
  }
}

class DBFavoriteFood implements Insertable<DBFavoriteFood>, Syncable {
  @override
  final String id;
  @override
  final DateTime updatedAt;
  @override
  final bool deleted;
  @override
  final String? userId;

  DBFavoriteFood({
    required this.id,
    required this.updatedAt,
    required this.deleted,
    this.userId,
  });

  factory DBFavoriteFood.fromJson(Map<String, dynamic> json) {
    return DBFavoriteFood(
      id: json['id'] as String? ?? json['food_id'] as String,
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
    'updated_at': updatedAt.toUtc().toIso8601String(),
    'deleted': deleted,
    'user_id': userId,
  };

  @override
  Map<String, Expression<Object>> toColumns(bool nullToAbsent) {
    return FavoriteFoodsCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
    ).toColumns(nullToAbsent);
  }

  @override
  UpdateCompanion<DBFavoriteFood> toCompanion() {
    return FavoriteFoodsCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      userId: Value(userId),
    );
  }
}
