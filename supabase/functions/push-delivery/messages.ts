import catalog from "./catalog.json" with { type: "json" };

export function notificationMessage(
  locale: string,
  kind: string,
  actor: string,
  params: Record<string, unknown>,
) {
  const language = locale === "it" ? "it" : "en";
  const translations = catalog[language];
  const events: Record<string, string> = translations.events;
  const statuses: Record<string, string> = translations.statuses;
  const base = events[kind] ?? translations.fallback;
  return {
    title: actor || "GymBro",
    body: kind === "report_status"
      ? `${base}: ${statuses[String(params.status)] ?? ""}`
      : base,
  };
}
