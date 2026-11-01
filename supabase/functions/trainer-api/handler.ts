import type { SupabaseClient } from "npm:@supabase/supabase-js@2";
export const operations = new Set([
  "session", "synced", "activate", "settings", "invite_create", "invite_revoke", "invites", "invite_accept",
  "events", "overview", "clients", "client", "history", "templates", "template_save", "plans", "plan_save", "publish",
  "accept", "reject", "share", "unshare", "disconnect", "catalog",
]);
const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, apikey, content-type, x-client-info",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};
export async function handleTrainer(req: Request, client: SupabaseClient, refreshBilling: (id: string) => Promise<unknown>) {
  const reply = (data: unknown, status = 200) => Response.json(data, { status, headers: cors });
  if (req.method === "OPTIONS") return new Response(null, { headers: cors });
  if (req.method !== "POST") return reply({ error: "method_not_allowed" }, 405);
  try {
    const token = req.headers.get("Authorization")?.replace(/^Bearer /i, "");
    if (!token) return reply({ error: "unauthorized" }, 401);
    const { data: claims, error: invalid } = await client.auth.getClaims(token);
    if (invalid || claims?.claims.role !== "authenticated" || claims.claims.client_id) return reply({ error: "unauthorized" }, 401);
    const { data: { user }, error } = await client.auth.getUser(token);
    if (error || !user) return reply({ error: "unauthorized" }, 401);
    const raw = await req.text();
    if (new TextEncoder().encode(raw).length > 1100000) return reply({ error: "request_too_large" }, 413);
    const body = JSON.parse(raw);
    if (!body || Array.isArray(body) || !operations.has(body.operation)) return reply({ error: "invalid_request" }, 400);
    if (body.operation === "accept") {
      if (body.protocol_version !== 1) return reply({ error: "update_required" }, 409);
      try {
        await refreshBilling(user.id);
      } catch {
        return reply({ error: "billing_unavailable" }, 503);
      }
    }
    const { data, error: failure } = await client.rpc("trainer_execute", { actor: user.id, operation: body.operation, payload: body });
    if (failure) throw failure;
    return reply(data);
  } catch (error) {
    const e = error as { code?: string; message?: string };
    const status = e.code === "42501" ? 403 : e.code === "P0002" ? 404
      : ["23505", "40001", "40P01"].includes(e.code ?? "") ? 409
      : e.code === "P1003" ? 402 : e.code === "P1002" || e.code === "billing_unavailable" ? 503
      : error instanceof SyntaxError || ["22023", "22P02", "23514", "23502"].includes(e.code ?? "") ? 400 : 500;
    const known = new Set(["billing_unavailable", "noncontiguous_superset", "routine_exercise_limit", "trainer_controlled", "relationship_ended", "proposal_superseded", "routine_slots_exhausted", "exercise_slots_exhausted", "already_linked", "self_link", "invite_unavailable", "identity_conflict", "client_limit", "trainer_required"]);
    return reply({ error: known.has(e.message ?? "") ? e.message : status === 503 ? "temporarily_unavailable" : status === 409 ? "conflict" : status === 403 ? "forbidden" : status === 404 ? "not_found" : status === 400 ? "invalid_request" : "server_error" }, status);
  }
}
