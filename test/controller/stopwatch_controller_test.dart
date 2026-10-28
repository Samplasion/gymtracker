import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/controller/countdown_controller.dart';
import 'package:gymtracker/controller/stopwatch_controller.dart';

class _ManualTimer implements Timer {
  _ManualTimer(this.callback);
  final void Function(Timer) callback;
  @override
  bool isActive = true;
  @override
  int tick = 0;
  void fire() {
    if (!isActive) return;
    tick++;
    callback(this);
  }

  @override
  void cancel() => isActive = false;
}

class _ManualClock extends WorkoutClock {
  DateTime time = DateTime.utc(2026);
  late _ManualTimer timer;
  @override
  DateTime now() => time;
  void advance(Duration duration) => time = time.add(duration);
  @override
  Timer periodic(Duration duration, void Function(Timer) callback) =>
      timer = _ManualTimer(callback);
}

void main() {
  late _ManualClock clock;
  late List<(Duration, String)> ticks;
  TimeFieldStopwatch create([String initial = '00:10']) => TimeFieldStopwatch(
    setID: 'set',
    getCurrentTime: () => initial,
    clock: clock,
    onTick: (_, duration, encoded) => ticks.add((duration, encoded)),
  );
  setUp(() {
    clock = _ManualClock();
    ticks = [];
  });

  test('one callback catches up after suspension', () {
    final stopwatch = create();
    addTearDown(stopwatch.dispose);
    clock.advance(const Duration(seconds: 30));
    clock.timer.fire();
    expect(stopwatch.currentTime, '00:40');
    expect(ticks.single, (const Duration(seconds: 40), '00:40'));
  });

  test('irregular callbacks preserve fractions and minute rollover', () {
    final stopwatch = create('00:59');
    addTearDown(stopwatch.dispose);
    clock.advance(const Duration(milliseconds: 1600));
    clock.timer.fire();
    expect(ticks.last, (const Duration(seconds: 60), '01:00'));
    clock.advance(const Duration(milliseconds: 600));
    clock.timer.fire();
    expect(ticks.last, (const Duration(seconds: 61), '01:01'));
    clock.timer.fire();
    expect(ticks.last, (const Duration(seconds: 61), '01:01'));
  });

  test(
    'stop flushes elapsed time even without callbacks and cancels timer',
    () {
      final stopwatch = create();
      clock.advance(const Duration(seconds: 30));
      stopwatch.dispose();
      expect(ticks.single, (const Duration(seconds: 40), '00:40'));
      expect(stopwatch.currentTime, '00:40');
      expect(stopwatch.isStopped, isTrue);
      clock.advance(const Duration(seconds: 5));
      clock.timer.fire();
      expect(ticks, hasLength(1));
    },
  );

  test('restart from saved value and rebind use the updated duration', () {
    final first = create('00:00');
    clock.advance(const Duration(seconds: 3));
    first.dispose();
    final second = create(ticks.last.$2);
    final rebound = <(Duration, String)>[];
    second.onTick = (_, duration, encoded) => rebound.add((duration, encoded));
    clock.advance(const Duration(seconds: 2));
    second.dispose();
    expect(rebound.single, (const Duration(seconds: 5), '00:05'));
  });
}
