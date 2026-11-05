import { strictEqual as eq } from "node:assert";
import type { SupabaseClient } from "npm:@supabase/supabase-js@2";
import { handlePersonal } from "./handler.ts";
function fake(claims: Record<string, unknown> = { role: "authenticated" }) {
  const calls: Record<string, unknown>[] = [];
  return {
    calls,
    client: {
      auth: {
        getClaims: async () => ({ data: { claims } }),
        getUser: async () => ({ data: { user: { id: "verified-user" } } }),
      },
      rpc: async (_name: string, args: Record<string, unknown>) => {
        calls.push(args);
        return { data: { ok: true } };
      },
    } as unknown as SupabaseClient,
  };
}
const request = (body: unknown, auth = true) =>
  new Request("https://test.invalid", {
    method: "POST",
    headers: auth ? { Authorization: "Bearer test" } : {},
    body: JSON.stringify(body),
  });
Deno.test("private operations reject anonymous and delegated sessions", async () => {
  for (
    const operation of [
      "overview",
      "history",
      "detail",
      "progress",
      "routines",
      "share_create",
      "shares",
      "share_revoke",
    ]
  ) {
    const f = fake({ role: "authenticated", client_id: "external" });
    eq((await handlePersonal(request({ operation }), f.client)).status, 401);
    eq(
      (await handlePersonal(request({ operation }, false), f.client)).status,
      401,
    );
    eq(f.calls.length, 0);
  }
});
Deno.test("caller cannot choose actor", async () => {
  const f = fake();
  eq(
    (await handlePersonal(
      request({ operation: "history", actor: "victim" }),
      f.client,
    )).status,
    200,
  );
  eq(f.calls[0].actor, "verified-user");
});
Deno.test("only token reads and catalog are public", async () => {
  const f = fake();
  eq(
    (await handlePersonal(
      request({ operation: "read", token: "a".repeat(48) }, false),
      f.client,
    )).status,
    200,
  );
  eq(f.calls[0].actor, null);
  eq(
    (await handlePersonal(
      request({ operation: "read", token: "invalid" }, false),
      f.client,
    )).status,
    404,
  );
  eq(f.calls.length, 1);
});
Deno.test("invalid snapshots fail before persistence", async () => {
  const f = fake();
  eq(
    (await handlePersonal(
      request({ operation: "share_create", document: { version: 2 } }),
      f.client,
    )).status,
    400,
  );
  eq(f.calls.length, 0);
});
