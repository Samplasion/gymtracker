import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../model/set.dart';

Widget buildSetType(
  BuildContext context,
  SetKind kind, {
  required ExSet set,
  required List<ExSet> allSets,
}) {
  final scheme = Theme.of(context).colorScheme;
  switch (kind) {
    case SetKind.warmUp:
      return Text(
        "set.kindShort.warmUp".tr,
        style: TextStyle(
          color: scheme.tertiary,
          fontWeight: FontWeight.bold,
        ),
      );
    case SetKind.normal:
      return Text(
        max(
                allSets
                        .where((element) => element.kind == SetKind.normal)
                        .toList()
                        .indexOf(set) +
                    1,
                1)
            .toString(),
        style: TextStyle(
          color: scheme.primary,
          fontWeight: FontWeight.bold,
        ),
      );
    case SetKind.drop:
      return Text(
        "set.kindShort.drop".tr,
        style: TextStyle(
          color: scheme.error,
          fontWeight: FontWeight.bold,
        ),
      );
  }
}
