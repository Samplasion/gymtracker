import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymtracker/model/trainer.dart';
import 'package:gymtracker/model/workout.dart';
import 'package:gymtracker/provider/online.dart';
import 'package:gymtracker/provider/routines.dart';
import 'package:gymtracker/provider/trainer.dart';
import 'package:gymtracker/service/trainer.dart';
import 'package:gymtracker/view/trainer.dart';
import 'package:material_ui/material_ui.dart' as expressive;
import 'package:mocktail/mocktail.dart';

import '../test_helpers/mock_services.dart';
import '../test_helpers/widget_test_app.dart';

class _TrainerService extends Mock implements TrainerService {}

void main() {
  late _TrainerService service;
  setUp(() async {
    MockServices.setup();
    await initTestLocalizations();
    service = _TrainerService();
    when(() => service.refresh()).thenAnswer((_) async {});
    when(() => service.refreshAndSync(any())).thenAnswer((_) async {});
  });
  tearDown(MockServices.tearDown);

  Widget page(
    TrainerState state, {
    double scale = 1,
    bool show = true,
    List<Workout>? routines,
    List<GTRoutineFolder> folders = const [],
  }) => ProviderScope(
    overrides: [
      ...MockServices.defaultOverrides,
      currentUserIdProvider.overrideWithValue('client'),
      trainerServiceProvider.overrideWithValue(service),
      trainerStateProvider.overrideWith((ref) => Stream.value(state)),
      foldersStreamProvider.overrideWith((ref) => Stream.value(folders)),
      routinesStreamProvider.overrideWith(
        (ref) => Stream.value(
          routines ??
              [
                Workout(id: 'assigned', name: 'Assigned day', exercises: []),
                Workout(id: 'personal', name: 'Personal day', exercises: []),
              ],
        ),
      ),
    ],
    child: WidgetTestApp(
      child: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: show ? const TrainerView() : const SizedBox.shrink(),
        ),
      ),
    ),
  );

  testWidgets('invitation stays readable and cannot submit an empty code', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(page(TrainerState.empty, scale: 1.6));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Accept connection'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Accept connection'),
          )
          .onPressed,
      isNull,
    );
    await tester.enterText(find.byType(TextField), 'invitation-code');
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Accept connection'),
          )
          .onPressed,
      isNotNull,
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  testWidgets('a plan can be expanded to inspect its prescription', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      page(
        const TrainerState(
          link: {'id': 'link', 'trainer_name': 'Alex'},
          offers: [
            {
              'id': 'plan',
              'name': 'Strength plan',
              'revision': {
                'id': 'revision',
                'document': {
                  'routines': [
                    {
                      'id': 'day',
                      'name': 'Day A',
                      'weight_unit': 'kg',
                      'distance_unit': 'km',
                      'exercises': [
                        {
                          'name': 'Squat',
                          'sets': [
                            {'reps': 8, 'weight': 20},
                          ],
                          'rest_time': 90,
                        },
                      ],
                    },
                  ],
                },
              },
            },
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Day A'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text('Day A'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Day A'));
    await tester.pumpAndSettle();
    expect(find.text('Squat'), findsOneWidget);
    expect(find.textContaining('8 reps'), findsOneWidget);
    expect(find.text('Accept'), findsOneWidget);
    expect(find.text('Reject'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  testWidgets(
    'sharing sorts folders alphabetically and keeps routine stream order',
    (tester) async {
      const first = GTRoutineFolder(
        id: 'first',
        name: 'Z folder',
        sortOrder: 0,
        notes: '',
      );
      const second = GTRoutineFolder(
        id: 'second',
        name: 'A folder',
        sortOrder: 1,
        notes: '',
      );
      await tester.pumpWidget(
        page(
          const TrainerState(link: {'id': 'link', 'trainer_name': 'Alex'}),
          folders: [second, first],
          routines: [
            Workout(id: 'z', name: 'Z day', exercises: [], folder: first),
            Workout(id: 'a', name: 'A day', exercises: [], folder: first),
            Workout(
              id: 'other',
              name: 'Other day',
              exercises: [],
              folder: second,
            ),
            Workout(id: 'root-z', name: 'Root Z', exercises: []),
            Workout(id: 'root-a', name: 'Root A', exercises: []),
          ],
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Z folder'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(
        tester.getTopLeft(find.text('A folder')).dy,
        lessThan(tester.getTopLeft(find.text('Z folder')).dy),
      );
      await tester.ensureVisible(find.text('Z folder'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Z folder'));
      await tester.pumpAndSettle();
      expect(
        tester.getTopLeft(find.text('Z day')).dy,
        lessThan(tester.getTopLeft(find.text('A day')).dy),
      );
      await tester.scrollUntilVisible(
        find.text('Root Z'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(
        tester.getTopLeft(find.text('Root Z')).dy,
        lessThan(tester.getTopLeft(find.text('Root A')).dy),
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    },
  );

  testWidgets('open folders survive page recreation and layout changes', (
    tester,
  ) async {
    const folder = GTRoutineFolder(
      id: 'folder',
      name: 'My folder',
      sortOrder: 0,
      notes: '',
    );
    const state = TrainerState(link: {'id': 'link', 'trainer_name': 'Alex'});
    final routines = [
      Workout(id: 'day', name: 'Training day', exercises: [], folder: folder),
    ];
    Widget screen({bool show = true}) =>
        page(state, show: show, folders: [folder], routines: routines);
    await tester.pumpWidget(screen());
    await tester.pumpAndSettle();
    Future<void> showFolder() async {
      await tester.scrollUntilVisible(
        find.text('My folder'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(find.text('My folder'));
      await tester.pumpAndSettle();
    }

    await showFolder();
    await tester.tap(find.text('My folder'));
    await tester.pumpAndSettle();
    expect(find.text('Training day').hitTestable(), findsOneWidget);

    await tester.pumpWidget(screen(show: false));
    await tester.pumpAndSettle();
    await tester.pumpWidget(screen());
    await tester.pumpAndSettle();
    await showFolder();
    expect(find.text('Training day').hitTestable(), findsOneWidget);

    await tester.binding.setSurfaceSize(const Size(600, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpAndSettle();
    await showFolder();
    expect(find.text('Training day').hitTestable(), findsOneWidget);
    await tester.tap(find.text('My folder'));
    await tester.pumpAndSettle();
    await tester.pumpWidget(screen(show: false));
    await tester.pumpAndSettle();
    await tester.pumpWidget(screen());
    await tester.pumpAndSettle();
    await showFolder();
    expect(find.text('Training day').hitTestable(), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  testWidgets('folder header stays readable through repeated expansion', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    const folder = GTRoutineFolder(
      id: 'folder',
      name: 'My weekly strength training programme',
      sortOrder: 0,
      notes: '',
    );
    await tester.pumpWidget(
      page(
        const TrainerState(link: {'id': 'link', 'trainer_name': 'Alex'}),
        scale: 1.6,
        folders: [folder],
        routines: [
          Workout(
            id: 'day',
            name: 'Training day',
            exercises: [],
            folder: folder,
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
    final title = find.text(folder.name);
    await tester.scrollUntilVisible(
      title,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(title);
    await tester.pumpAndSettle();
    final card = find
        .ancestor(of: title, matching: find.byType(expressive.Material))
        .first;
    final collapsedHeight = tester.getSize(card).height;
    final titleSize = tester.getSize(title);
    void expectCompactClosedCard() {
      final bounds = tester.getRect(card);
      final subtitle = tester.getRect(find.text('1 routine'));
      expect(bounds.bottom - subtitle.bottom, closeTo(12, 0.02));
    }

    expectCompactClosedCard();

    void expectReadableHeader() {
      final count = find.text('1 routine');
      expect(count, findsOneWidget);
      expect(tester.getSize(title), titleSize);
      final bounds = tester.getRect(card);
      for (final text in [title, count]) {
        final rect = tester.getRect(text);
        expect(rect.top, greaterThanOrEqualTo(bounds.top));
        expect(rect.bottom, lessThanOrEqualTo(bounds.bottom));
      }
      expect(tester.takeException(), isNull);
    }

    expectReadableHeader();
    for (var cycle = 0; cycle < 2; cycle++) {
      await tester.tap(title);
      for (var frame = 0; frame < 6; frame++) {
        await tester.pump(const Duration(milliseconds: 40));
        expectReadableHeader();
      }
      await tester.pumpAndSettle();
      expect(find.text('Training day').hitTestable(), findsOneWidget);
      await tester.tap(title);
      for (var frame = 0; frame < 6; frame++) {
        await tester.pump(const Duration(milliseconds: 40));
        expectReadableHeader();
      }
      await tester.pumpAndSettle();
      expect(tester.getSize(card).height, closeTo(collapsedHeight, 0.01));
      expectCompactClosedCard();
      expect(find.text('Training day').hitTestable(), findsNothing);
      expectReadableHeader();
    }
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  for (final width in [360.0, 1024.0]) {
    testWidgets(
      'connected page keeps sharing and disconnect confirmations at width $width',
      (tester) async {
        await tester.binding.setSurfaceSize(Size(width, 900));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pumpWidget(
          page(
            const TrainerState(
              link: {'id': 'link', 'trainer_name': 'Alex Personal Trainer'},
              controls: {'assigned'},
            ),
            scale: width == 360 ? 1.6 : 1,
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Active relationship'), findsOneWidget);
        await tester.scrollUntilVisible(
          find.text('You’re all caught up'),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text('You’re all caught up'), findsOneWidget);
        await tester.scrollUntilVisible(
          find.byType(Switch),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.byType(Switch), findsOneWidget);
        await tester.ensureVisible(find.byType(Switch));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(Switch));
        await tester.pumpAndSettle();
        expect(find.text('Which workouts should be shared?'), findsOneWidget);
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          find.text('End relationship'),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.ensureVisible(find.text('End relationship'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('End relationship'));
        await tester.pumpAndSettle();
        expect(find.text('End the relationship?'), findsOneWidget);
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        verifyNever(() => service.execute(any(), any()));
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      },
    );
  }
}
