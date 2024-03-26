import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gymtracker/utils/constants.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/view/components/responsive_builder.dart';

class WeightChart extends StatelessWidget {
  final List<double> weights;

  const WeightChart({required this.weights, super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ResponsiveBuilder(builder: (context, breakpoint) {
      final relevantWeights = weights.reversed
          .take(switch (breakpoint) {
            Breakpoints.xxs || Breakpoints.xs => 10,
            _ => 20,
          })
          .toList()
          .reversed
          .toList();
      final minY = relevantWeights.min;
      final maxY = relevantWeights.max;
      final padding = (maxY - minY) / 5;

      return LineChart(
        LineChartData(
          minY: minY - padding,
          maxY: maxY + padding,
          maxX: relevantWeights.length - 0.5,
          gridData: FlGridData(
            show: false,
            drawVerticalLine: false,
          ),
          titlesData: FlTitlesData(
            show: false,
          ),
          borderData: FlBorderData(
            border: Border.all(color: Colors.transparent),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: Colors.transparent,
              getTooltipItems: (items) => <LineTooltipItem?>[
                ...items.map((_) => LineTooltipItem(
                      "hhh",
                      const TextStyle(color: Colors.transparent),
                    ))
              ],
            ),
            touchSpotThreshold: 10000,
            enabled: false,
          ),
          lineBarsData: [
            LineChartBarData(
              dotData: FlDotData(
                show: true,
                checkToShowDot: (spot, data) => data.spots.length == spot.x + 1,
              ),
              spots: [
                for (int i = 0; i < relevantWeights.length; i++)
                  FlSpot(
                    i.toDouble(),
                    relevantWeights[i],
                  ),
              ],
              isCurved: true,
              preventCurveOverShooting: true,
              color: colorScheme.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              belowBarData: BarAreaData(
                show: true,
                spotsLine: BarAreaSpotsLine(
                  show: true,
                  checkToShowSpotLine: (spot) =>
                      spot.x == relevantWeights.length - 1,
                  flLineStyle: FlLine(color: context.colorScheme.primary),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colorScheme.primary.withOpacity(0.8),
                    colorScheme.primary.withOpacity(0),
                  ],
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(milliseconds: 350),
        curve: Curves.linearToEaseOut,
      );
    });
  }
}
