import 'package:flutter/material.dart';
import 'package:gymtracker/controller/migrations_controller.dart';
import 'package:gymtracker/icons/gymtracker_icons.dart';
import 'package:gymtracker/model/exercise.dart';
import 'package:gymtracker/model/set.dart';
import 'package:gymtracker/service/localizations.dart';
import 'package:gymtracker/struct/data_migration.dart';
import 'package:gymtracker/utils/extensions.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/components/alert_banner.dart';
import 'package:gymtracker/view/components/controlled.dart';
import 'package:gymtracker/view/exercise_picker.dart';
import 'package:gymtracker/view/exercises.dart';
import 'package:gymtracker/view/routines.dart';
import 'package:gymtracker/view/utils/exercise.dart';
import 'package:gymtracker/view/utils/exercise_form_picker.dart';
import 'package:gymtracker/view/utils/history_workout.dart';
import 'package:gymtracker/view/utils/input_decoration.dart';

class AllMigrationsView extends ControlledWidget<MigrationsController> {
  const AllMigrationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text("migrations.title".t),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              for (final migration in controller.migrations)
                ListTile(
                  title: Text(migration.title),
                  subtitle: Text(migration.description),
                  trailing: const Icon(GTIcons.lt_chevron),
                  onTap: migration.action,
                ),
            ]),
          ),
        ],
      ),
    );
  }
}

class CustomToLibraryMigrationSetupView extends StatefulWidget {
  final UIMigration<CustomToLibraryExerciseMigration> migration;

  const CustomToLibraryMigrationSetupView(this.migration, {super.key});

  @override
  State<CustomToLibraryMigrationSetupView> createState() =>
      _CustomToLibraryMigrationSetupViewState();
}

class _CustomToLibraryMigrationSetupViewState extends ControlledState<
    CustomToLibraryMigrationSetupView, MigrationsController> {
  Exercise? from, to;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("migrations.customToLibraryExercise.title".t),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "migrations.customToLibraryExercise.fields.from.title".t,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ExerciseFormPicker(
                exercise: from,
                onChanged: (ex) => setState(() => from = ex),
                filter: ExercisePickerFilter.custom,
                individualFilter: (ex) {
                  if (to == null) return true;
                  return ex.parameters == to!.parameters;
                },
                decoration: GymTrackerInputDecoration(
                  labelText:
                      "migrations.customToLibraryExercise.fields.from.label".t,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "migrations.customToLibraryExercise.fields.to.title".t,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ExerciseFormPicker(
                exercise: to,
                onChanged: (ex) => setState(() => to = ex),
                filter: ExercisePickerFilter.library,
                individualFilter: (ex) {
                  if (from == null) return true;
                  return ex.parameters == from!.parameters;
                },
                decoration: GymTrackerInputDecoration(
                  labelText:
                      "migrations.customToLibraryExercise.fields.to.label".t,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _nextCallback(),
                child: Text("migrations.common.actions.next".t),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void Function()? _nextCallback() {
    if (from == null || to == null) return null;
    if (from!.parameters != to!.parameters) return null;
    return () {
      // Go.to(() => CustomToLibraryMigrationPreviewView(from: from!, to: to!));
      widget.migration.preview(CustomToLibraryExerciseMigration(from!, to!));
    };
  }
}

class CustomToLibraryMigrationPreviewView
    extends ControlledWidget<MigrationsController> {
  final CustomToLibraryExerciseMigration migration;

  CustomToLibraryMigrationPreviewView({
    super.key,
    required this.migration,
  });

  late final affectedRoutines = migration.affectedRoutines;
  late final affectedWorkouts = migration.affectedHistory.reversed.toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("migrations.common.preview".t),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                SafeArea(
                  bottom: false,
                  child: Text(
                    "migrations.customToLibraryExercise.preview.from".t,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 8),
                ExerciseListTile(
                  exercise: migration.from,
                  selected: false,
                  isConcrete: false,
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 16),
                SafeArea(
                  bottom: false,
                  child: Text(
                    "migrations.customToLibraryExercise.preview.to".t,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 8),
                ExerciseListTile(
                  exercise: migration.to,
                  selected: false,
                  isConcrete: false,
                  contentPadding: EdgeInsets.zero,
                ),
                if (affectedRoutines.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  SafeArea(
                    bottom: false,
                    child: Text(
                      "migrations.customToLibraryExercise.preview.affectedRoutines"
                          .t,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ]),
            ),
          ),
          if (affectedRoutines.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 16),
              sliver: SliverList.builder(
                itemBuilder: (context, index) {
                  return MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: TerseRoutineListTile(
                      routine: affectedRoutines[index],
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16.0),
                      showIcon: true,
                      onTap: () {
                        Go.to(() => ExercisesView(
                              workout: affectedRoutines[index],
                              highlightExercise: (we) {
                                if (!we.isExercise) return false;
                                final ex = we.asExercise;
                                return migration.from.isTheSameAs(ex);
                              },
                            ));
                      },
                    ),
                  );
                },
                itemCount: affectedRoutines.length,
              ),
            ),
          if (affectedWorkouts.isNotEmpty) ...[
            SliverPadding(
              padding: const EdgeInsets.all(16).copyWith(top: 0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  SafeArea(
                    bottom: false,
                    child: Text(
                      "migrations.customToLibraryExercise.preview.affectedWorkouts"
                          .t,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ]),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 16),
              sliver: SliverList.builder(
                itemBuilder: (context, i) {
                  return TerseWorkoutListTile(
                    workout: affectedWorkouts[i],
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16.0),
                    onTap: () {
                      Go.to(() => ExercisesView(
                            workout: affectedWorkouts[i],
                            highlightExercise: (we) {
                              if (!we.isExercise) return false;
                              final ex = we.asExercise;
                              return migration.from.isTheSameAs(ex);
                            },
                          ));
                    },
                  );
                },
                itemCount: affectedWorkouts.length,
              ),
            ),
          ],
          SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.of(context).padding.bottom,
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: context.colorScheme.surfaceContainerHigh,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SafeArea(
            child: FilledButton(
              onPressed: () {
                if (affectedRoutines.isEmpty && affectedWorkouts.isEmpty) {
                  return null;
                }
                return () {
                  controller.applyMigration(migration);
                };
              }(),
              child: Text("migrations.common.actions.apply".t),
            ),
          ),
        ),
      ),
    );
  }
}

