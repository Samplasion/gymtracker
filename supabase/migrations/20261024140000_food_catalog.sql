-- Public product definitions are contributions, not synchronized user records.
CREATE SCHEMA gymbro_food;
REVOKE ALL ON SCHEMA gymbro_food FROM PUBLIC,anon,authenticated;
CREATE TABLE public.food_catalog (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), food jsonb NOT NULL,
 barcode text GENERATED ALWAYS AS (food->>'barcode') STORED,
 fingerprint text GENERATED ALWAYS AS (md5(food::text)) STORED UNIQUE,
 status text NOT NULL DEFAULT 'published' CHECK(status IN ('published','suspended','removed')),
 version bigint NOT NULL DEFAULT 1, report_epoch bigint NOT NULL DEFAULT 1,
 created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
 search_document tsvector GENERATED ALWAYS AS (to_tsvector('simple'::regconfig,(food->>'name')||' '||COALESCE(food->>'brand',''))) STORED
);
CREATE UNIQUE INDEX food_catalog_barcode ON public.food_catalog(barcode) WHERE barcode IS NOT NULL;
CREATE INDEX food_catalog_search ON public.food_catalog USING gin(search_document) WHERE status='published';
CREATE TABLE public.food_catalog_corrections (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), food_id uuid NOT NULL REFERENCES public.food_catalog,
 base_version bigint NOT NULL, base_fingerprint text NOT NULL, food jsonb NOT NULL,
 fingerprint text GENERATED ALWAYS AS (md5(food::text)) STORED,
 status text NOT NULL DEFAULT 'pending' CHECK(status IN ('pending','approved','rejected')),
 created_at timestamptz NOT NULL DEFAULT now(), reviewed_at timestamptz,
 UNIQUE(food_id,base_version,fingerprint)
);
CREATE TABLE public.food_catalog_reports (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), food_id uuid NOT NULL REFERENCES public.food_catalog,
 reporter_id uuid NOT NULL REFERENCES auth.users ON DELETE CASCADE, epoch bigint NOT NULL,
 reason text NOT NULL CHECK(reason IN ('spam','inappropriate','nutrition','product','duplicate','other')),
 details text NOT NULL DEFAULT '' CHECK(length(details)<=2000),
 status text NOT NULL DEFAULT 'open' CHECK(status IN ('open','dismissed','resolved')),
 created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
 UNIQUE(food_id,reporter_id,epoch)
);
CREATE INDEX food_catalog_reports_count ON public.food_catalog_reports(food_id,epoch,reason) WHERE status='open';
CREATE TABLE public.food_catalog_audit (
 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY, food_id uuid NOT NULL REFERENCES public.food_catalog,
 correction_id uuid REFERENCES public.food_catalog_corrections, report_id uuid REFERENCES public.food_catalog_reports ON DELETE SET NULL,
 action text NOT NULL, note text NOT NULL CHECK(length(btrim(note)) BETWEEN 1 AND 2000),
 actor text NOT NULL, created_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE gymbro_food.receipts (
 owner uuid NOT NULL REFERENCES auth.users ON DELETE CASCADE, operation_id uuid NOT NULL,
 fingerprint text NOT NULL, result jsonb NOT NULL, created_at timestamptz NOT NULL DEFAULT now(),
 PRIMARY KEY(owner,operation_id)
);
-- RLS protects every new table, including the server-only operational ledger.
ALTER TABLE public.food_catalog ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.food_catalog_corrections ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.food_catalog_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.food_catalog_audit ENABLE ROW LEVEL SECURITY;
ALTER TABLE gymbro_food.receipts ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.food_catalog,public.food_catalog_corrections,public.food_catalog_reports,public.food_catalog_audit FROM PUBLIC,anon,authenticated;
GRANT SELECT ON public.food_catalog TO anon,authenticated;
GRANT SELECT ON public.food_catalog_reports TO authenticated;
GRANT ALL ON public.food_catalog,public.food_catalog_corrections,public.food_catalog_reports,public.food_catalog_audit TO service_role;
GRANT USAGE,SELECT ON SEQUENCE public.food_catalog_audit_id_seq TO service_role;
CREATE POLICY catalog_published ON public.food_catalog FOR SELECT TO anon,authenticated USING(status='published');
CREATE POLICY catalog_own_reports ON public.food_catalog_reports FOR SELECT TO authenticated USING(reporter_id=auth.uid());

CREATE FUNCTION gymbro_food.nutrient_keys() RETURNS jsonb LANGUAGE sql IMMUTABLE SET search_path='' AS $$ SELECT '["calories", "fat", "saturatedFat", "carbs", "sugar", "protein", "salt", "sodium", "fiber", "addedSugars", "caffeine", "calcium", "iron", "vitaminC", "magnesium", "phosphorus", "potassium", "zinc", "copper", "selenium", "vitaminA", "vitaminE", "vitaminD", "vitaminB1", "vitaminB2", "vitaminPP", "vitaminB6", "vitaminB12", "vitaminB9", "vitaminK", "cholesterol", "butyricAcid", "caproicAcid", "caprylicAcid", "capricAcid", "lauricAcid", "myristicAcid", "palmiticAcid", "stearicAcid", "oleicAcid", "linoleicAcid", "docosahexaenoicAcid", "eicosapentaenoicAcid", "erucicAcid", "monounsaturatedFat", "polyunsaturatedFat", "alcohol", "pantothenicAcid", "biotin", "chloride", "chromium", "fluoride", "iodine", "manganese", "molybdenum", "omega3", "omega6", "omega9", "betaCarotene", "bicarbonate", "sugarAlcohol", "alphaLinolenicAcid", "arachidicAcid", "arachidonicAcid", "behenicAcid", "ceroticAcid", "dihomoGammaLinolenicAcid", "elaidicAcid", "gammaLinolenicAcid", "gondoicAcid", "lignocericAcid", "meadAcid", "melissicAcid", "montanicAcid", "nervonicAcid", "transFat"]'::jsonb $$;

-- Nutritional values always refer to 100 g (unit=g) or 100 ml (unit=ml).
-- The historical JSON key nutritionalValuesPer100g is retained for both units.
-- Strict allow-list: no diary identity, author, quantity, meal, or device data.
CREATE FUNCTION gymbro_food.definition(raw jsonb) RETURNS jsonb
LANGUAGE plpgsql IMMUTABLE SET search_path='' AS $$
#variable_conflict use_variable
DECLARE nutrients jsonb; sizes jsonb; item jsonb; key text; val jsonb; result jsonb;
BEGIN
 IF raw IS NULL OR jsonb_typeof(raw)<>'object' OR octet_length(raw::text)>65536
 OR jsonb_typeof(raw->'name') IS DISTINCT FROM 'string' OR length(btrim(raw->>'name')) NOT BETWEEN 1 AND 500
 OR jsonb_typeof(raw->'nutritionalValuesPer100g') IS DISTINCT FROM 'object'
 OR COALESCE(raw->>'unit','g') NOT IN ('g','ml') THEN RAISE EXCEPTION 'Invalid food definition' USING ERRCODE='22023'; END IF;
 IF EXISTS(SELECT 1 FROM jsonb_object_keys(raw) k WHERE k NOT IN ('name','brand','barcode','unit','servingSizes','nutritionalValuesPer100g','isDownloaded')) THEN
  RAISE EXCEPTION 'Unexpected product metadata' USING ERRCODE='22023'; END IF;
 IF raw ? 'brand' AND raw->'brand'<>'null'::jsonb AND (jsonb_typeof(raw->'brand')<>'string' OR length(raw->>'brand')>300) THEN RAISE EXCEPTION 'Invalid brand' USING ERRCODE='22023'; END IF;
 IF raw ? 'barcode' AND raw->'barcode'<>'null'::jsonb AND (jsonb_typeof(raw->'barcode')<>'string' OR btrim(raw->>'barcode')!~'^[0-9]{4,32}$') THEN RAISE EXCEPTION 'Invalid barcode' USING ERRCODE='22023'; END IF;
 IF COALESCE(raw->'isDownloaded','false')<>'false'::jsonb THEN RAISE EXCEPTION 'Manual submissions cannot claim OFF provenance' USING ERRCODE='22023'; END IF;
 nutrients:=raw->'nutritionalValuesPer100g';
 FOR key,val IN SELECT * FROM jsonb_each(nutrients) LOOP
  IF key NOT IN (SELECT jsonb_array_elements_text(gymbro_food.nutrient_keys())) OR (val<>'null'::jsonb AND (jsonb_typeof(val)<>'number' OR (val#>>'{}')::numeric<0)) THEN RAISE EXCEPTION 'Invalid nutrient' USING ERRCODE='22023'; END IF;
  IF val<>'null'::jsonb THEN nutrients:=jsonb_set(nutrients,ARRAY[key],to_jsonb(trim_scale((val#>>'{}')::numeric))); END IF;
 END LOOP;
 FOREACH key IN ARRAY ARRAY['calories','fat','saturatedFat','carbs','sugar','protein'] LOOP
  IF jsonb_typeof(nutrients->key) IS DISTINCT FROM 'number' THEN RAISE EXCEPTION 'Missing nutrient %',key USING ERRCODE='22023'; END IF;
 END LOOP;
 -- Normalize optional nulls so equivalent clients produce the same fingerprint.
 SELECT jsonb_object_agg(k,COALESCE(nutrients->k,'null')) INTO nutrients FROM jsonb_array_elements_text(gymbro_food.nutrient_keys()) k;
 sizes:=COALESCE(raw->'servingSizes','[]');
 IF jsonb_typeof(sizes)<>'array' OR jsonb_array_length(sizes)>50 THEN RAISE EXCEPTION 'Invalid servings' USING ERRCODE='22023'; END IF;
 FOR item IN SELECT value FROM jsonb_array_elements(sizes) LOOP
  IF jsonb_typeof(item)<>'object' OR jsonb_typeof(item->'amount') IS DISTINCT FROM 'number' OR (item->>'amount')::numeric<=0
   OR EXISTS(SELECT 1 FROM jsonb_object_keys(item) k WHERE k NOT IN ('name','amount'))
   OR (item ? 'name' AND item->'name'<>'null'::jsonb AND (jsonb_typeof(item->'name')<>'string' OR length(item->>'name')>300))
  THEN RAISE EXCEPTION 'Invalid serving' USING ERRCODE='22023'; END IF;
 END LOOP;
 SELECT COALESCE(jsonb_agg(jsonb_build_object('name',NULLIF(btrim(s->>'name'),''),'amount',to_jsonb(trim_scale((s->>'amount')::numeric))) ORDER BY n),'[]') INTO sizes FROM jsonb_array_elements(sizes) WITH ORDINALITY t(s,n);
 result:=jsonb_build_object('name',btrim(raw->>'name'),'brand',NULLIF(btrim(raw->>'brand'),''),'barcode',NULLIF(btrim(raw->>'barcode'),''),
 'unit',COALESCE(raw->>'unit','g'),'isDownloaded',false,'servingSizes',sizes,'nutritionalValuesPer100g',nutrients);
 RETURN result;
END $$;
-- Populated from the app's complete nutrient vocabulary, not just macros.
CREATE FUNCTION public.submit_catalog_food(operation_id uuid, definition jsonb) RETURNS jsonb
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
CREATE FUNCTION public.search_food_catalog(query text DEFAULT '', barcode text DEFAULT NULL, result_limit integer DEFAULT 50, result_offset integer DEFAULT 0)
RETURNS TABLE(id uuid,food jsonb,version bigint) LANGUAGE sql STABLE SET search_path='' AS $$
 WITH tokens AS (
 SELECT string_agg(quote_literal(token)||':*',' & ') expression
 FROM unnest(tsvector_to_array(to_tsvector('simple'::regconfig,left(query,200)))) token
 ), search AS (SELECT to_tsquery('simple'::regconfig,expression) q FROM tokens)
 SELECT f.id,f.food,f.version FROM public.food_catalog f CROSS JOIN search
 WHERE f.status='published' AND CASE WHEN NULLIF(btrim($2),'') IS NOT NULL THEN f.barcode=btrim($2) ELSE f.search_document @@ search.q END
 ORDER BY CASE WHEN $2 IS NULL THEN ts_rank(f.search_document,search.q) END DESC,f.id
 LIMIT greatest(1,least(COALESCE(result_limit,50),100)) OFFSET greatest(0,least(COALESCE(result_offset,0),10000));
$$;
CREATE FUNCTION public.report_catalog_food(food_id uuid, reason text, details text DEFAULT '') RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
#variable_conflict use_variable
DECLARE owner uuid:=auth.uid(); product public.food_catalog; threshold integer;
BEGIN
 IF owner IS NULL OR COALESCE(auth.jwt()->>'client_id','')<>'' THEN RAISE EXCEPTION 'Login required in Gym Bro' USING ERRCODE='42501'; END IF;
 IF reason IS NULL OR reason NOT IN ('spam','inappropriate','nutrition','product','duplicate','other') OR details IS NULL OR length(details)>2000 OR (reason='other' AND length(btrim(details))=0) THEN RAISE EXCEPTION 'Invalid report' USING ERRCODE='22023'; END IF;
 SELECT * INTO product FROM public.food_catalog f WHERE f.id=food_id AND f.status<>'removed' FOR UPDATE;
 IF NOT FOUND THEN RAISE EXCEPTION 'Product unavailable' USING ERRCODE='22023'; END IF;
 INSERT INTO public.food_catalog_reports(food_id,reporter_id,epoch,reason,details)
 VALUES(food_id,owner,product.report_epoch,reason,btrim(details))
 ON CONFLICT ON CONSTRAINT food_catalog_reports_food_id_reporter_id_epoch_key DO UPDATE SET reason=EXCLUDED.reason,details=EXCLUDED.details,updated_at=now()
 WHERE food_catalog_reports.status='open';
 threshold:=CASE WHEN reason IN ('spam','inappropriate') THEN 5 ELSE 10 END;
 IF (SELECT count(*) FROM public.food_catalog_reports r WHERE r.food_id=product.id AND r.epoch=product.report_epoch AND r.reason=report_catalog_food.reason AND r.status='open')>=threshold AND product.status='published' THEN
  UPDATE public.food_catalog SET status='suspended',version=version+1,updated_at=now() WHERE id=product.id;
  INSERT INTO public.food_catalog_audit(food_id,action,note,actor) VALUES(product.id,'auto_suspend','Report threshold reached: '||reason,'system');
 END IF;
END $$;
-- Admin functions are callable by service_role / SQL editor only, never app JWTs.
CREATE FUNCTION public.admin_moderate_catalog_food(food_id uuid, expected_version bigint, action text, note text) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
#variable_conflict use_variable
DECLARE product public.food_catalog;
BEGIN
 IF action IS NULL OR action NOT IN ('suspend','restore','remove') OR note IS NULL OR length(btrim(note)) NOT BETWEEN 1 AND 2000 THEN RAISE EXCEPTION 'Invalid admin action' USING ERRCODE='22023'; END IF;
 SELECT * INTO product FROM public.food_catalog f WHERE f.id=food_id FOR UPDATE;
 IF NOT FOUND OR product.version IS DISTINCT FROM expected_version THEN RAISE EXCEPTION 'Stale product version' USING ERRCODE='40001'; END IF;
 UPDATE public.food_catalog SET status=CASE action WHEN 'suspend' THEN 'suspended' WHEN 'restore' THEN 'published' ELSE 'removed' END,
 version=version+1,report_epoch=report_epoch+CASE WHEN action='restore' THEN 1 ELSE 0 END,updated_at=now() WHERE id=food_id;
 IF action IN ('restore','remove') THEN UPDATE public.food_catalog_reports r SET status='resolved',updated_at=now() WHERE r.food_id=product.id AND r.status='open'; END IF;
 INSERT INTO public.food_catalog_audit(food_id,action,note,actor) VALUES(food_id,action,btrim(note),COALESCE(auth.uid()::text,'service_role/sql_editor'));
END $$;
CREATE FUNCTION public.admin_resolve_catalog_report(report_id uuid, note text) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
#variable_conflict use_variable
DECLARE report public.food_catalog_reports;
BEGIN
 IF note IS NULL OR length(btrim(note)) NOT BETWEEN 1 AND 2000 THEN RAISE EXCEPTION 'A review note is required' USING ERRCODE='22023'; END IF;
 SELECT * INTO report FROM public.food_catalog_reports r WHERE r.id=report_id;
 IF NOT FOUND THEN RAISE EXCEPTION 'Report unavailable' USING ERRCODE='22023'; END IF;
 PERFORM 1 FROM public.food_catalog WHERE id=report.food_id FOR UPDATE;
 UPDATE public.food_catalog_reports SET status='dismissed',updated_at=now() WHERE id=report_id AND status='open';
 IF NOT FOUND THEN RAISE EXCEPTION 'Report already reviewed' USING ERRCODE='40001'; END IF;
 INSERT INTO public.food_catalog_audit(food_id,report_id,action,note,actor) VALUES(report.food_id,report_id,'dismiss_report',btrim(note),COALESCE(auth.uid()::text,'service_role/sql_editor'));
END $$;
CREATE FUNCTION public.admin_review_catalog_correction(correction_id uuid, expected_version bigint, approve boolean, note text) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
#variable_conflict use_variable
DECLARE proposal public.food_catalog_corrections; product public.food_catalog;
BEGIN
 IF approve IS NULL OR note IS NULL OR length(btrim(note)) NOT BETWEEN 1 AND 2000 THEN RAISE EXCEPTION 'Invalid review' USING ERRCODE='22023'; END IF;
 SELECT * INTO proposal FROM public.food_catalog_corrections c WHERE c.id=correction_id;
 IF NOT FOUND THEN RAISE EXCEPTION 'Correction unavailable' USING ERRCODE='22023'; END IF;
 SELECT * INTO product FROM public.food_catalog f WHERE f.id=proposal.food_id FOR UPDATE;
 SELECT * INTO proposal FROM public.food_catalog_corrections c WHERE c.id=correction_id FOR UPDATE;
 IF proposal.status<>'pending' OR product.version IS DISTINCT FROM expected_version OR (approve AND product.fingerprint<>proposal.base_fingerprint) THEN RAISE EXCEPTION 'Stale review' USING ERRCODE='40001'; END IF;
 UPDATE public.food_catalog_corrections SET status=CASE WHEN approve THEN 'approved' ELSE 'rejected' END,reviewed_at=now() WHERE id=correction_id;
 IF approve THEN
  UPDATE public.food_catalog SET food=proposal.food,status='published',version=version+1,report_epoch=report_epoch+1,updated_at=now() WHERE id=product.id;
  UPDATE public.food_catalog_reports r SET status='resolved',updated_at=now() WHERE r.food_id=product.id AND r.status='open';
 END IF;
 INSERT INTO public.food_catalog_audit(food_id,correction_id,action,note,actor) VALUES(product.id,correction_id,CASE WHEN approve THEN 'approve_correction' ELSE 'reject_correction' END,btrim(note),COALESCE(auth.uid()::text,'service_role/sql_editor'));
END $$;
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA gymbro_food FROM PUBLIC,anon,authenticated;
REVOKE ALL ON FUNCTION public.submit_catalog_food(uuid,jsonb),public.report_catalog_food(uuid,text,text),public.search_food_catalog(text,text,integer,integer),public.admin_moderate_catalog_food(uuid,bigint,text,text),public.admin_resolve_catalog_report(uuid,text),public.admin_review_catalog_correction(uuid,bigint,boolean,text) FROM PUBLIC,anon,authenticated;
GRANT EXECUTE ON FUNCTION public.search_food_catalog(text,text,integer,integer) TO anon,authenticated;
GRANT EXECUTE ON FUNCTION public.submit_catalog_food(uuid,jsonb),public.report_catalog_food(uuid,text,text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.admin_moderate_catalog_food(uuid,bigint,text,text),public.admin_resolve_catalog_report(uuid,text),public.admin_review_catalog_correction(uuid,bigint,boolean,text),public.search_food_catalog(text,text,integer,integer) TO service_role;
-- Contributions and admin logs are not personal exports; own reports remain RLS-filtered.
CREATE OR REPLACE FUNCTION public.export_schema_to_json() RETURNS json LANGUAGE plpgsql SET search_path='' AS $$
#variable_conflict use_variable
DECLARE tbl record; result jsonb:='{}'; rows jsonb;
BEGIN
 FOR tbl IN SELECT c.relname AS table_name FROM pg_catalog.pg_class c JOIN pg_catalog.pg_namespace n ON n.oid=c.relnamespace
 WHERE n.nspname='public' AND c.relkind IN ('r','p') AND c.relname NOT LIKE 'boutique_%' AND c.relname NOT IN ('food_catalog','food_catalog_corrections','food_catalog_audit')
 AND has_table_privilege(current_user,c.oid,'SELECT') LOOP
  EXECUTE format('SELECT COALESCE(jsonb_agg(to_jsonb(t)),''[]''::jsonb) FROM public.%I t',tbl.table_name) INTO rows;
  result:=result||jsonb_build_object(tbl.table_name,rows);
 END LOOP;
 RETURN result::json;
END $$;

-- MCP resolves catalog references to complete snapshots; legacy OFF references
-- resolve published catalog barcodes and never initiate external downloads.
CREATE OR REPLACE FUNCTION gymbro_mcp.food(owner uuid, ref jsonb) RETURNS jsonb LANGUAGE plpgsql STABLE SET search_path='' AS $$
DECLARE result jsonb;
BEGIN
 PERFORM gymbro_mcp.object_keys(ref,ARRAY['source','id']); PERFORM gymbro_mcp.text_value(ref->'id',300,true);
 CASE ref->>'source'
 WHEN 'catalog' THEN SELECT food INTO result FROM public.food_catalog WHERE id::text=ref->>'id' AND status='published';
 WHEN 'openfoodfacts' THEN SELECT food INTO result FROM public.food_catalog WHERE barcode=ref->>'id' AND status='published';
 WHEN 'favorite' THEN SELECT f.json_data INTO result FROM public.favorite_foods fav JOIN public.foods f ON f.id=fav.id AND f.user_id=owner WHERE fav.user_id=owner AND NOT fav.deleted AND NOT f.deleted AND f.id=ref->>'id';
 WHEN 'customBarcode' THEN SELECT json_data INTO result FROM public.custom_barcode_foods WHERE user_id=owner AND NOT deleted AND id=ref->>'id';
 ELSE RAISE EXCEPTION 'Invalid food reference' USING ERRCODE='22023'; END CASE;
 RETURN gymbro_mcp.decode_json(result);
END $$;
-- Wrap the latest MCP implementation, preserving its measurement/OAuth work.
ALTER FUNCTION public.mcp_execute(text,jsonb,uuid) RENAME TO mcp_execute_before_food_catalog;
REVOKE ALL ON FUNCTION public.mcp_execute_before_food_catalog(text,jsonb,uuid) FROM PUBLIC,anon,authenticated,gymbro_mcp_user;
CREATE FUNCTION public.mcp_execute(operation text, request jsonb DEFAULT '{}', idempotency_key uuid DEFAULT NULL) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
DECLARE owner uuid:=gymbro_mcp.owner(); items jsonb; cursor_data jsonb; offset_value int:=0; page_limit int:=20; fingerprint text; catalog_query tsquery;
BEGIN
 IF operation<>'search_foods' THEN RETURN public.mcp_execute_before_food_catalog(operation,request,idempotency_key); END IF;
 IF request IS NULL OR jsonb_typeof(request)<>'object' OR octet_length(request::text)>1048576 THEN RAISE EXCEPTION 'Invalid request' USING ERRCODE='22023'; END IF;
 PERFORM gymbro_mcp.object_keys(request,ARRAY['query','source','cursor','limit','language','country']);
 PERFORM gymbro_mcp.text_value(request->'query',200,true);
 IF COALESCE(request->>'source','all') NOT IN ('all','catalog','favorite','customBarcode') THEN RAISE EXCEPTION 'Invalid food source' USING ERRCODE='22023'; END IF;
 IF request ? 'limit' THEN page_limit:=gymbro_mcp.number_value(request->'limit',100,true); END IF;
 IF page_limit IS NULL OR page_limit<1 THEN RAISE EXCEPTION 'Invalid limit' USING ERRCODE='22023'; END IF;
 SELECT to_tsquery('simple'::regconfig,string_agg(quote_literal(token)||':*',' & ')) INTO catalog_query FROM unnest(tsvector_to_array(to_tsvector('simple'::regconfig,request->>'query'))) token;
 fingerprint:=md5('catalog-search-v1'||(request-ARRAY['cursor','limit'])::text);
 IF request ? 'cursor' THEN
  BEGIN cursor_data:=convert_from(decode(request->>'cursor','base64'),'UTF8')::jsonb;
   offset_value:=(cursor_data->>'offset')::int;
   IF cursor_data->>'filter' IS DISTINCT FROM fingerprint OR offset_value IS NULL OR offset_value NOT BETWEEN 0 AND 10000 THEN RAISE EXCEPTION 'Invalid cursor'; END IF;
  EXCEPTION WHEN OTHERS THEN RAISE EXCEPTION 'Invalid cursor' USING ERRCODE='22023'; END;
 END IF;
 SELECT COALESCE(jsonb_agg(to_jsonb(t)),'[]') INTO items FROM (
  SELECT jsonb_build_object('source',source,'id',id) AS reference,food FROM (
   SELECT 'favorite' AS source,f.id,gymbro_mcp.decode_json(f.json_data) AS food FROM public.favorite_foods fav JOIN public.foods f ON f.user_id=owner AND f.id=fav.id AND NOT f.deleted WHERE fav.user_id=owner AND NOT fav.deleted AND COALESCE(request->>'source','all') IN ('all','favorite')
   UNION ALL SELECT 'customBarcode',id,gymbro_mcp.decode_json(json_data) FROM public.custom_barcode_foods WHERE user_id=owner AND NOT deleted AND COALESCE(request->>'source','all') IN ('all','customBarcode')
   UNION ALL SELECT 'catalog',id::text,food FROM public.food_catalog WHERE status='published' AND search_document @@ catalog_query AND COALESCE(request->>'source','all') IN ('all','catalog')
  ) foods WHERE source='catalog' OR position(lower(request->>'query') IN lower(COALESCE(food->>'name','')||' '||COALESCE(food->>'brand','')))>0
  ORDER BY source,id OFFSET offset_value LIMIT page_limit+1) t;
 RETURN jsonb_build_object('items',(SELECT COALESCE(jsonb_agg(value),'[]') FROM jsonb_array_elements(items) WITH ORDINALITY t(value,n) WHERE n<=page_limit),
 'nextCursor',CASE WHEN jsonb_array_length(items)>page_limit THEN encode(convert_to(jsonb_build_object('offset',offset_value+page_limit,'filter',fingerprint)::text,'UTF8'),'base64') ELSE NULL END);
END $$;
REVOKE ALL ON FUNCTION public.mcp_execute(text,jsonb,uuid) FROM PUBLIC,anon,authenticated;
GRANT EXECUTE ON FUNCTION public.mcp_execute(text,jsonb,uuid) TO gymbro_mcp_user;
