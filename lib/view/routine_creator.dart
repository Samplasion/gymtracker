import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/workouts_controller.dart';
import '../model/exercise.dart';
import '../model/set.dart';
import '../model/workout.dart';
import '../utils/go.dart';
import 'exercise_picker.dart';
import 'utils/workout.dart';

class _DateWrapped<T> {
  T data;
  final DateTime date;

  _DateWrapped(this.data) : date = DateTime.now();
}

extension _Wrap<T> on List<T> {
  List<_DateWrapped<T>> wrap() => [for (final data in this) _DateWrapped(data)];
}

extension _Unwrap<T> on RxList<_DateWrapped<T>> {
  List<T> unwrap() => [for (final box in this) box.data];
}

class _RoutineCreatorController extends GetxController {
  final exercises = <_DateWrapped<Exercise>>[].obs;
}

// ignore: library_private_types_in_public_api
_RoutineCreatorController get controller =>
    Get.put(_RoutineCreatorController());

class RoutineCreator extends StatefulWidget {
  final Workout? base;

  const RoutineCreator({this.base, super.key});

  @override
  State<RoutineCreator> createState() => _RoutineCreatorState();
}

class _RoutineCreatorState extends State<RoutineCreator> {
  final formKey = GlobalKey<FormState>();
  late final titleController = TextEditingController(text: widget.base?.name);
  late final infoboxController = TextEditingController(text: widget.base?.infobox);

  WorkoutsController get workoutsController => Get.find<WorkoutsController>();

  @override
  void initState() {
    super.initState();
    if (widget.base != null) {
      controller.exercises(widget.base!.exercises.wrap());
    }
  }

  @override
  void dispose() {
    Get.delete<_RoutineCreatorController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(() {
          if (widget.base == null) {
            return "routines.actions.create".tr;
          } else {
            return "routines.actions.edit".tr;
          }
        }()),
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
                decoration: InputDecoration(
                  isDense: true,
                  border: const OutlineInputBorder(),
                  labelText: "routines.editor.fields.name.label".tr,
                ),
                validator: (string) {
                  if (string == null || string.isEmpty) {
                    return "routines.editor.fields.name.errors.empty".tr;
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: infoboxController,
                minLines: 3,
                maxLines: null,
                decoration: InputDecoration(
                  isDense: true,
                  border: const OutlineInputBorder(),
                  labelText: "routines.editor.fields.infobox.label".tr,
                  alignLabelWithHint: true,
                ),
              ),
              Text("routines.editor.exercises.title".tr,
                  style: Theme.of(context).textTheme.titleMedium),
            ]
                .map((c) => Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 16,
                      ).copyWith(top: 0),
                      child: c,
                    ))
                .toList(),
            ListTile(
              title: Text("routines.editor.exercises.add".tr),
              leading: const CircleAvatar(child: Icon(Icons.add_rounded)),
              onTap: () {
                Go.to<List<Exercise>>(() => const ExercisePicker(
                      singlePick: false,
                    )).then((result) {
                  result ??= [];
                  setState(() {
                    controller.exercises.addAll(result!.wrap());
                  });
                });
              },
            ),
            Obx(
              () => ReorderableListView(
                buildDefaultDragHandles: false,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  for (int i = 0; i < controller.exercises.length; i++) ...[
                    WorkoutExerciseEditor(
                      key: ValueKey(
                          "${controller.exercises[i].data.name}${controller.exercises[i].date}"),
                      exercise: controller.exercises[i].data,
                      index: i,
                      isCreating: true,
                      onReorder: () {},
                      onReplace: () {},
                      onRemove: () {
                        controller.exercises.removeAt(i);
                        controller.exercises.refresh();
                      },
                      onChangeRestTime: (value) {
                        controller.exercises[i].data.restTime = value;
                        controller.exercises.refresh();
                      },
                      onSetCreate: () {
                        final ex = controller.exercises[i];
                        controller.exercises[i].data.sets.add(
                          ExSet.empty(
                            kind: SetKind.normal,
                            parameters: ex.data.parameters,
                          ),
                        );
                        controller.exercises.refresh();
                      },
                      onSetRemove: (int index) {
                        setState(() {
                          controller.exercises[i].data.sets.removeAt(index);
                          controller.exercises.refresh();
                        });
                      },
                      onSetSelectKind: (set, kind) {
                        set.kind = kind;
                        controller.exercises.refresh();
                      },
                      onSetSetDone: (ex, set, done) {},
                      onSetValueChange: () {},
                      onNotesChange: (ex, notes) {
                        ex.notes = notes;
                        controller.exercises.refresh();
                      },
                    ),
                  ],
                ],
                onReorder: (oldIndex, newIndex) {
                  _reorder(controller.exercises, oldIndex, newIndex);
                  controller.exercises.refresh();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _reorder<T>(List<T> list, int oldIndex, int newIndex) {
    setState(
      () {
        if (newIndex > oldIndex) newIndex -= 1;
        list.insert(newIndex, list.removeAt(oldIndex));
      },
    );
  }

  void _submit() {
    final isValid = formKey.currentState!.validate();

    if (isValid) {
      if (widget.base == null) {
        workoutsController.submitRoutine(
          name: titleController.text,
          exercises: controller.exercises.unwrap(),
          infobox: infoboxController.text.trim().isEmpty ? null : infoboxController.text,
        );
      } else {
        Get.back(
          result: workoutsController.generate(
            name: titleController.text,
            exercises: controller.exercises.unwrap(),
            id: widget.base!.id,
            infobox: infoboxController.text.trim().isEmpty ? null : infoboxController.text,
          ),
        );
      }
    }
  }
}
