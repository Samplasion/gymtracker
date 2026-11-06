import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/controller/workout_controller.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/trainer.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/provider/connectivity.dart';
import 'package:gymtracker/provider/feed.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/provider/trainer.dart';
import 'package:gymtracker/provider/training_data.dart';
import 'package:gymtracker/service/feed.dart';
import 'package:gymtracker/service/online.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/utils/theme.dart';
import 'package:gymtracker/view/components/suggested_routines_carousel.dart';
import 'package:gymtracker/view/feed.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers.dart';
import '../test_helpers/mock_services.dart';
import '../test_helpers/widget_test_app.dart';

class _Feed extends Feed {
  _Feed([this.items = const []]);
  final List<FeedItem> items;
  final visibility = <bool>[];
  int refreshes = 0;

  @override
  Future<List<FeedItem>> build() async => items;
  @override
  bool get hasMore => false;
  @override
  void setVisible(bool value) => visibility.add(value);
  @override
  Future<void> refreshIfStale() async => refreshes++;
  @override
  Future<void> refresh() async => refreshes++;

  void replaceItems(List<FeedItem> items) => state = AsyncData(items);
}

class _Online extends Online {
  @override
  OnlineAccount? build() => null;
}

class _Connectivity extends NetworkConnectivityNotifier {
  @override
  Stream<bool> build() => Stream.value(false);
}

class _FailingFeed extends _Feed {
  @override
  Future<List<FeedItem>> build() async =>
      throw StateError('technical feed error');

  @override
  Future<void> refresh() async {
    refreshes++;
    state = const AsyncData([]);
  }
}

class _FailingOnline extends Online {
  int retries = 0;
  @override
  Future<OnlineAccount?> build() async =>
      throw StateError('technical account error');
  @override
  Future<void> retryAccount() async {
    retries++;
    state = const AsyncData(null);
  }
}

final _suggestionsProvider =
    NotifierProvider<_Suggestions, List<RoutineSuggestion>>(_Suggestions.new);

class _Suggestions extends Notifier<List<RoutineSuggestion>> {
  @override
  List<RoutineSuggestion> build() => [];
  void replace(List<RoutineSuggestion> values) => state = values;
}

