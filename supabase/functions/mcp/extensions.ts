import { McpServer } from "@modelcontextprotocol/server";
import { z } from "zod";
import * as s from "./schemas.ts";
import {
  compactTraining,
  exerciseHistory,
  foodResult,
  hydrationSummary,
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
        const { idempotencyKey, includeDetails: _includeDetails, ...request } =
          args;
        const result = await call(name, request, idempotencyKey);
        return transform ? transform(result, args) : result;
      })());
  };
  const uuid = { idempotencyKey: z.uuid() };
  add(
    "list_water_entries",
    "List drinking-water records for inclusive dates in the account time zone, newest first. Free: today ±7 days. Food water is included only in hydration summaries.",
    { ...s.dateRange, ...s.cursorPage },
  );
  add(
    "get_water_entries",
    "Read 1–20 drinking-water records by ID. Deleted, missing and other-account IDs are unavailable. Free date restrictions also apply to ID reads.",
    { ids: s.idsSchema },
  );
  add(
    "log_water",
    "After the user requests saving, record 1–100 drinking-water entries atomically. milliliters is the TOTAL volume: two 250ml glasses are 500ml; convert liters exactly and ask when glass/bottle volume is unknown. Do not also record water for the same beverage already logged as food: its water nutrient is counted separately. No future entries, updates or deletions. Free: today ±7 days. Reuse idempotencyKey on retries; never deduplicate historical records by similarity.",
    { ...uuid, entries: z.array(s.waterLogSchema).min(1).max(100) },
    true,
  );
  add(
    "get_hydration_summary",
    "Daily drinking water, known water from food snapshots and combined known totals, completeness and effective optional goal. Unknown food water is never estimated. Includes empty days. Free: today ±7 days.",
    s.dateRange,
    false,
    (r) => hydrationSummary(r),
  );

  add(
    "list_measurements",
    "Read actual weight and body measurements, newest first. Optional inclusive local calendar dates. Available on Free and Pro; no predictions.",
    {
      kind: z.enum(["weight", "body"]).optional(),
      types: z.array(s.bodyMeasurementType).min(1).max(15).optional(),
      from: s.measurementDate.optional(),
      to: s.measurementDate.optional(),
      ...s.cursorPage,
    },
  );
  add(
    "get_measurements",
    "Read actual measurements by kind and ID. Unknown, deleted and other-account references are unavailable.",
    {
      references: z.array(s.measurementRef).min(1).max(20),
    },
  );
  add(
    "create_measurements",
    "After the user requests saving, create 1–100 actual weight/body measurements atomically. Reuse idempotencyKey on retries. Preserve units; body measurements use cm or percent. No updates or deletions; multiple records per day are allowed. Available on Free and Pro.",
    {
      ...uuid,
      entries: z.array(s.measurementSchema).min(1).max(100),
    },
    true,
  );

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
          "repsNegWeight",
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
    "Read complete routines in one hierarchical entries array, including nested supersets, progression and set targets. Notes are readable text; includeDetails adds original rich notes. Omitted set parameters inherit from the exercise; omitted nonapplicable zero time/distance fields mean zero and omitted nulls are unset. done remains explicit. Missing references are listed as unavailable.",
    {
      ids: s.idsSchema,
      language: s.language,
      includeDetails: z.boolean().default(false).describe(
        "Include original rich notes and, for workouts, full source session components.",
      ),
    },
    false,
    (r, a) => ({
      ...r,
      items: r.items.map((x: Row) =>
        compactTraining(routineView(x, a.language), a.includeDetails)
      ),
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
        return compactTraining({
          ...w,
          entries: undefined,
          components: undefined,
        });
      }),
    }),
  );
  add(
    "get_workouts",
    "Read complete logical workouts with actual sets in one hierarchical entries array. A continuation ID resolves to the original workout. componentIds identifies source sessions; includeDetails adds their complete data and original rich notes. Default notes are text. Omitted set parameters inherit from the exercise; omitted nonapplicable zero time/distance fields mean zero and omitted nulls are unset. done remains explicit.",
    {
      ids: s.idsSchema,
      language: s.language,
      includeDetails: z.boolean().default(false).describe(
        "Include original rich notes and, for workouts, full source session components.",
      ),
    },
    false,
    (r, a) => ({
      ...r,
      items: r.items.map((x: Row) =>
        compactTraining(workoutView(x, a.language), a.includeDetails)
      ),
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
        compactTraining(exerciseHistory(x, a.references, a.language))
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
      "Search the shared Gym Bro food catalog, local favorites and personal barcode definitions. By default search all three sources; no external service is contacted. Use returned references when logging. missingNutrients lists only missing REQUIRED nutrients: calories, fat, saturatedFat, carbs, sugar and protein. An empty list means these six are present, not that all nutrients are known. Optional nutrients may be null (unknown, never zero) and do not prevent logging. Complete missing required nutrients explicitly before logging. Nutritional values omit unknown/null nutrients, never known zeros; omitted values are unknown, NOT zero. nutrientUnits is shared once at response level for returned nutrients.",
    inputSchema: z.strictObject({
      query: z.string().trim().min(1).max(200),
      source: z.enum(["all", "catalog", "favorite", "customBarcode"]).default(
        "all",
      ),
      language: s.language,
      country: z.string().regex(/^[a-z]{2}$/).default("it"),
      ...s.cursorPage,
    }),
    annotations: read,
    _meta: { securitySchemes },
  }, (args) =>
    wrap(async () => {
      const result = await call("search_foods", args);
      return foodResult(result);
    })());
  server.registerTool("get_foods", {
    title: "Get food definitions",
    description:
      "Resolve up to 20 food references. Catalog references use the product ID. Legacy Open Food Facts barcode references resolve only from the published Gym Bro catalog. missingNutrients lists only missing REQUIRED nutrients: calories, fat, saturatedFat, carbs, sugar and protein. An empty list means these six are present, not that all nutrients are known. Optional nutrients may be null (unknown, never zero) and do not prevent logging. Complete missing required nutrients explicitly before logging. Nutritional values omit unknown/null nutrients, never known zeros; omitted values are unknown, NOT zero. nutrientUnits is shared once at response level for returned nutrients.",
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
      return foodResult(result);
    })());
  add(
    "list_food_entries",
    "Read the food diary for inclusive calendar dates, optionally filtering a meal category. Each item.id identifies a diary consumption; food.id is the same consumption snapshot ID, not the catalog product ID. Use item.id with get_food_entries. Free accounts can access today ±7 days only. Nutritional values omit unknown/null nutrients, never known zeros; omitted values are unknown, NOT zero. nutrientUnits is shared once at response level for returned nutrients.",
    { ...s.dateRange, category: nm.optional(), ...s.cursorPage },
    false,
    (r) => foodResult(r),
  );
  add(
    "get_food_entries",
    "Read saved food consumption snapshots using diary item.id values returned by list_food_entries or log_foods, not catalog product IDs. Each returned food.id repeats its consumption item.id. The same Free date restriction applies to direct ID access. Nutritional values omit unknown/null nutrients, never known zeros; omitted values are unknown, NOT zero. nutrientUnits is shared once at response level for returned nutrients.",
    { ids: s.idsSchema },
    false,
    (r) => foodResult(r),
  );
  server.registerTool("log_foods", {
    title: "Log food consumption",
    description:
      "After the user requests saving, log 1–100 consumptions atomically. Supply a resolved foodRef OR explicit manual food values per 100g/100ml, amount and pieces. For X units of Y (slices, spoons, glasses, packs), amount is grams/ml for ONE unit and pieces is X; e.g. three slices weighing 30g TOTAL: amount=10, pieces=3; three slices weighing 30g EACH: amount=30, pieces=3. If only a total for equal units is given divide by X. Use a matching servingSize or user-supplied unit size; ask when unknown. Nutrients stay per 100g/100ml; never multiply twice. Only calories, fat, saturatedFat, carbs, sugar and protein are required; missingNutrients reports missing values among these six. Optional nutrients may remain null (unknown), do not prevent logging and do not require completion. Do not invent missing nutrient values, replace unknown values with zero or convert mass to volume. Returned item.id and food.id both identify the newly created consumption snapshot, not the source catalog product. Separate consumptions receive distinct IDs. Free: today ±7 days. Reuse idempotencyKey on retries. Nutritional values omit unknown/null nutrients, never known zeros; omitted values are unknown, NOT zero. nutrientUnits is shared once at response level for returned nutrients.",
    inputSchema: z.strictObject({
      ...uuid,
      entries: z.array(s.foodLogSchema).min(1).max(100),
    }),
    annotations: { ...read, readOnlyHint: false },
    _meta: { securitySchemes },
  }, (args) =>
    wrap(async () => {
      try {
        return foodResult(
          await call(
            "log_foods",
            { entries: args.entries },
            args.idempotencyKey,
          ),
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
        return foodResult(
          await call(
            "log_foods",
            { entries: args.entries },
            args.idempotencyKey,
          ),
        );
      }
    })());
  add(
    "get_nutrition_summary",
    "Daily and meal totals, applicable goals and remaining nutrients for inclusive calendar dates. At both day and meal level, totals contain only complete numeric nutrient totals, including known zeros. Any nutrient from the response-level nutrientUnits map omitted from a total is unknown or incomplete; repeated incompleteNutrients lists are not returned. Omitted nutrients are NOT zero; do not treat partial data as complete. Empty days remain present with zero totals. remaining may be null when its nutrient total is incomplete. nutrientUnits applies to the entire response; hydration is separate from food nutrient totals. Free: today ±7 days.",
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
