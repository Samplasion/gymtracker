import { isFirstPartyCall } from "../_shared/first_party.ts";
// Setup type definitions for built-in Supabase Runtime APIs
import "edge-runtime";
import { type UserClaims, withSupabase } from "@supabase/server";
import JSZip from "jszip";

console.info("server started");

export default {
  fetch: withSupabase({ auth: ["user", "secret"] }, async (req, ctx) => {
    if (!isFirstPartyCall(ctx.authMode, ctx.jwtClaims)) {
      return Response.json({ error: "Delegated OAuth access is not allowed" }, {
        status: 403,
      });
    }

    try {
      const { supabase, supabaseAdmin, authMode } = ctx;

      // Resolve User ID based on authMode
      let userId: string | undefined;

      if (authMode === "user") {
        userId = (ctx.userClaims as UserClaims | null)?.id;
      } else if (authMode === "secret") {
        // If invoked via service/admin secret key, pass userId in query params
        const url = new URL(req.url);
        userId = url.searchParams.get("userId") ?? undefined;
      }

      if (!userId) {
        return new Response(
          JSON.stringify({ error: "User ID missing or unauthorized" }),
          {
            status: 400,
            headers: { "Content-Type": "application/json" },
          },
        );
      }

      // Use user-scoped client for user calls (RLS applied) or admin client for secret calls
      const client = authMode === "user" ? supabase : supabaseAdmin;

      // 3. Fetch User Data via Postgres RPC
      const { data: userData, error: rpcError } = await client.rpc(
        "export_schema_to_json",
      );

      if (rpcError) {
        throw new Error(`RPC Error: ${rpcError.message}`);
      }

      // Initialize JSZip archive
      const zip = new JSZip();
      zip.file("user_data.json", JSON.stringify(userData, null, 2));

      // 4. Download files from Supabase Storage Bucket
      const bucketName = "profile_pictures";
      const filePath = userId; // Exact path/filename in bucket

      const { data: blob, error: downloadError } = await client.storage
        .from(bucketName)
        .download(filePath);

      if (!downloadError && blob) {
        const arrayBuffer = await blob.arrayBuffer();

        // Optional: determine extension from content type if available
        let fileName = "profile_picture";
        if (blob.type.includes("jpeg") || blob.type.includes("jpg")) {
          fileName += ".jpg";
        } else if (blob.type.includes("png")) fileName += ".png";
        else if (blob.type.includes("webp")) fileName += ".webp";

        zip.file(fileName, arrayBuffer);
      } else if (downloadError) {
        console.warn(
          `Profile picture not found for ${userId}: ${downloadError.message}`,
        );
      }

      // 5. Generate binary ZIP file
      const zipBuffer = await zip.generateAsync({ type: "uint8array" });

      // 6. Return downloadable file response
      return new Response(new Uint8Array(zipBuffer).buffer, {
        status: 200,
        headers: {
          "Content-Type": "application/zip",
          "Content-Disposition":
            `attachment; filename="data-export-${userId}.zip"`,
        },
      });
    } catch (error) {
      return new Response(JSON.stringify({ error: (error as Error).message }), {
        status: 500,
        headers: { "Content-Type": "application/json" },
      });
    }
  }),
};
