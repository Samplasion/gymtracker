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
  late Future<Map<MonthYear, List<Workout>>> historyByMonth = Future.value({});
  late Worker worker;

  Set<String> selectedEntries = {};

  @override
  void initState() {
    super.initState();
    printInfo(info: "Init state");
    _recompute();
    final controller = Get.find<HistoryController>();
    worker = ever(
      controller.history,
      (callback) {
        printInfo(info: "History updated");
        _recompute();
      },
    );
  }

  _recompute() {
    final controller = Get.find<HistoryController>();
    try {
      // TODO: Figure out why this freaks out
      // historyByMonth = compute(_getHistoryByMonthThread, () {
      //   print(
      //       controller.userVisibleWorkouts.map((e) => e.runtimeType).toList());
      //   return controller.userVisibleWorkouts;
      // }());
      historyByMonth = Future.value(_getHistoryByMonthThread(
        controller.userVisibleWorkouts,
      ));
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      printError(info: e.toString());
    }
  }

  @override
  void dispose() {
    printInfo(info: "Dispose state");
    worker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: historyByMonth,
        builder: (context, snapshot) {
          final history = snapshot.data ?? {};

          return CustomScrollView(
            slivers: [
              _buildAppBar(),
              if (!snapshot.hasData)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                SliverToBoxAdapter(
                  child: AnimatedCrossFade(
                    firstChild: const SizedBox(
                      height: 100,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    secondChild: const SizedBox.shrink(),
                    crossFadeState:
                        snapshot.connectionState != ConnectionState.done
                            ? CrossFadeState.showFirst
                            : CrossFadeState.showSecond,
                    duration: const Duration(milliseconds: 300),
                  ),
                ),
              for (final date in history.keys) ...[
                SliverStickyHeader.builder(
                  builder: (context, state) => _buildHeader(state, date),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      childCount: (history[date] ?? []).length,
                      (context, index) {
                        final thatDate = (history[date] ?? []);

                        _toggle() {
                          if (snapshot.connectionState !=
                              ConnectionState.done) {
                            return;
                          }
                          setState(() {
                            if (selectedEntries.contains(thatDate[index].id)) {
                              selectedEntries.remove(thatDate[index].id);
                            } else {
                              selectedEntries.add(thatDate[index].id);
                            }
                          });
                        }

                        return HistoryWorkout(
                          workout: thatDate[index],
                          isSelected:
                              selectedEntries.contains(thatDate[index].id),
                          onTap: () {
                            if (selectedEntries.isEmpty) {
                              Go.to(() =>
                                  ExercisesView(workout: thatDate[index]));
                            } else {
                              _toggle();
                            }
                          },
                          onLongPress: () {
                            _toggle();
                          },
                        );
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

  Widget _buildAppBar() {
    if (selectedEntries.isEmpty) {
      return SliverAppBar.large(
        title: Text("history.title".t),
      );
    }

    return SliverAppBar.large(
      backgroundColor: Theme.of(context).colorScheme.inverseSurface,
      foregroundColor: Theme.of(context).colorScheme.onInverseSurface,
      surfaceTintColor: Colors.transparent,
      title: Text(
        "general.selected".plural(selectedEntries.length),
      ),
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () {
          setState(() {
            selectedEntries.clear();
          });
        },
      ),
      actions: [
        IconButton(
          tooltip: "history.actions.deleteMultiple.title"
              .plural(selectedEntries.length),
          icon: const Icon(Icons.delete),
          onPressed: () {
            final controller = Get.find<HistoryController>();
            controller.deleteWorkoutsWithDialog(
              context,
              workoutIDs: selectedEntries,
              onDeleted: () {
                Go.snack("history.actions.deleteMultiple.done"
                    .plural(selectedEntries.length));
                selectedEntries.clear();
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildHeader(
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
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  HistoryController get controller => Get.find<HistoryController>();

  late final Workout? continuation =
      controller.getContinuation(incompleteWorkout: workout);

  HistoryWorkout({
    required this.workout,
    this.showExercises = 5,
    this.isSelected = false,
    this.onTap,
    this.onLongPress,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final fg =
        isSelected ? colorScheme.onSurface : colorScheme.onPrimaryContainer;
    final bg = isSelected ? colorScheme.surface : colorScheme.primaryContainer;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: isSelected ? 16 : Theme.of(context).cardTheme.elevation,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          onLongPress: onLongPress,
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
                          backgroundColor: bg,
                          foregroundColor: fg,
                          child: isSelected
                              ? const Icon(Icons.check)
                              : Text(
                                  workout.name.characters.first.toUpperCase()),
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
