import 'package:flutter/material.dart';
import 'package:gymtracker/struct/nutrition.dart';

class NutritionCategoryIconPicker extends StatefulWidget {
  final NutritionCategoryIcon initialIcon;
  final void Function(NutritionCategoryIcon) onIconChanged;
  final Widget title;

  const NutritionCategoryIconPicker({
    super.key,
    required this.initialIcon,
    required this.onIconChanged,
    required this.title,
  });

  @override
  State<NutritionCategoryIconPicker> createState() =>
      _NutritionCategoryIconPickerState();
}

class _NutritionCategoryIconPickerState
    extends State<NutritionCategoryIconPicker> {
  late var selectedIcon = widget.initialIcon;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: widget.title,
      content: SingleChildScrollView(
        child: Wrap(
          children: NutritionCategoryIcon.values.map((icon) {
            final selected = icon == selectedIcon;
            final backgroundColor = selected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent;
            final iconColor = selected
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurface;
            return InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () => setState(() => selectedIcon = icon),
              child: CircleAvatar(
                minRadius: 24,
                maxRadius: 32,
                backgroundColor: backgroundColor,
                foregroundColor: iconColor,
                child: Icon(icon.iconData),
              ),
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        TextButton(
          onPressed: () {
            widget.onIconChanged(selectedIcon);
            Navigator.of(context).pop();
          },
          child: Text(MaterialLocalizations.of(context).okButtonLabel),
        ),
      ],
    );
  }
}
