import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart' hide ContextExtensionss;
import 'package:gymtracker/controller/exercises_controller.dart';
import 'package:gymtracker/controller/history_controller.dart';
import 'package:gymtracker/controller/settings_controller.dart';
import 'package:gymtracker/controller/workout_controller.dart';
import 'package:gymtracker/data/exercises.dart';
import 'package:gymtracker/data/weights.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/model/exercisable.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/model/superset.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/utils/utils.dart';
import 'package:gymtracker/view/charts/line_charts_by_workout.dart';
import 'package:gymtracker/view/components/badges.dart';
import 'package:gymtracker/view/components/master_detail.dart';
import 'package:gymtracker/view/components/themed_subtree.dart';
import 'package:gymtracker/view/exercise_creator.dart';
import 'package:gymtracker/view/exercises.dart';
import 'package:gymtracker/view/skeleton.dart';
import 'package:gymtracker/view/utils/exercise.dart';
import 'package:gymtracker/view/utils/history_workout.dart';
import 'package:gymtracker/view/utils/sliver_utils.dart';
import 'package:rxdart/rxdart.dart';

class LibraryView extends GetView<ExercisesController> {
  const LibraryView({super.key});

  Map<GTExerciseMuscleCategory, ExerciseCategory> get exercises {
    return {
      GTExerciseMuscleCategory.custom: ExerciseCategory(
        exercises: Get.find<ExercisesController>().exercises.toList(),
        iconGetter: () => const Icon(GTIcons.custom_exercises),
        color: Colors.yellow,
      ),
      for (final key in sortedCategories) key: exerciseStandardLibrary[key]!,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text("library.title".t),
            leading: const SkeletonDrawerButton(),
            actions: [
              if (kDebugMode) ...[
                IconButton(
                  icon: const Icon(GTIcons.explanation),
                  onPressed: () {
                    Go.to(() => const DebugExercisesWithoutExplanationList());
                  },
                ),
              ],
            ],
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
                    title: Text(category.key.localizedName),
                    subtitle: Text(
                      "general.exercises"
                          .plural(category.value.exercises.length),
                    ),
                    onTap: () {
                      final exStream =
                          category.key == GTExerciseMuscleCategory.custom
                              ? Get.find<ExercisesController>().exercises$
                              : Stream.value(category.value.exercises);
                      Go.to(
                        () => StreamBuilder<List<Exercise>>(
                          stream: exStream,
                          builder: (context, snapshot) {
                            final exercises = snapshot.data ?? [];
                            return LibraryExercisesView(
                              name: category.key.localizedName,
                              category: category.value,
                              getExercises: () {
                                return exercises;
                              },
                              isCustom: category.key ==
                                  GTExerciseMuscleCategory.custom,
                            );
                          },
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          const SliverBottomSafeArea(),
        ],
      ),
    );
  }
}

class LibraryExercisesView extends StatelessWidget {
  const LibraryExercisesView({
    required this.name,
    required this.category,
    required this.getExercises,
    required this.isCustom,
    super.key,
  });

  final String name;
  final ExerciseCategory category;
  final List<Exercise> Function() getExercises;
  final bool isCustom;

  @override
  Widget build(BuildContext context) {
    return ThemedSubtree(
      color: category.color,
      enabled: Get.find<SettingsController>().tintExercises.value,
      child: isCustom ? _buildInnerView(context) : _buildInnerView(context),
    );
  }

