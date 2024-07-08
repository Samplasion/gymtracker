import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/utils/skeletons.dart';
import 'package:gymtracker/utils/theme.dart';
import 'package:gymtracker/view/exercises.dart';
import 'package:gymtracker/view/me/calendar.dart';
import 'package:gymtracker/view/skeleton.dart';
import 'package:gymtracker/view/utils/action_icon.dart';
import 'package:gymtracker/view/utils/history_workout.dart';
import 'package:gymtracker/view/utils/sliver_utils.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

const kHistoryWorkoutsAbridgedCount = 20;

typedef MonthYear = (int month, int year);

final List<Workout> fakeData = List.generate(7, (_) => skeletonWorkout());

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

  final searchController = SearchController();

  Set<String> selectedEntries = {};

  Map<MonthYear, List<Workout>> getSearchResults(String query) {
    if (query.isEmpty) return {};
    final controller = Get.find<HistoryController>();
    final matching = controller.userVisibleWorkouts.where((workout) {
      return workout.name.toLowerCase().contains(query.toLowerCase());
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

    searchController.dispose();
    worker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: historyByMonth,
        builder: (context, snapshot) {
          final isLoading = !snapshot.hasData;
          final history = isLoading
              ? _getHistoryByMonthThread(fakeData)
              : (snapshot.data ?? {});

          return CustomScrollView(
            physics: isLoading ? const NeverScrollableScrollPhysics() : null,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              _buildAppBar(isLoading),
              for (final date in history.keys) ...[
                SliverStickyHeader.builder(
                  builder: (context, state) =>
                      _buildHeader(state, date, isLoading, true),
                  sliver: SliverSkeletonizer(
                    enabled: isLoading,
                    child: SliverList(
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
                              if (selectedEntries
                                  .contains(thatDate[index].id)) {
                                selectedEntries.remove(thatDate[index].id);
                              } else {
                                selectedEntries.add(thatDate[index].id);
                              }
                            });
                          }

                          return _buildWorkout(thatDate[index], _toggle);
                        },
                      ),
                    ),
                  ),
                ),
              ],
              if (Get.find<HistoryController>().userVisibleWorkouts.length >
                  kHistoryWorkoutsAbridgedCount)
                SliverPadding(
                  padding: const EdgeInsets.only(top: 16),
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
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              const SliverBottomSafeArea(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWorkout(
    Workout workout,
    void Function() _toggle, {
    void Function()? onWillOpenView,
  }) {
    return SafeArea(
      top: false,
      bottom: false,
      child: HistoryWorkout(
        workout: workout,
        isSelected: selectedEntries.contains(workout.id),
        onTap: () {
          if (selectedEntries.isEmpty) {
            onWillOpenView?.call();
            Go.to(() => ExercisesView(workout: workout));
          } else {
            _toggle();
          }
        },
        onLongPress: () {
          _toggle();
        },
      ),
    );
  }

  Widget _buildAppBar(bool isLoading) {
    Widget widget;
    if (selectedEntries.isEmpty) {
      widget = SliverAppBar.large(
        title: Text("history.title".t),
        leading: const SkeletonDrawerButton(),
        actions: [
          SearchAnchor(
            builder: (context, sController) => IconButton(
              onPressed: () => sController.openView(),
              icon: const Icon(GymTrackerIcons.search),
            ),
            viewBuilder: (suggestions) {
              return CustomScrollView(
                slivers: suggestions.toList(),
              );
            },
            suggestionsBuilder: (context, sController) {
              final results = getSearchResults(sController.text);
              return [
                for (final date in results.keys) ...[
                  SliverStickyHeader.builder(
                    builder: (context, state) =>
                        _buildHeader(state, date, isLoading, false),
                    sliver: SliverSkeletonizer(
                      enabled: isLoading,
                      child: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          childCount: (results[date] ?? []).length,
                          (context, index) {
                            final thatDate = (results[date] ?? []);

                            return _buildWorkout(thatDate[index], () {},
                                onWillOpenView: () {
                              sController.closeView(null);
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 8)),
                  const SliverBottomSafeArea(),
                ],
              ];
            },
          ),
        ],
      );
    } else {
      widget = SliverAppBar.large(
        backgroundColor: Theme.of(context).colorScheme.inverseSurface,
        foregroundColor: Theme.of(context).colorScheme.onInverseSurface,
        surfaceTintColor: Colors.transparent,
        title: Text(
          "general.selected".plural(selectedEntries.length),
        ),
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

    var theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        appBarTheme: theme.appBarTheme.copyWith(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
        ),
      ),
      child: widget,
    );
  }

  Widget _buildHeader(
    SliverStickyHeaderState state,
    MonthYear date,
    bool isLoading,
    bool rounded,
  ) {
    final elevatedAppBarColor = ElevationOverlay.applySurfaceTint(
      Theme.of(context).colorScheme.surface,
      Theme.of(context).colorScheme.surfaceTint,
      3,
    );
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: state.isPinned
            ? elevatedAppBarColor
            : Theme.of(context).colorScheme.surface,
        borderRadius: rounded
            ? const BorderRadius.vertical(
                bottom: Radius.circular(kAppBarRadius),
              )
            : null,
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Skeletonizer(
          enabled: isLoading,
          child: Text(
            DateFormat.yMMMM(context.locale.languageCode).format(
              DateTime(date.$2, date.$1),
            ),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ),
    );
  }
}
