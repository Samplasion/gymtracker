import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/me_controller.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/model/measurements.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/utils/constants.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/utils/utils.dart';
import 'package:gymtracker/view/me/calendar.dart';
import 'package:gymtracker/view/utils/date_field.dart';
import 'package:gymtracker/view/utils/section_title.dart';
import 'package:gymtracker/view/utils/speed_dial.dart';
import 'package:intl/intl.dart';

class MeView extends GetView<MeController> {
  const MeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text("me.title".t),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SafeArea(
                    top: false,
                    bottom: false,
                    child: SpeedDial(
                      crossAxisCountBuilder: (breakpoint) =>
                          switch (breakpoint) {
                        Breakpoints.xxs => 1,
                        _ => 2,
                      },
                      buttons: [
                        SpeedDialButton(
                          icon: const Icon(Icons.calendar_month_rounded),
                          text: Text("me.calendar.label".t),
                          onTap: () {
                            Go.to(() => const MeCalendarPage());
                          },
                        ),
                        SpeedDialButton(
                          icon: const Icon(Icons.query_stats_rounded),
                          text: Text("me.stats.label".t),
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SafeArea(
                    top: false,
                    bottom: false,
                    child: SectionTitle("me.weight.label".t),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: WeightCard(),
                ),
                Obx(
                  () => ListTile(
                    title: Text("me.weight.allData.label".t),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    enabled: controller.weightMeasurements.isNotEmpty,
                    onTap: () {
                      Go.to(() => const WeightMeasurementDataPage());
                    },
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

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
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Obx(
              () {
                final latestMeasurement = controller.latestWeightMeasurement;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      latestMeasurement == null
                          ? "me.weight.none".t
                          : "exerciseList.fields.weight".trParams({
                              "weight": stringifyDouble(
                                  latestMeasurement.convertedWeight),
                              "unit":
                                  "units.${settingsController.weightUnit.value!.name}"
                                      .t,
                            }),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    Text(
                      latestMeasurement == null
                          ? "me.weight.measured.never".t
                          : "me.weight.measured.date".tParams({
                              "date":
                                  DateFormat.yMMMMd(context.locale.languageCode)
                                      .format(latestMeasurement.time),
                            }),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () async {
                        var measurement =
                            await Go.showBottomModalScreen<WeightMeasurement>(
                                (context, controller) {
                          return WeightMeasurementAddSheet(
                              controller: controller);
                        });

                        if (measurement != null) {
                          controller.addWeightMeasurement(measurement);
                        }
                      },
                      child: Text("me.weight.addMeasurement".t),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class WeightMeasurementDataPage extends StatelessWidget {
  const WeightMeasurementDataPage({super.key});

  MeController get controller => Get.find<MeController>();

  @override
  Widget build(BuildContext context) {
    final measurements = [...controller.weightMeasurements.reversed];
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text("me.allData.label".t),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          final measurement = measurements[index];
          return Slidable(
            key: ValueKey(measurement.id),
            endActionPane: ActionPane(
              extentRatio: 1 / 3,
              dragDismissible: false,
              motion: const BehindMotion(),
              children: [
                SlidableAction(
                  onPressed: (_) {
                    controller.removeWeightMeasurement(measurement);
                    Go.snack(
                      "me.allData.removed.text".t,
                      action: SnackBarAction(
                        label: "actions.undo".t,
                        onPressed: () {
                          controller.addWeightMeasurement(measurement);
                        },
                      ),
                    );
                  },
                  backgroundColor: scheme.error,
                  foregroundColor: scheme.onError,
                  icon: Icons.delete_forever_rounded,
                  label: 'actions.remove'.t,
                ),
              ],
            ),
            child: ListTile(
              title: Text("exerciseList.fields.weight".trParams({
                "weight": stringifyDouble(measurement.convertedWeight),
                "unit": "units.${settingsController.weightUnit.value!.name}".t,
              })),
              subtitle: Text(DateFormat.MMMd(context.locale.languageCode)
                  .add_Hm()
                  .format(measurement.time)),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                Go.to(() => WeightMeasurementDataDetailsPage(
                      measurementID: measurement.id,
                    ));
              },
            ),
          );
        },
        itemCount: controller.weightMeasurements.length,
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
      appBar: AppBar(
        title: Text("me.weight.label".t),
      ),
      body: Obx(() {
        debugPrint((
          measurementID,
          [...controller.service.weightMeasurementsBox.keys]
        ).toString());
        final measurement = controller.getWeightMeasurementByID(measurementID)!;
        debugPrint("$measurement");
        return ListView(
          children: [
            ListTile(
              title: Text("me.addWeight.weight.label".t),
              subtitle: Text(
                "exerciseList.fields.weight".trParams({
                  "weight": stringifyDouble(measurement.convertedWeight),
                  "unit":
                      "units.${settingsController.weightUnit.value!.name}".t,
                }),
              ),
            ),
            ListTile(
              title: Text("me.addWeight.time.label".t),
              subtitle: Text(
                DateFormat.yMMMMEEEEd(context.locale.languageCode)
                    .add_Hms()
                    .format(measurement.time),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text("actions.edit".t),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () async {
                var newMeasurement =
                    await Go.showBottomModalScreen<WeightMeasurement>(
                        (context, controller) {
                  return WeightMeasurementAddSheet(
                    controller: controller,
                    base: measurement,
                  );
                });

                if (newMeasurement != null) {
                  controller.addWeightMeasurement(newMeasurement);
                }
              },
            ),
            ListTile(
              iconColor: scheme.error,
              leading: const Icon(Icons.delete_forever),
              title: Text(
                "actions.remove".t,
                style: TextStyle(color: scheme.error),
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                Get.back();

                SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                  Go.snack(
                    "me.allData.removed.text".t,
                    action: SnackBarAction(
                      label: "actions.undo".t,
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

class WeightMeasurementAddSheet extends StatefulWidget {
  final WeightMeasurement? base;
  final ScrollController? controller;

  const WeightMeasurementAddSheet({
    this.controller,
    this.base,
    super.key,
  });

  @override
  State<WeightMeasurementAddSheet> createState() =>
      _WeightMeasurementAddSheet();
}

class _WeightMeasurementAddSheet extends State<WeightMeasurementAddSheet> {
  DateTime time = DateTime.now();
  late var weightController = TextEditingController(text: "0");
  Weights weightUnit = settingsController.weightUnit()!;
  final FocusNode _weightFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.base != null) {
      time = widget.base!.time;
      weightController.text = stringifyDouble(widget.base!.weight);
      weightUnit = widget.base!.weightUnit;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("me.weight.label".t),
        actions: [
          IconButton(onPressed: submit, icon: const Icon(Icons.done)),
        ],
      ),
      body: ListView(
        controller: widget.controller,
        padding: const EdgeInsets.all(16),
        children: [
          DateField(
            decoration: _decoration("me.addWeight.time.label".t),
            date: time,
            onSelect: (date) => setState(() => time = date),
            firstDate: DateTime.fromMillisecondsSinceEpoch(0),
            lastDate: DateTime.now()
                .add(const Duration(days: 1))
                .copyWith(hour: 0, minute: 0, second: 0),
          ),
          const SizedBox(height: 16),
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
            decoration: InputDecoration(
              isDense: true,
              border: const OutlineInputBorder(),
              labelText: "me.addWeight.weight.label".t,
              suffix: Text("units.${weightUnit.name}".t),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<Weights>(
            decoration: _decoration("me.addWeight.weightUnit.label".t),
            items: [
              for (final weightUnit in Weights.values)
                DropdownMenuItem(
                  value: weightUnit,
                  child: Text("weightUnits.${weightUnit.name}".t),
                ),
            ],
            onChanged: (v) => setState(() => weightUnit = v!),
            value: weightUnit,
          ),
        ],
      ),
    );
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      isDense: true,
      border: const OutlineInputBorder(),
      labelText: label,
    );
  }

  void submit() {
    final weight = weightController.text.tryParseDouble();
    if (weight == null) {
      Go.snack("me.addWeight.errors.invalidWeight".t);
      return;
    }
    Navigator.of(context).pop(
      WeightMeasurement(
        weight: weight,
        time: time,
        weightUnit: weightUnit,
        id: widget.base?.id,
      ),
    );
  }
}
