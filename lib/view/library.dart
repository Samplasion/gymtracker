import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/exercises_controller.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/data/exercises.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/model/superset.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/utils/utils.dart';
import 'package:gymtracker/view/components/badges.dart';
import 'package:gymtracker/view/exercise_creator.dart';
import 'package:gymtracker/view/exercises.dart';
import 'package:gymtracker/view/utils/exercise.dart';
import 'package:intl/intl.dart';

class LibraryView extends GetView<ExercisesController> {
  const LibraryView({super.key});

  Map<String, ExerciseCategory> get exercises {
    final sortedKeys = [...exerciseStandardLibrary.keys]
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return {
      if (controller.exercises.isNotEmpty)
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
                              isCustom: category.key == "library.custom".t,
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
    required this.isCustom,
    super.key,
  });

  final String name;
  final ExerciseCategory category;
  final bool isCustom;

  @override
  Widget build(BuildContext context) {
    final sorted = [...category.exercises]
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: CustomScrollView(
        slivers: [
          if (isCustom) ...[
            SliverToBoxAdapter(
              child: ListTile(
                title: Text("library.newCustomExercise".t),
                leading: const CircleAvatar(child: Icon(Icons.add_rounded)),
                onTap: () {
                  Go.showBottomModalScreen(
                      (context, controller) => ExerciseCreator(
                            base: null,
                            scrollController: controller,
                          ));
                },
              ),
            ),
            const SliverToBoxAdapter(child: Divider()),
          ],
          SliverList.builder(
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
        ],
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
        child: SafeArea(
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
                    exercise.displayName,
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                ),
              ),
              if (history.isNotEmpty)
                SliverList(
                  delegate:
                      SliverChildListDelegate(_getInfoTiles(exercise, context)),
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
                            weightUnit: history[index].$3.weightUnit,
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
                                  subtitle: Text(DateFormat.yMd(
                                          context.locale.languageCode)
                                      .add_Hm()
                                      .format(history[index].$3.startingDate ??
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
              if (history.isEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text("exercise.info.noHistory".t),
                  ),
                ),
              ],
              const SliverToBoxAdapter(
                child: SizedBox(height: 8),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<ListTileTheme> _getInfoTiles(Exercise exercise, BuildContext context) {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text("exercise.info.usefulData".t,
            style: Theme.of(context).textTheme.labelLarge!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                )),
      ),
      if ([SetParameters.repsWeight, SetParameters.timeWeight]
          .contains(exercise.parameters))
        Builder(builder: (context) {
          var best = history.first;
          var bestScore = -1.0;

          for (final hist in history) {
            final (Exercise exercise, int _, Workout workout) = hist;
            if (exercise.sets.where((set) => set.done).isEmpty) continue;
            final value = Weights.convert(
                value: exercise.sets
                    .where((set) => set.done)
                    .map((set) => set.weight)
                    .whereType<num>()
                    .max
                    .toDouble(),
                from: workout.weightUnit,
                to: settingsController.weightUnit.value!);
            if (value >= bestScore) {
              best = hist;
              bestScore = value;
            }
          }

          return ExerciseInfoTile(
            "exercise.info.heaviestWeight.label".t,
            bestScore.userFacingWeight,
            onTap: () {
              Go.to(() => ExercisesView(workout: best.$3));
            },
          );
        }),
      if ([SetParameters.repsWeight].contains(exercise.parameters))
        Builder(builder: (context) {
          var best = history.first;
          var bestScore = -1.0;

          for (final hist in history) {
            final (Exercise exercise, int _, Workout workout) = hist;
            if (exercise.sets.where((set) => set.done).isEmpty) continue;
            final value = Weights.convert(
                value: exercise.sets
                    .where((set) => set.done)
                    .map((set) => set.oneRepMax)
                    .whereType<num>()
                    .max
                    .toDouble(),
                from: workout.weightUnit,
                to: settingsController.weightUnit.value!);
            if (value >= bestScore) {
              best = hist;
              bestScore = value;
            }
          }

          return ExerciseInfoTile(
            "exercise.info.best1rm.label".t,
            bestScore.userFacingWeight,
            onTap: () {
              Go.to(() => ExercisesView(workout: best.$3));
            },
          );
        }),
      if ([SetParameters.repsWeight].contains(exercise.parameters))
        Builder(builder: (context) {
          var best = history.first;
          var bestWeight = 0.0;
          var bestReps = 0;
          var bestScore = -1.0;

          for (final hist in history) {
            final (Exercise exercise, int _, Workout workout) = hist;
            for (final set in exercise.sets.where((set) => set.done)) {
              final value = Weights.convert(
                  value: set.weight!,
                  from: workout.weightUnit,
                  to: settingsController.weightUnit.value!);
              if ((value * set.reps!) >= bestScore) {
                best = hist;
                bestScore = (value * set.reps!);
                bestWeight = value;
                bestReps = set.reps!;
              }
            }
          }

          return ExerciseInfoTile(
            "exercise.info.bestSetVolume.label".t,
            "${bestWeight.userFacingWeight} × $bestReps",
            onTap: () {
              Go.to(() => ExercisesView(workout: best.$3));
            },
          );
        }),
      if ([SetParameters.repsWeight, SetParameters.timeWeight]
          .contains(exercise.parameters))
        Builder(builder: (context) {
          var best = history.first;
          var bestScore = -1.0;

          for (final hist in history) {
            final (Exercise exercise, int _, Workout workout) = hist;
            if (exercise.sets.where((set) => set.done).isEmpty) continue;
            final value = Weights.convert(
                value: exercise.sets
                    .where((set) => set.done)
                    .map((set) => set.weight! * (set.reps ?? 1))
                    .whereType<num>()
                    .sum
                    .toDouble(),
                from: workout.weightUnit,
                to: settingsController.weightUnit.value!);
            if (value >= bestScore) {
              best = hist;
              bestScore = value;
            }
          }

          return ExerciseInfoTile(
            "exercise.info.bestSessionVolume.label".t,
            bestScore.userFacingWeight,
            onTap: () {
              Go.to(() => ExercisesView(workout: best.$3));
            },
          );
        }),
    ].map((w) {
      // Restore default theme for this section only
      return ListTileTheme(
        data: Theme.of(context).listTileTheme,
        child: w,
      );
    }).toList();
  }
}

class ExerciseInfoTile extends StatelessWidget {
  final String title, subtitle;
  final VoidCallback? onTap;

  const ExerciseInfoTile(
    this.title,
    this.subtitle, {
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(title: Text(title), subtitle: Text(subtitle), onTap: onTap);
  }
}
