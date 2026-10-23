import {
  createRemoteJWKSet,
  type JWTPayload,
  jwtVerify,
  type JWTVerifyGetKey,
} from "jose";

export type Config = {
  supabaseUrl: string;
  publicKey: string;
  clientId: string;
  resource: string;
  siteOrigin: string;
};
export function readConfig(): Config {
  const config = {
    supabaseUrl: Deno.env.get("SUPABASE_URL") ?? "",
    publicKey: Deno.env.get("SUPABASE_PUBLISHABLE_KEY") ??
      Deno.env.get("SUPABASE_ANON_KEY") ?? "",
    clientId: Deno.env.get("MCP_OAUTH_CLIENT_ID") ?? "",
    resource: Deno.env.get("MCP_RESOURCE_URL") ?? "",
    siteOrigin: Deno.env.get("MCP_SITE_ORIGIN") ??
      "https://gym-bro.techtonicfault.com",
  };
  if (!config.supabaseUrl || !config.publicKey || !config.resource) {
    throw new Error("MCP configuration missing");
  }
  const resource = new URL(config.resource);
  const loopback = ["localhost", "127.0.0.1", "[::1]"].includes(
    resource.hostname,
  );
  if (
    (resource.protocol !== "https:" &&
      !(resource.protocol === "http:" && loopback)) ||
    resource.search || resource.hash || resource.username ||
    resource.password || config.resource.endsWith("/")
  ) throw new Error("Invalid canonical MCP resource URL");
  return config;
}
export function metadataUrl(config: Config) {
  // The WWW-Authenticate pointer permits metadata below the Edge Function path.
  return `${
    config.resource.replace(/\/$/, "")
  }/.well-known/oauth-protected-resource`;
}
export function challenge(config: Config) {
  return `Bearer resource_metadata="${metadataUrl(config)}"`;
}
export function protectedResource(config: Config) {
  return {
    resource: config.resource,
    authorization_servers: [`${config.supabaseUrl}/auth/v1`],
    scopes_supported: ["openid"],
    bearer_methods_supported: ["header"],
    resource_name: "Gym Bro",
  };
}
export async function verifyToken(
  token: string,
  config: Config,
  keys: JWTVerifyGetKey,
) {
  const { payload } = await jwtVerify(token, keys, {
    issuer: `${config.supabaseUrl}/auth/v1`,
    audience: config.resource,
    algorithms: ["ES256", "RS256"],
    requiredClaims: ["sub", "exp", "iat", "client_id", "role"],
  });
  validateIdentity(payload, config);
  return payload;
}
function validateIdentity(payload: JWTPayload, config: Config) {
  if (
    !config.clientId || payload.role !== "gymbro_mcp_user" ||
    payload.client_id !== config.clientId ||
    !/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(
      payload.sub ?? "",
    )
  ) throw new Error("Invalid MCP identity");
}
export function tokenVerifier(config: Config) {
  const keys = createRemoteJWKSet(
    new URL(`${config.supabaseUrl}/auth/v1/.well-known/jwks.json`),
  );
  return (token: string) => verifyToken(token, config, keys);
}
