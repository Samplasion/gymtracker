import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/utils/extensions.dart';

const kBarHeight = 24.0;
const kBarPadding = 24.0;

class WorkoutMuscleCategoriesBarChart extends GetWidget<HistoryController> {
  final Workout workout;

  const WorkoutMuscleCategoriesBarChart({required this.workout, super.key});

  static bool shouldShow(Workout workout) => Get.find<HistoryController>()
      .calculateMuscleCategoryDistributionFor(workouts: [workout])
      .entries
      .where((e) => e.value > 0)
      .isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final data =
        controller.calculateMuscleCategoryDistributionFor(workouts: [workout]);
    final nonEmptyData = data.entries.where((e) => e.value > 0).toList();
    final max = data.values.sum;

    String getLabel(GTMuscleCategory cat) =>
        "${"muscleCategories.${cat.name}".t} (${((data[cat] ?? 0) * 100 / max).round()}%)";

    final textReservedSize =
        nonEmptyData.map((e) => getLabel(e.key).computeSize().width + 16).max;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "exerciseList.workoutMuscleCategoriesBarChart.label".t,
          style: context.textTheme.bodyLarge!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        ConstrainedBox(
          constraints: BoxConstraints.loose(Size.fromHeight(
              nonEmptyData.length * (kBarHeight + kBarPadding))),
          child: Padding(
            padding: const EdgeInsets.only(
              top: 16,
            ),
            child: RotatedBox(
              quarterTurns: 1,
              child: BarChart(
                BarChartData(
                  barGroups: [
                    for (int i = 0; i < nonEmptyData.length; i++)
                      BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: nonEmptyData[i].value / max,
                            color: context.colorScheme.secondary,
                            width: 24,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      ),
                  ],
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    drawHorizontalLine: false,
                  ),
                  borderData: FlBorderData(show: false),
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: AxisTitles(
                        sideTitles: SideTitles(
                      showTitles: false,
                      reservedSize: 16,
                    )),
                    leftTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: textReservedSize,
                        getTitlesWidget: (x, meta) {
                          return RotatedBox(
                            quarterTurns: -1,
                            child: Text(getLabel(nonEmptyData[x.toInt()].key)),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
