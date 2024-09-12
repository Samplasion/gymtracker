import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/theme.dart';
import 'package:gymtracker/utils/utils.dart';
import 'package:gymtracker/view/utils/input_decoration.dart';

class WeightCalculator extends StatefulWidget {
  final double? startingWeight;
  final Weights weightUnit;

  const WeightCalculator({
    super.key,
    this.startingWeight,
    required this.weightUnit,
  });

  @override
  State<WeightCalculator> createState() => _WeightCalculatorState();
}

class _WeightCalculatorState extends State<WeightCalculator>
    with SingleTickerProviderStateMixin {
  late final _weightController = TextEditingController(
      text: widget.startingWeight != null
          ? stringifyDouble(widget.startingWeight!)
          : null);
  Bars selectedBarbell = Bars.normal;
  late final animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  late final selectedWeights = widget.weightUnit.weights.toSet();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: () {
        final format = widget.weightUnit;
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

        return Column(
          mainAxisSize: MainAxisSize.min,
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
            Flexible(
              fit: FlexFit.loose,
              child: ListView(
                shrinkWrap: true,
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
                      decoration: GymTrackerInputDecoration(
                        labelText: 'weightCalculator.weight.label'.t,
                      ),
                      onChanged: (value) {
                        setState(() {
                          var dbl = value.tryParseDouble();
                          _weightController.text = dbl == null
                              ? ""
                              : stringifyDouble(dbl.clamp(0, 10000));
                          if (value.endsWith(".")) {
                            _weightController.text += ".";
                          }
                        });
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Wrap(
                      children: [
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Wrap(
                      children: [
                        for (final barbell in Bars.values)
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: ChoiceChip(
                              label: Text.rich(TextSpan(children: [
                                TextSpan(text: "barbells.${barbell.name}".t),
                                TextSpan(
                                  text: () {
                                    switch (format) {
                                      case Weights.kg:
                                        return " (${stringifyDouble(barbell.weightKg)} kg)";
                                      case Weights.lb:
                                        return " (${stringifyDouble(barbell.weightLb)} lb)";
                                    }
                                  }(),
                                  style: Theme.of(context).textTheme.bodySmall,
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Barbell(
                        barbellWeight: barbellWeight,
                        weights: weights,
                        format: format,
                        dense: weights.length >= 4,
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
                          icon: const Icon(GymTrackerIcons.done),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          ],
        );
      }(),
    );
  }
}

class Barbell extends StatelessWidget {
  const Barbell({
    super.key,
    required this.barbellWeight,
    required this.weights,
    required this.format,
    required this.dense,
  });

  final double barbellWeight;
  final List<double> weights;
  final Weights format;
  final bool dense;

  List<(double, int)> get weightCounts {
    if (!dense) {
      return weights.map((e) => (e, 1)).toList();
    }

    final result = <(double, int)>[];
    for (final weight in weights) {
      if (result.isNotEmpty && result.last.$1 == weight) {
        result[result.length - 1] = (weight, result.last.$2 + 1);
      } else {
        result.add((weight, 1));
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    const interWeightSpacing = 5.0;

    final weightCounts = this.weightCounts;
    return Row(
      children: [
        const SizedBox(width: 8),
        Container(
          height: 20,
          width: 12,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(8),
              right: Radius.circular(3),
            ),
          ),
        ),
        const SizedBox(width: 4),
        for (final (weight, count) in weightCounts.reversed) ...[
          BarbellWeightPlate(weight: weight, count: count, format: format),
          const SizedBox(width: interWeightSpacing),
        ],
        const SizedBox(width: 1),
        Container(
          height: 28,
          width: 12,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(3),
              right: Radius.circular(5),
            ),
          ),
        ),
        Container(
          height: 20,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
          ),
          child: Center(
            child: Text(
              stringifyDouble(barbellWeight),
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
            ),
          ),
        ),
        Container(
          height: 28,
          width: 12,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(5),
              right: Radius.circular(3),
            ),
          ),
        ),
        const SizedBox(width: 1),
        for (final (weight, count) in weightCounts) ...[
          const SizedBox(width: interWeightSpacing),
          BarbellWeightPlate(weight: weight, count: count, format: format),
        ],
        const SizedBox(width: 4),
        Container(
          height: 20,
          width: 12,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(3),
              right: Radius.circular(8),
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

class BarbellWeightPlate extends StatelessWidget {
  const BarbellWeightPlate({
    super.key,
    required this.weight,
    required this.count,
    required this.format,
  });

  final double weight;
  final int count;
  final Weights format;

  @override
  Widget build(BuildContext context) {
    return Badge(
      label: Text("x$count"),
      offset: const Offset(-3, -6),
      backgroundColor: context.colorScheme.quinary,
      textColor: context.colorScheme.onQuinary,
      isLabelVisible: count > 1,
      child: Container(
        height:
            mapRange(weight, format.weights.min, format.weights.max, 32, 64),
        constraints: const BoxConstraints(
          maxWidth: 40,
        ),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.tertiaryContainer,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.onTertiaryContainer,
            width: 0.5,
          ),
        ),
        child: Center(
          child: Text(
            stringifyDouble(weight),
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Theme.of(context).colorScheme.onTertiaryContainer,
                ),
          ),
        ),
      ),
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
    globalLogger.d("[calculateBarbellWeights] $perSide >= $weight");
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
