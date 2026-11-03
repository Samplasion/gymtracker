import {
  compactTraining,
  foodResult,
  foodView,
  hydrationSummary,
  nutritionSummary,
  routineView,
  trainingStats,
  workoutView,
} from "./views.ts";
import {
  foodDefinition,
  foodLogSchema,
  programSchema,
  ToolError,
} from "./schemas.ts";
function equal(a: unknown, b: unknown) {
  if (JSON.stringify(a) !== JSON.stringify(b)) {
    throw new Error(`${JSON.stringify(a)} != ${JSON.stringify(b)}`);
  }
}

Deno.test("food results share units once and preserve zero, missing required nutrients and metadata", () => {
  const source = {
    items: [
      {
        id: "a",
        date: "2026-11-03",
        food: {
          id: "a",
          name: "Coffee",
          nutritionalValuesPer100g: { calories: 0, fat: 0, fiber: null },
        },
      },
      {
        reference: { source: "catalog", id: "b" },
        food: {
          name: "Apple",
          nutritionalValuesPer100g: { calories: 50, water: 85, fiber: null },
        },
      },
    ],
    unavailable: ["c"],
    nextCursor: "next",
  };
  const result = foodResult(source);
  equal(result.nutrientUnits, { calories: "kcal", fat: "g", water: "ml" });
  equal(result.items[0].food.nutritionalValuesPer100g, { calories: 0, fat: 0 });
  equal(result.items[0].food.missingNutrients, [
    "saturatedFat",
    "carbs",
    "sugar",
    "protein",
  ]);
  equal(Object.hasOwn(result.items[0].food, "nutrientUnits"), false);
  equal(result.items[0].id, result.items[0].food.id);
  equal(result.items[1].reference, source.items[1].reference);
  equal(result.unavailable, ["c"]);
  equal(result.nextCursor, "next");
  equal(source.items[0].food.nutritionalValuesPer100g.fiber, null);
});

