import { createClient } from "npm:@supabase/supabase-js@2";
import { handleCatalog } from "./handler.ts";
const client = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  {
    auth: { persistSession: false, autoRefreshToken: false },
  },
);
Deno.serve((request) => handleCatalog(request, client));
