import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/exercises.dart';
import 'package:gymtracker/view/me/calendar.dart';
import 'package:gymtracker/view/utils/action_icon.dart';
import 'package:gymtracker/view/utils/history_workout.dart';
import 'package:intl/intl.dart';

const kHistoryWorkoutsAbridgedCount = 20;

typedef MonthYear = (int month, int year);

Map<MonthYear, List<Workout>> _getHistoryByMonthThread(List<Workout> raw) {
  final map = <MonthYear, List<Workout>>{};
  for (final workout in raw.reversed.take(kHistoryWorkoutsAbridgedCount)) {
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

  final searchTextController = TextEditingController();
  final searchFocusNode = FocusNode();

  bool isSearching = false;

  Set<String> selectedEntries = {};

  Map<MonthYear, List<Workout>> get searchResults {
    if (!isSearching) return {};
    final controller = Get.find<HistoryController>();
    final matching = controller.userVisibleWorkouts.where((workout) {
      return workout.name
          .toLowerCase()
          .contains(searchTextController.text.toLowerCase());
    }).toList();
    return _getHistoryByMonthThread(matching);
  }

  @override
  void initState() {
    super.initState();
    logger.d("Init state");
    _recompute();
    final controller = Get.find<HistoryController>();
    worker = ever(
      controller.history,
      (callback) {
        logger.i("History updated");
        _recompute();
      },
    );
  }

  _recompute() {
    final controller = Get.find<HistoryController>();
    try {
      historyByMonth = Future.value(_getHistoryByMonthThread(
        controller.userVisibleWorkouts,
      ));
      if (mounted) {
        setState(() {});
      }
    } catch (e, s) {
      logger.e("Error computing history", error: e, stackTrace: s);
    }
  }

  @override
  void dispose() {
    logger.d("Dispose state");
    worker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: historyByMonth,
        builder: (context, snapshot) {
          final history = isSearching ? searchResults : snapshot.data ?? {};

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

                        return SafeArea(
                          top: false,
                          bottom: false,
                          child: HistoryWorkout(
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
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
              if (!isSearching &&
                  Get.find<HistoryController>().userVisibleWorkouts.length >
                      kHistoryWorkoutsAbridgedCount)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  sliver: SliverToBoxAdapter(
                    child: ListTile(
                      title: Text("history.showAll".t),
                      trailing: const ListTileActionIcon(),
                      onTap: () {
                        Go.to(
                          () => const MeCalendarPage(),
                        );
                      },
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar() {
    final searchBar = PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight / 1.25 + 32),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SearchBar(
          hintText: "history.search".t,
          controller: searchTextController,
          focusNode: searchFocusNode,
          constraints: const BoxConstraints.tightFor(
            height: kToolbarHeight / 1.25,
          ),
          onChanged: (q) {
            setState(() {
              isSearching = q.isNotEmpty;
            });
          },
          trailing: [
            if (isSearching) ...[
              IconButton(
                icon: const Icon(GymTrackerIcons.clear),
                onPressed: () {
                  setState(() {
                    searchTextController.clear();
                    searchFocusNode.unfocus();
                    isSearching = false;
                  });
                },
              ),
            ]
          ],
        ),
      ),
    );
    if (selectedEntries.isEmpty) {
      return SliverAppBar.medium(
        title: Text("history.title".t),
        bottom: searchBar,
      );
    }

    return SliverAppBar.medium(
      backgroundColor: Theme.of(context).colorScheme.inverseSurface,
      foregroundColor: Theme.of(context).colorScheme.onInverseSurface,
      surfaceTintColor: Colors.transparent,
      title: Text(
        "general.selected".plural(selectedEntries.length),
      ),
      bottom: searchBar,
      leading: IconButton(
        icon: const Icon(GymTrackerIcons.close),
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
          icon: const Icon(GymTrackerIcons.delete),
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
      height: 32,
      color: state.isPinned
          ? elevatedAppBarColor
          : Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Text(
          DateFormat.yMMMM(context.locale.languageCode).format(
            DateTime(date.$2, date.$1),
          ),
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