Deno.test("compact training preserves hierarchy, progression, set kinds, performed state and detailed source sessions", () => {
  const rich = JSON.stringify([{ insert: "Rest carefully\n" }]);
  const raw = workoutView({
    id: "w",
    components: [component("w", {
      infobox: rich,
      exercises: [
        exercise("group", { is_superset: true, sets: [] }),
        exercise("child", {
          superset_id: "group",
          notes: rich,
          progression: '{"setCount":1}',
          sets: [
            {
              kind: "drop",
              weight: 0,
              reps: 0,
              done: false,
              parameters: "repsWeight",
              time: 0,
              distance: 0,
              rpe: null,
            },
            {
              kind: "failure",
              weight: 20,
              reps: 5,
              done: true,
              parameters: "time",
              time: 0,
              rpe: 9,
            },
          ],
        }),
      ],
    })],
  });
  const slim = compactTraining(raw);
  equal(Object.hasOwn(slim, "components"), false);
  equal(slim.componentIds, ["w"]);
  equal(slim.notes, "Rest carefully\n");
  const child = slim.entries[0].exercises[0];
  equal(child.progression, { setCount: 1 });
  equal(child.notes, "Rest carefully\n");
  equal(child.sets[0], { kind: "drop", weight: 0, reps: 0, done: false });
  equal(child.sets[1], {
    kind: "failure",
    weight: 20,
    reps: 5,
    done: true,
    parameters: "time",
    rpe: 9,
    timeSeconds: 0,
  });
  const detailed = compactTraining(raw, true);
  equal(detailed.components[0].notes, rich);
  equal(detailed.components[0].notesText, "Rest carefully\n");
  equal(Object.hasOwn(detailed.components[0], "exercises"), false);
  equal(raw.components[0].exercises.length, 2);
  if (JSON.stringify(slim).length >= JSON.stringify(raw).length / 2) {
    throw new Error("Expected substantial payload reduction");
  }
});
const exercise = (id: string, extra: Record<string, unknown> = {}) => ({
  id,
  name: id,
  sort_order: 0,
  is_custom: false,
  is_superset: false,
  library_exercise_id: "library.abs.exercises.bicycleCrunches",
  parameters: "repsWeight",
  primary_muscle_group: "abs",
  secondary_muscle_groups: [],
  equipment: "barbell",
  sets: [{
    id: `${id}-set`,
    kind: "normal",
    reps: 8,
    weight: 10,
    time: 1500000,
    done: true,
  }],
  ...extra,
});
const component = (id: string, extra: Record<string, unknown> = {}) => ({
  id,
  name: "Workout",
  weight_unit: "kg",
  distance_unit: "km",
  starting_date: "2026-10-23T10:00:00Z",
  duration: 60,
  exercises: [exercise("original")],
  ...extra,
});
Deno.test("routine view preserves legacy flat fields and adds ordered superset children and parsed progression", () => {
  const result = routineView(
    component("r", {
      exercises: [
        exercise("group", { is_superset: true, sets: null }),
        exercise("child", {
          superset_id: "group",
          is_in_superset: true,
          progression: '{"setCount":1}',
        }),
      ],
    }),
  );
  equal(result.exercises.length, 2);
  equal(result.entries.length, 1);
  equal(result.entries[0].exercises[0].id, "child");
  equal(result.exercises[1].sets[0].timeSeconds, 1.5);
  equal(result.exercises[1].progression, { setCount: 1 });
});
Deno.test("modern continuation replaces snapshots, converts units and retains original components", () => {
  const result = workoutView({
    id: "a",
    components: [
      component("a", { completed_by: "b" }),
      component("b", {
        completes: "a",
        weight_unit: "lb",
        distance_unit: "mi",
        exercises: [
          exercise("replacement", {
            supersedes_id: "original",
            sets: [{
              kind: "normal",
              weight: 100,
              reps: 9,
              time: 0,
              done: true,
            }],
          }),
        ],
      }),
    ],
  });
  equal(result.componentIds, ["a", "b"]);
  equal(result.entries.length, 1);
  equal(result.entries[0].id, "original");
  equal(result.durationSeconds, 120);
  equal(result.entries[0].sets[0].weight, 45.359237);
  equal(result.components[1].entries[0].sets[0].weight, 100);
});
Deno.test("legacy continuations append and inconsistent links never imply supersedence", () => {
  for (const completed_by of [null, "other"]) {
    const result = workoutView({
      id: "a",
      components: [
        component("a", { completed_by }),
        component("b", {
          completes: "a",
          exercises: [exercise("replacement", { supersedes_id: "original" })],
        }),
      ],
    });
    equal(result.entries.length, 2);
  }
});
Deno.test("stats count each logical workout once, only completed sets, and convert component units", () => {
  const result = trainingStats([{
    components: [
      component("a"),
      component("b", {
        weight_unit: "lb",
        duration: 30,
        exercises: [
          exercise("e", {
            sets: [{ done: true, reps: 10, weight: 100 }, {
              done: false,
              reps: 100,
              weight: 1000,
            }],
          }),
        ],
      }),
    ],
  }]);
  equal(result.workouts, 1);
  equal(result.completedSets, 2);
  equal(result.durationSeconds, 90);
  if (Math.abs(result.volume - 533.59237) > 1e-8) {
    throw new Error("Wrong converted volume");
  }
});
Deno.test("nutrition sums quantity and pieces, preserves missing optional values and empty days", () => {
  const settings = ["2026-10-22", "2026-10-23"].map((date) => ({
    date,
    goal: {
      dailyCalories: 2000,
      dailyFat: 60,
      dailyCarbs: 250,
      dailyProtein: 100,
    },
  }));
  const result = nutritionSummary({
    settings,
    entries: [{
      date: "2026-10-23",
      food: {
        amount: 50,
        pieces: 2,
        category: "Lunch",
        nutritionalValuesPer100g: {
          calories: 200,
          fat: 5,
          carbs: 20,
          protein: 10,
        },
      },
    }],
  });
  equal(result.items[0].totals.calories, 0);
  equal(result.items[1].totals.calories, 200);
  equal(result.items[1].remaining.calories, 1800);
  equal(Object.hasOwn(result.items[1].totals, "fiber"), false);
  equal(!Object.hasOwn(result.items[1].totals, "fiber"), true);
  equal(
    Object.hasOwn(result.items[1].categories[0], "incompleteNutrients"),
    false,
  );
  equal(
    Object.values(result.items[1].categories[0].totals).includes(null),
    false,
  );
  equal(Object.hasOwn(result.items[0], "incompleteNutrients"), false);
  equal(result.items[1].categories[0].totals.protein, 10);
});
Deno.test("incomplete food sources cannot be silently logged and manual provenance is rejected", () => {
  const food = {
    name: "Food",
    unit: "g",
    nutritionalValuesPer100g: { calories: 100, fat: 0, carbs: 20, protein: 5 },
  };
  equal(foodView(food).missingNutrients, ["saturatedFat", "sugar"]);
  equal(foodDefinition.safeParse(food).success, false);
  equal(
    foodLogSchema.safeParse({
      date: "2026-10-23",
      amount: 50,
      food,
      foodRef: { source: "favorite", id: "x" },
    }).success,
    false,
  );
  equal(
    foodLogSchema.safeParse({ date: "2026-02-30", amount: 50, food }).success,
    false,
  );
});
Deno.test("complete routine schemas accept simple legacy entries and bounded nonrecursive supersets", () => {
  const simple = {
    exerciseRef: { source: "standard", id: "x" },
    sets: [{ reps: 8 }],
  };
  equal(
    programSchema.safeParse({
      name: "p",
      routines: [{
        name: "r",
        exercises: [simple, { type: "superset", exercises: [simple, simple] }],
      }],
    }).success,
    true,
  );
  equal(
    programSchema.safeParse({
      name: "p",
      routines: [{
        name: "r",
        exercises: [{
          type: "superset",
          exercises: [simple, {
            type: "superset",
            exercises: [simple, simple],
          }],
        }],
      }],
    }).success,
    false,
  );
});

