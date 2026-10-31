import { readConfig } from "./auth.ts";

Deno.test("OAuth configuration supports both clients and fails closed for malformed lists", () => {
  const overrides = {
    SUPABASE_URL: "https://supabase.test",
    SUPABASE_PUBLISHABLE_KEY: "test-public-key",
    MCP_RESOURCE_URL: "https://gymbro.test/mcp",
    MCP_OAUTH_CLIENT_ID: "legacy-client",
    MCP_OAUTH_CLIENTS: "",
  };
  const original = Object.fromEntries(
    Object.keys(overrides).map((key) => [key, Deno.env.get(key)]),
  );
  try {
    for (const [key, value] of Object.entries(overrides)) {
      Deno.env.set(key, value);
    }
    if (
      readConfig().clientId !== "legacy-client" ||
      readConfig().clientIds !== undefined
    ) throw new Error("Legacy configuration lost");
    Deno.env.set(
      "MCP_OAUTH_CLIENTS",
      JSON.stringify([
        {
          clientId: "existing-client",
          redirectUri: "https://existing.test/callback",
        },
        {
          clientId: "claude-client",
          redirectUri: "https://claude.test/callback",
        },
      ]),
    );
    if (
      JSON.stringify(readConfig().clientIds) !==
        '["existing-client","claude-client"]'
    ) throw new Error("Multi-client configuration lost");
    for (
      const value of [
        "null",
        "[]",
        "{}",
        "invalid-json",
        "[null]",
        '[{"clientId":""}]',
      ]
    ) {
      Deno.env.set("MCP_OAUTH_CLIENTS", value);
      let rejected = false;
      try {
        readConfig();
      } catch {
        rejected = true;
      }
      if (!rejected) throw new Error(`Accepted invalid client list: ${value}`);
    }
  } finally {
    for (const [key, value] of Object.entries(original)) {
      if (value === undefined) Deno.env.delete(key);
      else Deno.env.set(key, value);
    }
  }
});
