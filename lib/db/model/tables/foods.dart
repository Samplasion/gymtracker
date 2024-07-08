import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

@DataClassName('DBFood')
class Foods extends Table {
  @override
  Set<Column<Object>> get primaryKey => {id};

  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  DateTimeColumn get dateAdded => dateTime()();
  DateTimeColumn get referenceDate => dateTime()();
  TextColumn get jsonData => text()();
}

class CustomBarcodeFoods extends Table {
  @override
  Set<Column<Object>> get primaryKey => {barcode};

  TextColumn get barcode => text()();
  TextColumn get jsonData => text()();
}

class FavoriteFoods extends Table {
  TextColumn get foodId => text().references(Foods, #id)();
}
