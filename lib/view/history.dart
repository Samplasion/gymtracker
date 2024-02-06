import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controller/history_controller.dart';
import '../model/workout.dart';
import '../service/localizations.dart';
import '../utils/go.dart';
import 'exercises.dart';
import 'utils/exercise.dart';
import 'utils/timer.dart';

typedef MonthYear = (int month, int year);

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  Map<MonthYear, List<Workout>> get historyByMonth {
    final controller = Get.find<HistoryController>();
    final history = controller.history.reversed;
    final map = <MonthYear, List<Workout>>{};
    for (final workout in history) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () {
          final history = historyByMonth;
          return CustomScrollView(
            slivers: [
              SliverAppBar.large(
                title: Text("history.title".t),
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

  const HistoryWorkout(
      {required this.workout, this.showExercises = 5, super.key});

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
                              Text(workout.name,
                                  style:
                                      Theme.of(context).textTheme.titleMedium),
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
                                            time
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
