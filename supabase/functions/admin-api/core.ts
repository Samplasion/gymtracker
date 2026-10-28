export type Section =
  | "users"
  | "catalogRequests"
  | "catalog"
  | "corrections"
  | "foodReports"
  | "social"
  | "audit"
  | "notes"
  | "push"
  | "pushAudit";
export const sections: Record<
  Section,
  { table: string; columns: string; order: string; statuses?: string[] }
> = {
  users: {
    table: "profiles",
    columns: "id,username,full_name,updated_at",
    order: "updated_at",
  },
  catalogRequests: {
    table: "catalog_operator_requests",
    columns:
      "id,food_id,requester_id,kind,base_version,food,note,status,reviewer_id,review_note,created_at,reviewed_at,food_catalog(food)",
    order: "created_at",
    statuses: ["pending", "approved", "rejected"],
  },
  catalog: {
    table: "food_catalog",
    columns:
      "id,food,barcode,status,version,report_epoch,created_at,updated_at",
    order: "updated_at",
    statuses: ["published", "suspended", "removed"],
  },
  corrections: {
    table: "food_catalog_corrections",
    columns: "id,food_id,base_version,food,status,created_at,reviewed_at",
    order: "created_at",
    statuses: ["pending", "approved", "rejected"],
  },
  foodReports: {
    table: "food_catalog_reports",
    columns:
      "id,food_id,reporter_id,epoch,reason,details,status,created_at,updated_at",
    order: "created_at",
    statuses: ["open", "dismissed", "resolved"],
  },
  social: {
    table: "reports",
    columns:
      "id,reporter_id,reported_id,reason,status,created_at,updated_at,metadata",
    order: "created_at",
    statuses: ["received", "reviewing", "resolved", "dismissed"],
  },
  audit: {
    table: "food_catalog_audit",
    columns: "id,food_id,correction_id,report_id,action,note,actor,created_at",
    order: "created_at",
  },
  notes: {
    table: "report_notes",
    columns: "id,report_id,body,created_at",
    order: "created_at",
  },
  push: {
    table: "push_deliveries",
    columns:
      "id,notification_id,attempts,available_at,lease_until,finished_at,last_error,notifications(kind)",
    order: "available_at",
  },
  pushAudit: {
    table: "admin_console_audit",
    columns: "id,delivery_id,actor,note,created_at",
    order: "created_at",
  },
};
export function operatorNote(
  email: string | undefined,
  id: string,
  value: unknown,
): string {
  if (typeof value !== "string" || !value.trim()) {
    throw new Error("invalid_note");
  }
  const note = `Operatore: ${email ?? id} (${id}); ${value.trim()}`;
  if ([...note].length > 2000) throw new Error("invalid_note");
  return note;
}
export function isAdmin(
  user: { app_metadata?: Record<string, unknown> } | null,
  claims: Record<string, unknown>,
): boolean {
  return claims.role === "authenticated" && !claims.client_id &&
    user?.app_metadata?.is_admin === true;
}
export function errorStatus(code?: string): number {
  return code === "40001" || code === "23505" || code === "23505" ||
      code === "40P01"
    ? 409
    : code === "42501"
    ? 403
    : code === "P0002"
    ? 404
    : code === "22023" || code === "22P02"
    ? 400
    : 500;
}
