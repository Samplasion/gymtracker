import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_app_intents/flutter_app_intents.dart';

class IntentsController {
  static bool get isSupported => Platform.isIOS && !kIsWeb;

  static final startRoutineIntent = AppIntentBuilder()
      .identifier('start_routine')
      .title('Start Routine')
      .description('Starts a routine')
      .parameter(
        const AppIntentParameter(
          name: 'routine',
          title: 'Routine',
          type: AppIntentParameterType.entity,
          isOptional: false,
        ),
      )
      .build();

  /// 1. Call this in your main.dart before runApp() or in your initial state
  static void Function() initialize({
    required void Function(String id, String displayName) start,
    bool? supported,
    Future<bool> Function(
      AppIntent intent,
      Future<AppIntentResult> Function(Map<String, dynamic>) handler,
    )?
    register,
    Future<bool> Function(String identifier)? unregister,
  }) {
    if (!(supported ?? isSupported)) return () {};
    var active = true;
    final registerIntent =
        register ?? FlutterAppIntentsClient.instance.registerIntent;
    final unregisterIntent =
        unregister ?? FlutterAppIntentsClient.instance.unregisterIntent;
    final registration = registerIntent(startRoutineIntent, (parameters) {
      if (!active) {
        return Future.value(
          AppIntentResult.failed(error: 'Application is closed.'),
        );
      }
      return handleStartRoutine(parameters, start: start, supported: true);
    });
    unawaited(
      registration.then<void>(
        (_) {},
        onError: (Object error, StackTrace stack) {
          if (active) Zone.current.handleUncaughtError(error, stack);
        },
      ),
    );
    return () {
      if (!active) return;
      active = false;
      // The plugin removes its Dart handler synchronously before awaiting iOS.
      unawaited(
        unregisterIntent(startRoutineIntent.identifier).catchError((
          Object error,
        ) {
          debugPrint('Could not release routine intent: $error');
          return false;
        }),
      );
    };
  }

  static Future<AppIntentResult> handleStartRoutine(
    Map<String, dynamic> parameters, {
    required void Function(String id, String displayName) start,
    bool? supported,
  }) async {
    if (!(supported ?? isSupported)) {
      return AppIntentResult.failed(error: 'Not supported on this platform.');
    }
    try {
      final routineId = parameters['routineId'] as String?;
      final routineDisplayName = parameters['routineDisplayName'] as String?;

      if (routineId != null && routineDisplayName != null) {
        debugPrint(
          "Siri triggered workout: $routineDisplayName (ID: $routineId)",
        );

        start(routineId, routineDisplayName);
      }

      return AppIntentResult.successful(value: 'Started $routineDisplayName');
    } catch (e) {
      return AppIntentResult.failed(error: 'Could not start the routine.');
    }
  }

  /// 3. Call this whenever the user successfully SAVES a workout
  static Future<void> donateRoutineStarted({
    required String routineId,
    required String routineDisplayName,
  }) async {
    if (!isSupported) return;
    try {
      // We pass the exact identifier and arguments mapped to our Swift AppIntent
      await FlutterAppIntentsService.donateIntentWithMetadata(
        startRoutineIntent.identifier,
        {'routineId': routineId, 'routineDisplayName': routineDisplayName},
        timestamp: DateTime.now(),
      );
      debugPrint("Successfully donated $routineDisplayName to Siri.");
    } catch (e) {
      debugPrint("Failed to donate intent to Siri: $e");
    }
  }
}
