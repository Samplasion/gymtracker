import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_app_intents/flutter_app_intents.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/routines_controller.dart';

class IntentsController {
  static bool get isSupported => Platform.isIOS && !kIsWeb;

  static final startRoutineIntent = AppIntentBuilder()
      .identifier('start_routine')
      .title('Start Routine')
      .description('Starts a routine')
      .parameter(const AppIntentParameter(
        name: 'routine',
        title: 'Routine',
        type: AppIntentParameterType.entity,
        isOptional: false,
      ))
      .build();

  /// 1. Call this in your main.dart before runApp() or in your initial state
  static void initialize() {
    if (!isSupported) return;
    FlutterAppIntentsClient.instance.registerIntent(
      startRoutineIntent,
      _handleSiriStartRoutine,
    );
  }

  /// 2. Handles the incoming command when the user talks to Siri
  static Future<AppIntentResult> _handleSiriStartRoutine(
      Map<String, dynamic> parameters) async {
    if (!isSupported) {
      return AppIntentResult.failed(error: 'Not supported on this platform.');
    }
    try {
      final routineId = parameters['routineId'] as String?;
      final routineDisplayName = parameters['routineDisplayName'] as String?;

      if (routineId != null && routineDisplayName != null) {
        debugPrint(
            "Siri triggered workout: $routineDisplayName (ID: $routineId)");

        Get.find<RoutinesController>().startRoutine(
          Get.context!,
          Get.find<RoutinesController>().getRoutine(routineId),
        );
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
        {
          'routineId': routineId,
          'routineDisplayName': routineDisplayName,
        },
        timestamp: DateTime.now(),
      );
      debugPrint("Successfully donated $routineDisplayName to Siri.");
    } catch (e) {
      debugPrint("Failed to donate intent to Siri: $e");
    }
  }
}
