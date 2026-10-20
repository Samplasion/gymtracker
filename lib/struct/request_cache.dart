import 'dart:collection';
import 'dart:math';

/// Bounded session cache. Invalidating a key also fences its in-flight result.
class RequestCache<K, V> {
  RequestCache(this.ttl, {this.capacity = 256, DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final Duration ttl;
  final int capacity;
  final DateTime Function() _now;
  final _values = LinkedHashMap<K, (DateTime, V)>();
  final _pending = <K, Future<V>>{};
  final _versions = <K, Object>{};
  final _errors = LinkedHashMap<K, (DateTime, int, Object, StackTrace)>();

  V? peek(K key) => _values[key]?.$2;
  bool isFresh(K key) {
    final entry = _values[key];
    return entry != null && _now().difference(entry.$1) < ttl;
  }

  void put(K key, V value) {
    invalidate(key);
    _values[key] = (_now(), value);
    while (_values.length > capacity) {
      _values.remove(_values.keys.first);
    }
  }

  Future<V> get(K key, Future<V> Function() fetch, {bool force = false}) {
    final pending = _pending[key];
    if (pending != null) return pending;
    final failure = _errors[key];
    if (!force && failure != null && _now().isBefore(failure.$1)) {
      final previous = _values[key];
      return previous != null
          ? Future.value(previous.$2)
          : Future.error(failure.$3, failure.$4);
    }
    if (!force && isFresh(key)) {
      final entry = _values.remove(key)!;
      _values[key] = entry;
      return Future.value(entry.$2);
    }
    final version = Object();
    _versions[key] = version;
    final future = Future<V>.sync(fetch)
        .then((value) {
          if (identical(_versions[key], version)) {
            _errors.remove(key);
            _values.remove(key);
            _values[key] = (_now(), value);
            while (_values.length > capacity) {
              _values.remove(_values.keys.first);
            }
          }
          return value;
        })
        .catchError((Object error, StackTrace stack) {
          if (identical(_versions[key], version)) {
            final attempts = (_errors[key]?.$2 ?? 0) + 1;
            _errors[key] = (
              _now().add(Duration(seconds: min(60, 1 << min(attempts - 1, 6)))),
              attempts,
              error,
              stack,
            );
            while (_errors.length > capacity) {
              _errors.remove(_errors.keys.first);
            }
            final previous = _values[key];
            if (previous != null) return previous.$2;
          }
          Error.throwWithStackTrace(error, stack);
        })
        .whenComplete(() {
          if (identical(_versions[key], version)) {
            _pending.remove(key);
            _versions.remove(key);
          }
        });
    _pending[key] = future;
    return future;
  }

  void invalidate(K key) {
    _errors.remove(key);
    _values.remove(key);
    _pending.remove(key);
    _versions.remove(key);
  }

  void clear() {
    _errors.clear();
    _values.clear();
    _pending.clear();
    _versions.clear();
  }
}
