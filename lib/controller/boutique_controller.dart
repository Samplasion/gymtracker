import 'package:gymtracker/model/model.dart';
import 'package:gymtracker/repository/boutique.dart';
import 'package:gymtracker/service/logger.dart';
import 'package:gymtracker/service/version.dart';
import 'package:gymtracker/struct/request_cache.dart';
import 'package:pub_semver/pub_semver.dart';

export 'package:gymtracker/repository/boutique.dart' show BoutiqueRepository;

class BoutiqueController {
  final BoutiqueRepository _repository;
  final void Function(List<Workout>) _installRoutines;
  final String Function() _version;
  final _settings = RequestCache<String, BoutiqueSettings>(
    const Duration(minutes: 30),
  );
  final _categories = RequestCache<String, List<BoutiqueCategory>>(
    const Duration(minutes: 30),
  );
  final _packages = RequestCache<String, List<BoutiquePackage>>(
    const Duration(minutes: 30),
  );
  void invalidateCache() {
    _settings.clear();
    _categories.clear();
    _packages.clear();
  }

  BoutiqueController({
    BoutiqueRepository? repository,
    String Function()? version,
    required void Function(List<Workout>) installRoutines,
  }) : _repository = repository ?? createBoutiqueRepository(),
       _version = version ?? (() => VersionService().packageInfo.version),
       _installRoutines = installRoutines;

  Future<BoutiqueSettings> getSettings() async {
    return _settings.get('settings', _repository.getSettings);
  }

  Future<void> _checkVersion() async {
    final settings = await getSettings();
    if (!settings.enabled) throw BoutiqueError.unknown;
    final range = VersionConstraint.parse(settings.compatibility);
    if (!range.allows(Version.parse(_version()))) {
      throw BoutiqueError.version;
    }
  }

  BoutiqueApiResponse<List<BoutiqueCategory>> getCategories() async {
    try {
      await _checkVersion();
      final response = await _categories.get(
        'categories',
        _repository.getCategories,
      );
      return BoutiqueResponse.success(response);
    } catch (e, s) {
      logger.e("ERROR", error: e, stackTrace: s);
      return BoutiqueResponse.error(
        e is BoutiqueError ? e : BoutiqueError.unknown,
      );
    }
  }

  BoutiqueApiResponse<List<BoutiquePackage>> getPackages(
    String categoryId, {
    required String language,
  }) async {
    try {
      await _checkVersion();
      final response = await _packages.get(
        '$categoryId/$language',
        () => _repository.getPackages(categoryId, language: language),
      );
      return BoutiqueResponse.success(response);
    } catch (e, s) {
      logger.e("ERROR", error: e, stackTrace: s);
      return BoutiqueResponse.error(
        e is BoutiqueError ? e : BoutiqueError.unknown,
      );
    }
  }

  void install(BoutiquePackage package) {
    _installRoutines(package.routines);
  }
}

typedef BoutiqueApiResponse<T> = Future<BoutiqueResponse<T, BoutiqueError>>;

enum BoutiqueError { unknown, version }

sealed class BoutiqueResponse<Ok, Err> {
  const BoutiqueResponse();

  factory BoutiqueResponse.success(Ok data) => _BoutiqueResponseSuccess(data);
  factory BoutiqueResponse.error(Err error) => _BoutiqueResponseError(error);

  Ok? get success => this is _BoutiqueResponseSuccess
      ? (this as _BoutiqueResponseSuccess).data
      : null;
  Err? get error => this is _BoutiqueResponseError
      ? (this as _BoutiqueResponseError).error
      : null;

  bool get isSuccess => this is _BoutiqueResponseSuccess;
  bool get isError => this is _BoutiqueResponseError;
}

class _BoutiqueResponseSuccess<T> extends BoutiqueResponse<T, Never> {
  final T data;

  _BoutiqueResponseSuccess(this.data);
}

class _BoutiqueResponseError<T> extends BoutiqueResponse<Never, T> {
  @override
  final T error;

  _BoutiqueResponseError(this.error);
}
