import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/view/components/controlled.dart';

class MuscleCategoryGraph extends StatefulWidget {
  final List<Workout> workouts;

  const MuscleCategoryGraph({required this.workouts, super.key});

  @override
  State<MuscleCategoryGraph> createState() => _MuscleCategoryGraphState();
}

class _MuscleCategoryGraphState
    extends ControlledState<MuscleCategoryGraph, HistoryController> {
  Map<GTMuscleCategory, double> get data => controller
      .calculateMuscleCategoryDistributionFor(workouts: widget.workouts);
  double get maxValue => data.values.max;

  @override
  Widget build(BuildContext context) {
    final entries = data.entries.toList();

    return RadarChart(
      RadarChartData(
        dataSets: [
          RadarDataSet(
            dataEntries: [
              for (int i = 0; i < entries.length; i++)
                RadarEntry(value: entries[i].value),
            ],
            borderColor: context.colorScheme.primary,
            fillColor:
                context.colorScheme.primary.withAlpha((0.3 * 255).round()),
            entryRadius: 0,
          ),
        ],
        radarShape: RadarShape.polygon,
        radarBorderData:
            BorderSide(color: context.colorScheme.outlineVariant, width: 1.5),
        tickBorderData: BorderSide(color: context.colorScheme.outlineVariant),
        gridBorderData: BorderSide(color: context.colorScheme.outlineVariant),
        radarTouchData: RadarTouchData(enabled: false),
        borderData: FlBorderData(show: false),
        ticksTextStyle: const TextStyle(color: Colors.transparent),
        getTitle: (i, angle) {
          if (angle > 90 && angle < 270) angle -= 180;
          return RadarChartTitle(
            text: "muscleCategories.${entries[i].key.name}".t,
            angle: angle,
            positionPercentageOffset: 0.1,
          );
        },
      ),
      swapAnimationDuration: const Duration(seconds: 1),
      swapAnimationCurve: Curves.easeInOut,
    );
  }
}
