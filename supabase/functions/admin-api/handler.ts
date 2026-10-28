import { loadDashboard } from "./dashboard.ts";
import type { SupabaseClient } from "npm:@supabase/supabase-js@2";
import {
  errorStatus,
  isAdmin,
  operatorNote,
  type Section,
  sections,
} from "./core.ts";
const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, apikey, content-type, x-client-info",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};
export async function handleAdmin(
  req: Request,
  client: SupabaseClient,
) {
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
    // Fresh user metadata makes revocation effective without waiting for JWT expiry.
    const { data: { user }, error: authError } = await client.auth.getUser(
      token,
    );
    if (authError || !user) return reply({ error: "unauthorized" }, 401);
    if (!isAdmin(user, verified.claims)) {
      return reply({ error: "forbidden" }, 403);
    }
    const b = await req.json();
    if (!b || typeof b !== "object") {
      return reply({ error: "invalid_request" }, 400);
    }
    if (b.operation === "dashboard") return reply(await loadDashboard(client));
    if (b.operation === "catalogReview") {
      const { data, error } = await client.rpc("catalog_operator_execute", {
        actor: user.id,
        operation: "review",
        payload: { ...b, operationId: b.operationId ?? crypto.randomUUID() },
      });
      if (error) throw error;
      return reply(data);
    }
    if (b.operation === "session") {
      return reply({ id: user.id, email: user.email });
    }
    const checked = async (
      query: PromiseLike<{ data: unknown; error: { code?: string } | null }>,
    ) => {
      const r = await query;
      if (r.error) throw r.error;
      return r.data;
    };
    if (b.operation === "updateProfile") {
      // An exact allowlist prevents metadata/role writes, including self-promotion.
      if (
        Object.keys(b).some((k) =>
          !["operation", "id", "username", "fullName", "updatedAt", "note"]
            .includes(k)
        ) ||
        typeof b.id !== "string" || typeof b.username !== "string" ||
        !/^[a-zA-Z0-9_]{3,30}$/.test(b.username) ||
        typeof b.fullName !== "string" || b.fullName.trim().length > 100 ||
        typeof b.updatedAt !== "string" ||
        !Number.isFinite(Date.parse(b.updatedAt))
      ) {
        return reply({ error: "invalid_request" }, 400);
      }
      await checked(client.rpc("admin_update_public_profile", {
        target_id: b.id,
        expected_updated_at: b.updatedAt,
        new_username: b.username,
        new_full_name: b.fullName.trim(),
        operator_id: user.id,
        note: operatorNote(user.email, user.id, b.note),
      }));
      return reply({ ok: true });
    }
    if (b.operation === "list" || b.operation === "detail") {
      if (!Object.hasOwn(sections, b.section)) {
        return reply({ error: "invalid_section" }, 400);
      }
      const section = b.section as Section, config = sections[section];
      let query = client.from(config.table).select(config.columns);
      if (b.operation === "detail") {
        if (typeof b.id !== "string" && typeof b.id !== "number") {
          return reply({ error: "invalid_id" }, 400);
        }
        const record = await checked(query.eq("id", b.id).maybeSingle()) as
          | Record<string, unknown>
          | null;
        if (!record) return reply({ error: "not_found" }, 404);
        const extra: Record<string, unknown> = {};
        if (
          section === "catalogRequests" || section === "catalog" ||
          section === "corrections" ||
          section === "foodReports"
        ) {
          const foodId = section === "catalog" ? record.id : record.food_id;
          extra.product = await checked(
            client.from("food_catalog").select(sections.catalog.columns).eq(
              "id",
              foodId,
            ).single(),
          );
          extra.counts = await checked(
            client.rpc("admin_catalog_report_counts", { product_id: foodId }),
          );
        }
        if (section === "users") {
          const { data, error } = await client.auth.admin.getUserById(
            String(record.id),
          );
          if (error || !data.user) throw error ?? new Error("missing_user");
          extra.permissions = {
            is_admin: data.user.app_metadata?.is_admin === true,
          };
          extra.permissionsReadOnly = true;
        }
        return reply({ record, ...extra });
      }
      const offset = b.offset ?? 0;
      if (!Number.isSafeInteger(offset) || offset < 0) {
        return reply({ error: "invalid_offset" }, 400);
      }
      if (b.status === "active" && section === "social") {
        query = query.in("status", ["received", "reviewing"]);
      } else if (b.status) {
        if (!config.statuses?.includes(b.status)) {
          return reply({ error: "invalid_status" }, 400);
        }
        query = query.eq("status", b.status);
      }
      if (b.reason) {
        if (
          section !== "foodReports" ||
          ![
            "spam",
            "inappropriate",
            "nutrition",
            "product",
            "duplicate",
            "other",
          ].includes(b.reason)
        ) return reply({ error: "invalid_reason" }, 400);
        query = query.eq("reason", b.reason);
      }
      if (
        b.foodId && ["audit", "foodReports", "corrections"].includes(section)
      ) query = query.eq("food_id", b.foodId);
      if (b.userId && section === "social") {
        if (
          typeof b.userId !== "string" || !/^[0-9a-f-]{36}$/i.test(b.userId)
        ) return reply({ error: "invalid_id" }, 400);
        query = query.or(
          `reporter_id.eq.${b.userId},reported_id.eq.${b.userId}`,
        );
      }
      if (b.userId && section === "foodReports") {
        query = query.eq("reporter_id", b.userId);
      }
      if (b.search && section === "users") {
        if (typeof b.search !== "string" || b.search.length > 200) {
          return reply({ error: "invalid_search" }, 400);
        }
        const words = b.search.match(/[\p{L}\p{N}_]+/gu) ?? [];
        if (!words.length) return reply({ rows: [] });
        const term = words.join(" ");
        query = query.or(`username.ilike.%${term}%,full_name.ilike.%${term}%`);
      }
      if (b.reportId && section === "notes") {
        query = query.eq("report_id", b.reportId);
      }
      if (b.search && section === "catalog") {
        if (typeof b.search !== "string" || b.search.length > 200) {
          return reply({ error: "invalid_search" }, 400);
        }
        // Sanitize PostgREST filter syntax; each term must prefix a name/brand token.
        const words = b.search.match(/[\p{L}\p{N}]+/gu) ?? [];
        if (!words.length) return reply({ rows: [] });
        if (words.length) {
          query = query.or(
            `barcode.eq.${words.join("")},search_document.fts(simple).${
              words.map((w: string) => `${w}:*`).join(" & ")
            }`,
          );
        }
      }
      if (section === "push") {
        query = query.or("finished_at.is.null,last_error.not.is.null");
      }
      const rows = await checked(
        query.order(config.order, {
          ascending: section === "social" || section === "corrections" ||
            section === "push",
        }).order("id", { ascending: false }).range(offset, offset + 49),
      );
      return reply({ rows });
    }
    const operations = [
      "moderate",
      "review",
      "dismiss",
      "transition",
      "requeue",
    ];
    if (!operations.includes(b.operation)) {
      return reply({ error: "invalid_operation" }, 400);
    }
    const uuid =
      /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
    if (b.operation === "requeue") {
      if (
        !Number.isSafeInteger(b.id) || b.id < 1 ||
        !Number.isSafeInteger(b.attempts) ||
        b.attempts < 8 || typeof b.availableAt !== "string" ||
        !Number.isFinite(Date.parse(b.availableAt))
      ) return reply({ error: "invalid_request" }, 400);
    } else if (typeof b.id !== "string" || !uuid.test(b.id)) {
      return reply({ error: "invalid_id" }, 400);
    }
    if (
      ["moderate", "review"].includes(b.operation) &&
      (!Number.isSafeInteger(b.version) || b.version < 1)
    ) return reply({ error: "invalid_version" }, 400);
    if (
      b.operation === "transition" &&
      (typeof b.updatedAt !== "string" ||
        !Number.isFinite(Date.parse(b.updatedAt)) ||
        !((b.status === "received" && b.nextStatus === "reviewing") ||
          (b.status === "reviewing" &&
            ["resolved", "dismissed"].includes(b.nextStatus))))
    ) return reply({ error: "invalid_transition" }, 400);
    const note = operatorNote(user.email, user.id, b.note);
    let rpc: string, args: Record<string, unknown>;
    switch (b.operation) {
      case "moderate":
        if (!["suspend", "restore", "remove"].includes(b.action)) {
          return reply({ error: "invalid_action" }, 400);
        }
        rpc = "admin_moderate_catalog_food";
        args = {
          food_id: b.id,
          expected_version: b.version,
          action: b.action,
          note,
        };
        break;
      case "review":
        if (typeof b.approve !== "boolean") {
          return reply({ error: "invalid_approval" }, 400);
        }
        rpc = "admin_review_catalog_correction";
        args = {
          correction_id: b.id,
          expected_version: b.version,
          approve: b.approve,
          note,
        };
        break;
      case "dismiss":
        rpc = "admin_resolve_catalog_report";
        args = { report_id: b.id, note };
        break;
      case "transition":
        rpc = "admin_transition_report";
        args = {
          report_id: b.id,
          expected_status: b.status,
          expected_updated_at: b.updatedAt,
          next_status: b.nextStatus,
          note,
        };
        break;
      case "requeue":
        rpc = "admin_requeue_push";
        args = {
          delivery_id: b.id,
          expected_attempts: b.attempts,
          expected_available_at: b.availableAt,
          operator_id: user.id,
          note,
        };
        break;
      default:
        return reply({ error: "invalid_operation" }, 400);
    }
    await checked(client.rpc(rpc, args));
    return reply({ ok: true });
  } catch (e) {
    if (
      e instanceof SyntaxError ||
      e instanceof Error && e.message === "invalid_note"
    ) return reply({ error: "invalid_request" }, 400);
    const code = (e as { code?: string })?.code;
    const status = errorStatus(code);
    return reply({
      error: status === 409
        ? "conflict"
        : status === 400
        ? "invalid_request"
        : "server_error",
    }, status);
  }
}
