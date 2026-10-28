BEGIN;
-- Attribution is private and survives deletion of the Auth account.
CREATE TABLE gymbro_food.provenance (
 food_id uuid PRIMARY KEY REFERENCES public.food_catalog(id),
 creator_id uuid,
 created_at timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE gymbro_food.provenance ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON gymbro_food.provenance FROM PUBLIC,anon,authenticated;
-- A published receipt at precisely the original insert timestamp is evidence of
-- creation. Duplicate/correction receipts and ambiguous attribution are excluded.
INSERT INTO gymbro_food.provenance(food_id,creator_id)
 SELECT f.id,CASE WHEN count(DISTINCT r.owner)=1 THEN (array_agg(DISTINCT r.owner))[1] END
 FROM public.food_catalog f LEFT JOIN gymbro_food.receipts r
 ON r.result->>'outcome'='published' AND r.result->>'food_id'=f.id::text
 AND r.created_at=f.created_at AND r.fingerprint=f.fingerprint GROUP BY f.id;
CREATE FUNCTION gymbro_food.attribute_creation() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$ BEGIN
 INSERT INTO gymbro_food.provenance(food_id,creator_id) VALUES(NEW.id,auth.uid());
 INSERT INTO public.food_catalog_audit(food_id,action,note,actor)
 VALUES(NEW.id,'create','Creazione articolo',COALESCE(auth.uid()::text,'catalog-api/system'));
 RETURN NEW;
END $$;
CREATE TRIGGER catalog_attribution AFTER INSERT ON public.food_catalog
 FOR EACH ROW EXECUTE FUNCTION gymbro_food.attribute_creation();

CREATE TABLE public.catalog_operator_requests (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), food_id uuid NOT NULL REFERENCES public.food_catalog(id),
 requester_id uuid NOT NULL, kind text NOT NULL CHECK(kind IN ('update','remove')),
 base_version bigint NOT NULL, food jsonb, note text NOT NULL CHECK(length(btrim(note)) BETWEEN 1 AND 1500),
 status text NOT NULL DEFAULT 'pending' CHECK(status IN ('pending','approved','rejected')),
 reviewer_id uuid, review_note text, created_at timestamptz NOT NULL DEFAULT now(), reviewed_at timestamptz,
 CHECK((kind='update' AND food IS NOT NULL) OR (kind='remove' AND food IS NULL))
);
CREATE INDEX catalog_operator_requests_queue ON public.catalog_operator_requests(status,created_at);
CREATE INDEX catalog_operator_requests_owner ON public.catalog_operator_requests(requester_id,created_at DESC,id);
ALTER TABLE public.catalog_operator_requests ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.catalog_operator_requests FROM PUBLIC,anon,authenticated;
GRANT SELECT ON public.catalog_operator_requests TO service_role;
CREATE TABLE gymbro_food.operator_receipts (
 actor uuid NOT NULL, operation_id uuid NOT NULL, fingerprint text NOT NULL, result jsonb NOT NULL,
 PRIMARY KEY(actor,operation_id)
);
ALTER TABLE gymbro_food.operator_receipts ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON gymbro_food.operator_receipts FROM PUBLIC,anon,authenticated;

CREATE FUNCTION gymbro_food.catalog_can_edit(actor uuid, product uuid) RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $$
 SELECT EXISTS(SELECT 1 FROM auth.users a WHERE a.id=actor AND
 (a.raw_app_meta_data->'is_admin'='true'::jsonb OR (
 a.raw_app_meta_data->'is_catalog_operator'='true'::jsonb AND EXISTS(
 SELECT 1 FROM gymbro_food.provenance p LEFT JOIN auth.users creator ON creator.id=p.creator_id
 WHERE p.food_id=product AND (p.creator_id=actor OR (creator.id IS NOT NULL
 AND COALESCE(creator.raw_app_meta_data->'is_admin','false')<>'true'::jsonb
 AND COALESCE(creator.raw_app_meta_data->'is_catalog_operator','false')<>'true'::jsonb))))));
$$;

-- Only the Edge Function can supply the verified actor; app JWTs cannot call this.
CREATE FUNCTION public.catalog_operator_execute(actor uuid, operation text, payload jsonb DEFAULT '{}') RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
#variable_conflict use_variable
DECLARE account auth.users; creator auth.users; product public.food_catalog; request public.catalog_operator_requests;
 normalized jsonb; result jsonb; previous gymbro_food.operator_receipts; operation_id uuid;
 digest text; note text; can_edit boolean; product_id uuid; is_admin boolean; offset_value int;
