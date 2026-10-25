import { createHandler, database } from "./server.ts";
import { type Config, metadataUrl, verifyToken } from "./auth.ts";
import {
  catalogVersion,
  programSchema,
  search,
  searchSchema,
  standardExercises,
  ToolError,
} from "./schemas.ts";
import { createLocalJWKSet, exportJWK, generateKeyPair, SignJWT } from "jose";

const config: Config = {
  resource: "https://gymbro.test/functions/v1/mcp",
  supabaseUrl: "https://supabase.test",
  clientId: "chatgpt-test",
  publicKey: "public",
  siteOrigin: "https://gym-bro.techtonicfault.com",
};
function assert(value: unknown, message = "Assertion failed"): asserts value {
  if (!value) throw new Error(message);
}
function equal(a: unknown, b: unknown) {
  assert(
    JSON.stringify(a) === JSON.stringify(b),
    `${JSON.stringify(a)} != ${JSON.stringify(b)}`,
  );
}
const standard = standardExercises.find((e) => e.parameters === "repsWeight")!;
const custom = {
  source: "custom" as const,
  id: "private-a",
  name: "Mio esercizio",
  category: "custom",
  parameters: "time",
  primaryMuscleGroup: "abs",
  secondaryMuscleGroups: [],
  equipment: "none",
};
const called: { name: string; args: Record<string, unknown> }[] = [];
const handler = createHandler(config, (token) => {
  if (token !== "valid") return Promise.reject(new Error("Invalid"));
  return Promise.resolve();
}, () => (name, args = {}) => {
  called.push({ name, args });
  if (
    name === "mcp_execute" &&
    [
      "search_foods",
      "list_measurements",
      "get_measurements",
      "create_measurements",
      "list_water_entries",
      "get_water_entries",
      "log_water",
    ].includes(String(args.operation))
  ) {
    return Promise.resolve({ items: [], nextCursor: null });
  }
  if (
    name === "mcp_execute" &&
    ["get_hydration_summary", "get_nutrition_summary"].includes(
      String(args.operation),
    )
  ) {
    return Promise.resolve({
      settings: [{ date: "2026-10-25", goal: { dailyWater: null } }],
      entries: [],
      waterEntries: [{ date: "2026-10-25", milliliters: 500 }],
    });
  }
  if (name === "mcp_custom_exercises") return Promise.resolve([custom]);
  if (name === "mcp_create_program") {
    return Promise.resolve({ folderId: "folder", routines: [{ id: "day1" }] });
  }
  if (name === "mcp_list_routines") {
    return Promise.resolve([{ id: "one" }, { id: "two" }]);
  }
  throw new ToolError("reference_unavailable", "Routine unavailable");
});
async function rpc(method: string, params: unknown = {}) {
  const response = await handler(
    new Request(config.resource, {
      method: "POST",
      headers: {
        Authorization: "Bearer valid",
        "Content-Type": "application/json",
        Accept: "application/json, text/event-stream",
      },
      body: JSON.stringify({ jsonrpc: "2.0", id: 1, method, params }),
    }),
  );
  equal(response.status, 200);
  const text = await response.text();
  return JSON.parse(
    text.startsWith("event:") || text.startsWith("data:")
      ? text.split("\n").find((l) => l.startsWith("data:"))!.slice(5)
      : text,
  );
}
Deno.test("public discovery and authenticated transport do not expose tools anonymously", async () => {
  const metadata = await handler(new Request(metadataUrl(config)));
  equal(metadata.status, 200);
  equal((await metadata.json()).resource, config.resource);
  const gatewayMetadata = await handler(
    new Request("http://edge-runtime/mcp/.well-known/oauth-protected-resource"),
  );
  equal(gatewayMetadata.status, 200);
  equal((await gatewayMetadata.json()).resource, config.resource);
  equal((await handler(new Request("http://edge-runtime/mcp"))).status, 401);
  for (const token of ["", "Bearer invalid"]) {
    const response = await handler(
      new Request(config.resource, {
        method: "POST",
        headers: { Authorization: token },
      }),
    );
    equal(response.status, 401);
    assert(
      response.headers.get("www-authenticate")?.includes(metadataUrl(config)),
    );
  }
  equal(
    (await handler(
      new Request(config.resource, {
        headers: { Origin: "https://evil.test" },
      }),
    )).status,
    403,
  );
});
Deno.test("real MCP SDK initializes and exposes compatible and expanded annotated OAuth tools", async () => {
  const initialized = await rpc("initialize", {
    protocolVersion: "2025-03-26",
    capabilities: {},
    clientInfo: { name: "test", version: "1" },
  });
  equal(initialized.result.serverInfo.name, "gym-bro");
  const list = await rpc("tools/list");
  equal(list.result.tools.length, 29);
  for (
    const name of [
      "create_program",
      "get_exercises",
      "get_routine",
      "list_routines",
      "search_exercises",
      "log_foods",
      "get_account_limits",
      "create_routines",
    ]
  ) assert(list.result.tools.some((t: { name: string }) => t.name === name));
  for (const tool of list.result.tools) {
    equal(tool._meta.securitySchemes, [{ type: "oauth2", scopes: ["openid"] }]);
    equal(
      tool.annotations.readOnlyHint,
      !tool.name.startsWith("create_") && tool.name !== "log_foods" &&
        tool.name !== "log_water",
    );
  }
});
Deno.test("search combines bilingual catalog with private exercises, filters and pages deterministically", () => {
  const all = [...standardExercises, custom];
  const found = search(
    all,
    searchSchema.parse({ query: "mio esercizio", language: "en" }),
  );
  equal(found.items.map((e) => e.id), ["private-a"]);
  const italian = search(
    all,
    searchSchema.parse({ query: standard.names!.it, language: "en" }),
  );
  assert(
    italian.items.some((e) =>
      e.id === standard.id && e.name === standard.names!.en
    ),
  );
  const first = search(all, searchSchema.parse({ limit: 1 }));
  const second = search(
    all,
    searchSchema.parse({ limit: 1, offset: first.nextOffset }),
  );
  assert(first.items[0].id !== second.items[0].id);
  const filtered = search(
    all,
    searchSchema.parse({
      muscles: ["abs"],
      equipment: "none",
      source: "custom",
    }),
  );
  equal(filtered.items.map((e) => e.id), [custom.id]);
});
Deno.test("exercise resolution reports missing references without leaking other users", async () => {
  const result = await rpc("tools/call", {
    name: "get_exercises",
    arguments: {
      references: [{ source: "custom", id: custom.id }, {
        source: "custom",
        id: "other-user",
      }],
    },
  });
  equal(result.result.structuredContent.items.length, 1);
  equal(result.result.structuredContent.unavailable, [{
    source: "custom",
    id: "other-user",
  }]);
  equal(result.result.structuredContent.catalogVersion, catalogVersion);
});
Deno.test("program defaults normalize retries and never allow caller identity or generated metadata", async () => {
  const program = {
    name: "Program",
    routines: [{
      name: "Day 1",
      exercises: [{
        exerciseRef: { source: "standard", id: standard.id },
        sets: [{ reps: 8 }],
      }],
    }],
  };
  const normalized = programSchema.parse(program);
  equal(normalized.routines[0].weightUnit, "kg");
  const entry = normalized.routines[0].exercises[0];
  assert("sets" in entry);
  equal(entry.sets[0].weight, undefined);
  assert(
    !programSchema.safeParse({ ...program, userId: "other-user" }).success,
  );
  assert(!programSchema.safeParse({ ...program, routines: [] }).success);
  const result = await rpc("tools/call", {
    name: "create_program",
    arguments: {
      program,
      idempotencyKey: "b303cefc-01a7-4da4-9d2c-4ca75cefbe65",
    },
  });
  equal(result.result.structuredContent.folderId, "folder");
  const saved = called.findLast((c) => c.name === "mcp_create_program")!;
  equal(saved.args.program, normalized);
});
Deno.test("routine pagination and unavailable routine return structured tool results", async () => {
  const page = await rpc("tools/call", {
    name: "list_routines",
    arguments: { limit: 1 },
  });
  equal(page.result.structuredContent, {
    items: [{ id: "one" }],
    nextOffset: 1,
  });
  const missing = await rpc("tools/call", {
    name: "get_routine",
    arguments: { id: "unavailable" },
  });
  assert(missing.result.isError);
  equal(missing.result.structuredContent.error.code, "reference_unavailable");
});
Deno.test("JWT verification rejects expired, wrong audience, issuer, client, role and ordinary login tokens", async () => {
  const { privateKey, publicKey } = await generateKeyPair("ES256");
  const jwk = await exportJWK(publicKey);
  jwk.kid = "test";
  const keys = createLocalJWKSet({ keys: [jwk] });
  const claims = {
    sub: "00000000-0000-0000-0000-000000000031",
    client_id: config.clientId,
    role: "gymbro_mcp_user",
    aud: ["authenticated", config.resource],
    iss: `${config.supabaseUrl}/auth/v1`,
    iat: Math.floor(Date.now() / 1000),
    exp: Math.floor(Date.now() / 1000) + 60,
  };
  const sign = (override: Record<string, unknown>) =>
    new SignJWT({ ...claims, ...override }).setProtectedHeader({
      alg: "ES256",
      kid: "test",
    }).sign(privateKey);
  await verifyToken(await sign({}), config, keys);
  for (
    const override of [
      { exp: 1 },
      { nbf: Math.floor(Date.now() / 1000) + 3600 },
      { aud: "authenticated" },
      { iss: "https://evil.test" },
      { client_id: "other" },
      { role: "authenticated" },
      { client_id: null },
    ]
  ) {
    let rejected = false;
    try {
      await verifyToken(await sign(override), config, keys);
    } catch {
      rejected = true;
    }
    assert(rejected, `Accepted ${JSON.stringify(override)}`);
  }
});
Deno.test("chunked oversized requests are rejected before MCP parsing", async () => {
  const response = await handler(
    new Request(config.resource, {
      method: "POST",
      headers: { Authorization: "Bearer valid" },
      body: " ".repeat(1048577),
    }),
  );
  equal(response.status, 413);
});

