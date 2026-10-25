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
Deno.test("legacy barcodes resolve only from the published Gym Bro catalog", async () => {
  const calls: string[] = [];
  const service = new Services(config, async (input) => {
    const url = new URL(String(input));
    equal(url.origin, config.supabaseUrl);
    calls.push(url.pathname);
    if (url.pathname === "/rest/v1/food_catalog") {
      equal(url.searchParams.get("barcode"), "eq.00123456");
      equal(url.searchParams.get("status"), "eq.published");
      return Response.json([{
        food: { name: "Catalog food", isDownloaded: false },
      }]);
    }
    throw new Error("Unexpected catalog call");
  });
  equal((await service.product("00123456"))?.name, "Catalog food");
  equal(calls, ["/rest/v1/food_catalog"]);
});
Deno.test("missing catalog barcodes never fall back to OFF", async () => {
  const service = new Services(config, async (input) => {
    equal(new URL(String(input)).pathname, "/rest/v1/food_catalog");
    return Response.json([]);
  });
  equal(await service.product("00123456"), null);
});

Deno.test("console-granted entitlements are Pro without a store subscription, including lifetime access", async () => {
  for (
    const expires of [null, "2099-01-01T00:00:00Z", "2000-01-01T00:00:00Z"]
  ) {
    let stored: Record<string, unknown> = {};
    const service = new Services(
      { ...config, entitlement: "Gym Bro Pro" },
      (input, init) => {
        if (String(input).startsWith("https://api.revenuecat.com/")) {
          return Promise.resolve(Response.json({
            subscriber: {
              entitlements: {
                "Gym Bro Pro": {
                  expires_date: expires,
                  product_identifier: "rc_promo_lifetime",
                },
              },
              subscriptions: {},
              non_subscriptions: {},
            },
          }));
        }
        stored = JSON.parse(String(init?.body));
        return Promise.resolve(new Response(null, { status: 204 }));
      },
    );
    equal(await service.billing("account"), { refreshed: true });
    equal(stored.active, expires !== "2000-01-01T00:00:00Z");
    equal(
      stored.expiration,
      expires === null ? null : new Date(expires).toISOString(),
    );
  }
});

Deno.test("sandbox lifetime non-subscription cannot grant production Pro", async () => {
  for (const environment of ["PRODUCTION", "SANDBOX"] as const) {
    let active: unknown;
    const service = new Services({ ...config, environment }, (input, init) => {
      if (String(input).startsWith("https://api.revenuecat.com/")) {
        return Promise.resolve(Response.json({
          subscriber: {
            entitlements: {
              pro: { expires_date: null, product_identifier: "lifetime" },
            },
            subscriptions: {},
            non_subscriptions: {
              lifetime: [{ store: "app_store", is_sandbox: true }],
            },
          },
        }));
      }
      active = JSON.parse(String(init?.body)).active;
      return Promise.resolve(new Response(null, { status: 204 }));
    });
    await service.billing("account");
    equal(active, environment === "SANDBOX");
  }
});

Deno.test("production promotional grants survive a sandbox lifetime entitlement snapshot", async () => {
  for (
    const variant of [
      "active",
      "expired",
      "otherEntitlement",
      "sandbox",
      "refunded",
      "wrongStore",
      "missingExpiry",
      "longerEntitlement",
    ] as const
  ) {
    let stored: Record<string, unknown> = {};
    const name = variant === "otherEntitlement"
      ? "Other"
      : variant === "longerEntitlement"
      ? "Gym Bro Pro_extra"
      : "Gym Bro Pro";
    const promo: Record<string, unknown> = {
      store: variant === "wrongStore" ? "app_store" : "promotional",
      is_sandbox: variant === "sandbox",
      expires_date: variant === "expired"
        ? "2000-01-01T00:00:00Z"
        : "2226-09-06T11:33:14Z",
      refunded_at: variant === "refunded" ? "2026-01-01T00:00:00Z" : null,
    };
    if (variant === "missingExpiry") delete promo.expires_date;
    const service = new Services(
      { ...config, entitlement: "Gym Bro Pro" },
      (input, init) => {
        if (String(input).startsWith("https://api.revenuecat.com/")) {
          return Promise.resolve(Response.json({
            subscriber: {
              entitlements: {
                "Gym Bro Pro": {
                  expires_date: null,
                  product_identifier: "sandbox_lifetime",
                },
              },
              subscriptions: { [`rc_promo_${name}_lifetime`]: promo },
              non_subscriptions: {
                sandbox_lifetime: [{ store: "app_store", is_sandbox: true }],
              },
            },
          }));
        }
        stored = JSON.parse(String(init?.body));
        return Promise.resolve(new Response(null, { status: 204 }));
      },
    );
    await service.billing("account");
    equal(stored.active, variant === "active");
    if (variant === "active") {
      equal(stored.expiration, "2226-09-06T11:33:14.000Z");
    }
  }
});