BEGIN
 SELECT * INTO account FROM auth.users WHERE id=actor FOR SHARE;
 is_admin:=COALESCE(account.raw_app_meta_data->'is_admin'='true'::jsonb,false);
 IF account.id IS NULL OR NOT (is_admin OR COALESCE(account.raw_app_meta_data->'is_catalog_operator'='true'::jsonb,false)) THEN
 RAISE EXCEPTION 'Catalog access denied' USING ERRCODE='42501'; END IF;
 IF operation='session' THEN RETURN jsonb_build_object('id',account.id,'email',account.email,'isAdmin',is_admin); END IF;
 IF operation IN ('list','requests') THEN
 offset_value:=COALESCE((payload->>'offset')::int,0);
 IF offset_value<0 OR length(COALESCE(payload->>'search',''))>200 THEN RAISE EXCEPTION 'Invalid query' USING ERRCODE='22023'; END IF;
 IF operation='requests' THEN
 SELECT COALESCE(jsonb_agg(to_jsonb(t)),'[]') INTO result FROM
 (SELECT r.*,f.food->>'name' AS product_name FROM public.catalog_operator_requests r JOIN public.food_catalog f ON f.id=r.food_id WHERE r.requester_id=actor ORDER BY r.created_at DESC,r.id LIMIT 50 OFFSET offset_value) t;
 ELSE
 SELECT COALESCE(jsonb_agg(to_jsonb(t)),'[]') INTO result FROM
 (SELECT f.id,f.food,f.status,f.version,f.updated_at,(f.status<>'removed' AND gymbro_food.catalog_can_edit(actor,f.id)) AS "canEdit"
 FROM public.food_catalog f WHERE (NULLIF(payload->>'barcode','') IS NULL OR f.barcode=payload->>'barcode') AND (NULLIF(payload->>'search','') IS NULL
 OR f.barcode=payload->>'search' OR (f.food->>'name') ILIKE '%'||(payload->>'search')||'%'
 OR (f.food->>'brand') ILIKE '%'||(payload->>'search')||'%')
 ORDER BY f.updated_at DESC,f.id LIMIT 50 OFFSET offset_value) t;
 END IF;
 RETURN jsonb_build_object('rows',result);
 END IF;
 IF operation='detail' THEN
 SELECT * INTO product FROM public.food_catalog WHERE id=(payload->>'id')::uuid;
 IF NOT FOUND THEN RAISE EXCEPTION 'Not found' USING ERRCODE='P0002'; END IF;
 RETURN to_jsonb(product)||jsonb_build_object('canEdit',product.status<>'removed' AND gymbro_food.catalog_can_edit(actor,product.id));
 END IF;
 IF operation NOT IN ('create','update','remove','propose','review') THEN RAISE EXCEPTION 'Invalid operation' USING ERRCODE='22023'; END IF;
 operation_id:=(payload->>'operationId')::uuid;
 IF operation_id IS NULL THEN RAISE EXCEPTION 'Missing operation ID' USING ERRCODE='22023'; END IF;
 digest:=md5(operation||payload::text);
 PERFORM pg_advisory_xact_lock(hashtextextended(actor::text||operation_id::text,2712));
 SELECT * INTO previous FROM gymbro_food.operator_receipts r WHERE r.actor=actor AND r.operation_id=operation_id;
 IF FOUND THEN
 IF previous.fingerprint<>digest THEN RAISE EXCEPTION 'Operation ID reused' USING ERRCODE='22023'; END IF;
 RETURN previous.result;
 END IF;
 note:=btrim(payload->>'note');
 IF operation<>'create' AND (jsonb_typeof(payload->'note') IS DISTINCT FROM 'string' OR note IS NULL OR length(note) NOT BETWEEN 1 AND 1500) THEN RAISE EXCEPTION 'Reason required' USING ERRCODE='22023'; END IF;
 IF operation IN ('create','update') OR (operation='propose' AND payload->>'kind'='update') THEN
 normalized:=gymbro_food.definition(payload->'food');
 END IF;
 IF operation='create' THEN
 INSERT INTO public.food_catalog(food) VALUES(normalized) RETURNING * INTO product;
 UPDATE gymbro_food.provenance SET creator_id=actor WHERE food_id=product.id;
 -- Replace the trigger's service identity with the verified creator.
 UPDATE public.food_catalog_audit SET actor=actor::text,note='Creazione da catalogo: '||COALESCE(account.email,actor::text)
 WHERE food_id=product.id AND action='create';
 result:=jsonb_build_object('id',product.id,'version',product.version);
 ELSE
 IF operation='review' THEN
 IF NOT is_admin THEN RAISE EXCEPTION 'Admin required' USING ERRCODE='42501'; END IF;
 SELECT * INTO request FROM public.catalog_operator_requests WHERE id=(payload->>'id')::uuid;
 IF NOT FOUND THEN RAISE EXCEPTION 'Not found' USING ERRCODE='P0002'; END IF;
 product_id:=request.food_id;
 ELSE product_id:=(payload->>'id')::uuid; END IF;
 SELECT * INTO product FROM public.food_catalog WHERE id=product_id FOR UPDATE;
 IF NOT FOUND THEN RAISE EXCEPTION 'Not found' USING ERRCODE='P0002'; END IF;
 -- Hold the author's current role stable until this transaction commits.
 SELECT u.* INTO creator FROM auth.users u JOIN gymbro_food.provenance p ON p.creator_id=u.id WHERE p.food_id=product.id FOR SHARE OF u;
 can_edit:=gymbro_food.catalog_can_edit(actor,product.id);
 IF operation='review' THEN
 SELECT * INTO request FROM public.catalog_operator_requests WHERE id=request.id FOR UPDATE;
 IF request.status<>'pending' THEN RAISE EXCEPTION 'Request already reviewed' USING ERRCODE='40001'; END IF;
 IF jsonb_typeof(payload->'approve') IS DISTINCT FROM 'boolean' THEN RAISE EXCEPTION 'Invalid decision' USING ERRCODE='22023'; END IF;
 IF (payload->>'approve')::boolean THEN
 IF product.version<>request.base_version OR product.status='removed' THEN RAISE EXCEPTION 'Stale request' USING ERRCODE='40001'; END IF;
 IF request.kind='update' THEN
 normalized:=gymbro_food.definition(request.food);
 UPDATE public.food_catalog SET food=normalized,version=version+1,updated_at=now() WHERE id=product.id;
 ELSE UPDATE public.food_catalog SET status='removed',version=version+1,updated_at=now() WHERE id=product.id; END IF;
 INSERT INTO public.food_catalog_audit(food_id,action,note,actor) VALUES(product.id,request.kind,'Richiesta approvata '||request.id::text||' · '||COALESCE(account.email,actor::text)||' · '||note,actor::text);
 END IF;
 UPDATE public.catalog_operator_requests SET status=CASE WHEN (payload->>'approve')::boolean THEN 'approved' ELSE 'rejected' END,
 reviewer_id=actor,review_note=note,reviewed_at=now() WHERE id=request.id;
 INSERT INTO public.food_catalog_audit(food_id,action,note,actor) VALUES(product.id,'operator_request_'||CASE WHEN (payload->>'approve')::boolean THEN 'approved' ELSE 'rejected' END,
 request.id::text||' · '||COALESCE(account.email,actor::text)||' · '||note,actor::text);
 result:=jsonb_build_object('id',request.id);
 ELSE
 IF product.version IS DISTINCT FROM (payload->>'version')::bigint OR product.status='removed' THEN RAISE EXCEPTION 'Stale product' USING ERRCODE='40001'; END IF;
 IF operation='propose' THEN
 IF payload->>'kind' IS NULL OR payload->>'kind' NOT IN ('update','remove') THEN RAISE EXCEPTION 'Invalid request kind' USING ERRCODE='22023'; END IF;
 INSERT INTO public.catalog_operator_requests(food_id,requester_id,kind,base_version,food,note)
 VALUES(product.id,actor,payload->>'kind',product.version,normalized,note) RETURNING * INTO request;
 INSERT INTO public.food_catalog_audit(food_id,action,note,actor) VALUES(product.id,'operator_request_'||request.kind,request.id::text||' · '||COALESCE(account.email,actor::text)||' · '||note,actor::text);
 result:=jsonb_build_object('id',request.id,'status','pending');
 ELSE
 IF NOT can_edit THEN RAISE EXCEPTION 'Proposal required' USING ERRCODE='42501'; END IF;
 IF operation='update' THEN UPDATE public.food_catalog SET food=normalized,version=version+1,updated_at=now() WHERE id=product.id;
 ELSE UPDATE public.food_catalog SET status='removed',version=version+1,updated_at=now() WHERE id=product.id; END IF;
 INSERT INTO public.food_catalog_audit(food_id,action,note,actor) VALUES(product.id,operation,COALESCE(account.email,actor::text)||' · '||note,actor::text);
 result:=jsonb_build_object('id',product.id,'version',product.version+1);
 END IF;
 END IF;
 END IF;
 INSERT INTO gymbro_food.operator_receipts(actor,operation_id,fingerprint,result) VALUES(actor,operation_id,digest,result);
 RETURN result;
END $$;
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA gymbro_food FROM PUBLIC,anon,authenticated;
REVOKE ALL ON FUNCTION public.catalog_operator_execute(uuid,text,jsonb) FROM PUBLIC,anon,authenticated;
GRANT EXECUTE ON FUNCTION public.catalog_operator_execute(uuid,text,jsonb) TO service_role;
COMMIT;
