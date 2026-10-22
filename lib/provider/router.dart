import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gymtracker/struct/navigation_observer.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/error.dart';
import 'package:gymtracker/view/feed.dart';
import 'package:gymtracker/view/me.dart';
import 'package:gymtracker/view/onboarding.dart';
import 'package:gymtracker/view/paywall.dart';
import 'package:gymtracker/view/routines.dart';
import 'package:gymtracker/view/skeleton.dart';
import 'package:gymtracker/view/utils/workout_simple.dart';
import 'package:gymtracker/view/workout.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

CustomTransitionPage<void> _sectionPage(GoRouterState state, Widget child) =>
    CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          FadeThroughTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            child: child,
          ),
    );

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    navigatorKey: Go.navigatorKey,
    initialLocation: '/',
    observers: [LoggerNavigationObserver(), SentryNavigatorObserver()],
    routes: [
      GoRoute(path: '/', builder: (_, _) => const GymTrackerAppLoader()),
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
      ShellRoute(
        builder: (_, state, child) => SkeletonView(
          sectionIndex: switch (state.uri.path) {
            '/profile' => 1,
            '/routines' => 2,
            _ => 0,
          },
          child: child,
        ),
        routes: [
          GoRoute(
            path: '/feed',
            pageBuilder: (_, state) => _sectionPage(state, const FeedView()),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (_, state) => _sectionPage(state, const MeView()),
          ),
          GoRoute(
            path: '/routines',
            pageBuilder: (_, state) =>
                _sectionPage(state, const RoutinesView()),
          ),
        ],
      ),
      GoRoute(
        path: WorkoutView.routeName,
        name: WorkoutView.routeName,
        builder: (_, _) => const WorkoutView(),
      ),
      GoRoute(
        path: WorkoutSimpleView.routeName,
        name: WorkoutSimpleView.routeName,
        builder: (_, _) => const WorkoutSimpleView(),
      ),
      GoRoute(
        path: ErrorView.routeName,
        name: ErrorView.routeName,
        builder: (_, _) => const ErrorView(),
      ),
      GoRoute(
        path: PaywallScreen.routeName,
        name: PaywallScreen.routeName,
        builder: (_, _) => const PaywallScreen(),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
