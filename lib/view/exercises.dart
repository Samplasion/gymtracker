import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controller/history_controller.dart' as history;
import '../controller/workouts_controller.dart';
import '../model/exercise.dart';
import '../model/set.dart';
import '../model/workout.dart';
import '../service/localizations.dart';
import '../utils/go.dart';
import '../utils/sets.dart';
import '../utils/utils.dart';
import 'routine_creator.dart';
import 'utils/dropdown_dialog.dart';
import 'utils/exercise.dart';
import 'utils/timer.dart';

class ExercisesView extends StatefulWidget {
  const ExercisesView({required this.workout, super.key});

  final Workout workout;

  @override
  State<ExercisesView> createState() => _ExercisesViewState();
}

class _ExercisesViewState extends State<ExercisesView> {
  late Workout workout;

  @override
  void initState() {
    super.initState();
    workout = widget.workout;
  }

  WorkoutsController get controller => Get.find<WorkoutsController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(workout.name),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              if (workout.isConcrete) ...[
                PopupMenuItem(
                  textStyle: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                  child: Text("workouts.actions.changeParent.label".tr),
                  onTap: () {
                    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                      showDialog(
                        context: context,
                        builder: (_) {
                          return DropdownDialog(
                            title:
                                Text("workouts.actions.changeParent.label".tr),
                            items: [
                              DropdownMenuItem(
                                value: null,
                                child: Text(
                                  "workouts.actions.changeParent.options.none"
                                      .tr,
                                  style: const TextStyle(
                                      fontStyle: FontStyle.italic),
                                ),
                              ),
                              for (final workout in controller.workouts)
                                DropdownMenuItem(
                                  value: workout.id,
                                  child: Text(workout.name),
                                ),
                            ],
                            initialItem: workout.parentID,
                            onSelect: (value) {
                              setState(() => workout.parentID = value);
                              Get.find<history.HistoryController>()
                                  .setParentID(workout, newParentID: value);
                            },
                          );
                        },
                      );
                    });
                  },
                ),
                PopupMenuItem(
                  textStyle: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                  child: Text("workouts.actions.delete".tr),
                  onTap: () {
                    Get.find<history.HistoryController>()
                        .deleteWorkout(workout);
                    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                      Get.back();
                      Get.back();
                    });
                  },
                ),
              ] else ...[
                PopupMenuItem(
                  child: Text("routines.actions.edit".tr),
                  onTap: () {
                    SchedulerBinding.instance
                        .addPostFrameCallback((timeStamp) async {
                      final newRoutine = await Go.to<Workout>(
                          () => RoutineCreator(base: workout));

                      if (newRoutine != null) {
                        Get.find<WorkoutsController>().editRoutine(newRoutine);
                        setState(() {
                          workout = newRoutine;
                        });
                      }
                    });
                  },
                ),
                PopupMenuItem(
                  textStyle: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                  child: Text("routines.actions.delete".tr),
                  onTap: () {
                    Get.find<WorkoutsController>().deleteWorkout(workout);
                    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                      Get.back();
                      Get.back();
                    });
                  },
                ),
              ],
            ],
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          if (!workout.isConcrete && controller.getChildren(workout).isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: RoutineHistoryData(routine: workout),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                onPressed: () {
                  controller.startRoutine(context, workout);
                },
                child: Text(() {
                  if (workout.isConcrete) {
                    return "workouts.actions.start".tr;
                  } else {
                    return "routines.actions.start".tr;
                  }
                }()),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final exercise = workout.exercises[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ExerciseDataView(
                    exercise: exercise,
                    workout: workout,
                    index: index,
                  ),
                );
              },
              childCount: workout.exercises.length,
            ),
          ),
          if (kDebugMode)
            SliverToBoxAdapter(
              child: Text(workout.id, textAlign: TextAlign.center),
            ),
          if (kDebugMode)
            SliverToBoxAdapter(
              child: Text("${workout.parentID}", textAlign: TextAlign.center),
            ),
        ],
      ),
    );
  }
}

class RoutineHistoryData extends StatefulWidget {
  const RoutineHistoryData({
    required this.routine,
    super.key,
  });

  final Workout routine;

  @override
  State<RoutineHistoryData> createState() => _RoutineHistoryDataState();
}

enum _RoutineHistoryDataType {
  volume,
  reps,
  duration,
}

class _RoutineHistoryDataState extends State<RoutineHistoryData> {
  WorkoutsController get controller => Get.find<WorkoutsController>();
  List<Workout> get children => controller.getChildren(widget.routine);

