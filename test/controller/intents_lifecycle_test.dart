import 'dart:async';

import 'package:flutter_app_intents/flutter_app_intents.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/controller/intents_controller.dart';

void main() {
  test(
    'intent disposal unregisters once and ignores callbacks after closure',
    () async {
      late Future<AppIntentResult> Function(Map<String, dynamic>) callback;
      final registration = Completer<bool>();
      var starts = 0;
      final removed = <String>[];
      final release = IntentsController.initialize(
        supported: true,
        start: (_, _) => starts++,
        register: (intent, handler) {
          callback = handler;
          return registration.future;
        },
        unregister: (id) async {
          removed.add(id);
          return true;
        },
      );
      await callback({'routineId': 'r', 'routineDisplayName': 'Routine'});
      expect(starts, 1);
      release();
      release();
      registration.complete(true);
      await callback({'routineId': 'r', 'routineDisplayName': 'Routine'});
      expect(starts, 1);
      expect(removed, ['start_routine']);
    },
  );

  test(
    'registration failures arriving after scope closure are ignored',
    () async {
      final registration = Completer<bool>();
      final release = IntentsController.initialize(
        supported: true,
        start: (_, _) => fail('unexpected start'),
        register: (_, _) => registration.future,
        unregister: (_) async => true,
      );
      release();
      registration.completeError(
        StateError('late native registration failure'),
      );
      await Future<void>.delayed(Duration.zero);
    },
  );

  test('unsupported scopes never register or unregister an intent', () {
    final release = IntentsController.initialize(
      supported: false,
      start: (_, _) => fail('unexpected start'),
      register: (_, _) async => throw StateError('unexpected registration'),
      unregister: (_) async => throw StateError('unexpected removal'),
    );
    release();
  });
}
