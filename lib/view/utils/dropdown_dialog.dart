import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DropdownDialog<T> extends StatefulWidget {
  final Widget? title;
  final List<DropdownMenuItem<T>> items;
  final T initialItem;
  final ValueChanged<T?>? onSelect;

  const DropdownDialog({
    this.title,
    required this.items,
    required this.initialItem,
    this.onSelect,
    super.key,
  });

  @override
  State<DropdownDialog<T>> createState() => _DropdownDialogState<T>();
}

class _DropdownDialogState<T> extends State<DropdownDialog<T>> {
  late T? item = widget.initialItem;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: widget.title,
      content: DropdownButtonFormField<T>(
        items: widget.items,
        onChanged: (v) {
          setState(() => item = v);
        },
        value: item,
        decoration: const InputDecoration(
          isDense: true,
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
          },
          child: Text("general.dialogs.actions.cancel".tr),
        ),
        FilledButton.tonal(
          onPressed: () {
            Get.back();
            widget.onSelect?.call(item);
          },
          child: Text("general.dialogs.actions.ok".tr),
        ),
      ],
    );
  }
}
