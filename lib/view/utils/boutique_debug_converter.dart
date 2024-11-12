import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymtracker/model/model.dart';
import 'package:gymtracker/view/utils/input_decoration.dart';
import 'package:gymtracker/view/utils/routine_form_picker.dart';

class BoutiqueDebugConverter extends StatefulWidget {
  final List<BoutiquePackage> packages;
  final void Function(Workout routine, BoutiquePackage package) onPicked;

  const BoutiqueDebugConverter({
    super.key,
    required this.packages,
    required this.onPicked,
  });

  @override
  State<BoutiqueDebugConverter> createState() => _BoutiqueDebugConverterState();
}

class _BoutiqueDebugConverterState extends State<BoutiqueDebugConverter> {
  Workout? routine;
  BoutiquePackage? package;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Boutique Debug Converter'),
      ),
      body: ListView(
        children: [
          DropdownButton<BoutiquePackage>(
            value: package,
            onChanged: (value) {
              setState(() {
                package = value;
              });
            },
            items: widget.packages
                .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(e.name),
                    ))
                .toList(),
          ),
          RoutineFormPicker(
            routine: routine,
            onChanged: (routine) {
              setState(() {
                this.routine = routine;
              });
            },
            decoration: const GymTrackerInputDecoration(),
          ),
          ElevatedButton(
            onPressed: () {
              if (routine != null && package != null) {
                widget.onPicked(routine!, package!);
                Get.back();
              }
            },
            child: const Text('Convert'),
          ),
        ],
      ),
    );
  }
}
