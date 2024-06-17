import 'package:get/get.dart';
import 'package:gymtracker/controller/serviceable_controller.dart';
import 'package:gymtracker/service/localizations.dart';
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
  List<UIMigration> get migrations => [
        UIMigration<CustomToLibraryExerciseMigration>(
          'migrations.customToLibraryExercise.title'.t,
          'migrations.customToLibraryExercise.description'.t,
          (uiMigration) =>
              Go.to(() => CustomToLibraryMigrationSetupView(uiMigration)),
          (dataMigration) => Go.to(() =>
              CustomToLibraryMigrationPreviewView(migration: dataMigration)),
          (dataMigration) => dataMigration.apply(),
        ),
        UIMigration<RemoveUnusedExercisesMigration>(
          'migrations.removeUnusedExercises.title'.t,
          'migrations.removeUnusedExercises.description'.t,
          (uiMigration) => Go.to(() =>
              RemoveUnusedExercisesMigrationPreviewView(
                  migration: RemoveUnusedExercisesMigration())),
          (dataMigration) => Go.to(() =>
              RemoveUnusedExercisesMigrationPreviewView(
                  migration: dataMigration)),
          (dataMigration) => dataMigration.apply(),
        ),
        UIMigration<RemoveWeightFromCustomExerciseMigration>(
          'migrations.removeWeightFromCustomExercise.title'.t,
          'migrations.removeWeightFromCustomExercise.description'.t,
          (uiMigration) => Go.to(() =>
              RemoveWeightFromCustomExerciseMigrationSetupView(uiMigration)),
          (dataMigration) => Go.to(() =>
              RemoveWeightFromCustomExerciseMigrationPreviewView(
                  migration: dataMigration)),
          (dataMigration) => dataMigration.apply(),
        ),
      ];

  @override
  void onServiceChange() {}

  void applyMigration(DataMigration migration) {
    migration.apply();
    Go.popUntil((route) => route.isFirst);
    Go.snack('migrations.common.migrated'.t);
  }
}
