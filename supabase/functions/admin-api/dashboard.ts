import type { SupabaseClient } from "npm:@supabase/supabase-js@2";

/** Exact database counts: never inferred from a page of records. */
export async function loadDashboard(client: SupabaseClient) {
  const count = async (
    table: string,
    filters: {
      column: string;
      value: string | number;
      operator?: "gte" | "notNull" | "null";
    }[],
  ) => {
    let query = client.from(table).select("id", { count: "exact", head: true });
    for (const filter of filters) {
      if (filter.operator === "gte") {
        query = query.gte(filter.column, filter.value);
      } else if (filter.operator === "null") {
        query = query.is(filter.column, null);
      } else if (filter.operator === "notNull") {
        query = query.not(filter.column, "is", null);
      } else query = query.eq(filter.column, filter.value);
    }
    const result = await query;
    if (result.error) throw result.error;
    if (result.count === null) throw new Error("Missing exact count");
    return result.count;
  };
  const status = (table: string, value: string) =>
    count(table, [{ column: "status", value }]);
  const [
    published,
    suspended,
    removed,
    corrections,
    foodReports,
    received,
    reviewing,
    pending,
    errors,
    exhausted,
    recent,
  ] = await Promise.all([
    status("food_catalog", "published"),
    status("food_catalog", "suspended"),
    status("food_catalog", "removed"),
    status("food_catalog_corrections", "pending"),
    status("food_catalog_reports", "open"),
    status("reports", "received"),
    status("reports", "reviewing"),
    count("push_deliveries", [{
      column: "finished_at",
      value: "",
      operator: "null",
    }]),
    count("push_deliveries", [{
      column: "last_error",
      value: "",
      operator: "notNull",
    }]),
    count("push_deliveries", [
      { column: "attempts", value: 8, operator: "gte" },
      { column: "last_error", value: "", operator: "notNull" },
    ]),
    client.from("food_catalog_audit").select("id,food_id,action,created_at")
      .order(
        "created_at",
        { ascending: false },
      ).order("id", { ascending: false }).limit(5),
  ]);
  if (recent.error) throw recent.error;
  return {
    generatedAt: new Date().toISOString(),
    catalog: { published, suspended, removed },
    corrections: { pending: corrections },
    foodReports: { open: foodReports },
    social: { received, reviewing },
    push: { pending, errors, exhausted },
    recentActivity: recent.data,
  };
}
