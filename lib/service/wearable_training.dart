import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/controller/workout_controller.dart';
import 'package:gymtracker/db/wearable_training_store.dart';
import 'package:gymtracker/model/wearable_training.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/provider/routines.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/service/native.dart';
import 'package:gymtracker/service/wearable/training_transport.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/utils/workout_navigation.dart';

final wearableTrainingProvider = Provider<WearableTrainingService>((ref) {
  final service = WearableTrainingService(
    ref,
    transport: ref.watch(wearableTrainingTransportProvider),
  );
  service.start();
  ref.onDispose(service.dispose);
  return service;
});

class WearableTrainingService {
  WearableTrainingService(this.ref, {required this.transport});
  final WearableTrainingTransport transport;
  static const responseTimeout = Duration(seconds: 5);
  final Ref ref;
  Timer? _timer;
  AppLifecycleListener? _lifecycle;
  bool _busy = false;
  bool _conflictShowing = false;
  final Set<String> _declined = {};
  String? _lastCatalog;
  Map<String, dynamic>? _last;
  String? _lastRaw;
  Map<String, dynamic>? _observed;
  int? _observedAt;
  String get owner => ref.read(databaseServiceProvider).db.currentUserId == null
      ? 'guest'
      : 'user:${ref.read(databaseServiceProvider).db.currentUserId}';

