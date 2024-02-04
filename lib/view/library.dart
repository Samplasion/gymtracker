import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymtracker/data/exercises.dart';
import 'package:gymtracker/model/superset.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/view/exercises.dart';
import 'package:intl/intl.dart';

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

class ExerciseInfoView extends StatefulWidget {
  const ExerciseInfoView({required this.exercise, super.key});

  final Exercise exercise;

  @override
  State<ExerciseInfoView> createState() => _ExerciseInfoViewState();
}

class _ExerciseInfoViewState extends State<ExerciseInfoView> {
  late final List<(Exercise, int, Workout)> history = getHistory();

  List<(Exercise, int, Workout)> getHistory() {
    final controller = Get.find<HistoryController>();
    final history = <(Exercise, int, Workout)>[];
    for (final workout in controller.history) {
      history.addAll(
        [
          for (int i = 0; i < workout.exercises.length; i++)
            if (workout.exercises[i] is Exercise) ...[
              (workout.exercises[i] as Exercise, i),
            ] else if (workout.exercises[i] is Superset) ...[
              for (final e in (workout.exercises[i] as Superset).exercises)
                (e, i),
            ],
        ]
            .where(
              (element) => widget.exercise.isTheSameAs(element.$1),
            )
            .map((e) => (e.$1, e.$2, workout)),
      );
    }
    history.sort((a, b) =>
        (b.$3.startingDate ?? DateTime.fromMillisecondsSinceEpoch(0)).compareTo(
            a.$3.startingDate ?? DateTime.fromMillisecondsSinceEpoch(0)));
    return history;
  }

  @override
  Widget build(BuildContext context) {
    final exercise = widget.exercise;
    return Scaffold(
      appBar: AppBar(title: Text("exercise.info.title".t)),
      body: ListTileTheme(
        contentPadding: EdgeInsets.zero,
        child: CustomScrollView(
          slivers: [
            if (exercise.isCustom)
              SliverPadding(
                padding: const EdgeInsets.all(16).copyWith(bottom: 8),
                sliver: const SliverToBoxAdapter(
                  child: Row(
                    children: [CustomExerciseBadge()],
                  ),
                ),
              ),
            SliverPadding(
              padding: const EdgeInsets.all(16)
                  .copyWith(top: exercise.isCustom ? 0 : 16),
              sliver: SliverToBoxAdapter(
                child: Text(
                  exercise.name,
                  style: Theme.of(context).textTheme.displayMedium,
                ),
              ),
            ),
            SliverList.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8)
                        .copyWith(bottom: 16),
                    child: Column(
                      children: [
                        ExerciseDataView(
                          exercise: history[index].$1,
                          index: history[index].$2,
                          workout: history[index].$3,
                          isInSuperset: false,
                        ),
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                  foregroundColor: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                  child: Text(history[index]
                                      .$3
                                      .name
                                      .characters
                                      .first
                                      .toUpperCase()),
                                ),
                                title: Text(history[index].$3.name),
                                subtitle: Text(DateFormat.yMd().add_Hm().format(
                                    history[index].$3.startingDate ??
                                        DateTime.now())),
                              ),
                            ],
                          ),
                        ),
                        OutlinedButton(
                          onPressed: () {
                            Go.to(
                              () => ExercisesView(workout: history[index].$3),
                            );
                          },
                          child: Text("exercise.info.viewWorkout".t),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 8),
            ),
          ],
        ),
      ),
    );
  }
}
