import 'package:flat/flat.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/debug_controller.dart';
import 'package:gymtracker/utils/go.dart';

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
                    Clipboard.setData(ClipboardData(text: missingKeys));
                    Go.snack(
                        "The missing keys have been copied to the clipboard");
                  },
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

  var yamlString = "";

  String processMap(currentLevel, Map map) {
    var current = "";
    for (final entry in map.entries) {
      if (entry.value is Map)
        current +=
            "$currentLevel${entry.key}:\n${processMap(currentLevel + "  ", entry.value)}";
      else
        current += "$currentLevel${entry.key}: ${entry.value}\n";
    }
    return current;
  }

  // return keys.toString();
  return processMap("", keys);
}
