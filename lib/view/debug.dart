import 'package:flat/flat.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/debug_controller.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/controller/stopwatch_controller.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/utils/timer.dart';

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
                  db.workoutHistory =
                      db.workoutHistory.map(hc.fixWorkout).toList();

                  Go.snack("Fixed ${db.workoutHistory.length} workouts");
                },
              ),
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
