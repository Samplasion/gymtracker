# Validation — 2 November 2026

Implemented and built in the local workspace. No Play Console upload or production
release has been performed.

## Automated checks

- 44 Flutter tests passed: training model/journal/bridge, water import/bridge and the
  Wear OS method-channel contract.
- 11 shared Kotlin tests passed: cloning, superset order, parameter units, rest,
  immutable acknowledgements, terminal fencing, metrics merging and export-version
  reservation across crashes.
- 6 Android/Robolectric tests passed: dirty replica ownership, stale acknowledgements,
  terminal replay, account generations, confirmed-water reconciliation/deletion and
  Quill block formatting.
- Wear OS release/debug compilation and Android release/debug compilation passed.
- Wear OS lint passed; dependency/deprecation warnings remain.
- Existing native watchOS training, workout/metrics and nutrition regression scripts
  passed. No watchOS source was changed.
- Targeted Dart analysis reported no errors/warnings and three existing informational
  brace-style findings in unrelated sections of `lib/service/database.dart`.
- `git diff --check` passed.

## Emulator and artifacts

A dedicated isolated Wear OS 3/API 30 ARM64 round emulator was installed for testing.
Debug and optimized/signed release APKs installed and launched successfully. The
release opened with empty real data; screenshot fixtures were only enabled in the
explicit debug flow. Workout controls, routines, notes, nutrients and water were
visually checked. English and Italian screenshots are in the store directories.

Signed release outputs in `out/android`:

- `GymBro-android-0.15.1+1793113092-release.apk`
- `GymBro-wear-0.15.1+1793113092-release.apk`
- Corresponding `.aab` files for Play.

The release APK signing certificates match. Build number `1793113092` was explicitly
chosen above the existing local Android APK (`1793113091`) to avoid a downgrade on
installation. The repository's pubspec version is unchanged. The Play Console's
current maximum code still needs to be checked before upload.

## Not verified here

- A physically paired Android phone and watch, including background Data Layer
  delivery and account changes across the real device pair.
- Real heart-rate/calorie accuracy, sensor permissions/revocation/recovery across OEMs,
  and hour-long battery behavior.
- Health Connect insertion, retry, update and deletion against a real provider and
  an actual user's permission flow.
- TalkBack and large-text acceptance on hardware; OEM-specific exact-alarm behavior.
- Internal-track installation from Google Play, Data safety/health declarations and
  reviewer access. These require Console access and the normal release process.

These are acceptance gates before production promotion. Emulator startup and unit
coverage do not establish that physical synchronization or health export works
end to end.

## Routine navigation and action icon regression checks

Wear build `1793113094`: debug and release APK builds, debug lint and watch unit tests passed. All 8 instrumented UI tests passed on the isolated Wear OS preview app, including starting a routine inside a folder and checking the actual rendered Diary icon uses the orange label color. Starting a routine clears the complete detail stack after successful persistence. Primary and tonal actions explicitly share their label color with their icon.
