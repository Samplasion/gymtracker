-- Shared product definitions, not diary entries. Canonical names follow the
-- original Italian definitions; search and moderation use the regular catalog.
-- Stable IDs and conflict checks preserve prior contributions and moderation.
DO $$
DECLARE seed record; inserted_id uuid;
BEGIN
  FOR seed IN SELECT * FROM (VALUES
    ('6c0b02a2-fd41-5e8d-9d47-0f6504de9d5f'::uuid, '{"name":"Acqua naturale","brand":null,"unit":"ml","servingSizes":[],"isDownloaded":false,"nutritionalValuesPer100g":{"calories":0,"fat":0,"saturatedFat":0,"carbs":0,"sugar":0,"protein":0,"water":100}}'::jsonb, 'Plain still drinking water: 100 ml water per 100 ml.'),
    ('138dcf3b-16cc-560f-85c8-a00680e840df'::uuid, '{"name":"Acqua frizzante","brand":null,"unit":"ml","servingSizes":[],"isDownloaded":false,"nutritionalValuesPer100g":{"calories":0,"fat":0,"saturatedFat":0,"carbs":0,"sugar":0,"protein":0,"water":100}}'::jsonb, 'Plain sparkling drinking water: 100 ml water per 100 ml.'),
    ('9b1e7724-58d8-50e4-985b-922126a1c4c4'::uuid, '{"name":"Cetriolo con buccia, crudo","brand":"USDA SR Legacy · FDC 168409","unit":"g","servingSizes":[],"isDownloaded":false,"nutritionalValuesPer100g":{"calories":15,"fat":0.11,"saturatedFat":0.037,"carbs":3.63,"sugar":1.67,"protein":0.65,"water":95.23}}'::jsonb, 'USDA SR Legacy: https://fdc.nal.usda.gov/food-details/168409/nutrients ; raw with peel; water g approximated as ml.'),
    ('0321e67d-d0ad-54cc-9e88-78de55df428b'::uuid, '{"name":"Pomodoro rosso, crudo","brand":"USDA SR Legacy · FDC 170457","unit":"g","servingSizes":[],"isDownloaded":false,"nutritionalValuesPer100g":{"calories":18,"fat":0.2,"saturatedFat":0.028,"carbs":3.89,"sugar":2.63,"protein":0.88,"water":94.52}}'::jsonb, 'USDA SR Legacy: https://fdc.nal.usda.gov/food-details/170457/nutrients ; red ripe raw; water g approximated as ml.'),
    ('72ea9566-d516-5a90-8270-8dc1ae8618ed'::uuid, '{"name":"Anguria, cruda","brand":"USDA SR Legacy · FDC 167765","unit":"g","servingSizes":[],"isDownloaded":false,"nutritionalValuesPer100g":{"calories":30,"fat":0.15,"saturatedFat":0.016,"carbs":7.55,"sugar":6.2,"protein":0.61,"water":91.45}}'::jsonb, 'USDA SR Legacy: https://fdc.nal.usda.gov/food-details/167765/nutrients ; raw; water g approximated as ml.'),
    ('95df02a8-7821-5d75-8aeb-970bd7662739'::uuid, '{"name":"Mela con buccia, cruda","brand":"USDA SR Legacy · FDC 171688","unit":"g","servingSizes":[],"isDownloaded":false,"nutritionalValuesPer100g":{"calories":52,"fat":0.17,"saturatedFat":0.028,"carbs":13.81,"sugar":10.39,"protein":0.26,"water":85.56}}'::jsonb, 'USDA SR Legacy: https://fdc.nal.usda.gov/food-details/171688/nutrients ; raw with skin; water g approximated as ml.')
  ) AS definitions(id, food, source) LOOP
    inserted_id := NULL;
    INSERT INTO public.food_catalog(id, food)
    VALUES(seed.id, gymbro_food.definition(seed.food))
    ON CONFLICT DO NOTHING
    RETURNING id INTO inserted_id;
    IF inserted_id IS NOT NULL THEN
      INSERT INTO public.food_catalog_audit(food_id, action, note, actor)
      VALUES(inserted_id, 'seed_hydration_food', seed.source, 'migration:20261025200000');
    END IF;
  END LOOP;
END $$;
