import 'package:flutter/material.dart';

const kGymTrackerInputBorderRadius = 24.0;

class GymTrackerInputDecoration extends InputDecoration {
  const GymTrackerInputDecoration({
    String labelText = '',
    super.suffix,
    super.suffixIcon,
    super.alignLabelWithHint,
  }) : super(
          isDense: true,
          border: const OutlineInputBorder(
            borderRadius:
                BorderRadius.all(Radius.circular(kGymTrackerInputBorderRadius)),
          ),
          labelText: labelText,
        );
}
