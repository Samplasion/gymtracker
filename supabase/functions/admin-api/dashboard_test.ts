import type { SupabaseClient } from "npm:@supabase/supabase-js@2";
import { loadDashboard } from "./dashboard.ts";
import { handleAdmin } from "./handler.ts";
function assert(value: unknown, message = "Assertion failed"): asserts value {
  if (!value) throw new Error(message);
}
const totals: Record<string, Record<string, number>> = {
  food_catalog: { published: 140, suspended: 7, removed: 2 },
  food_catalog_corrections: { pending: 61 },
  food_catalog_reports: { open: 75 },
  reports: { received: 51, reviewing: 4 },
};
function fixture(fail = false, admin = true) {
  const queries: {
    table: string;
    columns: string;
    head: boolean;
    filters: unknown[][];
    limit?: number;
  }[] = [];
  const client = {
    auth: {
      getClaims: () => ({
        data: { claims: { role: "authenticated" } },
        error: null,
      }),
      getUser: () => ({
        data: { user: { id: "admin", app_metadata: { is_admin: admin } } },
        error: null,
      }),
    },
    from(table: string) {
      const query = {
        table,
        columns: "",
        head: false,
        filters: [] as unknown[][],
        limit: undefined as number | undefined,
      };
      queries.push(query);
      const builder = {
        select(columns: string, options?: { head?: boolean; count?: string }) {
          query.columns = columns;
          query.head = options?.head ?? false;
          if (query.head) assert(options?.count === "exact");
          return builder;
        },
        eq(column: string, value: unknown) {
          query.filters.push(["eq", column, value]);
          return builder;
        },
        gte(column: string, value: unknown) {
          query.filters.push(["gte", column, value]);
          return builder;
        },
        is(column: string, value: unknown) {
          query.filters.push(["is", column, value]);
          return builder;
        },
        not(column: string, op: string, value: unknown) {
          query.filters.push(["not", column, op, value]);
          return builder;
        },
        order(_column: string, _options: unknown) {
          return builder;
        },
        limit(value: number) {
          query.limit = value;
          return builder;
        },
        then(
          resolve: (value: unknown) => unknown,
          reject: (reason: unknown) => unknown,
        ) {
          const status = query.filters.find((f) => f[1] === "status")?.[2] as
            | string
            | undefined;
          const count = status
            ? totals[table][status]
            : query.filters.some((f) => f[0] === "gte")
            ? 2
            : 8;
          return Promise.resolve({
            data: query.head ? null : [],
            count,
            error: fail
              ? { code: "XX000", message: "secret database details" }
              : null,
          }).then(resolve, reject);
        },
      };
      return builder;
    },
  };
  return { client: client as unknown as SupabaseClient, queries };
}
Deno.test("Dashboard returns global exact counts beyond a page and limits audit fields", async () => {
  const { client, queries } = fixture();
  const result = await loadDashboard(client);
  assert(result.corrections.pending === 61);
  assert(result.foodReports.open === 75);
  assert(result.social.received === 51);
  assert(result.catalog.suspended === 7);
  assert(result.push.exhausted === 2);
  assert(queries.length === 11);
  assert(queries.filter((q) => q.head).every((q) => q.columns === "id"));
  const audit = queries.find((q) => q.table === "food_catalog_audit")!;
  assert(audit.limit === 5);
  assert(audit.columns === "id,food_id,action,created_at");
  assert(!JSON.stringify(result).includes("secret"));
});
Deno.test("Dashboard requires live administrator privileges before reading data", async () => {
  const { client, queries } = fixture(false, false);
  const r = await handleAdmin(
    new Request("http://localhost/admin-api", {
      method: "POST",
      headers: {
        Authorization: "Bearer test",
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ operation: "dashboard" }),
    }),
    client,
  );
  assert(r.status === 403);
  assert(queries.length === 0);
});
Deno.test("Dashboard database failure does not return partial zeros or database errors", async () => {
  const { client } = fixture(true);
  const r = await handleAdmin(
    new Request("http://localhost/admin-api", {
      method: "POST",
      headers: {
        Authorization: "Bearer test",
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ operation: "dashboard" }),
    }),
    client,
  );
  assert(r.status === 500);
  const body = await r.json();
  assert(body.error === "server_error");
  assert(!("catalog" in body));
  assert(!JSON.stringify(body).includes("secret"));
});
