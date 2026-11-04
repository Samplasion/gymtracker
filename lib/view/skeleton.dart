import 'dart:async';
import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide Localizations;
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymtracker/controller/logger_controller.dart';
import 'package:gymtracker/controller/purchases_controller.dart';
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/controller/workout_controller.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/provider/bootstrap.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/service/protocol.dart';
import 'package:gymtracker/service/test.dart';
import 'package:gymtracker/service/version.dart';
import 'package:gymtracker/utils/constants.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/actions/purchases.dart';
import 'package:gymtracker/view/actions/workout.dart';
import 'package:gymtracker/view/components/error_view.dart';
import 'package:gymtracker/view/components/pro_builder.dart';
import 'package:gymtracker/view/debug.dart';
import 'package:gymtracker/view/feed.dart';
import 'package:gymtracker/view/food.dart';
import 'package:gymtracker/view/legal.dart';
import 'package:gymtracker/view/loading.dart';
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

// Allows capture/test hosts to present the same destinations as release builds.
final showDeveloperNavigationProvider = Provider<bool>((ref) => true);

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

class SkeletonView extends ConsumerStatefulWidget {
  const SkeletonView({this.child, this.sectionIndex = 0, super.key});
  final Widget? child;
  final int sectionIndex;

  @override
  ConsumerState<SkeletonView> createState() => _SkeletonViewState();

  static SkeletonViewState? of(BuildContext context) {
    return context.findAncestorStateOfType<_SkeletonViewState>();
  }

  static _SkeletonViewState? _of(BuildContext context) {
    return of(context) as _SkeletonViewState?;
  }

  static bool isTwoPane(BuildContext context) {
    return Breakpoints.computeBreakpoint(MediaQuery.sizeOf(context).width) >=
        Breakpoints.l;
  }
}

abstract class SkeletonViewState {
  void goToRoutines();
}

