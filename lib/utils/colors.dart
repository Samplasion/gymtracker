import 'package:flutter/material.dart';
import 'package:gymtracker/utils/theme.dart';

enum GTMaterialColor {
  primary,
  secondary,
  tertiary,
  quaternary,
  quinary,
  error;

  Color getForeground(BuildContext context) {
    switch (this) {
      case GTMaterialColor.primary:
        return Theme.of(context).colorScheme.onPrimaryContainer;
      case GTMaterialColor.secondary:
        return Theme.of(context).colorScheme.onSecondaryContainer;
      case GTMaterialColor.tertiary:
        return Theme.of(context).colorScheme.onTertiaryContainer;
      case GTMaterialColor.quaternary:
        return Theme.of(context).colorScheme.onQuaternaryContainer;
      case GTMaterialColor.quinary:
        return Theme.of(context).colorScheme.onQuinaryContainer;
      case GTMaterialColor.error:
        return Theme.of(context).colorScheme.onErrorContainer;
    }
  }

  Color getBackground(BuildContext context) {
    switch (this) {
      case GTMaterialColor.primary:
        return Theme.of(context).colorScheme.primaryContainer;
      case GTMaterialColor.secondary:
        return Theme.of(context).colorScheme.secondaryContainer;
      case GTMaterialColor.tertiary:
        return Theme.of(context).colorScheme.tertiaryContainer;
      case GTMaterialColor.quaternary:
        return Theme.of(context).colorScheme.quaternaryContainer;
      case GTMaterialColor.quinary:
        return Theme.of(context).colorScheme.quinaryContainer;
      case GTMaterialColor.error:
        return Theme.of(context).colorScheme.errorContainer;
    }
  }
}