  void start() {
    if (!transport.isSupported) return;
    ref.listen(workoutControllerProvider, (_, next) {
      if (next != null) {
        _observed = WearableTrainingDocument.copy(
          ref.read(workoutControllerProvider.notifier).exportWearableSession(),
        );
        _observedAt = DateTime.now().millisecondsSinceEpoch;
      }
    });
    transport.setReceiver((document) async {
      if (_busy) return {'accepted': false};
      _busy = true;
      try {
        return await receive(document);
      } finally {
        _busy = false;
      }
    });
    _lifecycle = AppLifecycleListener(onResume: () => unawaited(_exchange()));
    _timer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => unawaited(_exchange()),
    );
    unawaited(_exchange());
  }

  void dispose() {
    _timer?.cancel();
    _lifecycle?.dispose();
    transport.dispose();
  }

  String _signature(Map<String, dynamic> document) =>
      WearableTrainingDocument.canonical(
        {...document}..remove('globalStopwatch'),
      );

  Future<Map<String, dynamic>?> _capture() async {
    final controller = ref.read(workoutControllerProvider.notifier);
    if (!controller.isActive) return null;
    final raw = WearableTrainingDocument.copy(
      controller.exportWearableSession(),
    );
    final encoded = _signature(raw);
    if (_lastRaw == encoded && _last?['ownerScope'] == owner) return _last;
    final store = WearableTrainingStore(ref.read(databaseServiceProvider).db);
    final previous = await store.read(owner, raw['id'] as String);
    final observedTime = _observed != null && _signature(_observed!) == encoded
        ? _observedAt
        : null;
    _last = WearableTrainingDocument.capture(
      raw,
      previous,
      observedTime ?? DateTime.now().millisecondsSinceEpoch,
    );
    _lastRaw = encoded;
    await store.write(_last!);
    return _last;
  }

  Future<void> _exchange() async {
    if (_busy || !ref.mounted) return;
    _busy = true;
    try {
      final scope = owner;
      final routines = ref.read(routinesStreamProvider);
      final folders = ref.read(foldersStreamProvider);
      Map<String, dynamic>? catalog;
      if (routines.hasValue && folders.hasValue) {
        catalog = WearableTrainingDocument.copy({
          'version': 1,
          'ownerScope': owner,
          'routines': [
            for (final routine in routines.value!)
              {
                ...routine.toJson(),
                'exercises': [
                  for (final group in routine.exercises)
                    group.map(
                      exercise: (e) => {
                        ...ref
                            .read(workoutControllerProvider.notifier)
                            .exportWearableExercise(e),
                      },
                      superset: (s) => {
                        ...s.toJson(),
                        'exercises': [
                          for (final e in s.exercises)
                            {
                              ...ref
                                  .read(workoutControllerProvider.notifier)
                                  .exportWearableExercise(e),
                            },
                        ],
                      },
                    ),
                ],
              },
          ],
          'folders': [for (final folder in folders.value!) folder.toJson()],
        });
      }
      final encoded = jsonEncode(catalog);
      final session = await _capture();
      final entries = await transport
          .exchange({
            'version': 1,
            'ownerScope': owner,
            if (catalog != null && encoded != _lastCatalog) 'catalog': catalog,
            'session': ?session,
          })
          .timeout(responseTimeout);
      _lastCatalog = encoded;
      for (final entry in entries) {
        if (!ref.mounted || owner != scope) break;
        final document = Map<String, dynamic>.from(entry as Map);
        final response = await receive(document);
        if (response['accepted'] == true) {
          await transport
              .acknowledge(document, response)
              .timeout(responseTimeout);
        }
      }
    } catch (error, stack) {
      globalLogger.w(
        'Wearable training synchronization deferred',
        error: error,
        stackTrace: stack,
      );
    } finally {
      _busy = false;
    }
  }

  void _closeFinishedWorkout() {
    if (!ref.read(workoutControllerProvider.notifier).isActive &&
        Go.context != null &&
        isWorkoutRouteName(Go.getTopmostRouteName())) {
      Go.back();
    }
  }

  Future<Map<String, dynamic>> receive(Map<String, dynamic> remote) async {
    if (remote['version'] != 1 ||
        remote['ownerScope'] != owner ||
        remote['id'] is! String ||
        remote['exercises'] is! List ||
        !const [
          'active',
          'completed',
          'discarded',
        ].contains(remote['status']) ||
        remote['time'] is! int ||
        (remote['status'] != 'active' && remote['end'] is! int)) {
      return {'accepted': false};
    }
    final db = ref.read(databaseServiceProvider).db;
    final scope = owner;
    final store = WearableTrainingStore(db);
    final id = remote['id'] as String;
    if (await store.processed(scope, id)) {
      final terminal = await store.read(scope, id);
      if (terminal != null && terminal['status'] == 'completed') {
        final reconciled = WearableTrainingDocument.merge(terminal, remote);
        if (WearableTrainingDocument.canonical(reconciled['exercises']) !=
            WearableTrainingDocument.canonical(terminal['exercises'])) {
          await db.transaction(() async {
            if (owner != scope) throw StateError('Account changed');
            // Never resurrect a history entry the user has subsequently deleted.
            final history = await db.getAllHistoryWorkoutsFuture();
            if (history.any((workout) => workout.id == id)) {
              await db.updateHistoryWorkout(
                Workout.fromJson({
                  ...reconciled,
                  'folder': null,
                  'startingDate': DateTime.fromMillisecondsSinceEpoch(
                    reconciled['time'] as int,
                  ).toIso8601String(),
                  'duration':
                      ((reconciled['end'] as int) -
                          (reconciled['time'] as int)) *
                      1000,
                }),
              );
            }
            if (owner != scope) throw StateError('Account changed');
            await store.write(reconciled, processed: true);
          });
        }
      }
      final running = ref.read(workoutControllerProvider.notifier);
      if (running.isActive && running.nativeWorkoutId == id) {
        await running.cancel(
          saveHealthWorkout: terminal?['status'] == 'completed',
          publishWearableTerminal: false,
        );
        _closeFinishedWorkout();
      }
      return {
        'accepted': true,
        'terminal': true,
        'id': id,
        'ownerScope': scope,
        'document': terminal,
      };
    }
    final controller = ref.read(workoutControllerProvider.notifier);
    if (controller.isSubmitting) return {'accepted': false};
    final active = controller.isActive;
    final same = active && controller.nativeWorkoutId == id;
    Map<String, dynamic>? phone;
    if (same) phone = await _capture();
    phone ??= await store.read(scope, id);
    var merged = phone == null
        ? WearableTrainingDocument.copy(remote)
        : WearableTrainingDocument.merge(phone, remote);
    if (phone == null) {
      // Establish shared structural versions in the very first adoption reply,
      // before either device can make further edits to this session.
      final seeded = WearableTrainingDocument.capture(
        merged,
        null,
        merged['time'] as int,
      );
      merged['structures'] = {
        ...seeded['structures'] as Map,
        ...merged['structures'] as Map? ?? {},
      };
      merged['stamps'] ??= seeded['stamps'];
      merged['modified'] ??= seeded['modified'];
      merged['sequence'] ??= seeded['sequence'];
    }
    if (merged['status'] != 'active') {
      final start = DateTime.fromMillisecondsSinceEpoch(merged['time'] as int);
      final end = DateTime.fromMillisecondsSinceEpoch(merged['end'] as int);
      if (end.isBefore(start)) return {'accepted': false};
      if (merged['status'] == 'completed') {
        final workout = fixWorkout(
          Workout.fromJson({
            ...merged,
            'folder': null,
            'duration':
                merged['duration'] as int? ??
                end.difference(start).inMicroseconds,
            'startingDate': start.toIso8601String(),
          }),
        );
        await db.transaction(() async {
          if (db.currentUserId !=
              (scope == 'guest' ? null : scope.substring(5))) {
            throw StateError('Account changed');
          }
          if (await store.processed(scope, id)) return;
          await db.insertHistoryWorkout(workout);
          if (owner != scope) throw StateError('Account changed');
          await ref
              .read(routinesControllerProvider)
              .advanceProgressionsFromWorkout(workout);
          if (owner != scope) throw StateError('Account changed');
          await store.write(merged, processed: true);
        });
      } else {
        await store.write(merged, processed: true);
      }
      if (owner == scope && merged['status'] == 'completed') {
        ref.read(databaseServiceProvider).onSocialDataSaved?.call();
        ref.read(routinesControllerProvider).scheduleBackup();
      }
      if (same) {
        await controller.cancel(
          saveHealthWorkout: merged['status'] == 'completed',
          publishWearableTerminal: false,
        );
        _closeFinishedWorkout();
      }
      return {
        'accepted': true,
        'terminal': true,
        'id': id,
        'ownerScope': scope,
        'document': merged,
      };
    }
    if (active && !same) {
      await store.write(merged);
      if (!_declined.contains(id) && !_conflictShowing && Go.context != null) {
        _conflictShowing = true;
        final italian =
            Localizations.localeOf(Go.context!).languageCode == 'it';
        final generation = controller.sessionGeneration;
        bool? switchToWearable;
        try {
          switchToWearable = await showDialog<bool>(
            context: Go.context!,
            builder: (context) => AlertDialog(
              title: Text(
                italian
                    ? 'Due allenamenti in corso'
                    : 'Two workouts in progress',
              ),
              content: Text(
                italian
                    ? 'Puoi continuare quello sul telefono oppure salvarlo e prendere in carico quello dell’orologio. Entrambi gli allenamenti vengono conservati.'
                    : 'Continue on your phone, or save that workout and take over the one on your watch. Both workouts are preserved.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(
                    italian ? 'Continua sul telefono' : 'Continue on phone',
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(
                    italian
                        ? 'Salva e passa all’orologio'
                        : 'Save and switch to watch',
                  ),
                ),
              ],
            ),
          );
        } finally {
          _conflictShowing = false;
        }
        if (switchToWearable == true &&
            owner == scope &&
            controller.isSessionActive(generation)) {
          final saved = await controller.submit(
            controller.name,
            DateTime.now().difference(controller.time),
          );
          await ref
              .read(routinesControllerProvider)
              .advanceProgressionsFromWorkout(saved);
          await controller.cancel(saveHealthWorkout: true);
          return receive(remote);
        }
        _declined.add(id);
      }
      return {'accepted': false, 'conflict': true};
    }
    if (owner != scope) return {'accepted': false};
    merged['epoch'] = (merged['epoch'] as int? ?? 0) + 1;
    ref.read(nativeServiceProvider).adoptWorkoutIdentity(id);
    await controller.adoptWearableSession(merged);
    if (owner != scope) return {'accepted': false};
    final adopted = controller.exportWearableSession();
    // Include the phone model's timer defaults in the initial shared state.
    // Their restoration on a later launch must not look like a user edit.
    for (final key in [
      'cursor',
      'restStart',
      'restEnd',
      'globalStopwatch',
      'globalStopwatchPaused',
      'globalStopwatchNominalDuration',
    ]) {
      merged[key] = adopted[key];
    }
    // Commit the journal only after the model and ongoing have been adopted.
    // A failed import must not leave new Watch results against an old phone UI:
    // the next capture would misinterpret that old UI as fresh phone edits.
    await store.write(merged);
    _last = merged;
    _lastRaw = _signature(adopted);
    await transport
        .adoptSensors({...merged, 'parameters': controller.nativeWorkoutState})
        .timeout(responseTimeout);
    // The native phone snapshot now owns this ID; subsequent updates must use it.
    controller.refreshWearableData();
    return {
      'accepted': true,
      'document': merged,
      'ownerScope': scope,
      'id': id,
      'serverTime': DateTime.now().millisecondsSinceEpoch,
    };
  }
}
