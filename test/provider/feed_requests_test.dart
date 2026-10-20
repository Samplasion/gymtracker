import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:gymtracker/model/achievements.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/provider/connectivity.dart';
import 'package:gymtracker/provider/feed.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/service/feed.dart';
import 'package:gymtracker/service/online.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxdart/rxdart.dart';
import '../test_helpers/mock_services.dart';

class _Service extends TestOnlineServiceImpl {
  int calls = 0;
  Completer<void>? response;
  @override
  Future<({List<FeedItem> feed, bool hasMore})> getFriendsFeed({
    required Set<FeedSource> sources,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    calls++;
    await response?.future;
    return (feed: <FeedItem>[], hasMore: false);
  }
}

class _Online extends Online {
  _Online(this.service);
  final _Service service;
  @override
  OnlineService get onlineService => service;
  @override
  OnlineAccount? build() => OnlineAccount(id: 'owner', name: 'Owner');
}

class _Connectivity extends NetworkConnectivityNotifier {
  @override
  Stream<bool> build() => Stream.value(true);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(MockServices.setup);
  tearDown(MockServices.tearDown);
  test('pending feed response is ignored after provider disposal', () async {
    final history = BehaviorSubject<List<Workout>>.seeded([]);
    final completions = BehaviorSubject<List<AchievementCompletion>>.seeded([]);
    addTearDown(history.close);
    addTearDown(completions.close);
    when(
      () => MockServices.databaseService.history$,
    ).thenAnswer((_) => history);
    when(
      () => MockServices.databaseService.completions$,
    ).thenAnswer((_) => completions);
    when(
      () => MockServices.achievementsController.completionStream,
    ).thenAnswer((_) => completions.stream);
    final response = Completer<void>();
    final service = _Service()..response = response;
    final container = ProviderContainer(
      overrides: [
        onlineProvider.overrideWith(() => _Online(service)),
        currentUserIdProvider.overrideWithValue('owner'),
        networkConnectivityProvider.overrideWith(_Connectivity.new),
      ],
    );
    container.listen(feedProvider, (_, _) {});
    final pending = container.read(feedProvider.future);
    unawaited(pending.then<void>((_) {}, onError: (Object _, StackTrace _) {}));
    await container.read(networkConnectivityProvider.future);
    await pumpEventQueue();
    expect(service.calls, 1);
    container.dispose();
    response.complete();
    await pumpEventQueue();
  });
  test('tab listeners and local changes reuse remote pages', () async {
    final history = BehaviorSubject<List<Workout>>.seeded([]);
    final completions = BehaviorSubject<List<AchievementCompletion>>.seeded([]);
    addTearDown(history.close);
    addTearDown(completions.close);
    when(
      () => MockServices.databaseService.history$,
    ).thenAnswer((_) => history);
    when(
      () => MockServices.databaseService.completions$,
    ).thenAnswer((_) => completions);
    when(
      () => MockServices.achievementsController.completionStream,
    ).thenAnswer((_) => completions.stream);
    final service = _Service();
    final c = ProviderContainer(
      overrides: [
        onlineProvider.overrideWith(() => _Online(service)),
        currentUserIdProvider.overrideWithValue('owner'),
        networkConnectivityProvider.overrideWith(_Connectivity.new),
      ],
    );
    addTearDown(c.dispose);
    var listener = c.listen(feedProvider, (_, __) {});
    await c.read(feedProvider.future);
    expect(service.calls, 1);
    listener.close();
    await c.pump();
    listener = c.listen(feedProvider, (_, __) {});
    await c.read(feedProvider.future);
    expect(service.calls, 1);
    final workout = Workout(
      id: 'new-local',
      name: 'Local',
      exercises: [],
      startingDate: DateTime.now().subtract(const Duration(minutes: 1)),
    );
    history.add([workout]);
    MockServices.historyController.history.assignAll([workout]);
    await pumpEventQueue();
    await c.pump();
    expect(service.calls, 1);
    expect(
      c
          .read(feedProvider)
          .value!
          .whereType<FeedItemWorkout>()
          .single
          .workout
          .id,
      'new-local',
    );
    await c.read(feedProvider.notifier).refreshIfStale();
    expect(service.calls, 1);
    await c.read(feedProvider.notifier).refresh();
    expect(service.calls, 2);
    listener.close();
  });
}
