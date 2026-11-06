# Gym Bro submission preparation

Status: draft package prepared; not ready for public submission. No plugin upload, submission, publication, website deployment or app release has occurred. The existing private development plugin was preserved.

## Completed

- Portable Gym Bro package and draft archive: `gym-bro/`, `gym-bro-draft-1.0.0.zip`.
- TECHTONIC FAULT publisher name, all available countries, confirmed Free/Pro commerce disclosure, icon, listing, prompts and release notes.
- Six positive and three negative cases embedded in the manifest. The food case now uses explicit synthetic manual values; it requires no publication to the shared food catalog. All six positive cases now pass direct live-tool rehearsal; three negative host-prompt cases remain pending. ChatGPT and saved-portal checks remain separate.
- English and Italian support routes implemented and locally checked in the landing repository.
- All eight website/app policy documents reviewed, corrected and rendered. See policy-review.md. Diagnostics consent is a separate open follow-up at the publisher’s request.
- Dedicated-account setup instructions, one schema-validated routine seed plan and a recording walkthrough prepared. Dedicated account verified in the website; routine seeded and read back after fresh connector checks. Synthetic food, water and measurements saved by their review cases. No credentials packaged.

## Verification evidence

- Previous local server checks: 32 MCP tests plus 17 service tests passed, and MCP entry point type check passed. No server source has changed during this policy review; those tests were not unnecessarily rerun.
- All 29 source tools have the required boolean annotations. Prior package schema, listing-length, icon and archive checks passed.
- Live read-only smoke checks through the existing connector succeeded: standard exercise search for “bench”, then category=chest/equipment=barbell returned real exercise references, including flat/decline/incline bench press. This verifies connectivity and filtering, not the identity of a dedicated test account or all review cases. No records were written.
- Live website check: homepage HTTP 200; `/en/support` and `/it/support` HTTP 404; all four published policy Markdown files HTTP 200 but differ from the corrected local files. See checks/live-pages.json. The supportURL remains absent until the public page exists and passes content/access checks.
- Matched website/app policy bodies, successful Markdown rendering of all eight documents, and clean whitespace checks.
- Prepared routine payload checked against the actual MCP routine schema. Final draft ZIP reopened and compared to current manifest; no app bindings, account credentials, seed plan, server source or review notes included.

## Current action: host rehearsal and recording

November 6, 2026: the fresh chat successfully called Gym Bro tools. get_account_limits returned Free, zero routines and zero custom exercises before seeding, consistent with the dedicated account rather than the previous Pro account. The authenticated website showed gymbro_plugin_review_1, the expected test email, Europe/Rome and one ChatGPT authorization. The tools expose no explicit account identifier, so verification combines that website identity with fresh empty-account usage and the publisher’s reconnect.

Created and read back Review - Upper body, routine ID 84e2f828-11ed-420f-b362-bdb802c6ce73, using the original idempotency key. All six positive workflows passed direct live-tool rehearsal. Sample food, 500 ml water, 72.5 kg weight and 18% body-fat measurements were saved only to the test account. See checks/live-tool-rehearsal.md for record references and retry keys. Do not create these fixtures again with new keys.

The completed-workout fixture has now synced and passed: 1 workout, 2 completed bench-press sets of 8 reps at 20 kg, 320 kg volume. Workout ID d8ba7701-2162-45ae-b4c8-4982576815d9. Both sets were read back as done=true, with no warnings. No purchase is required. Negative prompt behavior and the real ChatGPT recording still need rehearsal in the intended host.

The latest automated public-page recheck received HTTP 403 for both support routes and all four policy Markdown files. This does not establish whether deployment occurred; the earlier check observed support 404 and old policies. Verify ordinary browser access and current content before adding supportURL or declaring the policies live.

## Then finish preparation

1. Publish the prepared support pages and corrected legal documents through the intended website release process, then verify all four listing destinations and add supportURL.
2. Rehearse the actual connection with the dedicated account, run the declared cases and record evidence. Never use production personal records as test fixtures.
3. Record the real walkthrough, check playback and absence of secrets, host it at a reviewer-accessible location, verify the link, then add review.demo_recording_url. The existing walkthrough document is not a recording.
4. Rebuild and inspect the final ZIP. The draft is not submission-ready while these items remain.

Optional dark-mode icons and brand colors are not present and do not block preparation.

## Later portal requirements

Only after preparation and an authorized upload: use the intended organization and verified TECHTONIC FAULT identity, upload a draft, configure the actual static OAuth connection, verify imported metadata, run saved-version checks, provide reviewer credentials through secure fields, and complete required scans, domain/developer verification and developer attestations. No secrets belong in the ZIP or chat. Upload, review submission and publication are separate actions. A valid archive does not establish legal compliance or guarantee approval.
