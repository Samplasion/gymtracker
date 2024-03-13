import 'package:flat/flat.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/debug_controller.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/controller/stopwatch_controller.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/utils/import_routine.dart';
import 'package:gymtracker/view/utils/timer.dart';
import 'package:hive/hive.dart';
import 'package:hive_ui/hive_ui.dart';

class DebugView extends StatelessWidget {
  const DebugView({super.key});

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
                    generateYamlForMissingKeys([...controller.missingKeys]);
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
                    printInfo(info: "\n$missingKeys\n");
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
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    constraints: BoxConstraints.loose(Size(
                      MediaQuery.of(context).size.width,
                      MediaQuery.of(context).size.height - kToolbarHeight,
                    )),
                    builder: (context) => ImportRoutineModal(
                        workout: Get.find<RoutinesController>().workouts.first),
                  );
                },
              ),
              ListTile(
                  title: const Text("Database inspector"),
                  onTap: () {
                    Go.to(
                      () => HiveBoxesView(
                        hiveBoxes: {
                          Hive.box<Exercise>("exercises"): (json) =>
                              Exercise.fromJson(json),
                          Hive.box<Workout>("routines"): (json) =>
                              Workout.fromJson(json),
                          Hive.box<Workout>("history"): (json) =>
                              Workout.fromJson(json),
                        },
                        onError: (String errorMessage) =>
                            Go.snack(errorMessage),
                      ),
                    );
                  }),
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

String generateYamlForMissingKeys(List<String> missingKeys) {
  Map<String, dynamic> keys = unflatten({
    for (final key in missingKeys) key: key.split(".").last,
  });

  String processMap(currentLevel, Map map) {
    var current = "";
    for (final entry in map.entries) {
      if (entry.value is Map) {
        current +=
            "$currentLevel${entry.key}:\n${processMap(currentLevel + "  ", entry.value)}";
      } else {
        current += "$currentLevel${entry.key}: ${entry.value}\n";
      }
    }
    return current;
  }

  return processMap("", keys);
}
