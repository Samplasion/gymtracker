import 'package:animations/animations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Localizations;
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/coordinator.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/controller/logger_controller.dart';
import 'package:gymtracker/controller/notifications_controller.dart';
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/controller/workout_controller.dart';
import 'package:gymtracker/data/exercises.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/utils/constants.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/debug.dart';
import 'package:gymtracker/view/history.dart';
import 'package:gymtracker/view/library.dart';
import 'package:gymtracker/view/logs.dart';
import 'package:gymtracker/view/me.dart';
import 'package:gymtracker/view/routines.dart';
import 'package:gymtracker/view/settings.dart';
import 'package:gymtracker/view/utils/crossfade.dart';
import 'package:gymtracker/view/utils/timer.dart';
import 'package:gymtracker/view/workout.dart';

class SkeletonView extends StatefulWidget {
  const SkeletonView({super.key});

  @override
  State<SkeletonView> createState() => _SkeletonViewState();
}

class _SkeletonViewState extends State<SkeletonView>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      Get.find<NotificationController>().androidRequestExactAlarmsPermission();
    });

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  int _selectedIndex = 0;

  List<Widget> get pages => [
        const RoutinesView(),
        const LibraryView(),
        const HistoryView(),
        const MeView(),
        const SettingsView(),
        if (kDebugMode) const DebugView(),
        if (LoggerController.shouldShowPane) const LogView(),
      ];

  @override
  void reassemble() {
    super.reassemble();
    Get.find<Coordinator>().onHotReload();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    Get.find<RoutinesController>().didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageTransitionSwitcher(
        transitionBuilder: (
          Widget child,
          Animation<double> primaryAnimation,
          Animation<double> secondaryAnimation,
        ) {
          return FadeThroughTransition(
            animation: primaryAnimation,
            secondaryAnimation: secondaryAnimation,
            child: child,
          );
        },
        child: KeyedSubtree(
          key: ValueKey<int>(_selectedIndex),
          child: pages[_selectedIndex],
        ),
      ),
      bottomNavigationBar: Obx(
        () => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (Get.find<RoutinesController>().hasOngoingWorkout.isTrue)
              OngoingWorkoutBar(
                open: () =>
                    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                  Go.toNamed(WorkoutView.routeName);
                }),
              ),
            NavigationBarTheme(
              data: NavigationBarThemeData(
                labelTextStyle: WidgetStatePropertyAll(
                  Theme.of(context).textTheme.labelMedium!.copyWith(
                        overflow: TextOverflow.ellipsis,
                      ),
                ),
              ),
              child: NavigationBar(
                labelBehavior:
                    NavigationDestinationLabelBehavior.onlyShowSelected,
                destinations: [
                  NavigationDestination(
                    icon: const Icon(GymTrackerIcons.routines),
                    label: "routines.title".t,
                  ),
                  NavigationDestination(
                    icon: Badge(
                      label:
                          Text(exerciseStandardLibraryAsList.length.toString()),
                      isLabelVisible: _selectedIndex == 1 && kDebugMode,
                      child: const Icon(GymTrackerIcons.library),
                    ),
                    label: "library.title".t,
                  ),
                  NavigationDestination(
                    icon: Badge(
                      label: Text(
                          "${Get.find<HistoryController>().userVisibleLength}"),
                      isLabelVisible: _selectedIndex == 2,
                      child: const Icon(GymTrackerIcons.history),
                    ),
                    label: "history.title".t,
                  ),
                  NavigationDestination(
                    icon: const Icon(GymTrackerIcons.profile),
                    label: "me.title".t,
                  ),
                  NavigationDestination(
                    icon: const Icon(GymTrackerIcons.settings),
                    label: "settings.title".t,
                  ),
                  if (kDebugMode)
                    const NavigationDestination(
                      icon: Icon(GymTrackerIcons.debug),
                      label: "Debug",
                    ),
                  if (LoggerController.shouldShowPane)
                    const NavigationDestination(
                      icon: Icon(GymTrackerIcons.logs),
                      label: "Logs",
                    ),
                ],
                selectedIndex: _selectedIndex,
                onDestinationSelected: (i) =>
                    setState(() => _selectedIndex = i),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OngoingWorkoutBar extends StatelessWidget {
  final VoidCallback open;

  const OngoingWorkoutBar({required this.open, super.key});

  RoutinesController get controller => Get.put(RoutinesController());

  @override
  Widget build(BuildContext context) {
    final isPhone = context.width < Breakpoints.xs.screenWidth;
    return SafeArea(
      bottom: false,
      child: Card(
        elevation: 1,
        color: context.colorScheme.surfaceContainerHighest,
        margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(13),
        ),
        child: Container(
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Center(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Obx(
                    () => TimerView(
                      startingTime: Get.isRegistered<WorkoutController>()
                          ? Get.find<WorkoutController>().time.value
                          : DateTime.now(),
                      builder: (_, time) => time,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Crossfade(
                  firstChild: TextButton.icon(
                    onPressed: resumeWorkout,
                    icon: const Icon(GymTrackerIcons.resume),
                    clipBehavior: Clip.hardEdge,
                    label: Text(
                      "ongoingWorkout.actions.short.resume".t,
                      overflow: TextOverflow.clip,
                      maxLines: 1,
                    ),
                  ),
                  secondChild: IconButton(
                    onPressed: resumeWorkout,
                    icon: Icon(
                      GymTrackerIcons.resume,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  showSecond: isPhone,
                ),
                const SizedBox(width: 8),
                ClipRect(
                  clipBehavior: Clip.hardEdge,
                  child: Crossfade(
                    firstChild: TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                      ),
                      onPressed: () => cancelWorkout(context),
                      icon: const Icon(GymTrackerIcons.close),
                      clipBehavior: Clip.hardEdge,
                      label: Text(
                        "ongoingWorkout.actions.short.cancel".t,
                        overflow: TextOverflow.clip,
                        maxLines: 1,
                      ),
                    ),
                    secondChild: IconButton(
                      style: IconButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                      ),
                      onPressed: () => cancelWorkout(context),
                      icon: const Icon(GymTrackerIcons.close),
                    ),
                    showSecond: isPhone,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void resumeWorkout() {
    open();
  }

  void cancelWorkout(BuildContext context) {
    Get.find<WorkoutController>().cancelWorkoutWithDialog(
      context,
      onCanceled: () {},
    );
  }
}
