import "dart:math" as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymtracker/utils/extensions.dart' hide ContextThemingUtils;
import 'package:gymtracker/utils/utils.dart';
import 'package:intl/intl.dart';

class DensityCalendarChart extends StatelessWidget {
  final List<int> values;
  final String Function(DateTime start, int daysInThePast, int value)
      tooltipBuilder;

  DensityCalendarChart({
    super.key,
    required this.values,
    this.tooltipBuilder = _defaultTooltipBuilder,
  })  : assert(values.isNotEmpty),
        assert(values.every((value) => value >= 0));

  static String _defaultTooltipBuilder(
      DateTime start, int daysInThePast, int value) {
    return "${DateFormat.yMEd(Get.locale?.languageCode).format(start.subtract(Duration(days: daysInThePast)))}: $value";
  }

  final maxSquareSize = 24.0;
  final padding = 1.5;
  final minOpacity = 0.1;
  final maxOpacity = 1.0;
  final start = DateTime.now();

  TextStyle _labelStyle(BuildContext context) =>
      context.theme.textTheme.labelSmall!;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, size) {
        final crossCount =
            (size.maxWidth / (maxSquareSize + 2 * padding)).floor() - 1;

        final squareCount = 7 * crossCount;
        final sublist = (values + List.generate(squareCount, (_) => 0))
            .take(squareCount)
            .toList();

        final runningMin = sublist.safeMin ?? 0;
        final runningMax = sublist.safeMax ?? 1;

        return Column(
          children: [
            ConstrainedBox(
              constraints: size,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      for (int j = 0; j < 7; j++) _day(context, j),
                    ],
                  ),
                  for (int i = crossCount - 1; i >= 0; i--)
                    Column(
                      children: [
                        for (int j = 0; j < 7; j++)
                          _square(context, 7 * i + j, runningMax),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  runningMin.toString(),
                  style: _labelStyle(context),
                ),
                const SizedBox(width: 16),
                for (int i = 0;
                    i <
                        math.min((runningMax - runningMin + 1),
                            math.min(8, crossCount - 2));
                    i++)
                  _rawSquare(
                    context,
                    context.theme.colorScheme.tertiary.withOpacity(mapRange(
                      i.toDouble(),
                      0,
                      math.min((runningMax - runningMin + 1).toDouble(),
                              math.min(8, crossCount - 2)) -
                          1,
                      minOpacity,
                      maxOpacity,
                    ).clamp(0, 1)),
                  ),
                const SizedBox(width: 16),
                Text(
                  runningMax.toString(),
                  style: _labelStyle(context),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _square(BuildContext context, int index, int max) {
    final val = index >= values.length ? 0 : values[index];
    return Tooltip(
      message: tooltipBuilder(start, index, val),
      child: _rawSquare(
        context,
        context.theme.colorScheme.tertiary.withOpacity(
            mapRange(val.toDouble(), 0, max.toDouble(), minOpacity, maxOpacity)
                .clamp(0, 1)),
      ),
    );
  }

  Widget _rawSquare(BuildContext context, Color color) {
    return Container(
      margin: EdgeInsets.all(padding),
      constraints: BoxConstraints(
        minWidth: maxSquareSize,
        maxWidth: maxSquareSize,
        minHeight: maxSquareSize,
        maxHeight: maxSquareSize,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: context.theme.dividerColor.withOpacity(0.35),
          width: 0.8,
        ),
        color: color,
      ),
      child: const SizedBox.expand(),
    );
  }

  Widget _day(BuildContext context, int index) {
    return Container(
      margin: EdgeInsets.all(padding),
      constraints: BoxConstraints(
        minWidth: maxSquareSize,
        maxWidth: maxSquareSize,
        minHeight: maxSquareSize,
        maxHeight: maxSquareSize,
      ),
      child: Center(
        child: Text(
          DateFormat.E(Get.locale?.languageCode)
              .format(start.subtract(Duration(days: index)))
              .characters
              .first
              .toUpperCase(),
          style: _labelStyle(context),
        ),
      ),
    );
  }
}
