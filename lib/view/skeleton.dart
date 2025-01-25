import 'dart:async';

import 'package:animations/animations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Localizations;
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/coordinator.dart';
import 'package:gymtracker/controller/exercises_controller.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/controller/logger_controller.dart';
import 'package:gymtracker/controller/notifications_controller.dart';
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/controller/workout_controller.dart';
import 'package:gymtracker/data/exercises.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/utils/colors.dart';
import 'package:gymtracker/utils/constants.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/achievements.dart';
import 'package:gymtracker/view/boutique.dart';
import 'package:gymtracker/view/components/badges.dart';
import 'package:gymtracker/view/debug.dart';
import 'package:gymtracker/view/food.dart';
import 'package:gymtracker/view/history.dart';
import 'package:gymtracker/view/library.dart';
import 'package:gymtracker/view/logs.dart';
import 'package:gymtracker/view/me.dart';
import 'package:gymtracker/view/routines.dart';
import 'package:gymtracker/view/settings.dart';
import 'package:gymtracker/view/utils/crossfade.dart';
import 'package:gymtracker/view/utils/in_app_icon.dart';
import 'package:gymtracker/view/utils/timer.dart';
import 'package:gymtracker/view/workout.dart';
import 'package:rxdart/rxdart.dart';
import 'package:skeletonizer/skeletonizer.dart';

const _kDrawerSize = 304.0;
const _kRailSize = 80.0;

class SkeletonDrawerButton extends StatefulWidget {
  const SkeletonDrawerButton({
    super.key,
    this.isInRail = false,
  });

  final bool isInRail;

  @override
  State<SkeletonDrawerButton> createState() => _SkeletonDrawerButtonState();
}

class _SkeletonDrawerButtonState extends State<SkeletonDrawerButton>
    with LoggerConfigurationMixin {
  @override
  int get loggerMethodCount => 0;

  _SkeletonViewState? _skeleton;
  StreamSubscription<bool>? _skeletonSub;

  _onStateChange(_) {
    logger.t("SkeletonDrawerButton: _onStateChange");
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    // SkeletonView._of(context)?.addListener(_onStateChange);
    _skeleton = SkeletonView._of(context);
    _skeletonSub = _skeleton?.isSidebarCollapsedStream.listen(_onStateChange);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _skeletonSub?.cancel();
    _skeleton = SkeletonView._of(context);
    _skeletonSub = _skeleton?.isSidebarCollapsedStream.listen(_onStateChange);
  }

  @override
  void dispose() {
    _skeletonSub?.cancel();
    _skeleton = null;
    _skeletonSub = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final skeleton = SkeletonView._of(context);
    void _toggleSidebar() {
      setState(() => skeleton?.toggleSidebar());
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    }

    const sidebarIcon = Icons.menu;

    if (widget.isInRail) {
      return IconButton(
        icon: const Icon(sidebarIcon),
        onPressed: _toggleSidebar,
      );
    } else if (SkeletonView.isTwoPane(context)) {
      var hide = _skeleton?.isSidebarCollapsed == true;
      final iconSize = IconTheme.of(context).size ?? kDefaultFontSize;
      return IconButton(
        icon: Crossfade(
          firstChild: const Icon(sidebarIcon),
          secondChild: SizedBox(width: iconSize, height: iconSize),
          showSecond: hide,
          alignment: Alignment.center,
        ),
        onPressed: hide ? null : _toggleSidebar,
      );
    } else {
      return IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () {
          setState(() => SkeletonView._of(context)?.openDrawer());
          SchedulerBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() {});
          });
        },
      );
    }
  }
}

class SkeletonView extends StatefulWidget {
  const SkeletonView({super.key});

  @override
  State<SkeletonView> createState() => _SkeletonViewState();

  static _SkeletonViewState? _of(BuildContext context) {
    return context.findAncestorStateOfType<_SkeletonViewState>();
  }

  static bool isTwoPane(BuildContext context) {
    return Breakpoints.computeBreakpoint(context.width) >= Breakpoints.l;
  }
}

