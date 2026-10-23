import { isFirstPartyCall } from "../_shared/first_party.ts";
// Setup type definitions for built-in Supabase Runtime APIs
import "edge-runtime";
import { type UserClaims, withSupabase } from "@supabase/server";

interface ReqPayload {
  target_user_id: string;
}

console.info("delete-user-complete server started");

export default {
  fetch: withSupabase({ auth: ["user", "secret"] }, async (req, ctx) => {
    if (!isFirstPartyCall(ctx.authMode, ctx.jwtClaims)) {
      return Response.json({ error: "Delegated OAuth access is not allowed" }, {
        status: 403,
      });
    }

    if (req.method !== "POST") {
      return Response.json({ error: "Method not allowed" }, { status: 405 });
    }

    let target_user_id = null;
    try {
      const payload: ReqPayload = await req.json();
      target_user_id = payload.target_user_id;
    } catch {
      return Response.json({ error: "Invalid request" }, { status: 400 });
    }
    if (!target_user_id) {
      return Response.json({ error: "target_user_id is required" }, {
        status: 400,
      });
    }

    let isAuthorized = false;

    // 1. Check privileges based on how the function was invoked
    if (ctx.authMode === "secret") {
      // Service role / secret callers have full admin privilege
      isAuthorized = true;
    } else if (ctx.authMode === "user") {
      // Regular user token provided; check identity and custom admin claim
      const requestingUserId = (ctx.userClaims as UserClaims | null)?.id;
      const isAdmin = ctx.jwtClaims?.app_metadata?.is_admin === true;

      if (isAdmin || requestingUserId === target_user_id) {
        isAuthorized = true;
      }
    }

    if (!isAuthorized) {
      return Response.json(
        {
          error:
            "Access denied: You can only delete your own account or must be an admin.",
        },
        { status: 403 },
      );
    }

    // 2. Use ctx.supabaseAdmin (bypasses RLS) for privileged clean-up actions
    const adminClient = ctx.supabaseAdmin;

    // Delete the profile picture from the storage bucket via the Storage API
    const { error: storageError } = await adminClient.storage
      .from("profile_pictures")
      .remove([target_user_id]);

    if (storageError) {
      console.warn(`Storage deletion warning: ${storageError.message}`);
    }

    // 3. Finally, delete the user from Supabase Auth
    const { error: authDeleteError } = await adminClient.auth.admin.deleteUser(
      target_user_id,
    );
    if (authDeleteError) {
      return Response.json({
        error: `Auth deletion failed: ${authDeleteError.message}`,
      }, { status: 500 });
    }

    return Response.json({
      success: true,
      message: "User completely deleted.",
    });
  }),
};
