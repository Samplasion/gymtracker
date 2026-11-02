import 'dart:math';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/controller/exercises_controller.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/data/exercises.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/gen/exercises.gen.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/provider/settings.dart';
import 'package:gymtracker/provider/stats.dart';
import 'package:gymtracker/provider/training_data.dart';
import 'package:gymtracker/utils/colors.dart';
import 'package:gymtracker/utils/constants.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/utils.dart'
    show getWeekNumber, firstDayOfWeekFor;
import 'package:gymtracker/view/charts/gym_equipment.dart';
import 'package:gymtracker/view/charts/line_charts_time_series.dart';
import 'package:gymtracker/view/charts/muscle_category.dart';
import 'package:gymtracker/view/components/alert_banner.dart';
import 'package:gymtracker/view/components/equipment_icon.dart';
import 'package:gymtracker/view/components/error_view.dart';
import 'package:gymtracker/view/components/loading_indicator.dart';
import 'package:gymtracker/view/components/muscles.dart';
import 'package:gymtracker/view/components/tweened_builder.dart';
import 'package:gymtracker/view/me/plateau.dart';
import 'package:gymtracker/view/utils/input_decoration.dart';
import 'package:gymtracker/view/utils/speed_dial.dart';
import 'package:gymtracker/view/utils/timer.dart';
import 'package:intl/intl.dart';

typedef _SpeedDialData = (int, Duration, double, int, double);

enum TimeFrame {
  sevenDays(Duration(days: 7)),
  thirtyDays(Duration(days: 30)),
  threeMonths(Duration(days: 90)),
  year(Duration(days: 365)),
  allTime;

  const TimeFrame([this.duration]);

  final Duration? duration;
}

class MeStatisticsPage extends ConsumerStatefulWidget {
  const MeStatisticsPage({super.key});

  @override
  ConsumerState<MeStatisticsPage> createState() => _MeStatisticsPageState();
}

