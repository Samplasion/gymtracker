import { createServiceHandler } from "./handler.ts";
import { readConfig, tokenVerifier } from "../mcp/auth.ts";
import { Services } from "./core.ts";
const config = readConfig();
const verify = tokenVerifier(config);
const services = new Services({
  supabaseUrl: config.supabaseUrl,
  serviceKey: Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
  revenueCatKey: Deno.env.get("REVENUECAT_SECRET_API_KEY") ?? "",
  entitlement: Deno.env.get("REVENUECAT_ACCESS_ENTITLEMENT_ID") ?? "",
  environment: Deno.env.get("REVENUECAT_ENVIRONMENT") === "SANDBOX"
    ? "SANDBOX"
    : "PRODUCTION",
  userAgent: "GymBro-MCP/0.2 (https://gym-bro.techtonicfault.com)",
});
Deno.serve(
  createServiceHandler(
    config,
    services,
    verify,
    Deno.env.get("REVENUECAT_WEBHOOK_AUTHORIZATION"),
  ),
);