class RemoveUnusedExercisesMigrationPreviewView
    extends ControlledWidget<MigrationsController> {
  final RemoveUnusedExercisesMigration migration;

  RemoveUnusedExercisesMigrationPreviewView({
    super.key,
    required this.migration,
  });

  late final affectedExercises = migration.affectedExercises;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("migrations.common.preview".t),
      ),
      body: CustomScrollView(
        slivers: [
          if (affectedExercises.isNotEmpty) ...[
            SliverPadding(
              padding: const EdgeInsets.all(16).copyWith(top: 0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  SafeArea(
                    bottom: false,
                    child: Text(
                      "migrations.removeUnusedExercises.preview.affectedExercises"
                          .t,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ]),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 16),
              sliver: SliverList.builder(
                itemBuilder: (context, index) {
                  return MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: ExerciseListTile(
                      exercise: affectedExercises[index],
                      selected: false,
                      isConcrete: false,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16.0),
                    ),
                  );
                },
                itemCount: affectedExercises.length,
              ),
            ),
          ] else ...[
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  SafeArea(
                    bottom: false,
                    child: Text(
                      "migrations.removeUnusedExercises.preview.noAffected".t,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ]),
              ),
            ),
          ],
          SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.of(context).padding.bottom,
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: context.colorScheme.surfaceContainerHigh,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SafeArea(
            child: FilledButton(
              onPressed: () {
                if (affectedExercises.isEmpty) {
                  return null;
                }
                return () {
                  controller.applyMigration(migration);
                };
              }(),
              child: Text("migrations.common.actions.apply".t),
            ),
          ),
        ),
      ),
    );
  }
}

class RemoveWeightFromCustomExerciseMigrationSetupView extends StatefulWidget {
  final UIMigration<RemoveWeightFromCustomExerciseMigration> migration;

  const RemoveWeightFromCustomExerciseMigrationSetupView(this.migration,
      {super.key});

  @override
  State<RemoveWeightFromCustomExerciseMigrationSetupView> createState() =>
      _RemoveWeightFromCustomExerciseMigrationSetupViewState();
}

