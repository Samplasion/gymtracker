import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/model/measurements.dart';
import 'package:gymtracker/model/preferences.dart';
import 'package:gymtracker/model/progress_report.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/provider/db.dart';
import 'package:gymtracker/service/progress_report_builder.dart';
import 'package:gymtracker/struct/nutrition.dart';

final progressReportRepositoryProvider = Provider<ProgressReportRepository>(
  (ref) => ProgressReportRepository(ref.watch(appDatabaseProvider)),
);

final reportOwnerProvider = StreamProvider<String?>(
  (ref) => ref.watch(appDatabaseProvider).watchCurrentUserId(),
);

class ProgressReportRepository {
  final GTDatabase db;
  ProgressReportRepository(this.db);

  Future<ProgressReport> load(
    ReportRequest request, {
    required Translations translations,
    required String locale,
    required Prefs preferences,
    required DateTime generatedAt,
    required String? owner,
  }) async {
    var changed = false;
    final subscription = db.watchCurrentUserId().listen((id) {
      if (id != owner) changed = true;
    });
    try {
      return await db.transaction(() async {
        void checkOwner() {
          if (changed || db.currentUserId != owner) {
            throw StateError('Account changed during report generation');
          }
        }

        checkOwner();
        // Each source is read once; account changes invalidate the entire snapshot.
        // Do not use UI providers that substitute empty lists or default goals.
        final training = request.sections.contains(ReportSection.training);
        final nutrition = request.sections.contains(ReportSection.nutrition);
        final measurements = request.sections.contains(
          ReportSection.measurements,
        );
        final results = await Future.wait<Object>([
          if (training) db.getAllHistoryWorkoutsFuture(),
          if (nutrition) db.watchFoods().first,
          if (nutrition) db.watchNutritionGoals().first,
          if (measurements) db.watchWeightMeasurements().first,
          if (measurements) db.watchBodyMeasurements().first,
        ]).timeout(const Duration(seconds: 30));
        checkOwner();
        var i = 0;
        final workouts = training ? results[i++] as List<Workout> : <Workout>[];
        final foods = nutrition
            ? results[i++] as List<TaggedFood>
            : <TaggedFood>[];
        final goals = nutrition
            ? results[i++] as List<TaggedNutritionGoal>
            : <TaggedNutritionGoal>[];
        final weights = measurements
            ? results[i++] as List<WeightMeasurement>
            : <WeightMeasurement>[];
        final body = measurements
            ? results[i++] as List<BodyMeasurement>
            : <BodyMeasurement>[];
        return ProgressReportBuilder(
          t: translations,
          locale: locale,
          weightUnit: preferences.weightUnit,
          distanceUnit: preferences.distanceUnit,
          accentColor: preferences.color.toARGB32(),
        ).build(
          request,
          generatedAt: generatedAt,
          timeZone: generatedAt.timeZoneName,
          workouts: workouts,
          foods: foods,
          goals: goals,
          weights: weights,
          body: body,
        );
      });
    } finally {
      await subscription.cancel();
    }
  }
}