Deno.test("food search defaults to all local and shared sources without external search", async () => {
  const before = called.length;
  const result = await rpc("tools/call", {
    name: "search_foods",
    arguments: { query: "Pollo" },
  });
  equal(result.result.structuredContent.items, []);
  equal(called.slice(before), [{
    name: "mcp_execute",
    args: {
      operation: "search_foods",
      request: {
        query: "Pollo",
        source: "all",
        language: "it",
        country: "it",
        limit: 20,
      },
    },
  }]);
  const catalog = await rpc("tools/call", {
    name: "search_foods",
    arguments: { query: "Milk", source: "catalog" },
  });
  equal(catalog.result.structuredContent.items, []);
  equal(
    (called.at(-1)?.args.request as Record<string, unknown>).source,
    "catalog",
  );
  const count = called.length;
  const invalid = await rpc("tools/call", {
    name: "search_foods",
    arguments: { query: "Pollo", source: "openfoodfacts" },
  });
  assert(invalid.result?.isError || invalid.error);
  equal(called.length, count);
});

Deno.test("missing billing triggers authoritative refresh and retries account limits before returning a plan", async () => {
  const actions: string[] = [];
  let reads = 0;
  const db = database(config, "valid", (input, init) => {
    const body = JSON.parse(String(init?.body));
    if (String(input).endsWith("/mcp-services")) {
      equal(body, { action: "billing" });
      actions.push("refresh");
      return Promise.resolve(Response.json({ refreshed: true }));
    }
    actions.push("read");
    reads++;
    return Promise.resolve(
      reads === 1
        ? Response.json({ code: "P1002" }, { status: 400 })
        : Response.json({ plan: "pro" }),
    );
  });
  equal(
    await db("mcp_execute", { operation: "get_account_limits", request: {} }),
    { plan: "pro" },
  );
  equal(actions, ["read", "refresh", "read"]);
});
Deno.test("failed billing refresh never invents a Free plan", async () => {
  const db = database(config, "valid", (input) =>
    Promise.resolve(
      String(input).endsWith("/mcp-services")
        ? Response.json({ error: "billing_unavailable" }, { status: 503 })
        : Response.json({ code: "P1002" }, { status: 400 }),
    ));
  let code: string | undefined;
  try {
    await db("mcp_execute", { operation: "get_account_limits", request: {} });
  } catch (error) {
    if (error instanceof ToolError) code = error.code;
    else throw error;
  }
  equal(code, "billing_unavailable");
});

