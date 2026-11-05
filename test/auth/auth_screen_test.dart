import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/i18n/strings.g.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/service/online.dart';
import 'package:gymtracker/utils/go.dart';
import 'package:gymtracker/utils/theme.dart';
import 'package:gymtracker/view/components/expressive_theme.dart';
import 'package:gymtracker/view/login.dart';
import 'package:http/http.dart';

class _Online extends Online {
  _Online() : super(service: TestOnlineServiceImpl());
  int registrations = 0;
  int logins = 0;
  final recoveries = <(String, String)>[];
  bool recoveryFails = false;
  @override
  Future<void> requestPasswordRecovery({
    required String email,
    required String locale,
  }) async {
    recoveries.add((email, locale));
    if (recoveryFails) throw ClientException("offline");
  }

  late final pending = Completer<void>();

  @override
  FutureOr<OnlineAccount?> build() => null;

  @override
  Future<void> register({
    required String email,
    required String password,
    required String username,
  }) {
    registrations++;
    return pending.future;
  }

  @override
  Future<void> login({required String email, required String password}) async {
    logins++;
    throw ClientException('Failed host lookup');
  }
}

void main() {
  final screenshotKey = GlobalKey();
  late _Online online;

  setUpAll(() async {
    if (Platform.environment['AUTH_SCREENSHOT_DIR'] != null) {
      final regular = FontLoader('Roboto')
        ..addFont(rootBundle.load('assets/fonts/NotoSans-Regular.ttf'));
      await regular.load();
      final icons = FontLoader('MaterialIcons')
        ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
      await icons.load();
    }
  });

  setUp(() {
    online = _Online();
    LocaleSettings.setLocaleSync(AppLocale.it);
  });

  tearDown(() => LocaleSettings.setLocaleSync(AppLocale.en));

  Future<void> mount(
    WidgetTester tester, {
    Size size = const Size(390, 844),
    double textScale = 1,
    Brightness brightness = Brightness.light,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [onlineProvider.overrideWith(() => online)],
        child: Builder(
          builder: (context) => TranslationProvider(
            child: MaterialApp(
              navigatorKey: Go.navigatorKey,
              debugShowCheckedModeBanner: false,
              locale: const Locale('it'),
              localizationsDelegates: GlobalMaterialLocalizations.delegates,
              supportedLocales: const [Locale('it'), Locale('en')],
              theme: getGymTrackerThemeFor(
                context,
                Colors.deepPurple,
                brightness,
              ),
              builder: (context, child) => GTExpressiveTheme(
                child: MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: TextScaler.linear(textScale)),
                  child: child!,
                ),
              ),
              home: RepaintBoundary(
                key: screenshotKey,
                child: const AuthScreen(),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> signUp(WidgetTester tester) async {
    final switchButton = find.widgetWithText(
      TextButton,
      t.login.buttons.signUp,
    );
    await tester.ensureVisible(switchButton);
    await tester.tap(switchButton);
    await tester.pumpAndSettle();
  }

  Finder field(String label) => find.ancestor(
    of: find.byWidgetPredicate(
      (widget) => widget is TextField && widget.decoration?.labelText == label,
    ),
    matching: find.byType(TextFormField),
  );

  Future<void> submit(WidgetTester tester) async {
    final button = find.byType(FilledButton);
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pump();
  }

  Future<void> screenshot(WidgetTester tester, String name) async {
    final directory = Platform.environment['AUTH_SCREENSHOT_DIR'];
    if (directory == null) return;
    final boundary =
        screenshotKey.currentContext!.findRenderObject()
            as RenderRepaintBoundary;
    await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: 2);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await Directory(directory).create(recursive: true);
      await File(
        '$directory/$name.png',
      ).writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose();
    });
  }

  testWidgets(
    'registration requires matching passwords before contacting server',
    (tester) async {
      await mount(tester);
      await signUp(tester);
      await tester.enterText(
        field(t.login.fields.username.label),
        'mario_rossi',
      );
      await tester.enterText(
        field(t.login.fields.email.label),
        'mario@example.com',
      );
      await tester.enterText(
        field(t.login.fields.password.label),
        'Password123!',
      );
      await submit(tester);
      expect(find.text(t.login.errors.confirmPasswordRequired), findsOneWidget);
      expect(online.registrations, 0);
      await tester.enterText(
        field(t.login.fields.confirmPassword.label),
        'Different123!',
      );
      await submit(tester);
      expect(find.text(t.login.errors.passwordMismatch), findsOneWidget);
      expect(online.registrations, 0);
      await tester.enterText(
        field(t.login.fields.confirmPassword.label),
        'Password123!',
      );
      await submit(tester);
      expect(online.registrations, 1);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('failed login preserves form and shows recoverable error', (
    tester,
  ) async {
    await mount(tester);
    await tester.enterText(
      field(t.login.fields.email.label),
      'mario@example.com',
    );
    await tester.enterText(
      field(t.login.fields.password.label),
      'Password123!',
    );
    await submit(tester);
    await tester.pumpAndSettle();
    expect(online.logins, 1);
    expect(find.byType(AuthScreen), findsOneWidget);
    expect(find.text(t.login.errors.noInternet), findsOneWidget);
    expect(
      tester
          .widget<TextFormField>(field(t.login.fields.email.label))
          .controller!
          .text,
      'mario@example.com',
    );
  });

  testWidgets('full screen switches variants and Back returns to sign in', (
    tester,
  ) async {
    await mount(tester);
    expect(find.byType(AppBar), findsNothing);
    expect(find.byType(TabBar), findsNothing);
    expect(find.byIcon(Icons.arrow_back_rounded), findsNothing);
    await signUp(tester);
    expect(find.text(t.login.presentation.haveAccount), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();
    expect(find.text(t.login.presentation.noAccount), findsOneWidget);
  });

  testWidgets('recovery validates email, handles failure and allows retry', (
    tester,
  ) async {
    await mount(tester);
    await tester.tap(find.text(t.login.recovery.forgot));
    await tester.pumpAndSettle();
    await submit(tester);
    expect(online.recoveries, isEmpty);
    expect(find.text(t.login.errors.email), findsOneWidget);
    await tester.enterText(
      field(t.login.fields.email.label),
      'mario@example.com',
    );
    online.recoveryFails = true;
    await submit(tester);
    await tester.pumpAndSettle();
    expect(find.text(t.login.errors.noInternet), findsOneWidget);
    online.recoveryFails = false;
    await submit(tester);
    await tester.pumpAndSettle();
    expect(online.recoveries, [
      ('mario@example.com', 'it'),
      ('mario@example.com', 'it'),
    ]);
    expect(find.text(t.login.recovery.sentTitle), findsOneWidget);
    expect(online.logins, 0);
    expect(online.registrations, 0);
    await tester.tap(find.text(t.login.recovery.backToSignIn));
    await tester.pumpAndSettle();
    expect(find.text(t.login.presentation.noAccount), findsOneWidget);
  });

  for (final brightness in Brightness.values) {
    for (final layout in ['phone', 'large-text', 'desktop']) {
      testWidgets('auth layout $brightness $layout', (tester) async {
        await mount(
          tester,
          brightness: brightness,
          size: layout == 'desktop'
              ? const Size(1200, 900)
              : layout == 'large-text'
              ? const Size(360, 800)
              : const Size(390, 844),
          textScale: layout == 'large-text' ? 1.6 : 1,
        );
        expect(tester.takeException(), isNull);
        if (layout == 'phone') {
          await screenshot(tester, 'accesso-${brightness.name}');
        }
        await signUp(tester);
        expect(tester.takeException(), isNull);
        if (layout == 'phone') {
          await screenshot(tester, 'registrazione-${brightness.name}');
        }
        await tester.ensureVisible(find.byType(FilledButton));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.ensureVisible(find.byIcon(Icons.arrow_back_rounded));
        await tester.tap(find.byIcon(Icons.arrow_back_rounded));
        await tester.pumpAndSettle();
        final forgot = find.text(t.login.recovery.forgot);
        await tester.ensureVisible(forgot);
        await tester.tap(forgot);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        if (layout == 'phone') {
          await screenshot(tester, 'recupero-${brightness.name}');
        }
      });
    }
  }
}
