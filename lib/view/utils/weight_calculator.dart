import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/utils.dart';

class WeightCalculator extends StatefulWidget {
  const WeightCalculator({super.key});

  @override
  State<WeightCalculator> createState() => _WeightCalculatorState();
}

class _WeightCalculatorState extends State<WeightCalculator>
    with SingleTickerProviderStateMixin {
  final _weightController = TextEditingController();
  Bars selectedBarbell = Bars.normal;
  late final animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  late final selectedWeights =
      Get.find<SettingsController>().weightUnit()!.weights.toSet();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();
    return BottomSheet(
      animationController: animationController,
      onClosing: () {},
      builder: (context) {
        return Obx(
          () {
            final format = controller.weightUnit()!;
            final double barbellWeight;
            switch (format) {
              case Weights.kg:
                barbellWeight = selectedBarbell.weightKg;
                break;
              case Weights.lb:
                barbellWeight = selectedBarbell.weightLb;
                break;
            }
            final weights = calculateBarbellWeights(
              double.tryParse(_weightController.text.replaceAll(",", ".")) ?? 0,
              weights: selectedWeights.toList(),
              barbellWeight: barbellWeight,
            );

            return SizedBox(
              height: 420,
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    height: kToolbarHeight,
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(
                      "ongoingWorkout.weightCalculator".t,
                      style: context.textTheme.titleLarge,
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: TextField(
                            controller: _weightController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                              signed: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(
                                  r'^\d+[\.,]?\d*',
                                ),
                              )
                            ],
                            decoration: InputDecoration(
                              labelText: 'weightCalculator.weight.label'.t,
                              border: const OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            "weightCalculator.weights.label".t,
                            style: context.textTheme.bodyMedium,
                          ),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              const SizedBox(width: 8),
                              for (final weight in format.weights.reversed)
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: FilterChip(
                                    label: Text(stringifyDouble(weight)),
                                    selected: selectedWeights.contains(weight),
                                    onSelected: (selected) {
                                      setState(() {
                                        if (selected) {
                                          selectedWeights.add(weight);
                                        } else {
                                          selectedWeights.remove(weight);
                                        }
                                      });
                                    },
                                  ),
                                ),
                              const SizedBox(width: 8),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            "weightCalculator.barbells.label".t,
                            style: context.textTheme.bodyMedium,
                          ),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              const SizedBox(width: 8),
                              for (final barbell in Bars.values)
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: ChoiceChip(
                                    label: Text.rich(TextSpan(children: [
                                      TextSpan(
                                          text: "barbells.${barbell.name}".t),
                                      TextSpan(
                                        text: () {
                                          switch (format) {
                                            case Weights.kg:
                                              return " (${stringifyDouble(barbell.weightKg)} kg)";
                                            case Weights.lb:
                                              return " (${stringifyDouble(barbell.weightLb)} lb)";
                                          }
                                        }(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ])),
                                    selected: selectedBarbell == barbell,
                                    onSelected: (selected) {
                                      setState(() {
                                        selectedBarbell = barbell;
                                      });
                                    },
                                  ),
                                ),
                              const SizedBox(width: 8),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                const SizedBox(width: 8),
                                Container(
                                  height: 20,
                                  padding: const EdgeInsets.only(
                                      left: 16, right: 12),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    borderRadius: const BorderRadius.horizontal(
                                      left: Radius.circular(8),
                                      // right: Radius.circular(3),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      stringifyDouble(barbellWeight),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSecondary,
                                          ),
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 28,
                                  width: 12,
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    borderRadius: const BorderRadius.horizontal(
                                      left: Radius.circular(5),
                                      right: Radius.circular(3),
                                    ),
                                  ),
                                ),
                                for (final weight in weights) ...[
                                  const SizedBox(width: 2),
                                  Container(
                                    height: mapRange(weight, format.weights.min,
                                        format.weights.max, 32, 64),
                                    constraints: const BoxConstraints(
                                      maxWidth: 40,
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiary,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        stringifyDouble(weight),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onTertiary,
                                            ),
                                      ),
                                    ),
                                  ),
                                ],
                                const SizedBox(width: 2),
                                Container(
                                  height: 20,
                                  width: 12,
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    borderRadius: const BorderRadius.horizontal(
                                      left: Radius.circular(3),
                                      right: Radius.circular(8),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 8,
                            bottom: 8,
                            left: 16,
                            right: 16,
                          ),
                          child: Wrap(
                            alignment: WrapAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                label: Text("general.dialogs.actions.ok".t),
                                icon: const Icon(Icons.done),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }
}

List<double> calculateBarbellWeights(double weight,
    {required List<double> weights, required double barbellWeight}) {
  final applicableWeight = weight - barbellWeight;
  final result = <double>[];
  double perSide = applicableWeight / 2;
  final sortedWeights = [...weights]..sort((a, b) => b.compareTo(a));

  for (final weight in sortedWeights) {
    // print("$perSide >= $weight");
    if (perSide >= weight) {
      final count = perSide ~/ weight;
      for (var i = 0; i < count; i++) {
        result.add(weight);
        perSide -= weight;
      }
    }
  }

  if (perSide > 0) {
    result.add(perSide);
  }

  return result;
}
