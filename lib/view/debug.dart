import 'dart:convert';

import 'package:drift/drift.dart' show GeneratedDatabase;
import 'package:drift_db_viewer/drift_db_viewer.dart';
import 'package:flat/flat.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/debug_controller.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/controller/me_controller.dart';
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/controller/stopwatch_controller.dart';
import 'package:gymtracker/controller/workout_controller.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/measurements.dart';
import 'package:gymtracker/service/database.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/utils/constants.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/utils/noise.dart';
import 'package:gymtracker/utils/theme.dart';
import 'package:gymtracker/view/settings/radio.dart';
import 'package:gymtracker/view/skeleton.dart';
import 'package:gymtracker/view/utils/import_routine.dart';
import 'package:gymtracker/view/utils/sliver_utils.dart';
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
            leading: SkeletonDrawerButton(),
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
                    style: monospace,
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
                  Go.to(() => DriftDbViewer(Get.find<DatabaseService>().db as GeneratedDatabase));
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
              ListTile(
                title: const Text("Colors"),
                onTap: () async {
                  Go.to(() => const ColorsPane());
                },
              ),
              ListTile(
                title: const Text("MaterialBanner test"),
                onTap: () async {
                  Go.to(() => const _DebugMaterialBannerTest());
                },
              ),
              ListTile(
                title: const Text("Add random weights..."),
                onTap: () async {
                  Go.toDialog(() => const _DebugAddRandomWeightAlert());
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
          const SliverBottomSafeArea(),
        ],
      ),
    );
  }
}

String generateJsonForMissingKeys(List<String> missingKeys) {
  missingKeys = missingKeys.where((key) => key != "appName").toList();
  globalLogger.d("Missing keys: $missingKeys");
  Map<String, dynamic> keys = unflatten({
    for (final key in missingKeys) key: key.split(".").last,
  });

  const encoder = JsonEncoder.withIndent("  ");
  final lines = encoder.convert(keys).split('\n');
  if (lines.length == 1) return lines.join('\n');
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

const _divider = SizedBox(height: 10);

class ColorsPane extends StatelessWidget {
  const ColorsPane({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Colors"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: ColorSchemeView(colorScheme: Theme.of(context).colorScheme),
        ),
      ),
    );
  }
}

