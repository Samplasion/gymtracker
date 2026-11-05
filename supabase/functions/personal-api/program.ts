/** Portable snake_case prescription. No account, trainer or history identifiers. */
type Row = Record<string, unknown>;
const object = (x: unknown): Row => {
  if (!x || typeof x !== "object" || Array.isArray(x)) {
    throw new Error("invalid_program");
  }
  return x as Row;
};
const string = (x: unknown, max = 100000): string => {
  if (typeof x !== "string" || x.length > max) {
    throw new Error("invalid_program");
  }
  return x;
};
const array = (x: unknown, max: number): unknown[] => {
  if (!Array.isArray(x) || x.length > max) throw new Error("invalid_program");
  return x;
};
const number = (x: unknown, fallback = 0) => {
  if (x == null) return fallback;
  if (typeof x !== "number" || !Number.isFinite(x) || Math.abs(x) > 1e15) {
    throw new Error("invalid_program");
  }
  return x;
};
const nullable = (x: unknown) => x == null ? null : string(x, 300);
const parameters = new Set([
  "repsWeight",
  "repsNegWeight",
  "timeWeight",
  "freeBodyReps",
  "time",
  "distance",
  "setless",
]);
const kinds = new Set([
  "normal",
  "warmUp",
  "drop",
  "failure",
  "failureStripping",
]);
export function sanitizeProgram(input: unknown) {
  const p = object(input);
  if (p.version !== 1) throw new Error("unsupported_version");
  if (
    !["routine", "program"].includes(String(p.kind)) ||
    !string(p.title, 1000).trim()
  ) throw new Error("invalid_program");
  const routineIds = new Set<string>();
  const routines = array(p.routines, 100).map((value) => {
    const r = object(value);
    const routineId = string(r.id, 300);
    if (!routineId || routineIds.has(routineId)) {
      throw new Error("invalid_program");
    }
    routineIds.add(routineId);
    if (
      !["kg", "lb"].includes(String(r.weight_unit)) ||
      !["km", "mi"].includes(String(r.distance_unit))
    ) throw new Error("invalid_program");
    const ids = new Set<string>();
    let currentGroup: string | null = null;
    const exercises = array(r.exercises, 500).map((value) => {
      const e = object(value);
      const id = string(e.id, 300);
      if (!id || ids.has(id)) throw new Error("invalid_program");
      ids.add(id);
      if (e.is_superset === true) {
        if (e.superset_id || e.is_in_superset) {
          throw new Error("invalid_program");
        }
        currentGroup = id;
      } else if (e.superset_id || e.is_in_superset) {
        if (
          !e.is_in_superset || e.superset_id !== currentGroup || !currentGroup
        ) throw new Error("invalid_program");
      } else currentGroup = null;
      if (
        e.is_superset !== true && e.is_custom !== true &&
        !nullable(e.library_exercise_id)
      ) throw new Error("invalid_program");
      const param = e.parameters ?? "repsWeight";
      if (!parameters.has(String(param))) throw new Error("invalid_program");
      return {
        id,
        name: string(e.name, 1000),
        parameters: param,
        primary_muscle_group: string(e.primary_muscle_group ?? "none", 100),
        secondary_muscle_groups: array(e.secondary_muscle_groups ?? [], 50).map(
          (x) => string(x, 100),
        ),
        equipment: string(e.equipment ?? "none", 100),
        is_custom: e.is_custom === true,
        library_exercise_id: nullable(e.library_exercise_id),
        custom_exercise_id: nullable(e.custom_exercise_id),
        is_superset: e.is_superset === true,
        is_in_superset: e.is_in_superset === true,
        superset_id: nullable(e.superset_id),
        sort_order: number(e.sort_order),
        rest_time: number(e.rest_time),
        notes: string(e.notes ?? ""),
        progression: e.progression == null ? null : string(
          typeof e.progression === "string"
            ? e.progression
            : JSON.stringify(e.progression),
        ),
        sets: array(e.sets ?? [], 500).map((value) => {
          const s = object(value);
          if (
            !parameters.has(String(s.parameters)) || !kinds.has(String(s.kind))
          ) throw new Error("invalid_program");
          return {
            id: string(s.id, 300),
            kind: s.kind,
            parameters: s.parameters,
            reps: number(s.reps),
            weight: number(s.weight),
            time: number(s.time),
            distance: number(s.distance),
            rpe: s.rpe == null ? null : number(s.rpe),
            done: false,
          };
        }),
      };
    });
    return {
      id: string(r.id, 300),
      name: string(r.name, 1000),
      infobox: string(r.infobox ?? ""),
      weight_unit: r.weight_unit,
      distance_unit: r.distance_unit,
      folder_id: null,
      exercises,
    };
  });
  if (
    !routines.length || (p.kind === "routine" && routines.length !== 1) ||
    routines.some((r) => !r.name.trim())
  ) throw new Error("invalid_program");
  const custom_exercises = routines.flatMap((r) =>
    r.exercises.filter((e) => e.is_custom && !e.is_superset).map((e) => ({
      id: e.custom_exercise_id ?? e.id,
      name: e.name,
      parameters: e.parameters,
      primary_muscle_group: e.primary_muscle_group,
      secondary_muscle_groups: e.secondary_muscle_groups,
      equipment: e.equipment,
    }))
  );
  return {
    version: 1,
    title: string(p.title, 1000),
    notes: string(p.notes ?? ""),
    kind: p.kind === "program" ? "program" : "routine",
    routines,
    custom_exercises,
  };
}
