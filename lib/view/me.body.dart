part of 'me.dart';

class WeightCard extends StatelessWidget {
  const WeightCard({super.key});

  MeController get controller => Get.find<MeController>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Card(
          clipBehavior: Clip.hardEdge,
          margin: EdgeInsets.zero,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Obx(() {
                if (controller.weightMeasurements.length < 2) {
                  return const SizedBox.shrink();
                }
                return Positioned.fill(
                  child: WeightChart(
                    weights: controller.weightMeasurements
                        .map(
                          (element) => Weights.convert(
                            value: element.weight,
                            from: element.weightUnit,
                            to: settingsController.weightUnit.value,
                          ),
                        )
                        .toList(),
                  ),
                );
              }),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        context.cardColor().withAlpha((0.99 * 255).round()),
                        context.cardColor().withAlpha((0.8 * 255).round()),
                        context.cardColor().withAlpha((0.5 * 255).round()),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Obx(() {
                  final latestMeasurement = controller.latestWeightMeasurement;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        latestMeasurement == null
                            ? context.t.me.weight.none
                            : latestMeasurement.convertedWeight
                                  .getUserFacingWeight(context.t),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      Text(
                        latestMeasurement == null
                            ? context.t.me.weight.measured.never
                            : context.t.me.weight.measured.date(
                                date: DateFormat.yMMMMd(
                                  context.locale.languageCode,
                                ).format(latestMeasurement.time),
                              ),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () async {
                          var measurement =
                              await Go.showBottomModalScreen<
                                (WeightMeasurement, List<BodyMeasurement>)
                              >((context, controller) {
                                return WeightMeasurementAddSheet(
                                  controller: controller,
                                );
                              });

                          if (measurement != null) {
                            controller.addWeightMeasurement(measurement.$1);
                            for (final body in measurement.$2) {
                              controller.addBodyMeasurement(body);
                            }
                          }
                        },
                        child: Text(context.t.me.weight.addMeasurement),
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WeightMeasurementDataPage extends StatefulWidget {
  const WeightMeasurementDataPage({super.key});

  @override
  State<WeightMeasurementDataPage> createState() =>
      _WeightMeasurementDataPageState();
}

class _WeightMeasurementDataPageState extends State<WeightMeasurementDataPage> {
  MeController get controller => Get.find<MeController>();
  BodyMeasurementPart? selected;

  Widget get chart {
    final predictedWeight = controller.predictedWeight.valueOrNull;
    return Crossfade(
      firstChild: const SizedBox.shrink(),
      secondChild: Padding(
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          top: false,
          bottom: false,
          child: Card(
            clipBehavior: Clip.hardEdge,
            margin: EdgeInsets.zero,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (predictedWeight != null) ...[
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: context.colorScheme.quaternaryContainer,
                      foregroundColor:
                          context.colorScheme.onQuaternaryContainer,
                      child: Icon(() {
                        final diff =
                            predictedWeight.weight -
                            controller.latestWeightMeasurement!.weight;
                        final normalized = (diff * 100).truncate();
                        if (normalized > 10) {
                          return GTIcons.weight_up;
                        } else if (normalized < -10) {
                          return GTIcons.weight_down;
                        } else {
                          return GTIcons.weight_flat;
                        }
                      }()),
                    ),
                    title: Text(context.t.me.allData.predictedWeight.label),
                    subtitle: Text(
                      "${predictedWeight.weight.getUserFacingWeight(context.t)} (${DateFormat.yMd(context.locale.languageCode).format(predictedWeight.time)})",
                    ),
                    onTap: () {
                      Go.dialog(
                        "me.allData.predictedWeight.dialog.title",
                        "me.allData.predictedWeight.dialog.text",
                      );
                    },
                    trailing: const Icon(GTIcons.info),
                  ),
                  const Divider(),
                ],
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: WeightChartTimeSeries(
                    weights: controller.weightMeasurements,
                    bodyMeasurements: controller.bodyMeasurements,
                    predictedWeight: predictedWeight,
                    onSelectCategory: (part) {
                      setState(() {
                        selected = part;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      showSecond: controller.weightMeasurements.length > 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.me.allData.label),
        actions: [
          IconButton(
            icon: const Icon(GTIcons.add_measurement),
            onPressed: () async {
              var measurement =
                  await Go.showBottomModalScreen<
                    (WeightMeasurement, List<BodyMeasurement>)
                  >((context, controller) {
                    return WeightMeasurementAddSheet(controller: controller);
                  });

              if (measurement != null) {
                controller.addWeightMeasurement(measurement.$1);
                for (final body in measurement.$2) {
                  controller.addBodyMeasurement(body);
                }
              }
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: controller.bodyMeasurements.stream,
        initialData: controller.bodyMeasurements,
        builder: (context, snapshot) {
          final allBodyMeasurements = snapshot.data!.reversed;
          Map<BodyMeasurementPart, List<BodyMeasurement>> bodyMeasurements = {
            for (final part in BodyMeasurementPart.values)
              part: allBodyMeasurements
                  .where((element) => element.type == part)
                  .toList(),
          };

          return StreamBuilder(
            stream: controller.weightMeasurements.stream,
            initialData: controller.weightMeasurements,
            builder: (context, snapshot) {
              final weightMeasurements = [...snapshot.data!.reversed];

              if (weightMeasurements.isEmpty) {
                return Center(
                  child: Text(
                    context.t.me.allData.none,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                );
              }

              final selectedLength = selected == null
                  ? weightMeasurements.length
                  : bodyMeasurements[selected]!.length;
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: chart),
                  SliverList.builder(
                    itemBuilder: (context, index) {
                      final GenericMeasurement measurement =
                          (selected == null
                                  ? weightMeasurements[index]
                                  : bodyMeasurements[selected]![index])
                              as GenericMeasurement;
                      return Slidable(
                        key: ValueKey(measurement.id),
                        endActionPane: ActionPane(
                          extentRatio: 1 / 3,
                          dragDismissible: false,
                          motion: const BehindMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (_) {
                                if (selected == null) {
                                  controller.removeWeightMeasurement(
                                    measurement as WeightMeasurement,
                                  );
                                } else {
                                  controller.removeBodyMeasurement(
                                    measurement as BodyMeasurement,
                                  );
                                }
                                Go.snack(
                                  context.t.me.allData.removed.text,
                                  action: SnackBarAction(
                                    label: context.t.actions.undo,
                                    onPressed: () {
                                      if (selected == null) {
                                        controller.addWeightMeasurement(
                                          measurement as WeightMeasurement,
                                        );
                                      } else {
                                        controller.addBodyMeasurement(
                                          measurement as BodyMeasurement,
                                        );
                                      }
                                    },
                                  ),
                                  assertive: true,
                                );
                              },
                              backgroundColor: scheme.error,
                              foregroundColor: scheme.onError,
                              icon: GTIcons.delete_forever,
                              label: context.t.actions.remove,
                            ),
                          ],
                        ),
                        child: selected == null
                            ? ListTile(
                                title: Text(
                                  (measurement as WeightMeasurement)
                                      .convertedWeight
                                      .getUserFacingWeight(context.t),
                                ),
                                subtitle: Text(
                                  DateFormat.MMMd(
                                    context.locale.languageCode,
                                  ).add_Hm().format(measurement.time),
                                ),
                                trailing: const Icon(GTIcons.lt_chevron),
                                onTap: () {
                                  Go.to(
                                    () => WeightMeasurementDataDetailsPage(
                                      measurementID: measurement.id,
                                    ),
                                  );
                                },
                              )
                            : ListTile(
                                title: Text(
                                  "${stringifyDouble(measurement.value, decimalSeparator: NumberFormat(context.locale.languageCode).symbols.DECIMAL_SEP)} ${selected!.unit}",
                                ),
                                subtitle: Text(
                                  DateFormat.MMMd(
                                    context.locale.languageCode,
                                  ).add_Hm().format(measurement.time),
                                ),
                                trailing: const Icon(GTIcons.lt_chevron),
                                onTap: () {
                                  Go.to(
                                    () => BodyMeasurementDataDetailsPage(
                                      measurementID: measurement.id,
                                    ),
                                  );
                                },
                              ),
                      );
                    },
                    itemCount: selectedLength,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class WeightMeasurementDataDetailsPage extends StatelessWidget {
  final String measurementID;

  const WeightMeasurementDataDetailsPage({
    required this.measurementID,
    super.key,
  });

  MeController get controller => Get.find<MeController>();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(context.t.me.weight.label)),
      body: Obx(() {
        final measurement = controller.getWeightMeasurementByID(measurementID);
        if (measurement == null) return const SizedBox.shrink();
        return ListView(
          children: [
            ListTile(
              title: Text(context.t.me.addWeight.weight.label),
              subtitle: Text(
                measurement.convertedWeight.getUserFacingWeight(context.t),
              ),
            ),
            ListTile(
              title: Text(context.t.me.addWeight.time.label),
              subtitle: Text(
                DateFormat.yMMMMEEEEd(
                  context.locale.languageCode,
                ).add_Hms().format(measurement.time),
              ),
            ),
            ListTile(
              leading: const Icon(GTIcons.edit),
              title: Text(context.t.actions.edit),
              trailing: const Icon(GTIcons.lt_chevron),
              onTap: () async {
                var newMeasurement =
                    await Go.showBottomModalScreen<
                      (WeightMeasurement, List<BodyMeasurement>?)
                    >((context, controller) {
                      return WeightMeasurementAddSheet(
                        controller: controller,
                        baseWeight: measurement,
                      );
                    });

                if (newMeasurement != null) {
                  controller.addWeightMeasurement(newMeasurement.$1);
                }
              },
            ),
            ListTile(
              iconColor: scheme.error,
              leading: const Icon(GTIcons.delete_forever),
              title: Text(
                context.t.actions.remove,
                style: TextStyle(color: scheme.error),
              ),
              trailing: const Icon(GTIcons.lt_chevron),
              onTap: () {
                Get.back();

                SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                  Go.snack(
                    context.t.me.allData.removed.text,
                    action: SnackBarAction(
                      label: context.t.actions.undo,
                      onPressed: () {
                        controller.addWeightMeasurement(measurement);
                      },
                    ),
                  );
                  controller.removeWeightMeasurement(measurement);
                });
              },
            ),
          ],
        );
      }),
    );
  }
}

class BodyMeasurementDataDetailsPage extends StatelessWidget {
  final String measurementID;

  const BodyMeasurementDataDetailsPage({
    required this.measurementID,
    super.key,
  });

  MeController get controller => Get.find<MeController>();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(context.t.me.bodyMeasurements)),
      body: StreamBuilder(
        stream: controller.bodyMeasurements.stream,
        builder: (context, _) {
          final measurement = controller.getBodyMeasurementByID(measurementID);
          if (measurement == null) return const SizedBox.shrink();
          final part = measurement.type;
          return ListView(
            children: [
              ListTile(
                title: Text(context.t.bodyMeasurement[part.name].label),
                subtitle: Text(
                  "${stringifyDouble(measurement.value, decimalSeparator: NumberFormat(context.locale.languageCode).symbols.DECIMAL_SEP)} ${part.unit}",
                ),
              ),
              ListTile(
                title: Text(context.t.me.addWeight.time.label),
                subtitle: Text(
                  DateFormat.yMMMMEEEEd(
                    context.locale.languageCode,
                  ).add_Hms().format(measurement.time),
                ),
              ),
              ListTile(
                leading: const Icon(GTIcons.edit),
                title: Text(context.t.actions.edit),
                trailing: const Icon(GTIcons.lt_chevron),
                onTap: () async {
                  var newMeasurement =
                      await Go.showBottomModalScreen<
                        (WeightMeasurement?, List<BodyMeasurement>)
                      >((context, controller) {
                        return WeightMeasurementAddSheet(
                          controller: controller,
                          baseBody: measurement,
                        );
                      });

                  if (newMeasurement != null) {
                    controller.addBodyMeasurement(newMeasurement.$2.single);
                  }
                },
              ),
              ListTile(
                iconColor: scheme.error,
                leading: const Icon(GTIcons.delete_forever),
                title: Text(
                  context.t.actions.remove,
                  style: TextStyle(color: scheme.error),
                ),
                trailing: const Icon(GTIcons.lt_chevron),
                onTap: () {
                  Get.back();

                  SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                    Go.snack(
                      context.t.me.allData.removed.text,
                      action: SnackBarAction(
                        label: context.t.actions.undo,
                        onPressed: () {
                          controller.addBodyMeasurement(measurement);
                        },
                      ),
                    );
                    controller.removeBodyMeasurement(measurement);
                  });
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class WeightMeasurementAddSheet extends StatefulWidget {
  final WeightMeasurement? baseWeight;
  final BodyMeasurement? baseBody;
  final ScrollController? controller;

  const WeightMeasurementAddSheet({
    this.controller,
    this.baseWeight,
    this.baseBody,
    super.key,
  }) : assert(
         baseWeight == null && baseBody == null ||
             baseWeight != null && baseBody == null ||
             baseBody != null && baseWeight == null,
         "Only one base allowed",
       );

  @override
  State<WeightMeasurementAddSheet> createState() =>
      _WeightMeasurementAddSheet();
}

enum _Mode { add, edit }

class _WeightMeasurementAddSheet
    extends ControlledState<WeightMeasurementAddSheet, MeController> {
  DateTime time = DateTime.now();
  late final weightController = TextEditingController(text: "0");
  Weights weightUnit = settingsController.weightUnit();
  final FocusNode _weightFocusNode = FocusNode();
  late final _Mode mode = widget.baseWeight == null && widget.baseBody == null
      ? _Mode.add
      : _Mode.edit;

  late final Map<BodyMeasurementPart, TextEditingController> _bodyControllers =
      {
        for (final part in BodyMeasurementPart.values)
          part: TextEditingController(text: ""),
      };

  @override
  void initState() {
    super.initState();
    if (widget.baseWeight != null) {
      time = widget.baseWeight!.time;
      weightController.text = stringifyDouble(widget.baseWeight!.weight);
      weightUnit = widget.baseWeight!.weightUnit;
    } else if (widget.baseBody != null) {
      time = widget.baseBody!.time;
      _bodyControllers[widget.baseBody!.type]!.text = stringifyDouble(
        widget.baseBody!.value,
      );
    } else {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {
          weightController.text = stringifyDouble(
            controller.latestWeightMeasurement?.weight ?? 0,
            decimalSeparator: NumberFormat(
              context.locale.languageCode,
            ).symbols.DECIMAL_SEP,
          );
        });
      });
    }
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _weightFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    for (final controller in _bodyControllers.values) {
      controller.dispose();
    }
    weightController.dispose();
    _weightFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.me.bodyMeasurements),
        actions: [
          IconButton(onPressed: submit, icon: const Icon(GTIcons.done)),
        ],
      ),
      body: SafeArea(
        child: ListView(
          controller: widget.controller,
          padding: const EdgeInsets.all(16),
          children: [
            DateField(
              decoration: _decoration(context.t.me.addWeight.time.label),
              date: time,
              onSelect: (date) => setState(() => time = date),
              firstDate: DateTime.fromMillisecondsSinceEpoch(0),
              lastDate: DateTime.now()
                  .add(const Duration(days: 1))
                  .copyWith(hour: 0, minute: 0, second: 0),
            ),
            const SizedBox(height: 16),
            if (mode == _Mode.add || widget.baseWeight != null) ...[
              TextField(
                focusNode: _weightFocusNode,
                controller: weightController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp("[0123456789.,]")),
                ],
                decoration: GymTrackerInputDecoration(
                  labelText: context.t.me.addWeight.weight.label,
                  suffix: Text(context.t.units[weightUnit.name] ?? "UNKNOWN"),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Weights>(
                decoration: _decoration(
                  context.t.me.addWeight.weightUnit.label,
                ),
                items: [
                  for (final weightUnit in Weights.values)
                    DropdownMenuItem(
                      value: weightUnit,
                      child: Text(
                        context.t.weightUnits[weightUnit.name] ?? "UNKNOWN",
                      ),
                    ),
                ],
                onChanged: (v) => setState(() => weightUnit = v!),
                value: weightUnit,
              ),
              const SizedBox(height: 16),
            ],
            for (final part in BodyMeasurementPart.values)
              if (mode == _Mode.add || widget.baseBody?.type == part) ...[
                TextField(
                  controller: _bodyControllers[part],
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp("[0123456789.,]")),
                  ],
                  decoration: GymTrackerInputDecoration(
                    labelText: context.t.bodyMeasurement[part.name].label,
                    suffix: Text(part.unit),
                  ),
                ),
                const SizedBox(height: 16),
              ],
          ],
        ),
      ),
    );
  }

  InputDecoration _decoration(String label) {
    return GymTrackerInputDecoration(labelText: label);
  }

  void submit() {
    double? weight;
    if (mode == _Mode.add || widget.baseWeight != null) {
      weight = weightController.text.tryParseDouble();
      if (weight == null) {
        Go.snack(context.t.me.addWeight.errors.invalidWeight);
        return;
      }
    }
    if (mode == _Mode.add) {
      Navigator.of(context).pop((
        WeightMeasurement.generateID(
          weight: weight!,
          time: time,
          weightUnit: weightUnit,
        ),
        [
          for (final part in BodyMeasurementPart.values)
            if (_bodyControllers[part] != null &&
                _bodyControllers[part]!.text.tryParseDouble() != null)
              BodyMeasurement.generateID(
                time: time,
                type: part,
                value: _bodyControllers[part]!.text.parseDouble(),
              ),
        ],
      ));
    } else {
      Navigator.of(context).pop((
        widget.baseWeight == null
            ? null
            : WeightMeasurement(
                id: widget.baseWeight!.id,
                weight: weight!,
                time: time,
                weightUnit: weightUnit,
              ),
        <BodyMeasurement>[
          if (widget.baseBody != null)
            BodyMeasurement(
              id: widget.baseBody!.id,
              time: time,
              type: widget.baseBody!.type,
              value: _bodyControllers[widget.baseBody!.type]!.text
                  .parseDouble(),
            ),
        ],
      ));
    }
  }
}
