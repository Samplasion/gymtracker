-- Disposable database only; every test write is rolled back.
\set ON_ERROR_STOP on
BEGIN;
DO $$
#variable_conflict use_variable
DECLARE owner uuid:=gen_random_uuid(); reporter uuid; request jsonb; first_result jsonb; proposal jsonb; published jsonb;
 mcp_result jsonb; logged_food jsonb;
 initial_catalog_count bigint; product uuid; correction uuid; op uuid:=gen_random_uuid(); i int; v bigint;
BEGIN
 SELECT count(*) INTO initial_catalog_count FROM public.food_catalog;
 IF EXISTS(SELECT 1 FROM public.food_catalog c WHERE NOT EXISTS(SELECT 1 FROM public.food_catalog_audit a WHERE a.food_id=c.id AND a.action='seed_hydration_food')) THEN RAISE EXCEPTION 'Unexpected catalog rows: no diary backfill'; END IF;
 INSERT INTO auth.users(id,email,raw_user_meta_data) VALUES(owner,owner::text||'@catalog.test',jsonb_build_object('username','fc_'||left(replace(owner::text,'-',''),24)));
 PERFORM set_config('request.jwt.claim.sub',owner::text,true);
 PERFORM set_config('request.jwt.claims','{}',true);
 request:='{"name":"Catalog Latte","brand":"Test Brand","barcode":"00123456","unit":"ml","isDownloaded":false,"servingSizes":[{"name":"Glass","amount":200}],"nutritionalValuesPer100g":{"calories":45,"fat":1,"saturatedFat":0,"carbs":5,"sugar":5,"protein":3,"calcium":120}}';
 first_result:=public.submit_catalog_food(op,request); product:=(first_result->>'food_id')::uuid;
 IF first_result->>'outcome'<>'published' OR public.submit_catalog_food(op,request)<>first_result THEN RAISE EXCEPTION 'Publication/retry failed'; END IF;
 IF public.submit_catalog_food(gen_random_uuid(),jsonb_set(request,'{nutritionalValuesPer100g,fat}','1.0'))->>'outcome'<>'duplicate' OR (SELECT count(*) FROM public.food_catalog)<>initial_catalog_count+1 THEN RAISE EXCEPTION 'Definition dedup failed'; END IF;
 BEGIN PERFORM public.submit_catalog_food(op,request||'{"name":"Other"}'); RAISE EXCEPTION 'Operation reuse accepted' USING ERRCODE='XX000'; EXCEPTION WHEN invalid_parameter_value THEN NULL; END;
 BEGIN PERFORM public.submit_catalog_food(gen_random_uuid(),request||jsonb_build_object('user_id',owner)); RAISE EXCEPTION 'User metadata accepted' USING ERRCODE='XX000'; EXCEPTION WHEN invalid_parameter_value THEN NULL; END;
 BEGIN PERFORM public.submit_catalog_food(gen_random_uuid(),request||'{"isDownloaded":true}'); RAISE EXCEPTION 'Invented provenance accepted' USING ERRCODE='XX000'; EXCEPTION WHEN invalid_parameter_value THEN NULL; END;
 SELECT food INTO published FROM public.food_catalog WHERE id=product;
 IF published ?| ARRAY['id','amount','category','pieces','user_id','owner'] OR published->'nutritionalValuesPer100g'->>'calcium'<>'120' OR published->'servingSizes'<>request->'servingSizes' THEN RAISE EXCEPTION 'Snapshot incomplete or personal metadata leaked'; END IF;
 IF NOT EXISTS(SELECT 1 FROM public.search_food_catalog('cat lat test br') WHERE id=product) OR NOT EXISTS(SELECT 1 FROM public.search_food_catalog(barcode=>'00123456') WHERE id=product) THEN RAISE EXCEPTION 'Text/barcode search failed'; END IF;
 IF EXISTS(SELECT 1 FROM public.search_food_catalog('!!!')) THEN RAISE EXCEPTION 'Empty token search failed'; END IF;
 -- A different barcode definition proposes a correction, without modifying published food.
 proposal:=public.submit_catalog_food(gen_random_uuid(),jsonb_set(request,'{nutritionalValuesPer100g,protein}','4'));
 correction:=(proposal->>'correction_id')::uuid;
 IF proposal->>'outcome'<>'correction' OR (SELECT food FROM public.food_catalog WHERE id=product)<>published THEN RAISE EXCEPTION 'Correction overwrote published food'; END IF;
 -- Rejected identical proposals must not be presented as a fresh pending review.
 proposal:=public.submit_catalog_food(gen_random_uuid(),jsonb_set(request,'{nutritionalValuesPer100g,protein}','6'));
 PERFORM public.admin_review_catalog_correction((proposal->>'correction_id')::uuid,1,false,'Rejected after label check');
 IF public.submit_catalog_food(gen_random_uuid(),jsonb_set(request,'{nutritionalValuesPer100g,protein}','6'))->>'outcome'<>'unavailable' THEN RAISE EXCEPTION 'Rejected proposal was reopened'; END IF;
 -- Catalog MCP references resolve to full diary snapshots without external services.
 PERFORM public.test_mcp_oauth(owner);
 INSERT INTO gymbro_mcp.settings(singleton,client_id,resource) VALUES(true,'00000000-0000-0000-0000-000000000090','https://gym-bro.test/mcp')
 ON CONFLICT(singleton) DO UPDATE SET client_id=EXCLUDED.client_id,resource=EXCLUDED.resource;
 INSERT INTO gymbro_mcp.billing VALUES(owner,true,NULL,now(),'PRODUCTION');
 PERFORM set_config('request.jwt.claims',jsonb_build_object('sub',owner,'session_id',owner,'role','gymbro_mcp_user','client_id','00000000-0000-0000-0000-000000000090','aud',jsonb_build_array('https://gym-bro.test/mcp'))::text,true);
 mcp_result:=public.mcp_execute('search_foods','{"query":"Catalog","source":"catalog"}');
 IF mcp_result->'items'->0->'reference'->>'id'<>product::text THEN RAISE EXCEPTION 'MCP catalog search failed'; END IF;
 mcp_result:=public.mcp_execute('log_foods',jsonb_build_object('entries',jsonb_build_array(jsonb_build_object('date',(now() AT TIME ZONE 'UTC')::date::text,'amount',125,'pieces',2,'foodRef',jsonb_build_object('source','catalog','id',product)))),gen_random_uuid());
 logged_food:=mcp_result->'items'->0->'food';
 IF logged_food->'nutritionalValuesPer100g'<>published->'nutritionalValuesPer100g' OR logged_food->'servingSizes'<>published->'servingSizes' OR logged_food->>'amount'<>'125' OR logged_food->>'pieces'<>'2' OR (SELECT count(*) FROM public.food_catalog)<>initial_catalog_count+1 THEN RAISE EXCEPTION 'MCP snapshot incomplete or diary triggered a new contribution'; END IF;
 PERFORM set_config('request.jwt.claims','{}',true);
 -- Reports change category, rather than counting twice.
 PERFORM public.report_catalog_food(product,'nutrition','Wrong protein');
 PERFORM public.report_catalog_food(product,'spam','Changed reason');
 IF (SELECT count(*) FROM public.food_catalog_reports WHERE food_id=product AND reporter_id=owner)<>1 THEN RAISE EXCEPTION 'Repeated reporter counted twice'; END IF;
 BEGIN PERFORM public.report_catalog_food(product,'other','  '); RAISE EXCEPTION 'Empty other report accepted' USING ERRCODE='XX000'; EXCEPTION WHEN invalid_parameter_value THEN NULL; END;
 FOR i IN 1..4 LOOP
  reporter:=gen_random_uuid();
  INSERT INTO auth.users(id,email,raw_user_meta_data) VALUES(reporter,reporter::text||'@catalog.test',jsonb_build_object('username','fc_'||left(replace(reporter::text,'-',''),24)));
  PERFORM set_config('request.jwt.claim.sub',reporter::text,true);
  PERFORM public.report_catalog_food(product,'spam','Spam');
  IF i<4 AND (SELECT status FROM public.food_catalog WHERE id=product)<>'published' THEN RAISE EXCEPTION 'Suspended too early'; END IF;
 END LOOP;
 IF (SELECT status FROM public.food_catalog WHERE id=product)<>'suspended' OR EXISTS(SELECT 1 FROM public.search_food_catalog(barcode=>'00123456')) THEN RAISE EXCEPTION 'Spam threshold/visibility failed'; END IF;
 SELECT version INTO v FROM public.food_catalog WHERE id=product;
 BEGIN PERFORM public.admin_moderate_catalog_food(product,v-1,'restore','Stale'); RAISE EXCEPTION 'Stale admin write accepted' USING ERRCODE='XX000'; EXCEPTION WHEN serialization_failure THEN NULL; END;
 PERFORM public.admin_moderate_catalog_food(product,v,'restore','Reviewed reports');
 PERFORM public.report_catalog_food(product,'nutrition','New epoch');
 IF (SELECT status FROM public.food_catalog WHERE id=product)<>'published' THEN RAISE EXCEPTION 'Reviewed reports re-suspended product'; END IF;
 -- Nutrition category needs ten distinct reporters; mixed categories do not add up.
 FOR i IN 1..9 LOOP
  reporter:=gen_random_uuid();
  INSERT INTO auth.users(id,email,raw_user_meta_data) VALUES(reporter,reporter::text||'@catalog.test',jsonb_build_object('username','fc_'||left(replace(reporter::text,'-',''),24)));
  PERFORM set_config('request.jwt.claim.sub',reporter::text,true);
  PERFORM public.report_catalog_food(product,'nutrition','Wrong values');
  IF i<9 AND (SELECT status FROM public.food_catalog WHERE id=product)<>'published' THEN RAISE EXCEPTION 'Nutrition suspended before ten'; END IF;
 END LOOP;
 IF (SELECT status FROM public.food_catalog WHERE id=product)<>'suspended' THEN RAISE EXCEPTION 'Nutrition threshold failed'; END IF;
 -- Removing the contributor must not remove products or proposals.
 DELETE FROM auth.users WHERE id=owner;
 IF NOT EXISTS(SELECT 1 FROM public.food_catalog WHERE id=product) OR NOT EXISTS(SELECT 1 FROM public.food_catalog_corrections WHERE id=correction) OR EXISTS(SELECT 1 FROM gymbro_food.receipts WHERE receipts.owner=owner) THEN RAISE EXCEPTION 'Account deletion broke contribution independence'; END IF;
 SELECT version INTO v FROM public.food_catalog WHERE id=product;
 PERFORM public.admin_review_catalog_correction(correction,v,true,'Checked label');
 IF (SELECT food->'nutritionalValuesPer100g'->>'protein' FROM public.food_catalog WHERE id=product)<>'4' OR published->'nutritionalValuesPer100g'->>'protein'<>'3' THEN RAISE EXCEPTION 'Correction or independent snapshot failed'; END IF;
 BEGIN PERFORM public.admin_review_catalog_correction(correction,v,true,'Repeated'); RAISE EXCEPTION 'Repeated approval accepted' USING ERRCODE='XX000'; EXCEPTION WHEN serialization_failure THEN NULL; END;
 BEGIN PERFORM public.admin_resolve_catalog_report((SELECT id FROM public.food_catalog_reports WHERE food_id=product LIMIT 1),'Already reviewed'); RAISE EXCEPTION 'Resolved report was reviewed twice' USING ERRCODE='XX000'; EXCEPTION WHEN serialization_failure THEN NULL; END;
