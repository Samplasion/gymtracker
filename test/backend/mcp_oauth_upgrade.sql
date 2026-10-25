-- Executed around the OAuth-only migration by the disposable harness.
\set ON_ERROR_STOP on
INSERT INTO auth.users(id,email,raw_user_meta_data) VALUES
 ('00000000-0000-0000-0000-000000000901','upgrade-zone@unit.test','{"username":"upgradezone"}'),
 ('00000000-0000-0000-0000-000000000902','upgrade-invalid@unit.test','{"username":"upgradeinvalid"}');
INSERT INTO gymbro_mcp.consents VALUES
 ('00000000-0000-0000-0000-000000000901','00000000-0000-0000-0000-000000000090',2,'Europe/Rome',now()),
 ('00000000-0000-0000-0000-000000000902','00000000-0000-0000-0000-000000000090',2,'invalid/zone',now());
