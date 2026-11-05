import 'dart:convert';
import 'dart:typed_data';
// ignore: depend_on_referenced_packages
import 'package:cross_file/cross_file.dart';
// ignore: depend_on_referenced_packages
import 'package:file_picker_platform_interface/file_picker_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/view/actions/settings.dart';
import 'package:mocktail/mocktail.dart';
// ignore: depend_on_referenced_packages
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import '../test_helpers/mock_services.dart';
import '../test_helpers/widget_test_app.dart';

class _Picker extends Mock
    with MockPlatformInterfaceMixin
    implements FilePickerPlatform {}

final class _SelectedFile extends PlatformFile {
  @override
  String get name => 'hevy.csv';
  @override
  Uri get uri => Uri.parse('file:///virtual/hevy.csv');
  @override
  XFile get xFile => XFile.fromData(
    Uint8List.fromList(utf8.encode('hevy content')),
    name: name,
  );
  @override
  Future<int> length() async => (await readAsBytes()).length;
  @override
  Future<Uint8List> readAsBytes() async =>
      Uint8List.fromList(utf8.encode('hevy content'));
  @override
  Stream<Uint8List> readAsByteStream() => Stream.fromFuture(readAsBytes());
}

void main() {
  late FilePickerPlatform original;
  late _Picker picker;
  setUp(() async {
    MockServices.setup();
    await initTestLocalizations();
    await LocaleSettings.setLocale(AppLocale.en);
    original = FilePickerPlatform.instance;
    picker = _Picker();
    FilePickerPlatform.instance = picker;
    when(() => picker.pickFile()).thenAnswer((_) async => null);
  });
  tearDown(() {
    FilePickerPlatform.instance = original;
    MockServices.tearDown();
  });
  Future<void> open(WidgetTester tester) async {
    await tester.pumpWidget(
      WidgetTestApp(
        child: Builder(
          builder: (context) => TextButton(
            onPressed: () =>
                MockServices.settingsController.importSettings(context),
            child: const Text('Import file'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Import file'));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'dismiss import format chooser never opens a file picker or writes data',
    (tester) async {
      await open(tester);
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      verifyNever(() => picker.pickFile());
      verifyNever(() => MockServices.settingsController.importHevy(any()));
    },
  );
  testWidgets(
    'cancel native file selection imports nothing and shows no error',
    (tester) async {
      await open(tester);
      await tester.tap(find.text(t.settings.options.import.types.hevy));
      await tester.pumpAndSettle();
      verify(() => picker.pickFile()).called(1);
      verifyNever(() => MockServices.settingsController.importHevy(any()));
      expect(find.byType(AlertDialog), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
  for (final fails in [false, true]) {
    testWidgets(
      'selected Hevy file ${fails ? "reports rejected content" : "imports successfully"}',
      (tester) async {
        when(() => picker.pickFile()).thenAnswer((_) async => _SelectedFile());
        when(
          () => MockServices.settingsController.importHevy('hevy content'),
        ).thenAnswer((_) async {
          if (fails) throw const FormatException('Invalid Hevy columns');
        });
        await open(tester);
        await tester.tap(find.text(t.settings.options.import.types.hevy));
        await tester.pumpAndSettle();
        verify(
          () => MockServices.settingsController.importHevy('hevy content'),
        ).called(1);
        expect(
          find.text(t.settings.options.import.failed.title),
          fails ? findsOneWidget : findsNothing,
        );
        if (!fails) {
          expect(find.text(t.settings.options.import.success), findsOneWidget);
        }
        expect(tester.takeException(), isNull);
      },
    );
  }
}
