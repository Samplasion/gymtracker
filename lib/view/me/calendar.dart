import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/controller/me_controller.dart';
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
import 'package:scrollable_clean_calendar/utils/extensions.dart';

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
    minDate: historyController.userVisibleWorkouts.first.startingDate!,
    maxDate: DateTime.now(),
    rangeMode: false,
    initialFocusDate: DateTime.now(),
    onDayTapped: (day) {
      Go.to(() => MeCalendarDayPage(day: day.startOfDay));
    },
  );

  (int, int) computeStreaks(Map<DateTime, List<Workout>> workoutsByDay) {
    var (streak, rest) = (0, 0);

    var today = DateTime.now().startOfDay;

    if (workoutsByDay.containsKey(today)) {
      int past = 0;
      do {
        past += 1;
        streak++;
      } while (workoutsByDay
          .containsKey(today.subtract(Duration(days: past)).startOfDay));
    } else {
      int past = 0;
      do {
        past += 1;
        rest++;
      } while (!workoutsByDay
          .containsKey(today.subtract(Duration(days: past)).startOfDay));
    }

    return (streak, rest);
  }

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
            child: ListenableBuilder(
              listenable: historyController,
              builder: (context, _) {
                final (streakDays, restDays) =
                    computeStreaks(historyController.workoutsByDay);
                return SpeedDial(
                  crossAxisCountBuilder: (breakpoint) => switch (breakpoint) {
                    Breakpoints.xxs => 1,
                    Breakpoints.xs => 1,
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
                      icon: const Icon(Icons.fireplace_rounded),
                      text: Text("me.calendar.streak".t),
                      subtitle:
                          Text("me.calendar.streakDays".plural(streakDays)),
                      dense: true,
                    ),
                    SpeedDialButton(
                      icon: const Icon(Icons.nightlight_round),
                      text: Text("me.calendar.rest".t),
                      subtitle: Text("me.calendar.streakDays".plural(restDays)),
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
        border: values.day.isSameDay(values.minDate)
            ? Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              )
            : null,
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
