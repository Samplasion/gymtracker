import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/exercises_controller.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/components/equipment_icon.dart';
import 'package:gymtracker/view/utils/input_decoration.dart';

class ExerciseCreator extends StatefulWidget {
  final Exercise? base;
  final ScrollController? scrollController;
  final bool shouldChangeParameters;

  const ExerciseCreator({
    required this.base,
    this.scrollController,
    this.shouldChangeParameters = true,
    super.key,
  });

  @override
  State<ExerciseCreator> createState() => _ExerciseCreatorState();
}

class _ExerciseCreatorState extends State<ExerciseCreator> {
  final formKey = GlobalKey<FormState>();
  late final titleController = TextEditingController(text: widget.base?.name);

  late GTSetParameters params =
      widget.base?.parameters ?? GTSetParameters.repsWeight;
  late GTMuscleGroup? primaryGroup = widget.base?.primaryMuscleGroup;
  late Set<GTMuscleGroup> otherGroups =
      widget.base?.secondaryMuscleGroups ?? {};
  late GTGymEquipment equipment =
      widget.base?.gymEquipment ?? GTGymEquipment.none;

  ExercisesController get controller => Get.put(ExercisesController());

  @override
  Widget build(BuildContext context) {
    final muscleGroups = GTMuscleGroup.values.toList();
    muscleGroups.sort((a, b) =>
        "muscleGroups.${a.name}".t.compareTo("muscleGroups.${b.name}".t));
    final equipments = GTGymEquipment.values.toList();

    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: Text(() {
            if (widget.base == null) {
              return "exercise.editor.create.title".t;
            } else {
              return "exercise.editor.edit.title".t;
            }
          }()),
          leading: const CloseButton(),
          bottom: const PreferredSize(
            preferredSize: Size(0, 1),
            child: Divider(height: 1),
          ),
          actions: [
            IconButton(
              key: const Key("done"),
              icon: const Icon(GTIcons.done),
              onPressed: _submit,
            )
          ],
        ),
        body: Form(
          key: formKey,
          child: ListView(
            controller: widget.scrollController,
            children: [
              ...[
                const SizedBox(height: 8),
                TextFormField(
                  controller: titleController,
                  decoration:
                      _decoration("exercise.editor.fields.title.label".t),
                  validator: (string) {
                    if (string == null || string.isEmpty) {
                      return "exercise.editor.fields.title.errors.empty".t;
                    }
                    if (widget.base == null &&
                        !controller.isNameValid(string)) {
                      return "exercise.editor.fields.title.errors.invalid".t;
                    }
                    return null;
                  },
                ),
                GestureDetector(
                  onTap: widget.shouldChangeParameters
                      ? null
                      : () {
                          Go.dialog(
                            "exercise.editor.cannotChangeParameters.title",
                            "exercise.editor.cannotChangeParameters.text",
                          );
                        },
                  child: DropdownButtonFormField(
                    decoration: _decoration(
                        "exercise.editor.fields.parameters.label".t),
                    items: [
                      for (final param in GTSetParameters.values)
                        if (!param.hidden)
                          DropdownMenuItem(
                            value: param,
                            child: Text(
                                "exercise.editor.fields.parameters.values.${param.name}"
                                    .t),
                          ),
                    ],
                    onChanged: widget.shouldChangeParameters
                        ? (GTSetParameters? v) => setState(() => params = v!)
                        : null,
                    validator: (value) {
                      if (value == null) {
                        return "exercise.editor.fields.parameters.errors.empty"
                            .t;
                      }
                      return null;
                    },
                    value: params,
                  ),
                ),
                DropdownButtonFormField<GTGymEquipment>(
                  decoration: _decoration(
                      "exercise.editor.fields.gymEquipment.label".t),
                  items: [
                    for (final equipment in equipments)
                      DropdownMenuItem(
                        value: equipment,
                        child: Text.rich(
                          TextSpan(
                            children: [
                              WidgetSpan(
                                child: EquipmentIcon(
                                  equipment: equipment,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                                alignment: PlaceholderAlignment.middle,
                              ),
                              const TextSpan(text: " "),
                              TextSpan(text: equipment.localizedName),
                            ],
                          ),
                        ),
                      ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => equipment = value);
                  },
                  validator: (value) {
                    if (value == null) {
                      // Theoretically unreachable
                      return "exercise.editor.fields.gymEquipment.errors.empty"
                          .t;
                    }
                    return null;
                  },
                  value: equipment,
                ),
                DropdownButtonFormField<GTMuscleGroup>(
                  decoration: _decoration(
                      "exercise.editor.fields.primaryMuscleGroup.label".t),
                  items: [
                    for (final muscle in muscleGroups)
                      DropdownMenuItem(
                        value: muscle,
                        child: Text("muscleGroups.${muscle.name}".t),
                      ),
                  ],
                  onChanged: (value) {
                    if (otherGroups.contains(value)) {
                      otherGroups.remove(value);
                    }

                    setState(() => primaryGroup = value);
                  },
                  validator: (value) {
                    if (value == null) {
                      return "exercise.editor.fields.primaryMuscleGroup.errors.empty"
                          .t;
                    }
                    return null;
                  },
                  value: primaryGroup,
                ),
                Text(
                  "exercise.editor.fields.secondaryMuscleGroups.label".t,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Wrap(
                  runSpacing: 8,
                  spacing: 8,
                  children: [
                    for (final muscle in muscleGroups)
                      ChoiceChip(
                        label: Text("muscleGroups.${muscle.name}".t),
                        avatar: CircleAvatar(
                          child: Text(
                            otherGroups.contains(muscle)
                                ? ""
                                : "muscleGroups.${muscle.name}"
                                    .t
                                    .characters
                                    .first
                                    .toUpperCase(),
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                        selected: otherGroups.contains(muscle),
                        onSelected: primaryGroup == muscle
                            ? null
                            : (notSelected) {
                                setState(() {
                                  if (notSelected) {
                                    otherGroups.add(muscle);
                                  } else {
                                    otherGroups.remove(muscle);
                                  }
                                });
                              },
                      ),
                  ],
                ),
              ].map((c) => Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ).copyWith(top: 0),
                    child: c,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration(String label) {
    return GymTrackerInputDecoration(labelText: label);
  }

  void _submit() async {
    final isValid = formKey.currentState!.validate();

    if (isValid) {
      if (widget.base == null) {
        controller.submit(
          name: titleController.text,
          parameters: params,
          primaryMuscleGroup: primaryGroup!,
          otherMuscleGroups: otherGroups,
          restTime: Duration.zero,
        );
      } else {
        Get.back(
          result: Exercise.replaced(
            from: widget.base!,
            to: Exercise.custom(
              id: widget.base!.id,
              parentID: widget.base!.parentID,
              name: titleController.text,
              parameters: params,
              primaryMuscleGroup: primaryGroup!,
              secondaryMuscleGroups: otherGroups,
              restTime: Duration.zero,
              notes: widget.base!.notes,
              sets: [],
              workoutID: widget.base!.workoutID,
              supersetID: null,
              equipment: equipment,
            ),
          ),
        );
      }
    }
  }
}
