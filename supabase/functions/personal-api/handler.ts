import type { SupabaseClient } from "npm:@supabase/supabase-js@2";
import { sanitizeProgram } from "./program.ts";
const operations = new Set([
  "overview",
  "history",
  "detail",
  "progress",
  "routines",
  "share_create",
  "shares",
  "share_revoke",
  "read",
  "catalog",
]);
const headers = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, apikey, content-type, x-client-info",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Cache-Control": "no-store",
  "Referrer-Policy": "no-referrer",
};
export async function handlePersonal(req: Request, client: SupabaseClient) {
  const reply = (body: unknown, status = 200) =>
    Response.json(body, { status, headers });
  if (req.method === "OPTIONS") return new Response(null, { headers });
  if (req.method !== "POST") return reply({ error: "method_not_allowed" }, 405);
  try {
    const raw = await req.text();
    if (new TextEncoder().encode(raw).length > 1100000) {
      return reply({ error: "request_too_large" }, 413);
    }
    const body = JSON.parse(raw);
    if (!body || Array.isArray(body) || !operations.has(body.operation)) {
      return reply({ error: "invalid_request" }, 400);
    }
    let actor: string | null = null;
    if (!["read", "catalog"].includes(body.operation)) {
      const token = req.headers.get("Authorization")?.replace(/^Bearer /i, "");
      if (!token) return reply({ error: "unauthorized" }, 401);
      const { data: claims, error: bad } = await client.auth.getClaims(token);
      if (
        bad || claims?.claims.role !== "authenticated" ||
        claims.claims.client_id
      ) return reply({ error: "unauthorized" }, 401);
      const { data: { user }, error } = await client.auth.getUser(token);
      if (error || !user) return reply({ error: "unauthorized" }, 401);
      actor = user.id;
    }
    if (body.operation === "read" && !/^[a-f0-9]{48}$/.test(body.token ?? "")) {
      return reply({ error: "not_found" }, 404);
    }
    if (body.operation === "share_create") {
      body.document = sanitizeProgram(body.document);
    }
    const { data, error } = await client.rpc("personal_execute", {
      actor,
      operation: body.operation,
      payload: body,
    });
    if (error) throw error;
    return reply(data);
  } catch (e) {
    const error = e as { code?: string; message?: string };
    const invalid = e instanceof SyntaxError ||
      ["22023", "22P02", "22007", "22008", "23514"].includes(
        error.code ?? "",
      ) ||
      ["invalid_program", "unsupported_version"].includes(error.message ?? "");
    const status = error.code === "P0002"
      ? 404
      : error.code === "42501"
      ? 403
      : invalid
      ? 400
      : 500;
    return reply({
      error: status === 404
        ? "not_found"
        : status === 403
        ? "forbidden"
        : invalid
        ? (error.message === "unsupported_version"
          ? "unsupported_version"
          : "invalid_request")
        : "temporarily_unavailable",
    }, status);
  }
}