  _RoutineHistoryDataType type = _RoutineHistoryDataType.volume;

  late int selectedIndex = children.length - 1;

  IconData buildType(_RoutineHistoryDataType type) {
    switch (type) {
      case _RoutineHistoryDataType.volume:
        return Icons.line_weight_rounded;
      case _RoutineHistoryDataType.reps:
        return Icons.numbers_rounded;
      case _RoutineHistoryDataType.duration:
        return Icons.timer_rounded;
    }
  }

  double _getY(Workout wo) {
    switch (type) {
      case _RoutineHistoryDataType.volume:
        return wo.liftedWeight;
      case _RoutineHistoryDataType.reps:
        return wo.reps.toDouble();
      case _RoutineHistoryDataType.duration:
        return wo.duration!.inSeconds.toDouble();
    }
  }

  Widget buildSpan(
    double value,
    TextStyle style, {
    bool showDate = true,
    TextAlign? textAlign,
  }) {
    return TimerView.buildTimeString(
      context,
      Duration(seconds: value.toInt()),
      builder: (time) {
        TextSpan buildType() {
          switch (type) {
            case _RoutineHistoryDataType.volume:
              return TextSpan(
                  text: "exerciseList.fields.weight".trParams({
                "weight": stringifyDouble(value),
                "unit": "units.kg".tr,
              }));
            case _RoutineHistoryDataType.reps:
              return TextSpan(
                  text: "exerciseList.fields.reps".plural(value.toInt()));
            case _RoutineHistoryDataType.duration:
              return time;
          }
        }

        return Text.rich(
          TextSpan(children: [
            TextSpan(
              children: [buildType()],
              style: style,
            ),
            if (showDate) ...[
              const TextSpan(text: " "),
              TextSpan(
                text: DateFormat.yMd()
                    .format(children[selectedIndex].startingDate!),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ]),
          textAlign: textAlign,
        );
      },
      style: style,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSpan(
            _getY(children[selectedIndex]),
            Theme.of(context)
                .textTheme
                .bodyLarge!
                .copyWith(fontWeight: FontWeight.bold)),
        AspectRatio(
          aspectRatio: 1.7,
          child: Padding(
            padding: const EdgeInsets.only(
              top: 16,
              right: 16,
            ),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: colorScheme.outlineVariant,
                      strokeWidth: 1,
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: colorScheme.outlineVariant,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 70,
                      // interval: 1,
                      getTitlesWidget: leftTitleWidgets(context),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: bottomTitleWidgets(context),
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  border: Border.all(color: colorScheme.outline),
                ),
                showingTooltipIndicators: [],
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
                  enabled: true,
                  touchCallback: (event, response) {
                    final touchLineBarSpot = response?.lineBarSpots?.first;
                    final index = touchLineBarSpot?.x.toInt();
                    if (index != selectedIndex && index != null) {
                      setState(() => selectedIndex = index);
                    }
                  },
                ),
                lineBarsData: [
                  LineChartBarData(
                    dotData: FlDotData(show: false),
                    spots: [
                      for (int i = 0; i < children.length; i++)
                        FlSpot(
                          i.toDouble(),
                          _getY(children[i]),
                        ),
                    ],
                    isCurved: true,
                    preventCurveOverShooting: true,
                    color: colorScheme.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    belowBarData: BarAreaData(
                      show: true,
                      color: colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                ],
              ),
              swapAnimationDuration: const Duration(milliseconds: 350),
              swapAnimationCurve: Curves.linearToEaseOut,
            ),
          ),
        ),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final type in _RoutineHistoryDataType.values)
                  ChoiceChip(
                    label: Text("exercise.chart.views.${type.name}".tr),
                    avatar: CircleAvatar(
                      child: this.type == type
                          ? const SizedBox.shrink()
                          : Icon(buildType(type), size: 16),
                    ),
                    selected: this.type == type,
                    onSelected: (sel) {
                      if (sel) {
                        setState(() => this.type = type);
                      }
                    },
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getDayMonth(DateTime? dateTime) {
    if (dateTime == null) return "";
    return "${dateTime.day}/${dateTime.month}";
  }

  Widget Function(double, TitleMeta) bottomTitleWidgets(BuildContext context) {
    return (double value, TitleMeta meta) {
      if (value == 0 ||
          _getDayMonth(children[value.toInt() - 1].startingDate) !=
              _getDayMonth(children[value.toInt()].startingDate)) {
        return SideTitleWidget(
          axisSide: meta.axisSide,
          child: Text(
            DateFormat.yMd()
                .format(children[value.toInt()].startingDate ?? DateTime.now()),
            style: Theme.of(context).textTheme.labelSmall,
          ),
        );
      } else {
        return SideTitleWidget(
          axisSide: meta.axisSide,
          child: Text(
            "",
            style: Theme.of(context).textTheme.labelSmall,
          ),
        );
      }
    };
  }

  Widget Function(double, TitleMeta) leftTitleWidgets(BuildContext context) {
    return (double value, TitleMeta meta) => SideTitleWidget(
          axisSide: meta.axisSide,
          child: buildSpan(
            value,
            Theme.of(context).textTheme.labelSmall!,
            showDate: false,
            textAlign: TextAlign.end,
          ),
        );
  }
}

class ExerciseDataView extends StatelessWidget {
  const ExerciseDataView({
    super.key,
    required this.exercise,
    required this.workout,
    required this.index,
  });

  final Exercise exercise;
  final Workout workout;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              ExerciseIcon(exercise: exercise),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(exercise.name,
                      style: Theme.of(context).textTheme.titleMedium),
                  TimerView.buildTimeString(
                    context,
                    workout.exercises[index].restTime,
                    builder: (time) => Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: "exerciseList.restTime".tr),
                          time
                        ],
                        style:
                            Theme.of(context).textTheme.labelMedium!.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                      ),
                    ),
                    style: const TextStyle(),
                  ),
                  if (kDebugMode) ...[
                    Text(exercise.id),
                    Text("parent: ${exercise.parentID}"),
                  ],
                ],
              ),
            ],
          ),
        ),
        for (int i = 0; i < exercise.sets.length; i++)
          ExerciseSetView(
            set: exercise.sets[i],
            exercise: exercise,
            isConcrete: workout.isConcrete,
            alt: i % 2 == 0,
          ),
      ],
    );
  }
}

