import { McpServer } from "@modelcontextprotocol/server";
import { z } from "zod";
import * as s from "./schemas.ts";
import {
  exerciseHistory,
  foodView,
  nutritionSummary,
  routineView,
  trainingStats,
  workoutView,
} from "./views.ts";
type Row = Record<string, any>;
type Rpc = (name: string, args?: Record<string, unknown>) => Promise<unknown>;
export function registerExtensions(
  server: McpServer,
  rpc: Rpc,
  config: { siteOrigin: string },
  shared: {
    read: Row;
    securitySchemes: Row[];
    wrap: (fn: () => Promise<Row>) => () => Promise<any>;
  },
) {
  const { read, securitySchemes, wrap } = shared;
  const call = (operation: string, request: Row, idempotencyKey?: string) =>
    rpc("mcp_execute", {
      operation,
      request,
      ...(idempotencyKey ? { idempotency_key: idempotencyKey } : {}),
    }) as Promise<Row>;
  const add = (
    name: string,
    description: string,
    shape: z.ZodRawShape,
    write = false,
    transform?: (result: Row, args: Row) => Row,
  ) => {
    server.registerTool(name, {
      title: name.replaceAll("_", " "),
      description,
      inputSchema: z.strictObject(shape),
      annotations: { ...read, readOnlyHint: !write },
      _meta: { securitySchemes },
    }, (args: Row) =>
      wrap(async () => {
        const { idempotencyKey, ...request } = args;
        const result = await call(name, request, idempotencyKey);
        return transform ? transform(result, args) : result;
      })());
  };
  const uuid = { idempotencyKey: z.uuid() };
  const nm = z.string().trim().min(1).max(200),
    notes = z.string().max(10000).default("");
  add(
    "create_custom_exercises",
    "After the user requests saving, create personal exercise definitions atomically. Free accounts may have at most 10 active custom exercises. Reuse idempotencyKey on retries.",
    {
      ...uuid,
      exercises: z.array(z.strictObject({
        name: nm,
        parameters: z.enum([
          "repsWeight",
          "timeWeight",
          "freeBodyReps",
          "time",
          "distance",
          "setless",
        ]),
        primaryMuscleGroup: z.string().min(1).max(100),
        secondaryMuscleGroups: z.array(z.string().max(100)).max(30).default([]),
        equipment: z.string().min(1).max(100).default("none"),
      })).min(1).max(100),
    },
    true,
  );
  add(
    "list_routine_folders",
    "List active folders, notes and routine counts.",
    s.cursorPage,
  );
  add(
    "create_routine_folders",
    "Create new folders atomically after the user requests saving. Requires Pro.",
    {
      ...uuid,
      folders: z.array(z.strictObject({ name: nm, notes })).min(1).max(31),
    },
    true,
  );
  add(
    "get_routines",
    "Read complete routines including nested supersets, progression and set targets. Missing references are listed as unavailable.",
    { ids: s.idsSchema, language: s.language },
    false,
    (r, a) => ({
      ...r,
      items: r.items.map((x: Row) => routineView(x, a.language)),
    }),
  );
  add(
    "create_routines",
    "After the user requests saving, create routines atomically with supersets and progression. Free: 4 active routines total, home only; Pro: existing folders allowed. Omitted weight is zero. Resolve exercise references first. Reuse idempotencyKey.",
    {
      ...uuid,
      routines: z.array(
        s.routineSchema.extend({ folderId: z.uuid().nullable().optional() }),
      ).min(1).max(31),
    },
    true,
  );
  const training = {
    ...s.dateRange,
    routineId: z.string().min(1).max(300).optional(),
    language: s.language,
    ...s.cursorPage,
  };
  add(
    "list_workouts",
    "List logical saved workouts in an inclusive UTC date interval. Continuation sessions are composed once. Follow nextCursor.",
    training,
    false,
    (r, a) => ({
      ...r,
      items: r.items.map((raw: Row) => {
        const w = workoutView(raw, a.language);
        return { ...w, entries: undefined, components: undefined };
      }),
    }),
  );
  add(
    "get_workouts",
    "Read complete logical workouts with actual sets and original session components. A continuation ID resolves to the original workout.",
    { ids: s.idsSchema, language: s.language },
    false,
    (r, a) => ({
      ...r,
      items: r.items.map((x: Row) => workoutView(x, a.language)),
    }),
  );
  add(
    "get_exercise_history",
    "Read performed exercise instances for the requested standard/custom references, including supersets. Dates are inclusive UTC; each logical workout appears once.",
    { ...training, references: z.array(s.exerciseRef).min(1).max(20) },
    false,
    (r, a) => ({
      ...r,
      items: r.items.map((x: Row) =>
        exerciseHistory(x, a.references, a.language)
      ),
    }),
  );
  add(
    "get_training_stats",
    "Compute basic training totals and muscle/equipment set distributions. No forecasts. Dates are inclusive UTC.",
    {
      ...s.dateRange,
      routineId: training.routineId,
      weightUnit: z.enum(["kg", "lb"]).default("kg"),
      distanceUnit: z.enum(["km", "mi"]).default("km"),
    },
    false,
    (r, a) => trainingStats(r.items, a.weightUnit, a.distanceUnit),
  );
  add(
    "get_account_limits",
    "Check the verified account plan, active usage, limits and allowed inclusive nutrition dates. This is informational; writes enforce limits again.",
    {},
  );
  server.registerTool("search_foods", {
    title: "Search foods",
    description:
      "Search only local Gym Bro favorites and personal barcode definitions. By default search both sources; no external food search is performed. Use returned references when logging. Missing nutrients require explicit completion, never assume zero.",
    inputSchema: z.strictObject({
      query: z.string().trim().min(1).max(200),
      source: z.enum(["all", "favorite", "customBarcode"]).default("all"),
      language: s.language,
      country: z.string().regex(/^[a-z]{2}$/).default("it"),
      ...s.cursorPage,
    }),
    annotations: read,
    _meta: { securitySchemes },
  }, (args) =>
    wrap(async () => {
      const result = await call("search_foods", args);
      return {
        ...result,
        items: result.items.map((i: Row) => ({ ...i, food: foodView(i.food) })),
      };
    })());
  server.registerTool("get_foods", {
    title: "Get food definitions",
    description:
      "Resolve up to 20 food references. For Open Food Facts the ID is the barcode. Returns missing nutrients explicitly.",
    inputSchema: z.strictObject({
      references: z.array(s.foodRef).min(1).max(20),
    }),
    annotations: read,
    _meta: { securitySchemes },
  }, (args) =>
    wrap(async () => {
      for (const reference of args.references) {
        if (reference.source === "openfoodfacts") {
          await rpc("@food_get", { barcode: reference.id });
        }
      }
      const result = await call("get_foods", args);
      return {
        ...result,
        items: result.items.map((i: Row) => ({ ...i, food: foodView(i.food) })),
      };
    })());
  add(
    "list_food_entries",
    "Read the food diary for inclusive calendar dates, optionally filtering a meal category. Free accounts can access today ±7 days only.",
    { ...s.dateRange, category: nm.optional(), ...s.cursorPage },
  );
  add(
    "get_food_entries",
    "Read saved food consumption snapshots by ID. The same Free date restriction applies to direct ID access.",
    { ids: s.idsSchema },
  );
  server.registerTool("log_foods", {
    title: "Log food consumption",
    description:
      "After the user requests saving, log 1–100 consumptions atomically. Supply a resolved foodRef OR explicit manual food values per 100g/100ml, amount and pieces. Do not invent missing nutrient values or convert mass to volume. Free: today ±7 days. Reuse idempotencyKey on retries.",
    inputSchema: z.strictObject({
      ...uuid,
      entries: z.array(s.foodLogSchema).min(1).max(100),
    }),
    annotations: { ...read, readOnlyHint: false },
    _meta: { securitySchemes },
  }, (args) =>
    wrap(async () => {
      try {
        return await call(
          "log_foods",
          { entries: args.entries },
          args.idempotencyKey,
        );
      } catch (error) {
        if (
          !(error instanceof s.ToolError) ||
          error.code !== "reference_unavailable"
        ) throw error;
        for (const entry of args.entries) {
          if (entry.foodRef?.source === "openfoodfacts") {
            await rpc("@food_get", { barcode: entry.foodRef.id });
          }
        }
        return await call(
          "log_foods",
          { entries: args.entries },
          args.idempotencyKey,
        );
      }
    })());
  add(
    "get_nutrition_summary",
    "Daily and meal totals, applicable goals and remaining nutrients for inclusive calendar dates. Missing optional nutrients remain unknown. Free: today ±7 days.",
    s.dateRange,
    false,
    (r) => nutritionSummary(r),
  );
  add(
    "get_nutrition_settings",
    "Read effective nutrition goals and meal categories, their effective dates and default status. Does not change settings. Free: today ±7 days.",
    s.dateRange,
  );
  void config;
}
