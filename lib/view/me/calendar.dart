import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/controller/me_controller.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/utils/constants.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/components/controlled.dart';
import 'package:gymtracker/view/exercises.dart';
import 'package:gymtracker/view/utils/history_workout.dart';
import 'package:gymtracker/view/utils/speed_dial.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_clean_calendar/controllers/clean_calendar_controller.dart';
import 'package:scrollable_clean_calendar/models/day_values_model.dart';
import 'package:scrollable_clean_calendar/scrollable_clean_calendar.dart';
import 'package:scrollable_clean_calendar/utils/enums.dart';

const double kDayBorderRadius = 6;

class MeCalendarPage extends StatefulWidget {
  const MeCalendarPage({super.key});

  @override
  State<MeCalendarPage> createState() => _MeCalendarPageState();
}

class _MeCalendarPageState
    extends ControlledState<MeCalendarPage, MeController> {
  HistoryController get historyController => Get.find<HistoryController>();
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
    weekdayStart: GTLocalizations.firstDayOfWeekFor(context),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("me.calendar.label".t),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Obx(
              () {
                final streaks = historyController.streaks();
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
                      icon: Icon(GTIcons.streak_weeks,
                          color: context.harmonizeColor(Colors.orange)),
                      text: Text(
                          "me.calendar.streakWeeks".plural(streaks.weekStreak)),
                      subtitle: Text("me.calendar.streak".t),
                      dense: true,
                    ),
                    SpeedDialButton(
                      icon: Icon(GTIcons.streak_rest,
                          color: context
                              .harmonizeColor(Colors.deepPurple.shade300)),
                      text: Text(
                          "me.calendar.streakDays".plural(streaks.restDays)),
                      subtitle: Text("me.calendar.rest".t),
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
              locale: Get.locale!.languageCode,
              calendarController: calendarController,
              layout: Layout.DEFAULT,
              padding: EdgeInsets.symmetric(
                    horizontal: max(
                        0,
                        (context.width -
                                Breakpoints.xs.screenWidth.toDouble()) /
                            2),
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
                  alignment: AlignmentDirectional.bottomEnd,
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
      bgColor = Theme.of(context).colorScheme.surface.withOpacity(.4);
      txtStyle = (Theme.of(context).textTheme.bodyLarge)!.copyWith(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(.5),
      );
    }

    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(kDayBorderRadius),
      ),
      child: Text(
        values.text,
        textAlign: TextAlign.center,
        style: txtStyle,
      ),
    );
  }
}

class MeCalendarDayPage extends StatelessWidget {
  final DateTime day;

  const MeCalendarDayPage({required this.day, super.key});

  HistoryController get historyController => Get.find<HistoryController>();

  @override
  Widget build(BuildContext context) {
    final workouts = historyController.workoutsByDay[day] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat.yMMMMd(Get.locale!.languageCode).format(day)),
      ),
      body: workouts.isEmpty
          ? _buildEmpty(context)
          : _buildValues(context, workouts),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Text("me.calendar.empty".t),
    );
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
