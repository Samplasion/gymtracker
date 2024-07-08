import 'package:flutter/material.dart';

const kGymTrackerInputBorderRadius = 24.0;

class GymTrackerInputDecoration extends InputDecoration {
  const GymTrackerInputDecoration({
    String labelText = '',
    super.hintText,
    super.suffix,
    super.suffixIcon,
    super.alignLabelWithHint,
  }) : super(
          labelText: labelText,
        );
}
