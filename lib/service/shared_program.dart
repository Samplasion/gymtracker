import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymtracker/db/database.dart';
import 'package:gymtracker/model/shared_program.dart';
import 'package:gymtracker/provider/db.dart';
import 'package:gymtracker/service/database.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final sharedProgramServiceProvider = Provider(
  (ref) => SharedProgramService(
    Supabase.instance.client,
    ref.watch(appDatabaseProvider),
  ),
);

class SharedProgramService {
  final SupabaseClient client;
  final GTDatabase db;
  SharedProgramService(this.client, this.db);
  static const site = String.fromEnvironment(
    'GYM_BRO_SITE_URL',
    defaultValue: 'https://gym-bro.techtonicfault.com',
  );
  Future<dynamic> request(
    String operation, [
    Map<String, dynamic> payload = const {},
  ]) async {
    final owner = db.currentUserId;
    if (operation != 'read' &&
        (owner == null || client.auth.currentUser?.id != owner)) {
      throw const FormatException('sign_in_required');
    }
    final response = await client.functions
        .invoke('personal-api', body: {...payload, 'operation': operation})
        .timeout(const Duration(seconds: 30));
    if (db.currentUserId != owner) {
      throw const FormatException('account_changed');
    }
    return response.data;
  }

  Future<SharedProgramV1> read(String token) async => SharedProgramV1.fromJson(
    Map<String, dynamic>.from(await request('read', {'token': token}) as Map),
  );
  Future<Uri> create(SharedProgramV1 program, String locale) async {
    final result =
        await request('share_create', {'document': program.document}) as Map;
    return Uri.parse('$site/$locale/share/${result['token']}');
  }

  Future<List<Map<String, dynamic>>> shares() async =>
      (await request('shares') as List)
          .map((x) => Map<String, dynamic>.from(x as Map))
          .toList();
  Future<void> revoke(String id) async {
    await request('share_revoke', {'id': id});
  }

  Future<void> import(String token, DatabaseService service) async {
    // Recheck revocation immediately before starting the atomic local write.
    final program = await read(token);
    final materialized = program.materialize();
    await service.transaction(() async {
      for (final e in materialized.customExercises) {
        await service.db.insertCustomExercise(e);
      }
      if (materialized.folder != null) {
        await service.addFolder(materialized.folder!);
      }
      for (final routine in materialized.routines) {
        await service.db.insertRoutine(routine);
      }
    });
  }
}
