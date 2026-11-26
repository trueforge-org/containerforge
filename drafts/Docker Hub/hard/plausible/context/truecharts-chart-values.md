# TrueCharts plausible chart values

Source URL: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/plausible/values.yaml (fetched)
Chart page: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/plausible (not fetched)

- Image: docker.io/plausible/analytics:v2.0.0 (sha256 pinned), pullPolicy IfNotPresent. NOTE: upstream CE repo tag is v3.2.2 (ghcr.io/plausible/community-edition); chart is older.
- Main service port 10277 -> PORT env
- plausible config: secretKeyBase placeholder (>=64 chars must change); base_url http://localhost:10277; disable_registration "true"; log_failed_login_attempts false; log_level warn; clickhouse_flush_interval_ms 5000; clickhouse_max_buffer_size 10000
- Mail: mailer_email hello@plausible.local; smtp localhost:25; SSL off; smtp_retries 2; adapter Bamboo.SMTPAdapter; Postmark/Mailgun/Mandrill/Sendgrid empty
- MaxMind: license_key empty; edition GeoLite2-City. Google client id/secret empty
- Env from configMap plausible-config and secret plausible-secret
- Persistence: none defined
- Probes: liveness/readiness HTTP /api/health; startup TCP
- securityContext main and init: runAsUser 1000, runAsGroup 1000, readOnlyRootFilesystem false
- Init containers: db-create (`/entrypoint.sh db createdb && /entrypoint.sh db migrate`), db-migrate (`/entrypoint.sh db migrate`)
- Deps: postgresql (user/db plausible), clickhouse (user/db plausible)
