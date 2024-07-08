import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

@DataClassName('DBNutritionGoal')
class NutritionGoals extends Table {
  @override
  Set<Column<Object>> get primaryKey => {id};

  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  DateTimeColumn get referenceDate => dateTime()();
  RealColumn get calories => real()();
  RealColumn get fat => real()();
  RealColumn get carbs => real()();
  RealColumn get protein => real()();
}