class ColorSchemeView extends StatelessWidget {
  const ColorSchemeView({super.key, required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ColorGroup(children: [
          ColorChip(
            label: 'primary',
            color: colorScheme.primary,
            onColor: colorScheme.onPrimary,
          ),
          ColorChip(
              label: 'onPrimary',
              color: colorScheme.onPrimary,
              onColor: colorScheme.primary),
          ColorChip(
            label: 'primaryContainer',
            color: colorScheme.primaryContainer,
            onColor: colorScheme.onPrimaryContainer,
          ),
          ColorChip(
            label: 'onPrimaryContainer',
            color: colorScheme.onPrimaryContainer,
            onColor: colorScheme.primaryContainer,
          ),
        ]),
        _divider,
        ColorGroup(children: [
          ColorChip(
            label: 'secondary',
            color: colorScheme.secondary,
            onColor: colorScheme.onSecondary,
          ),
          ColorChip(
            label: 'onSecondary',
            color: colorScheme.onSecondary,
            onColor: colorScheme.secondary,
          ),
          ColorChip(
            label: 'secondaryContainer',
            color: colorScheme.secondaryContainer,
            onColor: colorScheme.onSecondaryContainer,
          ),
          ColorChip(
              label: 'onSecondaryContainer',
              color: colorScheme.onSecondaryContainer,
              onColor: colorScheme.secondaryContainer),
        ]),
        _divider,
        ColorGroup(
          children: [
            ColorChip(
                label: 'tertiary',
                color: colorScheme.tertiary,
                onColor: colorScheme.onTertiary),
            ColorChip(
                label: 'onTertiary',
                color: colorScheme.onTertiary,
                onColor: colorScheme.tertiary),
            ColorChip(
                label: 'tertiaryContainer',
                color: colorScheme.tertiaryContainer,
                onColor: colorScheme.onTertiaryContainer),
            ColorChip(
                label: 'onTertiaryContainer',
                color: colorScheme.onTertiaryContainer,
                onColor: colorScheme.tertiaryContainer),
          ],
        ),
        _divider,
        ColorGroup(
          children: [
            ColorChip(
                label: 'quaternary',
                color: colorScheme.quaternary,
                onColor: colorScheme.onQuaternary),
            ColorChip(
                label: 'onQuaternary',
                color: colorScheme.onQuaternary,
                onColor: colorScheme.quaternary),
            ColorChip(
                label: 'quaternaryContainer',
                color: colorScheme.quaternaryContainer,
                onColor: colorScheme.onQuaternaryContainer),
            ColorChip(
                label: 'onQuaternaryContainer',
                color: colorScheme.onQuaternaryContainer,
                onColor: colorScheme.quaternaryContainer),
          ],
        ),
        _divider,
        ColorGroup(
          children: [
            ColorChip(
                label: 'quinary',
                color: colorScheme.quinary,
                onColor: colorScheme.onQuinary),
            ColorChip(
                label: 'onQuinary',
                color: colorScheme.onQuinary,
                onColor: colorScheme.quinary),
            ColorChip(
                label: 'quinaryContainer',
                color: colorScheme.quinaryContainer,
                onColor: colorScheme.onQuinaryContainer),
            ColorChip(
                label: 'onQuinaryContainer',
                color: colorScheme.onQuinaryContainer,
                onColor: colorScheme.quinaryContainer),
          ],
        ),
        _divider,
        ColorGroup(
          children: [
            ColorChip(
                label: 'error',
                color: colorScheme.error,
                onColor: colorScheme.onError),
            ColorChip(
                label: 'onError',
                color: colorScheme.onError,
                onColor: colorScheme.error),
            ColorChip(
                label: 'errorContainer',
                color: colorScheme.errorContainer,
                onColor: colorScheme.onErrorContainer),
            ColorChip(
                label: 'onErrorContainer',
                color: colorScheme.onErrorContainer,
                onColor: colorScheme.errorContainer),
          ],
        ),
        _divider,
        ColorGroup(
          children: [
            ColorChip(
                label: 'background',
                color: colorScheme.surface,
                onColor: colorScheme.onSurface),
            ColorChip(
                label: 'onBackground',
                color: colorScheme.onSurface,
                onColor: colorScheme.surface),
          ],
        ),
        _divider,
        ColorGroup(
          children: [
            ColorChip(
                label: 'surfaceContainer',
                color: colorScheme.surfaceContainer,
                onColor: colorScheme.onSurface),
            ColorChip(
                label: 'surfaceBright',
                color: colorScheme.surfaceBright,
                onColor: colorScheme.onSurface),
            ColorChip(
                label: 'surfaceDim',
                color: colorScheme.surfaceDim,
                onColor: colorScheme.onSurface),
            ColorChip(
                label: 'surface',
                color: colorScheme.surface,
                onColor: colorScheme.onSurface),
            ColorChip(
                label: 'onSurface',
                color: colorScheme.onSurface,
                onColor: colorScheme.surface),
          ],
        ),
        _divider,
        ColorGroup(
          children: [
            ColorChip(
                label: 'surfaceContainerHighest',
                color: colorScheme.surfaceContainerHighest,
                onColor: colorScheme.onSurface),
            ColorChip(
                label: 'surfaceContainerHigh',
                color: colorScheme.surfaceContainerHigh,
                onColor: colorScheme.onSurface),
            ColorChip(
                label: 'surfaceContainerLow',
                color: colorScheme.surfaceContainerLow,
                onColor: colorScheme.onSurface),
            ColorChip(
                label: 'surfaceContainerLowest',
                color: colorScheme.surfaceContainerLowest,
                onColor: colorScheme.onSurface),
          ],
        ),
        _divider,
        ColorGroup(
          children: [
            ColorChip(label: 'outline', color: colorScheme.outline),
            ColorChip(
              label: 'outlineVariant',
              color: colorScheme.outlineVariant,
            ),
            ColorChip(label: 'shadow', color: colorScheme.shadow),
            ColorChip(
                label: 'inverseSurface',
                color: colorScheme.inverseSurface,
                onColor: colorScheme.onInverseSurface),
            ColorChip(
                label: 'onInverseSurface',
                color: colorScheme.onInverseSurface,
                onColor: colorScheme.inverseSurface),
            ColorChip(
                label: 'inversePrimary',
                color: colorScheme.inversePrimary,
                onColor: colorScheme.primary),
          ],
        ),
      ],
    );
  }
}

