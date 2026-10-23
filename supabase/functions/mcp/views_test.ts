import {
  foodView,
  nutritionSummary,
  routineView,
  trainingStats,
  workoutView,
} from "./views.ts";
import { foodDefinition, foodLogSchema, programSchema } from "./schemas.ts";
function equal(a: unknown, b: unknown) {
  if (JSON.stringify(a) !== JSON.stringify(b)) {
    throw new Error(`${JSON.stringify(a)} != ${JSON.stringify(b)}`);
  }
}
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
  equal(result.items[1].totals.fiber, null);
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
