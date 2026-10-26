import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/measurements.dart';
import 'package:gymtracker/model/progress_report.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/progress_report_builder.dart';
import 'package:gymtracker/struct/nutrition.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

Exercise reportExercise(List<GTSet> sets) => Exercise.custom(
  name: 'Squat personalizzato',
  parameters: sets.first.parameters,
  sets: sets,
  primaryMuscleGroup: GTMuscleGroup.values.first,
  restTime: Duration.zero,
  notes: 'Private note must never appear',
  supersetID: null,
  workoutID: null,
  equipment: GTGymEquipment.none,
);
Food reportFood({
  String name = 'Pasta',
  double calories = 100,
  double amount = 150,
  int pieces = 2,
}) => Food(
  name: name,
  nutritionalValuesPer100g: NutritionValues(
    calories: calories,
    protein: 10,
    carbs: 20,
    fat: 5,
    saturatedFat: 0,
    sugar: 0,
  ),
  amount: amount,
  pieces: pieces,
  category: 'Pranzo',
);
ReportRequest reportRequest({
  Set<ReportSection>? sections,
  ReportPeriodKind kind = ReportPeriodKind.month,
  DateTime? reference,
}) => ReportRequest(
  kind: kind,
  period: ReportPeriod.forDate(
    kind,
    reference ?? DateTime(2026, 10, 25),
    firstDayOfWeek: DateTime.monday,
  ),
  sections: sections ?? ReportSection.values.toSet(),
);
ProgressReportBuilder reportBuilder([AppLocale locale = AppLocale.it]) =>
    ProgressReportBuilder(
      t: locale.buildSync(),
      locale: locale.languageCode,
      weightUnit: Weights.kg,
      distanceUnit: Distance.km,
    );

