-- Account statistics follow the history shown in the app. Continuations are
-- implementation details of their original workout, including orphaned ones.
CREATE OR REPLACE FUNCTION public.get_user_stats()
RETURNS json
LANGUAGE sql
STABLE
SECURITY INVOKER
SET search_path = ''
AS $function$
    WITH RECURSIVE visible_workouts AS (
        SELECT starting_date
        FROM public.history_workouts
        WHERE user_id = (SELECT auth.uid())
          AND NOT deleted
          AND completes IS NULL
    ), week_streak AS (
        SELECT date_trunc('week', CURRENT_DATE)::timestamp AS week_start,
               0 AS streak
        UNION ALL
        SELECT ws.week_start - INTERVAL '1 week', ws.streak + 1
        FROM week_streak ws
        WHERE EXISTS (
            SELECT 1 FROM visible_workouts hw
            WHERE hw.starting_date >= ws.week_start
              AND hw.starting_date < ws.week_start + INTERVAL '1 week'
        )
    )
    SELECT json_build_object(
        'workouts', (SELECT COUNT(*) FROM visible_workouts),
        'foods', (SELECT COUNT(*) FROM public.foods
                  WHERE user_id = (SELECT auth.uid()) AND NOT deleted),
        'weeks', (SELECT COALESCE(MAX(streak), 0) FROM week_streak)
    );
$function$;

REVOKE EXECUTE ON FUNCTION public.get_user_stats() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.get_user_stats() TO authenticated;
