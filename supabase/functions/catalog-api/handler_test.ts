import { handleCatalog, isCatalogOperator } from "./handler.ts";
import type { SupabaseClient } from "npm:@supabase/supabase-js@2";
function assert(value: unknown, message = "Assertion failed"): asserts value {
  if (!value) throw new Error(message);
}
Deno.test("catalog access accepts only current boolean operator/admin privileges and ordinary sessions", () => {
  for (
    const metadata of [{ is_admin: true }, { is_catalog_operator: true }, {
      is_admin: true,
      is_catalog_operator: true,
    }]
  ) {
    assert(
      isCatalogOperator({ app_metadata: metadata }, { role: "authenticated" }),
    );
    assert(
      !isCatalogOperator({ app_metadata: metadata }, {
        role: "authenticated",
        client_id: "delegated",
      }),
    );
  }
  for (
    const metadata of [
      {},
      { is_admin: false },
      { is_catalog_operator: "true" },
      { is_admin: "true" },
    ]
  ) {
    assert(
      !isCatalogOperator({ app_metadata: metadata }, { role: "authenticated" }),
    );
  }
});
Deno.test("verified identity replaces forged actor; role is fetched on every request", async () => {
  let metadata: Record<string, unknown> = { is_catalog_operator: true };
  let received: Record<string, unknown> = {};
  const client = {
    auth: {
      getClaims: () => ({ data: { claims: { role: "authenticated" } } }),
      getUser: () => ({
        data: { user: { id: "verified", app_metadata: metadata } },
      }),
    },
    rpc: (_: string, args: Record<string, unknown>) => {
      received = args;
      return { data: { ok: true }, error: null };
    },
  } as unknown as SupabaseClient;
  const req = () =>
    new Request("https://example.invalid", {
      method: "POST",
      headers: { Authorization: "Bearer verified" },
      body: JSON.stringify({ operation: "create", actor: "forged" }),
    });
  assert((await handleCatalog(req(), client)).status === 200);
  assert(received.actor === "verified");
  metadata = {};
  assert((await handleCatalog(req(), client)).status === 403);
});
Deno.test("review is unavailable through catalog endpoint; conflicts remain explicit", async () => {
  const client = {
    auth: {
      getClaims: () => ({ data: { claims: { role: "authenticated" } } }),
      getUser: () => ({
        data: { user: { id: "verified", app_metadata: { is_admin: true } } },
      }),
    },
    rpc: () => ({ error: { code: "40001" } }),
  } as unknown as SupabaseClient;
  const req = (operation: string) =>
    new Request("https://example.invalid", {
      method: "POST",
      headers: { Authorization: "Bearer verified" },
      body: JSON.stringify({ operation }),
    });
  assert((await handleCatalog(req("review"), client)).status === 400);
  assert((await handleCatalog(req("update"), client)).status === 409);
  assert(
    (await handleCatalog(
      new Request("https://example.invalid", { method: "POST" }),
      client,
    )).status === 401,
  );
});
