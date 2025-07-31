import 'dart:ui';

import 'package:gymtracker/utils/extensions.dart';

class NativeWorkoutStateMessage {
  final bool hasExercise;
  final String exerciseName;
  final Color exerciseColor;
  final String exerciseParameters;
  final DateTime startingTime;
  final DateTime? restTimeStart;
  final DateTime? restTimeEnd;
  final double percentageDone;

  NativeWorkoutStateMessage({
    required this.hasExercise,
    required this.exerciseName,
    required this.exerciseColor,
    required this.exerciseParameters,
    required this.startingTime,
    this.restTimeStart,
    this.restTimeEnd,
    required this.percentageDone,
  });

  Map<String, dynamic> toJson() {
    return {
      'hasExercise': hasExercise,
      'exerciseName': exerciseName,
      'exerciseColor': exerciseColor.hexValue,
      'exerciseParameters': exerciseParameters,
      'startingTime': startingTime.millisecondsSinceEpoch,
      'restTimeStart': restTimeStart?.millisecondsSinceEpoch,
      'restTimeEnd': restTimeEnd?.millisecondsSinceEpoch,
      'percentageDone': percentageDone,
    };
  }
}