  Widget _buildInnerView(BuildContext context) {
    return StatefulBuilder(
      builder: (context, refresh) {
        final exercises = getExercises();

        final sorted = exercises.toList()
          ..sort((a, b) => a.displayName.compareTo(b.displayName));

        return MasterDetailView(
          appBarTitle: Text(name),
          items: [
            if (isCustom) ...[
              MasterItem(
                Text("library.newCustomExercise".t),
                leading:
                    const CircleAvatar(child: Icon(GTIcons.create_exercise)),
                onTap: () {
                  Go.showBottomModalScreen(
                      (context, controller) => ThemedSubtree(
                            color: category.color,
                            enabled: Get.find<SettingsController>()
                                .tintExercises
                                .value,
                            child: ExerciseCreator(
                              base: null,
                              scrollController: controller,
                            ),
                          ));
                },
              ),
              const MasterItemDivider(),
            ],
            ...List.generate(
              sorted.length,
              (index) {
                MasterItem exerciseListTile = ExerciseListTile(
                  exercise: sorted[index],
                  selected: false,
                  isConcrete: false,
                  trailing: kDebugMode && sorted[index].hasExplanation
                      ? const Icon(GTIcons.explanation)
                      : null,
                ).getAsMasterItem(context, detailsBuilder: (context) {
                  return ExerciseInfoView(
                    key: ValueKey(sorted[index].id),
                    exercise: sorted[index],
                    refresh: () => refresh(() {}),
                  );
                });

                return exerciseListTile;
              },
            ),
          ],
        );
      },
    );
  }
}

class ExerciseInfoView extends StatefulWidget {
  const ExerciseInfoView({required this.exercise, this.refresh, super.key});

  final Exercise exercise;
  final void Function()? refresh;

