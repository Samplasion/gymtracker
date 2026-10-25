import { ServiceError, Services } from "./core.ts";
import type { Config } from "../mcp/auth.ts";
import type { JWTPayload } from "jose";
export function createServiceHandler(
  config: Config,
  services: Services,
  verify: (token: string) => Promise<JWTPayload>,
  webhookSecret: string | undefined,
  http: typeof fetch = fetch,
) {
  return async (request: Request) => {
    try {
      if (request.method !== "POST") return new Response(null, { status: 405 });
      const authorization = request.headers.get("authorization") ?? "";
      const isWebhook = Boolean(
        webhookSecret && authorization === webhookSecret,
      );
      let identity;
      if (!isWebhook) {
        try {
          identity = await verify(authorization.replace(/^Bearer /i, ""));
        } catch {
          return Response.json({ error: "authentication_required" }, {
            status: 401,
          });
        }
      }
      const reader = request.body?.getReader();
      const chunks: Uint8Array[] = [];
      let size = 0;
      if (reader) {
        for (;;) {
          const { done, value } = await reader.read();
          if (done) break;
          size += value.length;
          if (size > 1048576) {
            await reader.cancel();
            return new Response(null, { status: 413 });
          }
          chunks.push(value);
        }
      }
      const bytes = new Uint8Array(size);
      let position = 0;
      for (const chunk of chunks) {
        bytes.set(chunk, position);
        position += chunk.length;
      }
      const body = JSON.parse(new TextDecoder().decode(bytes));
      // Webhooks use a separate secret, never user JWTs or event-supplied account claims.
      if (isWebhook) {
        const event = body.event;
        if (!event || typeof event.id !== "string") {
          throw new ServiceError("invalid_input");
        }
        if (
          event.environment && event.environment !== services.config.environment
        ) return Response.json({ ignored: true });
        if (await services.admin("mcp_webhook_event", { event_id: event.id })) {
          return Response.json({ duplicate: true });
        }
        for (const key of ["aliases", "transferred_from", "transferred_to"]) {
          if (
            body.event[key] !== undefined &&
            (!Array.isArray(body.event[key]) || body.event[key].length > 100)
          ) throw new ServiceError("invalid_input");
        }
        const ids = new Set(
          [
            event.app_user_id,
            ...(event.aliases ?? []),
            ...(event.transferred_from ?? []),
            ...(event.transferred_to ?? []),
          ].filter((id) =>
            typeof id === "string" &&
            /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i
              .test(id)
          ),
        );
        if (ids.size > 100) throw new ServiceError("invalid_input");
        for (const id of ids) await services.billing(String(id));
        await services.admin("mcp_webhook_event", {
          event_id: event.id,
          complete: true,
        });
        return Response.json({ processed: true });
      }
      if (body.action === "billing") {
        const status = await http(
          `${config.supabaseUrl}/rest/v1/rpc/mcp_billing_status`,
          {
            method: "POST",
            headers: {
              apikey: config.publicKey,
              Authorization: authorization,
              "Content-Type": "application/json",
            },
            body: "{}",
            signal: AbortSignal.timeout(10000),
          },
        );
        if (status.status === 401 || status.status === 403) {
          throw new ServiceError("authentication_required");
        }
        if (status.ok) {
          const cached = await status.json();
          if (
            cached.environment === services.config.environment &&
            typeof cached.checkedAt === "string" &&
            Date.parse(cached.checkedAt) > Date.now() - 300000
          ) return Response.json({ refreshed: false });
        }
        return Response.json(await services.billing(identity!.sub!));
      }
      // Verify access before resolving catalog products.
      const check = await http(
        `${config.supabaseUrl}/rest/v1/rpc/mcp_execute`,
        {
          method: "POST",
          headers: {
            apikey: config.publicKey,
            Authorization: authorization,
            "Content-Type": "application/json",
          },
          body: JSON.stringify({ operation: "external_access", request: {} }),
        },
      );
      if (!check.ok) {
        throw new ServiceError(
          "authentication_required",
        );
      }
      if (body.action === "food_get") {
        return Response.json({
          food: await services.product(String(body.barcode)),
        });
      }
      // Food search is local-only. Reject stale clients instead of contacting OFF.
      throw new ServiceError("invalid_input");
    } catch (error) {
      return Response.json({
        error: error instanceof SyntaxError
          ? "invalid_input"
          : error instanceof ServiceError
          ? error.code
          : "external_service_unavailable",
      }, {
        status: error instanceof SyntaxError ||
            (error instanceof ServiceError && error.code === "invalid_input")
          ? 400
          : 503,
      });
    }
  };
}