class _MeStatisticsPageState extends ConsumerState<MeStatisticsPage>
    with SingleTickerProviderStateMixin {
  HistoryController get controller => ref.read(historyControllerProvider);
  late final _controller = TabController(length: 5, vsync: this);

  TimeFrame timeFrame = TimeFrame.thirtyDays;

  List<Workout> get periodWorkouts {
    if (timeFrame.duration != null) {
      return controller.history.inTimePeriod(
        timeFrame.duration!,
        now: ref.read(trainingClockProvider)(),
      );
    }
    return controller.history;
  }

  _SpeedDialData get speedDialData {
    final pw = periodWorkouts;

    int workouts = pw.length;
    Duration duration = Duration.zero;
    double volume = 0;
    int sets = 0;
    double distance = 0;

    for (final workout in pw) {
      duration += workout.duration ?? Duration.zero;
      volume += Weights.convert(
        value: workout.liftedWeight,
        from: workout.weightUnit,
        to: ref.read(settingsControllerInstanceProvider).weightUnit,
      );
      sets += workout.doneSets.length;
      distance += Distance.convert(
        value: workout.distanceRun,
        from: workout.distanceUnit,
        to: ref.read(settingsControllerInstanceProvider).distanceUnit,
      );
    }

    return (workouts, duration, volume, sets, distance);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(appPreferencesProvider);
    ref.watch(historyWorkoutsProvider);
    final speedDialData = this.speedDialData;

    final dropdown = DropdownButtonFormField(
      decoration: const GymTrackerInputDecoration(),
      items: [
        for (final timeFrame in TimeFrame.values)
          DropdownMenuItem(
            value: timeFrame,
            child: Text(
              context.t.me.stats.timeFrame[timeFrame.name] ?? "UNKNOWN",
            ),
          ),
      ],
      onChanged: (v) {
        if (v != null) setState(() => timeFrame = v);
      },
      initialValue: timeFrame,
    );
    final padded = Padding(
      padding:
          const EdgeInsets.only(left: 16, right: 16, top: 16) +
          MediaQuery.of(context).padding.copyWith(top: 0, bottom: 0),
      child: dropdown,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.me.stats.label),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        bottom: TabBar(
          isScrollable: true,
          controller: _controller,
          tabs: [
            Tab(
              icon: const Icon(GTIcons.stats),
              text: context.t.me.stats.atAGlance,
            ),
            Tab(
              icon: const Icon(GTIcons.muscle_groups),
              text: context.t.me.stats.muscleCategory,
            ),
            Tab(
              icon: const Icon(GTIcons.equipment),
              text: context.t.me.stats.gymEquipment,
            ),
            Tab(
              icon: EquipmentIcon(
                equipment: .barbell,
                size: Theme.of(context).iconTheme.size ?? 24,
              ),
              text: context.t.me.stats.mainThree.label,
            ),
            Tab(
              icon: const Icon(Icons.trending_flat),
              text: context.t.plateau.title,
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _controller,
        children: [
          SingleChildScrollView(
            padding:
                const EdgeInsets.all(16) +
                MediaQuery.of(context).padding.copyWith(top: 0),
            child: Column(
              spacing: 16,
              children: [
                dropdown,
                SpeedDial(
                  crossAxisCountBuilder: (bp) => switch (bp) {
                    Breakpoints.xxs || Breakpoints.xs => 1,
                    Breakpoints.xl => 4,
                    _ => 2,
                  },
                  buttonHeight: (bp) =>
                      switch (bp) {
                        Breakpoints.xxs || Breakpoints.xs => 1.1,
                        _ => 1.3,
                      } *
                      kSpeedDialButtonHeight,
                  buttons: [
                    TweenedIntBuilder(
                      value: speedDialData.$1,
                      builder: (context, value) {
                        return SpeedDialButton(
                          icon: const Icon(GTIcons.workout),
                          text: Text("${value.toInt()}"),
                          subtitle: Text(context.t.me.stats.workouts.label),
                        );
                      },
                    ),
                    TweenedIntBuilder(
                      value: speedDialData.$2.inMilliseconds,
                      builder: (context, value) {
                        return SpeedDialButton(
                          icon: const Icon(GTIcons.duration),
                          text: TimerView.buildTimeString(
                            context,
                            Duration(milliseconds: value),
                            builder: (time) => Text("${time.text}"),
                          ),
                          subtitle: Text(context.t.me.stats.duration.label),
                        );
                      },
                    ),
                    TweenedDoubleBuilder(
                      value: speedDialData.$3,
                      builder: (context, value) {
                        return SpeedDialButton(
                          icon: const Icon(GTIcons.volume),
                          text: Text(
                            value.getUserFacingWeight(
                              context.t,
                              ref.read(settingsControllerProvider).weightUnit,
                            ),
                          ),
                          subtitle: Text(context.t.me.stats.volume.label),
                        );
                      },
                    ),
                    TweenedIntBuilder(
                      value: speedDialData.$4,
                      builder: (context, value) {
                        return SpeedDialButton(
                          icon: const Icon(GTIcons.sets),
                          text: Text("$value"),
                          subtitle: Text(context.t.me.stats.sets.label),
                        );
                      },
                    ),
                    TweenedDoubleBuilder(
                      value: speedDialData.$5,
                      builder: (context, value) {
                        return SpeedDialButton(
                          icon: const Icon(GTIcons.distance),
                          text: Text(
                            value.getUserFacingDistance(
                              context.t,
                              ref.read(settingsControllerProvider).distanceUnit,
                            ),
                          ),
                          subtitle: Text(context.t.me.stats.distance.label),
                        );
                      },
                    ),
                  ],
                ),
                LayoutBuilder(
                  builder: (context, constr) {
                    return SizedBox(
                      child: MusclesView(
                        muscles: getIntensities(
                          periodWorkouts
                              .map(
                                (e) =>
                                    e.flattenedExercises.whereType<Exercise>(),
                              )
                              .expand((e) => e)
                              .toList(),
                          customExercises: ref
                              .read(exercisesControllerProvider)
                              .exercises,
                        ),
                        curve: Curves.easeOutSine,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Column(
            children: [
              padded,
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constr) {
                    return Padding(
                      padding:
                          const EdgeInsets.all(16) +
                          MediaQuery.of(context).padding.copyWith(top: 0),
                      child: SizedBox(
                        height: constr.maxHeight,
                        child: MuscleCategoryGraph(workouts: periodWorkouts),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          Column(
            children: [
              padded,
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constr) {
                    return Padding(
                      padding:
                          const EdgeInsets.all(16) +
                          MediaQuery.of(context).padding.copyWith(top: 0),
                      child: SizedBox(
                        height: constr.maxHeight,
                        child: GymEquipmentRadialChart(
                          workouts: periodWorkouts,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          _BigThreeStatsTab(),
          const PlateauStatisticsTab(),
        ],
      ),
    );
  }
}

class _BigThreeStatsTab extends ConsumerWidget {
  const _BigThreeStatsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(appPreferencesProvider);
    ref.watch(historyWorkoutsProvider);
    return LayoutBuilder(
      builder: (context, constr) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16) + MediaQuery.of(context).padding,
          child: Column(
            children: [
              _StatsMainLiftsChart(),
              const SizedBox(height: 16),
              AlertBanner(
                title: context.t.me.stats.mainThree.label,
                text: Text(context.t.me.stats.mainThree.description),
                color: GTMaterialColor.primary,
              ),
              AlertBanner(
                title: context.t.me.stats.mainThree.warning.title,
                text: Text(
                  context.t.me.stats.mainThree.warning.text(
                    exercises:
                        [
                              GTStandardLibrary.chest.barbellBenchPressFlat,
                              GTStandardLibrary.quadriceps.squatsBarbell,
                              GTStandardLibrary.back.deadlift,
                            ]
                            .map(
                              (id) =>
                                  '"${getStandardExerciseByID(id)?.getDisplayName(context.t) ?? id.toString()}"',
                            )
                            .join(", "),
                  ),
                ),
                color: GTMaterialColor.warning,
                icon: const Icon(GTIcons.warning),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatsMainLiftsChart extends ConsumerWidget {
  /// This chart shows the main lifts (bench press, squat, deadlift) over time.
  ///
  /// The chart is a line chart with the x-axis being the date and the y-axis
  /// being the weight lifted. Each lift is represented by a different color.
  /// Each point on the chart represents the heaviest set of that lift for that
  /// week. If there are no sets for a lift on a given week, that lift will not
  /// have a point for that week.
  const _StatsMainLiftsChart();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(appPreferencesProvider);
    final weightResult = ref.watch(
      majorThreeDisplayChartDataProvider(firstDayOfWeekFor(context.locale)),
    );

    return PageTransitionSwitcher(
      transitionBuilder: (child, animation, secondaryAnimation) {
        return SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: .scaled,
          child: child,
        );
      },
      layoutBuilder: (entries) {
        return LayoutBuilder(
          builder: (context, constr) {
            return AnimatedSize(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              clipBehavior: .none,
              child: SizedBox(
                width: constr.maxWidth,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: .none,
                  children: entries,
                ),
              ),
            );
          },
        );
      },
      child: weightResult.when(
        data: (weights) => _dataBuilder(context, weights, ref),
        loading: () => const Center(child: GBLoadingIndicator()),
        error: (error, stackTrace) => ErrorViewComponent(
          error: error,
          retryCallback: () => ref.refresh(majorThreeDataStreamProvider),
        ),
      ),
    );
  }

  Widget _dataBuilder(
    BuildContext context,
    Map<MajorLiftType, Map<DateTime, double>> weights,
    WidgetRef ref,
  ) {
    final Map<MajorLiftType, List<LineChartPoint>> data = {};

    for (final MapEntry(key: lift, value: weights) in weights.entries) {
      final Map<DateTime, List<num>> points = {};

      for (final MapEntry(key: date, :value) in weights.entries) {
        final weekStart = date.getStartOfWeek(context);
        points.putIfAbsent(weekStart, () => []);
        points[weekStart]!.add(value);
      }

      data[lift] = [
        for (final entry in points.entries)
          LineChartPoint(
            date: entry.key,
            value: entry.value.reduce(max).toDouble(),
          ),
      ];
    }

    final colors = [
      Colors.red,
      Colors.blue,
      Colors.orange,
      Colors.teal,
      Colors.purple,
      Colors.green,
    ];

    final names = {
      MajorLiftType.benchPress: exerciseStandardLibraryAsList
          .firstWhere(
            (ex) => ex.id == GTStandardLibrary.chest.barbellBenchPressFlat,
          )
          .getDisplayName(context.t),
      MajorLiftType.squat: exerciseStandardLibraryAsList
          .firstWhere(
            (ex) => ex.id == GTStandardLibrary.quadriceps.squatsBarbell,
          )
          .getDisplayName(context.t),
      MajorLiftType.deadlift: exerciseStandardLibraryAsList
          .firstWhere((ex) => ex.id == GTStandardLibrary.back.deadlift)
          .getDisplayName(context.t),
    };

    return LineChartTimeSeries(
      concurrent: true,
      categories: {
        MajorLiftType.benchPress: LineChartCategory(
          title: "Bench Press",
          // icon: const Icon(GTIcons.bench_press),
          icon: const Icon(Icons.abc),
        ),
        MajorLiftType.squat: LineChartCategory(
          title: "Squat",
          // icon: const Icon(GTIcons.squat),
          icon: const Icon(Icons.abc),
        ),
        MajorLiftType.deadlift: LineChartCategory(
          title: "Deadlift",
          // icon: const Icon(GTIcons.deadlift),
          icon: const Icon(Icons.abc),
        ),
      },
      data: {
        MajorLiftType.benchPress: [],
        MajorLiftType.squat: [],
        MajorLiftType.deadlift: [],
        ...data,
      },
      currentValueBuilder: (selectedCategory, hoveredIndex, point, isPredicted) {
        return Text(
          "${names[selectedCategory] ?? selectedCategory}: ${point.value.getUserFacingWeight(context.t, ref.read(statsWeightUnitProvider))} (${DateFormat.yMMMd(context.locale.languageCode).format(point.date)})",
        );
      },
      nullCurrentValueBuilder: (selectedCategory) {
        return Text("${names[selectedCategory] ?? selectedCategory}: ---");
      },
      leftTitleBuilder: (category, weight) {
        if (weight < 0) return "";
        return weight.getUserFacingWeight(
          context.t,
          ref.read(statsWeightUnitProvider),
        );
      },
      categoryColors: (context) => colors,
      bottomTitleBuilder: (date) {
        return context.t.me.stats.mainThree.bottomTitle(
          week: getWeekNumber(date).toString(),
        );
      },
    );
  }
}
