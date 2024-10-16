import 'package:drift/drift.dart';
import 'package:gymtracker/model/achievements.dart';

@UseRowClass(AchievementCompletion)
class Achievements extends Table {
  @override
  Set<Column<Object>> get primaryKey => {achievementID, level};

  TextColumn get achievementID => text()();
  IntColumn get level => integer()();
  DateTimeColumn get completedAt => dateTime()();
}
