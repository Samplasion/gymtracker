BEGIN;

-- Removing a folder must clear its reference, never the routine owner's ID.
ALTER TABLE public.routines DROP CONSTRAINT routines_folder_fk;
ALTER TABLE public.routines ADD CONSTRAINT routines_folder_fk
 FOREIGN KEY(folder_id,user_id) REFERENCES public.routine_folders(id,user_id)
 ON DELETE SET NULL(folder_id);

-- The folder identity belongs to the plan, not to an editable document.
ALTER TABLE gymbro_trainer.plans ADD COLUMN folder_id uuid NOT NULL DEFAULT gen_random_uuid();
CREATE FUNCTION gymbro_trainer.plan_document(doc jsonb, folder uuid, title text) RETURNS jsonb
LANGUAGE plpgsql SET search_path='' AS $$
BEGIN
 IF jsonb_typeof(doc->'routines') IS DISTINCT FROM 'array' THEN RAISE EXCEPTION 'invalid_document' USING ERRCODE='22023'; END IF;
 IF COALESCE(trim(title),'')='' THEN RAISE EXCEPTION 'invalid_plan_name' USING ERRCODE='22023'; END IF;
 RETURN jsonb_set(jsonb_set(doc,'{folders}',jsonb_build_array(jsonb_build_object('id',folder,'name',trim(title),'notes','','sort_order',0))),'{routines}',
   COALESCE((SELECT jsonb_agg(jsonb_set(r,'{folder_id}',to_jsonb(folder::text)) ORDER BY position) FROM jsonb_array_elements(doc->'routines') WITH ORDINALITY rows(r,position)),'[]'::jsonb));
END $$;

-- Canonicalize drafts and existing accepted content without deleting old user
-- folders or rewriting any immutable published revision.
UPDATE gymbro_trainer.plans SET draft=gymbro_trainer.plan_document(draft,folder_id,name);
UPDATE gymbro_trainer.templates SET document=gymbro_trainer.plan_document(document,id,name);
DO $$
DECLARE p record;
BEGIN
 FOR p IN SELECT plan.*,link.client_id FROM gymbro_trainer.plans plan JOIN gymbro_trainer.links link ON link.id=plan.link_id WHERE EXISTS(SELECT 1 FROM gymbro_trainer.controls c WHERE c.plan_id=plan.id) ORDER BY link.client_id,plan.id LOOP
  PERFORM gymbro_trainer.lock_client(p.client_id);
  PERFORM set_config('gymbro.trainer_write','on',true);
  PERFORM set_config('gymtracker.sync_v2','on',true);
  INSERT INTO public.routine_folders(id,user_id,name,notes,sort_order) VALUES(p.folder_id,p.client_id,p.name,'',0);
  INSERT INTO gymbro_trainer.imports VALUES(p.link_id,p.client_id,'routine_folders',p.folder_id::text);
  UPDATE public.routines r SET folder_id=p.folder_id,updated_at=clock_timestamp() WHERE r.user_id=p.client_id AND EXISTS(SELECT 1 FROM gymbro_trainer.controls c WHERE c.plan_id=p.id AND c.routine_id=r.id);
 END LOOP;
 PERFORM set_config('gymbro.trainer_write','off',true);
END $$;

CREATE OR REPLACE FUNCTION gymbro_trainer.guard_write() RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
DECLARE owner uuid; rid text; locked boolean:=false; before_json jsonb; after_json jsonb;
BEGIN
 IF current_setting('gymbro.trainer_write',true)='on' THEN IF TG_OP='DELETE' THEN RETURN OLD; ELSE RETURN NEW; END IF; END IF;
 IF TG_OP='DELETE' THEN owner:=OLD.user_id; ELSE owner:=NEW.user_id; END IF;
 -- Auth cascades delete the account row before its owned content. Those
 -- deletes must not recreate sync-account locks or enforce trainer controls.
 IF TG_OP='DELETE' AND NOT EXISTS(SELECT 1 FROM auth.users WHERE id=owner) THEN RETURN OLD; END IF;
 PERFORM gymbro_trainer.lock_client(owner);
 IF TG_TABLE_NAME='routines' THEN
 rid:=CASE WHEN TG_OP='DELETE' THEN OLD.id ELSE NEW.id END;
 SELECT EXISTS(SELECT 1 FROM gymbro_trainer.controls WHERE client_id=owner AND routine_id=rid) INTO locked;
 ELSIF TG_TABLE_NAME='routine_exercises' THEN
 rid:=CASE WHEN TG_OP='DELETE' THEN OLD.routine_id ELSE NEW.routine_id END;
 SELECT EXISTS(SELECT 1 FROM gymbro_trainer.controls WHERE client_id=owner AND routine_id=rid) INTO locked;
 ELSIF TG_TABLE_NAME='custom_exercises' THEN
 SELECT EXISTS(SELECT 1 FROM gymbro_trainer.controls c JOIN public.routine_exercises e ON e.user_id=c.client_id AND e.routine_id=c.routine_id AND NOT e.deleted WHERE c.client_id=owner AND e.custom_exercise_id=CASE WHEN TG_OP='DELETE' THEN OLD.id ELSE NEW.id END) INTO locked;
 ELSIF TG_TABLE_NAME='routine_folders' THEN
 IF TG_OP='DELETE' OR NEW.deleted THEN
 SELECT EXISTS(SELECT 1 FROM gymbro_trainer.controls c JOIN public.routines r ON r.user_id=c.client_id AND r.id=c.routine_id WHERE c.client_id=owner AND r.folder_id=OLD.id) INTO locked;
 END IF;
 ELSIF TG_TABLE_NAME='history_workouts' AND TG_OP='UPDATE' THEN
 IF (NEW.parent_id,NEW.starting_date) IS DISTINCT FROM (OLD.parent_id,OLD.starting_date) THEN
 SELECT EXISTS(SELECT 1 FROM gymbro_trainer.controls WHERE client_id=owner AND routine_id=OLD.parent_id) INTO locked;
 END IF;
 END IF;
 IF locked THEN
 IF TG_OP='UPDATE' AND TG_TABLE_NAME NOT IN ('history_workouts','routine_folders') THEN
 before_json:=to_jsonb(OLD)-'updated_at'-'revision'; after_json:=to_jsonb(NEW)-'updated_at'-'revision';
 IF before_json=after_json THEN RETURN NEW; END IF;
 END IF;
 RAISE EXCEPTION 'trainer_controlled' USING ERRCODE='23514';
 END IF;
 IF TG_OP='DELETE' THEN RETURN OLD; ELSE RETURN NEW; END IF;
