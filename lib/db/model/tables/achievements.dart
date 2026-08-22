import 'package:drift/drift.dart';
import 'package:gymtracker/model/achievements.dart';
import 'package:syncable/syncable.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

@UseRowClass(AchievementCompletion)
class Achievements extends Table implements SyncableTable {
  // This table was renamed to "achievements_v2" in database version 13 due to
  // the addition of syncable support. The old table is still present in the
  // database for migration purposes and will be removed on migration from v12.
  @override
  String? get tableName => "achievements_v2";

  @override
  Set<Column<Object>> get primaryKey => {achievementID, level, userId};

  TextColumn get achievementID =>
      text().named('achievement_id').clientDefault(() => _uuid.v4())();
  IntColumn get level => integer()();
  DateTimeColumn get completedAt => dateTime()();
  @override
  TextColumn get id => text().generatedAs(
    achievementID + Constant("_") + level.cast(),
    stored: true,
  )();
  @override
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  @override
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  @override
  TextColumn get userId => text().nullable()();
}
