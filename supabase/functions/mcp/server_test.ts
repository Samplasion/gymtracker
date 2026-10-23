import { createHandler } from "./server.ts";
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
Deno.test("real MCP SDK initializes and exposes exactly five annotated OAuth tools", async () => {
  const initialized = await rpc("initialize", {
    protocolVersion: "2025-03-26",
    capabilities: {},
    clientInfo: { name: "test", version: "1" },
  });
  equal(initialized.result.serverInfo.name, "gym-bro");
  const list = await rpc("tools/list");
  equal(list.result.tools.map((t: { name: string }) => t.name).sort(), [
    "create_program",
    "get_exercises",
    "get_routine",
    "list_routines",
    "search_exercises",
  ]);
  for (const tool of list.result.tools) {
    equal(tool._meta.securitySchemes, [{ type: "oauth2", scopes: ["openid"] }]);
    equal(tool.annotations.readOnlyHint, tool.name !== "create_program");
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
  equal(normalized.routines[0].exercises[0].sets[0].weight, undefined);
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
