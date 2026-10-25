-- MCP water integration; requires hydration storage, never activates sync v2.
BEGIN;
-- Evaluate billing explicitly: SQL may short-circuit an AND expression when
-- the date is already inside the Free window, skipping an embedded pro() call.
CREATE OR REPLACE FUNCTION gymbro_mcp.check_days(owner uuid, first_day date, last_day date) RETURNS void
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $$
DECLARE today date; verified_pro boolean; BEGIN
 IF first_day IS NULL OR last_day IS NULL OR first_day>last_day OR last_day-first_day>366 THEN RAISE EXCEPTION 'Invalid date range (maximum 367 days)' USING ERRCODE='22023'; END IF;
 verified_pro:=gymbro_mcp.pro(owner);
 today:=(now() AT TIME ZONE gymbro_mcp.time_zone(owner))::date;
 IF NOT verified_pro AND (first_day<today-7 OR last_day>today+7) THEN RAISE EXCEPTION 'pro_required' USING ERRCODE='P1003'; END IF;
END $$;
CREATE FUNCTION gymbro_mcp.water_view(entry public.water_logs, owner uuid, zone text) RETURNS jsonb
LANGUAGE plpgsql STABLE SET search_path='' AS $$
DECLARE data jsonb:=entry.json_data::jsonb; instant timestamptz; ml numeric; BEGIN
 ml:=gymbro_mcp.number_value(data->'milliliters',1.7976931348623157e308,false);
 IF ml IS NULL OR ml<=0 OR NOT data ? 'time' THEN RAISE EXCEPTION 'Invalid stored water entry' USING ERRCODE='22023'; END IF;
 instant:=gymbro_mcp.measurement_time(data->'time',owner);
 RETURN jsonb_build_object('id',entry.id,'milliliters',ml,'time',instant,'date',(instant AT TIME ZONE zone)::date);
END $$;
CREATE FUNCTION gymbro_mcp.water(operation text, request jsonb, idempotency_key uuid) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
DECLARE owner uuid:=gymbro_mcp.owner(); zone text; receipt gymbro_mcp.operations; item jsonb; raw jsonb; result jsonb;
 items jsonb:='[]'; unavailable jsonb:='[]'; instant timestamptz; day date; first_day date; last_day date; ml numeric; uid text; i int:=0;
 lim int:=20; cursor_data jsonb; cursor_time timestamptz; cursor_id text; fingerprint text; more boolean; last_row jsonb;
