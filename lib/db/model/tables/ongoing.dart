import 'package:drift/drift.dart';
import 'package:gymtracker/db/model/tables/base.dart';

@DataClassName("OngoingDatum")
class OngoingData extends AnyDataTable {
  // Existing unowned saves remain recoverable until explicitly claimed.
  TextColumn get owner => text().withDefault(const Constant('legacy'))();

  @override
  Set<Column<Object>> get primaryKey => {owner};
}