void main() {
  setUpAll(() async {
    await initializeDateFormatting();
  });
  test(
    'calendar boundaries cover leap month, year rollover and localized weeks',
    () {
      final leap = ReportPeriod.forDate(
        ReportPeriodKind.month,
        DateTime(2024, 2, 15),
        firstDayOfWeek: 1,
      );
      expect(leap.days.length, 29);
      expect(leap.end, DateTime(2024, 3));
      final year = ReportPeriod.forDate(
        ReportPeriodKind.month,
        DateTime(2026, 12, 31),
        firstDayOfWeek: 1,
      );
      expect(year.end, DateTime(2027));
      final it = ReportPeriod.forDate(
        ReportPeriodKind.week,
        DateTime(2026, 10, 25),
        firstDayOfWeek: 1,
      );
      final en = ReportPeriod.forDate(
        ReportPeriodKind.week,
        DateTime(2026, 10, 25),
        firstDayOfWeek: 7,
      );
      expect(it.start, DateTime(2026, 10, 19));
      expect(en.start, DateTime(2026, 10, 25));
      expect(it.containsInstant(it.start), isTrue);
      expect(it.containsInstant(it.end), isFalse);
      expect(it.containsDay(it.end), isFalse);
    },
  );
  test('calendar days remain consecutive over DST transitions', () {
    tzdata.initializeTimeZones();
    final rome = tz.getLocation('Europe/Rome');
    // Date selection is a civil date even when supplied with timezone metadata.
    for (final date in [
      tz.TZDateTime(rome, 2026, 3, 29),
      tz.TZDateTime(rome, 2026, 10, 25),
    ]) {
      final p = ReportPeriod.forDate(
        ReportPeriodKind.week,
        date,
        firstDayOfWeek: 1,
      );
      expect(p.days.length, 7);
      expect(p.days.map((d) => d.hour).toSet(), {0});
      expect(
        p.days.map((d) => '${d.year}-${d.month}-${d.day}').toSet().length,
        7,
      );
    }
  });
  test('all seven nonempty combinations select only requested records', () {
    final workout = Workout(
      name: 'Workout',
      exercises: [],
      duration: Duration.zero,
      startingDate: DateTime(2026, 10, 2),
    );
    final food = TaggedFood(date: DateTime(2026, 10, 2), value: reportFood());
    final weight = WeightMeasurement.generateID(
      weight: 80,
      time: DateTime(2026, 10, 2),
      weightUnit: Weights.kg,
    );
    for (var mask = 1; mask < 8; mask++) {
      final sections = {
        for (final s in ReportSection.values)
          if (mask & (1 << s.index) != 0) s,
      };
      final r = reportBuilder().build(
        reportRequest(sections: sections),
        generatedAt: DateTime(2026, 10, 25),
        timeZone: 'Europe/Rome',
        workouts: [workout],
        foods: [food],
        weights: [weight],
      );
      final day = r.days[1];
      expect(day.sessions, sections.contains(ReportSection.training) ? 1 : 0);
      expect(day.foodCount, sections.contains(ReportSection.nutrition) ? 1 : 0);
      expect(
        day.measurementCount,
        sections.contains(ReportSection.measurements) ? 1 : 0,
      );
      expect(day.tables.length, sections.length);
      expect(() => r.days.clear(), throwsUnsupportedError);
    }
    expect(() => reportRequest(sections: {}), throwsArgumentError);
  });
  test(
    'completed sets, assisted loads, mixed units and continuations counted once',
    () {
      final sets = [
        GTSet(
          kind: GTSetKind.normal,
          parameters: GTSetParameters.repsWeight,
          reps: 10,
          weight: 22.0462262185,
          done: true,
        ),
        GTSet(
          kind: GTSetKind.normal,
          parameters: GTSetParameters.repsWeight,
          reps: 20,
          weight: 100,
          done: false,
        ),
      ];
      final w = Workout(
        id: 'base',
        name: 'Session',
        exercises: [reportExercise(sets)],
        duration: const Duration(minutes: 20),
        startingDate: DateTime(2026, 10, 1, 23, 50),
        weightUnit: Weights.lb,
        completedBy: 'next',
      );
      final next = Workout(
        id: 'next',
        name: 'Continuation',
        exercises: [
          reportExercise([
            GTSet(
              kind: GTSetKind.normal,
              parameters: GTSetParameters.repsNegWeight,
              reps: 5,
              weight: 20,
              done: true,
            ),
          ]),
        ],
        duration: const Duration(minutes: 10),
        startingDate: DateTime(2026, 10, 2),
        completes: 'base',
      );
      final r = reportBuilder().build(
        reportRequest(),
        generatedAt: DateTime(2026, 10, 25),
        timeZone: 'Europe/Rome',
        workouts: [w, w, next],
      );
      expect(r.days[0].sessions, 1);
      expect(r.days[0].completedSets, 1);
      expect(r.days[0].repetitions, 10);
      expect(r.days[0].volume, closeTo(100, 0.0001));
      expect(r.days[1].sessions, 1);
      expect(r.days[1].volume, 0);
      expect(r.days[1].tables.first.rows.first[3], '-20 kg');
      expect(r.days[0].tables.first.rows.last[1], 'Non completata');
      expect(r.days[0].tables.toString(), isNot(contains('Private note')));
      sets.clear();
      expect(r.days[0].tables.first.rows.length, 2);
    },
  );
  test('food portions, recorded zero, missing days and historical goals', () {
    final foods = [
      TaggedFood(date: DateTime(2026, 10, 2), value: reportFood()),
      TaggedFood(date: DateTime(2026, 10, 3), value: reportFood(calories: 0)),
    ];
    const goal = NutritionGoal(
      dailyCalories: 1800,
      dailyProtein: 100,
      dailyCarbs: 200,
      dailyFat: 60,
    );
    final r = reportBuilder().build(
      reportRequest(),
      generatedAt: DateTime(2026, 10, 25),
      timeZone: 'Europe/Rome',
      foods: foods,
      goals: [TaggedNutritionGoal(date: DateTime(2026, 10, 3), value: goal)],
    );
    expect(r.days.first.calories, isNull);
    expect(r.days[1].calories, 300);
    expect(r.days[1].protein, 30);
    expect(r.days[2].calories, 0);
    expect(r.recordedFoodDays, 2);
    expect(r.averageCalories, 150);
    expect(
      r.days[1].tables[1].rows.any(
        (r) => r.first == 'Obiettivo giornaliero salvato',
      ),
      isFalse,
    );
    expect(r.days[2].tables[1].rows.last[2], '1800');
    expect(r.charts.firstWhere((c) => c.unit == 'kcal').values.take(3), [
      null,
      300,
      0,
    ]);
  });
  test(
    'actual measurements sort, convert, omit deleted and do not extrapolate',
    () {
      final r = reportBuilder().build(
        reportRequest(),
        generatedAt: DateTime(2026, 10, 25),
        timeZone: 'Europe/Rome',
        weights: [
          WeightMeasurement.generateID(
            weight: 176.369809748,
            time: DateTime(2026, 10, 2),
            weightUnit: Weights.lb,
          ),
          WeightMeasurement.generateID(
            weight: 82,
            time: DateTime(2026, 10, 1),
            weightUnit: Weights.kg,
          ),
          WeightMeasurement.generateID(
            weight: 1,
            time: DateTime(2026, 10, 3),
            weightUnit: Weights.kg,
            deleted: true,
          ),
          WeightMeasurement.generateID(
            weight: 50,
            time: DateTime(2026, 11, 1),
            weightUnit: Weights.kg,
          ),
        ],
        body: [
          BodyMeasurement.generateID(
            value: 90,
            time: DateTime(2026, 10, 4),
            type: BodyMeasurementPart.waist,
          ),
        ],
      );
      final table = r.summaries.last;
      expect(table.rows.first.first, 'Peso');
      expect(table.rows.first[3], '-2 kg');
      expect(table.rows.last.first, 'Vita');
      expect(table.rows.last[3], '—');
      expect(r.days[2].measurementCount, 0);
      expect(r.charts.last.values[2], isNull);
    },
  );
  test('empty period has no averages, charts or default goals', () {
    final r = reportBuilder(AppLocale.en).build(
      reportRequest(),
      generatedAt: DateTime(2026, 10, 25),
      timeZone: 'Europe/Rome',
    );
    expect(r.isEmpty, isTrue);
    expect(r.averageCalories, isNull);
    expect(r.charts, isEmpty);
    expect(r.days.first.tables[1].rows.length, 1);
  });
}