Deno.test("training stats do not double count completed sets copied into a modern continuation", () => {
  const result = trainingStats([{
    id: "a",
    components: [
      component("a", { completed_by: "b" }),
      component("b", {
        completes: "a",
        exercises: [
          exercise("replacement", {
            supersedes_id: "original",
            sets: [{ kind: "normal", weight: 10, reps: 8, done: true }, {
              kind: "normal",
              weight: 20,
              reps: 8,
              done: true,
            }],
          }),
        ],
      }),
    ],
  }]);
  equal(result.completedSets, 2);
  equal(result.volume, 240);
  equal(result.workouts, 1);
});

Deno.test("counted foods use one-unit amount and multiply pieces exactly once", () => {
  const settings = [{
    date: "2026-10-24",
    goal: {
      dailyCalories: 2000,
      dailyFat: 60,
      dailyCarbs: 250,
      dailyProtein: 100,
    },
  }];
  for (
    const [amount, pieces, calories] of [[10, 3, 75], [30, 3, 225], [
      200,
      2,
      1000,
    ], [15, 4, 150]]
  ) {
    const r = nutritionSummary({
      settings,
      entries: [{
        date: "2026-10-24",
        food: {
          amount,
          pieces,
          nutritionalValuesPer100g: {
            calories: 250,
            fat: 0,
            saturatedFat: 0,
            carbs: 50,
            sugar: 0,
            protein: 5,
          },
        },
      }],
    });
    equal(r.items[0].totals.calories, calories);
  }
});

