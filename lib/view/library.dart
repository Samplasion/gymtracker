import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymtracker/data/exercises.dart';
import 'package:gymtracker/model/superset.dart';
import 'package:gymtracker/service/localizations.dart';

import '../controller/exercises_controller.dart';
import '../controller/history_controller.dart';
import '../model/exercise.dart';
import '../utils/go.dart';
import '../utils/utils.dart';
import 'utils/exercise.dart';

class LibraryView extends GetView<ExercisesController> {
  const LibraryView({super.key});

  Map<String, ExerciseCategory> get exercises {
    final sortedKeys = [...exerciseStandardLibrary.keys]
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return {
      "library.custom".t: ExerciseCategory(
        exercises: controller.exercises,
        icon: const Icon(Icons.star_rounded),
        color: Colors.yellow,
      ),
      for (final key in sortedKeys) key: exerciseStandardLibrary[key]!,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => CustomScrollView(
          slivers: [
            SliverAppBar.large(
              title: Text("library.title".t),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  for (final category in exercises.entries)
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            getContainerColor(context, category.value.color),
                        foregroundColor:
                            getOnContainerColor(context, category.value.color),
                        child: category.value.icon,
                      ),
                      title: Text(category.key),
                      subtitle: Text(
                        "general.exercises"
                            .plural(category.value.exercises.length),
                      ),
                      onTap: () {
                        Go.to(() => LibraryExercisesView(
                              name: category.key,
                              category: category.value,
                            ));
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LibraryExercisesView extends StatelessWidget {
  const LibraryExercisesView({
    required this.name,
    required this.category,
    super.key,
  });

  final String name;
  final ExerciseCategory category;

  @override
  Widget build(BuildContext context) {
    final sorted = [...category.exercises]
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: ListView.builder(
        itemCount: category.exercises.length,
        itemBuilder: (context, index) {
          return ExerciseListTile(
            exercise: sorted[index],
            selected: false,
            isConcrete: false,
            onTap: () {
              Go.to(() => ExerciseInfoView(exercise: sorted[index]));
            },
          );
        },
      ),
    );
  }
}

class ExerciseInfoView extends StatelessWidget {
  const ExerciseInfoView({required this.exercise, super.key});

  final Exercise exercise;

  List<Exercise> getHistory() {
    final controller = Get.find<HistoryController>();
    final history = <Exercise>[];
    for (final workout in controller.history) {
      history.addAll(
        [
          for (final exercise in workout.exercises)
            if (exercise is Exercise) ...[
              exercise,
            ] else if (exercise is Superset) ...[
              for (final e in exercise.exercises) e,
            ],
        ].where(
          (element) => exercise.isTheSameAs(element),
        ),
      );
    }
    return history;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("exercise.info.title".t)),
      body: ListTileTheme(
        contentPadding: EdgeInsets.zero,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (exercise.isCustom) Row(children: const [CustomExerciseBadge()]),
            Text(exercise.name,
                style: Theme.of(context).textTheme.displayMedium),
            if (kDebugMode) ...[
              Text(exercise.id),
              Text("parent: ${exercise.parentID}"),
              ListTile(
                title: Text("history"),
                subtitle: Text(getHistory().length.toString()),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
