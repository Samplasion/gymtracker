-- Deployment setup: execute after configuring pg_cron, pg_net and Vault.
-- Secrets must already exist; this script does not embed credentials.
DO $$ BEGIN
 IF NOT EXISTS(SELECT 1 FROM vault.decrypted_secrets WHERE name='social_push_worker_url')
 OR NOT EXISTS(SELECT 1 FROM vault.decrypted_secrets WHERE name='social_push_worker_secret') THEN
  RAISE EXCEPTION 'Configure social_push_worker_url and social_push_worker_secret in Vault first';
 END IF;
END; $$;
SELECT cron.schedule('gymtracker-social-push','* * * * *',$job$
 SELECT net.http_post(
   url := (SELECT decrypted_secret FROM vault.decrypted_secrets WHERE name='social_push_worker_url'),
   headers := jsonb_build_object('Content-Type','application/json','x-worker-secret',(SELECT decrypted_secret FROM vault.decrypted_secrets WHERE name='social_push_worker_secret')),
   body := '{}'::jsonb,
   timeout_milliseconds := 60000
 );
$job$);
