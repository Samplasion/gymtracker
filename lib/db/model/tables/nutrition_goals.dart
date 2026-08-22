import 'package:drift/drift.dart';
import 'package:syncable/syncable.dart';
import 'package:uuid/uuid.dart';
import 'package:gymtracker/db/database.dart';

const _uuid = Uuid();

@UseRowClass(DBNutritionGoal)
class NutritionGoals extends Table implements SyncableTable {
  @override
  Set<Column<Object>> get primaryKey => {id, userId};

  @override
  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  DateTimeColumn get referenceDate => dateTime()();
  RealColumn get calories => real()();
  RealColumn get fat => real()();
  RealColumn get carbs => real()();
  RealColumn get protein => real()();
  @override
  DateTimeColumn get updatedAt => dateTime().withDefault(
    Constant(DateTime.fromMicrosecondsSinceEpoch(0, isUtc: true)),
  )();
  @override
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  @override
  TextColumn get userId => text().nullable()();
}

class DBNutritionGoal implements Insertable<DBNutritionGoal>, Syncable {
  @override
  final String id;
  final DateTime referenceDate;
  final double calories;
  final double fat;
  final double carbs;
  final double protein;
  @override
  final DateTime updatedAt;
  @override
  final bool deleted;
  @override
  final String? userId;

  DBNutritionGoal({
    required this.id,
    required this.referenceDate,
    required this.calories,
    required this.fat,
    required this.carbs,
    required this.protein,
    required this.updatedAt,
    required this.deleted,
    this.userId,
  });

  factory DBNutritionGoal.fromJson(Map<String, dynamic> json) {
    return DBNutritionGoal(
      id: json['id'] as String,
      referenceDate: DateTime.parse(
        json['reference_date'] as String? ?? json['referenceDate'] as String,
      ),
      calories: (json['calories'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
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
    'calories': calories,
    'fat': fat,
    'carbs': carbs,
    'protein': protein,
    'updated_at': updatedAt.toUtc().toIso8601String(),
    'deleted': deleted,
    'user_id': userId,
  };

  @override
  Map<String, Expression<Object>> toColumns(bool nullToAbsent) {
    return NutritionGoalsCompanion(
      id: Value(id),
      referenceDate: Value(referenceDate),
      calories: Value(calories),
      fat: Value(fat),
      carbs: Value(carbs),
      protein: Value(protein),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
    ).toColumns(nullToAbsent);
  }

  @override
  UpdateCompanion<DBNutritionGoal> toCompanion() {
    return NutritionGoalsCompanion(
      id: Value(id),
      referenceDate: Value(referenceDate),
      calories: Value(calories),
      fat: Value(fat),
      carbs: Value(carbs),
      protein: Value(protein),
      updatedAt: Value(updatedAt),
      deleted: Value(deleted),
      userId: Value(userId),
    );
  }
}
