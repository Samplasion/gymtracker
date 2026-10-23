import { createMcpHandler, McpServer } from "@modelcontextprotocol/server";
import { z } from "zod";
import { challenge, type Config, protectedResource } from "./auth.ts";
import {
  catalogVersion,
  displayExercise,
  type ExerciseDefinition,
  exerciseRef,
  language,
  pagination,
  programSchema,
  search,
  searchSchema,
  standardExercises,
  ToolError,
} from "./schemas.ts";

type Rpc = (name: string, args?: Record<string, unknown>) => Promise<unknown>;
export function database(config: Config, token: string): Rpc {
  return async (name, args = {}) => {
    const response = await fetch(`${config.supabaseUrl}/rest/v1/rpc/${name}`, {
      method: "POST",
      headers: {
        apikey: config.publicKey,
        Authorization: `Bearer ${token}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(args),
      signal: AbortSignal.timeout(15000),
    });
    if (!response.ok) {
      const body = await response.json().catch(() => ({}));
      const code = body.code === "42501" || response.status === 401
        ? "authentication_required"
        : body.code === "P0002"
        ? "reference_unavailable"
        : body.code === "23505"
        ? "idempotency_conflict"
        : ["22023", "22P02", "23502", "23514"].includes(body.code)
        ? "invalid_input"
        : "server_error";
      throw new ToolError(
        code,
        code === "server_error"
          ? "Gym Bro temporarily unavailable"
          : code.replaceAll("_", " "),
      );
    }
    return await response.json();
  };
}
const content = (value: Record<string, unknown>) => ({
  structuredContent: value,
  content: [{ type: "text" as const, text: JSON.stringify(value) }],
});
export function mcpServer(config: Config, rpc: Rpc) {
  const server = new McpServer({ name: "gym-bro", version: "0.1.0" });
  const securitySchemes = [{ type: "oauth2", scopes: ["openid"] }];
  const read = {
    readOnlyHint: true,
    destructiveHint: false,
    openWorldHint: false,
    idempotentHint: true,
  };
  const wrap =
    (handler: () => Promise<Record<string, unknown>>) => async () => {
      try {
        return content(await handler());
      } catch (error) {
        const known = error instanceof ToolError;
        const code = known ? error.code : "server_error";
        return {
          ...content({
            error: {
              code,
              message: known
                ? error.message
                : "Gym Bro temporarily unavailable",
            },
          }),
          isError: true,
          ...(code === "authentication_required"
            ? { _meta: { "mcp/www_authenticate": [challenge(config)] } }
            : {}),
        };
      }
    };
  const definitions = async (): Promise<
    ExerciseDefinition[]
  > => [
    ...standardExercises,
    ...await rpc("mcp_custom_exercises") as ExerciseDefinition[],
  ];
  server.registerTool("search_exercises", {
    title: "Search Gym Bro exercises",
    description:
      "Find real exercises in the standard and connected user catalogs. Use returned source/id references when composing a program. Muscle filters match every requested muscle, primary or secondary. Searches Italian and English names.",
    inputSchema: searchSchema,
    annotations: read,
    _meta: { securitySchemes },
  }, (args) => wrap(async () => search(await definitions(), args))());
  server.registerTool("get_exercises", {
    title: "Get exercise definitions",
    description:
      "Resolve standard/custom exercise references and their permitted set parameters. Unavailable references are returned separately.",
    inputSchema: z.strictObject({
      references: z.array(exerciseRef).min(1).max(100),
      language,
    }),
    annotations: read,
    _meta: { securitySchemes },
  }, (args) =>
    wrap(async () => {
      const all = await definitions();
      const items = [], unavailable = [];
      for (const ref of args.references) {
        const exercise = all.find((e) =>
          e.source === ref.source && e.id === ref.id
        );
        if (exercise) items.push(displayExercise(exercise, args.language));
        else unavailable.push(ref);
      }
      return { catalogVersion, items, unavailable };
    })());
  server.registerTool("list_routines", {
    title: "List saved routines",
    description:
      "List the connected user’s active routines and their folders. Follow nextOffset for subsequent pages.",
    inputSchema: z.strictObject(pagination),
    annotations: read,
    _meta: { securitySchemes },
  }, (args) =>
    wrap(async () => {
      const rows = await rpc("mcp_list_routines", {
        page_offset: args.offset,
        page_limit: args.limit,
      }) as unknown[];
      return {
        items: rows.slice(0, args.limit),
        nextOffset: rows.length > args.limit ? args.offset + args.limit : null,
      };
    })());
  server.registerTool("get_routine", {
    title: "Read a saved routine",
    description:
      "Read a complete routine, including ordered exercises, sets, notes and existing supersets. Time values are seconds; weight and distance use the routine’s units.",
    inputSchema: z.strictObject({ id: z.string().min(1).max(300), language }),
    annotations: read,
    _meta: { securitySchemes },
  }, (args) =>
    wrap(async () => {
      const routine = await rpc("mcp_get_routine", {
        routine_id: args.id,
      }) as Record<string, unknown>;
      const raw = routine.exercises as Record<string, unknown>[];
      return {
        id: routine.id,
        name: routine.name,
        notes: routine.infobox,
        weightUnit: routine.weight_unit,
        distanceUnit: routine.distance_unit,
        folderId: routine.folder_id,
        exercises: raw.map((e) => {
          const standard = standardExercises.find((d) =>
            d.id === e.library_exercise_id
          );
          return {
            id: e.id,
            name: standard
              ? displayExercise(standard, args.language).name
              : e.name,
            exerciseRef: e.is_superset ? null : {
              source: e.is_custom ? "custom" : "standard",
              id: e.is_custom ? e.custom_exercise_id : e.library_exercise_id,
            },
            parameters: e.parameters,
            primaryMuscleGroup: e.primary_muscle_group,
            secondaryMuscleGroups: e.secondary_muscle_groups ?? [],
            equipment: e.equipment,
            restSeconds: e.rest_time ?? 0,
            notes: e.notes ?? "",
            isSuperset: e.is_superset,
            supersetId: e.superset_id,
            supersedesId: e.supersedes_id,
            rpe: e.rpe,
            progression: e.progression,
            sets: ((e.sets ?? []) as Record<string, unknown>[]).map((s) => ({
              id: s.id,
              kind: s.kind,
              parameters: s.parameters,
              reps: s.reps,
              weight: s.weight,
              timeSeconds: Number(s.time ?? 0) / 1000000,
              distance: s.distance,
              rpe: s.rpe,
              done: s.done,
            })),
          };
        }),
      };
    })());
  server.registerTool("create_program", {
    title: "Save a complete training program",
    description:
      "After the user requests saving the proposed program, create one new folder and all its daily routines atomically. Resolve exercises first. Reuse the same UUID idempotencyKey and identical program on retries. Omitted weight means zero, not a prescribed load. Creation supports simple exercises, not supersets or progressions; setless exercises have an empty sets array.",
    inputSchema: z.strictObject({
      idempotencyKey: z.uuid(),
      program: programSchema,
    }),
    annotations: { ...read, readOnlyHint: false },
    _meta: { securitySchemes },
  }, (args) =>
    wrap(async () => {
      return await rpc("mcp_create_program", {
        program: args.program,
        idempotency_key: args.idempotencyKey,
      }) as Record<string, unknown>;
    })());
  return server;
}
export function createHandler(
  config: Config,
  verify: (token: string) => Promise<unknown>,
  rpcFactory: (token: string) => Rpc = (token) => database(config, token),
) {
  return async (request: Request): Promise<Response> => {
    const url = new URL(request.url);
    const origin = request.headers.get("origin");
    const allowedOrigins = [config.siteOrigin, "https://chatgpt.com"];
    const headers = {
      "Cache-Control": "no-store",
      "Access-Control-Allow-Origin": origin && allowedOrigins.includes(origin)
        ? origin
        : config.siteOrigin,
      "Access-Control-Allow-Headers":
        "authorization, content-type, mcp-protocol-version, mcp-session-id",
      "Access-Control-Expose-Headers": "WWW-Authenticate",
      "Access-Control-Allow-Methods": "POST, GET, DELETE, OPTIONS",
      Vary: "Origin",
    };
    if (origin && !allowedOrigins.includes(origin)) {
      return new Response("Forbidden origin", { status: 403, headers });
    }
    if (request.method === "OPTIONS") {
      return new Response(null, { status: 204, headers });
    }
    // Supabase's gateway strips /functions/v1 before dispatching to the worker.
    // Also support the original external URL for direct hosting and tests.
    const resourcePath = new URL(config.resource).pathname.replace(/\/$/, "");
    const paths = [
      resourcePath,
      resourcePath.replace(/^\/functions\/v1(?=\/)/, ""),
    ];
    if (
      paths.some((path) =>
        url.pathname === `${path}/.well-known/oauth-protected-resource`
      ) && request.method === "GET"
    ) return Response.json(protectedResource(config), { headers });
    if (!paths.includes(url.pathname.replace(/\/$/, ""))) {
      return new Response("Not found", { status: 404, headers });
    }
    const token = request.headers.get("authorization")?.match(
      /^Bearer ([^\s]+)$/i,
    )?.[1];
    try {
      if (!token) throw new Error("Missing token");
      await verify(token);
    } catch {
      return Response.json({ error: "authentication_required" }, {
        status: 401,
        headers: { ...headers, "WWW-Authenticate": challenge(config) },
      });
    }
    // Enforce the body limit before JSON parsing, including chunked requests.
    if (request.method === "POST") {
      const reader = request.body?.getReader();
      let size = 0;
      const chunks: Uint8Array[] = [];
      if (reader) {
        for (;;) {
          const { done, value } = await reader.read();
          if (done) break;
          size += value.length;
          if (size > 1048576) {
            await reader.cancel();
            return new Response("Request too large", { status: 413, headers });
          }
          chunks.push(value);
        }
      }
      const body = new Uint8Array(size);
      let offset = 0;
      for (const chunk of chunks) {
        body.set(chunk, offset);
        offset += chunk.length;
      }
      request = new Request(request.url, {
        method: request.method,
        headers: request.headers,
        body,
      });
    }
    const handler = createMcpHandler(() =>
      mcpServer(config, rpcFactory(token!))
    );
    try {
      const response = await handler.fetch(request);
      const merged = new Headers(response.headers);
      for (const [key, value] of Object.entries(headers)) {
        merged.set(key, value);
      }
      return new Response(response.body, {
        status: response.status,
        headers: merged,
      });
    } catch {
      return Response.json({ error: "server_error" }, { status: 500, headers });
    }
  };
}
