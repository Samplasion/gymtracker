-- Only executed against the disposable backend test database.
BEGIN;
DO $$
DECLARE a uuid:=gen_random_uuid(); b uuid:=gen_random_uuid(); r uuid; stamp timestamptz;
 n bigint; d bigint; device uuid:=gen_random_uuid(); old_available timestamptz;
BEGIN
 INSERT INTO auth.users(id,email,raw_user_meta_data) VALUES
 (a,a||'@admin.test',jsonb_build_object('username','ac_'||left(a::text,8))),
 (b,b||'@admin.test',jsonb_build_object('username','ac_'||left(b::text,8)));
 INSERT INTO public.reports(reporter_id,reported_id,reason) VALUES(a,b,'Test') RETURNING id,updated_at INTO r,stamp;
 PERFORM public.admin_transition_report(r,'received',stamp,'reviewing','Operatore: Test; esame');
 IF (SELECT status FROM public.reports WHERE id=r)<>'reviewing' OR
 (SELECT count(*) FROM public.report_notes WHERE report_id=r)<>1 THEN RAISE EXCEPTION 'Transition not atomic'; END IF;
 BEGIN
 PERFORM public.admin_transition_report(r,'received',stamp,'reviewing','stale');
 RAISE EXCEPTION 'Stale update accepted'; EXCEPTION WHEN serialization_failure THEN NULL; END;
 BEGIN
 PERFORM public.admin_transition_report(r,'reviewing',stamp,'resolved','');
 RAISE EXCEPTION 'Empty note accepted'; EXCEPTION WHEN invalid_parameter_value THEN NULL; END;
 IF (SELECT count(*) FROM public.report_notes WHERE report_id=r)<>1 THEN RAISE EXCEPTION 'Stale note inserted'; END IF;
 SELECT updated_at INTO stamp FROM public.reports WHERE id=r;
 PERFORM public.admin_transition_report(r,'reviewing',stamp,'resolved','Operatore: Test; conclusa');
 IF (SELECT count(*) FROM public.notifications WHERE report_id=r AND kind='report_status')<>2 THEN RAISE EXCEPTION 'Missing/duplicate notifications'; END IF;
 SELECT id INTO n FROM public.notifications WHERE report_id=r ORDER BY id DESC LIMIT 1;
 INSERT INTO public.push_devices(id,user_id,token,platform) VALUES(device,a,'admin-console-test-device','ios');
 INSERT INTO public.push_deliveries(notification_id,device_id,attempts,finished_at,last_error)
 VALUES(n,device,8,now(),'FCM 503: UNAVAILABLE') RETURNING id,available_at INTO d,old_available;
 PERFORM public.admin_requeue_push(d,8,old_available,b,'Operatore: Test; configurazione corretta');
 IF (SELECT attempts FROM public.push_deliveries WHERE id=d)<>0 OR
 (SELECT count(*) FROM public.admin_console_audit WHERE delivery_id=d)<>1 THEN RAISE EXCEPTION 'Requeue/audit failed'; END IF;
 BEGIN
 PERFORM public.admin_requeue_push(d,8,old_available,b,'stale');
 RAISE EXCEPTION 'Repeated requeue accepted'; EXCEPTION WHEN serialization_failure THEN NULL; END;
 FOR stamp IN SELECT now() LOOP
 -- Ambiguous outcomes, accepted sends, cancellations, active leases, unauthorized devices.
 UPDATE public.push_deliveries SET attempts=8,last_error='Delivery transport failed',finished_at=now() WHERE id=d;
 BEGIN PERFORM public.admin_requeue_push(d,8,(SELECT available_at FROM public.push_deliveries WHERE id=d),b,'test'); RAISE EXCEPTION 'Ambiguous outcome accepted'; EXCEPTION WHEN serialization_failure THEN NULL; END;
 UPDATE public.push_deliveries SET last_error=NULL WHERE id=d;
 BEGIN PERFORM public.admin_requeue_push(d,8,(SELECT available_at FROM public.push_deliveries WHERE id=d),b,'test'); RAISE EXCEPTION 'Sent delivery accepted'; EXCEPTION WHEN serialization_failure THEN NULL; END;
 UPDATE public.push_deliveries SET last_error='no_longer_authorized' WHERE id=d;
 BEGIN PERFORM public.admin_requeue_push(d,8,(SELECT available_at FROM public.push_deliveries WHERE id=d),b,'test'); RAISE EXCEPTION 'Cancelled accepted'; EXCEPTION WHEN serialization_failure THEN NULL; END;
 UPDATE public.push_deliveries SET last_error='FCM 503: UNAVAILABLE',lease_until=now()+interval '1 minute',lease_id=gen_random_uuid() WHERE id=d;
 BEGIN PERFORM public.admin_requeue_push(d,8,(SELECT available_at FROM public.push_deliveries WHERE id=d),b,'test'); RAISE EXCEPTION 'Leased delivery accepted'; EXCEPTION WHEN serialization_failure THEN NULL; END;
 UPDATE public.push_deliveries SET lease_until=NULL,lease_id=NULL WHERE id=d;
 UPDATE public.push_devices SET user_id=b WHERE id=device;
 BEGIN PERFORM public.admin_requeue_push(d,8,(SELECT available_at FROM public.push_deliveries WHERE id=d),b,'test'); RAISE EXCEPTION 'Unauthorized delivery accepted'; EXCEPTION WHEN serialization_failure THEN NULL; END;
 END LOOP;
 IF has_function_privilege('authenticated','public.admin_transition_report(uuid,text,timestamptz,text,text)','EXECUTE') OR
 has_function_privilege('anon','public.admin_requeue_push(bigint,integer,timestamptz,uuid,text)','EXECUTE') OR
 has_table_privilege('authenticated','public.admin_console_audit','SELECT') THEN RAISE EXCEPTION 'Privilege leak'; END IF;
END $$;
ROLLBACK;
