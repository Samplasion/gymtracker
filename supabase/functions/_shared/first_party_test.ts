import { isFirstPartyCall } from "./first_party.ts";
Deno.test("account-management functions deny delegated OAuth tokens before admin operations", () => {
  const cases: [string, unknown, boolean][] = [
    ["secret", null, true],
    ["user", { role: "authenticated" }, true],
    ["user", {
      role: "gymbro_mcp_user",
      client_id: "chatgpt",
      app_metadata: { is_admin: true },
    }, false],
    ["user", { role: "authenticated", client_id: "chatgpt" }, false],
    ["user", null, false],
    ["user", { role: "service_role" }, false],
    ["anonymous", {}, false],
  ];
  for (const [mode, claims, expected] of cases) {
    if (isFirstPartyCall(mode, claims) !== expected) {
      throw new Error(
        `Unexpected authorization for ${mode}: ${JSON.stringify(claims)}`,
      );
    }
  }
});
