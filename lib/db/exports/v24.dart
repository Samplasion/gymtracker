import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/db/exports/v23.dart';

class VersionedJsonExportV24 extends VersionedJsonExportV23 {
  const VersionedJsonExportV24();
  @override
  int get version => 24;
  @override
  Future<Map<String, dynamic>> export(GTDatabase db) {
    final owner = db.currentUserId;
    return db.transaction(() async {
      final json = await super.export(db);
      final recipes = await db.watchRecipes().first;
      if (db.currentUserId != owner) {
        throw StateError('Account changed during export');
      }
      json['recipes'] = recipes.map((r) => r.toJson()).toList();
      return json;
    });
  }
}
