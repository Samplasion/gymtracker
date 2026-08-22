import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'preferences.g.dart';

@riverpod
Future<SharedPreferences> sharedPreferences(Ref ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs;
}
