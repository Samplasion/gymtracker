# Live tool rehearsal — November 6, 2026

Scope: direct tool execution in Codex, not a recorded ChatGPT run or saved-version portal test. Dedicated website identity gymbro_plugin_review_1 and Europe/Rome verified. Fresh connector reported Free, 0 routines, 0 custom exercises before writes. No explicit account identity field is exposed by the connector. Existing production account records were not used.

## Passed positive checks

- Exercise search: category=chest, equipment=barbell, language=en; then query=panca with the same filters and language=it. Returned standard exercise references included library.chest.exercises.barbellBenchPressFlat, with English Bench press (barbell) and Italian Panca piana (bilanciere).
- Routine creation/read: original seed payload/key in sample-data-plan.json created routine 84e2f828-11ed-420f-b362-bdb802c6ce73. list_routines returned that ID, home folder, kg/km, nextOffset=null. get_routine returned the expected notes, flat bench press, restSeconds=90 and two normal sets of 8 reps at 20 kg. Routine sets are templates with done=false, not completed workout records.
- Water: log_water({entries:[{milliliters:500}],idempotencyKey:52d785d0-a48f-4f7b-b42e-8c989575cda3}) omitted time for server time. Returned aa76c941-7070-4318-9a17-d68c88f90e0e at 2026-11-06T14:41:07.653274+00:00. Summary for November 6 returned drinkingWaterMl=500, knownFoodWaterMl=0, knownTotalWaterMl=500, foodWaterComplete=true before logging food, no goal.
- Measurements: idempotencyKey=71a84931-d633-4ef5-88cc-6b2bdc4ccbfc; entries [{kind:weight,value:72.5,unit:kg},{kind:body,type:bodyFat,value:18}], time omitted. Returned weight 82fadfd8-88b0-4959-84f3-0b49eb2d276c and body 8e6ed6a4-c72e-4c6d-9466-6e1baa02aaf4, both at 2026-11-06T14:41:23.870879+00:00. list_measurements for November 6 read both back, nextCursor=null.
- Food: November 6 diary checked empty first. idempotencyKey=7decb5c6-77dc-4b95-9fb0-6501c78c49c6; date=2026-11-06, amount=30, pieces=1; manual food {name:Demo oats,unit:g,nutritionalValuesPer100g:{calories:380,fat:7,saturatedFat:1.3,carbs:60,sugar:1,protein:13}}. Returned diary snapshot ddb37d63-205d-4992-9cbc-a40c7eb551f5, six known nutrient values, no invented optional nutrients. Summary returned 114 kcal, 2.1 g fat, 0.39 g saturated fat, 18 g carbs, 0.3 g sugar, 3.9 g protein, with identical meal totals. Optional nutrient totals were absent. Hydration known total remained 500 ml and foodWaterComplete=false, correctly reflecting unknown water in Demo oats.

These values are synthetic review data, not a real person's diet or measurements. No catalog entry was published. No update or deletion calls were made. No failed or ambiguous writes occurred, so retry/idempotency behavior was not independently exercised. Preserve exact original payloads and keys for retries; do not reuse a key for another payload or repeat these writes with new keys.

## Pending

- Training fixture: resolved by the successful follow-up below; no longer blocked.
- Three negative prompts: Not run in intended ChatGPT host. Do not invoke mutating tools for deletion, watch control or settings edits; no such capabilities are exposed.
- Actual ChatGPT prompt routing, real demo recording/playback/hosting and portal saved-version checks: Not run.
- Public pages: latest network check received HTTP 403 for all six tested support/policy URLs. Earlier evidence saw support 404 and policies differing from local copies. Current deployment/content remains unverified.

## Follow-up after publisher reported “Both are saved”

Rechecked October 31–November 6 inclusive: list_workouts returned items=[], nextCursor=null; get_training_stats still returned 0 workouts, 0 completed sets and 0 volume. Connector still reports Free, 1 routine, 0 custom exercises and lists the exact seeded routine ID 84e2f828-11ed-420f-b362-bdb802c6ce73. The completed-workout fixture is not yet visible through the connected cloud account. Need to distinguish saved routine sets from a finished/synced workout and verify the mobile account before calling the training case passed.

## Successful follow-up after publisher confirmed completion

Training case Passed. get_training_stats({from:2026-10-31,to:2026-11-06,weightUnit:kg}) returned workouts=1, durationSeconds=11, completedSets=2, volume=320, weightUnit=kg, distance=0, muscles={chest:2,triceps:2}, equipment={barbell:2}. Muscle distributions overlap; they do not mean four distinct sets.

list_workouts returned d8ba7701-2162-45ae-b4c8-4982576815d9, parentId=84e2f828-11ed-420f-b362-bdb802c6ce73, startingDate=2026-11-06T14:54:16+00:00, durationSeconds=11, one component and no warnings. get_workouts read back standard flat barbell bench press, two normal sets with done=true, reps=8 and weight=20 kg each, restSeconds=90. unavailable=[], warnings=[]. The expected 320 kg volume matches 2 × 8 × 20. All six positive tool workflows now pass direct live-tool rehearsal. Earlier empty results above are historical sync observations. ChatGPT prompt-routing/negative-case rehearsal, recording and portal tests remain pending.
