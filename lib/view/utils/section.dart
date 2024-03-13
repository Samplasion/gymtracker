import 'package:flutter/material.dart';
import 'package:gymtracker/model/section.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/view/utils/drag_handle.dart';
import 'package:gymtracker/view/utils/textfield_dialog.dart';

class EditorSection extends StatelessWidget {
  final Section section;
  final ValueChanged<String> onNoteChange;
  final bool reorderable;
  final int? index;

  const EditorSection({
    super.key,
    required this.section,
    required this.onNoteChange,
    required this.reorderable,
    this.index,
  }) : assert(reorderable && index != null);

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Theme.of(context).colorScheme.secondaryContainer;
    Color foregroundColor = Theme.of(context).colorScheme.onSecondaryContainer;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        child: const Icon(Icons.category_rounded),
      ),
      title: Text("section.label".t),
      subtitle: Text(section.notes.isEmpty ? "section.notes".t : section.notes),
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => TextFieldDialog(
            title: Text("section.notes".t),
            initialValue: section.notes,
            onDone: onNoteChange,
          ),
        );
      },
      trailing: reorderable ? DragHandle(index: index!) : null,
    );
  }
}

class ViewSection extends StatelessWidget {
  final Section section;

  const ViewSection({required this.section, super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
