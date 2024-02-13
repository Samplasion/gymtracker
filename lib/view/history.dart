import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/exercises.dart';
import 'package:gymtracker/view/utils/exercise.dart';
import 'package:gymtracker/view/utils/timer.dart';
import 'package:intl/intl.dart';

typedef MonthYear = (int month, int year);

Map<MonthYear, List<Workout>> _getHistoryByMonthThread(List<Workout> raw) {
  final map = <MonthYear, List<Workout>>{};
  for (final workout in raw.reversed) {
    final key = (
      workout.startingDate!.month,
      workout.startingDate!.year,
    );
    if (!map.containsKey(key)) {
      map[key] = [];
    }
    map[key]!.add(workout);
  }
  return map;
}

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  late Future<Map<MonthYear, List<Workout>>> historyByMonth =
      compute(_getHistoryByMonthThread, () {
    final controller = Get.find<HistoryController>();
    return controller.userVisibleWorkouts;
  }());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: historyByMonth,
        builder: (context, snapshot) {
          final history = snapshot.data ?? {};

          return CustomScrollView(
            slivers: [
              SliverAppBar.large(
                title: Text("history.title".t),
              ),
              if (!snapshot.hasData)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
              for (final date in history.keys) ...[
                SliverStickyHeader.builder(
                  builder: (context, state) =>
                      _buildHeader(context, state, date),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      childCount: (history[date] ?? []).length,
                      (context, index) {
                        return HistoryWorkout(
                            workout: (history[date] ?? [])[index]);
                      },
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  _buildHeader(
    BuildContext context,
    SliverStickyHeaderState state,
    MonthYear date,
  ) {
    final elevatedAppBarColor = ElevationOverlay.applySurfaceTint(
      Theme.of(context).colorScheme.surface,
      Theme.of(context).colorScheme.surfaceTint,
      3,
    );
    return Container(
      height: 60,
      color: state.isPinned
          ? elevatedAppBarColor
          : Theme.of(context).colorScheme.background,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      child: Text(
        DateFormat.yMMMM(context.locale.languageCode).format(
          DateTime(date.$2, date.$1),
        ),
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}

class HistoryWorkout extends StatelessWidget {
  final Workout workout;
  final int showExercises;

  HistoryController get controller => Get.find<HistoryController>();

  late final Workout? continuation =
      controller.getContinuation(incompleteWorkout: workout);

  HistoryWorkout({
    required this.workout,
    this.showExercises = 5,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Go.to(() => ExercisesView(workout: workout));
          },
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                          child:
                              Text(workout.name.characters.first.toUpperCase()),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(text: workout.name),
                                    if (workout.isContinuation && kDebugMode)
                                      TextSpan(
                                        text: " [CONTINUATION]",
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error,
                                        ),
                                      ),
                                  ],
                                ),
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("general.exercises".plural(
                                    workout.displayExerciseCount,
                                  )),
                                  Flexible(
                                    child: TimerView.buildTimeString(
                                      context,
                                      workout.duration ?? Duration.zero,
                                      builder: (time) => Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(
                                              text: DateFormat.yMd(context
                                                      .locale.languageCode)
                                                  .add_Hm()
                                                  .format(
                                                      workout.startingDate ??
                                                          DateTime.now()),
                                            ),
                                            const TextSpan(text: " - "),
                                            time,
                                            if (continuation != null) ...[
                                              const TextSpan(text: "\n+ "),
                                              TextSpan(
                                                text: DateFormat.yMd(context
                                                        .locale.languageCode)
                                                    .add_Hm()
                                                    .format(continuation!
                                                            .startingDate ??
                                                        DateTime.now()),
                                              ),
                                              const TextSpan(text: " - "),
                                              TimerView.buildTimeString(
                                                context,
                                                continuation!.duration ??
                                                    Duration.zero,
                                                builder: (time) => time,
                                              ),
                                              const TextSpan(text: "\n"),
                                              TimerView.buildTimeString(
                                                context,
                                                (continuation!.duration ??
                                                        Duration.zero) +
                                                    (workout.duration ??
                                                        Duration.zero),
                                                builder: (time) => TextSpan(
                                                  text: "general.totalTime"
                                                      .tParams({
                                                    "time": time.text!,
                                                  }),
                                                ),
                                              )
                                            ]
                                          ],
                                        ),
                                        textAlign: TextAlign.end,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              for (final exercise in workout.exercises.take(showExercises))
                ExerciseListTile(
                  exercise: exercise,
                  selected: false,
                  isConcrete: true,
                ),
              if (workout.exercises.length > showExercises) ...[
                ListTile(
                  title: Text(
                    "history.andMore"
                        .plural(workout.displayExerciseCount - showExercises),
                  ),
                ),
              ] else ...[
                const SizedBox(height: 16),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
