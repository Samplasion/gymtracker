import {
  deepStrictEqual as assertEquals,
  throws as assertThrows,
} from "node:assert";
import { sanitizeProgram } from "./program.ts";
const program = () => ({
  version: 1,
  title: "Plan",
  kind: "program",
  owner_id: "private",
  routines: [{
    id: "r",
    name: "Day",
    weight_unit: "kg",
    distance_unit: "km",
    exercises: [{
      id: "e",
      name: "Squat",
      parameters: "repsWeight",
      library_exercise_id: "squat",
      notes: "Note",
      user_id: "private",
      sets: [{
        id: "s",
        kind: "normal",
        parameters: "repsWeight",
        weight: 50,
        reps: 5,
        done: true,
      }],
    }],
  }],
});
Deno.test("snapshot strips account fields and completion without mutating source", () => {
  const p = program();
  const result = sanitizeProgram(p);
  assertEquals(JSON.stringify(result).includes("private"), false);
  assertEquals(result.routines[0].exercises[0].sets[0].done, false);
  assertEquals(p.routines[0].exercises[0].sets[0].done, true);
});
Deno.test("rejects unknown versions and broken supersets", () => {
  assertThrows(() => sanitizeProgram({ ...program(), version: 2 }));
  const p = program();
  Object.assign(p.routines[0].exercises[0], {
    superset_id: "missing",
    is_in_superset: true,
  });
  assertThrows(() => sanitizeProgram(p));
});
Deno.test("rejects non-finite numbers and excessive collections", () => {
  const p = program();
  p.routines[0].exercises[0].sets[0].weight = Infinity;
  assertThrows(() => sanitizeProgram(p));
  assertThrows(() => sanitizeProgram({ ...program(), routines: [] }));
});