END $$;
CREATE OR REPLACE FUNCTION public.trainer_execute(actor uuid, operation text, payload jsonb DEFAULT '{}') RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
#variable_conflict use_variable
DECLARE profile gymbro_trainer.profiles; link gymbro_trainer.links; invite gymbro_trainer.invites; plan gymbro_trainer.plans; revision gymbro_trainer.revisions; template gymbro_trainer.templates;
 result jsonb; doc jsonb; r jsonb; e jsonb; f jsonb; obj uuid; client uuid; next_number int; is_pro boolean; new_routines int; new_custom int; total int; row_id text; seq int; stamp timestamptz; after_date timestamptz; page_size int; page_offset int;
BEGIN
 IF auth.jwt()->>'role' IS DISTINCT FROM 'service_role' THEN RAISE EXCEPTION 'forbidden' USING ERRCODE='42501'; END IF;
 IF NOT EXISTS(SELECT 1 FROM auth.users WHERE id=actor) THEN RAISE EXCEPTION 'unauthorized' USING ERRCODE='42501'; END IF;
 SELECT * INTO profile FROM gymbro_trainer.profiles WHERE user_id=actor;
 page_size:=greatest(1,least(100,COALESCE((payload->>'limit')::int,50))); page_offset:=greatest(0,COALESCE((payload->>'offset')::int,0));
 IF operation='activate' THEN
 INSERT INTO gymbro_trainer.profiles(user_id,display_name) VALUES(actor,COALESCE(NULLIF(trim(payload->>'display_name'),''),'Trainer')) ON CONFLICT DO NOTHING;
 RETURN jsonb_build_object('active',true);
 END IF;
 IF operation='synced' THEN
 IF EXISTS(SELECT 1 FROM gymbro_trainer.links WHERE client_id=actor AND ended_at IS NULL) THEN
 INSERT INTO gymbro_trainer.activity VALUES(actor,clock_timestamp()) ON CONFLICT(client_id) DO UPDATE SET checked_at=excluded.checked_at;
 END IF;
 RETURN '{}'::jsonb;
 END IF;
 IF operation='session' THEN
 RETURN jsonb_build_object('profile',CASE WHEN profile.user_id IS NULL THEN NULL ELSE to_jsonb(profile) END,'link',(SELECT to_jsonb(l)||jsonb_build_object('trainer_name',p.display_name) FROM gymbro_trainer.links l JOIN gymbro_trainer.profiles p ON p.user_id=l.trainer_id WHERE l.client_id=actor AND l.ended_at IS NULL),
 'controls',COALESCE((SELECT jsonb_agg(jsonb_build_object('routine_id',c.routine_id,'link_id',c.link_id)) FROM gymbro_trainer.controls c WHERE c.client_id=actor),'[]'),
 'protected_exercises',COALESCE((SELECT jsonb_agg(DISTINCT e.custom_exercise_id) FROM public.routine_exercises e JOIN gymbro_trainer.controls c ON c.client_id=e.user_id AND c.routine_id=e.routine_id WHERE c.client_id=actor AND e.is_custom AND NOT e.deleted),'[]'),
 'shares',COALESCE((SELECT jsonb_agg(to_jsonb(s)) FROM gymbro_trainer.shares s JOIN gymbro_trainer.links l ON l.id=s.link_id WHERE l.client_id=actor AND l.ended_at IS NULL),'[]'),
 'offers',COALESCE((SELECT jsonb_agg(to_jsonb(p)||jsonb_build_object('revision',to_jsonb(v),'active_revision',(SELECT to_jsonb(a) FROM gymbro_trainer.revisions a WHERE a.id=p.active_id))) FROM gymbro_trainer.plans p JOIN gymbro_trainer.links l ON l.id=p.link_id JOIN gymbro_trainer.revisions v ON v.id=p.pending_id WHERE l.client_id=actor AND l.ended_at IS NULL),'[]'));
 END IF;
 IF operation='invite_accept' THEN
 PERFORM gymbro_trainer.lock_client(actor);
 SELECT * INTO invite FROM gymbro_trainer.invites WHERE token=(payload->>'token')::uuid FOR UPDATE;
 IF invite.link_id IS NOT NULL THEN
 SELECT * INTO link FROM gymbro_trainer.links WHERE id=invite.link_id;
 IF link.client_id=actor AND link.ended_at IS NULL THEN RETURN to_jsonb(link); END IF;
 END IF;
 IF invite.id IS NULL OR invite.revoked OR invite.expires_at<=now() OR invite.link_id IS NOT NULL THEN RAISE EXCEPTION 'invite_unavailable' USING ERRCODE='P0002'; END IF;
 IF invite.trainer_id=actor THEN RAISE EXCEPTION 'self_link' USING ERRCODE='22023'; END IF;
 PERFORM 1 FROM gymbro_trainer.profiles WHERE user_id=invite.trainer_id FOR UPDATE;
 IF EXISTS(SELECT 1 FROM gymbro_trainer.links WHERE client_id=actor AND ended_at IS NULL) THEN RAISE EXCEPTION 'already_linked' USING ERRCODE='23505'; END IF;
 IF (SELECT client_limit FROM gymbro_trainer.settings WHERE singleton) <= (SELECT count(*) FROM gymbro_trainer.links WHERE trainer_id=invite.trainer_id AND ended_at IS NULL) THEN RAISE EXCEPTION 'client_limit' USING ERRCODE='23514'; END IF;
 INSERT INTO gymbro_trainer.links(trainer_id,client_id) VALUES(invite.trainer_id,actor) RETURNING * INTO link;
 UPDATE gymbro_trainer.invites SET link_id=link.id WHERE id=invite.id;
 INSERT INTO gymbro_trainer.events(link_id,trainer_id,kind) VALUES(link.id,link.trainer_id,'link_accepted'); RETURN to_jsonb(link);
 END IF;
 -- Client and trainer operations share the same account lock with all sync writes.
 IF operation IN ('disconnect','share','unshare','accept','reject','history','client','publish','plan_save') THEN
 SELECT * INTO link FROM gymbro_trainer.links WHERE id=(payload->>'link_id')::uuid AND (trainer_id=actor OR client_id=actor);
 IF link.id IS NULL THEN RAISE EXCEPTION 'not_found' USING ERRCODE='P0002'; END IF;
 PERFORM gymbro_trainer.lock_client(link.client_id);
 SELECT * INTO link FROM gymbro_trainer.links WHERE id=link.id FOR UPDATE;
 IF link.ended_at IS NOT NULL THEN IF operation='disconnect' THEN RETURN jsonb_build_object('ended',true); END IF; RAISE EXCEPTION 'relationship_ended' USING ERRCODE='P0002'; END IF;
 IF operation='disconnect' THEN
 UPDATE gymbro_trainer.links SET ended_at=clock_timestamp() WHERE id=link.id;
 DELETE FROM gymbro_trainer.controls WHERE link_id=link.id;
 DELETE FROM gymbro_trainer.shares WHERE link_id=link.id;
 DELETE FROM gymbro_trainer.imports WHERE link_id=link.id;
 DELETE FROM gymbro_trainer.activity WHERE client_id=link.client_id;
 DELETE FROM public.notifications WHERE kind='trainer_plan' AND params->>'link_id'=link.id::text;
 DELETE FROM gymbro_trainer.plans WHERE link_id=link.id;
 DELETE FROM gymbro_trainer.acceptances WHERE link_id=link.id;
 INSERT INTO gymbro_trainer.events(link_id,trainer_id,kind) VALUES(link.id,link.trainer_id,'link_ended'); RETURN jsonb_build_object('ended',true);
 END IF;
 IF operation IN ('share','unshare','accept','reject') AND link.client_id<>actor THEN RAISE EXCEPTION 'forbidden' USING ERRCODE='42501'; END IF;
 IF operation IN ('share','unshare') THEN
 row_id:=payload->>'routine_id';
 IF EXISTS(SELECT 1 FROM gymbro_trainer.controls WHERE client_id=actor AND routine_id=row_id) THEN RAISE EXCEPTION 'trainer_controlled' USING ERRCODE='42501'; END IF;
 IF operation='share' THEN
 IF NOT EXISTS(SELECT 1 FROM public.routines WHERE user_id=actor AND id=row_id AND NOT deleted) THEN RAISE EXCEPTION 'not_found' USING ERRCODE='P0002'; END IF;
 INSERT INTO gymbro_trainer.shares VALUES(link.id,row_id,CASE WHEN payload->>'include_previous'='true' THEN '-infinity'::timestamptz ELSE clock_timestamp() END) ON CONFLICT(link_id,routine_id) DO NOTHING;
 ELSE DELETE FROM gymbro_trainer.shares WHERE link_id=link.id AND routine_id=row_id; END IF;
 INSERT INTO gymbro_trainer.events(link_id,trainer_id,kind) VALUES(link.id,link.trainer_id,operation); RETURN '{}'::jsonb;
 END IF;
 IF operation IN ('client','history') THEN
 IF link.trainer_id<>actor THEN RAISE EXCEPTION 'forbidden' USING ERRCODE='42501'; END IF;
 IF operation='client' THEN
 RETURN jsonb_build_object('link',to_jsonb(link),'plans',COALESCE((SELECT jsonb_agg(to_jsonb(p)) FROM gymbro_trainer.plans p WHERE p.link_id=link.id),'[]'),'routines',COALESCE((SELECT jsonb_agg(to_jsonb(r)||jsonb_build_object('exercises',(SELECT jsonb_agg(to_jsonb(e) ORDER BY e.sort_order) FROM public.routine_exercises e WHERE e.user_id=r.user_id AND e.routine_id=r.id AND NOT e.deleted))) FROM public.routines r WHERE r.user_id=link.client_id AND NOT r.deleted AND (EXISTS(SELECT 1 FROM gymbro_trainer.controls c WHERE c.link_id=link.id AND c.routine_id=r.id) OR EXISTS(SELECT 1 FROM gymbro_trainer.shares s WHERE s.link_id=link.id AND s.routine_id=r.id))),'[]'),'events',COALESCE((SELECT jsonb_agg(to_jsonb(x)) FROM (SELECT * FROM gymbro_trainer.events WHERE link_id=link.id ORDER BY created_at DESC LIMIT 100) x),'[]'));
 END IF;
 SELECT COALESCE(jsonb_agg(to_jsonb(w)||jsonb_build_object('exercises',(SELECT jsonb_agg(to_jsonb(e) ORDER BY e.sort_order) FROM public.history_workout_exercises e WHERE e.user_id=w.user_id AND e.routine_id=w.id AND NOT e.deleted), 'prescription',(SELECT v.document FROM gymbro_trainer.acceptances a JOIN gymbro_trainer.revisions v ON v.id=a.revision_id WHERE a.link_id=link.id AND a.accepted_at<=w.starting_date AND a.id=(SELECT a2.id FROM gymbro_trainer.acceptances a2 WHERE a2.plan_id=a.plan_id AND a2.accepted_at<=w.starting_date ORDER BY a2.accepted_at DESC LIMIT 1) AND EXISTS(SELECT 1 FROM jsonb_array_elements(v.document->'routines') rr WHERE rr->>'id'=w.parent_id) ORDER BY a.accepted_at DESC LIMIT 1)) ORDER BY w.starting_date DESC),'[]') INTO result FROM (SELECT * FROM public.history_workouts w WHERE w.user_id=link.client_id AND NOT w.deleted AND gymbro_trainer.visible_workout(link.id,w.parent_id,w.starting_date) AND (NULLIF(payload->>'routine_id','') IS NULL OR w.parent_id=payload->>'routine_id') ORDER BY w.starting_date DESC LIMIT page_size OFFSET page_offset) w;
 RETURN result;
 END IF;
 IF operation IN ('plan_save','publish') AND link.trainer_id<>actor THEN RAISE EXCEPTION 'forbidden' USING ERRCODE='42501'; END IF;
 IF operation='plan_save' THEN
 obj:=(payload->>'id')::uuid;
 SELECT * INTO plan FROM gymbro_trainer.plans WHERE id=obj FOR UPDATE;
 IF plan.id IS NOT NULL AND (plan.link_id<>link.id OR plan.version<>COALESCE((payload->>'version')::int,0)) THEN RAISE EXCEPTION 'conflict' USING ERRCODE='40001'; END IF;
 doc:=gymbro_trainer.plan_document(payload->'document',COALESCE(plan.folder_id,gen_random_uuid()),payload->>'name');
 PERFORM gymbro_trainer.validate_document(doc);
 INSERT INTO gymbro_trainer.plans(id,link_id,name,draft,folder_id) VALUES(obj,link.id,payload->>'name',doc,(doc->'folders'->0->>'id')::uuid) ON CONFLICT(id) DO UPDATE SET name=excluded.name,draft=excluded.draft,version=gymbro_trainer.plans.version+1,updated_at=clock_timestamp() RETURNING * INTO plan;
 RETURN to_jsonb(plan);
 END IF;
 SELECT * INTO plan FROM gymbro_trainer.plans WHERE id=(payload->>'plan_id')::uuid AND link_id=link.id FOR UPDATE;
 IF plan.id IS NULL THEN RAISE EXCEPTION 'not_found' USING ERRCODE='P0002'; END IF;
 IF operation='publish' THEN
 IF plan.version<>COALESCE((payload->>'version')::int,0) THEN RAISE EXCEPTION 'conflict' USING ERRCODE='40001'; END IF;
 doc:=gymbro_trainer.plan_document(plan.draft,plan.folder_id,plan.name);
 PERFORM gymbro_trainer.validate_document(doc);
 SELECT COALESCE(max(number),0)+1 INTO next_number FROM gymbro_trainer.revisions WHERE plan_id=plan.id;
 INSERT INTO gymbro_trainer.revisions(plan_id,number,document) VALUES(plan.id,next_number,doc) RETURNING * INTO revision;
 DELETE FROM public.notifications WHERE kind='trainer_plan' AND params->>'plan_id'=plan.id::text;
 PERFORM public.enqueue_notification(link.client_id,'trainer_plan',link.trainer_id,NULL,NULL,NULL,jsonb_build_object('link_id',link.id,'plan_id',plan.id),'trainer-plan:'||revision.id);
 UPDATE gymbro_trainer.plans SET draft=doc,pending_id=revision.id,version=version+1,updated_at=clock_timestamp() WHERE id=plan.id;
 INSERT INTO gymbro_trainer.events(link_id,trainer_id,kind) VALUES(link.id,link.trainer_id,CASE WHEN plan.pending_id IS NULL THEN 'published' ELSE 'proposal_replaced' END);
 RETURN to_jsonb(revision);
 END IF;
 IF operation='accept' AND plan.active_id=(payload->>'revision_id')::uuid THEN RETURN jsonb_build_object('accepted',true); END IF;
 IF plan.pending_id IS NULL OR plan.pending_id<>(payload->>'revision_id')::uuid THEN RAISE EXCEPTION 'proposal_superseded' USING ERRCODE='40001'; END IF;
 IF operation IN ('accept','reject') THEN DELETE FROM public.notifications WHERE kind='trainer_plan' AND params->>'plan_id'=plan.id::text; END IF;
 IF operation='reject' THEN
 UPDATE gymbro_trainer.plans SET pending_id=NULL WHERE id=plan.id;
 INSERT INTO gymbro_trainer.events(link_id,trainer_id,kind) VALUES(link.id,link.trainer_id,'rejected'); RETURN '{}'::jsonb;
 END IF;
 IF operation='accept' THEN
 SELECT * INTO revision FROM gymbro_trainer.revisions WHERE id=plan.pending_id; doc:=gymbro_trainer.plan_document(revision.document,plan.folder_id,plan.name);
 SELECT count(*) INTO new_routines FROM jsonb_array_elements(doc->'routines') x WHERE NOT EXISTS(SELECT 1 FROM public.routines r WHERE r.user_id=actor AND r.id=x->>'id' AND NOT r.deleted);
 SELECT count(*) INTO new_custom FROM jsonb_array_elements(doc->'custom_exercises') x WHERE NOT EXISTS(SELECT 1 FROM public.custom_exercises e WHERE e.user_id=actor AND e.id=x->>'id' AND NOT e.deleted);
 -- IDs cannot take over personal content or another plan's content.
 IF EXISTS(SELECT 1 FROM jsonb_array_elements(doc->'routines') x JOIN public.routines r ON r.user_id=actor AND r.id=x->>'id' WHERE NOT EXISTS(SELECT 1 FROM gymbro_trainer.controls c WHERE c.client_id=actor AND c.routine_id=r.id AND c.plan_id=plan.id)) THEN RAISE EXCEPTION 'identity_conflict' USING ERRCODE='40001'; END IF;
 IF EXISTS(SELECT 1 FROM jsonb_array_elements(doc->'custom_exercises') x JOIN public.custom_exercises e ON e.user_id=actor AND e.id=x->>'id' WHERE NOT EXISTS(SELECT 1 FROM gymbro_trainer.imports i WHERE i.link_id=link.id AND i.client_id=actor AND i.entity='custom_exercises' AND i.record_id=e.id)) THEN RAISE EXCEPTION 'identity_conflict' USING ERRCODE='40001'; END IF;
 IF EXISTS(SELECT 1 FROM jsonb_array_elements(COALESCE(doc->'folders','[]')) x JOIN public.routine_folders f ON f.user_id=actor AND f.id::text=x->>'id' WHERE NOT EXISTS(SELECT 1 FROM gymbro_trainer.imports i WHERE i.link_id=link.id AND i.client_id=actor AND i.entity='routine_folders' AND i.record_id=f.id::text)) THEN RAISE EXCEPTION 'identity_conflict' USING ERRCODE='40001'; END IF;
 IF EXISTS(SELECT 1 FROM jsonb_array_elements(doc->'routines') rr, jsonb_array_elements(rr->'exercises') x JOIN public.routine_exercises e ON e.user_id=actor AND e.id=x->>'id' WHERE NOT EXISTS(SELECT 1 FROM gymbro_trainer.controls c WHERE c.client_id=actor AND c.plan_id=plan.id AND c.routine_id=e.routine_id)) THEN RAISE EXCEPTION 'identity_conflict' USING ERRCODE='40001'; END IF;
 SELECT gymbro_trainer.pro(actor) INTO is_pro;
 IF NOT is_pro THEN
 IF new_routines>0 AND (SELECT count(*) FROM public.routines WHERE user_id=actor AND NOT deleted)>=(SELECT routine_limit FROM gymbro_trainer.settings WHERE singleton) THEN RAISE EXCEPTION 'routine_slots_exhausted' USING ERRCODE='P1003'; END IF;
 IF new_custom>0 AND (SELECT count(*) FROM public.custom_exercises WHERE user_id=actor AND NOT deleted)>=(SELECT custom_limit FROM gymbro_trainer.settings WHERE singleton) THEN RAISE EXCEPTION 'exercise_slots_exhausted' USING ERRCODE='P1003'; END IF;
 END IF;
 PERFORM set_config('gymbro.trainer_write','on',true); PERFORM set_config('gymtracker.sync_v2','on',true);
 FOR f IN SELECT value FROM jsonb_array_elements(COALESCE(doc->'folders','[]')) LOOP
 INSERT INTO gymbro_trainer.imports VALUES(link.id,actor,'routine_folders',f->>'id') ON CONFLICT DO NOTHING;
 INSERT INTO public.routine_folders(id,user_id,name,sort_order,notes) VALUES((f->>'id')::uuid,actor,f->>'name',COALESCE((f->>'sort_order')::int,0),f->>'notes') ON CONFLICT(id,user_id) DO UPDATE SET name=excluded.name,notes=excluded.notes,deleted=false,updated_at=clock_timestamp();
 END LOOP;
 FOR e IN SELECT value FROM jsonb_array_elements(doc->'custom_exercises') LOOP
 INSERT INTO gymbro_trainer.imports VALUES(link.id,actor,'custom_exercises',e->>'id') ON CONFLICT DO NOTHING;
 INSERT INTO public.custom_exercises(id,user_id,name,parameters,primary_muscle_group,secondary_muscle_groups,equipment) VALUES(e->>'id',actor,e->>'name',e->>'parameters',e->>'primary_muscle_group',ARRAY(SELECT jsonb_array_elements_text(COALESCE(e->'secondary_muscle_groups','[]'))),COALESCE(e->>'equipment','none')) ON CONFLICT(id,user_id) DO UPDATE SET name=excluded.name,parameters=excluded.parameters,primary_muscle_group=excluded.primary_muscle_group,secondary_muscle_groups=excluded.secondary_muscle_groups,equipment=excluded.equipment,deleted=false,updated_at=clock_timestamp();
 END LOOP;
 DELETE FROM gymbro_trainer.controls c WHERE c.plan_id=plan.id AND NOT EXISTS(SELECT 1 FROM jsonb_array_elements(doc->'routines') x WHERE x->>'id'=c.routine_id);
 seq:=0;
 FOR r IN SELECT value FROM jsonb_array_elements(doc->'routines') LOOP
 INSERT INTO public.routines(id,user_id,name,infobox,weight_unit,distance_unit,sort_order,folder_id) VALUES(r->>'id',actor,r->>'name',COALESCE(r->>'infobox',''),r->>'weight_unit',r->>'distance_unit',seq,(r->>'folder_id')::uuid) ON CONFLICT(id,user_id) DO UPDATE SET name=excluded.name,infobox=excluded.infobox,weight_unit=excluded.weight_unit,distance_unit=excluded.distance_unit,folder_id=excluded.folder_id,deleted=false,updated_at=clock_timestamp();
 seq:=seq+1;
 UPDATE public.routine_exercises SET deleted=true,updated_at=clock_timestamp() WHERE user_id=actor AND routine_id=r->>'id';
 FOR e IN SELECT value FROM jsonb_array_elements(r->'exercises') LOOP
 INSERT INTO public.routine_exercises(id,user_id,routine_id,name,parameters,sets,primary_muscle_group,secondary_muscle_groups,rest_time,is_custom,library_exercise_id,custom_exercise_id,notes,is_superset,is_in_superset,superset_id,sort_order,supersedes_id,rpe,equipment,progression)
 VALUES(e->>'id',actor,r->>'id',COALESCE(e->>'name','Superset'),e->>'parameters',e->'sets',e->>'primary_muscle_group',ARRAY(SELECT jsonb_array_elements_text(COALESCE(e->'secondary_muscle_groups','[]'))),COALESCE((e->>'rest_time')::bigint,90),COALESCE((e->>'is_custom')::boolean,false),e->>'library_exercise_id',e->>'custom_exercise_id',e->>'notes',COALESCE((e->>'is_superset')::boolean,false),COALESCE((e->>'is_in_superset')::boolean,false),e->>'superset_id',COALESCE((e->>'sort_order')::int,0),NULL,(e->>'rpe')::int,COALESCE(e->>'equipment','none'),CASE WHEN e->'progression' IS NULL OR e->'progression'='null'::jsonb THEN NULL ELSE gymbro_mcp.progression((e->'progression')-'setCount',e->>'parameters',e->'sets')::jsonb END)
 ON CONFLICT(id,user_id) DO UPDATE SET routine_id=excluded.routine_id,name=excluded.name,parameters=excluded.parameters,sets=excluded.sets,primary_muscle_group=excluded.primary_muscle_group,secondary_muscle_groups=excluded.secondary_muscle_groups,rest_time=excluded.rest_time,is_custom=excluded.is_custom,library_exercise_id=excluded.library_exercise_id,custom_exercise_id=excluded.custom_exercise_id,notes=excluded.notes,is_superset=excluded.is_superset,is_in_superset=excluded.is_in_superset,superset_id=excluded.superset_id,sort_order=excluded.sort_order,rpe=excluded.rpe,equipment=excluded.equipment,progression=excluded.progression,deleted=false,updated_at=clock_timestamp();
 END LOOP;
 INSERT INTO gymbro_trainer.controls VALUES(link.id,plan.id,actor,r->>'id') ON CONFLICT(client_id,routine_id) DO NOTHING;
 END LOOP;
 INSERT INTO gymbro_trainer.acceptances(link_id,plan_id,revision_id) VALUES(link.id,plan.id,revision.id);
 UPDATE gymbro_trainer.plans SET active_id=revision.id,pending_id=NULL WHERE id=plan.id;
 INSERT INTO gymbro_trainer.events(link_id,trainer_id,kind) VALUES(link.id,link.trainer_id,'accepted');
 PERFORM set_config('gymbro.trainer_write','off',true);
 RETURN jsonb_build_object('accepted',true);
 END IF;
 END IF;
 IF profile.user_id IS NULL THEN RAISE EXCEPTION 'trainer_required' USING ERRCODE='42501'; END IF;
 IF operation='settings' THEN
 UPDATE gymbro_trainer.profiles SET display_name=COALESCE(NULLIF(trim(payload->>'display_name'),''),display_name),inactivity_days=COALESCE((payload->>'inactivity_days')::int,inactivity_days) WHERE user_id=actor RETURNING * INTO profile; RETURN to_jsonb(profile);
 ELSIF operation='invite_create' THEN
 INSERT INTO gymbro_trainer.invites(trainer_id) VALUES(actor) RETURNING * INTO invite; RETURN to_jsonb(invite);
 ELSIF operation='invite_revoke' THEN
 UPDATE gymbro_trainer.invites SET revoked=true WHERE id=(payload->>'id')::uuid AND trainer_id=actor; RETURN '{}'::jsonb;
 ELSIF operation='overview' THEN
 after_date:=clock_timestamp()-make_interval(days=>greatest(1,least(3650,COALESCE((payload->>'days')::int,30))));
 RETURN jsonb_build_object('clients',(SELECT count(*) FROM gymbro_trainer.links l WHERE l.trainer_id=actor AND ended_at IS NULL),
 'active',(SELECT count(*) FROM gymbro_trainer.links l WHERE l.trainer_id=actor AND ended_at IS NULL AND EXISTS(SELECT 1 FROM public.history_workouts w WHERE w.user_id=l.client_id AND NOT w.deleted AND w.starting_date>=after_date)),
 'inactive',(SELECT count(*) FROM gymbro_trainer.links l WHERE l.trainer_id=actor AND ended_at IS NULL AND NOT EXISTS(SELECT 1 FROM public.history_workouts w WHERE w.user_id=l.client_id AND NOT w.deleted AND w.starting_date>=after_date)),
 'workouts',(SELECT count(*) FROM public.history_workouts w JOIN gymbro_trainer.links l ON l.client_id=w.user_id AND l.trainer_id=actor AND l.ended_at IS NULL WHERE NOT w.deleted AND w.completes IS NULL AND w.starting_date>=after_date AND gymbro_trainer.visible_workout(l.id,w.parent_id,w.starting_date)),
 'pending',(SELECT count(*) FROM gymbro_trainer.plans p JOIN gymbro_trainer.links l ON l.id=p.link_id WHERE l.trainer_id=actor AND ended_at IS NULL AND p.pending_id IS NOT NULL));
 ELSIF operation='events' THEN
 RETURN COALESCE((SELECT jsonb_agg(to_jsonb(x)) FROM (SELECT id,kind,created_at FROM gymbro_trainer.events WHERE trainer_id=actor ORDER BY created_at DESC LIMIT page_size OFFSET page_offset) x),'[]');
 ELSIF operation='invites' THEN
 RETURN COALESCE((SELECT jsonb_agg(to_jsonb(x)) FROM (SELECT * FROM gymbro_trainer.invites WHERE trainer_id=actor ORDER BY created_at DESC LIMIT page_size OFFSET page_offset) x),'[]');
 ELSIF operation='clients' THEN
 after_date:=clock_timestamp()-make_interval(days=>greatest(1,least(3650,COALESCE((payload->>'days')::int,profile.inactivity_days))));
 RETURN COALESCE((WITH rows AS (SELECT l.*,p.full_name,p.username,
 (SELECT max(starting_date) FROM public.history_workouts w WHERE w.user_id=l.client_id AND NOT w.deleted) AS last_workout,
 (SELECT max(starting_date) FROM public.history_workouts w JOIN gymbro_trainer.controls c ON c.client_id=w.user_id AND c.routine_id=w.parent_id WHERE c.link_id=l.id AND NOT w.deleted AND w.starting_date>=l.created_at) AS last_assigned_workout,
 (SELECT checked_at FROM gymbro_trainer.activity WHERE client_id=l.client_id) AS last_updated
 FROM gymbro_trainer.links l LEFT JOIN public.profiles p ON p.id=l.client_id WHERE l.trainer_id=actor AND l.ended_at IS NULL AND (COALESCE(payload->>'search','')='' OR COALESCE(p.full_name,p.username,'') ILIKE '%'||(payload->>'search')||'%'))
 SELECT jsonb_agg(to_jsonb(x)) FROM (SELECT * FROM rows WHERE CASE COALESCE(payload->>'filter','all')
 WHEN 'assigned' THEN last_assigned_workout>=after_date
 WHEN 'outside' THEN last_workout>=after_date AND (last_assigned_workout IS NULL OR last_assigned_workout<after_date)
 WHEN 'inactive' THEN last_workout<after_date
 WHEN 'never' THEN last_workout IS NULL ELSE true END
 ORDER BY CASE WHEN payload->>'sort'='activity' THEN last_workout ELSE created_at END DESC NULLS LAST LIMIT page_size OFFSET page_offset) x),'[]');
 ELSIF operation='templates' THEN
 RETURN COALESCE((SELECT jsonb_agg(to_jsonb(x)) FROM (SELECT * FROM gymbro_trainer.templates WHERE trainer_id=actor ORDER BY updated_at DESC LIMIT page_size OFFSET page_offset) x),'[]');
 ELSIF operation='template_save' THEN
 obj:=(payload->>'id')::uuid;
 doc:=gymbro_trainer.plan_document(payload->'document',obj,payload->>'name'); PERFORM gymbro_trainer.validate_document(doc);
 SELECT * INTO template FROM gymbro_trainer.templates WHERE id=obj FOR UPDATE;
 IF template.id IS NOT NULL AND (template.trainer_id<>actor OR template.version<>COALESCE((payload->>'version')::int,0)) THEN RAISE EXCEPTION 'conflict' USING ERRCODE='40001'; END IF;
 INSERT INTO gymbro_trainer.templates(id,trainer_id,name,document) VALUES(obj,actor,payload->>'name',doc) ON CONFLICT(id) DO UPDATE SET name=excluded.name,document=excluded.document,version=gymbro_trainer.templates.version+1,updated_at=clock_timestamp() RETURNING * INTO template; RETURN to_jsonb(template);
 ELSIF operation='plans' THEN
 RETURN COALESCE((SELECT jsonb_agg(to_jsonb(x)) FROM (SELECT p.*,(SELECT jsonb_agg(to_jsonb(v) ORDER BY v.number DESC) FROM gymbro_trainer.revisions v WHERE v.plan_id=p.id) AS revisions FROM gymbro_trainer.plans p JOIN gymbro_trainer.links l ON l.id=p.link_id WHERE l.trainer_id=actor AND l.ended_at IS NULL ORDER BY p.updated_at DESC LIMIT page_size OFFSET page_offset) x),'[]');
 ELSIF operation='catalog' THEN
 RETURN COALESCE((SELECT jsonb_agg(to_jsonb(x)) FROM (SELECT value AS exercise FROM gymbro_mcp.catalog c, jsonb_array_elements(c.exercises) WHERE (payload->>'search' IS NULL OR (value->'names')::text ILIKE '%'||(payload->>'search')||'%') ORDER BY value->>'id' LIMIT page_size OFFSET page_offset) x),'[]');
 END IF;
 RAISE EXCEPTION 'invalid_operation' USING ERRCODE='22023';
