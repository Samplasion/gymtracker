import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/provider/plateau.dart';
import 'package:gymtracker/provider/settings.dart';
import 'package:gymtracker/provider/training_data.dart';
import 'package:gymtracker/service/plateau_analysis.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/charts/line_charts_time_series.dart';
import 'package:gymtracker/view/components/error_view.dart';
import 'package:gymtracker/view/components/loading_indicator.dart';
import 'package:gymtracker/view/exercises.dart';
import 'package:intl/intl.dart';
import 'package:m3e_core/m3e_core.dart';

class PlateauStatisticsTab extends ConsumerWidget {
  const PlateauStatisticsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(appPreferencesProvider);
    final t = context.t.plateau;
    return ref
        .watch(plateauAnalysisProvider)
        .when(
          loading: () => const Center(child: GBLoadingIndicator()),
          error: (error, stack) => SingleChildScrollView(
            child: ErrorViewComponent(
              error: error,
              retryCallback: () => ref.invalidate(historyWorkoutsProvider),
            ),
          ),
          data: (results) {
            final flagged = results
                .where((r) => r.status == PlateauStatus.possiblePlateau)
                .toList();
            final other = results
                .where((r) => r.status != PlateauStatus.possiblePlateau)
                .toList();
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(t.intro),
                const SizedBox(height: 12),
                if (results.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(t.empty),
                  ),
                if (flagged.isEmpty &&
                    results.any((r) => r.status == PlateauStatus.progressing))
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(t.progressing),
                  ),
                M3EExpandableCardColumn(
                  allowMultipleExpanded: true,
                  initiallyExpanded: const {0},
                  data: [
                    M3EExpandableData(
                      title: t.title,
                      body: Text('${t.criteria}\n\n${t.volumeInfo}'),
                    ),
                    for (final result in flagged)
                      M3EExpandableData(
                        title: result.exercise.getDisplayName(context.t),
                        bodyBuilder: (_) => _PlateauDetails(result: result),
                      ),
                    if (other.isNotEmpty)
                      M3EExpandableData(
                        title: t.other,
                        body: Column(
                          children: [
                            for (final result in other)
                              ListTile(
                                title: Text(
                                  result.exercise.getDisplayName(context.t),
                                ),
                                subtitle: Text(switch (result.status) {
                                  PlateauStatus.progressing => t.progressing,
                                  PlateauStatus.stale => t.stale,
                                  PlateauStatus.unsupported => t.unsupported,
                                  PlateauStatus.incomparable => t.incomparable,
                                  _ => t.insufficientData,
                                }),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            );
          },
        );
  }
}

enum _Metric { load, reps, totalReps, volume }

class _PlateauDetails extends ConsumerWidget {
  const _PlateauDetails({required this.result});
  final PlateauResult result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t.plateau;
    final unit = ref.watch(settingsControllerProvider).weightUnit;
    final sessions = result.sessions;
    final weighted = sessions.first.loadKg != null;
    final dates = DateFormat.yMMMd(context.locale.languageCode);
    String weight(double value) => unit.format(
      context.t,
      Weights.convert(value: value, from: Weights.kg, to: unit),
    );
    String format(_Metric metric, double value) => switch (metric) {
      _Metric.load || _Metric.volume => weight(value),
      _ => value.toInt().toString(),
    };
    final labels = <_Metric, String>{
      if (weighted) _Metric.load: t.load,
      _Metric.reps: weighted ? t.reps : t.bestReps,
      if (!weighted) _Metric.totalReps: t.totalReps,
      if (weighted) _Metric.volume: t.volume,
    };
    double value(PlateauSession s, _Metric metric) => switch (metric) {
      _Metric.load => s.loadKg!,
      _Metric.reps => s.reps.toDouble(),
      _Metric.totalReps => s.totalReps.toDouble(),
      _Metric.volume => s.volumeKg!,
    };
    final baseline = result.baseline!;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.possiblePlateau,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '${t.period}: ${dates.format(sessions.first.date)} – ${dates.format(sessions.last.date)}',
          ),
          Text(
            '${t.sessions}: ${sessions.length} - ${t.sets}: ${sessions.first.setCount}',
          ),
          const SizedBox(height: 8),
          Text(t.reference),
          Text(
            weighted
                ? '${t.load}: ${weight(baseline.loadKg)} - ${t.reps}: ${baseline.reps.toInt()} - ${t.volume}: ${weight(baseline.volumeKg)}'
                : '${t.bestReps}: ${baseline.reps.toInt()} - ${t.totalReps}: ${baseline.totalReps.toInt()}',
          ),
          LineChartTimeSeries<_Metric>(
            key: ValueKey((
              result.exercise.parentID,
              sessions
                  .map((s) => (s.date, s.loadKg, s.reps, s.volumeKg))
                  .toString(),
              unit,
            )),
            categories: labels.map(
              (metric, label) => MapEntry(
                metric,
                LineChartCategory(
                  title: label,
                  icon: const Icon(Icons.show_chart),
                ),
              ),
            ),
            data: {
              for (final metric in labels.keys)
                metric: [
                  for (final s in sessions)
                    LineChartPoint(date: s.date, value: value(s, metric)),
                ],
            },
            leftTitleBuilder: format,
            currentValueBuilder: (metric, index, point, predicted) {
              final session = sessions.firstWhere((s) => s.date == point.date);
              return TextButton(
                onPressed: () => Go.to(
                  () => ExercisesView(
                    workout: session.workout,
                    highlightExercise: (exercise) =>
                        exercise is Exercise &&
                        exercise.parentID == result.exercise.parentID,
                  ),
                ),
                child: Text(
                  '${dates.format(point.date)} · ${labels[metric]}: ${format(metric, point.value)}',
                ),
              );
            },
          ),
          Text(t.data, style: Theme.of(context).textTheme.titleMedium),
          Column(
            children: [
              for (final s in sessions)
                ListTile(
                  title: Text(dates.format(s.date)),
                  subtitle: Text(
                    labels.entries
                        .map(
                          (e) =>
                              '${e.value}: ${format(e.key, value(s, e.key))}',
                        )
                        .join(' · '),
                  ),
                  onTap: () => Go.to(
                    () => ExercisesView(
                      workout: s.workout,
                      highlightExercise: (exercise) =>
                          exercise is Exercise &&
                          exercise.parentID == result.exercise.parentID,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
