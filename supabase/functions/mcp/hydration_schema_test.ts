import { nutrientsSchema, nutrientUnits } from "./schemas.ts";

Deno.test("water is an optional nonnegative nutrient expressed in milliliters", () => {
  const macros = { calories: 0, fat: 0, saturatedFat: 0, carbs: 0, sugar: 0, protein: 0 };
  if (!nutrientsSchema.safeParse(macros).success) throw new Error("Legacy food rejected");
  if (nutrientsSchema.parse({ ...macros, water: 95.23 }).water !== 95.23) throw new Error("Water lost");
  if (nutrientUnits.water !== "ml") throw new Error("Incorrect water unit");
  if (nutrientsSchema.safeParse({ ...macros, water: -1 }).success) throw new Error("Negative water accepted");
  if (nutrientsSchema.safeParse({ ...macros, water: Infinity }).success) throw new Error("Infinite water accepted");
});
