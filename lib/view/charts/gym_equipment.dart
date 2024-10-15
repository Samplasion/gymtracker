import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/view/components/controlled.dart';

class GymEquipmentRadialChart extends StatefulWidget {
  final List<Workout> workouts;

  const GymEquipmentRadialChart({required this.workouts, super.key});

  @override
  State<GymEquipmentRadialChart> createState() =>
      _GymEquipmentRadialChartState();
}

class _GymEquipmentRadialChartState
    extends ControlledState<GymEquipmentRadialChart, HistoryController> {
  Map<GTGymEquipment, double> get data => controller
      .calculateGymEquipmentDistributionFor(workouts: widget.workouts);
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
            fillColor: context.colorScheme.primary.withOpacity(0.3),
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
            text: entries[i].key.localizedNameShort,
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