BEGIN
 zone:=gymbro_mcp.time_zone(owner);
 IF request IS NULL OR jsonb_typeof(request)<>'object' OR octet_length(request::text)>1048576 THEN RAISE EXCEPTION 'Invalid request' USING ERRCODE='22023'; END IF;
 IF operation='log_water' THEN
  PERFORM gymbro_mcp.object_keys(request,ARRAY['entries']);
  IF idempotency_key IS NULL THEN RAISE EXCEPTION 'Idempotency key required' USING ERRCODE='22023'; END IF;
  PERFORM gymbro_mcp.lock_account(owner);
  SELECT * INTO receipt FROM gymbro_mcp.operations WHERE user_id=owner AND operations.idempotency_key=$3;
  IF FOUND THEN
   IF receipt.operation<>operation OR receipt.request<>request THEN RAISE EXCEPTION 'Idempotency conflict' USING ERRCODE='23505'; END IF;
   RETURN receipt.result;
  END IF;
  IF EXISTS(SELECT 1 FROM gymbro_mcp.receipts WHERE user_id=owner AND receipts.idempotency_key=$3) THEN RAISE EXCEPTION 'Idempotency conflict' USING ERRCODE='23505'; END IF;
  IF jsonb_typeof(request->'entries') IS DISTINCT FROM 'array' OR jsonb_array_length(request->'entries') NOT BETWEEN 1 AND 100 THEN RAISE EXCEPTION 'Invalid entries' USING ERRCODE='22023'; END IF;
  FOR item IN SELECT value FROM jsonb_array_elements(request->'entries') LOOP
   BEGIN
    PERFORM gymbro_mcp.object_keys(item,ARRAY['milliliters','time']);
    ml:=gymbro_mcp.number_value(item->'milliliters',1.7976931348623157e308,false);
    IF ml IS NULL OR ml<=0 THEN RAISE EXCEPTION 'Invalid water quantity' USING ERRCODE='22023'; END IF;
    instant:=gymbro_mcp.measurement_time(item->'time',owner);
    IF instant>now() THEN RAISE EXCEPTION 'Future water entry' USING ERRCODE='22023'; END IF;
    day:=gymbro_mcp.day(((instant AT TIME ZONE zone)::date)::text);
   EXCEPTION WHEN invalid_parameter_value OR invalid_text_representation OR numeric_value_out_of_range THEN RAISE EXCEPTION 'entries[%]: Invalid water entry',i USING ERRCODE='22023'; END;
   PERFORM gymbro_mcp.check_days(owner,day,day);
   uid:=gen_random_uuid()::text;
   INSERT INTO public.water_logs(user_id,id,date_added,reference_date,json_data)
   VALUES(owner,uid,instant,day::timestamp AT TIME ZONE 'UTC',jsonb_build_object('milliliters',ml,'time',instant)::text);
   items:=items||jsonb_build_array(jsonb_build_object('id',uid,'milliliters',ml,'time',instant,'date',day)); i:=i+1;
  END LOOP;
  result:=jsonb_build_object('items',items);
  INSERT INTO gymbro_mcp.operations VALUES(owner,idempotency_key,operation,request,result);
  RETURN result;
 ELSIF operation='get_water_entries' THEN
  PERFORM gymbro_mcp.object_keys(request,ARRAY['ids']);
  IF jsonb_typeof(request->'ids') IS DISTINCT FROM 'array' OR jsonb_array_length(request->'ids') NOT BETWEEN 1 AND 20 THEN RAISE EXCEPTION 'Invalid IDs' USING ERRCODE='22023'; END IF;
  FOR item IN SELECT value FROM jsonb_array_elements(request->'ids') LOOP
   uid:=gymbro_mcp.text_value(item,300,true);
   SELECT gymbro_mcp.water_view(w,owner,zone) INTO raw FROM public.water_logs w WHERE w.user_id=owner AND w.id=uid AND NOT w.deleted;
   IF raw IS NULL THEN unavailable:=unavailable||jsonb_build_array(uid);
   ELSE
    day:=gymbro_mcp.day(raw->>'date'); PERFORM gymbro_mcp.check_days(owner,day,day);
    items:=items||jsonb_build_array(raw);
   END IF;
  END LOOP;
  RETURN jsonb_build_object('items',items,'unavailable',unavailable);
 ELSIF operation IN ('list_water_entries','hydration_entries') THEN
  IF operation='list_water_entries' THEN PERFORM gymbro_mcp.object_keys(request,ARRAY['from','to','cursor','limit']);
  ELSE PERFORM gymbro_mcp.object_keys(request,ARRAY['from','to']); END IF;
  first_day:=gymbro_mcp.day(request->>'from'); last_day:=gymbro_mcp.day(request->>'to');
  PERFORM gymbro_mcp.check_days(owner,first_day,last_day);
  IF request ? 'limit' THEN lim:=gymbro_mcp.number_value(request->'limit',100,true); END IF;
  IF lim IS NULL OR lim<1 THEN RAISE EXCEPTION 'Invalid limit' USING ERRCODE='22023'; END IF;
  fingerprint:=md5(operation||(request-ARRAY['cursor','limit'])::text||zone);
  IF request ? 'cursor' THEN
   BEGIN
    cursor_data:=convert_from(decode(request->>'cursor','base64'),'UTF8')::jsonb;
    cursor_time:=(cursor_data->>'time')::timestamptz; cursor_id:=cursor_data->>'id';
    IF cursor_data->>'filter' IS DISTINCT FROM fingerprint OR cursor_time IS NULL OR cursor_id IS NULL THEN RAISE EXCEPTION 'Invalid cursor'; END IF;
   EXCEPTION WHEN OTHERS THEN RAISE EXCEPTION 'Invalid cursor' USING ERRCODE='22023'; END;
  END IF;
  -- JSON time is authoritative, as in Flutter; reference_date/date_added must
  -- never let stale/imported metadata bypass the account-zone date restriction.
  SELECT COALESCE(jsonb_agg(t.view ORDER BY t.instant DESC,t.id DESC),'[]') INTO items FROM (
   SELECT v.view,(v.view->>'time')::timestamptz AS instant,v.view->>'id' AS id FROM (
    SELECT gymbro_mcp.water_view(w,owner,zone) AS view FROM public.water_logs w WHERE w.user_id=owner AND NOT w.deleted
   ) v WHERE (v.view->>'date')::date BETWEEN first_day AND last_day
   AND (cursor_time IS NULL OR ((v.view->>'time')::timestamptz,v.view->>'id')<(cursor_time,cursor_id))
   ORDER BY instant DESC,id DESC LIMIT CASE WHEN operation='hydration_entries' THEN 10001 ELSE lim+1 END
  ) t;
  IF operation='hydration_entries' THEN
   IF jsonb_array_length(items)>10000 THEN RAISE EXCEPTION 'Hydration interval too large; narrow dates' USING ERRCODE='22023'; END IF;
   RETURN jsonb_build_object('items',items);
  END IF;
  more:=jsonb_array_length(items)>lim;
  SELECT COALESCE(jsonb_agg(v),'[]') INTO items FROM jsonb_array_elements(items) WITH ORDINALITY t(v,n) WHERE n<=lim;
  last_row:=items->(jsonb_array_length(items)-1);
  RETURN jsonb_build_object('items',items,'nextCursor',CASE WHEN more THEN encode(convert_to(jsonb_build_object('time',last_row->>'time','id',last_row->>'id','filter',fingerprint)::text,'UTF8'),'base64') ELSE NULL END);
 END IF;
 RAISE EXCEPTION 'Unknown operation' USING ERRCODE='22023';
