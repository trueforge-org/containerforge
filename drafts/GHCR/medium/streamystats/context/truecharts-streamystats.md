# TrueCharts chart: streamystats (stable)

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/streamystats/values.yaml , .../Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `streamystats` v3.0.0, library `common` 32.8.5, appVersion 2.22.3, category media.
- Aggregates/visualizes watch history from Jellyfin, Emby, Plex. Two workloads: main (Next.js UI) and jobserver.

## Images (values.yaml)
| role | repository | tag |
| --- | --- | --- |
| main | ghcr.io/fredrikburmester/streamystats-nextjs | v2.22.3@sha256:251d4ad094946d9711922b38878aacad0721c1f0db43c042df172f98a4294732 |
| jobServerImage | ghcr.io/fredrikburmester/streamystats-job-server | v2.22.3@sha256:9bce17604d1a853044871edf53f8edcecf4e4139c46589c9f43521df37508b13 |

pullPolicy: IfNotPresent for both.

## Ports
| service | name | port | proto |
| --- | --- | --- | --- |
| main | main | 3000 | http |
| jobserver | main | 3005 | http |

## Env
| workload.container | var | value |
| --- | --- | --- |
| main | NODE_ENV | production |
| main | HOSTNAME | 0.0.0.0 |
| main | PORT | service.main port (3000) |
| main | DATABASE_URL | secretKeyRef `<release>-postgresqlcreds` key `url` |
| main | JOB_SERVER_URL | `http://<release>-jobserver.<ns>.svc.cluster.local:3005` |
| main | SESSION_SECRET | secretKeyRef `env-secrets` key SESSION_SECRET |
| jobserver | NODE_ENV | production |
| jobserver | PORT | 3005 |
| jobserver | HOST | 0.0.0.0 |
| jobserver | DATABASE_URL | secretKeyRef as above |
| jobserver | SESSION_SECRET | secretKeyRef as above |
| jobserver | SESSION_POLL_INTERVAL_MS | 5000 |
| jobserver | CRON_ACTIVITY_SYNC | */1 * * * * |
| jobserver | CRON_RECENT_ITEMS_SYNC | */1 * * * * |
| jobserver | CRON_USER_SYNC | */1 * * * * |
| jobserver | CRON_PEOPLE_SYNC | */15 * * * * |
| jobserver | CRON_EMBEDDINGS_SYNC | */15 * * * * |
| jobserver | CRON_GEOLOCATION_SYNC | */5 * * * * |
| jobserver | CRON_FINGERPRINT_SYNC | 0 4 * * * |
| jobserver | CRON_JOB_CLEANUP | */1 * * * * |
| jobserver | CRON_OLD_JOB_CLEANUP | 0 3 * * * |
| jobserver | CRON_FULL_SYNC | 0 2 * * * |
| jobserver | CRON_DELETED_ITEMS_CLEANUP | 0 * * * * |
| jobserver | SKIP_STARTUP_FULL_SYNC | "false" |

## Probes (chart)
- main: liveness/readiness/startup HTTP path `/api/health`
- jobserver: liveness/readiness/startup path `/health` on port 3005

## Secrets / deps
- `streamystats.sessionSecret` default `"change-me"` (chart comment: chart refuses to start without a real one; generate with `openssl rand -base64 48`). Stored in secret `env-secrets` key SESSION_SECRET.
- postgresql enabled: username `postgres`, database `streamystats`.

## Security context (chart values)
- runAsNonRoot false, runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false.
