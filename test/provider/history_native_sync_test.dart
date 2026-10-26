import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/model/preferences.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/provider/settings.dart';
import 'package:gymtracker/provider/training_data.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/service/native.dart';
import 'package:gymtracker/service/native.g.dart';
import 'package:gymtracker/service/widgets.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxdart/rxdart.dart';

class _Host extends Mock implements GymBroNativeHostAPI {}

class _Widgets extends WidgetsService {
  int? weekly, rest, total;
  @override
  Future<void> updateWeeklyStreak(int value) async => weekly = value;
  @override
  Future<void> updateRestStreak(int value) async => rest = value;
  @override
  Future<void> updateWorkouts(int value) async => total = value;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'history changes reach native widgets without profile consumers',
    () async {
      final errors = <Object?>[];
      final logs = Logger.root.onRecord.listen((record) {
        if (record.level >= Level.SEVERE) errors.add(record.error);
      });
      addTearDown(logs.cancel);
      final history = BehaviorSubject<List<Workout>>.seeded([]);
      final host = _Host();
      final widgets = _Widgets();
      final payloads = <Map<String, int>>[];
      final charts = <List<int>>[];
      when(() => host.updateHomeWidgetParameters(any(), any())).thenAnswer((
        call,
      ) async {
        payloads.add(Map<String, int>.from(call.positionalArguments[0] as Map));
        charts.add(List<int>.from(call.positionalArguments[1] as List));
      });
      final native = NativeService.withHost(host);
      final today = DateTime(2026, 10, 25);
      final container = ProviderContainer(
        overrides: [
          historyWorkoutsProvider.overrideWith((ref) => history.stream),
          appPreferencesProvider.overrideWith(
            (ref) => Stream.value(
              Prefs.fromJson({
                'locale': ['it'],
              }, true),
            ),
          ),
          trainingClockProvider.overrideWithValue(() => today),
          widgetsServiceProvider.overrideWithValue(widgets),
          nativeServiceProvider.overrideWithValue(native),
        ],
      );
      addTearDown(() async {
        container.dispose();
        native.dispose();
        await history.close();
      });
      // Same persistent observer as bootstrap, with no MeView or calendar mounted.
      container.listen(historyControllerProvider, (_, _) {});
      history.add([]);
      await container.pump();
      SchedulerBinding.instance.handleBeginFrame(null);
      SchedulerBinding.instance.handleDrawFrame();
      expect(container.read(historyControllerProvider).streaks.weekStreak, 0);
      expect(errors, isEmpty);
      expect(payloads.last, {
        streakKey: 0,
        restKey: today.millisecondsSinceEpoch,
        totalWorkoutsKey: 0,
      });
      expect(charts.last, List.filled(126, 0));

      Workout workout(String id, int day) => Workout(
        id: id,
        name: id,
        exercises: [],
        startingDate: DateTime(2026, 10, day, 12),
      );
      final older = workout('older', 12);
      final recent = workout('recent', 20);
      history.add([older, recent]);
      await container.pump();
      SchedulerBinding.instance.handleBeginFrame(null);
      SchedulerBinding.instance.handleDrawFrame();
      expect(payloads.last, {
        streakKey: 2,
        restKey: DateTime(2026, 10, 20).millisecondsSinceEpoch,
        totalWorkoutsKey: 2,
      });
      expect((widgets.weekly, widgets.rest, widgets.total), (2, 5, 2));
      expect(charts.last.length, 126);
      expect(charts.last[0], 1);
      expect(charts.last[8], 1);
      expect(charts.last.fold<int>(0, (sum, count) => sum + count), 2);

      history.add([older, recent.copyWith(startingDate: today)]);
      await container.pump();
      SchedulerBinding.instance.handleBeginFrame(null);
      SchedulerBinding.instance.handleDrawFrame();
      expect(payloads.last[restKey], today.millisecondsSinceEpoch);
      expect(widgets.rest, 0);
      expect(charts.last[13], 1);
      expect(charts.last[5], 0);

      history.add([older]);
      await container.pump();
      SchedulerBinding.instance.handleBeginFrame(null);
      SchedulerBinding.instance.handleDrawFrame();
      expect(payloads.last[streakKey], 1);
      expect(
        payloads.last[restKey],
        DateTime(2026, 10, 12).millisecondsSinceEpoch,
      );
      expect(payloads.last[totalWorkoutsKey], 1);
      expect((widgets.weekly, widgets.rest, widgets.total), (1, 13, 1));

      history.add([]);
      await container.pump();
      SchedulerBinding.instance.handleBeginFrame(null);
      SchedulerBinding.instance.handleDrawFrame();
      expect(payloads.last[streakKey], 0);
      expect(payloads.last[totalWorkoutsKey], 0);
      expect(charts.last, List.filled(126, 0));
    },
  );
}
