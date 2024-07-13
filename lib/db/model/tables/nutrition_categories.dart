import 'package:drift/drift.dart';

@DataClassName('DBNutritionCategory')
class NutritionCategories extends Table {
  DateTimeColumn get referenceDate => dateTime()();
  TextColumn get jsonData => text()();
}
