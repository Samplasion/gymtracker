import {
  displayExercise,
  nutrientNames,
  nutrientUnits,
  standardExercises,
  ToolError,
} from "./schemas.ts";
type Row = Record<string, any>;
const parse = (v: unknown) => typeof v === "string" ? JSON.parse(v) : v;
export function readableNotes(value: string): string {
  try {
    const delta = JSON.parse(value);
    if (Array.isArray(delta)) {
      return delta.map((op) => typeof op.insert === "string" ? op.insert : "")
        .join("");
    }
  } catch { /* plaintext */ }
  return value;
}
export function routineView(r: Row, language = "it") {
  const exercises: Row[] = (r.exercises ?? []).map((e: Row) => ({
    id: e.id,
    name: e.name,
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
    notesText: readableNotes(e.notes ?? ""),
    isSuperset: e.is_superset,
    supersetId: e.superset_id,
    supersedesId: e.supersedes_id,
    rpe: e.rpe,
    progression: parse(e.progression),
    sortOrder: e.sort_order,
    sets: (e.sets ?? []).map((s: Row) => ({
      ...s,
      time: undefined,
      timeSeconds: Number(s.time ?? 0) / 1e6,
    })),
  }));
  for (const e of exercises) {
    const standard = standardExercises.find((x) =>
      e.exerciseRef?.source === "standard" && x.id === e.exerciseRef.id
    );
    if (standard) e.name = displayExercise(standard, language).name;
  }
  const entries: Row[] = exercises.filter((e) => !e.supersetId).map((e) =>
    e.isSuperset
      ? {
        ...e,
        type: "superset",
        exercises: exercises.filter((c) => c.supersetId === e.id).sort(order),
      }
      : { ...e, type: "exercise" }
  );
  return {
    id: r.id,
    name: r.name,
    notes: r.infobox ?? "",
    notesText: readableNotes(r.infobox ?? ""),
    weightUnit: r.weight_unit,
    distanceUnit: r.distance_unit,
    folderId: r.folder_id,
    exercises,
    entries,
  };
}
function order(a: Row, b: Row) {
  return (a.sortOrder ?? 0) - (b.sortOrder ?? 0) ||
    String(a.id).localeCompare(String(b.id));
}
const weightFactor = (from: string, to: string) =>
  from === to ? 1 : from === "lb" ? 0.45359237 : 1 / 0.45359237;
const distanceFactor = (from: string, to: string) =>
  from === to ? 1 : from === "mi" ? 1.609344 : 1 / 1.609344;
