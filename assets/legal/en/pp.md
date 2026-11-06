# Privacy Policy

**Last Updated:** November 6, 2026

This Privacy Policy explains how **TECHTONIC FAULT** ("we," "us," or "our") collects, uses, and protects your information when you use the Gym Bro application (the "App"), its website, and its officially supported integrations, including connections to AI assistants such as ChatGPT.

## 1. Data Processing Architecture & Infrastructure
Gym Bro is designed with a privacy-focused architecture:
* **Local-First Default:** All workout logs, meal plans, metrics, and custom exercise entries created within the App are stored locally on your device by default.
* **Opt-In Cloud Features:** Account-based online features—including account registration, cross-device cloud synchronization, the friends feed, and connections to supported AI assistants—are entirely **opt-in**. If you choose to enable these features, your data is processed and stored using **Supabase** as our database and backend infrastructure provider. Supabase processes application data on our behalf to provide these backend services; this policy explains how Gym Bro uses that data. For further information about Supabase’s practices, see its [Privacy Policy](https://supabase.com/privacy), [Data Processing Addendum](https://supabase.com/legal/customer-resources/data-processing-addendum), and [data residency and retention information](https://supabase.com/legal/privacy-resources/data-residency-and-transfers-faq).

## 2. Information We Collect
Depending on how you interact with the App, we may collect or process the following categories of data:

### A. Fitness and Health Data
* **Workout & Nutrition Data:** Exercise types, weights, reps, set logs, custom exercise names, meal logs, and nutritional values stored locally on your device.

### B. Account, Sync & Social Data (Opt-In Cloud Features)
When you register for an account and enable cloud sync:
* **Account Credentials:** Email address, username, and authentication identifiers to secure your account and synchronize data across devices.
* **Friends Feed & Social Data:** Workout summaries, custom exercise names, and completion metrics that you choose to share with your approved connections/friends within the App.
* **Workout & Nutrition Data:** Copies of exercise types, weights, reps, set logs, custom exercise names, meal logs, and nutritional values are stored in the cloud for synchronization across devices and for sharing with friends, if you opt-in to these features.

### C. Diagnostics, Performance and Bug Reports
We use **Sentry** for crash and error reporting, performance monitoring, diagnostic logs and sampled session replay to understand failures and improve the App. This can include device and system information, stack traces, navigation or interaction events, and recorded representations of the interface. Reports are not necessarily anonymous or aggregated. The App disables Sentry’s default personally identifying information collection and configures masking for sensitive charts; these measures do not guarantee that every diagnostic item is free of personal data.

If you submit a bug report, the description and any name or email address you choose to provide are processed to investigate and respond. Do not include passwords or unnecessary health information in reports. See the [Sentry Privacy Policy](https://sentry.io/privacy/) for additional provider information. You can disable diagnostic data sent to Sentry, including sampled session replay, in **Settings → Advanced → Send diagnostic data to Sentry**. Your choice takes effect immediately, is stored on this device and is respected on subsequent launches. Disabling does not delete data already sent; contact us about your privacy choices and rights.

### D. In-App Purchases & Billing
Payment processing for subscriptions and lifetime perpetual licenses is handled directly by platform providers (e.g., Apple App Store or Google Play Store). We do not store or process your payment-card details on our systems. We use **RevenueCat** to manage and verify purchase entitlements, including whether your connected Gym Bro account has Free or Pro access. This involves processing your account identifier and purchase or entitlement information. See the [RevenueCat Privacy Policy](https://www.revenuecat.com/privacy/).

### E. Connections to AI Assistants (Optional)
When you authorize a supported AI assistant to connect to your Gym Bro account and request an action, Gym Bro sends the information retrieved for that action to the connected assistant’s provider. Depending on your request, this may include exercise definitions, routines, saved workouts, training summaries, food diary and nutrition data, drinking-water records, weight and body measurements, and account-plan limits. The connection requires an authenticated account and uses Gym Bro’s Supabase-hosted backend.

When you ask the assistant to save supported information, the resulting records are added to your Gym Bro account. Those records are handled like the corresponding records created in the App, including for synchronization, retention and account deletion. Connecting an assistant does not enable unsupported actions, such as deleting records or controlling a live workout.

The provider of the AI assistant processes the conversation and data it receives under its own applicable terms, privacy policy and account settings. Review those before connecting, particularly when requesting access to fitness or health information. Gym Bro does not determine that provider’s independent retention or use of conversation data.

You can revoke the connection through the available account or connected-service controls. Revocation stops future access as the authorization takes effect; an already-issued access token can remain valid until it expires. Disconnecting does not delete records already saved in Gym Bro or information already received by the assistant’s provider. To manage the latter, use that provider’s data controls or contact it directly.

### F. Service Operation and Security Logs
Gym Bro and its infrastructure providers process operational and security logs to run the service, investigate failures and protect accounts. Depending on the service and configuration, these logs may include request times, network and request metadata, response status, and security or error events. The connection’s application error logging records a service label, event label and error code, without including the prompt or tool request/response body in that log entry. Infrastructure logging is separate and is governed by the applicable service configuration and provider retention schedules.

Operational logging needed to provide and secure online services is separate from App diagnostics. Supabase’s linked privacy and infrastructure information provides additional details about its processing; it does not replace this Gym Bro policy.

### G. Health and Watch Features
With the relevant device or platform permissions, Gym Bro works with supported phone/watch health services, including Apple Health/HealthKit and Android Health Connect. Depending on the platform and enabled feature, it reads workout information, heart rate and active energy, displays live workout metrics, and writes supported workout records. You can manage health access through the platform’s permission controls. Revoking permission does not itself delete previously saved records or copies in the platform’s health store.

### H. Trainers and Public Food Contributions
When you use trainer features, we process trainer/client relationships, proposed training plans and revisions, and the workout information you choose to share with a connected trainer. The service uses this information to deliver plans and allow the trainer to review authorized workouts. Use the available sharing and disconnection controls to manage future access; stopping sharing cannot retrieve copies someone has already received.

If you explicitly submit a food definition or correction to the shared catalog, the product name, brand, barcode, nutritional values and serving information can be published for other users. Catalog contributions are separate from your private food diary and cloud synchronization. Published product definitions and corrections can remain available after account deletion. Moderation reports and audit information are processed to manage the catalog. Do not submit personal information in public product fields.

Infrastructure and diagnostic providers can process information outside your country, including outside the EEA. Their linked privacy and processing documents describe relevant locations and safeguards; contact us for information about the transfers applicable to your data.

---

## 3. Legal Grounds for Processing (EU GDPR Compliance)
If you reside in the European Economic Area (EEA), our legal bases for processing your data under the General Data Protection Regulation (GDPR) are:
* **Consent & Voluntary Activation:** Creating an account does not by itself constitute consent to every use of your data. Optional sharing, AI connections and device health access depend on the choices and authorizations you make for those features. Where consent is the applicable legal basis, including explicit consent where required for health data, it applies to the specified processing purpose. Optional AI connections are activated separately when you authorize the connection and request supported actions; account creation alone does not enable them. You can withdraw your consent at any time, including by revoking an optional connection. This does not affect the lawfulness of processing before withdrawal.
* **Contractual Necessity:** Processing needed to provide the account and online features you request, including synchronization and supported integrations, and to fulfill purchases or restore paid licenses. Additional requirements for health data still apply where relevant.
* **Legitimate Interests:** Processing technical, operational and security data to maintain service security, investigate failures and provide functionality. This does not remove any consent requirement applicable to a particular diagnostic or health-data processing activity.

---

## 4. Your Privacy Rights
Depending on applicable law, you can request access, correction, deletion, restriction of processing or a portable copy of your personal data, object to processing based on legitimate interests, and withdraw consent where processing relies on it. Contact us using the details below. You can also complain to your local data-protection authority; in Italy this is the [Garante per la protezione dei dati personali](https://www.garanteprivacy.it/). These rights are subject to the conditions and exceptions of the applicable law.

### California Consumer Privacy Act (CCPA/CPRA) Disclosures
For residents of California:
* **No Sale or Sharing of Personal Information:** We **do not sell** or **share** (for cross-context behavioral advertising) your personal information or health data with third parties.
* **Your Rights:** You have the right to request access to the personal data we hold about you, request deletion of your data, and opt out of any non-essential data collection.

---

## 5. Data Retention & Account Deletion
* **Local Data:** Uninstalling normally removes the App’s local data on that device. Exported files, device or operating-system backups, watch copies, health-platform records and cloud data are separate and are not necessarily removed. Manage those copies through their respective controls.
* **Cloud Account & Data Deletion:** If you have created a cloud account, you can request deletion of your account and associated private cloud records through the App settings or our web account page. Published catalog contributions and the separately retained copies described below are not automatically removed by that action. The account page is at:
  <https://gym-bro.techtonicfault.com/account>
* **Records Saved Through Integrations:** The same account retention and deletion controls apply to records saved through an AI connection. Deleting your Gym Bro account does not delete conversations or copies held independently by the connected AI provider.
* **Operational and Security Logs:** Retention depends on the relevant log category, service configuration and infrastructure provider’s applicable retention schedule, taking into account operation, security and troubleshooting needs. Account deletion does not necessarily remove existing operational logs or backup copies immediately; those remain subject to the applicable retention and deletion cycle. See the linked Supabase information for its infrastructure practices, or contact us for information about your data.
* **Diagnostics and Bug Reports:** Retention follows the applicable diagnostic service configuration and provider schedules, according to troubleshooting, performance and support needs. These records are separate from synchronized account data; contact us to exercise your rights concerning a report or other personal information.

---

## 6. Contact & Data Controller
For privacy inquiries or to exercise your data rights:
* **Data Controller:** TECHTONIC FAULT (Operated by Francesco Arieti, Italy)
* **Contact:** `support@techtonicfault.com`