END $$;

-- Called by the Auth hard delete, including deletion through delete-user-complete.
-- Serialize with sync/acceptance and detach consumed invites before FK cascades.
CREATE FUNCTION gymbro_trainer.before_account_delete() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
DECLARE client uuid;
BEGIN
 FOR client IN SELECT DISTINCT client_id FROM gymbro_trainer.links WHERE trainer_id=OLD.id OR client_id=OLD.id ORDER BY client_id LOOP
  PERFORM gymbro_trainer.lock_client(client);
 END LOOP;
 UPDATE gymbro_trainer.invites SET revoked=true,link_id=NULL WHERE link_id IN
  (SELECT id FROM gymbro_trainer.links WHERE trainer_id=OLD.id OR client_id=OLD.id);
 DELETE FROM public.notifications WHERE kind='trainer_plan' AND params->>'link_id' IN
  (SELECT id::text FROM gymbro_trainer.links WHERE trainer_id=OLD.id OR client_id=OLD.id);
 DELETE FROM gymbro_trainer.activity WHERE client_id IN
  (SELECT client_id FROM gymbro_trainer.links WHERE trainer_id=OLD.id OR client_id=OLD.id);
 -- Cascades remove links, controls, imports, shares and all client-specific
 -- revisions. Accepted content is owned by the surviving clients and stays put.
 RETURN OLD;
END $$;
CREATE TRIGGER trainer_account_delete BEFORE DELETE ON auth.users FOR EACH ROW EXECUTE FUNCTION gymbro_trainer.before_account_delete();

REVOKE ALL ON ALL FUNCTIONS IN SCHEMA gymbro_trainer FROM PUBLIC,anon,authenticated;
COMMIT;
