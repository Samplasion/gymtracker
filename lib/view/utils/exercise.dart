import 'package:flutter/material.dart';

import '../../model/exercise.dart';

class ExerciseIcon extends StatelessWidget {
  final Exercise exercise;

  const ExerciseIcon({required this.exercise, super.key});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
      child: Text(exercise.name.characters.first.toUpperCase()),
    );
  }
}

class ExerciseListTile extends StatelessWidget {
  final Exercise exercise;
  final bool selected;
  final VoidCallback? onTap;

  const ExerciseListTile({
    required this.exercise,
    required this.selected,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final unselectedIcon = ExerciseIcon(exercise: exercise);
    final selectedIcon = CircleAvatar(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      foregroundColor: Theme.of(context).colorScheme.onSecondary,
      child: const Icon(Icons.check),
    );
    return ListTile(
      leading: selected ? selectedIcon : unselectedIcon,
      title: Text(exercise.name),
      onTap: onTap,
    );
  }
}
