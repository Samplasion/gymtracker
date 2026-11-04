# Gym Bro Wear OS

Native Kotlin/Compose application (`android/wear`), shared Android protocol/storage
library (`android/wearable-core`) and a companion bridge in the Flutter phone app.
Minimum Wear OS 3/API 30; phone minimum API 26. Health Connect export is optional
and requires a supported Android phone/provider. Configure and initially download
routines using the Android companion; subsequently train without the phone.

## Build and installation

From the repository root, run `tools/build_wear.sh --debug` for a matched debug
pair, or `tools/build_wear.sh` for signed APKs and Play bundles. Set `FLUTTER_BIN`
when the repository's FVM SDK is unavailable. `BUILD_NUMBER` can override the
pubspec build number. The script preserves existing artifacts in `out/android`.

Phone and watch must use the same package **and signing certificate**. Debug uses
`org.js.samplasion.gymtracker.debug` on both; release uses the existing production
application ID and `android/key.properties`. The watch resolves `storeFile` using
the phone project's directory, including absolute paths used by CI.

The debug Firebase task derives local resources from the existing production
Firebase project when `android/app/src/debug/google-services.json` is absent.
This does not register a new Firebase app or OAuth/SHA client. Provide a real debug
configuration for independent Firebase environments or debug OAuth testing. Do not
commit credentials or generated configurations.

Install each APK separately using Android Studio or ADB:

```sh
adb -s PHONE_SERIAL install -r out/android/GymBro-android-VERSION-debug.apk
adb -s WATCH_SERIAL install -r out/android/GymBro-wear-VERSION-debug.apk
```

Enable wireless debugging on a physical watch and pair it using its displayed
address/code. Pair the watch with the Android phone in the manufacturer's companion
app. Open Gym Bro on both, using the same debug/release variant. Guest mode works;
no separate watch login exists. Play services supplies the device data connection.

Do not mix an upload-key-signed local release with a Play-app-signing-key-signed
installation. Download signed APKs from Play App Bundle Explorer when the app
signing key is managed by Google. Verify certificates before distributing a pair.

## Data and ownership

`WearOsTrainingTransport` uses the existing `gymbro/training` channel contract.
Flutter remains responsible for reconciliation, workout history and progression.
`exchange` persists a context and returns the native inbox without waiting for the
watch. `acknowledge` removes an inbox entry only after shared Dart persistence has
succeeded. The local-only `watch_training_journal` remains unchanged.

Watch actions are persisted locally first, including while connected; whole-set
stamps are reconciled by the same phone service used for watchOS. An acknowledgement
only clears dirty state if it matches the exact outgoing session. Both sides
preserve unknown JSON fields. Dates use Unix milliseconds, durations use Dart
microseconds. Terminal tombstones prevent a replay from reopening a workout.

Room stores account-scoped active sessions, terminal outboxes, acknowledgements,
water entries, metrics segments and Health Connect export intents. A native
`WearableListenerService` accepts data with no Flutter engine. Until the phone app
opens, pending workouts remain visible on the watch; background import never
launches a second Flutter engine.

Data Layer Asset items under `/gymbro/v1/` carry durable payloads; messages provide
best-effort live updates. Phone and watch publish in different namespaces. Network
failure is an ordinary offline state. Reopening either app replays stored items.

Catalog generation/revision fences account changes and stale catalog deliveries.
Old-account queues remain isolated. Routine snapshots are independent of subsequent
catalog edits. The existing phone conflict dialog handles simultaneous distinct
workouts; no workout is silently replaced.

## Recording, recovery and Health Connect

`WorkoutService` owns Health Services `ExerciseClient`, a foreground notification
and Ongoing Activity. Starting from Android invites the user to open the watch;
recording starts from visible watch UI after its permissions are granted. A matching
owned recording is reused. A different app's recording is never overwritten.
Denied permissions or unsupported sensors leave series logging usable.

