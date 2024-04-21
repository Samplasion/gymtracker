import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/theme.dart';

Widget buildSetType(
  BuildContext context,
  GTSetKind kind, {
  required GTSet set,
  required List<GTSet> allSets,
  double fontSize = 14,
}) {
  final scheme = Theme.of(context).colorScheme;
  switch (kind) {
    case GTSetKind.warmUp:
      return Text(
        "set.kindShort.warmUp".t,
        style: TextStyle(
          color: scheme.tertiary,
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
        ),
      );
    case GTSetKind.normal:
      return Text(
        max(
                allSets
                        .where((element) => element.kind == GTSetKind.normal)
                        .toList()
                        .indexOf(set) +
                    1,
                1)
            .toString(),
        style: TextStyle(
          color: scheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
        ),
      );
    case GTSetKind.drop:
      return Text(
        "set.kindShort.drop".t,
        style: TextStyle(
          color: scheme.error,
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
        ),
      );
    case GTSetKind.failure:
      return Text(
        "set.kindShort.failure".t,
        style: TextStyle(
          color: scheme.quinary,
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
        ),
      );
    case GTSetKind.failureStripping:
      return Text(
        "set.kindShort.failureStripping".t,
        style: TextStyle(
          color: scheme.quaternary,
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
        ),
      );
  }
}
