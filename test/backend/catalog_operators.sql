BEGIN;
INSERT INTO auth.users(id,email,raw_app_meta_data) VALUES
 ('00000000-0000-0000-0000-000000000871','admin@test.invalid','{"is_admin":true}'),
 ('00000000-0000-0000-0000-000000000872','operator@test.invalid','{"is_catalog_operator":true}'),
 ('00000000-0000-0000-0000-000000000873','other@test.invalid','{"is_catalog_operator":true}'),
 ('00000000-0000-0000-0000-000000000874','user@test.invalid','{}');
DO $$
DECLARE a uuid:='00000000-0000-0000-0000-000000000871'; o uuid:='00000000-0000-0000-0000-000000000872';
 other uuid:='00000000-0000-0000-0000-000000000873'; ordinary uuid:='00000000-0000-0000-0000-000000000874';
 f jsonb:='{"name":"Operator test","barcode":"0000872","nutritionalValuesPer100g":{"calories":10,"fat":1,"saturatedFat":0,"carbs":1,"sugar":0,"protein":1}}';
 result jsonb; product uuid; request uuid; op uuid:=gen_random_uuid(); cmd jsonb; n bigint; personal uuid; unknown uuid;
BEGIN
 cmd:=jsonb_build_object('operationId',op,'food',f);
 result:=public.catalog_operator_execute(o,'create',cmd); product:=(result->>'id')::uuid;
 IF public.catalog_operator_execute(o,'create',cmd)<>result THEN RAISE EXCEPTION 'Idempotency failed'; END IF;
 BEGIN PERFORM public.catalog_operator_execute(o,'create',jsonb_set(cmd,'{food,name}','"Different payload"')); RAISE EXCEPTION 'Operation ID reused with different data'; EXCEPTION WHEN invalid_parameter_value THEN NULL; END;
 IF (public.catalog_operator_execute(other,'detail',jsonb_build_object('id',product))->>'canEdit')::boolean THEN RAISE EXCEPTION 'Detail exposes wrong permissions'; END IF;
 IF NOT gymbro_food.catalog_can_edit(o,product) OR NOT gymbro_food.catalog_can_edit(a,product) OR gymbro_food.catalog_can_edit(other,product) THEN RAISE EXCEPTION 'Initial permission matrix failed'; END IF;
 IF NOT EXISTS(SELECT 1 FROM gymbro_food.provenance WHERE food_id=product AND creator_id=o) THEN RAISE EXCEPTION 'Missing provenance'; END IF;
 BEGIN PERFORM public.catalog_operator_execute(ordinary,'session'); RAISE EXCEPTION 'Ordinary account gained access'; EXCEPTION WHEN insufficient_privilege THEN NULL; END;
 BEGIN PERFORM public.catalog_operator_execute(other,'update',jsonb_build_object('id',product,'version',1,'operationId',gen_random_uuid(),'food',f,'note','forged direct edit')); RAISE EXCEPTION 'Other operator edited directly'; EXCEPTION WHEN insufficient_privilege THEN NULL; END;
 BEGIN PERFORM public.catalog_operator_execute(other,'remove',jsonb_build_object('id',product,'version',1,'operationId',gen_random_uuid(),'note','forged removal')); RAISE EXCEPTION 'Other operator removed directly'; EXCEPTION WHEN insufficient_privilege THEN NULL; END;
 result:=public.catalog_operator_execute(other,'propose',jsonb_build_object('id',product,'version',1,'kind','update','operationId',gen_random_uuid(),'food',jsonb_set(f,'{name}','"Reviewed title"'),'note','fix title'));
 request:=(result->>'id')::uuid;
 IF jsonb_array_length(public.catalog_operator_execute(o,'requests')->'rows')<>0 OR jsonb_array_length(public.catalog_operator_execute(other,'requests')->'rows')<>1 THEN RAISE EXCEPTION 'Own request isolation failed'; END IF;
 IF (SELECT version FROM public.food_catalog WHERE id=product)<>1 THEN RAISE EXCEPTION 'Proposal changed product'; END IF;
 BEGIN PERFORM public.catalog_operator_execute(other,'review',jsonb_build_object('id',request,'approve',true,'operationId',gen_random_uuid(),'note','approve own proposal')); RAISE EXCEPTION 'Operator reviewed proposal'; EXCEPTION WHEN insufficient_privilege THEN NULL; END;
 PERFORM public.catalog_operator_execute(a,'review',jsonb_build_object('id',request,'approve',true,'operationId',gen_random_uuid(),'note','checked label'));
 IF (SELECT food->>'name' FROM public.food_catalog WHERE id=product)<>'Reviewed title' OR (SELECT creator_id FROM gymbro_food.provenance WHERE food_id=product)<>o THEN RAISE EXCEPTION 'Review or provenance failed'; END IF;
 BEGIN PERFORM public.catalog_operator_execute(o,'remove',jsonb_build_object('id',product,'version',1,'operationId',gen_random_uuid(),'note','stale version')); RAISE EXCEPTION 'Stale write succeeded'; EXCEPTION WHEN serialization_failure THEN NULL; END;
 result:=public.catalog_operator_execute(other,'propose',jsonb_build_object('id',product,'version',2,'kind','remove','operationId',gen_random_uuid(),'note','remove duplicate')); request:=(result->>'id')::uuid;
 PERFORM public.catalog_operator_execute(o,'update',jsonb_build_object('id',product,'version',2,'operationId',gen_random_uuid(),'food',jsonb_set(f,'{name}','"Newer title"'),'note','new title'));
 BEGIN PERFORM public.catalog_operator_execute(a,'review',jsonb_build_object('id',request,'approve',true,'operationId',gen_random_uuid(),'note','stale approval')); RAISE EXCEPTION 'Stale proposal applied'; EXCEPTION WHEN serialization_failure THEN NULL; END;
 PERFORM public.catalog_operator_execute(a,'review',jsonb_build_object('id',request,'approve',false,'operationId',gen_random_uuid(),'note','please resubmit'));
 -- Current author role determines protection, without transferring attribution.
 UPDATE auth.users SET raw_app_meta_data='{}' WHERE id=o;
 IF NOT gymbro_food.catalog_can_edit(other,product) THEN RAISE EXCEPTION 'Demotion not reflected'; END IF;
 UPDATE auth.users SET raw_app_meta_data='{"is_catalog_operator":true}' WHERE id=o;
 IF gymbro_food.catalog_can_edit(other,product) THEN RAISE EXCEPTION 'Promotion not reflected'; END IF;
 -- Ordinary Gym Bro submissions receive immutable attribution too.
 PERFORM set_config('request.jwt.claim.sub',ordinary::text,true);
 result:=public.submit_catalog_food(gen_random_uuid(),jsonb_set(f,'{barcode}','"0000874"'));
 personal:=(result->>'food_id')::uuid;
 IF NOT gymbro_food.catalog_can_edit(o,personal) OR (SELECT creator_id FROM gymbro_food.provenance WHERE food_id=personal)<>ordinary THEN RAISE EXCEPTION 'User submission attribution failed'; END IF;
 PERFORM set_config('request.jwt.claim.sub','',true);
 INSERT INTO public.food_catalog(food) VALUES(gymbro_food.definition(jsonb_set(f,'{barcode}','"0000875"'))) RETURNING id INTO unknown;
 IF gymbro_food.catalog_can_edit(o,unknown) OR NOT gymbro_food.catalog_can_edit(a,unknown) THEN RAISE EXCEPTION 'Unknown author policy failed'; END IF;
 DELETE FROM auth.users WHERE id=ordinary;
 IF gymbro_food.catalog_can_edit(o,personal) OR (SELECT creator_id FROM gymbro_food.provenance WHERE food_id=personal)<>ordinary THEN RAISE EXCEPTION 'Orphan policy or preservation failed'; END IF;
 BEGIN PERFORM public.catalog_operator_execute(o,'create',jsonb_build_object('operationId',gen_random_uuid(),'food',f)); RAISE EXCEPTION 'Duplicate barcode allowed'; EXCEPTION WHEN unique_violation THEN NULL; END;
 PERFORM public.catalog_operator_execute(o,'remove',jsonb_build_object('id',product,'version',3,'operationId',gen_random_uuid(),'note','cleanup'));
 IF (SELECT status FROM public.food_catalog WHERE id=product)<>'removed' OR NOT EXISTS(SELECT 1 FROM public.food_catalog_audit WHERE food_id=product AND action='remove' AND actor=o::text) THEN RAISE EXCEPTION 'Soft removal or audit failed'; END IF;
 IF has_function_privilege('authenticated','public.catalog_operator_execute(uuid,text,jsonb)','EXECUTE') OR has_function_privilege('anon','public.catalog_operator_execute(uuid,text,jsonb)','EXECUTE') THEN RAISE EXCEPTION 'Client JWT can forge actor'; END IF;
END $$;
ROLLBACK;
