BEGIN;
CREATE TABLE public.admin_console_audit (
 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 delivery_id bigint NOT NULL, actor uuid NOT NULL, note text NOT NULL,
 created_at timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE public.admin_console_audit ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.admin_console_audit FROM PUBLIC, anon, authenticated;
GRANT SELECT, INSERT ON public.admin_console_audit TO service_role;
GRANT USAGE, SELECT ON SEQUENCE public.admin_console_audit_id_seq TO service_role;

CREATE FUNCTION public.admin_transition_report(report_id uuid, expected_status text,
 expected_updated_at timestamptz, next_status text, note text) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
BEGIN
 IF expected_status IS NULL OR next_status IS NULL OR expected_updated_at IS NULL OR note IS NULL OR char_length(btrim(note)) NOT BETWEEN 1 AND 2000 OR
 NOT ((expected_status='received' AND next_status='reviewing') OR
 (expected_status='reviewing' AND next_status IN ('resolved','dismissed'))) THEN
 RAISE EXCEPTION 'Invalid transition or note' USING ERRCODE='22023'; END IF;
 UPDATE public.reports SET status=next_status WHERE id=report_id
 AND status=expected_status AND updated_at=expected_updated_at;
 IF NOT FOUND THEN RAISE EXCEPTION 'Report changed or deleted' USING ERRCODE='40001'; END IF;
 INSERT INTO public.report_notes(report_id,body) VALUES(report_id,note);
END; $$;

CREATE FUNCTION public.admin_requeue_push(delivery_id bigint, expected_attempts integer,
 expected_available_at timestamptz, operator_id uuid, note text) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $$
DECLARE d public.push_deliveries;
BEGIN
 IF operator_id IS NULL OR note IS NULL OR char_length(btrim(note)) NOT BETWEEN 1 AND 2000 THEN
 RAISE EXCEPTION 'Invalid operator or note' USING ERRCODE='22023'; END IF;
 SELECT * INTO d FROM public.push_deliveries WHERE id=delivery_id FOR UPDATE;
 IF NOT FOUND THEN RAISE EXCEPTION 'Delivery changed or deleted' USING ERRCODE='40001'; END IF;
 -- Only explicit provider rejection is safe to retry. Transport failures and a
 -- lease expiry may conceal an accepted send; retry_limit_reached is ambiguous.
 IF d.attempts IS DISTINCT FROM expected_attempts OR d.available_at IS DISTINCT FROM expected_available_at OR
 d.attempts<8 OR (d.lease_until IS NOT NULL AND d.lease_until>now()) OR
 d.lease_id IS NOT NULL OR d.last_error IS NULL OR
 d.last_error !~ '^FCM (429|500|502|503|504): [A-Z_]+$' OR
 NOT EXISTS(SELECT 1 FROM public.notifications n JOIN public.push_devices p ON p.id=d.device_id
 WHERE n.id=d.notification_id AND p.user_id=n.user_id AND public.notification_visible(n,n.user_id)) THEN
 RAISE EXCEPTION 'Delivery is not eligible for requeue' USING ERRCODE='40001'; END IF;
 UPDATE public.push_deliveries SET attempts=0,finished_at=NULL,lease_until=NULL,
 lease_id=NULL,available_at=now() WHERE id=d.id;
 INSERT INTO public.admin_console_audit(delivery_id,actor,note) VALUES(d.id,operator_id,note);
END; $$;

-- Counts are grouped on the server across all open reports, never one page.
CREATE FUNCTION public.admin_catalog_report_counts(product_id uuid) RETURNS jsonb
LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $$
 SELECT coalesce(jsonb_agg(to_jsonb(c)),'[]'::jsonb) FROM (
 SELECT r.epoch,r.reason,count(*) AS count,
 CASE WHEN r.reason IN ('spam','inappropriate') THEN 5 ELSE 10 END AS threshold
 FROM public.food_catalog_reports r WHERE r.food_id=product_id AND r.status='open'
 GROUP BY r.epoch,r.reason ORDER BY r.epoch,r.reason) c;
$$;
REVOKE ALL ON FUNCTION public.admin_transition_report(uuid,text,timestamptz,text,text),
 public.admin_requeue_push(bigint,integer,timestamptz,uuid,text),
 public.admin_catalog_report_counts(uuid) FROM PUBLIC,anon,authenticated;
GRANT EXECUTE ON FUNCTION public.admin_transition_report(uuid,text,timestamptz,text,text),
 public.admin_requeue_push(bigint,integer,timestamptz,uuid,text),
 public.admin_catalog_report_counts(uuid) TO service_role;
COMMIT;
