import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/provider/training_data.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/utils/constants.dart';
import 'package:gymtracker/utils/extensions.dart' hide ContextThemingUtils;
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/utils/utils.dart' hide max;
import 'package:gymtracker/view/exercises.dart';
import 'package:gymtracker/view/utils/history_workout.dart';
import 'package:gymtracker/view/utils/speed_dial.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_clean_calendar/controllers/clean_calendar_controller.dart';
import 'package:scrollable_clean_calendar/models/day_values_model.dart';
import 'package:scrollable_clean_calendar/scrollable_clean_calendar.dart';
import 'package:scrollable_clean_calendar/utils/enums.dart';

const double kDayBorderRadius = 6;

class MeCalendarPage extends ConsumerStatefulWidget {
  const MeCalendarPage({super.key});

  @override
  ConsumerState<MeCalendarPage> createState() => _MeCalendarPageState();
}

class _MeCalendarPageState extends ConsumerState<MeCalendarPage> {
  HistoryController get historyController =>
      ref.read(historyControllerProvider);
  late final calendarController = CleanCalendarController(
    minDate: historyController.userVisibleWorkouts.isEmpty
        ? DateTime.now()
        : historyController.userVisibleWorkouts.first.startingDate!,
    maxDate: DateTime.now(),
    rangeMode: false,
    initialFocusDate: DateTime.now(),
    onDayTapped: (day) {
      Go.to(() => MeCalendarDayPage(day: day.startOfDay));
    },
    weekdayStart: firstDayOfWeekFor(context.locale),
  );
  late ProviderSubscription worker;

  @override
  void initState() {
    super.initState();
    historyController.queueStreaksRecomputation();
    worker = ref.listenManual(historyWorkoutsProvider, (_, next) {
      logger.i("History updated");
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    worker.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(historyWorkoutsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(context.t.me.calendar.label)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Builder(
              builder: (context) {
                final streaks = historyController.streaks;
                return SpeedDial(
                  crossAxisCountBuilder: (breakpoint) => switch (breakpoint) {
                    Breakpoints.xxs => 1,
                    _ => 2,
                  },
                  buttonHeight: (breakpoint) =>
                      switch (breakpoint) {
                        Breakpoints.xxs => 0.75,
                        _ => 1,
                      } *
                      kSpeedDialButtonHeight,
                  buttons: [
                    SpeedDialButton(
                      icon: Icon(
                        GTIcons.streak_weeks,
                        color: streaks.weekStreak == 0
                            ? Theme.of(context).colorScheme.outline
                            : context.harmonizeColor(Colors.orange),
                      ),
                      text: Text(context.t.time.weeks(n: streaks.weekStreak)),
                      subtitle: Text(context.t.me.calendar.streak),
                      dense: true,
                    ),
                    SpeedDialButton(
                      icon: Icon(
                        GTIcons.streak_rest,
                        color: context.harmonizeColor(
                          Colors.deepPurple.shade300,
                        ),
                      ),
                      text: Text(context.t.time.days(n: streaks.restDays)),
                      subtitle: Text(context.t.me.calendar.rest),
                      dense: true,
                    ),
                  ],
                );
              },
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ScrollableCleanCalendar(
              locale: Localizations.localeOf(context).languageCode,
              calendarController: calendarController,
              layout: Layout.DEFAULT,
              padding:
                  EdgeInsets.symmetric(
                    horizontal: max(
                      0,
                      (MediaQuery.sizeOf(context).width -
                              Breakpoints.xs.screenWidth.toDouble()) /
                          2,
                    ),
                  ) +
                  const EdgeInsets.all(16) +
                  MediaQuery.of(context).padding.copyWith(top: 0),
              dayBuilder: (context, values) {
                final date = values.day.startOfDay;
                final count =
                    (historyController.workoutsByDay[date]?.length ?? 0);
                return Badge(
                  label: Text(count.toString()),
                  isLabelVisible: count > 0,
                  offset: const Offset(2, 2),
                  child: _pattern(context, values),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _pattern(BuildContext context, DayValues values) {
    Color bgColor = Theme.of(context).colorScheme.surface;
    TextStyle txtStyle = (Theme.of(context).textTheme.bodyLarge)!.copyWith(
      color: Theme.of(context).colorScheme.onSurface,
    );

    if (values.day.startOfDay.isBefore(values.minDate.startOfDay) ||
        values.day.startOfDay.isAfter(values.maxDate.startOfDay)) {
      bgColor = Theme.of(
        context,
      ).colorScheme.surface.withAlpha((.4 * 255).round());
      txtStyle = (Theme.of(context).textTheme.bodyLarge)!.copyWith(
        color: Theme.of(
          context,
        ).colorScheme.onSurface.withAlpha((.5 * 255).round()),
      );
    }

    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(kDayBorderRadius),
      ),
      child: Text(values.text, textAlign: TextAlign.center, style: txtStyle),
    );
  }
}

class MeCalendarDayPage extends ConsumerWidget {
  final DateTime day;

  const MeCalendarDayPage({required this.day, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(historyWorkoutsProvider);
    final workouts =
        ref.read(historyControllerProvider).workoutsByDay[day] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          DateFormat.yMMMMd(
            Localizations.localeOf(context).languageCode,
          ).format(day),
        ),
      ),
      body: workouts.isEmpty
          ? _buildEmpty(context)
          : _buildValues(context, workouts),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(child: Text(context.t.me.calendar.empty));
  }

  Widget _buildValues(BuildContext context, List<Workout> workouts) {
    return ListView.builder(
      itemCount: workouts.length,
      itemBuilder: (context, index) {
        final workout = workouts[index];
        return HistoryWorkout(
          workout: workout,
          showExercises: workout.exercises.length,
          onTap: () {
            Go.to(() => ExercisesView(workout: workout));
          },
        );
      },
    );
  }
}
