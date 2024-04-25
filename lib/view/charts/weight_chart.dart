import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gymtracker/utils/constants.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/theme.dart';
import 'package:gymtracker/view/components/responsive_builder.dart';

class WeightChart extends StatelessWidget {
  final List<double> weights;
  final double? predictedWeight;

  const WeightChart({required this.weights, this.predictedWeight, super.key});

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
      final minY = [
        ...relevantWeights,
        if (predictedWeight != null) predictedWeight!
      ].min;
      final maxY = [
        ...relevantWeights,
        if (predictedWeight != null) predictedWeight!
      ].max;
      final padding = [(maxY - minY) / 5, 2.5].min;

      final predictionColor = colorScheme.quaternary;
      final d = (relevantWeights.length + (predictedWeight == null ? 0 : 1));
      return LineChart(
        LineChartData(
          minY: minY - padding,
          maxY: maxY + padding,
          maxX: d - 0.5,
          gridData: const FlGridData(
            show: false,
            drawVerticalLine: false,
          ),
          titlesData: const FlTitlesData(
            show: false,
          ),
          borderData: FlBorderData(
            border: Border.all(color: Colors.transparent),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: Colors.transparent,
              getTooltipItems: (items) => <LineTooltipItem?>[
                ...items.map((_) => const LineTooltipItem(
                      "hhh",
                      TextStyle(color: Colors.transparent),
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
                checkToShowDot: (spot, data) {
                  return data.spots.length == spot.x + 1;
                },
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
            if (predictedWeight != null)
              LineChartBarData(
                dotData: FlDotData(
                  show: true,
                  checkToShowDot: (spot, data) {
                    return spot.x == relevantWeights.length;
                  },
                ),
                spots: [
                  FlSpot(
                    (relevantWeights.length - 1).toDouble(),
                    relevantWeights[(relevantWeights.length - 1)],
                  ),
                  FlSpot(
                    relevantWeights.length.toDouble(),
                    predictedWeight!,
                  ),
                ],
                isCurved: true,
                preventCurveOverShooting: true,
                color: predictionColor,
                barWidth: 3,
                isStrokeCapRound: true,
                dashArray: [5, 10],
                belowBarData: BarAreaData(
                  show: true,
                  spotsLine: BarAreaSpotsLine(
                    show: true,
                    checkToShowSpotLine: (spot) =>
                        spot.x == relevantWeights.length,
                    flLineStyle: FlLine(color: predictionColor, dashArray: [5]),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      predictionColor.withOpacity(0.8),
                      predictionColor.withOpacity(0),
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