class ColorGroup extends StatelessWidget {
  const ColorGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: children,
        ),
      ),
    );
  }
}

class ColorChip extends StatelessWidget {
  const ColorChip({
    super.key,
    required this.color,
    required this.label,
    this.onColor,
  });

  final Color color;
  final Color? onColor;
  final String label;

  static Color contrastColor(Color color) {
    final brightness = ThemeData.estimateBrightnessForColor(color);
    switch (brightness) {
      case Brightness.dark:
        return Colors.white;
      case Brightness.light:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color labelColor = onColor ?? contrastColor(color);

    return Container(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(child: Text(label, style: TextStyle(color: labelColor))),
          ],
        ),
      ),
    );
  }
}

class _DebugMaterialBannerTest extends StatefulWidget {
  const _DebugMaterialBannerTest();

  @override
  State<_DebugMaterialBannerTest> createState() =>
      _DebugMaterialBannerTestState();
}

class _DebugMaterialBannerTestState extends State<_DebugMaterialBannerTest> {
  final Set<int> selected = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MaterialBanner test"),
      ),
      body: Column(
        children: [
          if (selected.length >= 5)
            MaterialBanner(
              content: const Text("You have selected 5 items"),
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
              contentTextStyle: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
              actions: const [SizedBox()],
              dividerColor: Colors.transparent,
            ),
          Expanded(
            child: ListView.builder(
              itemCount: 20,
              itemBuilder: (context, index) {
                return CheckboxListTile(
                  title: Text("Item $index"),
                  value: selected.contains(index),
                  onChanged: (_) {
                    setState(() {
                      if (selected.contains(index)) {
                        selected.remove(index);
                      } else {
                        selected.add(index);
                      }
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DebugAddRandomWeightAlert extends StatefulWidget {
  const _DebugAddRandomWeightAlert();

  @override
  State<_DebugAddRandomWeightAlert> createState() =>
      __DebugAddRandomWeightAlertState();
}

class __DebugAddRandomWeightAlertState
    extends State<_DebugAddRandomWeightAlert> {
  double startingWeight = 80;
  int numberOfWeights = 5;
  int displacement = 0;

  @override
  Widget build(BuildContext context) {
    final meController = Get.find<MeController>();

    return AlertDialog(
      title: const Text("Add random weight"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Starting weight: $startingWeight"),
          Slider(
            value: startingWeight,
            onChanged: (value) => setState(() => startingWeight = value),
            min: 10.0,
            max: 500.0,
          ),
          Text("Number of weights: $numberOfWeights"),
          Slider(
            value: numberOfWeights.toDouble(),
            onChanged: (value) =>
                setState(() => numberOfWeights = value.toInt()),
            min: 1.0,
            max: 50.0,
            divisions: 49,
          ),
          Text("Displacement: $displacement day(s)"),
          Slider(
            value: displacement.toDouble(),
            onChanged: (value) => setState(() => displacement = value.toInt()),
            min: 0.0,
            max: 14.0,
            divisions: 14,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            final now = DateTime.now();
            final noise = noiseSeries(numberOfWeights);
            final weights = [
              for (var i = 0; i < numberOfWeights; i++)
                WeightMeasurement.generateID(
                  weight: startingWeight + noise[i] * 20,
                  time: now.subtract(Duration(
                    days: i * displacement,
                  )),
                  weightUnit: Weights.kg,
                ),
            ];
            for (final weight in weights) {
              meController.addWeightMeasurement(weight);
            }
            Navigator.of(context).pop();
          },
          child: const Text("Add"),
        ),
      ],
    );
  }
}
