import 'package:drift/drift.dart';
import 'package:gymtracker/db/model/tables/base.dart';

class Preferences extends AnyDataTable {
  BoolColumn get onboardingComplete =>
      boolean().withDefault(const Constant(false))();
}
