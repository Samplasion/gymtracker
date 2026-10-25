\set ON_ERROR_STOP on
BEGIN;
DO $$
DECLARE owner uuid:=gen_random_uuid(); other_owner uuid:=gen_random_uuid(); op uuid:=gen_random_uuid(); request jsonb; receipt jsonb; rev bigint; food jsonb;
BEGIN
 INSERT INTO auth.users(id,email,raw_user_meta_data) VALUES(owner,owner::text||'@water.test',jsonb_build_object('username','water_'||left(replace(owner::text,'-',''),20))), (other_owner,other_owner::text||'@water.test',jsonb_build_object('username','water_'||left(replace(other_owner::text,'-',''),20)));
 PERFORM set_config('request.jwt.claim.sub',owner::text,true);
 request:=jsonb_build_array(jsonb_build_object('operation_id',op,'entity','water_logs','record_id','glass','base_revision',0,'payload',jsonb_build_object('id','glass','user_id',owner,'date_added',now(),'reference_date',current_date,'json_data',jsonb_build_object('milliliters',250,'time',now())::text,'updated_at',now(),'deleted',false)));
 receipt:=public.sync_push_v2(request);
 IF receipt->0->>'status'<>'applied' OR public.sync_push_v2(request)<>receipt THEN RAISE EXCEPTION 'Water sync not idempotent'; END IF;
 rev:=(receipt->0->>'revision')::bigint;
 IF NOT EXISTS(SELECT 1 FROM public.sync_changes_v2 WHERE user_id=owner AND entity='water_logs') THEN RAISE EXCEPTION 'Water missing from pull feed'; END IF;
 request:=jsonb_set(request,'{0,operation_id}',to_jsonb(gen_random_uuid()));
 request:=jsonb_set(request,'{0,base_revision}',to_jsonb(rev));
 request:=jsonb_set(request,'{0,payload,deleted}','true');
 receipt:=public.sync_push_v2(request);
 IF receipt->0->>'status'<>'applied' OR NOT (SELECT deleted FROM public.water_logs WHERE user_id=owner AND id='glass') THEN RAISE EXCEPTION 'Water deletion failed'; END IF;
 PERFORM set_config('request.jwt.claim.sub',other_owner::text,true);
 IF EXISTS(SELECT 1 FROM jsonb_array_elements(public.sync_pull_v2()->'changes') c WHERE c->>'entity'='water_logs') THEN RAISE EXCEPTION 'Water leaked across owners'; END IF;
 BEGIN
  PERFORM public.sync_push_v2(jsonb_set(request,'{0,operation_id}',to_jsonb(gen_random_uuid())));
  RAISE EXCEPTION 'Foreign owner accepted' USING ERRCODE='XX000';
 EXCEPTION WHEN insufficient_privilege THEN NULL; END;
 food:='{"name":"Water test cucumber","unit":"g","servingSizes":[],"nutritionalValuesPer100g":{"calories":15,"fat":0.11,"saturatedFat":0.037,"carbs":3.63,"sugar":1.67,"protein":0.65,"water":95.23}}';
 PERFORM gymbro_mcp.validate_food(food);
 IF gymbro_food.definition(food)->'nutritionalValuesPer100g'->>'water'<>'95.23' THEN RAISE EXCEPTION 'Water lost from catalog'; END IF;
END $$;
ROLLBACK;
