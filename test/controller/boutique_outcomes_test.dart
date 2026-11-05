import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/controller/boutique_controller.dart';
import 'package:gymtracker/model/boutique.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:mocktail/mocktail.dart';

class _Repository extends Mock implements BoutiqueRepository {}

void main() {
  late _Repository repository;
  late BoutiqueController controller;
  late List<Workout> installed;
  setUp(() {
    repository = _Repository();
    installed = [];
    controller = BoutiqueController(
      repository: repository,
      version: () => '1.0.0',
      installRoutines: (routines) => installed.addAll(routines),
    );
    when(() => repository.getSettings()).thenAnswer(
      (_) async =>
          const BoutiqueSettings(enabled: true, compatibility: '>=1.0.0'),
    );
  });
  test('install preserves all routines, order, and notes', () {
    final routines = [
      Workout(name: 'A', exercises: [], infobox: 'Notes'),
      Workout(name: 'B', exercises: []),
    ];
    controller.install(
      BoutiquePackage(
        id: 'p',
        name: 'Plan',
        description: '',
        routines: routines,
      ),
    );
    expect(installed, routines);
    expect(installed.first.infobox, 'Notes');
  });
  test('failed package download installs nothing and can be retried', () async {
    when(
      () => repository.getPackages('p', language: 'it'),
    ).thenThrow(StateError('offline'));
    final failure = await controller.getPackages('p', language: 'it');
    expect(failure.error, BoutiqueError.unknown);
    expect(installed, isEmpty);
    when(
      () => repository.getPackages('p', language: 'it'),
    ).thenAnswer((_) async => []);
    expect(
      (await controller.getPackages('p', language: 'it')).error,
      BoutiqueError.unknown,
    );
    controller.invalidateCache();
    expect(
      (await controller.getPackages('p', language: 'it')).success,
      isEmpty,
    );
    verify(() => repository.getPackages('p', language: 'it')).called(2);
  });
  test('disabled boutique refuses package download', () async {
    when(() => repository.getSettings()).thenAnswer(
      (_) async =>
          const BoutiqueSettings(enabled: false, compatibility: '>=1.0.0'),
    );
    expect(
      (await controller.getPackages('p', language: 'en')).error,
      BoutiqueError.unknown,
    );
    verifyNever(() => repository.getPackages('p', language: 'en'));
    expect(installed, isEmpty);
  });
}
