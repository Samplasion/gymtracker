import type { SupabaseClient } from "npm:@supabase/supabase-js@2";
import { handleAdmin } from "./handler.ts";
import { operatorNote, sections } from "./core.ts";
function assert(value: unknown, message = "Assertion failed"): asserts value {
  if (!value) throw new Error(message);
}
function mock(
  {
    admin = true,
    role = "authenticated",
    clientId = "",
    errorCode = "",
    claimsError = false,
  } = {},
) {
  const calls: unknown[] = [];
  const client = {
    auth: {
      getClaims: () => ({
        data: claimsError
          ? null
          : { claims: { role, ...(clientId ? { client_id: clientId } : {}) } },
        error: claimsError ? {} : null,
      }),
      getUser: () => ({
        data: {
          user: {
            id: "00000000-0000-0000-0000-000000000001",
            email: "admin@test.local",
            app_metadata: { is_admin: admin },
          },
        },
        error: null,
      }),
    },
    rpc: (name: string, args: unknown) => {
      calls.push({ name, args });
      return {
        data: null,
        error: errorCode ? { code: errorCode, secret: "must not leak" } : null,
      };
    },
  };
  return {
    client: client as unknown as SupabaseClient,
    calls,
  };
}
const request = (body: unknown, token = true) =>
  new Request("http://localhost/admin-api", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      ...(token ? { Authorization: "Bearer test" } : {}),
    },
    body: JSON.stringify(body),
  });
Deno.test("Rejects missing/invalid JWT, ordinary users, revoked admins and delegated OAuth", async () => {
  const cases = [{ admin: false }, { admin: true, clientId: "chatgpt" }, {
    admin: true,
    role: "gymbro_mcp_user",
  }, { claimsError: true }];
  for (const config of cases) {
    const m = mock(config);
    const r = await handleAdmin(request({ operation: "session" }), m.client);
    assert([401, 403].includes(r.status));
    assert(m.calls.length === 0);
  }
  assert((await handleAdmin(request({}, false), mock().client)).status === 401);
});
Deno.test("Reads live metadata on every request, revocation takes immediate effect", async () => {
  const m = mock();
  assert(
    (await handleAdmin(request({ operation: "session" }), m.client)).status ===
      200,
  );
  m.client.auth.getUser = (() => ({
    data: { user: { app_metadata: { is_admin: false } } },
    error: null,
  })) as unknown as typeof m.client.auth.getUser;
  assert(
    (await handleAdmin(request({ operation: "session" }), m.client)).status ===
      403,
  );
});
Deno.test("Injects verified identity into notes and maps conflicts without leaking errors", async () => {
  const m = mock({ errorCode: "40001" });
  const r = await handleAdmin(
    request({
      operation: "moderate",
      id: "00000000-0000-0000-0000-000000000002",
      version: 7,
      action: "suspend",
      note: "controllo",
      actor: "forged",
    }),
    m.client,
  );
  assert(r.status === 409);
  assert(!JSON.stringify(await r.json()).includes("must not leak"));
  assert(JSON.stringify(m.calls).includes("admin@test.local"));
  assert(!JSON.stringify(m.calls).includes("forged"));
});
Deno.test("Validates note including identity prefix and rejects unknown operations", async () => {
  for (const note of ["", " ".repeat(5), "x".repeat(2000), null]) {
    const m = mock();
    const r = await handleAdmin(
      request({
        operation: "dismiss",
        id: "00000000-0000-0000-0000-000000000002",
        note,
      }),
      m.client,
    );
    assert(r.status === 400);
    assert(m.calls.length === 0);
  }
  assert(operatorNote("a@b.test", "id", "OK").includes("(id); OK"));
  assert(
    (await handleAdmin(
      request({ operation: "arbitrary_sql", note: "test" }),
      mock().client,
    )).status === 400,
  );
});
Deno.test("Push projection explicitly excludes device credentials and lease ID", () => {
  assert(!/token|device_id|lease_id|\*/.test(sections.push.columns));
  assert(sections.push.columns.includes("notifications(kind)"));
});
Deno.test("Translates social and push commands into guarded RPC arguments", async () => {
  const m = mock();
  const stamp = "2026-10-24T12:00:00Z";
  const social = await handleAdmin(
    request({
      operation: "transition",
      id: "00000000-0000-0000-0000-000000000002",
      status: "received",
      nextStatus: "reviewing",
      updatedAt: stamp,
      note: "Verifica",
    }),
    m.client,
  );
  assert(social.status === 200);
  assert(JSON.stringify(m.calls).includes("expected_updated_at"));
  const push = await handleAdmin(
    request({
      operation: "requeue",
      id: 1,
      attempts: 8,
      availableAt: stamp,
      note: "Configurazione corretta",
    }),
    m.client,
  );
  assert(push.status === 200);
  assert(JSON.stringify(m.calls).includes("expected_attempts"));
  const invalid = await handleAdmin(
    request({
      operation: "transition",
      id: "00000000-0000-0000-0000-000000000002",
      status: "resolved",
      nextStatus: "reviewing",
      updatedAt: stamp,
      note: "test",
    }),
    m.client,
  );
  assert(invalid.status === 400);
  assert(m.calls.length === 2);
});
