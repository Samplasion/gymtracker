/** Call only after middleware has verified the JWT or administrative secret.
 * OAuth tokens represent delegated access, never account-management authority.
 */
export function isFirstPartyCall(authMode: string, claims: unknown): boolean {
  if (authMode === "secret") return true;
  if (authMode !== "user" || typeof claims !== "object" || claims === null) {
    return false;
  }
  const jwt = claims as Record<string, unknown>;
  return jwt.role === "authenticated" && !jwt.client_id;
}