Sensor segments retain monotonic cumulative **total calories**, revisioned updates
and timestamped heart samples. Total calories are exported as total calories, not
active energy. A live packet cannot erase stored sample history. A 30-second TTL
prevents stale heart readings from being displayed as current.

The phone writes `ExerciseSessionRecord`, `HeartRateRecord` and
`TotalCaloriesBurnedRecord` using stable client record IDs and increasing versions.
The export worker retries independently of Gym Bro imports. Grant permissions on the
phone; a missing/revoked provider does not discard the saved workout. User deletions
queue removal of this app's exported records and fence later terminal replays.
Historical workouts from before this integration are not automatically exported.

Rest alarms are independent of sensor permission. Exact alarms are used when
permitted; otherwise Android's inexact allow-while-idle scheduling can delay a
background rest alert. Sensor recording also checks deadlines while active. One
persisted receipt prevents duplicate vibrations. No GPS/background passive sensor
tracking is requested.

## Nutrition and complications

Food is read-only except water logging. It contains category nutrition summaries,
not individual food editing. The diary's `referenceDay` controls daily totals;
previous-day totals become zero while goals remain available. Water keeps an
optimistic overlay until the phone snapshot includes its stable entry ID.

Six complication providers expose streak, rest, total workouts, density, water and
nutrition. Unsupported watch-face slots simply do not offer a provider. The density
provider uses a small image; water and nutrition can use ranged values. Opening a
complication leads to its corresponding app screen. No Apple Activity rings or new
Tiles are included. Music is absent from the watch UI. See `UI-PARITY.md` for the interface mapping to Apple Watch.

## Verification

```sh
cd android
./gradlew :wearable-core:testDebugUnitTest :wear:testDebugUnitTest :wear:lintDebug :wear:assembleDebug
```

Run the shared Flutter training, water and transport tests, plus existing watchOS
native regression scripts. `WatchRepositoryTest` exercises Room and account/terminal
fences using Robolectric. Explicit screenshot fixtures are restricted to debug:

```sh
adb shell am force-stop org.js.samplasion.gymtracker.debug
adb shell am start -n org.js.samplasion.gymtracker.debug/org.js.samplasion.gymtracker.wear.MainActivity --ez screenshots true --es scene workout
```

Use `python3 tools/screenshots/capture_wear.py --serial WATCH_SERIAL` to reproduce
both English and Italian store screenshots on a dedicated test emulator.

Scenes: `home`, `routines`, `workout`, `edit-set`, `notes`, `food`, `nutrients`, `water`.
These developer fixtures are not fallback data for real users.

Before production release, test a physically paired Samsung and Google watch,
including Wear OS 3 and a recent version: finish offline, restart either app during
handoff/import, modify both copies, restructure exercises on Android, deny/revoke
permissions, change accounts, interrupt recording, reboot, cross midnight/time zones,
replay deliveries, and verify exactly one history entry/progression/export. Measure
battery use during an hour-long workout and inspect TalkBack/large-text rendering.
An emulator cannot validate real sensor quality, OEM background limits or a complete
manufacturer pairing flow.

## Play delivery

Store text is in `store/it-IT` and `store/en-US`. See `VALIDATION.md` for the completed checks and remaining device acceptance gates.
Capture real app screenshots for
round watch screens; do not upload fixture images as evidence of paired sensor
verification. Both apps use the existing Play listing/package and app signing key.
Opt into the Wear OS form factor, upload its AAB to internal testing, add screenshots,
complete health/foreground-service/Data safety declarations and verify reviewer
access. Ensure privacy disclosures cover health data transfer and Health Connect.

Choose version codes above the current console maximum for the relevant artifacts;
never lower an already-published code to match a local pubspec. Verify device
compatibility and both certificate fingerprints in the internal track. Promote to
production only after physical acceptance tests. Console access, app signing and
Google review are external prerequisites; building an AAB does not publish it.
