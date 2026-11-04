# Wear OS interface parity

The Apple Watch UI is the feature reference; Wear OS uses native Material 3
Expressive components and navigation rather than reproducing SwiftUI styling.

| Apple Watch | Wear OS |
| --- | --- |
| Training and food root pages | Native horizontal pages with M3 page indicators |
| Folders, routines, counts, details and exercise notes | Same content in morphing cards and native scrolling lists |
| Offline/empty/pending-sync states | Same states; no manual-sync or last-workout shortcuts |
| Workout elapsed time, set type, parameters, heart rate, energy and rest | Dedicated workout page with official Material icons and locale-aware values |
| Previous/complete/next set and set editing | Native animated icon buttons and parameter controls with the same bounds/steps |
| Session actions, progress, connection state, finish and confirmed discard | Separate actions page |
| Exercise and superset notes | Conditional pages, preserving rich-text content |
| Calorie detail with intake, goal, remaining/over-goal | Dedicated detail page; an unset goal is explicitly identified |
| Macro progress, goals and no-goal states | Same information in nutrient views |
| Diary category summaries and nutrient drill-down | Same summary and category-detail navigation |
| Water summary, quick amounts, custom amount, pending/account states | Same operations; numeric labels centered in equal-width buttons |
| Workout summary | Duration, total energy and average heart rate when recorded |
| Six watch complications | Retained; compact titles are localized and absent goals are not invented |

Music has no page, shortcut, explanation or other visible representation. Apple
Activity rings are omitted, with the user's agreement, because they are not
available on Wear OS. No substitute measurements are fabricated.

All companion-device messages say **phone / telefono**, including errors. Labels
are Android resources using the established Apple Watch translations where
applicable, with Android plurals and locale-aware number formatting. System
controls use official rounded Material vector icons, not text glyph substitutes.
The launcher/adaptive/monochrome assets are copied byte-for-byte from the existing
Android app (19 files); the placeholder dumbbell icon is removed.

Read-only surfaces size to their content and have no disabled-button semantics.
Single-line auxiliary labels are not oversized cards. List end padding is computed
from the viewport and the measured last item, allowing it to enter the round
screen's readable center without adding blank space inside the card.

## Verification

- Wear OS unit tests and debug/release lint.
- Six instrumented tests on the API 37 round watch emulator: catalog/routine
  navigation and absence of added shortcuts; one-set completion; custom-water
  bounds/step; calorie remaining/no-goal states; last-item scroll reachability;
  equal-width quick-water buttons and centered numeric labels.
- Explicit debug screenshots in English and Italian, with visual checks of the
  workout, lists, nutrition, water controls, editor and summary.
- Both updated Wear APKs retain the signing certificates of the corresponding
  existing Android APKs. The companion wire protocol is unchanged.

The screenshot build installs as `org.js.samplasion.gymtracker.preview`, isolated
from the paired `.debug` app and its workout data. Build it with
`./gradlew :wear:assembleScreenshot` and capture using:

```sh
python3 tools/screenshots/capture_wear.py --serial WATCH_SERIAL --package org.js.samplasion.gymtracker.preview
```

Test-only AndroidX Test 1.8/Espresso 3.8 previews are pinned for the API 37 emulator's
InputManager compatibility; these dependencies are not shipped in the app.
