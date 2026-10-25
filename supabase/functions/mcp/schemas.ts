import { z } from "zod";
import catalog from "./catalog.json" with { type: "json" };

export const language = z.enum(["it", "en"]).default("it");
export const exerciseRef = z.strictObject({
  source: z.enum(["standard", "custom"]),
  id: z.string().min(1).max(300),
});
const text = z.string().max(10000).default("");
const name = z.string().trim().min(1).max(200);
const nonnegative = z.number().finite().nonnegative();
export const setSchema = z.strictObject({
  kind: z.enum(["warmUp", "normal", "drop", "failure", "failureStripping"])
    .default("normal"),
  reps: nonnegative.int().max(100000).optional(),
  weight: nonnegative.max(100000).optional(),
  timeSeconds: nonnegative.max(604800).optional(),
  distance: nonnegative.max(100000).optional(),
  rpe: z.number().min(1).max(10).optional(),
});
export const progressionSchema = z.strictObject({
  mode: z.enum(["doubleProgression", "cyclicLinear"]),
  minReps: z.number().int().positive().max(100000),
  maxReps: z.number().int().positive().max(100000),
  repsPerStep: z.number().int().positive().max(100000),
  startingWeight: nonnegative.max(100000),
  weightPerStep: z.number().positive().max(100000),
  weightPerCycle: nonnegative.max(100000),
  cycle: nonnegative.int().max(100000).default(0),
  step: nonnegative.int().max(100000).default(0),
  targetReps: z.array(z.number().int().positive().max(100000)).max(100)
    .optional(),
});
export const simpleExerciseSchema = z.strictObject({
  type: z.literal("exercise").optional(),
  exerciseRef,
  notes: text,
  restSeconds: nonnegative.int().max(86400).default(0),
  rpe: z.number().int().min(1).max(10).optional(),
  progression: progressionSchema.optional(),
  sets: z.array(setSchema).max(100),
}).superRefine((entry, ctx) => {
  const p = entry.progression;
  if (!p) return;
  const issue = (path: string, message: string) =>
    ctx.addIssue({ code: "custom", path: ["progression", path], message });
  const normal = entry.sets.filter((s) => s.kind === "normal").length;
  if (normal === 0) {
    issue("setCount", "Progression requires normal working sets");
  }
  if (p.maxReps < p.minReps) issue("maxReps", "Must be at least minReps");
  if (
    p.mode === "cyclicLinear" && (p.maxReps - p.minReps) % p.repsPerStep !== 0
  ) issue("repsPerStep", "Must divide the rep range");
  if (p.step >= Math.floor((p.maxReps - p.minReps) / p.repsPerStep) + 1) {
    issue("step", "Step outside cycle");
  }
  if (
    p.targetReps &&
    (p.targetReps.length !== normal ||
      p.targetReps.some((n) => n < p.minReps || n > p.maxReps))
  ) {
    issue(
      "targetReps",
      "One in-range target per normal working set is required",
    );
  }
});
export const entrySchema = z.union([
  simpleExerciseSchema,
  z.strictObject({
    type: z.literal("superset"),
    notes: text,
    restSeconds: nonnegative.int().max(86400).default(0),
    exercises: z.array(simpleExerciseSchema).min(2).max(100),
  }),
]);
export const routineSchema = z.strictObject({
  name,
  notes: text,
  weightUnit: z.enum(["kg", "lb"]).default("kg"),
  distanceUnit: z.enum(["km", "mi"]).default("km"),
  exercises: z.array(entrySchema).min(1).max(100),
});
export const programSchema = z.strictObject({
  name,
  notes: text,
  routines: z.array(routineSchema).min(1).max(31),
});
export const dateSchema = z.iso.date().refine(
  (d) => d >= "2000-01-01" && d <= "2099-12-31",
  "Date outside supported range",
);
export const idsSchema = z.array(z.string().min(1).max(300)).min(1).max(20);
export const cursorPage = {
  cursor: z.string().max(2000).optional(),
  limit: z.number().int().min(1).max(100).default(20),
};
export const dateRange = { from: dateSchema, to: dateSchema };
export const foodRef = z.strictObject({
  source: z.enum(["catalog", "openfoodfacts", "favorite", "customBarcode"]),
  id: z.string().min(1).max(300),
});
export const nutrientNames = [
  "calories",
  "fat",
  "saturatedFat",
  "carbs",
  "sugar",
  "protein",
  "salt",
  "sodium",
  "fiber",
  "addedSugars",
  "caffeine",
  "calcium",
  "iron",
  "vitaminC",
  "magnesium",
  "phosphorus",
  "potassium",
  "zinc",
  "copper",
  "selenium",
  "vitaminA",
  "vitaminE",
  "vitaminD",
  "vitaminB1",
  "vitaminB2",
  "vitaminPP",
  "vitaminB6",
  "vitaminB12",
  "vitaminB9",
  "vitaminK",
  "cholesterol",
  "butyricAcid",
  "caproicAcid",
  "caprylicAcid",
  "capricAcid",
  "lauricAcid",
  "myristicAcid",
  "palmiticAcid",
  "stearicAcid",
  "oleicAcid",
  "linoleicAcid",
  "docosahexaenoicAcid",
  "eicosapentaenoicAcid",
  "erucicAcid",
  "monounsaturatedFat",
  "polyunsaturatedFat",
  "alcohol",
  "pantothenicAcid",
  "biotin",
  "chloride",
  "chromium",
  "fluoride",
  "iodine",
  "manganese",
  "molybdenum",
  "omega3",
  "omega6",
  "omega9",
  "betaCarotene",
  "bicarbonate",
  "sugarAlcohol",
  "alphaLinolenicAcid",
  "arachidicAcid",
  "arachidonicAcid",
  "behenicAcid",
  "ceroticAcid",
  "dihomoGammaLinolenicAcid",
  "elaidicAcid",
  "gammaLinolenicAcid",
  "gondoicAcid",
  "lignocericAcid",
  "meadAcid",
  "melissicAcid",
  "montanicAcid",
  "nervonicAcid",
  "transFat",
  "water",
] as const;
export const nutrientUnits: Record<string, string> = Object.fromEntries(
  nutrientNames.map((k) => [k, "g"]),
);
Object.assign(nutrientUnits, { calories: "kcal", alcohol: "%", water: "ml" });
for (
  const k of [
    "calcium",
    "iron",
    "vitaminC",
    "magnesium",
    "phosphorus",
    "potassium",
    "zinc",
    "copper",
    "vitaminE",
    "vitaminB1",
    "vitaminB2",
    "vitaminPP",
    "vitaminB6",
    "cholesterol",
    "pantothenicAcid",
    "chloride",
    "fluoride",
    "manganese",
    "omega3",
    "omega6",
    "omega9",
    "bicarbonate",
  ]
) nutrientUnits[k] = "mg";
for (
  const k of [
    "selenium",
    "vitaminA",
    "vitaminD",
    "vitaminB12",
    "vitaminB9",
    "vitaminK",
    "biotin",
    "chromium",
    "iodine",
    "molybdenum",
  ]
) nutrientUnits[k] = "µg";
export const nutrientsSchema = z.strictObject(
  Object.fromEntries(
    nutrientNames.map((
      key,
      i,
    ) => [
      key,
      (i < 6
        ? nonnegative.max(1e9)
        : nonnegative.max(1e9).nullable().optional()).describe(
          `${nutrientUnits[key]} per 100g or 100ml`,
        ),
    ]),
  ),
);
export const foodDefinition = z.strictObject({
  name,
  brand: z.string().max(200).optional(),
  unit: z.enum(["g", "ml"]),
  nutritionalValuesPer100g: nutrientsSchema,
  servingSizes: z.array(
    z.strictObject({
      name: z.string().max(200).optional(),
      amount: z.number().positive().max(1e6),
    }),
  ).max(100).default([]),
});
export const bodyMeasurementType = z.enum([
  "waist",
  "bodyFat",
  "neck",
  "shoulder",
  "chest",
  "leftBicep",
  "rightBicep",
  "leftForearm",
  "rightForearm",
  "abdomen",
  "hips",
  "leftThigh",
  "rightThigh",
  "leftCalf",
  "rightCalf",
]);
export const measurementRef = z.strictObject({
  kind: z.enum(["weight", "body"]),
  id: z.string().min(1).max(300),
});
export const measurementDate = z.iso.date().refine(
  (value) => !value.startsWith("0000-"),
  "Year must be at least 1",
);
const measurementTime = z.union([
  z.iso.datetime({ offset: true }),
  measurementDate,
])
  .optional().describe(
    "Instant with UTC/offset, or YYYY-MM-DD at midnight in the account time zone. Omit for server time.",
  );
