import { createServiceHandler } from "./handler.ts";
import { Services } from "./core.ts";
const config = {
  supabaseUrl: "https://test.supabase.co",
  publicKey: "public",
  clientId: "client",
  resource: "https://test.supabase.co/functions/v1/mcp",
  siteOrigin: "https://site.test",
};
function equal(a: unknown, b: unknown) {
  if (JSON.stringify(a) !== JSON.stringify(b)) {
    throw new Error(`${JSON.stringify(a)} != ${JSON.stringify(b)}`);
  }
}
function harness(consented = true) {
  const calls: string[] = [];
  const events = new Set<string>();
  const services = new Services({
    supabaseUrl: config.supabaseUrl,
    serviceKey: "server",
    revenueCatKey: "rc",
    entitlement: "pro",
    environment: "PRODUCTION",
    userAgent: "test",
  });
  services.admin = (name, args = {}) => {
    calls.push(name);
    if (name === "mcp_webhook_event") {
      if (args.complete) events.add(String(args.event_id));
      return Promise.resolve(events.has(String(args.event_id)));
    }
    return Promise.resolve(null);
  };
  services.billing = (id) => {
    calls.push(`billing:${id}`);
    return Promise.resolve({ refreshed: true });
  };
  services.search = () => {
    calls.push("search");
    throw new Error("External search must not be called");
  };
  services.product = () => {
    calls.push("product");
    return Promise.resolve({ name: "food" });
  };
  const handler = createServiceHandler(
    config,
    services,
    (token) =>
      token === "valid"
        ? Promise.resolve({ sub: "00000000-0000-0000-0000-000000000081" })
        : Promise.reject(new Error()),
    "Bearer webhook-secret",
    () =>
      Promise.resolve(
        consented
          ? Response.json({ allowed: true })
          : Response.json({ code: "P1001" }, { status: 403 }),
      ),
  );
  const request = (body: unknown, token = "Bearer valid") =>
    handler(
      new Request("https://edge/mcp-services", {
        method: "POST",
        headers: { authorization: token },
        body: JSON.stringify(body),
      }),
    );
  return { calls, request };
}
Deno.test("services reject ordinary/forged authorization before external or privileged calls", async () => {
  const h = harness();
  equal((await h.request({ action: "billing" }, "Bearer forged")).status, 401);
  equal(h.calls, []);
});
Deno.test("billing refresh cannot select another account supplied in the body", async () => {
  const h = harness();
  equal((await h.request({ action: "billing", userId: "victim" })).status, 200);
  equal(h.calls, ["billing:00000000-0000-0000-0000-000000000081"]);
});
Deno.test("catalog service repeats consent checks before retrieving external products", async () => {
  const h = harness(false);
  const result = await h.request({ action: "food_get", barcode: "12345678" });
  equal(result.status, 503);
  equal(await result.json(), { error: "consent_required" });
  equal(h.calls, []);
});
Deno.test("webhook retries are idempotent and transfers refresh both affected accounts", async () => {
  const h = harness();
  const body = {
    event: {
      id: "transfer",
      type: "TRANSFER",
      transferred_from: ["00000000-0000-0000-0000-000000000081"],
      transferred_to: ["00000000-0000-0000-0000-000000000082"],
    },
  };
  equal((await h.request(body, "Bearer webhook-secret")).status, 200);
  equal(await (await h.request(body, "Bearer webhook-secret")).json(), {
    duplicate: true,
  });
  equal(h.calls.filter((c) => c.startsWith("billing:")).length, 2);
});
Deno.test("sandbox webhook cannot update the production mirror", async () => {
  const h = harness();
  equal(
    await (await h.request({
      event: {
        id: "sandbox",
        environment: "SANDBOX",
        app_user_id: "00000000-0000-0000-0000-000000000081",
      },
    }, "Bearer webhook-secret")).json(),
    { ignored: true },
  );
  equal(h.calls, []);
});

Deno.test("stale clients cannot invoke the external food search action", async () => {
  const h = harness();
  const response = await h.request({
    action: "food_search",
    query: "Pollo",
    language: "it",
    country: "it",
    limit: 20,
  });
  equal(response.status, 400);
  equal(await response.json(), { error: "invalid_input" });
  equal(h.calls, []);
});

Deno.test("billing refresh succeeds end to end when the storage RPC returns HTTP 204", async () => {
  const calls: string[] = [];
  const services = new Services({
    supabaseUrl: config.supabaseUrl,
    serviceKey: "server-only",
    revenueCatKey: "rc",
    entitlement: "pro",
    environment: "PRODUCTION",
    userAgent: "test",
  }, (input) => {
    calls.push(String(input));
    if (String(input).startsWith("https://api.revenuecat.com/")) {
      return Promise.resolve(
        Response.json({ subscriber: { entitlements: {} } }),
      );
    }
    if (String(input).endsWith("/rpc/mcp_store_billing")) {
      return Promise.resolve(new Response(null, { status: 204 }));
    }
    throw new Error("Unexpected request");
  });
  const handler = createServiceHandler(
    config,
    services,
    () => Promise.resolve({ sub: "00000000-0000-0000-0000-000000000081" }),
    undefined,
    () => Promise.resolve(Response.json({})),
  );
  const response = await handler(
    new Request("https://edge/mcp-services", {
      method: "POST",
      headers: { authorization: "Bearer valid" },
      body: JSON.stringify({ action: "billing" }),
    }),
  );
  equal(response.status, 200);
  equal(await response.json(), { refreshed: true });
  equal(calls.length, 2);
});
