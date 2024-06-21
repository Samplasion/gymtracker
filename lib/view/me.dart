import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/controller/me_controller.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/model/measurements.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/utils/constants.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/utils/theme.dart';
import 'package:gymtracker/utils/utils.dart';
import 'package:gymtracker/view/charts/density_calendar_chart.dart';
import 'package:gymtracker/view/charts/weight_chart.dart';
import 'package:gymtracker/view/me/calendar.dart';
import 'package:gymtracker/view/me/statistics.dart';
import 'package:gymtracker/view/utils/crossfade.dart';
import 'package:gymtracker/view/utils/date_field.dart';
import 'package:gymtracker/view/utils/input_decoration.dart';
import 'package:gymtracker/view/utils/section_title.dart';
import 'package:gymtracker/view/utils/speed_dial.dart';
import 'package:intl/intl.dart';

part 'me.weight.dart';

class MeView extends GetView<MeController> {
  const MeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text("me.title".t),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SafeArea(
                    top: false,
                    bottom: false,
                    child: SpeedDial(
                      crossAxisCountBuilder: (breakpoint) =>
                          switch (breakpoint) {
                        Breakpoints.xxs => 1,
                        _ => 2,
                      },
                      buttonHeight: (_) => kSpeedDialButtonHeight / 1.3,
                      buttons: [
                        SpeedDialButton(
                          icon: const Icon(GymTrackerIcons.calendar),
                          text: Text(
                            "me.calendar.label".t,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          onTap: () {
                            Go.to(() => const MeCalendarPage());
                          },
                        ),
                        SpeedDialButton(
                          icon: const Icon(GymTrackerIcons.stats),
                          text: Text(
                            "me.stats.label".t,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          onTap: () {
                            Go.to(() => const MeStatisticsPage());
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SafeArea(
                    top: false,
                    bottom: false,
                    child: SectionTitle("me.workoutDistribution.label".t),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SafeArea(
                    top: false,
                    bottom: false,
                    child: Card(
                      clipBehavior: Clip.hardEdge,
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Obx(
                          () {
                            final historyController =
                                Get.find<HistoryController>();
                            final firstDay =
                                historyController.history.first.startingDate!;
                            final now = DateTime.now();
                            final allDays = now.difference(firstDay).inDays;
                            return DensityCalendarChart(
                              tooltipBuilder: (now, daysBeforeNow, value) {
                                return "${DateFormat.yMEd(Get.locale?.languageCode).format(now.subtract(Duration(days: daysBeforeNow)))}: ${"general.workouts".plural(value)}";
                              },
                              values: [
                                for (int i = 0; i < allDays; i++)
                                  historyController
                                          .workoutsByDay[now
                                              .subtract(Duration(days: i))
                                              .startOfDay]
                                          ?.length ??
                                      0,
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SafeArea(
                    top: false,
                    bottom: false,
                    child: SectionTitle("me.weight.label".t),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: WeightCard(),
                ),
                Obx(
                  () => ListTile(
                    title: Text("me.weight.allData.label".t),
                    trailing: const Icon(GymTrackerIcons.lt_chevron),
                    enabled: controller.weightMeasurements.isNotEmpty,
                    onTap: () {
                      Go.to(() => const WeightMeasurementDataPage());
                    },
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
