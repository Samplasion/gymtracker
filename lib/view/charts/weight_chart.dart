import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gymtracker/model/measurements.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/utils/constants.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/theme.dart';
import 'package:gymtracker/utils/utils.dart';
import 'package:gymtracker/view/charts/line_charts_time_series.dart';
import 'package:gymtracker/view/components/responsive_builder.dart';
import 'package:intl/intl.dart';

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
              getTooltipColor: (_) => Colors.transparent,
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
                    colorScheme.primary.withAlpha((0.8 * 255).round()),
                    colorScheme.primary.withAlpha((0 * 255).round()),
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
                      predictionColor.withAlpha((0.8 * 255).round()),
                      predictionColor.withAlpha((0 * 255).round()),
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

class WeightChartTimeSeries extends StatefulWidget {
  final List<WeightMeasurement> weights;
  final PredictedWeightMeasurement? predictedWeight;
  final List<BodyMeasurement> bodyMeasurements;
  final ValueChanged<BodyMeasurementPart?>? onSelectCategory;

  const WeightChartTimeSeries({
    required this.weights,
    this.predictedWeight,
    required this.bodyMeasurements,
    this.onSelectCategory,
    super.key,
  });

  @override
  State<WeightChartTimeSeries> createState() => _WeightChartTimeSeriesState();
}

class _WeightChartTimeSeriesState extends State<WeightChartTimeSeries> {
  late Map<BodyMeasurementPart, List<BodyMeasurement>> measurementsByPart;

  @override
  void initState() {
    super.initState();
    measurementsByPart = {
      for (final part in BodyMeasurementPart.values)
        part: widget.bodyMeasurements
            .where((element) => element.type == part)
            .toList(),
    };
  }

  @override
  void didUpdateWidget(WeightChartTimeSeries oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only check for length; we're optimizing for performance here
    if (oldWidget.bodyMeasurements.length != widget.bodyMeasurements.length) {
      measurementsByPart = {
        for (final part in BodyMeasurementPart.values)
          part: widget.bodyMeasurements
              .where((element) => element.type == part)
              .toList(),
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(builder: (context, breakpoint) {
      final relevantWeights = widget.weights;

      return LineChartTimeSeries<BodyMeasurementPart?>(
        data: {
          null: [
            for (int i = 0; i < relevantWeights.length; i++)
              LineChartPoint(
                value: relevantWeights[i].convertedWeight,
                date: relevantWeights[i].time,
              ),
          ],
          for (final part in BodyMeasurementPart.values)
            part: [
              for (int i = 0; i < (measurementsByPart[part]?.length ?? 0); i++)
                LineChartPoint(
                  value: measurementsByPart[part]![i].value,
                  date: measurementsByPart[part]![i].time,
                ),
            ],
        },
        predictions: {
          if (widget.predictedWeight != null)
            null: [
              LineChartPoint(
                value: relevantWeights.last.convertedWeight,
                date: relevantWeights.last.time,
              ),
              LineChartPoint(
                value: widget.predictedWeight!.weight,
                date: widget.predictedWeight!.time,
              ),
            ]
        },
        categories: {
          null: LineChartCategory(
            title: "me.addWeight.weight.label".t,
            icon: Text(
              "me.addWeight.weight.label".t.characters.first,
              style: const TextStyle(fontSize: 10),
            ),
          ),
          for (final part in BodyMeasurementPart.values)
            part: LineChartCategory(
              title: "bodyMeasurement.${part.name}.label".t,
              icon: Text(
                "bodyMeasurement.${part.name}.label"
                    .t
                    .characters
                    .first
                    .toUpperCase(),
                style: const TextStyle(fontSize: 10),
              ),
            ),
        },
        currentValueBuilder: (type, __, point, isPredicted) => Text.rich(
          TextSpan(children: [
            TextSpan(
              children: [
                TextSpan(
                  text: type == null
                      ? point.value.userFacingWeight
                      : "${stringifyDouble(point.value, decimalSeparator: NumberFormat(context.locale.languageCode).symbols.DECIMAL_SEP)} ${type.unit}",
                )
              ],
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isPredicted
                        ? Theme.of(context).colorScheme.quaternary
                        : null,
                  ),
            ),
            const TextSpan(text: " "),
            TextSpan(
              text: DateFormat.yMd(context.locale.languageCode)
                  .format(point.date),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ]),
        ),
        leftTitleBuilder: (type, value) => type == null
            ? value.userFacingWeight
            : "${stringifyDouble(value, decimalSeparator: NumberFormat(context.locale.languageCode).symbols.DECIMAL_SEP)} ${type.unit}",
        onCategoryChanged: widget.onSelectCategory,
      );
    });
  }
}
