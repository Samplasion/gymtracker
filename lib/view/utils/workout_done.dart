import 'package:flutter/material.dart';
import 'package:get/get.dart' hide ContextExtensionss;
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/utils/constants.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/view/charts/bar_charts.dart';
import 'package:gymtracker/view/components/muscles.dart';
import 'package:gymtracker/view/utils/sliver_utils.dart';
import 'package:gymtracker/view/utils/speed_dial.dart';
import 'package:gymtracker/view/utils/timer.dart';

class WorkoutDoneSheet extends StatefulWidget {
  final Workout workout;
  final ScrollController? controller;

  const WorkoutDoneSheet({required this.workout, this.controller, super.key});

  @override
  State<WorkoutDoneSheet> createState() => _WorkoutDoneSheetState();
}

class _WorkoutDoneSheetState extends State<WorkoutDoneSheet> {
  Workout get workout => widget.workout;
  ScrollController? get controller => widget.controller;

  late Map<GTMuscleHighlight, double> muscleChartHighlights;

  @override
  initState() {
    super.initState();
    muscleChartHighlights = getIntensities(
        workout.flattenedExercises.whereType<Exercise>().toList());
  }

  @override
  didUpdateWidget(WorkoutDoneSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.workout != widget.workout) {
      muscleChartHighlights = getIntensities(
          workout.flattenedExercises.whereType<Exercise>().toList());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: controller,
        slivers: [
          SliverAppBar.large(
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(GTIcons.done),
                onPressed: () {
                  Get.back();
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text('ongoingWorkout.goodJob.title'.t),
              expandedTitleScale:
                  context.theme.textTheme.displaySmall!.fontSize! /
                      context.theme.textTheme.titleLarge!.fontSize!,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16) +
                MediaQuery.paddingOf(context).onlyHorizontal,
            sliver: SliverList.list(
              children: [
                Text(
                  'ongoingWorkout.goodJob.body'.t,
                  style: context.theme.textTheme.bodyLarge,
                ),
                if (WeightDistributionBarChart.shouldShow(workout)) ...[
                  const SizedBox(height: 16),
                  WeightDistributionBarChart(workout: workout),
                ],
                if (WorkoutMuscleCategoriesBarChart.shouldShow(workout)) ...[
                  const SizedBox(height: 16),
                  WorkoutMuscleCategoriesBarChart(workout: workout),
                ],
                if (EquipmentDistributionBarChart.shouldShow(workout)) ...[
                  const SizedBox(height: 16),
                  EquipmentDistributionBarChart(workout: workout),
                ],
                const SizedBox(height: 16),
                MusclesView(
                  muscles: muscleChartHighlights,
                  curve: Curves.easeOutSine,
                ),
                const SizedBox(height: 16),
                SpeedDial(
                  crossAxisCountBuilder: (bp) => switch (bp) {
                    Breakpoints.xxs || Breakpoints.xs || Breakpoints.s => 1,
                    _ => 3,
                  },
                  buttonHeight: (bp) =>
                      switch (bp) {
                        Breakpoints.xxs || Breakpoints.xs => 1.1,
                        _ => 1.3,
                      } *
                      kSpeedDialButtonHeight,
                  buttons: [
                    SpeedDialButton(
                      icon: const Icon(GTIcons.duration),
                      text: TimerView.buildTimeString(
                        context,
                        workout.duration!,
                        builder: (time) => Text("${time.text}"),
                      ),
                      subtitle: Text("me.stats.duration.label".t),
                    ),
                    if (workout.liftedWeight > 0)
                      SpeedDialButton(
                        icon: const Icon(GTIcons.volume),
                        text: Text(workout.liftedWeight.userFacingWeight),
                        subtitle: Text("me.stats.volume.label".t),
                      ),
                    if (workout.distanceRun > 0)
                      SpeedDialButton(
                        icon: const Icon(GTIcons.distance),
                        text: Text(workout.distanceRun.userFacingDistance),
                        subtitle: Text("me.stats.distance.label".t),
                      ),
                    SpeedDialButton(
                      icon: const Icon(GTIcons.sets),
                      text: Text(workout.doneSets.length.toString()),
                      subtitle: Text("me.stats.sets.label".t),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          const SliverBottomSafeArea(),
        ],
      ),
    );
  }
}
