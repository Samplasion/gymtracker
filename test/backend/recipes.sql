\set ON_ERROR_STOP on
BEGIN;
DO $$
DECLARE owner uuid:=gen_random_uuid(); other_owner uuid:=gen_random_uuid();
 request jsonb; receipt jsonb; rev bigint; definition jsonb;
BEGIN
 INSERT INTO auth.users(id,email,raw_user_meta_data)
 VALUES(owner,owner::text||'@recipes.test',jsonb_build_object('username','recipe_'||left(replace(owner::text,'-',''),20))),
 (other_owner,other_owner::text||'@recipes.test',jsonb_build_object('username','recipe_'||left(replace(other_owner::text,'-',''),20)));
 PERFORM set_config('request.jwt.claim.sub',owner::text,true);
 definition:='{"id":"meal","name":"Rice bowl","description":"[{\"insert\":\"Meal\\n\"}]","instructions":"[{\"insert\":\"Cook\\n\"}]","servings":2,"ingredients":[{"food":{"name":"Rice","amount":100,"pieces":1,"unit":"g","servingSizes":[],"nutritionalValuesPer100g":{"calories":100,"fat":0,"saturatedFat":0,"carbs":20,"sugar":0,"protein":5}}}]}';
 request:=jsonb_build_array(jsonb_build_object('operation_id',gen_random_uuid(),'entity','recipes','record_id','meal','base_revision',0,
 'payload',jsonb_build_object('id','meal','user_id',owner,'json_data',definition::text,'updated_at',now(),'deleted',false)));
 receipt:=public.sync_push_v2(request);
 IF receipt->0->>'status'<>'applied' OR public.sync_push_v2(request)<>receipt THEN RAISE EXCEPTION 'Recipe sync not idempotent'; END IF;
 IF NOT EXISTS(SELECT 1 FROM jsonb_array_elements(public.sync_pull_v2()->'changes') c WHERE c->>'entity'='recipes') THEN RAISE EXCEPTION 'Recipe missing from pull feed'; END IF;
 IF (SELECT json_data::jsonb FROM public.recipes WHERE user_id=owner AND id='meal')<>definition THEN RAISE EXCEPTION 'Recipe JSON changed'; END IF;
 rev:=(receipt->0->>'revision')::bigint;
 -- Invalid serving counts must not change the stored definition.
 request:=jsonb_set(request,'{0,operation_id}',to_jsonb(gen_random_uuid()));
 request:=jsonb_set(request,'{0,base_revision}',to_jsonb(rev));
 request:=jsonb_set(request,'{0,payload,json_data}',to_jsonb(jsonb_set(definition,'{servings}','33')::text));
 IF public.sync_push_v2(request)->0->>'status'<>'error' THEN RAISE EXCEPTION 'Invalid recipe accepted'; END IF;
 request:=jsonb_set(request,'{0,operation_id}',to_jsonb(gen_random_uuid()));
 request:=jsonb_set(request,'{0,payload,json_data}',to_jsonb(definition::text));
 request:=jsonb_set(request,'{0,payload,deleted}','true');
 receipt:=public.sync_push_v2(request);
 IF receipt->0->>'status'<>'applied' OR NOT (SELECT deleted FROM public.recipes WHERE user_id=owner AND id='meal') THEN RAISE EXCEPTION 'Recipe deletion failed'; END IF;
 PERFORM set_config('request.jwt.claim.sub',other_owner::text,true);
 IF EXISTS(SELECT 1 FROM jsonb_array_elements(public.sync_pull_v2()->'changes') c WHERE c->>'entity'='recipes') THEN RAISE EXCEPTION 'Recipe leaked across owners'; END IF;
 BEGIN
  PERFORM public.sync_push_v2(jsonb_set(request,'{0,operation_id}',to_jsonb(gen_random_uuid())));
  RAISE EXCEPTION 'Foreign recipe owner accepted' USING ERRCODE='XX000';
 EXCEPTION WHEN insufficient_privilege THEN NULL; END;
 IF has_table_privilege('authenticated','public.recipes','INSERT') OR has_table_privilege('anon','public.recipes','SELECT') THEN RAISE EXCEPTION 'Direct recipe access granted'; END IF;
END $$;
ROLLBACK;
