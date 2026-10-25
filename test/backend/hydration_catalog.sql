\set ON_ERROR_STOP on
BEGIN;
CREATE TEMP TABLE expected_hydration_catalog(id uuid, water numeric, unit text);
INSERT INTO expected_hydration_catalog VALUES
    ('6c0b02a2-fd41-5e8d-9d47-0f6504de9d5f'::uuid, 100, 'ml'),
    ('138dcf3b-16cc-560f-85c8-a00680e840df'::uuid, 100, 'ml'),
    ('9b1e7724-58d8-50e4-985b-922126a1c4c4'::uuid, 95.23, 'g'),
    ('0321e67d-d0ad-54cc-9e88-78de55df428b'::uuid, 94.52, 'g'),
    ('72ea9566-d516-5a90-8270-8dc1ae8618ed'::uuid, 91.45, 'g'),
    ('95df02a8-7821-5d75-8aeb-970bd7662739'::uuid, 85.56, 'g');
DO $$ BEGIN
  IF (SELECT count(*) FROM public.food_catalog c JOIN expected_hydration_catalog e USING(id))<>6 THEN RAISE EXCEPTION 'Missing hydration seeds'; END IF;
  IF EXISTS(SELECT 1 FROM public.food_catalog c JOIN expected_hydration_catalog e USING(id)
    WHERE c.status<>'published' OR c.food->>'unit'<>e.unit
    OR (c.food->'nutritionalValuesPer100g'->>'water')::numeric IS DISTINCT FROM e.water
    OR c.food IS DISTINCT FROM gymbro_food.definition(c.food)) THEN RAISE EXCEPTION 'Invalid hydration definitions'; END IF;
  IF (SELECT count(*) FROM public.food_catalog_audit a JOIN expected_hydration_catalog e ON e.id=a.food_id WHERE a.action='seed_hydration_food')<>6 THEN RAISE EXCEPTION 'Seed provenance missing'; END IF;
END $$;
-- A repeated application must not duplicate products/audit entries.
\ir /tmp/hydration_catalog_seed.sql

DO $$ BEGIN
  IF (SELECT count(*) FROM public.food_catalog c JOIN expected_hydration_catalog e USING(id))<>6
    OR (SELECT count(*) FROM public.food_catalog_audit a JOIN expected_hydration_catalog e ON e.id=a.food_id WHERE a.action='seed_hydration_food')<>6 THEN RAISE EXCEPTION 'Hydration seed not idempotent'; END IF;
END $$;
-- Guest clients use exactly the same search RPC as for contributed foods.
SET LOCAL ROLE anon;
DO $$ BEGIN
  IF NOT EXISTS(SELECT 1 FROM public.search_food_catalog('Acqua naturale') WHERE id='6c0b02a2-fd41-5e8d-9d47-0f6504de9d5f')
    OR NOT EXISTS(SELECT 1 FROM public.search_food_catalog('Cetriolo') WHERE id='9b1e7724-58d8-50e4-985b-922126a1c4c4')
    OR NOT EXISTS(SELECT 1 FROM public.search_food_catalog('Anguria') WHERE id='72ea9566-d516-5a90-8270-8dc1ae8618ed') THEN RAISE EXCEPTION 'Seed not searchable'; END IF;
END $$;
RESET ROLE;
UPDATE public.food_catalog SET status='suspended',version=2 WHERE id='6c0b02a2-fd41-5e8d-9d47-0f6504de9d5f';
\ir /tmp/hydration_catalog_seed.sql

DO $$ BEGIN
  IF NOT EXISTS(SELECT 1 FROM public.food_catalog WHERE id='6c0b02a2-fd41-5e8d-9d47-0f6504de9d5f' AND status='suspended' AND version=2) THEN RAISE EXCEPTION 'Seed overwrote moderation'; END IF;
END $$;
ROLLBACK;
