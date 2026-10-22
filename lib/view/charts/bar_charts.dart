import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/provider/settings.dart';
import 'package:gymtracker/provider/training_data.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/theme.dart';

const kBarHeight = 24.0;
const kBarPadding = 24.0;

class GTRawBarChart<T> extends ConsumerWidget {
  final String title;
  final Map<T, double> data;
  final String Function(T, double) labelBuilder;
  final Color? color;
  final String Function(T)? rightSideLabelBuilder;
  final EdgeInsetsGeometry padding;

  GTRawBarChart({
    super.key,
    required this.title,
    required this.data,
    required this.labelBuilder,
    this.color,
    this.rightSideLabelBuilder,
    this.padding = const EdgeInsets.all(16),
  });

  late final nonEmptyData = () {
    final ned = data.entries.where((e) => e.value > 0).toList();
    ned.sort((a, b) => a.value.compareTo(b.value));
    return ned;
  }();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(appPreferencesProvider);
    ref.watch(historyWorkoutsProvider);
    ref.watch(customExercisesProvider);
    final max = data.values.sum;

    String _getLabel(T cat) {
      final percentage = ((data[cat] ?? 0) * 100 / max);
      return labelBuilder(cat, percentage);
    }

    final textReservedSize = nonEmptyData.isEmpty
        ? 0.0
        : nonEmptyData
              .map(
                (e) =>
                    _getLabel(e.key)
                        .computeSize(
                          style: Theme.of(context).textTheme.bodyMedium,
                        )
                        .width +
                    16,
              )
              .max;

    double rightSideReservedSize = 16;
    if (rightSideLabelBuilder != null) {
      final rightLabelLengths = nonEmptyData.map(
        (e) =>
            rightSideLabelBuilder!(
              e.key,
            ).computeSize(style: Theme.of(context).textTheme.bodyMedium).width +
            16,
      );
      if (rightLabelLengths.isNotEmpty) {
        rightSideReservedSize = rightLabelLengths.max;
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
        ),
        ConstrainedBox(
          constraints: BoxConstraints.loose(
            Size.fromHeight(nonEmptyData.length * (kBarHeight + kBarPadding)),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
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
                            color: color ?? context.colorScheme.secondary,
                            width: 24,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      ),
                  ],
                  gridData: const FlGridData(
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
                        showTitles: rightSideLabelBuilder != null,
                        reservedSize: rightSideReservedSize,
                        getTitlesWidget: (value, meta) {
                          return RotatedBox(
                            quarterTurns: -1,
                            child: Text(
                              textAlign: TextAlign.right,
                              rightSideLabelBuilder!(
                                nonEmptyData[value.toInt()].key,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: textReservedSize,
                        getTitlesWidget: (x, meta) {
                          return RotatedBox(
                            quarterTurns: -1,
                            child: Text(_getLabel(nonEmptyData[x.toInt()].key)),
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

class WorkoutMuscleCategoriesBarChart extends ConsumerWidget {
  final Workout workout;

  const WorkoutMuscleCategoriesBarChart({required this.workout, super.key});

  static bool shouldShow(Workout workout, WidgetRef ref) => ref
      .read(historyControllerProvider)
      .calculateMuscleCategoryDistributionFor(workouts: [workout])
      .entries
      .where((e) => e.value > 0)
      .isNotEmpty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(appPreferencesProvider);
    ref.watch(historyWorkoutsProvider);
    ref.watch(customExercisesProvider);
    final data = ref
        .read(historyControllerProvider)
        .calculateMuscleCategoryDistributionFor(workouts: [workout]);

    return GTRawBarChart(
      title: context.t.exerciseList.workoutMuscleCategoriesBarChart.label,
      data: data,
      color: context.colorScheme.quaternary,
      labelBuilder: (cat, percentage) =>
          "${context.t.muscleCategories[cat.name]} (${percentage.round()}%)",
    );
  }
}

class WeightDistributionBarChart extends ConsumerWidget {
  final Workout workout;

  const WeightDistributionBarChart({required this.workout, super.key});

  static bool shouldShow(Workout workout) =>
      workout.isConcrete &&
      workout.liftedWeight > 0 &&
      workout.flattenedExercises.whereType<Exercise>().any(
        (ex) =>
            [
              ex.primaryMuscleGroup,
              ...ex.secondaryMuscleGroups,
            ].where((c) => c.category != null).isNotEmpty &&
            ex.liftedWeight != null &&
            ex.liftedWeight! > 0,
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(appPreferencesProvider);
    ref.watch(historyWorkoutsProvider);
    ref.watch(customExercisesProvider);
    final mappedWeights = <GTMuscleCategory, double>{};

    void processExercise(Exercise ex) {
      if (ex.liftedWeight == null) return;
      for (final group in [
        ex.primaryMuscleGroup,
        ...ex.secondaryMuscleGroups,
      ]) {
        if (group.category == null) continue;
        mappedWeights[group.category!] =
            (mappedWeights[group.category!] ?? 0) + ex.liftedWeight!;
      }
    }

    for (final ex in workout.exercises) {
      ex.when(
        exercise: processExercise,
        superset: (s) => s.exercises.forEach(processExercise),
      );
    }
    final max = mappedWeights.values.reduce(
      (value, element) => value > element ? value : element,
    );

    final percentages = {
      for (final entry in mappedWeights.entries) entry.key: entry.value / max,
    };

    return GTRawBarChart(
      title: context.t.exerciseList.workoutWeightDistributionBarChart.label,
      data: percentages,
      color: context.colorScheme.quinary,
      rightSideLabelBuilder: (category) {
        return mappedWeights[category]!.getUserFacingWeight(
          context.t,
          ref.read(settingsControllerProvider).weightUnit,
        );
      },
      labelBuilder: (cat, percentage) =>
          "${context.t.muscleCategories[cat.name]} (${percentage.round()}%)",
    );
  }
}

class EquipmentDistributionBarChart extends ConsumerWidget {
  final Workout workout;

  const EquipmentDistributionBarChart({required this.workout, super.key});

  static bool shouldShow(Workout workout) => workout.flattenedExercises
      .whereType<Exercise>()
      .any((ex) => ex.doneSets.isNotEmpty || !workout.isConcrete);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(appPreferencesProvider);
    ref.watch(historyWorkoutsProvider);
    ref.watch(customExercisesProvider);
    final setsPerEquipment = <GTGymEquipment, int>{};

    final exs = workout.flattenedExercises.whereType<Exercise>();
    for (final ex in exs) {
      setsPerEquipment[ex.gymEquipment] =
          (setsPerEquipment[ex.gymEquipment] ?? 0) +
          ex.sets
              .where((element) => element.done || !workout.isConcrete)
              .length;
    }

    final sum = setsPerEquipment.values.sum;
    final equipmentPercentages = {
      for (final entry in setsPerEquipment.entries)
        entry.key: entry.value.toDouble() / sum.toDouble(),
    };

    return GTRawBarChart(
      title: context.t.exerciseList.workoutEquipmentDistributionBarChart.label,
      data: equipmentPercentages,
      color: context.colorScheme.tertiary,
      labelBuilder: (eq, percentage) =>
          "${eq.getLocalizedName(context.t)} (${percentage.round()}%)",
    );
  }
}
