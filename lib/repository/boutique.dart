import 'package:gymtracker/model/boutique.dart';
import 'package:gymtracker/service/test.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'boutique.g.dart';

abstract class BoutiqueRepository {
  Future<BoutiqueSettings> getSettings();
  Future<List<BoutiqueCategory>> getCategories();
  Future<List<BoutiquePackage>> getPackages(
    String categoryId, {
    required String language,
  });
}

class _TestBoutiqueRepositoryImpl implements BoutiqueRepository {
  @override
  Future<List<BoutiqueCategory>> getCategories() async {
    return [];
  }

  @override
  Future<List<BoutiquePackage>> getPackages(
    String categoryId, {
    required String language,
  }) async {
    return [];
  }

  @override
  Future<BoutiqueSettings> getSettings() async {
    return BoutiqueSettings(compatibility: "0.0.0", enabled: false);
  }
}

class _BoutiqueRepositoryImpl implements BoutiqueRepository {
  final _db = Supabase.instance.client;

  @override
  Future<BoutiqueSettings> getSettings() async {
    final response = await _db
        .from('boutique_settings')
        .select()
        .limit(1)
        .single();
    return BoutiqueSettings.fromJson(response);
  }

  @override
  Future<List<BoutiqueCategory>> getCategories() async {
    final response = await _db
        .from('boutique_categories')
        .select()
        .order('order', ascending: true);
    return response.map((e) => BoutiqueCategory.fromJson(e)).toList();
  }

  @override
  Future<List<BoutiquePackage>> getPackages(
    String categoryId, {
    required String language,
  }) async {
    final response = await _db
        .from('boutique_packages')
        .select("*, boutique_routines(*, boutique_routine_exercises(*))")
        .eq('category_id', categoryId);
    return response.map((e) => BoutiquePackage.fromJson(e, language)).toList();
  }
}

BoutiqueRepository createBoutiqueRepository() => TestService().isTest
    ? _TestBoutiqueRepositoryImpl()
    : _BoutiqueRepositoryImpl();

@Riverpod(keepAlive: true)
BoutiqueRepository boutiqueRepository(Ref ref) => createBoutiqueRepository();
