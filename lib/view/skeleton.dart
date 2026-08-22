import 'dart:async';
import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide Localizations;
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/coordinator.dart';
import 'package:gymtracker/controller/logger_controller.dart';
import 'package:gymtracker/controller/purchases_controller.dart';
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/controller/workout_controller.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/service/version.dart';
import 'package:gymtracker/utils/constants.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/components/pro_builder.dart';
import 'package:gymtracker/view/debug.dart';
import 'package:gymtracker/view/feed.dart';
import 'package:gymtracker/view/legal.dart';
import 'package:gymtracker/view/logs.dart';
import 'package:gymtracker/view/me.dart';
import 'package:gymtracker/view/routines.dart';
import 'package:gymtracker/view/settings.dart';
import 'package:gymtracker/view/utils/crossfade.dart';
import 'package:gymtracker/view/utils/in_app_icon.dart';
import 'package:gymtracker/view/utils/timer.dart';
import 'package:gymtracker/view/utils/workout_navigation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:skeletonizer/skeletonizer.dart';

const _kDrawerSize = 304.0;
const _kRailSize = 96.0;
const _kNavBarHeight = kNavBarHeight;

class SkeletonDrawerButton extends StatefulWidget {
  const SkeletonDrawerButton({super.key, this.isInRail = false});

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
        tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
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
        tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
      );
    } else {
      return IconButton(
        icon: const Icon(Icons.menu),
        tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
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

  static SkeletonViewState? of(BuildContext context) {
    return context.findAncestorStateOfType<_SkeletonViewState>();
  }

  static _SkeletonViewState? _of(BuildContext context) {
    return of(context) as _SkeletonViewState?;
  }

  static bool isTwoPane(BuildContext context) {
    return Breakpoints.computeBreakpoint(context.width) >= Breakpoints.l;
  }
}

abstract class SkeletonViewState {
  void goToRoutines();
}

class _SkeletonViewState extends State<SkeletonView>
    with WidgetsBindingObserver
    implements SkeletonViewState {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final BehaviorSubject<bool> _isSidebarCollapsed$ = BehaviorSubject.seeded(
    false,
  );

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
  void goToRoutines() {
    setState(() => _selectedIndex = 2);
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
    const FeedView(),
    const MeView(),
    const RoutinesView(),
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
                        Positioned(key: topChildKey, child: topChild),
                      ],
                    ),
                  );
                },
          ),
          Expanded(
            child: PageTransitionSwitcher(
              transitionBuilder:
                  (
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
                        bottom:
                            safeArea.bottom +
                            ((Get.find<RoutinesController>()
                                        .hasOngoingWorkout
                                        .isTrue ||
                                    Get.isRegistered<WorkoutController>())
                                ? (OngoingWorkoutBar.defaultHeight + 32)
                                : 0) +
                            (showMDView ? 0 : _kNavBarHeight),
                        left: showMDView ? 0 : safeArea.left,
                      ),
                      // TODO: Assess the utility of this
                      // viewInsets: MediaQuery.of(
                      //   context,
                      // ).viewInsets.copyWith(bottom: 0),
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
      bottomNavigationBar: () {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() {
              var hasWorkout =
                  Get.find<RoutinesController>().hasOngoingWorkout() ||
                  Get.isRegistered<WorkoutController>();
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  padding: safeArea.copyWith(
                    left: safeArea.left + leftNavigationSize,
                    bottom: 0,
                  ),
                ),
                child: Crossfade(
                  firstChild: const SizedBox(),
                  secondChild: OngoingWorkoutBar(
                    open: () => SchedulerBinding.instance.addPostFrameCallback((
                      timeStamp,
                    ) {
                      Go.toNamed(getPreferredWorkoutRouteName());
                    }),
                  ),
                  showSecond: hasWorkout,
                ),
              );
            }),
            Crossfade(
              firstChild: ProBuilder(
                builder: (context, subscriptionInfo) {
                  final isSubscribed = subscriptionInfo?.hasProFeatures == true;
                  return NavigationBar(
                    onDestinationSelected: _onBottomDestinationTap,
                    selectedIndex: _selectedIndex,
                    height: _kNavBarHeight,
                    destinations: [
                      NavigationDestination(
                        icon: const Icon(GTIcons.home),
                        label: "feed.title".t,
                      ),
                      NavigationDestination(
                        icon: const Icon(GTIcons.profile),
                        label: "me.title".t,
                      ),
                      NavigationDestination(
                        icon: const Icon(GTIcons.muscle),
                        label: "workoutPage.title".t,
                      ),
                      if (!isSubscribed)
                        NavigationDestination(
                          icon: const Icon(GTIcons.pro),
                          label: "pro.title".t,
                        ),
                    ],
                  );
                },
              ),
              secondChild: SizedBox.shrink(),
              showSecond: showMDView,
            ),
          ],
        );
      }(),
    );
  }

  void _onBottomDestinationTap(int i) {
    if (i == 3) {
      Get.find<PurchasesController>().presentPaywall();
      return;
    }
    setState(() => _selectedIndex = i);
  }

  Widget _drawer(bool expanded) {
    return ProBuilder(
      builder: (context, info) {
        final safeArea = MediaQuery.of(context).padding;
        final isSubscribed = info != null && info.hasProFeatures;
        final offset = () {
          int offset = 1; // Settings
          if (kDebugMode) offset += 1;
          if (LoggerController.shouldShowPane) offset += 1;
          return offset;
        }();
        final destinations = [
          NavigationDrawerDestination(
            icon: const Icon(GTIcons.home),
            label: Text("feed.title".t),
          ),
          NavigationDrawerDestination(
            icon: const Icon(GTIcons.profile),
            label: Text("me.title".t),
          ),
          NavigationDrawerDestination(
            icon: const Icon(GTIcons.muscle),
            label: Text("workoutPage.title".t),
          ),
          if (!isSubscribed)
            NavigationDrawerDestination(
              icon: const Icon(GTIcons.pro),
              label: Text("pro.title".t),
            ),
          NavigationDrawerDestination(
            icon: const Icon(GTIcons.settings),
            label: Text("settings.title".t, textAlign: TextAlign.center),
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
        ];

        void jumpOffTapHandler(int index) {
          if (expanded) {
            if (index < destinations.length - offset) {
              _scaffoldKey.currentState!.closeDrawer();
              _onBottomDestinationTap(index);
              return;
            } else {
              index -= destinations.length - offset;
            }
          }
          switch (index) {
            case 0:
              Go.to(() => SettingsView());
              break;
            case 1:
              Go.to(() => DebugView());
              break;
            case 2:
              Go.to(() => LogView());
              break;
          }
        }

        return _DrawerContainer(
          child: MediaQuery(
            data: MediaQueryData(
              padding: safeArea.copyWith(
                right: expanded ? 0 : safeArea.right,
                bottom: safeArea.bottom,
              ),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints.tightFor(height: context.height),
              child: Crossfade(
                firstChild: SizedBox(
                  height: context.height,
                  child: NavigationDrawer(
                    selectedIndex: expanded ? _selectedIndex : null,
                    onDestinationSelected: (i) {
                      if (!expanded) {
                        _scaffoldKey.currentState!.closeDrawer();
                      }
                      jumpOffTapHandler(i);
                    },
                    header: ColoredBox(
                      color: Theme.of(context).colorScheme.surfaceContainerLow,
                      child: Column(
                        children: [
                          const SafeArea(
                            bottom: false,
                            minimum: EdgeInsets.only(top: 16),
                            child: SizedBox(),
                          ),
                          const _GTDrawerHeader(),
                          const SizedBox(height: 16),
                          const Divider(thickness: 1, height: 1),
                        ],
                      ),
                    ),
                    footer: ColoredBox(
                      color: Theme.of(context).colorScheme.surfaceContainerLow,
                      child: SafeArea(child: const _GTDrawerFooter()),
                    ),
                    children: [
                      const SizedBox(height: 16),
                      if (expanded)
                        ...destinations
                      else
                        ...destinations.skip(destinations.length - offset),
                    ],
                  ),
                ),
                secondChild: SizedBox(
                  width: _kRailSize + safeArea.left,
                  height: context.height,
                  child: ScrollableNavigationRail(
                    leading: const SkeletonDrawerButton(isInRail: true),
                    backgroundColor: Colors.transparent,
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: jumpOffTapHandler,
                    labelType: NavigationRailLabelType.all,
                    destinations: destinations
                        .whereType<NavigationDrawerDestination>()
                        .map(
                          (d) => NavigationRailDestination(
                            icon: d.icon,
                            label: d.label,
                          ),
                        )
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
                            Positioned(key: topChildKey, child: topChild),
                          ],
                        ),
                      );
                    },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GTDrawerFooter extends StatefulWidget {
  const _GTDrawerFooter();

  @override
  State<_GTDrawerFooter> createState() => __GTDrawerFooterState();
}

class __GTDrawerFooterState extends State<_GTDrawerFooter> {
  final _termsGestureDetector = TapGestureRecognizer();
  final _privacyGestureDetector = TapGestureRecognizer();

  @override
  void initState() {
    super.initState();
    _termsGestureDetector.onTap = () {
      Go.to(() => TosViewerPage());
    };
    _privacyGestureDetector.onTap = () {
      Go.to(() => PrivacyViewerPage());
    };
  }

  @override
  void dispose() {
    _termsGestureDetector.dispose();
    _privacyGestureDetector.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Text.rich(
        textAlign: TextAlign.start,
        TextSpan(
          children: [
            TextSpan(
              text: "appInfo.version".tParams({
                "version": VersionService().packageInfo.version,
                "build":
                    const String.fromEnvironment(
                      "BUILD",
                      defaultValue: "[NO_VALUE]",
                    ).replaceAll(
                      "[NO_VALUE]",
                      VersionService().packageInfo.buildNumber,
                    ),
              }),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const TextSpan(text: "\n"),
            TextSpan(
              text: "appInfo.terms".t,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
              recognizer: _termsGestureDetector,
            ),
            const TextSpan(text: " • "),
            TextSpan(
              text: "appInfo.privacy".t,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
              recognizer: _privacyGestureDetector,
            ),
          ],
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
        style: Theme.of(
          context,
        ).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        "appInfo.shortDescription".t,
        style: Theme.of(
          context,
        ).textTheme.bodySmall!.copyWith(fontWeight: FontWeight.w400),
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
        final isPhone =
            Breakpoints.computeBreakpoint(constraints.maxWidth) <=
            Breakpoints.xs;
        final safeArea = MediaQuery.of(context).padding;
        final gradientColor = Theme.of(context).colorScheme.surfaceContainer;
        final controller = Get.isRegistered<WorkoutController>()
            ? Get.find<WorkoutController>()
            : null;
        return Container(
          alignment: Alignment.topCenter,
          // decoration: BoxDecoration(
          //   gradient: LinearGradient(
          //     colors: [gradientColor.withAlpha(0), gradientColor],
          //     begin: Alignment.topCenter,
          //     end: Alignment.bottomCenter,
          //     stops: [
          //       0,
          //       (defaultHeight / 2) / (1.5 * defaultHeight + safeArea.bottom),
          //     ],
          //   ),
          // ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCirc,
            padding: safeArea.copyWith(top: 0),
            child: SizedBox(
              height: defaultHeight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: BackdropFilter(
                    filterConfig: ImageFilterConfig.blur(
                      sigmaX: 16,
                      sigmaY: 16,
                    ),
                    child: Card(
                      elevation: 1,
                      color: context.colorScheme.surfaceContainerHighest
                          .withAlpha(128),
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                        side: BorderSide(
                          color: context.colorScheme.surfaceContainerHighest,
                        ),
                      ),
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 64),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Center(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: controller == null
                                    ? SizedBox.shrink()
                                    : Obx(
                                        () => TimerView(
                                          startingTime: controller.time.value,
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
                                        : "ongoingWorkout.actions.short.resume"
                                              .t,
                                    overflow: TextOverflow.clip,
                                    maxLines: 1,
                                  ),
                                ),
                                secondChild: IconButton(
                                  onPressed: resumeWorkout,
                                  icon: Icon(
                                    GTIcons.resume,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
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
                                      foregroundColor: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                      iconColor: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                    ),
                                    onPressed: () => cancelWorkout(context),
                                    icon: const Icon(GTIcons.close),
                                    clipBehavior: Clip.hardEdge,
                                    label: Text(
                                      isPhone
                                          ? ""
                                          : "ongoingWorkout.actions.short.cancel"
                                                .t,
                                      overflow: TextOverflow.clip,
                                      maxLines: 1,
                                    ),
                                  ),
                                  secondChild: IconButton(
                                    style: IconButton.styleFrom(
                                      foregroundColor: Theme.of(
                                        context,
                                      ).colorScheme.error,
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
            const Expanded(child: FeedView.skeleton()),
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
