import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/provider/connectivity.dart';
import 'package:gymtracker/provider/feed.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/service/feed.dart';
import 'package:gymtracker/service/online.dart';
import 'package:gymtracker/view/feed.dart';
import 'package:mocktail/mocktail.dart';

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

void main() {
  setUp(() async {
    MockServices.setup();
    await initTestLocalizations();
    when(
      () => MockServices.routinesController.suggestions,
    ).thenReturn(<RoutineSuggestion>[].obs);
  });
  tearDown(MockServices.tearDown);

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
