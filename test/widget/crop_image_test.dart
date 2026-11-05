import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/view/components/loading_indicator.dart';
import 'package:gymtracker/view/utils/crop_image.dart';

void main() {
  testWidgets('invalid images stop loading and show an error', (tester) async {
    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(home: CropImagePage(imageBytes: Uint8List(3))),
      ),
    );
    await tester.runAsync(
      () async => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump();
    expect(find.byType(GBLoadingIndicator), findsNothing);
    expect(find.text(t.userProfile.edit.error), findsOneWidget);
    expect(find.byType(FilledButton), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'rapid crop confirmations return one PNG and keep the parent route',
    (tester) async {
      late Uint8List bytes;
      await tester.runAsync(() async {
        final recorder = ui.PictureRecorder();
        Canvas(recorder).drawColor(Colors.red, BlendMode.src);
        final picture = recorder.endRecording();
        final image = await picture.toImage(32, 32);
        bytes = (await image.toByteData(
          format: ui.ImageByteFormat.png,
        ))!.buffer.asUint8List();
        image.dispose();
        picture.dispose();
      });
      final navigator = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        TranslationProvider(
          child: MaterialApp(
            navigatorKey: navigator,
            home: const Scaffold(body: Text('Home')),
          ),
        ),
      );
      navigator.currentState!.push(
        MaterialPageRoute<void>(
          builder: (_) => const Scaffold(body: Text('Editor')),
        ),
      );
      await tester.pumpAndSettle();
      final result = navigator.currentState!.push<Uint8List>(
        MaterialPageRoute(builder: (_) => CropImagePage(imageBytes: bytes)),
      );
      await tester.pump();
      await tester.runAsync(
        () async => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pumpAndSettle();
      // Also finish decoding the Image widget used by the repaint boundary.
      await tester.runAsync(
        () async => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pumpAndSettle();
      final confirm = tester
          .widget<FilledButton>(find.byType(FilledButton))
          .onPressed!;
      confirm();
      confirm();
      await tester.pump();
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      await tester.runAsync(
        () async => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pumpAndSettle();
      final cropped = await result;
      expect(cropped, isNotNull);
      expect(cropped!.take(8), [137, 80, 78, 71, 13, 10, 26, 10]);
      expect(find.text('Editor'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
