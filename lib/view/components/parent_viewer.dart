import 'package:flutter/material.dart';
import 'package:gymtracker/controller/exercises_controller.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/library.dart';

class ExerciseParentViewGesture extends StatelessWidget {
  final Exercise exercise;
  final Widget child;
  final bool enabled;

  const ExerciseParentViewGesture({
    required this.exercise,
    required this.child,
    this.enabled = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: child,
    );
  }

  void _onTap() {
    final parent = exercise.getParent();
    final enabled = this.enabled && parent != null;
    debugPrint(
        "onTap: ${exercise.id}'s parent is ${exercise.parentID} ($parent) enabled: $enabled");
    if (enabled) {
      Go.to(() => ExerciseInfoView(exercise: parent));
    }
  }
}
