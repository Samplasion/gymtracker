import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/controller/exercises_controller.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/library.dart';

class ExerciseParentViewGesture extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(onTap: () => _onTap(ref), child: child);
  }

  void _onTap(WidgetRef ref) {
    final parent = exercise.getParent(
      ref.read(exercisesControllerProvider).exercises,
    );
    final enabled = this.enabled && parent != null;
    logger.t(
      "onTap: ${exercise.id}'s parent is ${exercise.parentID} ($parent) enabled: $enabled",
    );
    if (enabled) {
      Go.to(
        () => ExerciseInfoView(exercise: parent, refresh: () => _refresh(ref)),
      );
    }
  }

  void _refresh(WidgetRef ref) {
    final parent = exercise.getParent(
      ref.read(exercisesControllerProvider).exercises,
    );
    if (parent != null) {
      Go.off(
        () => ExerciseInfoView(exercise: parent, refresh: () => _refresh(ref)),
      );
    }
  }
}
