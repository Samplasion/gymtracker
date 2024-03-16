import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/utils/constants.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/utils.dart';
import 'package:gymtracker/view/charts/muscle_category.dart';
import 'package:gymtracker/view/components/controlled.dart';
import 'package:gymtracker/view/utils/speed_dial.dart';
import 'package:gymtracker/view/utils/timer.dart';
import 'package:intl/intl.dart';

enum TimeFrame {
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

  (int, Duration, double, int) get speedDialData {
    final pw = periodWorkouts;

    int workouts = pw.length;
    Duration duration = Duration.zero;
    double volume = 0;
    int sets = 0;

    for (final workout in pw) {
      duration += workout.duration ?? Duration.zero;
      volume += Weights.convert(
        value: workout.liftedWeight,
        from: workout.weightUnit,
        to: settingsController.weightUnit.value!,
      );
      sets += workout.doneSets.length;
    }

    return (workouts, duration, volume, sets);
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
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
            ),
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
              key: ValueKey(timeFrame),
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
              SpeedDialButton(
                icon: const Icon(Icons.fitness_center_rounded),
                text: Text("${speedDialData.$1}"),
                subtitle: Text("me.stats.workouts.label".t),
              ),
              SpeedDialButton(
                icon: const Icon(Icons.access_time_rounded),
                text: TimerView.buildTimeString(
                  context,
                  speedDialData.$2,
                  builder: (time) => Text("${time.text}"),
                ),
                subtitle: Text("me.stats.duration.label".t),
              ),
              SpeedDialButton(
                icon: const Icon(Icons.line_weight_rounded),
                text: Text(
                  "exerciseList.fields.weight".trParams({
                    "weight":
                        NumberFormat.compact(locale: Get.locale!.languageCode)
                            .format(speedDialData.$3),
                    "unit":
                        "units.${settingsController.weightUnit.value!.name}".t,
                  }),
                ),
                subtitle: Text("me.stats.volume.label".t),
              ),
              SpeedDialButton(
                icon: const Icon(Icons.numbers_rounded),
                text: Text("${speedDialData.$4}"),
                subtitle: Text("me.stats.sets.label".t),
              ),
            ],
          )
        ],
      ),
    );
  }
}
