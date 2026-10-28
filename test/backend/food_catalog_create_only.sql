BEGIN;
INSERT INTO auth.users(id,email,raw_user_meta_data) VALUES
 ('00000000-0000-0000-0000-000000000850','catalog-create-only@test.invalid','{"username":"catalogcreateonly"}');
SELECT set_config('request.jwt.claim.sub','00000000-0000-0000-0000-000000000850',true);
SET LOCAL ROLE authenticated;
DO $$
DECLARE definition jsonb:='{"name":"Create only fixture","barcode":"0000850","unit":"ml","nutritionalValuesPer100g":{"calories":45,"fat":1,"saturatedFat":0,"carbs":5,"sugar":5,"protein":3}}';
 result jsonb; repeated jsonb; product uuid; changed jsonb; ambiguous jsonb;
BEGIN
 IF public.catalog_food_eligibility(definition)<>'absent' THEN RAISE EXCEPTION 'New product not eligible'; END IF;
 result:=public.create_catalog_food('00000000-0000-0000-0000-000000000851',definition);
 IF result->>'outcome'<>'published' THEN RAISE EXCEPTION 'New product not published'; END IF;
 product:=(result->>'food_id')::uuid;
 repeated:=public.create_catalog_food('00000000-0000-0000-0000-000000000851',definition);
 IF repeated<>result THEN RAISE EXCEPTION 'Publication not idempotent'; END IF;
 IF public.catalog_food_eligibility(definition)<>'present' THEN RAISE EXCEPTION 'Existing product not detected'; END IF;
 changed:=jsonb_set(definition,'{nutritionalValuesPer100g,protein}','4');
 result:=public.create_catalog_food('00000000-0000-0000-0000-000000000852',changed);
 IF result->>'outcome'<>'already_present' THEN RAISE EXCEPTION 'Barcode duplicate proposed correction'; END IF;
 -- Same name/brand without a barcode is deliberately ambiguous.
 ambiguous:=changed-'barcode';
 IF public.catalog_food_eligibility(ambiguous)<>'uncertain' THEN RAISE EXCEPTION 'Ambiguous product was eligible'; END IF;
 result:=public.create_catalog_food('00000000-0000-0000-0000-000000000853',ambiguous);
 IF result->>'outcome'<>'uncertain' THEN RAISE EXCEPTION 'Ambiguous product published'; END IF;
END $$;
RESET ROLE;
DO $$ BEGIN
 IF EXISTS(SELECT 1 FROM public.food_catalog_corrections c JOIN public.food_catalog f ON c.food_id=f.id WHERE f.barcode='0000850') THEN
  RAISE EXCEPTION 'Create-only request inserted a correction'; END IF;
 UPDATE public.food_catalog SET status='suspended' WHERE barcode='0000850';
END $$;
SET LOCAL ROLE authenticated;
DO $$ BEGIN
 IF public.catalog_food_eligibility('{"name":"Create only fixture","barcode":"0000850","unit":"ml","nutritionalValuesPer100g":{"calories":45,"fat":1,"saturatedFat":0,"carbs":5,"sugar":5,"protein":3}}')<>'uncertain' THEN
  RAISE EXCEPTION 'Hidden product existence leaked'; END IF;
END $$;
RESET ROLE;
SET LOCAL ROLE anon;
DO $$ BEGIN
 IF has_function_privilege(current_user,'public.catalog_food_eligibility(jsonb)','EXECUTE')
 OR has_function_privilege(current_user,'public.create_catalog_food(uuid,jsonb)','EXECUTE') THEN
  RAISE EXCEPTION 'Guest can publish or probe eligibility'; END IF;
END $$;
RESET ROLE;
ROLLBACK;
