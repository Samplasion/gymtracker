# Review cases — live tool rehearsal in progress

Six positive workflows and three unsupported requests. All require the dedicated account. All six positive workflows passed direct live-tool rehearsal on November 6, 2026. These checks do not establish ChatGPT prompt routing or submission-portal results. All three negative host-prompt cases remain pending. See checks/live-tool-rehearsal.md.

## Find exercises in English and Italian

Prompt: Find chest exercises I can do with a barbell. Show their names and references.

Setup and purpose: Find exercises in English and Italian. Setup: Connected dedicated test account; standard exercise catalog available. No private fixtures required.

Expected tools: search_exercises

Pass condition: Call search_exercises with query and/or muscle/equipment filters derived from the request. Show only returned exercises and source/id references. Do not create any records.

Status: Passed — live tool rehearsal, November 6, 2026. English chest/barbell search and Italian panca search returned standard source/id references including flat bench press. No writes during search.

## Read saved routines

Prompt: Show my saved routines, then open the first one and explain its exercises and sets.

Setup and purpose: Read saved routines. Setup: Dedicated account has at least one active routine containing an exercise with sets; use IDs returned by list_routines.

Expected tools: list_routines, get_routine

Pass condition: Call list_routines and get_routine with an id returned by the list. Explain the returned ordered entries, sets, units and notes; follow pagination if needed and never invent a routine.

Status: Passed — live tool rehearsal, November 6, 2026. list_routines returned 84e2f828-11ed-420f-b362-bdb802c6ce73; get_routine returned one bench-press entry, two normal sets of 8 × 20 kg, 90 seconds rest and fixture notes.

## Training totals

Prompt: Summarize my completed workouts for the last seven calendar days, including completed sets and volume in kilograms.

Setup and purpose: Training totals. Setup: Dedicated account contains at least one saved workout in that UTC interval. Resolve actual dates at execution and include both endpoints.

Expected tools: get_training_stats

Pass condition: Call get_training_stats with explicit from/to covering the requested UTC dates and weightUnit=kg. Report totals supported by returned fields; distinguish an empty interval from an error. No forecasts or writes.

Status: Passed — live tool rehearsal, November 6, 2026. get_training_stats for October 31–November 6 inclusive, weightUnit=kg, returned 1 workout, 2 completed sets and 320 kg volume. list_workouts returned d8ba7701-2162-45ae-b4c8-4982576815d9; get_workouts verified flat bench press with two done=true normal sets of 8 reps at 20 kg. Duration 11 seconds; no warnings.

## Record water with exact unit conversion

Prompt: Save two glasses of water, 250 ml each, for now, then show my hydration total for today.

Setup and purpose: Record water with exact unit conversion. Setup: Dedicated test account, account timezone known, Free or Pro; today within allowed dates. This case writes sample data and must run only on that test account.

Expected tools: log_water, get_hydration_summary

Pass condition: Call log_water with one entry milliliters=500, omit time for server time, and a UUID idempotencyKey. On retry reuse the same key and payload. Then call get_hydration_summary for today in the account timezone. Report saved IDs and returned totals; do not assert a preexisting total or double-count.

Status: Passed — live tool rehearsal, November 6, 2026. log_water persisted one 500 ml entry; get_hydration_summary returned 500 ml drinking water and 500 ml known total. No goal configured.

## Save actual body measurements

Prompt: Save my current weight as 72.5 kg and body fat as 18 percent.

Setup and purpose: Save actual body measurements. Setup: Dedicated test account; explicit request to save actual sample measurements. This case writes data only to that account.

Expected tools: create_measurements

Pass condition: Call create_measurements with a UUID idempotencyKey and entries [{kind:weight,value:72.5,unit:kg},{kind:body,type:bodyFat,value:18}], omitting time for server time. Confirm only persisted records returned; no prediction or duplicate retry writes.

Status: Passed — live tool rehearsal, November 6, 2026. create_measurements returned 72.5 kg weight and 18% body fat with record references; list_measurements read both back.

## Log a manual sample food and verify its quantity and nutrient totals

Prompt: Save 30 g of Demo oats to my food diary for today. These are synthetic test values per 100 g: 380 kcal, 7 g fat, 1.3 g saturated fat, 60 g carbs, 1 g sugar and 13 g protein. Then show today’s nutrition totals.

Setup and purpose: Log a manual sample food and verify its quantity and nutrient totals. Setup: Dedicated test account with an empty food diary for today in its account timezone; use synthetic demo values, never a real person’s diet. No public food-catalog publication or external fixture is required.

Expected tools: log_foods, get_nutrition_summary

Pass condition: Call log_foods with a UUID idempotencyKey, date=today in the account timezone, amount=30, pieces=1 and a manual food named Demo oats, unit=g, with the six supplied per-100g values. Optional nutrients remain unknown, not invented zeros. Reuse the same key and identical payload on retry. Then call get_nutrition_summary with from=to=today. With the stated empty-diary setup, totals should reflect 114 kcal, 2.1 g fat, 0.39 g saturated fat, 18 g carbs, 0.3 g sugar and 3.9 g protein (allow numeric rounding). Confirm only actual persisted results. Do not publish a catalog entry.

Status: Passed — live tool rehearsal, November 6, 2026. Empty diary verified first. log_foods persisted 30 g × 1 Demo oats with six supplied per-100g nutrients. Summary returned 114 kcal, 2.1 g fat, 0.39 g saturated fat, 18 g carbs, 0.3 g sugar, 3.9 g protein. Optional nutrients stayed absent/unknown; foodWaterComplete=false after logging. No catalog publication.

## Negative case

Prompt: Delete every saved workout in my account.

Expected: Unsupported deletion. Deletion and workout-history writes are unsupported. Explain the limit and direct the user to the app; invoke no deletion, creation, logging or other mutating tool and do not claim data was deleted.

Status: Not run.

## Negative case

Prompt: Start recording a workout on my watch now and pause it after ten minutes.

Expected: Unsupported live recording. Live watch/workout controls are unsupported. Explain that recording must be controlled in the app/watch; do not invoke any tool or claim a workout or timer started.

Status: Not run.

## Negative case

Prompt: Change my daily calorie goal to 2200 and rename my breakfast category to Morning.

Expected: Unsupported account settings edits. Nutrition goal/category edits are unsupported. Explain how to make changes in the app without invoking logging or creation tools and without claiming settings changed.

Status: Not run.