END $$;
REVOKE ALL ON FUNCTION gymbro_mcp.water_view(public.water_logs,uuid,text),gymbro_mcp.water(text,jsonb,uuid) FROM PUBLIC,anon,authenticated,gymbro_mcp_user;

-- Preserve catalog search, measurements, complete routines and the OAuth guard.
ALTER FUNCTION public.mcp_execute(text,jsonb,uuid) RENAME TO mcp_execute_before_hydration;
REVOKE ALL ON FUNCTION public.mcp_execute_before_hydration(text,jsonb,uuid) FROM PUBLIC,anon,authenticated,gymbro_mcp_user;
CREATE FUNCTION public.mcp_execute(operation text, request jsonb DEFAULT '{}', idempotency_key uuid DEFAULT NULL) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
DECLARE owner uuid:=gymbro_mcp.owner(); result jsonb; water jsonb; BEGIN
 IF operation IN ('list_water_entries','get_water_entries','log_water') THEN RETURN gymbro_mcp.water(operation,request,idempotency_key); END IF;
 IF operation IN ('get_hydration_summary','get_nutrition_summary') THEN
  result:=public.mcp_execute_before_hydration('get_nutrition_summary',request,NULL);
  water:=gymbro_mcp.water('hydration_entries',request,NULL);
  RETURN result||jsonb_build_object('waterEntries',water->'items');
 END IF;
 RETURN public.mcp_execute_before_hydration(operation,request,idempotency_key);
END $$;
REVOKE ALL ON FUNCTION public.mcp_execute(text,jsonb,uuid) FROM PUBLIC,anon,authenticated;
GRANT EXECUTE ON FUNCTION public.mcp_execute(text,jsonb,uuid) TO gymbro_mcp_user;
COMMIT;
