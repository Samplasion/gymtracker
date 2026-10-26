import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'mounting a consumer flushes a paused chain with a shared sibling safely',
    (tester) async {
      var value = 1;
      final database = Provider((ref) => value);
      final repository = Provider((ref) => [ref.watch(database)]);
      final records = Provider((ref) => ref.watch(repository).single);
      final selected = Provider((ref) => ref.watch(records) * 10);
      final sibling = Provider((ref) => ref.watch(records) * 100);
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final source = container.listen(database, (_, _) {});
      final dormant = container.listen(selected, (_, _) {});
      expect(dormant.read(), 10);
      final dormantSibling = container.listen(sibling, (_, _) {});
      expect(dormantSibling.read(), 100);
      dormant.pause();
      dormantSibling.pause();
      await tester.pump(const Duration(milliseconds: 1));
      final shown = ValueNotifier(false);
      addTearDown(shown.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: ValueListenableBuilder(
              valueListenable: shown,
              builder: (_, visible, _) => visible
                  ? Consumer(
                      builder: (_, ref, _) => Text('${ref.watch(selected)}'),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ),
      );
      value = 2;
      container.invalidate(database);
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump(const Duration(milliseconds: 1));
      shown.value = true;
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.text('20'), findsOneWidget);
      // The sibling must remain dirty and catch up when it becomes active.
      dormantSibling.resume();
      await tester.pumpAndSettle();
      expect(dormantSibling.read(), 200);
      // A subsequent regular invalidation must still notify visible consumers.
      value = 3;
      container.invalidate(database);
      await tester.pumpAndSettle();
      expect(find.text('30'), findsOneWidget);
      expect(dormantSibling.read(), 300);
      expect(tester.takeException(), isNull);
      dormant.close();
      dormantSibling.close();
      source.close();
      await tester.pump(const Duration(milliseconds: 1));
    },
  );

  testWidgets('flush guard resets after an error and preserves later updates', (
    tester,
  ) async {
    var fail = true, value = 1;
    final base = Provider<int>((ref) {
      if (fail) throw StateError('unavailable');
      return value;
    });
    final derived = Provider((ref) => ref.watch(base));
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Consumer(
            builder: (_, ref, _) {
              try {
                return Text('${ref.watch(derived)}');
              } catch (_) {
                return const Text('retry');
              }
            },
          ),
        ),
      ),
    );
    expect(find.text('retry'), findsOneWidget);
    fail = false;
    container.invalidate(base);
    await tester.pumpAndSettle();
    expect(find.text('1'), findsOneWidget);
    value = 2;
    container.invalidate(base);
    await tester.pumpAndSettle();
    expect(find.text('2'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