Deno.test("measurement tools support mixed creation and strict physiological types", async () => {
  const key = "b303cefc-01a7-4da4-9d2c-4ca75cefbe77";
  const result = await rpc("tools/call", {
    name: "create_measurements",
    arguments: {
      idempotencyKey: key,
      entries: [{ kind: "weight", value: 70, time: "2026-10-24" }, {
        kind: "body",
        type: "bodyFat",
        value: 15.5,
      }],
    },
  });
  equal(result.result.structuredContent.items, []);
  const saved = called.findLast((c) =>
    c.args.operation === "create_measurements"
  )!;
  equal(saved.args.idempotency_key, key);
  equal((saved.args.request as any).entries[0].unit, "kg");
  for (
    const entry of [
      { kind: "body", type: "bodyFat", value: 101 },
      { kind: "body", type: "chest", unit: "inch", value: 30 },
      { kind: "weight", value: -1 },
      { kind: "weight", value: 60, time: "2026-10-24T12:00:00" },
    ]
  ) {
    const count = called.length;
    const invalid = await rpc("tools/call", {
      name: "create_measurements",
      arguments: { idempotencyKey: key, entries: [entry] },
    });
    assert(invalid.result?.isError || invalid.error);
    equal(called.length, count);
  }
});

Deno.test("water tools preserve fractional volume, optional time and strict bulk schemas", async () => {
  const key = "b303cefc-01a7-4da4-9d2c-4ca75cefbe88";
  const logged = await rpc("tools/call", {
    name: "log_water",
    arguments: { idempotencyKey: key, entries: [{ milliliters: 500.25 }] },
  });
  equal(logged.result.structuredContent.items, []);
  const saved = called.findLast((c) => c.args.operation === "log_water")!;
  equal(saved.args.request, { entries: [{ milliliters: 500.25 }] });
  equal(saved.args.idempotency_key, key);
  for (
    const entry of [
      { milliliters: 0 },
      { milliliters: -1 },
      { milliliters: 100, unit: "l" },
      { milliliters: 200, pieces: 2 },
      { milliliters: 200, time: "2026-10-25T12:00:00" },
    ]
  ) {
    const count = called.length;
    const invalid = await rpc("tools/call", {
      name: "log_water",
      arguments: { idempotencyKey: key, entries: [entry] },
    });
    assert(invalid.result?.isError || invalid.error);
    equal(called.length, count);
  }
  for (
    const [name, args] of [["list_water_entries", {
      from: "2026-10-24",
      to: "2026-10-25",
    }], ["get_water_entries", { ids: ["record"] }]] as const
  ) {
    const r = await rpc("tools/call", { name, arguments: args });
    equal(r.result.structuredContent.items, []);
  }
});

Deno.test("hydration summary tool returns text equivalent to structured content and nutrition hydration", async () => {
  const args = { from: "2026-10-25", to: "2026-10-25" };
  const water = (await rpc("tools/call", {
    name: "get_hydration_summary",
    arguments: args,
  })).result;
  equal(JSON.parse(water.content[0].text), water.structuredContent);
  const food = (await rpc("tools/call", {
    name: "get_nutrition_summary",
    arguments: args,
  })).result;
  equal(
    water.structuredContent.items[0],
    food.structuredContent.items[0].hydration,
  );
  equal(water.structuredContent.items[0].knownTotalWaterMl, 500);
  equal(food.structuredContent.items[0].totals.water, 0);
});
