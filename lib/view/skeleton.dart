import 'package:animations/animations.dart';
import 'package:flutter/material.dart' hide Localizations;
import 'package:get/get.dart';
import 'package:gymtracker/controller/workouts_controller.dart';
import 'package:gymtracker/view/workout.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/mdi.dart';

import '../controller/workout_controller.dart';
import '../service/localizations.dart';
import '../utils/constants.dart';
import '../utils/go.dart';
import 'history.dart';
import 'library.dart';
import 'routines.dart';
import 'settings.dart';
import 'utils/crossfade.dart';
import 'utils/timer.dart';

class SkeletonView extends StatefulWidget {
  const SkeletonView({super.key});

  @override
  State<SkeletonView> createState() => _SkeletonViewState();
}

class _SkeletonViewState extends State<SkeletonView> {
  int _selectedIndex = 0;

  List<Widget> get pages => [
        const RoutinesView(),
        const LibraryView(),
        const HistoryView(),
        const SettingsView(),
      ];

  @override
  void reassemble() {
    super.reassemble();
    printInfo(info: "[#reassemble()] called");
    Get.find<GTLocalizations>().init();
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
            if (Get.find<WorkoutsController>().hasOngoingWorkout.isTrue)
              OngoingWorkoutBar(open: () => Go.to(() => const WorkoutView())),
            NavigationBar(
              labelBehavior:
                  NavigationDestinationLabelBehavior.onlyShowSelected,
              destinations: [
                NavigationDestination(
                  icon: Iconify(
                    Mdi.dumbbell,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  selectedIcon: Iconify(
                    Mdi.dumbbell,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                  label: "routines.title".tr,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.local_library_rounded),
                  label: "library.title".tr,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.history_rounded),
                  label: "history.title".tr,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.settings_rounded),
                  label: "settings.title".tr,
                ),
              ],
              selectedIndex: _selectedIndex,
              onDestinationSelected: (i) => setState(() => _selectedIndex = i),
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

  WorkoutsController get controller => Get.put(WorkoutsController());

  @override
  Widget build(BuildContext context) {
    final isPhone = context.width < Breakpoints.xs;
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(13),
        ),
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
                    startingTime: Get.find<WorkoutController>().time.value,
                    builder: (_, time) => Hero(
                      tag: "Ongoing",
                      child: time,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Crossfade(
                firstChild: TextButton.icon(
                  onPressed: resumeWorkout,
                  icon: const Icon(Icons.play_arrow_rounded),
                  clipBehavior: Clip.hardEdge,
                  label: Text(
                    "ongoingWorkout.actions.short.resume".tr,
                    overflow: TextOverflow.clip,
                    maxLines: 1,
                  ),
                ),
                secondChild: IconButton(
                  onPressed: resumeWorkout,
                  icon: Icon(
                    Icons.play_arrow_rounded,
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
                    onPressed: () => cancelWorkout(context),
                    icon: Icon(
                      Icons.close_rounded,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    clipBehavior: Clip.hardEdge,
                    label: Text(
                      "ongoingWorkout.actions.short.cancel".tr,
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.error),
                      overflow: TextOverflow.clip,
                      maxLines: 1,
                    ),
                  ),
                  secondChild: IconButton(
                    onPressed: () => cancelWorkout(context),
                    icon: Icon(
                      Icons.close_rounded,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  showSecond: isPhone,
                ),
              ),
            ],
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
