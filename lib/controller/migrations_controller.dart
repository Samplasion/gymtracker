import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:gymtracker/controller/serviceable_controller.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/struct/data_migration.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/view/migrations.dart';

class UIMigration<T extends DataMigration> {
  final String title;
  final String description;
  final void Function(T migration) preview;
  final void Function(T migration) apply;
  late final void Function() action;

  UIMigration(
    this.title,
    this.description,
    void Function(UIMigration<T>) action,
    this.preview,
    this.apply,
  ) {
    this.action = () {
      action(this);
    };
  }
}

class MigrationsController extends GetxController with ServiceableController {
  List<UIMigration> getMigrations({required BuildContext context}) => [
    UIMigration<CustomToLibraryExerciseMigration>(
      context.t.migrations.customToLibraryExercise.title,
      context.t.migrations.customToLibraryExercise.description,
      (uiMigration) =>
          Go.to(() => CustomToLibraryMigrationSetupView(uiMigration)),
      (dataMigration) => Go.to(
        () => CustomToLibraryMigrationPreviewView(migration: dataMigration),
      ),
      (dataMigration) => dataMigration.apply(),
    ),
    UIMigration<RemoveUnusedExercisesMigration>(
      context.t.migrations.removeUnusedExercises.title,
      context.t.migrations.removeUnusedExercises.description,
      (uiMigration) => Go.to(
        () => RemoveUnusedExercisesMigrationPreviewView(
          migration: RemoveUnusedExercisesMigration(),
        ),
      ),
      (dataMigration) => Go.to(
        () =>
            RemoveUnusedExercisesMigrationPreviewView(migration: dataMigration),
      ),
      (dataMigration) => dataMigration.apply(),
    ),
    UIMigration<RemoveWeightFromCustomExerciseMigration>(
      context.t.migrations.removeWeightFromCustomExercise.title,
      context.t.migrations.removeWeightFromCustomExercise.description,
      (uiMigration) => Go.to(
        () => RemoveWeightFromCustomExerciseMigrationSetupView(uiMigration),
      ),
      (dataMigration) => Go.to(
        () => RemoveWeightFromCustomExerciseMigrationPreviewView(
          migration: dataMigration,
        ),
      ),
      (dataMigration) => dataMigration.apply(),
    ),
    UIMigration<GenericMultiplyWeightInExerciseMigration>(
      context.t.migrations.doubleExerciseWeight.title,
      context.t.migrations.doubleExerciseWeight.description,
      (uiMigration) => Go.to(
        () => GenericMultiplyWeightInExerciseMigrationSetupView(
          uiMigration,
          multiplier: 2,
        ),
      ),
      (dataMigration) => Go.to(
        () => GenericMultiplyWeightInExerciseMigrationPreviewView(
          migration: dataMigration,
        ),
      ),
      (dataMigration) => dataMigration.apply(),
    ),
    UIMigration<GenericMultiplyWeightInExerciseMigration>(
      context.t.migrations.halveExerciseWeight.title,
      context.t.migrations.halveExerciseWeight.description,
      (uiMigration) => Go.to(
        () => GenericMultiplyWeightInExerciseMigrationSetupView(
          uiMigration,
          multiplier: 0.5,
        ),
      ),
      (dataMigration) => Go.to(
        () => GenericMultiplyWeightInExerciseMigrationPreviewView(
          migration: dataMigration,
        ),
      ),
      (dataMigration) => dataMigration.apply(),
    ),
  ];

  @override
  void onServiceChange() {}

  void applyMigration(BuildContext context, DataMigration migration) {
    migration.apply();
    Go.popUntil((route) => route.isFirst);
    Go.snack(context.t.migrations.common.migrated);
  }
}
