import 'package:gymtracker/controller/boutique_controller.dart';
import 'package:gymtracker/controller/routines_controller.dart';
import 'package:gymtracker/model/boutique.dart';
import 'package:gymtracker/repository/boutique.dart';
import 'package:gymtracker/service/version.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'boutique.g.dart';

@Riverpod(keepAlive: true)
BoutiqueController boutiqueController(Ref ref) => BoutiqueController(
  repository: ref.watch(boutiqueRepositoryProvider),
  version: () => ref.read(versionServiceProvider).packageInfo.version,
  installRoutines: (routines) =>
      ref.read(routinesControllerProvider).installRoutines(routines),
);

@riverpod
Future<BoutiqueSettings> boutiqueSettings(Ref ref) =>
    ref.watch(boutiqueControllerProvider).getSettings();

@riverpod
BoutiqueApiResponse<List<BoutiqueCategory>> boutiqueCategories(Ref ref) async {
  final controller = ref.watch(boutiqueControllerProvider);
  final settings = await ref.watch(boutiqueSettingsProvider.future);
  if (!settings.enabled) return BoutiqueResponse.success([]);
  return controller.getCategories();
}

@riverpod
BoutiqueApiResponse<List<BoutiquePackage>> boutiquePackages(
  Ref ref,
  String categoryId, {
  required String language,
}) => ref
    .watch(boutiqueControllerProvider)
    .getPackages(categoryId, language: language);