class _SkeletonViewState extends ConsumerState<SkeletonView>
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
    context.go('/routines');
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  int get _selectedIndex => widget.sectionIndex;

  List<Widget> get pages => [
    const FeedView(),
    const MeView(),
    const FoodView(),
    const RoutinesView(),
  ];

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    ref.read(routinesControllerProvider).didChangeAppLifecycleState(state);
    final online = ref.read(onlineProvider.notifier);
    if (online.isInit)
      online.syncManager.setForeground(state == AppLifecycleState.resumed);
  }

  @override
  Widget build(BuildContext context) {
    final safeArea = MediaQuery.of(context).padding;
    final subscriptionInfo = ref.watch(subscriptionInfoProvider).value;
    final showMDView = SkeletonView.isTwoPane(context);
    final leftNavigationSize = (showMDView
        ? (isSidebarCollapsed ? _kRailSize : _kDrawerSize - safeArea.left)
        : 0);
    return Scaffold(
      key: _scaffoldKey,
      body: Row(
        children: [
          Crossfade(
            firstChild: SizedBox(height: MediaQuery.sizeOf(context).height),
            secondChild: _drawer(true),
            showSecond: showMDView,
            alignment: Alignment.centerLeft,
            layoutBuilder:
                (topChild, topChildKey, bottomChild, bottomChildKey) {
                  return SizedBox(
                    height: MediaQuery.sizeOf(context).height,
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
                key: ValueKey<Object>(
                  widget.child == null ? _selectedIndex : 'shell-navigator',
                ),
                child: Builder(
                  builder: (context) => MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      padding: safeArea.copyWith(
                        bottom:
                            safeArea.bottom +
                            ((ref.watch(workoutControllerProvider) != null)
                                ? OngoingWorkoutBar.defaultHeight
                                : 0) +
                            (showMDView ? 0 : _kNavBarHeight),
                        left: showMDView ? 0 : safeArea.left,
                      ),
                      // TODO: Assess the utility of this
                      // viewInsets: MediaQuery.of(
                      //   context,
                      // ).viewInsets.copyWith(bottom: 0),
                    ),
                    child: widget.child ?? pages[_selectedIndex],
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
            Builder(
              builder: (context) {
                var hasWorkout = ref.watch(workoutControllerProvider) != null;
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    padding: safeArea.copyWith(
                      left: safeArea.left + leftNavigationSize,
                      bottom: showMDView ? safeArea.bottom : 0,
                    ),
                  ),
                  child: Crossfade(
                    firstChild: const SizedBox(),
                    secondChild: OngoingWorkoutBar(
                      open: () => SchedulerBinding.instance
                          .addPostFrameCallback((timeStamp) {
                            Go.toNamed(
                              getPreferredWorkoutRouteName(
                                simple: ref
                                    .read(settingsControllerProvider)
                                    .defaultToSimpleWorkoutView,
                              ),
                            );
                          }),
                    ),
                    showSecond: hasWorkout,
                  ),
                );
              },
            ),
            Crossfade(
              firstChild: Builder(
                builder: (context) {
                  final isSubscribed = subscriptionInfo?.hasProFeatures == true;
                  return NavigationBar(
                    onDestinationSelected: _onBottomDestinationTap,
                    selectedIndex: _selectedIndex,
                    height: _kNavBarHeight,
                    destinations: [
                      NavigationDestination(
                        icon: const Icon(GTIcons.home),
                        label: context.t.navigation.feed,
                      ),
                      NavigationDestination(
                        icon: const Icon(GTIcons.profile),
                        label: context.t.navigation.profile,
                      ),
                      NavigationDestination(
                        icon: const Icon(GTIcons.food),
                        label: context.t.navigation.food,
                      ),
                      NavigationDestination(
                        icon: const Icon(GTIcons.muscle),
                        label: context.t.navigation.workouts,
                      ),
                      if (!isSubscribed)
                        NavigationDestination(
                          icon: const Icon(GTIcons.pro),
                          label: context.t.navigation.pro,
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
    if (i == 4) {
      ref.read(purchasesControllerProvider).presentPaywall();
      return;
    }
    context.go(const ['/feed', '/profile', '/food', '/routines'][i]);
  }

  Widget _drawer(bool expanded) {
    return ProBuilder(
      builder: (context, info) {
        final safeArea = MediaQuery.of(context).padding;
        final isSubscribed = info != null && info.hasProFeatures;
        final showDeveloperNavigation = ref.watch(
          showDeveloperNavigationProvider,
        );
        final showDebug = showDeveloperNavigation && kDebugMode;
        final showLogs =
            showDeveloperNavigation && LoggerController.shouldShowPane;
        final offset = () {
          int offset = 1; // Settings
          if (showDebug) offset += 1;
          if (showLogs) offset += 1;
          return offset;
        }();
        final destinations = [
          NavigationDrawerDestination(
            icon: const Icon(GTIcons.home),
            label: Text(context.t.feed.title),
          ),
          NavigationDrawerDestination(
            icon: const Icon(GTIcons.profile),
            label: Text(context.t.me.title),
          ),
          NavigationDrawerDestination(
            icon: const Icon(GTIcons.food),
            label: Text(context.t.food.title),
          ),
          NavigationDrawerDestination(
            icon: const Icon(GTIcons.muscle),
            label: Text(context.t.workoutPage.title),
          ),
          if (!isSubscribed)
            NavigationDrawerDestination(
              icon: const Icon(GTIcons.pro),
              label: Text(context.t.pro.title),
            ),
          NavigationDrawerDestination(
            icon: const Icon(GTIcons.settings),
            label: Text(context.t.settings.title, textAlign: TextAlign.center),
          ),
          if (showDebug)
            const NavigationDrawerDestination(
              icon: Icon(GTIcons.debug),
              label: Text("Debug"),
            ),
          if (showLogs)
            const NavigationDrawerDestination(
              icon: Icon(GTIcons.logs),
              label: Text("Logs"),
            ),
        ];

        final railLabels = [
          context.t.navigation.feed,
          context.t.navigation.profile,
          context.t.navigation.food,
          context.t.navigation.workouts,
          if (!isSubscribed) context.t.navigation.pro,
          context.t.navigation.settings,
          if (showDebug) "Debug",
          if (showLogs) "Logs",
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
              constraints: BoxConstraints.tightFor(
                height: MediaQuery.sizeOf(context).height,
              ),
              child: Crossfade(
                firstChild: SizedBox(
                  height: MediaQuery.sizeOf(context).height,
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
                  height: MediaQuery.sizeOf(context).height,
                  child: ScrollableNavigationRail(
                    leading: const SkeletonDrawerButton(isInRail: true),
                    backgroundColor: Colors.transparent,
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: jumpOffTapHandler,
                    labelType: NavigationRailLabelType.all,
                    destinations: destinations
                        .whereType<NavigationDrawerDestination>()
                        .indexed
                        .map(
                          (entry) => NavigationRailDestination(
                            icon: entry.$2.icon,
                            label: Text(
                              railLabels[entry.$1],
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                showSecond: expanded && isSidebarCollapsed,
                layoutBuilder:
                    (topChild, topChildKey, bottomChild, bottomChildKey) {
                      return SizedBox(
                        height: MediaQuery.sizeOf(context).height,
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

class _GTDrawerFooter extends ConsumerStatefulWidget {
  const _GTDrawerFooter();

  @override
  ConsumerState<_GTDrawerFooter> createState() => __GTDrawerFooterState();
}

class __GTDrawerFooterState extends ConsumerState<_GTDrawerFooter> {
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
              text: context.t.appInfo.version(
                version: ref.watch(versionServiceProvider).packageInfo.version,
                build:
                    const String.fromEnvironment(
                      "BUILD",
                      defaultValue: "[NO_VALUE]",
                    ).replaceAll(
                      "[NO_VALUE]",
                      ref.watch(versionServiceProvider).packageInfo.buildNumber,
                    ),
              ),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const TextSpan(text: "\n"),
            TextSpan(
              text: context.t.appInfo.terms,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
              recognizer: _termsGestureDetector,
            ),
            const TextSpan(text: " • "),
            TextSpan(
              text: context.t.appInfo.privacy,
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
        context.t.appName,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        context.t.appInfo.shortDescription,
        style: Theme.of(
          context,
        ).textTheme.bodySmall!.copyWith(fontWeight: FontWeight.w400),
      ),
      leading: const Skeleton.leaf(child: InAppIcon.proportional(size: 38)),
    );
  }
}

class OngoingWorkoutBar extends ConsumerWidget {
  final VoidCallback open;

  const OngoingWorkoutBar({required this.open, super.key});

  static const defaultHeight = 64.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final isPhone =
            Breakpoints.computeBreakpoint(constraints.maxWidth) <=
            Breakpoints.xs;
        final safeArea = MediaQuery.of(context).padding;
        ref.watch(workoutControllerProvider);
        final controller = ref.read(workoutControllerProvider) != null
            ? ref.read(workoutControllerProvider.notifier)
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
                      child: InkWell(
                        onTap: open,
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 64),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Center(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: controller == null
                                      ? SizedBox.shrink()
                                      : Builder(
                                          builder: (context) => TimerView(
                                            startingTime: controller.time,
                                            builder: (_, time) => time,
                                          ),
                                        ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      if (isPhone)
                                        IconButton(
                                          onPressed: resumeWorkout,
                                          icon: const Icon(GTIcons.resume),
                                          tooltip: context
                                              .t
                                              .ongoingWorkout
                                              .actions
                                              .short
                                              .resume,
                                        )
                                      else
                                        Flexible(
                                          child: TextButton.icon(
                                            onPressed: resumeWorkout,
                                            icon: const Icon(GTIcons.resume),
                                            label: Text(
                                              context
                                                  .t
                                                  .ongoingWorkout
                                                  .actions
                                                  .short
                                                  .resume,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      const SizedBox(width: 8),
                                      if (isPhone)
                                        IconButton(
                                          onPressed: () =>
                                              cancelWorkout(context, ref),
                                          style: TextButton.styleFrom(
                                            foregroundColor:
                                                context.colorScheme.error,
                                          ),
                                          icon: const Icon(GTIcons.close),
                                          tooltip: context
                                              .t
                                              .ongoingWorkout
                                              .actions
                                              .short
                                              .cancel,
                                        )
                                      else
                                        Flexible(
                                          child: TextButton.icon(
                                            style: TextButton.styleFrom(
                                              foregroundColor:
                                                  context.colorScheme.error,
                                            ),
                                            onPressed: () =>
                                                cancelWorkout(context, ref),
                                            icon: Icon(
                                              GTIcons.close,
                                              color: context.colorScheme.error,
                                            ),
                                            label: Text(
                                              context
                                                  .t
                                                  .ongoingWorkout
                                                  .actions
                                                  .short
                                                  .cancel,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                    ],
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
          ),
        );
      },
    );
  }

  void resumeWorkout() {
    open();
  }

  void cancelWorkout(BuildContext context, WidgetRef ref) {
    ref
        .read(workoutControllerProvider.notifier)
        .cancelWorkoutWithDialog(context, onCanceled: () {});
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
class GymTrackerAppLoader extends ConsumerStatefulWidget {
  const GymTrackerAppLoader({super.key});

  @override
  ConsumerState<GymTrackerAppLoader> createState() => __LoaderState();
}

class __LoaderState extends ConsumerState<GymTrackerAppLoader> {
  Object? _error;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  void _initialize() {
    setState(() => _error = null);
    ref
        .read(appStartupProvider.future)
        .then(
          (_) {
            SchedulerBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              final onboarding = ref
                  .read(settingsControllerProvider)
                  .service
                  .prefs$
                  .value
                  .onboardingComplete;
              context.go(
                TestService().isTest || onboarding ? '/feed' : '/onboarding',
              );
              ref.read(protocolServiceProvider).markReady();
            });
          },
          onError: (Object error, StackTrace stack) {
            globalLogger.e(
              'Local initialization failed',
              error: error,
              stackTrace: stack,
            );
            if (mounted) setState(() => _error = error);
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        body: Center(
          child: ErrorViewComponent(
            title: context.t.error.title,
            error: null,
            retryCallback: _initialize,
          ),
        ),
      );
    }
    return LoadingPage();
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
