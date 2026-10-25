export type Fetcher = typeof fetch;
export class ServiceError extends Error {
  constructor(public code: string) {
    super(code);
  }
}
export type ServiceConfig = {
  supabaseUrl: string;
  serviceKey: string;
  revenueCatKey: string;
  entitlement: string;
  environment: "PRODUCTION" | "SANDBOX";
  userAgent: string;
};
export class Services {
  constructor(readonly config: ServiceConfig, readonly http: Fetcher = fetch) {}
  async admin(name: string, args: Record<string, unknown> = {}) {
    const response = await this.http(
      `${this.config.supabaseUrl}/rest/v1/rpc/${name}`,
      {
        method: "POST",
        headers: {
          apikey: this.config.serviceKey,
          Authorization: `Bearer ${this.config.serviceKey}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify(args),
        signal: AbortSignal.timeout(15000),
      },
    );
    if (!response.ok) {
      const body = await response.json().catch(() => ({}));
      throw new ServiceError(
        body.code === "P1005"
          ? "external_rate_limited"
          : "external_service_unavailable",
      );
    }
    // PostgREST returns 204 for void RPCs, including mcp_store_billing.
    // The write has already succeeded; parsing an empty body would turn it
    // into a misleading invalid_input error in the service handler.
    if (response.status === 204) return null;
    return await response.json();
  }
  async billing(userId: string) {
    if (!this.config.revenueCatKey || !this.config.entitlement) {
      throw new ServiceError("billing_unavailable");
    }
    const observedAt = new Date().toISOString();
    const response = await this.http(
      `https://api.revenuecat.com/v1/subscribers/${encodeURIComponent(userId)}`,
      {
        headers: {
          Authorization: `Bearer ${this.config.revenueCatKey}`,
          Accept: "application/json",
        },
        signal: AbortSignal.timeout(15000),
      },
    );
    if (!response.ok) throw new ServiceError("billing_unavailable");
    const body = await response.json();
    if (!body.subscriber || typeof body.subscriber.entitlements !== "object") {
      throw new ServiceError("billing_unavailable");
    }
    const ent = body.subscriber.entitlements[this.config.entitlement];
    let expiration: string | null = null, active = false;
    if (ent) {
      const sub = body.subscriber.subscriptions?.[ent.product_identifier] ??
        body.subscriber.non_subscriptions?.[ent.product_identifier]?.at(-1);
      const sandbox = sub?.is_sandbox === true;
      if (!sandbox || this.config.environment === "SANDBOX") {
        const dates = [ent.expires_date, sub?.grace_period_expires_date].filter(
          (d: unknown) => typeof d === "string",
        ).map((d: string) => Date.parse(d));
        if (dates.some((d: number) => !Number.isFinite(d))) {
          throw new ServiceError("billing_unavailable");
        }
        expiration = dates.length
          ? new Date(Math.max(...dates)).toISOString()
          : null;
        active = expiration === null || Date.parse(expiration) > Date.now();
      }
      // RevenueCat's merged entitlement can point to a sandbox lifetime purchase
      // even while a separate production promotional grant is active. Evaluate
      // those grants independently, using their own expiration (not ent's null).
      // Match the full entitlement + documented v1 duration, never a loose prefix
      // that could accidentally recognize a different entitlement.
      for (
        const duration of [
          "daily",
          "three_day",
          "weekly",
          "two_week",
          "monthly",
          "two_month",
          "three_month",
          "six_month",
          "yearly",
          "lifetime",
        ]
      ) {
        const grant = body.subscriber.subscriptions?.[
          `rc_promo_${this.config.entitlement}_${duration}`
        ];
        if (
          !grant || grant.store !== "promotional" ||
          grant.is_sandbox !== false || grant.refunded_at != null ||
          typeof grant.expires_date !== "string"
        ) continue;
        const until = Date.parse(grant.expires_date);
        if (!Number.isFinite(until)) {
          throw new ServiceError("billing_unavailable");
        }
        if (until <= Date.now()) continue;
        if (
          !active || (expiration !== null && until > Date.parse(expiration))
        ) {
          expiration = new Date(until).toISOString();
        }
        active = true;
      }
    }
    await this.admin("mcp_store_billing", {
      account_id: userId,
      active,
      expiration,
      environment: this.config.environment,
      observed_at: observedAt,
    });
    return { refreshed: true };
  }
  async product(barcode: string) {
    if (!/^\d{4,32}$/.test(barcode)) throw new ServiceError("invalid_input");
    const url = new URL(`${this.config.supabaseUrl}/rest/v1/food_catalog`);
    url.searchParams.set("select", "food");
    url.searchParams.set("barcode", `eq.${barcode}`);
    url.searchParams.set("status", "eq.published");
    url.searchParams.set("limit", "1");
    const response = await this.http(url, {
      headers: {
        apikey: this.config.serviceKey,
        Authorization: `Bearer ${this.config.serviceKey}`,
      },
      signal: AbortSignal.timeout(15000),
    });
    if (!response.ok) throw new ServiceError("external_service_unavailable");
    const rows = await response.json();
    const food = rows[0]?.food ?? null;
    return food;
  }
}
export function mapProduct(p: Record<string, any>, language = "it") {
  const n = p.nutriments ?? {};
  const mappings: Record<string, string> = {
    calories: "energy-kcal",
    fat: "fat",
    saturatedFat: "saturated-fat",
    carbs: "carbohydrates",
    sugar: "sugars",
    protein: "proteins",
    salt: "salt",
    sodium: "sodium",
    fiber: "fiber",
    addedSugars: "added-sugars",
    caffeine: "caffeine",
    calcium: "calcium",
    iron: "iron",
    vitaminC: "vitamin-c",
    magnesium: "magnesium",
    phosphorus: "phosphorus",
    potassium: "potassium",
    zinc: "zinc",
    copper: "copper",
    selenium: "selenium",
    vitaminA: "vitamin-a",
    vitaminE: "vitamin-e",
    vitaminD: "vitamin-d",
    vitaminB1: "vitamin-b1",
    vitaminB2: "vitamin-b2",
    vitaminPP: "vitamin-pp",
    vitaminB6: "vitamin-b6",
    vitaminB12: "vitamin-b12",
    vitaminB9: "vitamin-b9",
    vitaminK: "vitamin-k",
    cholesterol: "cholesterol",
    alcohol: "alcohol",
    pantothenicAcid: "pantothenic-acid",
    biotin: "biotin",
    chloride: "chloride",
    chromium: "chromium",
    fluoride: "fluoride",
    iodine: "iodine",
    manganese: "manganese",
    molybdenum: "molybdenum",
  };
  Object.assign(mappings, {
    butyricAcid: "butyric-acid",
    caproicAcid: "caproic-acid",
    caprylicAcid: "caprylic-acid",
    capricAcid: "capric-acid",
    lauricAcid: "lauric-acid",
    myristicAcid: "myristic-acid",
    palmiticAcid: "palmitic-acid",
    stearicAcid: "stearic-acid",
    oleicAcid: "oleic-acid",
    linoleicAcid: "linoleic-acid",
    docosahexaenoicAcid: "docosahexaenoic-acid",
    eicosapentaenoicAcid: "eicosapentaenoic-acid",
    erucicAcid: "erucic-acid",
    monounsaturatedFat: "monounsaturated-fat",
    polyunsaturatedFat: "polyunsaturated-fat",
    omega3: "omega-3-fat",
    omega6: "omega-6-fat",
    omega9: "omega-9-fat",
    betaCarotene: "beta-carotene",
    bicarbonate: "bicarbonate",
    sugarAlcohol: "polyols",
    alphaLinolenicAcid: "alpha-linolenic-acid",
    arachidicAcid: "arachidic-acid",
    arachidonicAcid: "arachidonic-acid",
    behenicAcid: "behenic-acid",
    ceroticAcid: "cerotic-acid",
    dihomoGammaLinolenicAcid: "dihomo-gamma-linolenic-acid",
    elaidicAcid: "elaidic-acid",
    gammaLinolenicAcid: "gamma-linolenic-acid",
    gondoicAcid: "gondoic-acid",
    lignocericAcid: "lignoceric-acid",
    meadAcid: "mead-acid",
    melissicAcid: "melissic-acid",
    montanicAcid: "montanic-acid",
    nervonicAcid: "nervonic-acid",
    transFat: "trans-fat",
  });
  const micro = new Set([
    "selenium",
    "vitaminA",
    "vitaminD",
    "vitaminB12",
    "vitaminB9",
    "vitaminK",
    "biotin",
    "chromium",
    "iodine",
    "molybdenum",
  ]);
  const milli = new Set([
    "calcium",
    "iron",
    "vitaminC",
    "magnesium",
    "phosphorus",
    "potassium",
    "zinc",
    "copper",
    "vitaminE",
    "vitaminB1",
    "vitaminB2",
    "vitaminPP",
    "vitaminB6",
    "cholesterol",
    "pantothenicAcid",
    "chloride",
    "fluoride",
    "manganese",
    "omega3",
    "omega6",
    "omega9",
    "bicarbonate",
  ]);
  const values: Record<string, number | null> = {};
  for (const [key, off] of Object.entries(mappings)) {
    const value = n[`${off}_100g`];
    values[key] =
      typeof value === "number" && Number.isFinite(value) && value >= 0
        ? value * (micro.has(key) ? 1e6 : milli.has(key) ? 1000 : 1)
        : null;
  }
  if (values.calories === null && typeof n["energy-kj_100g"] === "number") {
    values.calories = n["energy-kj_100g"] / 4.184;
  }
  const unit =
    /(?:\d|\b)(ml|l|cl)\b/i.test(`${p.quantity ?? ""} ${p.serving_size ?? ""}`)
      ? "ml"
      : "g";
  return {
    name: String(p[`product_name_${language}`] || p.product_name || p.code),
    brand: p.brands ?? null,
    unit,
    nutritionalValuesPer100g: values,
    servingSizes:
      typeof p.serving_quantity === "number" && p.serving_quantity > 0
        ? [{ name: p.serving_size ?? "", amount: p.serving_quantity }]
        : [],
    barcode: String(p.code),
    isDownloaded: true,
  };
}
