import 'package:gymtracker/model/preferences.dart';
import 'package:gymtracker/provider/db.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings.g.dart';

@Riverpod(keepAlive: true)
Stream<Prefs> appPreferences(Ref ref) =>
    ref.watch(appDatabaseProvider).watchPreferences();
