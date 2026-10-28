-- Eligibility deliberately reveals only a state, never hidden product data.
CREATE FUNCTION public.catalog_food_eligibility(definition jsonb) RETURNS text
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
DECLARE normalized jsonb; digest text; product public.food_catalog;
BEGIN
 IF auth.uid() IS NULL OR COALESCE(auth.jwt()->>'client_id','')<>'' THEN
  RAISE EXCEPTION 'Login required in Gym Bro' USING ERRCODE='42501';
 END IF;
 normalized:=gymbro_food.definition(definition); digest:=md5(normalized::text);
 SELECT * INTO product FROM public.food_catalog f WHERE f.fingerprint=digest
   OR (normalized->>'barcode' IS NOT NULL AND f.barcode=normalized->>'barcode') LIMIT 1;
 IF FOUND THEN RETURN CASE WHEN product.status='published' THEN 'present' ELSE 'uncertain' END; END IF;
 IF normalized->>'barcode' IS NULL AND EXISTS(
  SELECT 1 FROM public.food_catalog f
  WHERE lower(btrim(f.food->>'name'))=lower(normalized->>'name')
    AND lower(COALESCE(f.food->>'brand',''))=lower(COALESCE(normalized->>'brand',''))
 ) THEN RETURN 'uncertain'; END IF;
 RETURN 'absent';
END $$;

-- The legacy submission path also takes the name lock to serialize ambiguity
-- checks against concurrent legacy clients without changing their behavior.
CREATE OR REPLACE FUNCTION public.submit_catalog_food(operation_id uuid, definition jsonb) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
#variable_conflict use_variable
DECLARE owner uuid:=auth.uid(); normalized jsonb; digest text; previous gymbro_food.receipts;
 product public.food_catalog; correction uuid; correction_status text; result jsonb;
BEGIN
 IF owner IS NULL OR COALESCE(auth.jwt()->>'client_id','')<>'' THEN RAISE EXCEPTION 'Login required in Gym Bro' USING ERRCODE='42501'; END IF;
 IF operation_id IS NULL THEN RAISE EXCEPTION 'Missing operation ID' USING ERRCODE='22023'; END IF;
 normalized:=gymbro_food.definition(definition); digest:=md5(normalized::text);
 PERFORM pg_advisory_xact_lock(hashtextextended(owner::text,1400));
 SELECT * INTO previous FROM gymbro_food.receipts r WHERE r.owner=owner AND r.operation_id=submit_catalog_food.operation_id;
 IF FOUND THEN
  IF previous.fingerprint<>digest THEN RAISE EXCEPTION 'Operation ID reused' USING ERRCODE='22023'; END IF;
  RETURN previous.result;
 END IF;
 IF (SELECT count(*) FROM gymbro_food.receipts r WHERE r.owner=owner AND created_at>now()-interval '1 day')>=20 THEN RAISE EXCEPTION 'Daily submission limit reached' USING ERRCODE='P1005'; END IF;
 PERFORM pg_advisory_xact_lock(hashtextextended(COALESCE(normalized->>'barcode',digest),1401));
 PERFORM pg_advisory_xact_lock(hashtextextended(lower(normalized->>'name')||'|'||lower(COALESCE(normalized->>'brand','')),1402));
 SELECT * INTO product FROM public.food_catalog f WHERE f.fingerprint=digest FOR UPDATE;
 IF FOUND THEN
  result:=jsonb_build_object('outcome',CASE WHEN product.status='published' THEN 'duplicate' ELSE 'unavailable' END,'food_id',product.id);
 ELSE
  SELECT * INTO product FROM public.food_catalog f WHERE f.barcode=normalized->>'barcode' FOR UPDATE;
  IF FOUND THEN
   IF product.status='removed' THEN result:=jsonb_build_object('outcome','unavailable','food_id',product.id);
   ELSE
    INSERT INTO public.food_catalog_corrections(food_id,base_version,base_fingerprint,food)
    VALUES(product.id,product.version,product.fingerprint,normalized)
    ON CONFLICT(food_id,base_version,fingerprint) DO UPDATE SET food=EXCLUDED.food RETURNING id,status INTO correction,correction_status;
    result:=jsonb_build_object('outcome',CASE WHEN correction_status='pending' THEN 'correction' ELSE 'unavailable' END,'food_id',product.id,'correction_id',correction);
   END IF;
  ELSE
   INSERT INTO public.food_catalog(food) VALUES(normalized) RETURNING * INTO product;
   result:=jsonb_build_object('outcome','published','food_id',product.id);
  END IF;
 END IF;
 INSERT INTO gymbro_food.receipts(owner,operation_id,fingerprint,result) VALUES(owner,operation_id,digest,result);
 RETURN result;
END $$;

CREATE FUNCTION public.create_catalog_food(operation_id uuid, definition jsonb) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
#variable_conflict use_variable
DECLARE owner uuid:=auth.uid(); normalized jsonb; digest text; eligibility text;
 previous gymbro_food.receipts; result jsonb;
BEGIN
 IF owner IS NULL OR COALESCE(auth.jwt()->>'client_id','')<>'' THEN
  RAISE EXCEPTION 'Login required in Gym Bro' USING ERRCODE='42501';
 END IF;
 IF operation_id IS NULL THEN RAISE EXCEPTION 'Missing operation ID' USING ERRCODE='22023'; END IF;
 normalized:=gymbro_food.definition(definition); digest:=md5(normalized::text);
 PERFORM pg_advisory_xact_lock(hashtextextended(owner::text,1400));
 SELECT * INTO previous FROM gymbro_food.receipts r WHERE r.owner=owner AND r.operation_id=create_catalog_food.operation_id;
 IF FOUND THEN
  IF previous.fingerprint<>digest THEN RAISE EXCEPTION 'Operation ID reused' USING ERRCODE='22023'; END IF;
  RETURN previous.result;
 END IF;
 IF (SELECT count(*) FROM gymbro_food.receipts r WHERE r.owner=owner AND created_at>now()-interval '1 day')>=20 THEN
  RAISE EXCEPTION 'Daily submission limit reached' USING ERRCODE='P1005';
 END IF;
 PERFORM pg_advisory_xact_lock(hashtextextended(COALESCE(normalized->>'barcode',digest),1401));
 PERFORM pg_advisory_xact_lock(hashtextextended(lower(normalized->>'name')||'|'||lower(COALESCE(normalized->>'brand','')),1402));
 eligibility:=public.catalog_food_eligibility(normalized);
 IF eligibility='absent' THEN RETURN public.submit_catalog_food(operation_id,normalized); END IF;
 result:=jsonb_build_object('outcome',CASE WHEN eligibility='present' THEN 'already_present' ELSE 'uncertain' END);
 INSERT INTO gymbro_food.receipts(owner,operation_id,fingerprint,result) VALUES(owner,operation_id,digest,result);
 RETURN result;
END $$;
REVOKE ALL ON FUNCTION public.catalog_food_eligibility(jsonb),public.create_catalog_food(uuid,jsonb) FROM PUBLIC,anon,authenticated;
GRANT EXECUTE ON FUNCTION public.catalog_food_eligibility(jsonb),public.create_catalog_food(uuid,jsonb) TO authenticated;
