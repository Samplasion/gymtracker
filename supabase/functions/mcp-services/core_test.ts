import { mapProduct, ServiceConfig, Services } from "./core.ts";
function equal(a: unknown, b: unknown) {
  if (JSON.stringify(a) !== JSON.stringify(b)) {
    throw new Error(`${JSON.stringify(a)} != ${JSON.stringify(b)}`);
  }
}
const config: ServiceConfig = {
  supabaseUrl: "https://supabase.test",
  serviceKey: "server-only",
  revenueCatKey: "private",
  entitlement: "pro",
  environment: "PRODUCTION",
  userAgent: "GymBro-MCP test",
};
const product = {
  code: "12345678",
  product_name: "Food",
  nutriments: {
    "energy-kcal_100g": 100,
    "fat_100g": 0,
    "calcium_100g": 0.1,
    "vitamin-b12_100g": 0.000002,
  },
};
Deno.test("OFF mapping preserves zeros, marks missing nutrients and converts micronutrient units", () => {
  const food = mapProduct(product);
  equal(food.nutritionalValuesPer100g.calories, 100);
  equal(food.nutritionalValuesPer100g.fat, 0);
  equal(food.nutritionalValuesPer100g.sugar, null);
  equal(food.nutritionalValuesPer100g.calcium, 100);
  equal(food.nutritionalValuesPer100g.vitaminB12, 2);
});
Deno.test("RevenueCat cancellation does not revoke access before expiry; sandbox never grants production Pro", async () => {
  for (const sandbox of [false, true]) {
    let stored: Record<string, unknown> = {};
    const service = new Services(config, async (input, init) => {
      if (String(input).startsWith("https://api.revenuecat.com/")) {
        return Response.json({
          subscriber: {
            entitlements: {
              pro: {
                expires_date: "2099-01-01T00:00:00Z",
                product_identifier: "annual",
              },
            },
            subscriptions: {
              annual: {
                is_sandbox: sandbox,
                unsubscribe_detected_at: "2026-01-01T00:00:00Z",
              },
            },
          },
        });
      }
      stored = JSON.parse(String(init?.body));
      return Response.json(null);
    });
    await service.billing("account");
    equal(stored.active, !sandbox);
  }
});
Deno.test("RevenueCat lifetime, trial, grace period and expired entitlement are resolved server side", async () => {
  for (
    const [expiration, grace, expected] of [[null, null, true], [
      "2000-01-01T00:00:00Z",
      null,
      false,
    ], ["2000-01-01T00:00:00Z", "2099-01-01T00:00:00Z", true]] as const
  ) {
    let active: unknown;
    const service = new Services(
      config,
      async (input, init) =>
        String(input).startsWith("https://api.revenuecat.com/")
          ? Response.json({
            subscriber: {
              entitlements: {
                pro: { expires_date: expiration, product_identifier: "p" },
              },
              subscriptions: {
                p: {
                  is_sandbox: false,
                  period_type: "trial",
                  grace_period_expires_date: grace,
                },
              },
            },
          })
          : (active = JSON.parse(String(init?.body)).active,
            Response.json(null)),
    );
    await service.billing("account");
    equal(active, expected);
  }
});
Deno.test("billing failures never persist an inferred free/pro status", async () => {
  let writes = 0;
  const service = new Services(config, async (input) => {
    if (String(input).includes("revenuecat")) {
      return new Response(null, { status: 503 });
    }
    writes++;
    return Response.json(null);
  });
  let rejected = false;
  try {
    await service.billing("account");
  } catch {
    rejected = true;
  }
  equal(rejected, true);
  equal(writes, 0);
});
Deno.test("cached products avoid provider calls and uncached lookups reserve the shared budget", async () => {
  const calls: string[] = [];
  const service = new Services(config, async (input, init) => {
    calls.push(String(input));
    if (String(input).includes("mcp_cache_food")) {
      const body = JSON.parse(String(init?.body));
      return Response.json(body.definition ?? { name: "cached" });
    }
    throw new Error("Provider should not be called");
  });
  equal((await service.product("12345678"))?.name, "cached");
  equal(calls.length, 1);
});
Deno.test("search cursors are bound to source filters before network access", async () => {
  const service = new Services(config, () => {
    throw new Error("Network should not be used");
  });
  let rejected = false;
  try {
    await service.search({
      query: "food",
      language: "it",
      country: "it",
      limit: 20,
      cursor: btoa(JSON.stringify({ page: 2, filter: "another query" })),
    });
  } catch {
    rejected = true;
  }
  equal(rejected, true);
});

Deno.test("OFF search cursors round-trip Unicode queries without leaking account identity", async () => {
  const service = new Services(
    config,
    async () => Response.json({ products: [product], count: 2 }),
  );
  service.admin = () => Promise.resolve(null);
  const args = { query: "riso 🍚", language: "it", country: "it", limit: 1 };
  const first = await service.search(args);
  if (!first.nextCursor) throw new Error("Missing cursor");
  const second = await service.search({ ...args, cursor: first.nextCursor });
  equal(second.items.length, 1);
  equal(second.nextCursor, null);
});
