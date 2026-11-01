import { createClient } from "npm:@supabase/supabase-js@2";
import { Services } from "../mcp-services/core.ts";
import { handleTrainer } from "./handler.ts";
const url = Deno.env.get("SUPABASE_URL")!;
const key = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const services = new Services({ supabaseUrl: url, serviceKey: key,
  revenueCatKey: Deno.env.get("REVENUECAT_SECRET_API_KEY") ?? "",
  entitlement: Deno.env.get("REVENUECAT_ACCESS_ENTITLEMENT_ID") ?? "",
  environment: Deno.env.get("REVENUECAT_ENVIRONMENT") === "SANDBOX" ? "SANDBOX" : "PRODUCTION",
  userAgent: "GymBro-Trainers/1.0",
});
const client = createClient(url, key, { auth: { persistSession: false, autoRefreshToken: false } });
Deno.serve(req => handleTrainer(req, client, id => services.billing(id)));
