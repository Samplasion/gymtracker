import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/exercises_controller.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/service/localizations.dart';

class ExerciseCreator extends StatefulWidget {
  final Exercise? base;

  const ExerciseCreator({required this.base, super.key});

  @override
  State<ExerciseCreator> createState() => _ExerciseCreatorState();
}

class _ExerciseCreatorState extends State<ExerciseCreator> {
  final formKey = GlobalKey<FormState>();
  late final titleController = TextEditingController(text: widget.base?.name);

  late SetParameters params =
      widget.base?.parameters ?? SetParameters.repsWeight;
  late MuscleGroup? primaryGroup = widget.base?.primaryMuscleGroup;
  late Set<MuscleGroup> otherGroups = widget.base?.secondaryMuscleGroups ?? {};

  ExercisesController get controller => Get.put(ExercisesController());

  @override
  Widget build(BuildContext context) {
    final muscleGroups = MuscleGroup.values.toList();
    muscleGroups.sort((a, b) =>
        "muscleGroups.${a.name}".t.compareTo("muscleGroups.${b.name}".t));

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
              icon: const Icon(Icons.check),
              onPressed: _submit,
            )
          ],
        ),
        body: Form(
          key: formKey,
          child: ListView(
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
                    if (!controller.isNameValid(string)) {
                      return "exercise.editor.fields.title.errors.invalid".t;
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField(
                  decoration:
                      _decoration("exercise.editor.fields.parameters.label".t),
                  items: [
                    for (final param in SetParameters.values)
                      DropdownMenuItem(
                        value: param,
                        child: Text(
                            "exercise.editor.fields.parameters.values.${param.name}"
                                .t),
                      ),
                  ],
                  onChanged: (v) => setState(() => params = v!),
                  validator: (value) {
                    if (value == null) {
                      return "exercise.editor.fields.parameters.errors.empty".t;
                    }
                    return null;
                  },
                  value: params,
                ),
                DropdownButtonFormField<MuscleGroup>(
                  decoration: _decoration(
                      "exercise.editor.fields.primaryMuscleGroup.label".t),
                  items: [
                    for (final muscle in MuscleGroup.values)
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
              ]
                  .map((c) => Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 16,
                        ).copyWith(top: 0),
                        child: c,
                      ))
                  .toList(),
            ],
          ),
        ),
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

  void _submit() {
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
          result: controller.generateEmpty(
            name: titleController.text,
            parameters: params,
            primaryMuscleGroup: primaryGroup!,
            secondaryMuscleGroups: otherGroups,
            sets: widget.base!.sets,
            restTime: Duration.zero,
          ),
        );
      }
    }
  }
}
