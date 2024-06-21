import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/data/distance.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/utils/constants.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/view/charts/muscle_category.dart';
import 'package:gymtracker/view/components/controlled.dart';
import 'package:gymtracker/view/components/tweened_builder.dart';
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

class MeStatisticsPage extends StatefulWidget {
  const MeStatisticsPage({super.key});

  @override
  State<MeStatisticsPage> createState() => _MeStatisticsPageState();
}

class _MeStatisticsPageState
    extends ControlledState<MeStatisticsPage, HistoryController> {
  TimeFrame timeFrame = TimeFrame.thirtyDays;

  List<Workout> get periodWorkouts {
    if (timeFrame.duration != null) {
      return controller.history.inTimePeriod(timeFrame.duration!);
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
        to: settingsController.weightUnit.value,
      );
      sets += workout.doneSets.length;
      distance += Distance.convert(
        value: workout.distanceRun,
        from: workout.distanceUnit,
        to: settingsController.distanceUnit.value,
      );
    }

    return (workouts, duration, volume, sets, distance);
  }

  @override
  Widget build(BuildContext context) {
    final speedDialData = this.speedDialData;

    return Scaffold(
      appBar: AppBar(
        title: Text("me.stats.label".t),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16) +
            MediaQuery.of(context).viewPadding.copyWith(top: 0),
        children: [
          DropdownButtonFormField(
            decoration: const GymTrackerInputDecoration(),
            items: [
              for (final timeFrame in TimeFrame.values)
                DropdownMenuItem(
                  value: timeFrame,
                  child: Text("me.stats.timeFrame.${timeFrame.name}".t),
                ),
            ],
            onChanged: (v) {
              if (v != null) setState(() => timeFrame = v);
            },
            value: timeFrame,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: max(200, min(context.width, context.height / 3)),
            height: max(200, min(context.width, context.height / 3)),
            child: MuscleCategoryGraph(
              workouts: periodWorkouts,
            ),
          ),
          const Divider(height: 32),
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
                    icon: const Icon(GymTrackerIcons.workout),
                    text: Text("${value.toInt()}"),
                    subtitle: Text("me.stats.workouts.label".t),
                  );
                },
              ),
              TweenedIntBuilder(
                value: speedDialData.$2.inMilliseconds,
                builder: (context, value) {
                  return SpeedDialButton(
                    icon: const Icon(GymTrackerIcons.duration),
                    text: TimerView.buildTimeString(
                      context,
                      Duration(milliseconds: value),
                      builder: (time) => Text("${time.text}"),
                    ),
                    subtitle: Text("me.stats.duration.label".t),
                  );
                },
              ),
              TweenedDoubleBuilder(
                value: speedDialData.$3,
                builder: (context, value) {
                  return SpeedDialButton(
                    icon: const Icon(GymTrackerIcons.volume),
                    text: Text(
                      "exerciseList.fields.weight".trParams({
                        "weight": NumberFormat.compact(
                                locale: Get.locale!.languageCode)
                            .format(value),
                        "unit":
                            "units.${settingsController.weightUnit.value.name}"
                                .t,
                      }),
                    ),
                    subtitle: Text("me.stats.volume.label".t),
                  );
                },
              ),
              TweenedIntBuilder(
                value: speedDialData.$4,
                builder: (context, value) {
                  return SpeedDialButton(
                    icon: const Icon(GymTrackerIcons.sets),
                    text: Text("$value"),
                    subtitle: Text("me.stats.sets.label".t),
                  );
                },
              ),
              TweenedDoubleBuilder(
                value: speedDialData.$5,
                builder: (context, value) {
                  return SpeedDialButton(
                    icon: const Icon(GymTrackerIcons.distance),
                    text: Text(
                      "exerciseList.fields.distance".trParams({
                        "distance": NumberFormat.compact(
                                locale: Get.locale!.languageCode)
                            .format(value),
                        "unit":
                            "units.${settingsController.distanceUnit.value.name}"
                                .t,
                      }),
                    ),
                    subtitle: Text("me.stats.distance.label".t),
                  );
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}
