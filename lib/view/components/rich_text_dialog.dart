import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/view/components/rich_text_editor.dart';
import 'package:gymtracker/view/utils/input_decoration.dart';

class GTRichTextEditDialog extends StatelessWidget {
  const GTRichTextEditDialog({
    super.key,
    required this.controller,
    required this.onNotesChange,
  });

  final QuillController controller;
  final ValueChanged<String> onNotesChange;

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: Text('exercise.editor.fields.notes.label'.t),
          actions: [
            IconButton(
              onPressed: () {
                onNotesChange(controller.document.toEncoded());
              },
              icon: const Icon(GymTrackerIcons.done),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: GTRichTextEditor(
              infoboxController: controller,
              autofocus: true,
              decoration: GymTrackerInputDecoration(
                labelText: "exercise.editor.fields.notes.label".t,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
