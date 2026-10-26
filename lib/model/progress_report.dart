import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/data/weights.dart';

enum ReportPeriodKind { day, week, month }

enum ReportSection { training, nutrition, measurements }

/// Calendar boundaries: start inclusive, end exclusive. Never add 24-hour days.
class ReportPeriod {
  final DateTime start;
  final DateTime end;
  const ReportPeriod(this.start, this.end);

  factory ReportPeriod.forDate(
    ReportPeriodKind kind,
    DateTime date, {
    required int firstDayOfWeek,
  }) {
    final day = DateTime(date.year, date.month, date.day);
    return switch (kind) {
      ReportPeriodKind.day => ReportPeriod(
        day,
        DateTime(day.year, day.month, day.day + 1),
      ),
      ReportPeriodKind.week => () {
        final start = DateTime(
          day.year,
          day.month,
          day.day - (day.weekday - firstDayOfWeek + 7) % 7,
        );
        return ReportPeriod(
          start,
          DateTime(start.year, start.month, start.day + 7),
        );
      }(),
      ReportPeriodKind.month => ReportPeriod(
        DateTime(day.year, day.month),
        DateTime(day.year, day.month + 1),
      ),
    };
  }

  bool containsInstant(DateTime date) =>
      !date.toLocal().isBefore(start) && date.toLocal().isBefore(end);
  bool containsDay(DateTime date) =>
      containsInstant(DateTime(date.year, date.month, date.day));
  List<DateTime> get days => [
    for (
      var day = start;
      day.isBefore(end);
      day = DateTime(day.year, day.month, day.day + 1)
    )
      day,
  ];
}

class ReportRequest {
  final ReportPeriodKind kind;
  final ReportPeriod period;
  final Set<ReportSection> sections;
  ReportRequest({
    required this.kind,
    required this.period,
    required Set<ReportSection> sections,
  }) : sections = Set.unmodifiable(sections) {
    if (sections.isEmpty) throw ArgumentError('Select at least one section');
  }
}

class ReportTable {
  final String title;
  final List<String> headers;
  final List<List<String>> rows;
  ReportTable(this.title, List<String> headers, List<List<String>> rows)
    : headers = List.unmodifiable(headers),
      rows = List.unmodifiable(rows.map((r) => List<String>.unmodifiable(r)));
}

class ReportChart {
  final String title;
  final String unit;
  final List<double?> values;
  final bool zeroBaseline;
  ReportChart(
    this.title,
    this.unit,
    List<double?> values, {
    this.zeroBaseline = true,
  }) : values = List.unmodifiable(values);
}

class ReportDay {
  final DateTime date;
  final int sessions;
  final int completedSets;
  final int repetitions;
  final double volume;
  final Duration duration;
  final int foodCount;
  final double? calories, protein, carbs, fat;
  final int measurementCount;
  final List<ReportTable> tables;
  ReportDay({
    required this.date,
    required this.sessions,
    required this.completedSets,
    required this.repetitions,
    required this.volume,
    required this.duration,
    required this.foodCount,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.measurementCount,
    required List<ReportTable> tables,
  }) : tables = List.unmodifiable(tables);
  bool get hasRecords => sessions > 0 || foodCount > 0 || measurementCount > 0;
}

/// An immutable presentation snapshot: never retains mutable database models.
class ProgressReport {
  final ReportRequest request;
  final String locale;
  final Weights weightUnit;
  final Distance distanceUnit;
  final DateTime generatedAt;
  final String timeZone;
  final int accentColor;
  final List<ReportDay> days;
  final List<ReportTable> summaries;
  final List<ReportChart> charts;
  ProgressReport({
    required this.request,
    required this.locale,
    required this.weightUnit,
    required this.distanceUnit,
    required this.generatedAt,
    required this.timeZone,
    this.accentColor = 0xff2196f3,
    required List<ReportDay> days,
    required List<ReportTable> summaries,
    required List<ReportChart> charts,
  }) : days = List.unmodifiable(days),
       summaries = List.unmodifiable(summaries),
       charts = List.unmodifiable(charts);
  int get recordedFoodDays => days.where((d) => d.foodCount > 0).length;
  double? get averageCalories => recordedFoodDays == 0
      ? null
      : days.fold<double>(0, (n, d) => n + (d.calories ?? 0)) /
            recordedFoodDays;
  bool get isEmpty => !days.any((d) => d.hasRecords);
}
