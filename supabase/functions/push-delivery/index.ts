import { createClient } from "npm:@supabase/supabase-js@2";
import { notificationMessage } from "./messages.ts";

type Delivery = {
  id: number;
  lease_id: string;
  attempts: number;
  actor_name: string;
  notification: {
    id: number;
    user_id: string;
    kind: string;
    params: Record<string, unknown>;
  };
  device: { id: string; token: string; locale: string; platform: string };
};
const encode = (value: string | Uint8Array) =>
  btoa(typeof value === "string" ? value : String.fromCharCode(...value))
    .replace(/=/g, "").replace(/\+/g, "-").replace(/\//g, "_");
async function accessToken(
  account: { client_email: string; private_key: string },
) {
  const now = Math.floor(Date.now() / 1000);
  const header = encode(JSON.stringify({ alg: "RS256", typ: "JWT" }));
  const body = encode(
    JSON.stringify({
      iss: account.client_email,
      scope: "https://www.googleapis.com/auth/firebase.messaging",
      aud: "https://oauth2.googleapis.com/token",
      iat: now,
      exp: now + 3600,
    }),
  );
  const pem = account.private_key.replace(/-----[^-]+-----|\s/g, "");
  const key = await crypto.subtle.importKey(
    "pkcs8",
    Uint8Array.from(atob(pem), (c) => c.charCodeAt(0)),
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    key,
    new TextEncoder().encode(`${header}.${body}`),
  );
  const response = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: `${header}.${body}.${encode(new Uint8Array(signature))}`,
    }),
    signal: AbortSignal.timeout(15000),
  });
  if (!response.ok) throw new Error(`OAuth failed: ${response.status}`);
  return (await response.json()).access_token as string;
}
Deno.serve(async (request) => {
  const secret = Deno.env.get("PUSH_WORKER_SECRET");
  if (!secret || request.headers.get("x-worker-secret") !== secret) {
    return new Response("Unauthorized", { status: 401 });
  }
  if (request.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }
  const serviceAccount = Deno.env.get("FCM_SERVICE_ACCOUNT");
  if (!serviceAccount) {
    return new Response("FCM is not configured", { status: 503 });
  }
  const client = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    { auth: { persistSession: false } },
  );
  try {
    const account = JSON.parse(serviceAccount);
    const token = await accessToken(account);
    const { data: claimed, error } = await client.rpc("claim_push_deliveries", {
      batch_size: 10,
    });
    if (error) throw error;
    let sent = 0;
    await Promise.all((claimed as Delivery[]).map(async (delivery) => {
      let outcome = "retry", failure: string | null = null;
      try {
        const { data: allowed, error: authError } = await client.rpc(
          "authorize_push_delivery",
          { delivery: delivery.id, lease: delivery.lease_id },
        );
        if (authError) throw authError;
        if (!allowed) outcome = "cancelled";
        else {
          const notification = notificationMessage(
            delivery.device.locale,
            delivery.notification.kind,
            delivery.actor_name,
            delivery.notification.params,
          );
          const response = await fetch(
            `https://fcm.googleapis.com/v1/projects/${account.project_id}/messages:send`,
            {
              method: "POST",
              headers: {
                Authorization: `Bearer ${token}`,
                "Content-Type": "application/json",
              },
              body: JSON.stringify({
                message: {
                  token: delivery.device.token,
                  notification,
                  data: {
                    notification_id: String(delivery.notification.id),
                    recipient_id: delivery.notification.user_id,
                  },
                  android: {
                    ttl: "3600s",
                    notification: {
                      tag: `social-${delivery.notification.id}`,
                      channel_id: "social",
                    },
                  },
                  apns: {
                    headers: {
                      "apns-collapse-id": `social-${delivery.notification.id}`,
                      "apns-expiration": String(
                        Math.floor(Date.now() / 1000) + 3600,
                      ),
                    },
                    payload: { aps: { sound: "default" } },
                  },
                },
              }),
              signal: AbortSignal.timeout(15000),
            },
          );
          if (response.ok) {
            outcome = "sent";
            sent++;
          } else {
            const result = await response.json();
            const codes = (result.error?.details ?? []).map((
              e: { errorCode?: string },
            ) => e.errorCode);
            outcome = codes.includes("UNREGISTERED")
              ? "invalid_token"
              : "retry";
            // Store only the provider error code, never tokens or credentials.
            failure = `FCM ${response.status}: ${
              result.error?.status ?? "UNKNOWN"
            }`;
          }
        }
      } catch (_) {
        failure = "Delivery transport failed";
      }
      const { error: finishError } = await client.rpc("finish_push_delivery", {
        delivery: delivery.id,
        lease: delivery.lease_id,
        outcome,
        failure,
      });
      if (finishError) throw finishError;
    }));
    return Response.json({ claimed: claimed.length, sent });
  } catch (_) {
    return Response.json({
      error: "Push worker failed; pending deliveries will be retried",
    }, { status: 500 });
  }
});
