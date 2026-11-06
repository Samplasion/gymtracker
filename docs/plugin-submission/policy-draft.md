# Policy changes to review before publication

> Update, November 6, 2026: The publisher requested implementation. Updated English and Italian privacy policies and terms are now in `assets/legal/` and the landing website’s `public/{en,it}/terms/` files. Matching bodies and Markdown rendering were verified across all eight documents. The implemented wording explains conditional data sharing, infrastructure logging and provider/configuration-based retention without asserting a fixed period. The website changes still need deployment and the app changes still need release. The proposals below are historical preparation notes, superseded by those files.

These are proposed additions based on the implementation and publisher answers. They have not been applied to the published policies. Resolve provider retention/settings before treating the privacy disclosure as complete. Review equivalent Italian text before publishing both languages.

## Proposed privacy addition: connected AI assistants

When you connect your Gym Bro account to an AI assistant and request an action, Gym Bro returns the requested account information to that assistant’s provider. This may include your routines, saved workouts, food diary, hydration records and body measurements, depending on the request. When you ask the assistant to save supported data, the connection writes the resulting records to your Gym Bro account. The connection uses authenticated access to the Gym Bro backend hosted on Supabase. Data received by the AI provider is also subject to that provider’s applicable terms and privacy settings.

The MCP server’s application error log records a service label, an event label and an error code; the inspected log statement does not include prompts, authorization headers, tool arguments or tool responses.

## Facts still needed for the privacy text

- Actual Supabase/hosting request and error log retention and any additional log destinations.
- Whether request/response bodies are captured outside the inspected application log statement.
- Whether any additional providers process connection data beyond the connected assistant, Supabase and the account-plan checks through RevenueCat.
- Whether existing account deletion and retention language accurately covers records saved through this connection.

Do not claim no logging: platform access logs may exist independently of application log statements. Do not invent retention periods or promise how an independent AI provider handles data.

## Proposed terms correction

The current terms prohibit automated scripts or bots from interacting with the servers. Add a narrowly scoped exception if this reflects the intended policy:

“Automated access through Gym Bro’s officially supported integrations is permitted when you authorize it for your own account and comply with the integration’s documented limits. Other automated collection or access remains subject to the restrictions above.”

Confirm the published terms explicitly cover the Gym Bro connection and its supported account actions. This draft is not a published policy and does not complete submission requirements.