END $$;
-- Guest search is allowed, but direct writes and admin actions are not.
SET LOCAL ROLE anon;
DO $$ BEGIN
 IF NOT EXISTS(SELECT 1 FROM public.search_food_catalog('Catalog')) THEN RAISE EXCEPTION 'Guest search failed'; END IF;
 IF has_function_privilege(current_user,'public.submit_catalog_food(uuid,jsonb)','EXECUTE') OR has_function_privilege(current_user,'public.admin_moderate_catalog_food(uuid,bigint,text,text)','EXECUTE') THEN RAISE EXCEPTION 'Guest can publish/moderate'; END IF;
END $$;
RESET ROLE;
SET LOCAL ROLE authenticated;
DO $$ BEGIN
 IF has_table_privilege(current_user,'public.food_catalog','INSERT') OR has_table_privilege(current_user,'public.food_catalog_corrections','UPDATE') OR has_function_privilege(current_user,'public.admin_review_catalog_correction(uuid,bigint,boolean,text)','EXECUTE') THEN RAISE EXCEPTION 'Client moderation bypass'; END IF;
 IF public.export_schema_to_json()::jsonb ?| ARRAY['food_catalog','food_catalog_corrections','food_catalog_audit'] THEN RAISE EXCEPTION 'Catalog in personal export'; END IF;
END $$;
RESET ROLE;
ROLLBACK;
