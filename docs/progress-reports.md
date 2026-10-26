# Progress reports

The profile's **Progress reports** action opens the local report builder. Food
tracking is now a main shell destination between Profile and Work Out, including
the expanded drawer and collapsed navigation rail. Reports are available without
Pro. The shell observes subscription changes so the optional Pro destination
stays in sync with the user's entitlement.

## Data and calculation rules

- A report is an immutable snapshot of the selected sections, units, locale and
  generation time. Data acquisition uses the existing owner-filtered database
  streams inside a read transaction. Account transitions invalidate pending work
  and previews, including switching away and back to the original identity.
- Calendar boundaries are inclusive at the start and exclusive at the end. Days
  are constructed as civil dates, rather than adding 24 hours. Food log dates
  remain civil dates; workout and measurement instants are grouped in local time.
  English weeks begin Sunday; Italian weeks begin Monday, matching the app.
- Saved workouts and their continuations are separate sessions on their actual
  start dates. Each ID is counted once. Planned routines and the ongoing workout
  are excluded. Only completed sets contribute to repetition and volume totals.
  Volume means positive repetition load multiplied by repetitions; assisted
  loads remain negative in the detail and are excluded from volume. Stored
  weight and distance units are converted before display and aggregation.
- Food totals reuse `Food.nutritionalValues`, including quantity and pieces.
  Averages divide by the count of days containing food records, including days
  whose recorded calories are zero. No records is represented separately from
  zero. A recorded day is not assumed to be a complete food diary.
- Only persisted nutrition goals effective on or before each date are shown.
  Provider defaults are never presented as user goals.
- Body reports include actual weight, circumference and body-fat observations,
  excluding deleted and predicted values. Change is last minus first observation
  inside the selected period; a single observation has no calculated change.
  Charts use the last actual observation per day and never interpolate gaps.
- There are no comparisons with previous periods, clinical conclusions,
  uploaded report data, database migrations or new sync records.

## PDF and native integration

`pdf` produces A4 documents with bundled, SIL-OFL Noto Sans fonts. `printing`
previews the actual document bytes offline. The same bytes are passed to
`file_picker` for saving and `share_plus` for native sharing, including an iPad
popover origin. Cancellation is not reported as failure. macOS grants access to
user-selected files through the existing sandbox entitlements.

The PDF uses the app’s neutral light surfaces, 12pt rounded cards and saved theme
accent. Training and nutrition summaries use metric cards; measurement summaries
and daily detail use tables with thin horizontal separators. Calculation notes
follow the detail rather than occupying the overview.

Summaries precede charts and complete daily detail. Tables repeat headers
across pages; long strings continue without truncation. Charts are vector-based,
with missing days left blank and explicit units. Titles, generation time,
criteria and page numbers are included. Account identifiers, profile details,
contacts and free-text workout/exercise notes are omitted.

## Verification

The report tests cover calendar boundaries, localized weeks, DST dates, all seven
section combinations, empty selection, null versus zero, food portions, unit
conversion, incomplete sets, continuations, effective goals, actual measurements,
owner isolation, account transitions, loading/error/retry, native-action mocks,
preview invalidation and compact layouts. Navigation tests exercise the bottom
bar, expanded drawer and collapsed rail with and without Pro.

`test/service/progress_report_pdf_test.dart` writes daily/monthly fixtures in both
languages to `/tmp/gymbro-report-qa` for independent PDF extraction and rendering.
Dense fixtures exercise tables spanning many pages, accented text and long names.
Native save/share dialogs still require device validation on each target platform;
widget tests replace those services. Font coverage is suitable for the app's
Italian/English text; arbitrary user text in other writing systems may require
additional bundled fallback fonts.