class _SkeletonViewState extends State<SkeletonView>
    with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final BehaviorSubject<bool> _isSidebarCollapsed$ =
      BehaviorSubject.seeded(false);

  bool get isSidebarCollapsed => _isSidebarCollapsed$.value;
  Stream<bool> get isSidebarCollapsedStream => _isSidebarCollapsed$.stream;

  openDrawer() {
    _scaffoldKey.currentState!.openDrawer();
  }

  toggleSidebar() {
    _isSidebarCollapsed$.add(!isSidebarCollapsed);
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();

    // SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
    //   Get.find<NotificationController>().androidRequestExactAlarmsPermission();
    // });

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
        const BoutiqueView(),
        const MeView(),
        const FoodView(),
        const AchievementsView(),
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
    final safeArea = MediaQuery.of(context).padding;
    final showMDView = SkeletonView.isTwoPane(context);
    final leftNavigationSize = (showMDView
        ? (isSidebarCollapsed ? _kRailSize : _kDrawerSize - safeArea.left)
        : 0);
    return Scaffold(
      key: _scaffoldKey,
      body: Row(
        children: [
          Crossfade(
            firstChild: SizedBox(height: context.height),
            secondChild: _drawer(true),
            showSecond: showMDView,
            alignment: Alignment.centerLeft,
            layoutBuilder:
                (topChild, topChildKey, bottomChild, bottomChildKey) {
              return SizedBox(
                height: context.height,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: AlignmentDirectional.centerStart,
                  children: <Widget>[
                    Positioned(
                      key: bottomChildKey,
                      // Instead of forcing the positioned child to a width
                      // with left / right, just stick it to the top.
                      top: 0,
                      child: bottomChild,
                    ),
                    Positioned(
                      key: topChildKey,
                      child: topChild,
                    ),
                  ],
                ),
              );
            },
          ),
          Expanded(
            child: PageTransitionSwitcher(
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
                child: Obx(
                  () => MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      padding: safeArea.copyWith(
                        bottom: safeArea.bottom +
                            (Get.find<RoutinesController>()
                                    .hasOngoingWorkout
                                    .isTrue
                                ? OngoingWorkoutBar.defaultHeight
                                : 0),
                        left: showMDView ? 0 : safeArea.left,
                      ),
                      // TODO: Assess the utility of this
                      viewInsets: MediaQuery.of(context).viewInsets.copyWith(
                            bottom: 0,
                          ),
                    ),
                    child: pages[_selectedIndex],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: showMDView ? null : _drawer(false),
      extendBody: true,
      bottomNavigationBar: Obx(
        () {
          var hasWorkout =
              Get.find<RoutinesController>().hasOngoingWorkout.isTrue;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasWorkout)
                MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    padding: safeArea.copyWith(
                      left: safeArea.left + leftNavigationSize,
                    ),
                  ),
                  child: OngoingWorkoutBar(
                    open: () => SchedulerBinding.instance
                        .addPostFrameCallback((timeStamp) {
                      Go.toNamed(WorkoutView.routeName);
                    }),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _drawer(bool expanded) {
    final safeArea = MediaQuery.of(context).padding;
    final destinations = [
      const SafeArea(
        bottom: false,
        minimum: EdgeInsets.only(top: 16),
        child: SizedBox(),
      ),
      const _GTDrawerHeader(),
      const SizedBox(height: 16),
      NavigationDrawerDestination(
        icon: const Icon(GTIcons.routines),
        label: Text(
          "routines.title".t,
          textAlign: TextAlign.center,
        ),
      ),
      NavigationDrawerDestination(
        icon: const Icon(GTIcons.library),
        label: Text.rich(
          TextSpan(
            children: [
              TextSpan(text: "library.title".t),
              if (_selectedIndex == 1 && kDebugMode) ...[
                const TextSpan(text: " "),
                WidgetSpan(
                  child: GTBadge(
                    content:
                        "${exerciseStandardLibraryAsList.length} + ${Get.find<ExercisesController>().exercises.length}",
                    color: GTMaterialColor.quinary,
                    size: GTBadgeSize.small,
                    invert: true,
                  ),
                  alignment: PlaceholderAlignment.middle,
                ),
              ],
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
      NavigationDrawerDestination(
        icon: const Icon(GTIcons.history),
        label: Text.rich(
          TextSpan(
            children: [
              TextSpan(text: "history.title".t),
              if (_selectedIndex == 2) ...[
                const TextSpan(text: " "),
                WidgetSpan(
                  child: GTBadge(
                    content:
                        "${Get.find<HistoryController>().userVisibleLength}",
                    color: GTMaterialColor.quinary,
                    size: GTBadgeSize.small,
                    invert: true,
                  ),
                  alignment: PlaceholderAlignment.middle,
                ),
              ],
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
      NavigationDrawerDestination(
        icon: const Icon(GTIcons.boutique),
        label: Text(
          "boutique.title".t,
          textAlign: TextAlign.center,
        ),
      ),
      NavigationDrawerDestination(
        icon: const Icon(GTIcons.profile),
        label: Text(
          "me.title".t,
          textAlign: TextAlign.center,
        ),
      ),
      NavigationDrawerDestination(
        icon: const Icon(GTIcons.food),
        label: Text(
          "food.title".t,
          textAlign: TextAlign.center,
        ),
      ),
      NavigationDrawerDestination(
        icon: const Icon(GTIcons.achievements),
        label: Text(
          "achievements.title".t,
          textAlign: TextAlign.center,
        ),
      ),
      NavigationDrawerDestination(
        icon: const Icon(GTIcons.settings),
        label: Text(
          "settings.title".t,
          textAlign: TextAlign.center,
        ),
      ),
      if (kDebugMode)
        const NavigationDrawerDestination(
          icon: Icon(GTIcons.debug),
          label: Text("Debug"),
        ),
      if (LoggerController.shouldShowPane)
        const NavigationDrawerDestination(
          icon: Icon(GTIcons.logs),
          label: Text("Logs"),
        ),
      const SafeArea(
        top: false,
        minimum: EdgeInsets.only(bottom: 16),
        child: SizedBox(),
      ),
    ];
    return _DrawerContainer(
      child: MediaQuery(
        data: MediaQueryData(
          padding: safeArea.copyWith(
            right: expanded ? 0 : safeArea.right,
            bottom: safeArea.bottom +
                (Get.find<RoutinesController>().hasOngoingWorkout.isTrue
                    ? OngoingWorkoutBar.defaultHeight
                    : 0),
          ),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints.tightFor(height: context.height),
          child: Crossfade(
            firstChild: SizedBox(
              height: context.height,
              child: NavigationDrawer(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (i) {
                  if (!expanded) {
                    _scaffoldKey.currentState!.closeDrawer();
                  }
                  setState(() => _selectedIndex = i);
                },
                children: destinations,
              ),
            ),
            secondChild: SizedBox(
              width: _kRailSize + safeArea.left,
              height: context.height,
              child: ScrollableNavigationRail(
                leading: const SkeletonDrawerButton(isInRail: true),
                backgroundColor: Colors.transparent,
                selectedIndex: _selectedIndex,
                onDestinationSelected: (i) {
                  setState(() => _selectedIndex = i);
                },
                labelType: NavigationRailLabelType.all,
                destinations: destinations
                    .whereType<NavigationDrawerDestination>()
                    .map((d) => NavigationRailDestination(
                          icon: d.icon,
                          label: d.label,
                        ))
                    .toList(),
              ),
            ),
            showSecond: expanded && isSidebarCollapsed,
            layoutBuilder:
                (topChild, topChildKey, bottomChild, bottomChildKey) {
              return SizedBox(
                height: context.height,
                child: Stack(
                  clipBehavior: Clip.none,
                  // alignment: AlignmentDirectional.centerStart,
                  alignment: Alignment.center,
                  children: <Widget>[
                    Positioned(
                      key: bottomChildKey,
                      // Instead of forcing the positioned child to a width
                      // with left / right, just stick it to the top.
                      top: 0,
                      child: bottomChild,
                    ),
                    Positioned(
                      key: topChildKey,
                      child: topChild,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _GTDrawerHeader extends StatelessWidget {
  const _GTDrawerHeader();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        "appName".t,
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
      leading: const Skeleton.leaf(child: InAppIcon.proportional(size: 38)),
    );
  }
}

class OngoingWorkoutBar extends StatelessWidget {
  final VoidCallback open;

  const OngoingWorkoutBar({required this.open, super.key});

  RoutinesController get controller => Get.find<RoutinesController>();

  static const defaultHeight = 64.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final isPhone = Breakpoints.computeBreakpoint(constraints.maxWidth) <=
            Breakpoints.xs;
        final safeArea = MediaQuery.of(context).padding;
        final gradientColor = Theme.of(context).colorScheme.surfaceContainerLow;
        return Container(
          alignment: Alignment.topCenter,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                gradientColor.withAlpha(0),
                gradientColor,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [
                0,
                (defaultHeight / 2) / (1.5 * defaultHeight + safeArea.bottom),
              ],
            ),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCirc,
            padding: safeArea.copyWith(top: 0),
            child: SizedBox(
              height: defaultHeight,
              child: Card(
                elevation: 1,
                color: context.colorScheme.surfaceContainerHighest,
                margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 64),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Center(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Obx(
                            () => TimerView(
                              startingTime:
                                  Get.isRegistered<WorkoutController>()
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
                            icon: const Icon(GTIcons.resume),
                            clipBehavior: Clip.hardEdge,
                            label: Text(
                              isPhone
                                  ? ""
                                  : "ongoingWorkout.actions.short.resume".t,
                              overflow: TextOverflow.clip,
                              maxLines: 1,
                            ),
                          ),
                          secondChild: IconButton(
                            onPressed: resumeWorkout,
                            icon: Icon(
                              GTIcons.resume,
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
                                foregroundColor:
                                    Theme.of(context).colorScheme.error,
                                iconColor: Theme.of(context).colorScheme.error,
                              ),
                              onPressed: () => cancelWorkout(context),
                              icon: const Icon(GTIcons.close),
                              clipBehavior: Clip.hardEdge,
                              label: Text(
                                isPhone
                                    ? ""
                                    : "ongoingWorkout.actions.short.cancel".t,
                                overflow: TextOverflow.clip,
                                maxLines: 1,
                              ),
                            ),
                            secondChild: IconButton(
                              style: IconButton.styleFrom(
                                foregroundColor:
                                    Theme.of(context).colorScheme.error,
                              ),
                              onPressed: () => cancelWorkout(context),
                              icon: const Icon(GTIcons.close),
                            ),
                            showSecond: isPhone,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
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

class _DrawerContainer extends StatelessWidget {
  final Widget child;

  const _DrawerContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    final expanded = SkeletonView.isTwoPane(context);
    return Container(
      constraints: BoxConstraints(
        maxWidth: expanded ? _kDrawerSize : double.infinity,
      ),
      decoration: expanded
          ? BoxDecoration(
              color: context.colorScheme.surfaceContainerLow,
              borderRadius: const BorderRadiusDirectional.only(
                bottomEnd: Radius.circular(16),
              ),
            )
          : null,
      child: child,
    );
  }
}

/// A widget that launches the actual root widget.
///
/// Used to force the root widget to be an
/// animated route, so that exit animations work.
class GymTrackerAppLoader extends StatefulWidget {
  const GymTrackerAppLoader({super.key});

  @override
  State<GymTrackerAppLoader> createState() => __LoaderState();
}

class __LoaderState extends State<GymTrackerAppLoader> {
  @override
  void initState() {
    super.initState();
    Get.find<Coordinator>().awaitInitialized().then((_) {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        Get.find<Coordinator>().bootProcedure();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final showMDView = SkeletonView.isTwoPane(context);
    return Skeletonizer(
      child: Scaffold(
        body: Row(
          children: [
            if (showMDView) ...[
              _DrawerContainer(
                child: NavigationDrawer(
                  // backgroundColor: Colors.transparent,
                  indicatorColor: Colors.transparent,
                  children: [
                    const SafeArea(
                      bottom: false,
                      minimum: EdgeInsets.only(top: 16),
                      child: SizedBox(),
                    ),
                    const _GTDrawerHeader(),
                    const SizedBox(height: 16),
                    for (var i = 0; i < 6; i++)
                      NavigationDrawerDestination(
                        icon: const Icon(GTIcons.app_icon),
                        label: Text(BoneMock.words(i % 3 + 1)),
                        backgroundColor: Colors.transparent,
                      ),
                  ],
                ),
              ),
            ],
            const Expanded(
              child: RoutinesView.skeleton(),
            ),
          ],
        ),
      ),
    );
  }
}

class ScrollableNavigationRail extends StatelessWidget {
  final Widget? leading;
  final Color? backgroundColor;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final NavigationRailLabelType labelType;
  final List<NavigationRailDestination> destinations;

  const ScrollableNavigationRail({
    this.leading,
    this.backgroundColor,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.labelType,
    required this.destinations,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: NavigationRail(
                leading: leading,
                backgroundColor: backgroundColor,
                selectedIndex: selectedIndex,
                onDestinationSelected: onDestinationSelected,
                labelType: labelType,
                destinations: destinations,
              ),
            ),
          ),
        );
      },
    );
  }
}
