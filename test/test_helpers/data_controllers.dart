import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/provider/routines.dart';
import 'package:gymtracker/provider/training_data.dart';

import 'mock_services.dart';

/// Creates the real command object in an isolated scope with explicit snapshots.
T dataController<T>(
  T Function(Ref) create, {
  List<Workout> routines = const [],
  List<Workout> history = const [],
  List<Exercise> exercises = const [],
}) {
  final target = Provider<T>(create);
  final container = ProviderContainer(
    parent: MockServices.container,
    overrides: [
      target.overrideWith(create),
      routinesStreamProvider.overrideWithValue(AsyncData(routines)),
      foldersStreamProvider.overrideWithValue(const AsyncData([])),
      historyWorkoutsProvider.overrideWithValue(AsyncData(history)),
      customExercisesProvider.overrideWithValue(AsyncData(exercises)),
    ],
  );
  addTearDown(container.dispose);
  return container.read(target);
}
