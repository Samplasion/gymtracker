import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/view/utils/input_decoration.dart';

class TextFieldDialog extends StatefulWidget {
  final Widget? title;
  final String initialValue;
  final ValueChanged<String> onDone;
  final String? Function(String?)? validator;

  const TextFieldDialog({
    this.title,
    this.initialValue = "",
    required this.onDone,
    this.validator,
    super.key,
  });

  @override
  State<TextFieldDialog> createState() => _TextFieldDialogState();
}

class _TextFieldDialogState extends State<TextFieldDialog> {
  var formKey = GlobalKey<FormState>();
  late TextEditingController controller =
      TextEditingController(text: widget.initialValue);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: AlertDialog(
        title: widget.title,
        content: TextFormField(
          controller: controller,
          decoration: const GymTrackerInputDecoration(),
          validator: widget.validator,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text("general.dialogs.actions.cancel".t),
          ),
          FilledButton.tonal(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                widget.onDone.call(controller.text);
                Get.back();
              }
            },
            child: Text("general.dialogs.actions.ok".t),
          ),
        ],
      ),
    );
  }
}
