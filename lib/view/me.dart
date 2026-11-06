import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/controller/me_controller.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/model/measurements.dart';
import 'package:gymtracker/provider/measurements.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/provider/training_data.dart';
import 'package:gymtracker/utils/constants.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/utils/theme.dart';
import 'package:gymtracker/utils/utils.dart';
import 'package:gymtracker/view/achievements.dart';
import 'package:gymtracker/view/charts/density_calendar_chart.dart';
import 'package:gymtracker/view/charts/weight_chart.dart';
import 'package:gymtracker/view/components/section_card.dart';
import 'package:gymtracker/view/history.dart';
import 'package:gymtracker/view/me/calendar.dart';
import 'package:gymtracker/view/me/statistics.dart';
import 'package:gymtracker/view/progress_reports.dart';
import 'package:gymtracker/view/skeleton.dart';
import 'package:gymtracker/view/trainer.dart';
import 'package:gymtracker/view/utils/crossfade.dart';
import 'package:gymtracker/view/utils/date_field.dart';
import 'package:gymtracker/view/utils/input_decoration.dart';
import 'package:gymtracker/view/utils/online_profile_card.dart';
import 'package:gymtracker/view/utils/section_title.dart';
import 'package:gymtracker/view/utils/speed_dial.dart';
import 'package:intl/intl.dart';

part 'me.body.dart';
part 'me.profile.dart';

class MeView extends ConsumerWidget {
  const MeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(historyWorkoutsProvider);
    final workoutsByDay = ref.watch(workoutsByDayProvider);
    final history = ref.watch(historyControllerProvider).history;
    final firstDay = history.firstOrNull?.startingDate;
    final now = DateTime.now();
    final values = firstDay == null
        ? <int>[]
        : [
            for (
              var i = 0;
              i < math.max(1, now.difference(firstDay).inDays);
              i++
            )
              workoutsByDay[now.subtract(Duration(days: i)).startOfDay]
                      ?.length ??
                  0,
          ];
    final destinations = [
      (
        GTIcons.calendar,
        context.t.me.calendar.label,
        () => Go.to(() => const MeCalendarPage()),
      ),
      (
        GTIcons.stats,
        context.t.me.stats.label,
        () => Go.to(() => const MeStatisticsPage()),
      ),
      (
        Icons.picture_as_pdf_outlined,
        context.t.reports.title,
        () => Go.to(() => const ProgressReportsView()),
      ),
      (
        GTIcons.achievements,
        context.t.achievements.title,
        () => Go.to(() => const AchievementsView()),
      ),
    ];
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text(context.t.me.title),
            leading: const SkeletonDrawerButton(),
          ),
          SliverToBoxAdapter(
            child: SafeArea(
              top: false,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const OnlineProfileCard(),
                        const SizedBox(height: 16),
                        SpeedDial(
                          crossAxisCountBuilder: (breakpoint) =>
                              switch (breakpoint) {
                                Breakpoints.xxs => 1,
                                _ => 2,
                              },
                          buttonHeight: (_) =>
                              kSpeedDialButtonHeight /
                              1.3 *
                              math.max(
                                1,
                                MediaQuery.textScalerOf(context).scale(14) / 14,
                              ),
                          buttons: [
                            for (final (icon, title, onTap) in destinations)
                              SpeedDialButton(
                                icon: Icon(icon),
                                text: Text(
                                  title,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                onTap: onTap,
                              ),
                          ],
                        ),
                        if (values.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          GTSectionCard(
                            icon: Icons.calendar_month_rounded,
                            title: context.t.me.workoutDistribution.label,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                DensityCalendarChart(
                                  tooltipBuilder: (now, daysBeforeNow, value) =>
                                      "${DateFormat.yMEd(Localizations.localeOf(context).languageCode).format(now.subtract(Duration(days: daysBeforeNow)))}: ${context.t.general.workouts(n: value)}",
                                  values: values,
                                ),
                                const SizedBox(height: 16),
                                OutlinedButton.icon(
                                  onPressed: () =>
                                      Go.to(() => const HistoryView()),
                                  icon: const Icon(Icons.history_rounded),
                                  label: Text(context.t.history.title),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        SectionTitle(context.t.me.bodyMeasurements),
                        const SizedBox(height: 12),
                        const WeightCard(),
                        if (ref.watch(currentUserIdProvider) != null) ...[
                          const SizedBox(height: 24),
                          SectionTitle(context.t.me.trainer.heading),
                          const SizedBox(height: 12),
                          GTSectionCard(
                            icon: Icons.sports_rounded,
                            title: context.t.me.trainer.title,
                            subtitle: context.t.me.trainer.subtitle,
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: () => Go.to(() => const TrainerView()),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