  @override
  State<ExerciseInfoView> createState() => _ExerciseInfoViewState();
}

class _ExerciseInfoViewState extends State<ExerciseInfoView>
    with SingleTickerProviderStateMixin {
  final historyStream =
      BehaviorSubject<List<(Exercise, int, Workout)>>.seeded([]);
  late final StreamSubscription historySub;
  late final tabController = TabController(
    length: getTabs(widget.exercise, [], [], []).length,
    vsync: this,
  );

  @override
  void initState() {
    super.initState();
    final HistoryController controller = Get.find();
    historyStream.add(getHistory());
    historySub = controller.history.listen((_) {
      historyStream.add(getHistory());
    });
    if (!widget.exercise.hasExplanation) {
      logger.i("Exercise ${widget.exercise.id} has no explanation");
    }
  }

  @override
  void dispose() {
    historyStream.close();
    historySub.cancel();
    super.dispose();
  }

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

  List<Widget> getTabs(
          Exercise exercise,
          List<(Workout, Exercise)> chartHistory,
          List<(Exercise, int, Workout)> history,
          List<ListTileTheme> infoTiles) =>
      [
        SafeArea(
          bottom: false,
          child: _homeBody(exercise, chartHistory, history, infoTiles),
        ),
        SafeArea(
          bottom: false,
          child: _historyBody(exercise, chartHistory, history),
        ),
        if (exercise.standard && exercise.explanation != null)
          SafeArea(
            bottom: false,
            child: _explanationBody(exercise),
          ),
      ];

  late final category = exerciseStandardLibrary[widget.exercise.category];

  @override
  Widget build(BuildContext context) {
    final exercise = widget.exercise;

    return ThemedSubtree(
      color: category?.color ?? Theme.of(context).colorScheme.primary,
      child: DetailsView(
        child: StreamBuilder<List<(Exercise, int, Workout)>>(
          stream: historyStream,
          initialData: const <(Exercise, int, Workout)>[],
          builder: (context, historySnapshot) {
            final history = historySnapshot.data ?? [];

            final infoTiles = _getInfoTiles(exercise, context);
            final chartHistory = history.map((e) => (e.$3, e.$1)).toList();
            chartHistory.sort(
                (a, b) => a.$1.startingDate!.compareTo(b.$1.startingDate!));

            final tabs = getTabs(exercise, chartHistory, history, infoTiles);

            return Scaffold(
              appBar: AppBar(
                title: Text.rich(TextSpan(children: [
                  if (exercise.isCustom) ...[
                    const WidgetSpan(
                      child: CustomExerciseBadge(short: true),
                      alignment: PlaceholderAlignment.middle,
                    ),
                    const TextSpan(text: " "),
                  ],
                  TextSpan(text: exercise.displayName),
                ])),
                leading: MDVConfiguration.backButtonOf(context),
                automaticallyImplyLeading: MDVConfiguration.of(context) == null,
                actions: [
                  if (exercise.isCustom)
                    PopupMenuButton(
                      key: const Key("menu"),
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          child: Text("actions.edit".t),
                          onTap: () async {
                            final newExercise =
                                await Get.find<ExercisesController>()
                                    .editExercise(exercise, history);
                            if (context.mounted && newExercise != null) {
                              widget.refresh?.call();
                              MDVConfiguration.of(context)?.push(
                                context,
                                ExerciseInfoView(exercise: newExercise),
                                id: newExercise.key,
                              );
                            }
                          },
                        ),
                        if (history.isEmpty)
                          PopupMenuItem(
                            child: Text(
                              "actions.remove".t,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                            onTap: () async {
                              final delete = await Go.confirm(
                                  "exercise.delete.title",
                                  "exercise.delete.body");
                              if (delete) {
                                Get.find<ExercisesController>()
                                    .deleteExercise(exercise);
                                widget.refresh?.call();
                                Get.back();
                              }
                            },
                          ),
                      ],
                    ),
                ],
                bottom: TabBar(
                  tabAlignment: Platform.isMacOS || Platform.isIOS
                      ? TabAlignment.center
                      : TabAlignment.startOffset,
                  controller: tabController,
                  tabs: [
                    Tab(
                      icon: const Icon(GTIcons.home),
                      text: "exercise.info.home".t,
                    ),
                    Tab(
                      icon: const Icon(GTIcons.history),
                      text: "exercise.info.history".t,
                    ),
                    Tab(
                      icon: const Icon(GTIcons.explanation),
                      text: "exercise.info.explanation".t,
                    ),
                  ].take(tabs.length).toList(),
                  isScrollable: true,
                ),
              ),
              body: ListTileTheme(
                contentPadding: EdgeInsets.zero,
                child: TabBarView(
                  controller: tabController,
                  children: tabs,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _homeBody(Exercise exercise, List<(Workout, Exercise)> chartHistory,
      List<(Exercise, int, Workout)> history, List<ListTileTheme> infoTiles) {
    final ongoingWorkout = Get.isRegistered<WorkoutController>()
        ? Get.find<WorkoutController>().synthesizeTemporaryWorkout()
        : null;
    final ongoingWorkoutData = ongoingWorkout != null
        ? (
            ongoingWorkout,
            exercise.copyWith(
              sets: [
                for (final set in ongoingWorkout.flattenedExercises
                    .where((e) => e is Exercise && exercise.isTheSameAs(e))
                    .fold([], (prev, e) {
                  prev.addAll(e.sets);
                  return prev;
                }))
                  if (set.done) set,
              ],
            ),
          )
        : null;
    return ThemedSubtree.builder(
      color: category?.color ?? Theme.of(context).colorScheme.primary,
      enabled: Get.find<SettingsController>().tintExercises.value,
      builder: (context) {
        return CustomScrollView(
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
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16).copyWith(top: 0),
                child: Text.rich(
                  TextSpan(children: [
                    if (exercise.primaryMuscleGroup != GTMuscleGroup.none) ...[
                      TextSpan(
                          text: "exercise.info.primaryMuscleGroup".tParams({
                        "muscleGroup":
                            "muscleGroups.${exercise.primaryMuscleGroup.name}"
                                .t,
                      })),
                      if (exercise.secondaryMuscleGroups.isNotEmpty) ...[
                        const TextSpan(text: "\n"),
                        TextSpan(
                          text: "exercise.info.secondaryMuscleGroups".tParams({
                            "muscleGroups": exercise.secondaryMuscleGroups
                                .map((e) => "muscleGroups.${e.name}".t)
                                .join(", "),
                          }),
                        ),
                      ],
                    ],
                    const TextSpan(text: "\n"),
                    TextSpan(
                      text: "exercise.info.equipment".tParams({
                        "equipment": exercise.gymEquipment.localizedName,
                      }),
                    ),
                    if (kDebugMode) ...[
                      const TextSpan(text: "\n"),
                      TextSpan(
                        text: "Parameters: ${exercise.parameters}",
                      ),
                    ]
                  ]),
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            ),
            if (history.isEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text("exercise.info.noHistory".t),
                ),
              ),
            ],
            if (chartHistory.isNotEmpty &&
                ExerciseHistoryChart.shouldShow(
                    chartHistory, ongoingWorkout != null))
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverToBoxAdapter(
                  child: ExerciseHistoryChart(
                    key: ValueKey(chartHistory.length),
                    children: chartHistory,
                    ongoing: ongoingWorkoutData,
                  ),
                ),
              ),
            if (history.isNotEmpty && infoTiles.length > 1)
              SliverList(
                delegate: SliverChildListDelegate(infoTiles),
              ),
            if (kDebugMode) ...[
              const SliverToBoxAdapter(
                child: SizedBox(height: 8),
              ),
              SliverToBoxAdapter(
                child: Text(
                  "id: ${widget.exercise.id}",
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            const SliverToBoxAdapter(
              child: SizedBox(height: 8),
            ),
            SliverPadding(
              padding: MediaQuery.of(context).padding.copyWith(
                    top: 0,
                    left: 0,
                    right: 0,
                  ),
              sliver: const SliverToBoxAdapter(
                child: SizedBox.shrink(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _historyBody(Exercise exercise, List<(Workout, Exercise)> chartHistory,
      List<(Exercise, int, Workout)> history) {
    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
        SliverList.builder(
          itemCount: history.length,
          itemBuilder: (context, index) {
            return Card.outlined(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                      highlight: false,
                      weightUnit: history[index].$3.weightUnit,
                      distanceUnit: history[index].$3.distanceUnit,
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          TerseWorkoutListTile(
                            workout: history[index].$3,
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        Go.to(
                          () => ExercisesView(
                            workout: history[index].$3,
                            highlightExercise: (e) =>
                                e.id == history[index].$1.id,
                          ),
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
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
        SliverPadding(
          padding: MediaQuery.of(context).padding.copyWith(
                top: 0,
                left: 0,
                right: 0,
              ),
          sliver: const SliverToBoxAdapter(
            child: SizedBox.shrink(),
          ),
        ),
      ],
    );
  }

  Widget _explanationBody(Exercise exercise) {
    return ThemedSubtree.builder(
      color: category?.color ?? Theme.of(context).colorScheme.primary,
      enabled: Get.find<SettingsController>().tintExercises.value,
      builder: (context) {
        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: MarkdownBody(
                  data: exercise.explanation!,
                  styleSheet:
                      MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                    a: TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                  onTapLink: (text, href, title) {
                    if (href == null) return;
                    final uri = Uri.tryParse(href);
                    if (uri == null) return;
                    if (uri.scheme == "exercise" && uri.host == "library") {
                      final id = uri.pathSegments.first;
                      logger.d(id);
                      final exercise = getStandardExerciseByID(id);
                      if (exercise != null) {
                        final config = MDVConfiguration.of(context);
                        if (config == null) {
                          Go.to(() => ExerciseInfoView(exercise: exercise));
                        } else {
                          config.push(
                            context,
                            ExerciseInfoView(exercise: exercise),
                            id: exercise.key,
                          );
                        }
                      } else {
                        logger.e("Exercise not found: $id");
                      }
                    }
                  },
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              sliver: SliverToBoxAdapter(
                child: Text(
                  "exercise.info.explanationDisclaimer".t,
                  style: context.theme.textTheme.labelSmall,
                ),
              ),
            ),
            SliverPadding(
              padding: MediaQuery.of(context).padding.copyWith(
                    top: 0,
                    left: 0,
                    right: 0,
                  ),
              sliver: const SliverToBoxAdapter(
                child: SizedBox.shrink(),
              ),
            ),
          ],
        );
      },
    );
  }

  List<ListTileTheme> _getInfoTiles(Exercise exercise, BuildContext context) {
    final history = historyStream.value;
    if (history.isEmpty) return [];

    const nullTile = SizedBox.shrink();
    final tiles = <Builder>[
      if ([GTSetParameters.repsWeight, GTSetParameters.timeWeight]
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
                to: settingsController.weightUnit.value);
            if (value > bestScore) {
              best = hist;
              bestScore = value;
            }
          }

          if (bestScore < 0) return nullTile;

          return ExerciseInfoTile(
            "exercise.info.heaviestWeight.label".t,
            bestScore.userFacingWeight,
            onTap: () {
              Go.to(() => ExercisesView(workout: best.$3));
            },
          );
        }),
      if ([GTSetParameters.repsWeight].contains(exercise.parameters))
        Builder(builder: (context) {
          var best = history.first;
          var bestScore = -1.0;

          for (final hist in history) {
            final (Exercise exercise, int _, Workout workout) = hist;
            if (exercise.sets.where((set) => set.done).isEmpty) continue;
            var val = exercise.sets
                .where((set) => set.done)
                .map((set) => set.oneRepMax)
                .whereType<num>()
                .safeMax
                ?.toDouble();
            if (val == null) continue;
            final value = Weights.convert(
                value: val,
                from: workout.weightUnit,
                to: settingsController.weightUnit.value);
            if (value > bestScore) {
              best = hist;
              bestScore = value;
            }
          }

          if (bestScore < 0) return nullTile;

          return ExerciseInfoTile(
            "exercise.info.best1rm.label".t,
            bestScore.userFacingWeight,
            onTap: () {
              Go.to(() => ExercisesView(workout: best.$3));
            },
          );
        }),
      if ([GTSetParameters.repsWeight].contains(exercise.parameters))
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
                  to: settingsController.weightUnit.value);
              if ((value * set.reps!) > bestScore) {
                best = hist;
                bestScore = (value * set.reps!);
                bestWeight = value;
                bestReps = set.reps!;
              }
            }
          }

          if (bestReps == 0) return nullTile;

          return ExerciseInfoTile(
            "exercise.info.bestSetVolume.label".t,
            "${bestWeight.userFacingWeight} × $bestReps",
            onTap: () {
              Go.to(() => ExercisesView(workout: best.$3));
            },
          );
        }),
      if ([GTSetParameters.repsWeight, GTSetParameters.timeWeight]
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
                to: settingsController.weightUnit.value);
            if (value > bestScore) {
              best = hist;
              bestScore = value;
            }
          }

          if (bestScore < 0) return nullTile;

          return ExerciseInfoTile(
            "exercise.info.bestSessionVolume.label".t,
            bestScore.userFacingWeight,
            onTap: () {
              Go.to(() => ExercisesView(workout: best.$3));
            },
          );
        })
    ];

    if (tiles.isEmpty) return [];
    if (tiles
        .map((bld) => bld.build(context))
        .every((tile) => tile == nullTile)) return [];

    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text("exercise.info.usefulData".t,
            style: Theme.of(context).textTheme.labelLarge!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                )),
      ),
      ...tiles,
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

class DebugExercisesWithoutExplanationList extends StatelessWidget {
  const DebugExercisesWithoutExplanationList({super.key});

  @override
  Widget build(BuildContext context) {
    final filtered =
        exerciseStandardLibraryAsList.where((e) => !e.hasExplanation).toList();
    return Scaffold(
      appBar: AppBar(
        title: Text("${"exercise.info.explanation".t} [${filtered.length}]"),
      ),
      body: ListView.builder(
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final category = filtered[index].id.split(".")[1];
          return ExerciseListTile(
            exercise: filtered[index],
            trailing: Text(category),
            selected: false,
            isConcrete: false,
            onTap: () {
              final name = filtered[index].id.split(".").last;

              Clipboard.setData(ClipboardData(text: name));
            },
          );
        },
      ),
    );
  }
}

extension _MDView on ExerciseListTile {
  MasterItem getAsMasterItem(
    BuildContext context, {
    required Widget Function(BuildContext)? detailsBuilder,
  }) {
    final ListTile tile = build(context) as ListTile;
    return MasterItem(
      tile.title!,
      leading: tile.leading,
      subtitle: tile.subtitle,
      trailing: tile.trailing,
      detailsBuilder: detailsBuilder,
      id: exercise.key,
    );
  }
}

extension _MDItemConfig on WorkoutExercisable {
  String get key {
    if (this is! Exercise) return "";
    if (asExercise.standard) return id;
    return jsonEncode(asExercise.toJson());
  }
}
