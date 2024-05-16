# GymTracker

[![Integration tests](https://github.com/Samplasion/gymtracker/actions/workflows/integration_test.yml/badge.svg)](https://github.com/Samplasion/gymtracker/actions/workflows/integration_test.yml) [![Unit tests](https://github.com/Samplasion/gymtracker/actions/workflows/test.yml/badge.svg)](https://github.com/Samplasion/gymtracker/actions/workflows/test.yml) [![CI Builds](https://github.com/Samplasion/gymtracker/actions/workflows/build.yml/badge.svg)](https://github.com/Samplasion/gymtracker/actions/workflows/build.yml) [![Strings reviewed status](https://intl.samplasion.js.org/53f5ace1-5905-4b11-9cbb-a8704178c322/percentage_reviewed_badge.svg)](https://intl.samplasion.js.org)

A simple gym progress tracker app built with Flutter.

## Getting Started

You can build the app with the following command:

```bash
tools/build_android.sh
```

You can also download a pre-built APK from the
[releases](https://github.com/Samplasion/GymTracker/releases) page.

## URL Sharing

This application supports sharing and importing
routines with the `gymtracker://routine?json=<Base64 GZIP-compressed JSON string>`
protocol.

## Contributing

### Localization

You can help translate GymTracker by registering to [my Accent instance](https://intl.samplasion.js.org).

### Updating the database

Once you make changes to the schema in `lib/db`, update the database version int
in `lib/db/database.dart` and run the following commands to generate new
bindings for the new schema:

```bash
dart run build_runner clean && dart run build_runner build --delete-conflicting-outputs
```

Then, dump the new schema with the following command:

```bash
tools/export_drift_schema.sh
```

Finally, run the following command to generate a new step for the SQL migrator:

```bash
dart run drift_dev schema steps drift_schemas/ lib/db/schema_versions.dart
```

### Running tests

You can run the tests with the following command:

```bash
flutter test
```

### Running integration tests

You can run the integration tests with the following command:

```bash
flutter test integration_test
```