class ExerciseSetView extends StatelessWidget {
  final ExSet set;
  final Exercise exercise;
  final bool isConcrete;
  final bool alt;

  const ExerciseSetView({
    required this.set,
    required this.exercise,
    required this.isConcrete,
    required this.alt,
    super.key,
  });

  List<Widget> get fields => [
        if ([SetParameters.repsWeight, SetParameters.timeWeight]
            .contains(set.parameters))
          Text("exerciseList.fields.weight".trParams({
            "weight": stringifyDouble(set.weight!),
            "unit": "units.kg".tr,
          })),
        if ([
          SetParameters.timeWeight,
          SetParameters.time,
        ].contains(set.parameters))
          Text("exerciseList.fields.time".trParams({
            "time":
                "${(set.time!.inSeconds ~/ 60).toString().padLeft(2, "0")}:${(set.time!.inSeconds % 60).toString().padLeft(2, "0")}",
          })),
        if ([SetParameters.repsWeight, SetParameters.freeBodyReps]
            .contains(set.parameters))
          Text("exerciseList.fields.reps".plural(set.reps ?? 0)),
        if ([SetParameters.distance].contains(set.parameters))
          Text("exerciseList.fields.distance".trParams({
            "distance": stringifyDouble(set.distance!),
            "unit": "units.km".tr,
          })),
      ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    var colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: alt
          ? scheme.background
          : ElevationOverlay.applySurfaceTint(
              scheme.surface,
              scheme.surfaceTint,
              0.7,
            ),
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          PopupMenuButton(
            icon: buildSetType(
              context,
              set.kind,
              set: set,
              allSets: exercise.sets,
            ),
            itemBuilder: (context) => <PopupMenuEntry<SetKind>>[],
            enabled: false,
          ),
          const SizedBox(width: 8),
          for (int i = 0; i < fields.length; i++) ...[
            if (i != 0) const SizedBox(width: 8),
            Expanded(child: fields[i])
          ],
          const SizedBox(width: 8),
          if (isConcrete) ...[
            if (set.done)
              Icon(Icons.check_box, color: colorScheme.tertiary)
            else
              Icon(Icons.check_box_outline_blank,
                  color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class OverwriteDialog extends StatelessWidget {
  const OverwriteDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.info),
      title: Text("ongoingWorkout.overwrite.title".tr),
      content: Text(
        "ongoingWorkout.overwrite.text".tr,
      ),
      actions: [
        TextButton(
          onPressed: () {
            Get.back(result: false);
          },
          child: Text("ongoingWorkout.overwrite.actions.no".tr),
        ),
        FilledButton.tonal(
          onPressed: () {
            Get.back(result: true);
          },
          child: Text("ongoingWorkout.overwrite.actions.yes".tr),
        ),
      ],
    );
  }
}