function convert(e: Row, w: number, d: number): Row {
  return {
    ...e,
    progression: e.progression
      ? {
        ...e.progression,
        startingWeight: e.progression.startingWeight * w,
        weightPerStep: e.progression.weightPerStep * w,
        weightPerCycle: e.progression.weightPerCycle * w,
      }
      : null,
    sets: e.sets.map((s: Row) => ({
      ...s,
      weight: s.weight == null ? s.weight : s.weight * w,
      distance: s.distance == null ? s.distance : s.distance * d,
    })),
    ...(e.exercises
      ? { exercises: e.exercises.map((x: Row) => convert(x, w, d)) }
      : {}),
  };
}
export function workoutView(raw: Row, language = "it") {
  const components: Row[] = raw.components.map((c: Row) => ({
    ...routineView(c, language),
    startingDate: c.starting_date,
    durationSeconds: Number(c.duration),
    parentId: c.parent_id,
    completes: c.completes,
    completedBy: c.completed_by,
  }));
  const first = components[0];
  if (!first) throw new Error("Empty workout components");
  let entries: Row[] = first.entries;
  // Same branch as Workout.getExercisesLinearly: continuation supersedences replace
  // planned instances, legacy sessions append their independent entries.
  for (const component of components.slice(1)) {
    const incoming = component.entries.map((e: Row) =>
      convert(
        e,
        weightFactor(component.weightUnit, first.weightUnit),
        distanceFactor(component.distanceUnit, first.distanceUnit),
      )
    );
    const modern = components.length === 2 &&
      component.completes === first.id &&
      first.completedBy === component.id && incoming.some((e: Row) =>
        e.supersedesId
      );
    if (modern) {
      const mapped = new Map(entries.map((e) => [e.id, e]));
      for (const e of incoming) {
        if (e.supersedesId) {
          const id = e.supersedesId;
          mapped.set(id, {
            ...e,
            id,
            supersedesId: null,
            ...(e.exercises
              ? {
                exercises: e.exercises.map((child: Row) => ({
                  ...child,
                  id: child.supersedesId ?? child.id,
                  supersedesId: null,
                  supersetId: id,
                })),
              }
              : {}),
          });
        } else mapped.set(e.id, e);
      }
      const ids = [
        ...entries.map((e) => e.id),
        ...incoming.filter((e: Row) => !e.supersedesId).map((e: Row) => e.id),
      ];
      entries = ids.map((id) => mapped.get(id)!).filter(Boolean);
    } else entries = [...entries, ...incoming];
  }
  return {
    id: raw.id,
    name: first.name,
    notes: first.notes,
    parentId: first.parentId,
    startingDate: first.startingDate,
    durationSeconds: components.reduce((n, c) => n + c.durationSeconds, 0),
    weightUnit: first.weightUnit,
    distanceUnit: first.distanceUnit,
    componentIds: components.map((c) => c.id),
    components,
    entries,
    warnings: raw.warnings ?? [],
  };
}
export function exerciseHistory(raw: Row, references: Row[], language: string) {
  const workout = workoutView(raw, language);
  const leaves = workout.entries.flatMap((e: Row) => e.exercises ?? [e]);
  return {
    ...workout,
    entries: undefined,
    components: undefined,
    exercises: leaves.filter((e: Row) =>
      references.some((r) =>
        r.source === e.exerciseRef?.source && r.id === e.exerciseRef?.id
      )
    ),
  };
}
export function trainingStats(
  raw: Row[],
  weightUnit = "kg",
  distanceUnit = "km",
) {
  let durationSeconds = 0, volume = 0, distance = 0, completedSets = 0;
  const muscles: Record<string, number> = {},
    equipment: Record<string, number> = {};
  for (const source of raw) {
    const workout = workoutView(source);
    durationSeconds += workout.durationSeconds;
    const leaves = workout.entries.flatMap((e: Row) => e.exercises ?? [e]);
    for (const e of leaves) {
      for (const set of e.sets) {
        if (set.done) {
          completedSets++;
          volume += (Number(set.weight) || 0) * (set.reps ?? 1) *
            weightFactor(workout.weightUnit, weightUnit);
          distance += (Number(set.distance) || 0) *
            distanceFactor(workout.distanceUnit, distanceUnit);
          for (
            const muscle of new Set([
              e.primaryMuscleGroup,
              ...(e.secondaryMuscleGroups ?? []),
            ])
          ) {
            if (muscle) {
              muscles[String(muscle)] = (muscles[String(muscle)] ?? 0) + 1;
            }
          }
          equipment[e.equipment ?? "none"] =
            (equipment[e.equipment ?? "none"] ?? 0) + 1;
        }
      }
    }
  }
  return {
    workouts: raw.length,
    durationSeconds,
    completedSets,
    volume,
    weightUnit,
    distance,
    distanceUnit,
    muscles,
    equipment,
  };
}
export function foodView(f: Row) {
  const values = f.nutritionalValuesPer100g ?? {};
  const missingNutrients = nutrientNames.slice(0, 6).filter((k) =>
    typeof values[k] !== "number"
  );
  return {
    ...f,
    missingNutrients,
    nutrientUnits,
    ...(f.isDownloaded && f.barcode
      ? {
        attribution: {
          name: "Open Food Facts",
          url: `https://world.openfoodfacts.org/product/${
            encodeURIComponent(f.barcode)
          }`,
          license: "ODbL",
        },
      }
      : {}),
  };
}
export function hydrationSummary(raw: Row) {
  return {
    items: raw.settings.map((setting: Row) => {
      const foods = raw.entries.filter((e: Row) => e.date === setting.date);
      const drinking = (raw.waterEntries ?? []).filter((e: Row) =>
        e.date === setting.date
      );
      const drinkingWaterMl = drinking.reduce(
        (sum: number, entry: Row) => sum + entry.milliliters,
        0,
      );
      const hasWater = (entry: Row) =>
        typeof entry.food.nutritionalValuesPer100g?.water === "number";
      const knownFoodWaterMl = foods.filter(hasWater).reduce(
        (sum: number, entry: Row) =>
          sum +
          entry.food.nutritionalValuesPer100g.water * entry.food.amount *
            (entry.food.pieces ?? 1) / 100,
        0,
      );
      if (
        ![drinkingWaterMl, knownFoodWaterMl, drinkingWaterMl + knownFoodWaterMl]
          .every(Number.isFinite)
      ) {
        throw new ToolError(
          "invalid_input",
          "Hydration totals exceed numeric range",
        );
      }
      const waterGoalMl = setting.goal.dailyWater ?? null;
      return {
        date: setting.date,
        drinkingWaterMl,
        knownFoodWaterMl,
        knownTotalWaterMl: drinkingWaterMl + knownFoodWaterMl,
        foodWaterComplete: foods.every(hasWater),
        waterGoalMl,
        waterGoalEffectiveFrom: waterGoalMl === null
          ? null
          : setting.goalEffectiveFrom ?? null,
      };
    }),
  };
}
export function nutritionSummary(raw: Row) {
  const hydration = new Map(
    hydrationSummary(raw).items.map((day: Row) => [day.date, day]),
  );
  return {
    nutrientUnits,
    items: raw.settings.map((setting: Row) => {
      const entries = raw.entries.filter((e: Row) => e.date === setting.date);
      const groups = new Map<string, Row[]>();
      for (const e of entries) {
        const key = e.food.category ?? "";
        groups.set(key, [...(groups.get(key) ?? []), e]);
      }
      const total = (list: Row[]) =>
        Object.fromEntries(nutrientNames.map((key) => {
          const missing = list.some((e) =>
            typeof e.food.nutritionalValuesPer100g?.[key] !== "number"
          );
          return [
            key,
            missing ? null : list.reduce((n, e) =>
              n +
              e.food.nutritionalValuesPer100g[key] * e.food.amount *
                (e.food.pieces ?? 1) / 100, 0),
          ];
        }));
      const totals = total(entries);
      return {
        ...setting,
        hydration: hydration.get(setting.date),
        totals,
        incompleteNutrients: nutrientNames.filter((k) => totals[k] === null),
        remaining: {
          calories: totals.calories === null
            ? null
            : setting.goal.dailyCalories - totals.calories,
          fat: totals.fat === null ? null : setting.goal.dailyFat - totals.fat,
          carbs: totals.carbs === null
            ? null
            : setting.goal.dailyCarbs - totals.carbs,
          protein: totals.protein === null
            ? null
            : setting.goal.dailyProtein - totals.protein,
        },
        categories: [...groups].map(([category, list]) => ({
          category: category || null,
          totals: total(list),
        })),
      };
    }),
  };
}
