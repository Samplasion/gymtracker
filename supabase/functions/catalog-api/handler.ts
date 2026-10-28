import type { SupabaseClient } from "npm:@supabase/supabase-js@2";
export const catalogOperations = new Set([
  "session",
  "list",
  "detail",
  "requests",
  "create",
  "update",
  "remove",
  "propose",
]);
const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, apikey, content-type, x-client-info",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};
export function isCatalogOperator(
  user: { app_metadata?: Record<string, unknown> } | null,
  claims: Record<string, unknown>,
) {
  return claims.role === "authenticated" && !claims.client_id &&
    (user?.app_metadata?.is_admin === true ||
      user?.app_metadata?.is_catalog_operator === true);
}
export async function handleCatalog(req: Request, client: SupabaseClient) {
  const reply = (body: unknown, status = 200) =>
    Response.json(body, { status, headers: cors });
  if (req.method === "OPTIONS") return new Response(null, { headers: cors });
  if (req.method !== "POST") return reply({ error: "method_not_allowed" }, 405);
  try {
    const token = req.headers.get("Authorization")?.replace(/^Bearer /i, "");
    if (!token) return reply({ error: "unauthorized" }, 401);
    const { data: verified, error: jwtError } = await client.auth.getClaims(
      token,
    );
    if (jwtError || !verified) return reply({ error: "unauthorized" }, 401);
    const { data: { user }, error: authError } = await client.auth.getUser(
      token,
    );
    if (authError || !user) return reply({ error: "unauthorized" }, 401);
    if (!isCatalogOperator(user, verified.claims)) {
      return reply({ error: "forbidden" }, 403);
    }
    const raw = await req.text();
    if (new TextEncoder().encode(raw).length > 100000) {
      return reply({ error: "request_too_large" }, 413);
    }
    const body = JSON.parse(raw);
    if (
      !body || Array.isArray(body) || typeof body !== "object" ||
      !catalogOperations.has(body.operation)
    ) return reply({ error: "invalid_request" }, 400);
    const { data, error } = await client.rpc("catalog_operator_execute", {
      actor: user.id,
      operation: body.operation,
      payload: body,
    });
    if (error) throw error;
    return reply(data);
  } catch (error) {
    const code = (error as { code?: string })?.code;
    const status = error instanceof SyntaxError ||
        ["22023", "22P02", "22003", "23514", "23502"].includes(code ?? "")
      ? 400
      : code === "42501"
      ? 403
      : code === "P0002"
      ? 404
      : ["40001", "23505", "40P01"].includes(code ?? "")
      ? 409
      : 500;
    return reply({
      error: status === 409
        ? "conflict"
        : status === 403
        ? "forbidden"
        : status === 404
        ? "not_found"
        : status === 400
        ? "invalid_request"
        : "server_error",
    }, status);
  }
}
