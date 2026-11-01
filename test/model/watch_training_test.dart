import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/model/wearable_training.dart';

Map<String, dynamic> document() => {
  'version': 1,
  'id': 'session',
  'ownerScope': 'guest',
  'status': 'active',
  'time': 1,
  'exercises': [
    {
      'id': 'exercise',
      'name': 'Bench',
      'parameters': 'repsWeight',
      'restTime': 60000000,
      'sets': [
        {
          'id': 'a',
          'kind': 'normal',
          'parameters': 'repsWeight',
          'weight': 20,
          'reps': 10,
          'done': false,
        },
        {
          'id': 'b',
          'kind': 'normal',
          'parameters': 'repsWeight',
          'weight': 20,
          'reps': 10,
          'done': false,
        },
      ],
    },
  ],
};
Map set(Map document, int index) =>
    (document['exercises'] as List).first['sets'][index] as Map;
void main() {
  test('merged native channel set replacements remain valid model JSON', () {
    final phone = WearableTrainingDocument.capture(document(), null, 10);
    final watch = WearableTrainingDocument.copy(phone);
    set(watch, 0)['done'] = true;
    watch['stamps']['a'] = {'time': 20, 'device': 'watch', 'sequence': 2};
    const codec = StandardMessageCodec();
    final native = Map<String, dynamic>.from(
      codec.decodeMessage(codec.encodeMessage(watch)) as Map,
    );
    expect(set(native, 0), isNot(isA<Map<String, dynamic>>()));
    final merged = WearableTrainingDocument.merge(phone, native);
    final restored = GTSet.fromJson(set(merged, 0) as Map<String, dynamic>);
    expect(restored.done, true);
    expect(merged['stamps']['a'], isA<Map<String, dynamic>>());
  });
  test('expired countdown on launch is not a newer phone navigation', () {
    final raw = document()
      ..addAll({'cursor': 'a', 'restStart': 10, 'restEnd': 30});
    final base = WearableTrainingDocument.capture(raw, null, 10);
    raw.remove('restStart');
    raw.remove('restEnd');
    expect(WearableTrainingDocument.capture(raw, base, 1000)['modified'], 10);
  });
  test('cold capture does not outrank offline cursor and rest changes', () {
    final raw = document()..['cursor'] = 'a';
    final base = WearableTrainingDocument.capture(raw, null, 10);
    final watch = WearableTrainingDocument.copy(base)
      ..['cursor'] = 'b'
      ..['sequence'] = 20
      ..['epoch'] = 3
      ..['modified'] = 20
      ..['restStart'] = 20
      ..['restEnd'] = 80;
    final restored = WearableTrainingDocument.capture(raw, base, 1000);
    expect(restored['modified'], 10);
    final merged = WearableTrainingDocument.merge(restored, watch);
    expect(merged['cursor'], 'b');
    expect(merged['restEnd'], 80);
    expect(merged['sequence'], 20);
    expect(merged['epoch'], 3);
  });

  test(
    'restored zero defaults are not edits over nullable Watch parameters',
    () {
      final raw = WearableTrainingDocument.copy(document());
      set(raw, 0)['time'] = null;
      set(raw, 0)['distance'] = null;
      final base = WearableTrainingDocument.capture(raw, null, 10);
      final restored = WearableTrainingDocument.copy(raw);
      set(restored, 0)['time'] = 0;
      set(restored, 0)['distance'] = 0.0;
      final captured = WearableTrainingDocument.capture(restored, base, 1000);
      expect(captured['stamps']['a']['time'], 10);
    },
  );
  test(
    'restoring omitted nullable fields does not create a phone set edit',
    () {
      final original = WearableTrainingDocument.capture(document(), null, 10);
      final restored = WearableTrainingDocument.copy(original);
      final exercise = (restored['exercises'] as List).first as Map;
      final set = (exercise['sets'] as List).first as Map;
      set['distance'] = null;
      set['time'] = null;
      final captured = WearableTrainingDocument.capture(
        restored,
        original,
        1000,
      );
      expect(
        WearableTrainingDocument.canonical(captured['stamps']),
        WearableTrainingDocument.canonical(original['stamps']),
      );
      final offline = WearableTrainingDocument.copy(original);
      final remoteSet =
          ((((offline['exercises'] as List).first as Map)['sets']) as List)
                  .first
              as Map;
      remoteSet['done'] = true;
      (offline['stamps'] as Map)[remoteSet['id']] = {
        'time': 20,
        'device': 'watch',
        'sequence': 2,
      };
      final merged = WearableTrainingDocument.merge(captured, offline);
      expect(
        ((((merged['exercises'] as List).first as Map)['sets']) as List)
            .first['done'],
        true,
      );
    },
  );

  test('merges independent series, replacing each whole set atomically', () {
    final base = WearableTrainingDocument.capture(document(), null, 10);
    final phone = WearableTrainingDocument.copy(base);
    set(phone, 0)['weight'] = 30;
    final captured = WearableTrainingDocument.capture(phone, base, 20);
    final watch = WearableTrainingDocument.copy(base);
    set(watch, 1)['reps'] = 12;
    watch['stamps']['b'] = {'time': 30, 'device': 'watch', 'sequence': 1};
    final merged = WearableTrainingDocument.merge(captured, watch);
    expect(set(merged, 0)['weight'], 30);
    expect(set(merged, 1)['reps'], 12);
    expect(set(base, 1)['reps'], 10);
  });
  test(
    'native dictionary key order never turns unchanged sets into phone edits',
    () {
      final base = WearableTrainingDocument.capture(document(), null, 10);
      final raw = WearableTrainingDocument.copy(base);
      final original = Map<String, dynamic>.from(set(raw, 0));
      original['weight'] = 20.0;
      raw['exercises'][0]['sets'][0] = {
        for (final key in original.keys.toList().reversed) key: original[key],
      };
      final captured = WearableTrainingDocument.capture(raw, base, 100);
      expect(captured['stamps']['a']['time'], 10);
    },
  );

  test('latest whole set wins and phone breaks timestamp ties', () {
    final phone = WearableTrainingDocument.capture(document(), null, 10);
    final watch = WearableTrainingDocument.copy(phone);
    set(watch, 0)['weight'] = 35;
    watch['stamps']['a'] = {'time': 11, 'device': 'watch', 'sequence': 1};
    expect(set(WearableTrainingDocument.merge(phone, watch), 0)['weight'], 35);
    watch['stamps']['a']['time'] = 10;
    expect(set(WearableTrainingDocument.merge(phone, watch), 0)['weight'], 20);
  });
  test(
    'phone structural replacement invalidates even newer watch set edits',
    () {
      final base = WearableTrainingDocument.capture(document(), null, 10);
      final changed = WearableTrainingDocument.copy(base);
      changed['exercises'][0]['name'] = 'Replacement';
      final phone = WearableTrainingDocument.capture(changed, base, 20);
      final watch = WearableTrainingDocument.copy(base);
      set(watch, 0)['weight'] = 99;
      watch['stamps']['a'] = {'time': 1000, 'device': 'watch', 'sequence': 1};
      final merged = WearableTrainingDocument.merge(phone, watch);
      expect(set(merged, 0)['weight'], 20);
      expect(merged['exercises'][0]['name'], 'Replacement');
    },
  );
  test(
    'deleted exercise is not resurrected and terminal state stays terminal',
    () {
      final base = WearableTrainingDocument.capture(document(), null, 10);
      final phone = WearableTrainingDocument.copy(base)
        ..['exercises'] = []
        ..['status'] = 'discarded';
      final merged = WearableTrainingDocument.merge(phone, base);
      expect(merged['exercises'], isEmpty);
      expect(merged['status'], 'discarded');
    },
  );
  test(
    'late edits before completion merge, but post-completion edits do not',
    () {
      final terminal = WearableTrainingDocument.capture(document(), null, 10)
        ..['status'] = 'completed'
        ..['end'] = 20;
      final watch = WearableTrainingDocument.copy(terminal)
        ..['status'] = 'active';
      set(watch, 0)['weight'] = 40;
      watch['stamps']['a'] = {'time': 19, 'device': 'watch', 'sequence': 1};
      expect(
        set(WearableTrainingDocument.merge(terminal, watch), 0)['weight'],
        40,
      );
      watch['stamps']['a']['time'] = 21;
      expect(
        set(WearableTrainingDocument.merge(terminal, watch), 0)['weight'],
        20,
      );
    },
  );

  test('rejects cross-account and cross-session reconciliation', () {
    final phone = WearableTrainingDocument.capture(document(), null, 10);
    final remote = WearableTrainingDocument.copy(phone)
      ..['ownerScope'] = 'user:other';
    expect(
      () => WearableTrainingDocument.merge(phone, remote),
      throwsStateError,
    );
    remote['ownerScope'] = 'guest';
    remote['id'] = 'other';
    expect(
      () => WearableTrainingDocument.merge(phone, remote),
      throwsStateError,
    );
  });
}
