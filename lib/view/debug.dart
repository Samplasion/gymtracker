import 'dart:convert';

import 'package:drift_db_viewer/drift_db_viewer.dart';
import 'package:flat/flat.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/debug_controller.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/controller/stopwatch_controller.dart';
import 'package:gymtracker/controller/workout_controller.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/settings/radio.dart';
import 'package:gymtracker/view/utils/import_routine.dart';
import 'package:gymtracker/view/utils/timer.dart';
import 'package:logger/logger.dart' as logger_lib;

class DebugView extends StatefulWidget {
  const DebugView({super.key});

  @override
  State<DebugView> createState() => _DebugViewState();
}

class _DebugViewState extends State<DebugView> {
  Future<void> _loadTranslationsFuture = Future.value();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DebugController>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar.large(
            title: Text("Debug"),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Obx(() {
                final missingKeys =
                    generateJsonForMissingKeys([...controller.missingKeys]);
                return ListTile(
                  title: const Text("Missing translations"),
                  subtitle: Text(
                    missingKeys,
                    style: const TextStyle(
                      fontFamily: "monospace",
                      fontFamilyFallback: <String>["Menlo", "Courier"],
                    ),
                  ),
                  onTap: () {
                    logger.d("\n$missingKeys\n");
                    Clipboard.setData(ClipboardData(text: missingKeys));
                    Go.snack(
                        "The missing keys have been copied to the clipboard");
                  },
                );
              }),
              ListTile(
                title: const Text("Fix history std. exercise labels"),
                subtitle: const Text(
                    "Fixes the labels of the standard exercises in the history"),
                onTap: () {
                  final hc = Get.find<HistoryController>();
                  final db = Get.find<DatabaseService>();
                  for (final workout in db.workoutHistory) {
                    db.setHistoryWorkout(hc.fixWorkout(workout));
                  }

                  Go.snack("Fixed ${db.workoutHistory.length} workouts");
                },
              ),
              ListTile(
                title: const Text("Push workout import modal"),
                onTap: () {
                  Go.showBottomModalScreen(
                    (context, _) => ImportRoutineModal(
                      workout: Get.find<RoutinesController>().workouts.first,
                    ),
                  );
                },
              ),
              ListTile(
                title: const Text("Database inspector"),
                onTap: () {
                  Go.to(() => DriftDbViewer(Get.find<DatabaseService>().db));
                },
              ),
              FutureBuilder(
                future: _loadTranslationsFuture,
                builder: (context, snapshot) {
                  return ListTile(
                    enabled: snapshot.connectionState == ConnectionState.done,
                    title: const Text("Reload translation keys"),
                    onTap: () async {
                      controller.missingKeys.clear();
                      _loadTranslationsFuture =
                          Get.find<GTLocalizations>().init(false);
                      _loadTranslationsFuture.then((_) {
                        Go.snack("Reloaded");
                      });
                    },
                  );
                },
              ),
              ValueBuilder<bool?>(
                initialValue: controller.showSimulator.value,
                builder: (value, onChanged) => SwitchListTile(
                  title: const Text("Show device simulator"),
                  value: value ?? false,
                  onChanged: onChanged,
                ),
                onUpdate: (v) => controller.setShowSimulator(v ?? false),
              ),
              ListTile(
                title: const Text("CRASH!"),
                onTap: () {
                  throw Exception("Crash!");
                },
              ),
              ListTile(
                title: const Text("CRASH (MethodChannel)!"),
                onTap: () async {
                  const channel = MethodChannel('crashy-custom-channel');
                  await channel.invokeMethod('blah');
                },
              ),
              ListTile(
                title: const Text("Generated title alert"),
                onTap: () async {
                  Go.to(() => const WorkoutTitleGeneratorAlert());
                },
              ),
              ValueBuilder<logger_lib.Level?>(
                initialValue: logger_lib.Logger.level,
                builder: (val, onChange) => RadioModalTile<logger_lib.Level?>(
                  title: const Text("Logger level"),
                  onChange: onChange,
                  values: {
                    for (final lvl in logger_lib.Level.values) lvl: lvl.name,
                  },
                  selectedValue: val,
                ),
                onUpdate: (v) => logger_lib.Logger.level = v!,
              ),
              ListTile(
                title: const Text("Recompute streaks"),
                subtitle: Text(
                    "Current value: ${Get.find<HistoryController>().streaks.value}"),
                onTap: () {
                  Get.find<HistoryController>().computeStreaks();
                },
              ),

              // ------------
              ListTile(
                title: Text(
                  "Running stopwatches",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
              Obx(() {
                return Column(
                  children: [
                    for (final entry
                        in Get.find<StopwatchController>().stopwatches.entries)
                      TimerView(
                        builder: (ctx, _) => ListTile(
                          title: Text(entry.key),
                          subtitle: Text(
                              "Running: ${!entry.value.isStopped()}, Current time: ${entry.value.currentTime}"),
                        ),
                        startingTime: DateTime.now(),
                      ),
                  ],
                );
              }),
              StatefulBuilder(builder: (context, setState) {
                return Slider(
                  value: timeDilation,
                  onChanged: ((value) {
                    setState(() {
                      timeDilation = value;
                    });
                  }),
                  min: 1,
                  max: 15,
                );
              }),
            ]),
          ),
        ],
      ),
    );
  }
}

String generateJsonForMissingKeys(List<String> missingKeys) {
  missingKeys = missingKeys.where((key) => key != "appName").toList();
  Map<String, dynamic> keys = unflatten({
    for (final key in missingKeys) key: key.split(".").last,
  });

  const encoder = JsonEncoder.withIndent("  ");
  final lines = encoder.convert(keys).split('\n');
  return lines.skip(1).take(lines.length - 2).join('\n');
}

class WorkoutTitleGeneratorAlert extends StatefulWidget {
  const WorkoutTitleGeneratorAlert({super.key});

  @override
  State<WorkoutTitleGeneratorAlert> createState() =>
      _WorkoutTitleGeneratorAlertState();
}

class _WorkoutTitleGeneratorAlertState
    extends State<WorkoutTitleGeneratorAlert> {
  final Set<GTMuscleCategory> _selectedCategories = {};

  String _generate() =>
      WorkoutController.generateWorkoutTitle(_selectedCategories);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Generate workout title"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(_generate()),
          ...GTMuscleCategory.values.map((category) {
            return CheckboxListTile(
              title: Text(category.name),
              value: _selectedCategories.contains(category),
              onChanged: (value) {
                setState(() {
                  if (value!) {
                    _selectedCategories.add(category);
                  } else {
                    _selectedCategories.remove(category);
                  }
                });
              },
            );
          }),
        ],
      ),
    );
  }
}
