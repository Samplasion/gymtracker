import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/controller/exercises_controller.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/model/achievements.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/utils/constants.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/charts/bar_charts.dart';
import 'package:gymtracker/view/components/muscles.dart';
import 'package:gymtracker/view/utils/achievements.dart';
import 'package:gymtracker/view/utils/section_title.dart';
import 'package:gymtracker/view/utils/sliver_utils.dart';
import 'package:gymtracker/view/utils/speed_dial.dart';
import 'package:gymtracker/view/utils/timer.dart';

class WorkoutDoneSheet extends ConsumerStatefulWidget {
  final Workout workout;
  final ScrollController? controller;
  final Map<Achievement, AchievementCompletion> achievements;

  const WorkoutDoneSheet({
    required this.workout,
    this.controller,
    this.achievements = const {},
    super.key,
  });

  @override
  ConsumerState<WorkoutDoneSheet> createState() => _WorkoutDoneSheetState();
}

class _WorkoutDoneSheetState extends ConsumerState<WorkoutDoneSheet> {
  SettingsController get settingsController =>
      ref.watch(settingsControllerProvider);
  Workout get workout => widget.workout;
  ScrollController? get controller => widget.controller;

  late Map<GTMuscleHighlight, double> muscleChartHighlights;

  @override
  initState() {
    super.initState();
    muscleChartHighlights = getIntensities(
      workout.flattenedExercises.whereType<Exercise>().toList(),
      customExercises: ref.read(exercisesControllerProvider).exercises,
    );
  }

  @override
  didUpdateWidget(WorkoutDoneSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.workout != widget.workout) {
      muscleChartHighlights = getIntensities(
        workout.flattenedExercises.whereType<Exercise>().toList(),
      );
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
                  Go.back();
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(context.t.ongoingWorkout.goodJob.title),
              centerTitle: true,
              expandedTitleScale:
                  Theme.of(context).textTheme.displaySmall!.fontSize! /
                  Theme.of(context).textTheme.titleLarge!.fontSize!,
            ),
          ),
          if (widget.achievements.isNotEmpty) ...[
            SliverPadding(
              padding:
                  const EdgeInsets.all(16) +
                  MediaQuery.paddingOf(context).onlyHorizontal,
              sliver: SliverToBoxAdapter(
                child: SectionTitle(context.t.achievements.title),
              ),
            ),
            SliverList.builder(
              itemCount: widget.achievements.length,
              itemBuilder: (context, index) {
                final achievement = widget.achievements.keys.elementAt(index);
                final completion = widget.achievements.values.elementAt(index);
                return AchievementListTile(
                  achievement: achievement,
                  completion: completion,
                );
              },
            ),
          ],
          SliverPadding(
            padding:
                const EdgeInsets.all(16) +
                MediaQuery.paddingOf(context).onlyHorizontal,
            sliver: SliverList.list(
              children: [
                Text(
                  context.t.ongoingWorkout.goodJob.body,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                if (WeightDistributionBarChart.shouldShow(workout)) ...[
                  const SizedBox(height: 16),
                  WeightDistributionBarChart(workout: workout),
                ],
                if (WorkoutMuscleCategoriesBarChart.shouldShow(
                  workout,
                  ref,
                )) ...[
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
                      subtitle: Text(context.t.me.stats.duration.label),
                    ),
                    if (workout.liftedWeight > 0)
                      SpeedDialButton(
                        icon: const Icon(GTIcons.volume),
                        text: Text(
                          workout.liftedWeight.getUserFacingWeight(
                            context.t,
                            settingsController.weightUnit,
                          ),
                        ),
                        subtitle: Text(context.t.me.stats.volume.label),
                      ),
                    if (workout.distanceRun > 0)
                      SpeedDialButton(
                        icon: const Icon(GTIcons.distance),
                        text: Text(
                          workout.distanceRun.getUserFacingDistance(
                            context.t,
                            settingsController.distanceUnit,
                          ),
                        ),
                        subtitle: Text(context.t.me.stats.distance.label),
                      ),
                    SpeedDialButton(
                      icon: const Icon(GTIcons.sets),
                      text: Text(workout.doneSets.length.toString()),
                      subtitle: Text(context.t.me.stats.sets.label),
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
