# Achievement tests

Run the complete catalog suite:

```sh
flutter test test/achievements
```

Run a specific achievement and level:

```sh
flutter test test/achievements --plain-name 'foodWatcher/2'
```

`scenarios.dart` declares an independent contract for every achievement/level:
its expected trigger, domain data below the requirement, qualifying domain data,
and progress/maximum where applicable. Numeric cases use the threshold and a
value just below it. `alsoLocked` and `alsoEarned` add named edge cases.

`fixtures.dart` supplies real workouts, sets, measurements and meals. The fixed
clock defaults to 15 June 2024 (a leap year). Pass another `now` to test a
different month/year without depending on the machine's date or timezone.

`catalog_test.dart` compares the scenario matrix with the complete production
catalog. New, removed or duplicate levels fail the coverage check. Each level
also checks empty data, progress, the expected trigger, persistence, notification,
and deduplication before and after database stream delivery. Previous levels are
seeded so that each level is tested independently.

`harness.dart` runs the actual achievement controller. Only persistence and the
online account are mocked; rule predicates and progress are never mocked.
Database-backed integration coverage remains in
`test/data/achievement_rules_test.dart` and
`test/provider/achievement_unlocks_test.dart`.

To add a level, add its scenario with explicit expectations and fixtures. Do not
read its expected trigger or threshold from the implementation: doing so would
hide accidental rule changes. Add named edge cases when the level filters data
by dates, exercise type, completion state or unit.