class _RemoveWeightFromCustomExerciseMigrationSetupViewState
    extends ControlledState<RemoveWeightFromCustomExerciseMigrationSetupView,
        MigrationsController> {
  Exercise? ex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("migrations.removeWeightFromCustomExercise.title".t),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "migrations.removeWeightFromCustomExercise.fields.exercise.title"
                    .t,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ExerciseFormPicker(
                exercise: ex,
                onChanged: (ex) => setState(() => this.ex = ex),
                filter: ExercisePickerFilter.custom,
                individualFilter: (ex) {
                  return ex.parameters == GTSetParameters.repsWeight;
                },
                decoration: GymTrackerInputDecoration(
                  labelText:
                      "migrations.removeWeightFromCustomExercise.fields.exercise.label"
                          .t,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _nextCallback(),
                child: Text("migrations.common.actions.next".t),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void Function()? _nextCallback() {
    if (ex == null) return null;
    return () {
      widget.migration.preview(RemoveWeightFromCustomExerciseMigration(ex!));
    };
  }
}

class RemoveWeightFromCustomExerciseMigrationPreviewView
    extends ControlledWidget<MigrationsController> {
  final RemoveWeightFromCustomExerciseMigration migration;

  RemoveWeightFromCustomExerciseMigrationPreviewView({
    super.key,
    required this.migration,
  });

  late final affectedWorkouts = migration.affectedHistory;
  late final affectedRoutines = migration.affectedRoutines;
  late final isCompatible = migration.isCompatible;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("migrations.common.preview".t),
      ),
      body: CustomScrollView(
        slivers: [
          if (!isCompatible)
            SliverPadding(
              padding: const EdgeInsets.all(16).copyWith(bottom: 0),
              sliver: SliverToBoxAdapter(
                child: SafeArea(
                  child: AlertBanner(
                    color: Colors.amber,
                    title:
                        "migrations.removeWeightFromCustomExercise.preview.incompatible.title"
                            .t,
                    text: Text(
                      "migrations.removeWeightFromCustomExercise.preview.incompatible.text"
                          .t,
                    ),
                  ),
                ),
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                SafeArea(
                  bottom: false,
                  child: Text(
                    "migrations.removeWeightFromCustomExercise.preview.selected"
                        .t,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 8),
                ExerciseListTile(
                  exercise: migration.exercise,
                  selected: false,
                  isConcrete: false,
                  contentPadding: EdgeInsets.zero,
                ),
                if (affectedRoutines.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  SafeArea(
                    bottom: false,
                    child: Text(
                      "migrations.removeWeightFromCustomExercise.preview.affectedRoutines"
                          .t,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ]),
            ),
          ),
          if (affectedRoutines.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 16),
              sliver: SliverList.builder(
                itemBuilder: (context, index) {
                  return MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: TerseRoutineListTile(
                      routine: affectedRoutines[index],
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16.0),
                      showIcon: true,
                      onTap: () {
                        Go.to(() => ExercisesView(
                              workout: affectedRoutines[index],
                              highlightExercise: (we) {
                                if (!we.isExercise) return false;
                                final ex = we.asExercise;
                                return migration.exercise.isTheSameAs(ex);
                              },
                            ));
                      },
                    ),
                  );
                },
                itemCount: affectedRoutines.length,
              ),
            ),
          if (affectedWorkouts.isNotEmpty) ...[
            SliverPadding(
              padding: const EdgeInsets.all(16).copyWith(top: 0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  SafeArea(
                    bottom: false,
                    child: Text(
                      "migrations.removeWeightFromCustomExercise.preview.affectedWorkouts"
                          .t,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ]),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 16),
              sliver: SliverList.builder(
                itemBuilder: (context, i) {
                  return TerseWorkoutListTile(
                    workout: affectedWorkouts[i],
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16.0),
                    onTap: () {
                      Go.to(() => ExercisesView(
                            workout: affectedWorkouts[i],
                            highlightExercise: (we) {
                              if (!we.isExercise) return false;
                              final ex = we.asExercise;
                              return migration.exercise.isTheSameAs(ex);
                            },
                          ));
                    },
                  );
                },
                itemCount: affectedWorkouts.length,
              ),
            ),
          ],
          SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.of(context).padding.bottom,
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: context.colorScheme.surfaceContainerHigh,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SafeArea(
            child: FilledButton(
              onPressed: !isCompatible
                  ? null
                  : () {
                      if (affectedWorkouts.isEmpty &&
                          affectedRoutines.isEmpty) {
                        return null;
                      }
                      return () {
                        controller.applyMigration(migration);
                      };
                    }(),
              child: Text("migrations.common.actions.apply".t),
            ),
          ),
        ),
      ),
    );
  }
}
