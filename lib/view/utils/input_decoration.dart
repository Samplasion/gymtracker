import 'package:flutter/material.dart';

class GymTrackerInputDecoration extends InputDecoration {
  const GymTrackerInputDecoration({
    String labelText = '',
    super.suffix,
    super.suffixIcon,
    super.alignLabelWithHint,
  }) : super(
          isDense: true,
          border: const OutlineInputBorder(),
          labelText: labelText,
        );
}