Deno.test("hydration shares daily totals with nutrition without changing food-only water", () => {
  const raw = {
    settings: [
      {
        date: "2026-10-24",
        goal: { dailyWater: 2000 },
        goalEffectiveFrom: "2026-10-01",
      },
      {
        date: "2026-10-25",
        goal: { dailyWater: null },
        goalEffectiveFrom: "2026-10-25",
      },
      { date: "2026-10-26", goal: {} },
    ],
    entries: [
      {
        date: "2026-10-24",
        food: {
          amount: 10,
          pieces: 3,
          nutritionalValuesPer100g: { water: 90 },
        },
      },
      {
        date: "2026-10-25",
        food: { amount: 100, nutritionalValuesPer100g: { water: 0 } },
      },
      {
        date: "2026-10-25",
        food: { amount: 200, nutritionalValuesPer100g: {} },
      },
    ],
    waterEntries: [{ date: "2026-10-24", milliliters: 500.25 }, {
      date: "2026-10-24",
      milliliters: 125.5,
    }],
  };
  const water = hydrationSummary(raw).items;
  equal(water[0], {
    date: "2026-10-24",
    drinkingWaterMl: 625.75,
    knownFoodWaterMl: 27,
    knownTotalWaterMl: 652.75,
    foodWaterComplete: true,
    waterGoalMl: 2000,
    waterGoalEffectiveFrom: "2026-10-01",
  });
  equal(water[1].knownFoodWaterMl, 0);
  equal(water[1].foodWaterComplete, false);
  equal(water[1].waterGoalMl, null);
  equal(water[2].knownTotalWaterMl, 0);
  equal(water[2].foodWaterComplete, true);
  equal(water[2].waterGoalMl, null);
  const nutrition = nutritionSummary(raw).items;
  equal(nutrition.map((d: any) => d.hydration), water);
  equal(nutrition[0].totals.water, 27);
  equal(Object.hasOwn(nutrition[1].totals, "water"), false);
  equal(!Object.hasOwn(nutrition[1].totals, "water"), true);
});

Deno.test("hydration totals reject numeric overflow instead of serializing Infinity as null", () => {
  let failed = false;
  try {
    hydrationSummary({
      settings: [{ date: "2026-10-25", goal: {} }],
      entries: [],
      waterEntries: [{ date: "2026-10-25", milliliters: Number.MAX_VALUE }, {
        date: "2026-10-25",
        milliliters: Number.MAX_VALUE,
      }],
    });
  } catch (error) {
    failed = error instanceof ToolError && error.code === "invalid_input";
  }
  equal(failed, true);
});

Deno.test("shared hydration fixture matches the Flutter diary calculation", async () => {
  const fixture = JSON.parse(
    await Deno.readTextFile(
      new URL("../../../test/fixtures/mcp_hydration.json", import.meta.url),
    ),
  );
  const raw = {
    settings: [{ date: fixture.api.date, goal: {} }],
    entries: [{ date: fixture.api.date, food: fixture.food }],
    waterEntries: [fixture.api],
  };
  equal(
    hydrationSummary(raw).items[0].knownTotalWaterMl,
    fixture.knownTotalWaterMl,
  );
});

Deno.test("compact nutrition totals preserve zeros and distinguish meal completeness", () => {
  const result = nutritionSummary({
    settings: [{ date: "2026-11-03", goal: { dailyCalories: 2000 } }],
    entries: [
      {
        date: "2026-11-03",
        food: {
          category: "Lunch",
          amount: 100,
          nutritionalValuesPer100g: { calories: 100, fat: 0, fiber: 2 },
        },
      },
      {
        date: "2026-11-03",
        food: {
          amount: 100,
          nutritionalValuesPer100g: { calories: null, fat: 0, fiber: null },
        },
      },
    ],
  });
  const day = result.items[0];
  equal(day.totals, { fat: 0 });
  equal(day.remaining.calories, null);
  equal(!Object.hasOwn(day.totals, "calories"), true);
  equal(!Object.hasOwn(day.totals, "fiber"), true);
  equal(!Object.hasOwn(day.totals, "fat"), false);
  equal(day.categories[0].totals, { calories: 100, fat: 0, fiber: 2 });
  equal(!Object.hasOwn(day.categories[0].totals, "fiber"), false);
  equal(day.categories[1].category, null);
  equal(day.categories[1].totals, { fat: 0 });
  equal(!Object.hasOwn(day.categories[1].totals, "fiber"), true);
  equal(JSON.parse(JSON.stringify(result)).items[0].totals, { fat: 0 });
});
