import 'package:flutter/material.dart';
import 'package:gymtracker/utils/theme.dart';
import 'package:gymtracker/utils/utils.dart';

enum GTMaterialColor {
  primary,
  secondary,
  tertiary,
  quaternary,
  quinary,
  error,
  warning;

  Color getForeground(BuildContext context) {
    return switch (this) {
      GTMaterialColor.primary =>
        Theme.of(context).colorScheme.onPrimaryContainer,
      GTMaterialColor.secondary =>
        Theme.of(context).colorScheme.onSecondaryContainer,
      GTMaterialColor.tertiary =>
        Theme.of(context).colorScheme.onTertiaryContainer,
      GTMaterialColor.quaternary =>
        Theme.of(context).colorScheme.onQuaternaryContainer,
      GTMaterialColor.quinary =>
        Theme.of(context).colorScheme.onQuinaryContainer,
      GTMaterialColor.error => Theme.of(context).colorScheme.onErrorContainer,
      GTMaterialColor.warning => getOnContainerColor(context, Colors.amber),
    };
  }

  Color getBackground(BuildContext context) {
    return switch (this) {
      GTMaterialColor.primary => Theme.of(context).colorScheme.primaryContainer,
      GTMaterialColor.secondary =>
        Theme.of(context).colorScheme.secondaryContainer,
      GTMaterialColor.tertiary =>
        Theme.of(context).colorScheme.tertiaryContainer,
      GTMaterialColor.quaternary =>
        Theme.of(context).colorScheme.quaternaryContainer,
      GTMaterialColor.quinary => Theme.of(context).colorScheme.quinaryContainer,
      GTMaterialColor.error => Theme.of(context).colorScheme.errorContainer,
      GTMaterialColor.warning => getContainerColor(context, Colors.amber),
    };
  }
}
