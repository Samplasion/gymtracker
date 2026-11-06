# Separate product follow-up: diagnostics consent

Status: open. The publisher chose to track this separately and continue plugin preparation on November 6, 2026.

The current app initializes Sentry in lib/main.dart before any user diagnostics choice. It enables crash/error reporting, performance profiling, sampled session replay and logs; default PII collection is disabled and sensitive chart masking is configured. There is no general in-app opt-out/consent setting in the inspected implementation.

Decide which diagnostics require opt-in for the intended users and jurisdictions, implement the required consent/withdrawal controls, and verify that collection starts/stops accordingly. Test replay masking on actual fitness and account screens, diagnostic payloads, feedback fields and configured retention. Confirm the appropriate treatment of health data and required consent in account, health and integration flows. Corrected policy wording alone does not resolve runtime consent requirements.

No telemetry changes were made during the policy/plugin task. Do not advertise a switch until one exists or mark this item complete without implementation and verification.
