import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/struct/request_cache.dart';

void main() {
  test('shares requests, expires, and fences invalidated responses', () async {
    var time = DateTime(2026);
    var calls = 0;
    final cache = RequestCache<String, int>(
      const Duration(minutes: 5),
      now: () => time,
    );
    final pending = Completer<int>();
    final first = cache.get('a', () {
      calls++;
      return pending.future;
    });
    final second = cache.get('a', () {
      calls++;
      return Future.value(2);
    });
    expect(identical(first, second), true);
    expect(calls, 1);
    cache.invalidate('a');
    cache.put('a', 3);
    pending.complete(1);
    await first;
    expect(cache.peek('a'), 3);
    time = time.add(const Duration(minutes: 6));
    expect(await cache.get('a', () async => 4), 4);
  });
  test('failed requests are retriable and capacity is bounded', () async {
    final cache = RequestCache<String, int>(
      const Duration(minutes: 5),
      capacity: 2,
    );
    await expectLater(
      cache.get('a', () async => throw StateError('offline')),
      throwsStateError,
    );
    expect(await cache.get('a', () async => 1, force: true), 1);
    cache.put('b', 2);
    cache.put('c', 3);
    expect(cache.peek('a'), null);
  });
}
