import 'package:gymtracker/struct/data_migration.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'migrations_controller.g.dart';

class MigrationsController {
  MigrationsController(this.ref);
  final Ref ref;
  void apply(DataMigration migration) => migration.apply();
}

@Riverpod(keepAlive: true)
MigrationsController migrationsController(Ref ref) => MigrationsController(ref);
