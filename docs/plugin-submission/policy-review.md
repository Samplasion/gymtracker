# Policy review — November 6, 2026

Reviewed English and Italian website and bundled app documents against the current source. This is an implementation-consistency review, not a certification of legal compliance.

## Corrected across all eight documents

- Removed the nonexistent in-app analytics opt-out and the claim diagnostics are necessarily anonymous/aggregated. Disclosed Sentry crash/error reports, performance data, logs, sampled session replay and optional feedback contact fields. Evidence: lib/main.dart:_sentryInit, lib/service/error_reporter.dart; no corresponding switch found in settings.
- Added supported health/watch access and platform permission controls. Evidence: lib/controller/health_controller.dart, ios/Shared/WorkoutManager.swift, Android HealthExport.kt.
- Added trainer/client relationships, plan revisions and authorized workout sharing. Evidence: lib/service/trainer.dart and trainer-api handlers.
- Added explicitly submitted public food definitions/corrections and their persistence independently of account deletion. Evidence: food-catalog migration, catalog delivery and repository source. No account diary data is described as automatically public.
- Replaced the promise that uninstall permanently removes all copies; exports, backups, health platforms, watch and cloud records are separate. Qualified account deletion to distinguish private records, public catalog contributions and separately retained copies.
- Added privacy-rights and supervisory-authority information, and provider/international-processing context. Account creation is no longer described as blanket consent to all processing.
- Allowed supported trainer use with coaching clients; respected third-party/open-source rights and mandatory-law exceptions rather than asserting exclusive ownership of all components.
- Clarified that mandatory consumer rights and non-excludable liability remain unaffected.

## Verification

All website/app bodies match exactly for their language/document. All eight documents rendered successfully using the website's Markdown stack. Section structure and key disclosures checked; whitespace/diff checks passed. No runtime telemetry behavior was changed. No website deployment or app release occurred.

## Follow-up deliberately separate

The publisher explicitly chose to track diagnostics consent separately and continue the plugin work. The app initializes diagnostics/replay without a general consent control. Correct disclosure does not itself implement any consent required for a particular use of diagnostics or sensitive data. See follow-ups.md. Do not treat this follow-up as resolved or claim public-submission/legal approval.

## Supporting primary sources

- https://www.edpb.europa.eu/sme/be-compliant/respect-individuals-rights_en
- https://www.edpb.europa.eu/sme/be-compliant/process-personal-data-lawfully_en
- https://europa.eu/youreurope/business/selling-in-eu/consumer-contracts-guarantees/consumer-contracts/indexamp_en.htm
- https://supabase.com/privacy
- https://supabase.com/legal/privacy-resources/data-residency-and-transfers-faq
- https://www.revenuecat.com/privacy/
