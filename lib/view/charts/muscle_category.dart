import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/view/components/controlled.dart';
import 'package:gymtracker/view/components/spider_chart_plus.dart';
import 'package:simple_animations/simple_animations.dart';

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
    final tween = MovieTween(curve: Curves.easeOut);

    final entries = data.entries.toList();
    for (int i = 0; i < entries.length; i++) {
      tween.tween(
        "$i",
        Tween(begin: 0.0, end: entries[i].value),
        duration: const Duration(milliseconds: 400),
        begin: Duration(milliseconds: 50 * i),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: PlayAnimationBuilder<Movie>(
          tween: tween,
          duration: tween.duration,
          builder: (context, value, _) {
            return SpiderChartPlus(
              data: [
                for (int i = 0; i < entries.length; i++) value.get("$i"),
              ],
              maxValue: maxValue,
              colors: <Color>[
                for (final _ in data.entries)
                  Theme.of(context).colorScheme.primary,
              ],
              labels: [
                for (int i = 0; i < entries.length; i++)
                  "muscleCategories.${entries[i].key.name}".t,
              ],
              interPointStrokeColor: Theme.of(context).colorScheme.primary,
              interLineStrokeColor:
                  Theme.of(context).colorScheme.outlineVariant,
              areaFillColor:
                  Theme.of(context).colorScheme.primary.withOpacity(0.35),
              labelColor: Theme.of(context).colorScheme.outline,
              paintDataValues: kDebugMode,
            );
          }),
    );
  }
}