const measurementValue = z.number().min(0).max(3.4028234e38);
export const measurementSchema = z.discriminatedUnion("kind", [
  z.strictObject({
    kind: z.literal("weight"),
    value: measurementValue,
    unit: z.enum(["kg", "lb"]).default("kg"),
    time: measurementTime,
  }),
  z.strictObject({
    kind: z.literal("body"),
    type: bodyMeasurementType,
    value: measurementValue,
    time: measurementTime,
  }),
]).superRefine((entry, ctx) => {
  if (entry.kind === "body" && entry.type === "bodyFat" && entry.value > 100) {
    ctx.addIssue({
      code: "custom",
      path: ["value"],
      message: "Body fat must be between 0 and 100 percent",
    });
  }
});
export const waterLogSchema = z.strictObject({
  milliliters: z.number().positive().max(Number.MAX_VALUE).describe(
    "Total drinking water volume in ml. Two 250ml glasses are 500ml; ask if the unit size is unknown.",
  ),
  time: measurementTime,
});
export const foodLogSchema = z.strictObject({
  date: dateSchema,
  category: z.string().min(1).max(200).optional(),
  amount: z.number().positive().max(1e6).describe(
    "Grams/ml for ONE piece or serving, not the total across pieces. Three slices weighing 30g TOTAL: amount=10, pieces=3. Three slices weighing 30g EACH: amount=30, pieces=3.",
  ),
  pieces: z.number().int().positive().max(10000).default(1).describe(
    "Number of equal units consumed. For X slices, spoons, glasses or packs use X; resolve the grams/ml per unit from user input or a matching servingSize, otherwise ask.",
  ),
  foodRef: foodRef.optional(),
  food: foodDefinition.optional(),
}).refine(
  (v) => !!v.foodRef !== !!v.food,
  "Supply foodRef or food, exclusively",
);
export const pagination = {
  offset: nonnegative.int().max(1000000).default(0),
  limit: z.number().int().min(1).max(100).default(20),
};
export const searchSchema = z.strictObject({
  query: z.string().max(200).default(""),
  language,
  ...pagination,
  source: z.enum(["standard", "custom", "all"]).default("all"),
  category: z.string().max(100).optional(),
  muscles: z.array(z.string().max(100)).max(30).default([]),
  equipment: z.string().max(100).optional(),
});
export type Program = z.infer<typeof programSchema>;
export type ExerciseDefinition = {
  source: "standard" | "custom";
  id: string;
  name?: string;
  names?: Record<string, string>;
  category: string;
  parameters: string;
  primaryMuscleGroup: string;
  secondaryMuscleGroups: string[];
  equipment: string;
};
export const standardExercises = catalog.exercises as ExerciseDefinition[];
export const catalogVersion = catalog.version;
export function displayExercise(exercise: ExerciseDefinition, locale: string) {
  const { names, ...rest } = exercise;
  return {
    ...rest,
    name: names?.[locale] ?? names?.it ?? exercise.name ?? exercise.id,
  };
}
export const fold = (value: string) =>
  value.normalize("NFD").replace(/\p{M}/gu, "").toLocaleLowerCase("en").trim();
export function search(
  exercises: ExerciseDefinition[],
  args: z.infer<typeof searchSchema>,
) {
  const words = fold(args.query).split(/\s+/).filter(Boolean);
  const filtered = exercises.filter((e) =>
    (args.source === "all" || e.source === args.source) &&
    (!args.category || e.category === args.category) &&
    (!args.equipment || e.equipment === args.equipment) &&
    args.muscles.every((muscle) =>
      e.primaryMuscleGroup === muscle ||
      e.secondaryMuscleGroups.includes(muscle)
    ) &&
    words.every((word) =>
      fold([e.name, ...Object.values(e.names ?? {})].join(" ")).includes(word)
    )
  ).sort((a, b) =>
    a.source.localeCompare(b.source) || a.id.localeCompare(b.id)
  );
  return {
    catalogVersion,
    items: filtered.slice(args.offset, args.offset + args.limit).map((e) =>
      displayExercise(e, args.language)
    ),
    nextOffset: args.offset + args.limit < filtered.length
      ? args.offset + args.limit
      : null,
  };
}
export class ToolError extends Error {
  constructor(public code: string, message: string) {
    super(message);
  }
}
