import 'dart:math' as math;
import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/measurements.dart';
import 'package:gymtracker/model/progress_report.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/struct/nutrition.dart';
import 'package:intl/intl.dart';

/// Pure aggregation over actual records. No loading fallbacks or predictions.
class ProgressReportBuilder {
  final Translations t;
  final String locale;
  final Weights weightUnit;
  final Distance distanceUnit;
  final int accentColor;
  ProgressReportBuilder({
    required this.t,
    required this.locale,
    required this.weightUnit,
    required this.distanceUnit,
    this.accentColor = 0xff2196f3,
  });
  String n(num value) => NumberFormat('0.##', locale).format(value);
  String date(DateTime value) => DateFormat.yMMMd(locale).format(value);
  String duration(Duration value) =>
      '${value.inHours.toString().padLeft(2, '0')}:${(value.inMinutes % 60).toString().padLeft(2, '0')}:${(value.inSeconds % 60).toString().padLeft(2, '0')}';

  ProgressReport build(
    ReportRequest request, {
    required DateTime generatedAt,
    required String timeZone,
    List<Workout> workouts = const [],
    List<TaggedFood> foods = const [],
    List<TaggedNutritionGoal> goals = const [],
    List<WeightMeasurement> weights = const [],
    List<BodyMeasurement> body = const [],
  }) {
    final l = t.reports;
    final training = request.sections.contains(ReportSection.training);
    final nutrition = request.sections.contains(ReportSection.nutrition);
    final measurements = request.sections.contains(ReportSection.measurements);
    final selectedWorkouts = training
        ? {
            for (final w in workouts)
              if (w.isConcrete &&
                  w.startingDate != null &&
                  request.period.containsInstant(w.startingDate!))
                w.id: w,
          }.values.toList()
        : <Workout>[];
    selectedWorkouts.sort((a, b) => a.startingDate!.compareTo(b.startingDate!));
    final selectedGoals = [...goals]..sort((a, b) => a.date.compareTo(b.date));
    final points = <String, List<(DateTime, double, String)>>{};
    if (measurements) {
      for (final w in weights.where(
        (w) => !w.deleted && request.period.containsInstant(w.time),
      )) {
        (points[l.weight] ??= []).add((
          w.time.toLocal(),
          w.convertedWeightTo(weightUnit),
          weightUnit.name,
        ));
      }
      for (final b in body.where(
        (b) => !b.deleted && request.period.containsInstant(b.time),
      )) {
        (points[t.bodyMeasurement[b.type.name]?.label ?? b.type.name] ??= [])
            .add((b.time.toLocal(), b.value, b.type.unit));
      }
    }
    for (final series in points.values) {
      series.sort((a, b) => a.$1.compareTo(b.$1));
    }
    final days = <ReportDay>[];
    for (final day in request.period.days) {
      bool sameDay(DateTime d) =>
          d.year == day.year && d.month == day.month && d.day == day.day;
      final sessions = selectedWorkouts
          .where((w) => sameDay(w.startingDate!.toLocal()))
          .toList();
      final meals = nutrition
          ? foods.where((f) => sameDay(f.date)).toList()
          : <TaggedFood>[];
      final tables = <ReportTable>[];
      var completed = 0, reps = 0;
      var volume = 0.0;
      var elapsed = Duration.zero;
      for (final workout in sessions) {
        elapsed += workout.duration!;
        final rows = <List<String>>[];
        for (final entry in workout.exercises) {
          final exercises = entry.map(
            exercise: (e) => [e],
            superset: (s) => s.exercises,
          );
          for (final e in exercises) {
            for (var i = 0; i < e.sets.length; i++) {
              final set = e.sets[i];
              final p = set.parameters;
              final load = p.hasWeight && set.weight != null
                  ? Weights.convert(
                      value: set.effectiveWeight,
                      from: workout.weightUnit,
                      to: weightUnit,
                    )
                  : null;
              if (set.done) {
                completed++;
                if (p.hasReps) reps += set.reps ?? 0;
                if (p.hasReps && load != null) {
                  volume += math.max(0, load) * (set.reps ?? 0);
                }
              }
              rows.add([
                '${entry.isSuperset ? '${l.superset}: ' : ''}${e.getDisplayName(t)} · ${i + 1} · ${t.set.kindLong[set.kind.name] ?? set.kind.name}',
                set.done ? l.done : l.pending,
                p.hasReps && set.reps != null ? n(set.reps!) : '—',
                load == null ? '—' : '${n(load)} ${weightUnit.name}',
                p.hasTime && set.time != null ? duration(set.time!) : '—',
                p.hasDistance && set.distance != null
                    ? '${n(Distance.convert(value: set.distance!, from: workout.distanceUnit, to: distanceUnit))} ${distanceUnit.name}'
                    : '—',
              ]);
            }
            if (e.sets.isEmpty) {
              rows.add([
                e.getDisplayName(t),
                l.unavailable,
                '—',
                '—',
                '—',
                '—',
              ]);
            }
          }
        }
        tables.add(
          ReportTable(
            '${l.training}: ${workout.name}${workout.isContinuation ? ' · ${l.continuation}' : ''} · ${DateFormat.Hm(locale).format(workout.startingDate!.toLocal())} · ${duration(workout.duration!)}',
            [l.exercise, l.status, l.reps, l.load, l.duration, l.distance],
            rows.isEmpty
                ? [
                    [l.missing, '—', '—', '—', '—', '—'],
                  ]
                : rows,
          ),
        );
      }
      if (training && sessions.isEmpty) {
        tables.add(
          ReportTable(
            l.training,
            [l.status],
            [
              [l.missing],
            ],
          ),
        );
      }
      double sum(double Function(NutritionValues) value) =>
          meals.fold(0.0, (a, f) => a + value(f.value.nutritionalValues));
      final calories = meals.isEmpty ? null : sum((v) => v.calories);
      final protein = meals.isEmpty ? null : sum((v) => v.protein);
      final carbs = meals.isEmpty ? null : sum((v) => v.carbs);
      final fat = meals.isEmpty ? null : sum((v) => v.fat);
      if (nutrition) {
        final rows = <List<String>>[
          for (final f in meals)
            [
              '${f.value.category ?? l.unavailable} · ${f.value.name}',
              '${n(f.value.amount)} ${serializeUnit(f.value.unit)} × ${n(f.value.pieces)}',
              n(f.value.nutritionalValues.calories),
              n(f.value.nutritionalValues.protein),
              n(f.value.nutritionalValues.carbs),
              n(f.value.nutritionalValues.fat),
            ],
          if (meals.isNotEmpty)
            [l.total, '', n(calories!), n(protein!), n(carbs!), n(fat!)],
          if (meals.isEmpty) [l.missing, '—', '—', '—', '—', '—'],
        ];
        final applicable = selectedGoals.where((g) => !g.date.isAfter(day));
        if (applicable.isNotEmpty) {
          final g = applicable.last.value;
          rows.add([
            l.goal,
            '',
            n(g.dailyCalories),
            n(g.dailyProtein),
            n(g.dailyCarbs),
            n(g.dailyFat),
          ]);
        }
        tables.add(
          ReportTable(l.nutrition, [
            l.food,
            l.quantity,
            '${l.calories} (kcal)',
            '${l.protein} (g)',
            '${l.carbs} (g)',
            '${l.fat} (g)',
          ], rows),
        );
      }
      var count = 0;
      if (measurements) {
        final rows = <List<String>>[];
        for (final entry in points.entries) {
          for (final p in entry.value.where((p) => sameDay(p.$1))) {
            count++;
            rows.add([
              entry.key,
              DateFormat.Hm(locale).format(p.$1),
              '${n(p.$2)} ${p.$3}',
            ]);
          }
        }
        tables.add(
          ReportTable(
            l.measurements,
            [l.measurements, l.date, l.value],
            rows.isEmpty
                ? [
                    [l.missing, '—', '—'],
                  ]
                : rows,
          ),
        );
      }
      days.add(
        ReportDay(
          date: day,
          sessions: sessions.length,
          completedSets: completed,
          repetitions: reps,
          volume: volume,
          duration: elapsed,
          foodCount: meals.length,
          calories: calories,
          protein: protein,
          carbs: carbs,
          fat: fat,
          measurementCount: count,
          tables: tables,
        ),
      );
    }
    final summaries = <ReportTable>[];
    final charts = <ReportChart>[];
    if (training) {
      summaries.add(
        ReportTable(
          l.training,
          [l.summary, l.value],
          selectedWorkouts.isEmpty
              ? [
                  [l.status, l.missing],
                ]
              : [
                  [l.sessions, n(days.fold<int>(0, (a, d) => a + d.sessions))],
                  [l.sets, n(days.fold<int>(0, (a, d) => a + d.completedSets))],
                  [l.reps, n(days.fold<int>(0, (a, d) => a + d.repetitions))],
                  [
                    l.volume,
                    '${n(days.fold<double>(0, (a, d) => a + d.volume))} ${weightUnit.name}',
                  ],
                  [
                    l.duration,
                    duration(
                      days.fold(Duration.zero, (a, d) => a + d.duration),
                    ),
                  ],
                ],
        ),
      );
      if (days.where((d) => d.sessions > 0).length >= 2) {
        charts.add(
          ReportChart(l.activityChart, l.sets, [
            for (final d in days)
              d.sessions == 0 ? null : d.completedSets.toDouble(),
          ]),
        );
      }
    }
    if (nutrition) {
      final recorded = days.where((d) => d.foodCount > 0).toList();
      double total(double? Function(ReportDay) value) =>
          recorded.fold(0.0, (a, d) => a + (value(d) ?? 0));
      final totals = [
        total((d) => d.calories),
        total((d) => d.protein),
        total((d) => d.carbs),
        total((d) => d.fat),
      ];
      summaries.add(
        ReportTable(
          l.nutrition,
          [
            l.summary,
            '${l.calories} (kcal)',
            '${l.protein} (g)',
            '${l.carbs} (g)',
            '${l.fat} (g)',
          ],
          [
            [l.total, ...totals.map((v) => recorded.isEmpty ? '—' : n(v))],
            [
              '${l.average} (${recorded.length}/${days.length})',
              ...totals.map(
                (v) => recorded.isEmpty ? '—' : n(v / recorded.length),
              ),
            ],
          ],
        ),
      );
      if (recorded.length >= 2) {
        charts.add(
          ReportChart(l.calorieChart, 'kcal', [
            for (final d in days) d.calories,
          ]),
        );
      }
    }
    if (measurements) {
      final rows = <List<String>>[];
      for (final entry in points.entries) {
        final first = entry.value.first, last = entry.value.last;
        rows.add([
          entry.key,
          '${n(first.$2)} ${first.$3}\n${date(first.$1)}',
          '${n(last.$2)} ${last.$3}\n${date(last.$1)}',
          entry.value.length < 2 ? '—' : '${n(last.$2 - first.$2)} ${first.$3}',
        ]);
        if (entry.value.length >= 2) {
          charts.add(
            ReportChart(entry.key, first.$3, [
              for (final d in days)
                () {
                  final actual = entry.value.where(
                    (p) =>
                        p.$1.year == d.date.year &&
                        p.$1.month == d.date.month &&
                        p.$1.day == d.date.day,
                  );
                  return actual.isEmpty ? null : actual.last.$2;
                }(),
            ], zeroBaseline: false),
          );
        }
      }
      summaries.add(
        ReportTable(
          l.measurements,
          [l.measurements, l.first, l.last, l.change],
          rows.isEmpty
              ? [
                  [l.missing, '—', '—', '—'],
                ]
              : rows,
        ),
      );
    }
    return ProgressReport(
      request: request,
      locale: locale,
      weightUnit: weightUnit,
      distanceUnit: distanceUnit,
      generatedAt: generatedAt,
      timeZone: timeZone,
      accentColor: accentColor,
      days: days,
      summaries: summaries,
      charts: charts,
    );
  }
}
