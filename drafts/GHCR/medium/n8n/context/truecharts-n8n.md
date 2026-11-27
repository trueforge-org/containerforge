# TrueCharts chart: n8n (stable)

Source URL(s) + date:
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/n8n/values.yaml (2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/n8n/Chart.yaml (2026-11-27)

What it is: TrueCharts Helm chart for n8n, "extendable workflow automation tool". Chart `version: 25.1.1`, `appVersion: 3.4.1`. Depends on `common` 32.8.5 (oci://oci.trueforge.org/truecharts). kubeVersion >=1.33.0-0.

Image (values.yaml):
- repository `ghcr.io/n8n-io/n8n` (GHCR, not Docker Hub)
- tag `3.4.1@sha256:95f4fabd308669b35761ccf5b0d0a63526da06135e7e44d19d14694dbfd340be`
- pullPolicy IfNotPresent

Runtime deps (chart-managed, not in image):
- PostgreSQL (`dependencies.postgresql.enabled: true`, user `n8n`, db `n8n`)
- Valkey (`dependencies.valkey.enabled: true`), used as Bull queue (`QUEUE_BULL_REDIS_*`)

Env vars (set by chart workload.main, not exhaustive):
| Name | Value/source |
| --- | --- |
| GENERIC_TIMEZONE | `{{ .Values.TZ }}` |
| DB_TYPE | `postgresdb` |
| DB_POSTGRESDB_USER | `n8n` |
| DB_POSTGRESDB_DATABASE | `n8n` |
| DB_POSTGRESDB_PORT | 5432 |
| DB_POSTGRESDB_HOST | secret `<release>-postgresqlcreds` key `plainhost` |
| DB_POSTGRESDB_PASSWORD | secret `<release>-postgresqlcreds` key `postgresql-password` |
| QUEUE_BULL_REDIS_PORT | 6379 |
| QUEUE_BULL_REDIS_HOST | secret `<release>-valkeycreds` key `plainhost` |
| QUEUE_BULL_REDIS_PASSWORD | secret `<release>-valkeycreds` key `valkey-password` |
| N8N_USER_FOLDER | `/data` |
| N8N_HOST | `localhost` (deployment values) |
| N8N_LOG_FILE_LOCATION | `/data/logs` |
Commented-out defaults in values: N8N_ENCRYPTION_KEY, WEBHOOK_URL, N8N_EDITOR_BASE_URL, N8N_BASIC_AUTH_*, EXECUTIONS_*, N8N_LOG_LEVEL (default "info"), N8N_METRICS.

Ports: service main `port 5678`, `targetPort 5678`.

Volumes/paths: persistence `data`, enabled, mountPath `/data` (this is N8N_USER_FOLDER).

User/UID: chart sets `securityContext.container.runAsUser: 0`, `runAsNonRoot: false`, `readOnlyRootFilesystem: false`, pod `fsGroup: 1000`. (Chart runs as root; upstream image runs as `node`.)

Healthcheck: liveness, readiness and startup probes all `path: "/healthz"`.

Gotchas:
- Chart's `/data` path differs from the upstream image's `/home/node/.n8n`; the chart relies on `N8N_USER_FOLDER`.
- Chart pins image by digest and tag 3.4.1; the sibling draft tag 3.3.0 is not what TrueCharts ships.
