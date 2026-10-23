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
export const programSchema = z.strictObject({
  name,
  notes: text,
  routines: z.array(z.strictObject({
    name,
    notes: text,
    weightUnit: z.enum(["kg", "lb"]).default("kg"),
    distanceUnit: z.enum(["km", "mi"]).default("km"),
    exercises: z.array(z.strictObject({
      exerciseRef,
      notes: text,
      restSeconds: nonnegative.int().max(86400).default(0),
      sets: z.array(setSchema).max(100),
    })).min(1).max(100),
  })).min(1).max(31),
});
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
