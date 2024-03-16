import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/view/components/controlled.dart';
import 'package:gymtracker/view/components/spider_chart_plus.dart';

class MuscleCategoryGraph extends StatefulWidget {
  final List<Workout> workouts;

  const MuscleCategoryGraph({required this.workouts, super.key});

  @override
  State<MuscleCategoryGraph> createState() => _MuscleCategoryGraphState();
}

class _MuscleCategoryGraphState
    extends ControlledState<MuscleCategoryGraph, HistoryController> {
  late final data = controller.calculateMuscleCategoryDistributionFor(
      workouts: widget.workouts);
  double get maxValue => data.values.max;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: SpiderChartPlus(
        data: data.values.toList(),
        maxValue: maxValue,
        colors: <Color>[
          for (final _ in data.entries) Theme.of(context).colorScheme.primary,
        ],
        labels: data.keys.map((e) => "muscleCategories.${e.name}".t).toList(),
        interPointStrokeColor: Theme.of(context).colorScheme.primary,
        interLineStrokeColor: Theme.of(context).colorScheme.outlineVariant,
        areaFillColor: Theme.of(context).colorScheme.primary.withOpacity(0.35),
        labelColor: Theme.of(context).colorScheme.outline,
        paintDataValues: kDebugMode,
      ),
    );
  }
}