void main() {
  setUp(() async {
    MockServices.setup();
    await initTestLocalizations();
    when(
      () => MockServices.routinesController.suggestions,
    ).thenReturn(<RoutineSuggestion>[]);
  });
  tearDown(MockServices.tearDown);

  testWidgets(
    'suggestions update reactively and replace the workout chooser with the carousel',
    (tester) async {
      final container = ProviderContainer(
        overrides: [
          ...MockServices.defaultOverrides,
          feedProvider.overrideWith(_Feed.new),
          onlineProvider.overrideWith(_Online.new),
          networkConnectivityProvider.overrideWith(_Connectivity.new),
          routineSuggestionsProvider.overrideWith(
            (ref) => ref.watch(_suggestionsProvider),
          ),
          trainerStateProvider.overrideWith(
            (ref) => Stream.value(
              const TrainerState(
                controls: {'push'},
                link: {'trainer_name': 'Alex Morgan'},
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const WidgetTestApp(child: FeedView()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Choose a workout'), findsOneWidget);
      final routines = [
        for (final name in ['push', 'pull', 'legs', 'extra'])
          Workout(id: name, name: name, exercises: []),
      ];
      container.read(_suggestionsProvider.notifier).replace([
        for (final routine in routines) (routine: routine, score: 1),
      ]);
      await tester.pumpAndSettle();
      expect(find.byType(SuggestedRoutinesCarousel), findsOneWidget);
      expect(find.text('Choose a workout'), findsNothing);
      expect(find.text('Assigned by Alex Morgan'), findsOneWidget);
      expect(
        tester
            .widget<SuggestedRoutinesCarousel>(
              find.byType(SuggestedRoutinesCarousel),
            )
            .routines,
        routines.take(3).toList(),
      );
      container.read(_suggestionsProvider.notifier).replace([
        (routine: routines[1], score: 1),
      ]);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('suggested-routine-push')),
        findsNothing,
      );
      container.read(_suggestionsProvider.notifier).replace([]);
      await tester.pumpAndSettle();
      expect(find.byType(SuggestedRoutinesCarousel), findsNothing);
      expect(find.text('Choose a workout'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  for (final ongoing in [false, true]) {
    testWidgets(
      'carousel starts the selected routine and protects an ongoing workout ($ongoing)',
      (tester) async {
        when(
          () => MockServices.settingsController.defaultToSimpleWorkoutView,
        ).thenReturn(true);
        final routine = Workout(
          id: 'push',
          name: 'Push · Strength',
          exercises: [exerciseHelper('bench', 'Bench press')],
        );
        final container = ProviderContainer(
          overrides: [
            ...MockServices.defaultOverrides.where(
              (override) => override.origin != routinesControllerProvider,
            ),
            routinesControllerProvider.overrideWith(
              (ref) => RoutinesController(ref),
            ),
            feedProvider.overrideWith(_Feed.new),
            onlineProvider.overrideWith(_Online.new),
            networkConnectivityProvider.overrideWith(_Connectivity.new),
            routineSuggestionsProvider.overrideWith(
              (ref) => [(routine: routine, score: 1)],
            ),
            trainerStateProvider.overrideWith(
              (ref) => Stream.value(TrainerState.empty),
            ),
          ],
        );
        addTearDown(container.dispose);
        final controller = container.read(workoutControllerProvider.notifier);
        if (ongoing) {
          controller.start('In progress', null, null, saveInitial: false);
        }
        final router = GoRouter(
          navigatorKey: Go.navigatorKey,
          initialLocation: '/feed',
          routes: [
            GoRoute(path: '/feed', builder: (_, _) => const FeedView()),
            GoRoute(
              path: '/workout/simple',
              builder: (_, _) => const Scaffold(body: Text('Workout started')),
            ),
          ],
        );
        addTearDown(router.dispose);
        final theme = ThemeData(useMaterial3: true);
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: TranslationProvider(
              child: MaterialApp.router(
                routerConfig: router,
                theme: theme.copyWith(
                  extensions: [MoreColors.fromColorScheme(theme.colorScheme)],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(const ValueKey('start-suggested-routine-push')),
        );
        await tester.pumpAndSettle();
        if (ongoing) {
          expect(find.byType(AlertDialog), findsOneWidget);
          final context = tester.element(find.byType(AlertDialog));
          await tester.tap(
            find.widgetWithText(
              TextButton,
              context.t.ongoingWorkout.overwrite.actions.no,
            ),
          );
          await tester.pumpAndSettle();
          expect(controller.name, 'In progress');
          expect(controller.parentID, isNull);
          expect(router.routeInformationProvider.value.uri.path, '/feed');
        } else {
          await tester.pump(const Duration(milliseconds: 150));
          expect(find.text('Workout started'), findsOneWidget);
          expect(controller.parentID, routine.id);
          expect((controller.exercises.single as Exercise).name, 'Bench press');
        }
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }

  testWidgets('feed errors are localized and retry reloads activities', (
    tester,
  ) async {
    final feed = _FailingFeed();
    final container = ProviderContainer(
      overrides: [
        ...MockServices.defaultOverrides,
        feedProvider.overrideWith(() => feed),
        onlineProvider.overrideWith(_Online.new),
        networkConnectivityProvider.overrideWith(_Connectivity.new),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const WidgetTestApp(child: FeedView()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Choose a workout'), findsOneWidget);
    expect(find.text('Unable to load activities'), findsOneWidget);
    expect(find.textContaining('technical'), findsNothing);
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(feed.refreshes, greaterThan(0));
    expect(find.text('Unable to load activities'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('account error retries without rebuilding the online service', (
    tester,
  ) async {
    final online = _FailingOnline();
    final container = ProviderContainer(
      overrides: [
        ...MockServices.defaultOverrides,
        feedProvider.overrideWith(_Feed.new),
        onlineProvider.overrideWith(() => online),
        networkConnectivityProvider.overrideWith(_Connectivity.new),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const WidgetTestApp(child: FeedView()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Unable to load profile'));
    await tester.pumpAndSettle();
    expect(find.text('Unable to load profile'), findsOneWidget);
    expect(find.textContaining('technical'), findsNothing);
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(online.retries, 1);
    expect(find.byType(AlertDialog), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  for (final platform in [TargetPlatform.iOS, TargetPlatform.android]) {
    testWidgets(
      'feed handles flings, shrinking content and refresh on $platform',
      (tester) async {
        final feed = _Feed(
          List.generate(
            20,
            (index) => FeedItemWorkout(
              workout: Workout(
                id: 'workout-$index',
                name: 'Workout $index',
                exercises: [],
                duration: const Duration(minutes: 30),
                startingDate: DateTime(2026, 10, 20),
              ),
              authorship: FeedAuthorshipOwn(),
            ),
          ),
        );
        final container = ProviderContainer(
          overrides: [
            ...MockServices.defaultOverrides,
            feedProvider.overrideWith(() => feed),
            onlineProvider.overrideWith(_Online.new),
            networkConnectivityProvider.overrideWith(_Connectivity.new),
          ],
        );
        addTearDown(container.dispose);
        final shown = ValueNotifier(true);
        addTearDown(shown.dispose);
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: WidgetTestApp(
              child: ValueListenableBuilder(
                valueListenable: shown,
                builder: (_, visible, _) =>
                    visible ? const FeedView() : const SizedBox.shrink(),
              ),
            ),
          ),
        );
        await tester.pump();
        final scroll = find.byKey(const PageStorageKey('feed-scroll'));
        ScrollPosition position() => tester
            .state<ScrollableState>(
              find
                  .descendant(of: scroll, matching: find.byType(Scrollable))
                  .first,
            )
            .position;

        await tester.fling(scroll, const Offset(0, -900), 2500);
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();
        expect(position().pixels, greaterThan(0));
        final offset = position().pixels;
        shown.value = false;
        await tester.pump();
        shown.value = true;
        await tester.pump();
        await tester.pump();
        expect(position().pixels, closeTo(offset, 1));

        await tester.fling(scroll, const Offset(0, 700), 2500);
        await tester.pump(const Duration(milliseconds: 16));
        feed.replaceItems([]);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        position().jumpTo(0);
        await tester.pumpAndSettle();
        final refreshes = feed.refreshes;
        await tester.drag(scroll, const Offset(0, 500));
        await tester.pumpAndSettle();
        expect(feed.refreshes, greaterThan(refreshes));
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
      variant: TargetPlatformVariant({platform}),
    );
  }

  testWidgets(
    'feed unmount releases visibility and cancels refresh callbacks',
    (tester) async {
      final feed = _Feed();
      final container = ProviderContainer(
        overrides: [
          ...MockServices.defaultOverrides,
          feedProvider.overrideWith(() => feed),
          onlineProvider.overrideWith(_Online.new),
          networkConnectivityProvider.overrideWith(_Connectivity.new),
        ],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const WidgetTestApp(child: FeedView()),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(feed.visibility.last, isTrue);

      await tester.pumpWidget(const SizedBox.shrink());
      expect(tester.takeException(), isNull);
      expect(feed.visibility.last, isFalse);
      final refreshes = feed.refreshes;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump(const Duration(minutes: 6));
      expect(feed.refreshes, refreshes);
      expect(tester.takeException(), isNull);
    },
  );
}
