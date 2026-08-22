import 'package:get/get.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/service/database.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'db.g.dart';

// TODO: Do away with the database service and use the database directly in
// purpose-built repositories (like DAOs).
@Riverpod(keepAlive: true)
GTDatabase appDatabase(Ref ref) {
  final db = Get.find<DatabaseService>().db;
  return db;
}
