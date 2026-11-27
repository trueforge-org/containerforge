# TrueCharts chart: romm

**Source URL(s):** https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/romm/values.yaml (10.7 KB, full read) , .../Chart.yaml · fetched 2026-11-27

## What it is
- Chart `romm` (appVersion 5.4.1), train stable, category media. Game library manager for retro games.
- Dependencies: `common` 32.8.5; `postgresql` (enabled, db/user `romm`); `valkey` (enabled).

## Image
- repository: `ghcr.io/rommapp/romm`
- tag: `5.4.1@sha256:8677fb7b81b1d3db20b849e989a1dadc2a11159e51eb34a2acdcb01102274edf` (pullPolicy IfNotPresent)

## Ports
| name | port | proto |
| --- | --- | --- |
| main | 10680 | http |

## Env (chart-set, active)
| var | value |
| --- | --- |
| ROMM_AUTH_SECRET_KEY | secretKeyRef env-secrets/ROMM_AUTH_SECRET_KEY (placeholder `CHANGE_ME-...` in chart secret) |
| SCAN_WORKERS | 4 |
| ROMM_PORT | `{{ service.main.ports.main.port }}` (10680) |
| ROMM_BASE_URL | `{{ chartContext.appUrl }}` |
| LOGLEVEL | INFO |
| ROMM_DB_DRIVER | postgresql |
| DB_HOST | `{{ dependencies.postgresql.depconfig.creds.plainhost }}` (quotes trimmed) |
| DB_PORT | 5432 |
| DB_NAME | `{{ dependencies.postgresql.depconfig.postgresqlDatabase }}` (romm) |
| DB_USER | `{{ dependencies.postgresql.depconfig.postgresqlUsername }}` (romm) |
| DB_PASSWD | secretKeyRef `<release>-postgresqlcreds` / `postgresql-password` |
| REDIS_HOST | `{{ dependencies.valkey.depconfig.creds.plainhost }}` (quotes trimmed) |
| REDIS_PORT | 6379 |
| REDIS_USERNAME | default |
| REDIS_PASSWORD | secretKeyRef `<release>-valkeycreds` / `valkey-password` |
| IGDB_CLIENT_ID | "" |
| IGDB_CLIENT_SECRET | secretKeyRef env-secrets/IGDB_CLIENT_SECRET (empty) |

Commented-out options in chart (names only): DB_QUERY_JSON, REDIS_DB, REDIS_SSL, OIDC_REDIRECT_URI, DISABLE_CSRF_PROTECTION, DISABLE_DOWNLOAD_ENDPOINT_AUTH, DISABLE_USERPASS_LOGIN, SESSION_MAX_AGE_SECONDS (1209600), KIOSK_MODE, SCAN_TIMEOUT (14400), TASK_TIMEOUT (300), TASK_RESULT_TTL (86400), SEVEN_ZIP_TIMEOUT (60), DISABLE_EMULATOR_JS, DISABLE_RUFFLE_RS, YOUTUBE_BASE_URL, ROMM_BASE_PATH (/romm/), FORCE_COLOR, NO_COLOR, WEB_SERVER_* (CONCURRENCY 1, KEEPALIVE 2, MAX_REQUESTS 1000, MAX_REQUESTS_JITTER 100, TIMEOUT 300, WORKER_CONNECTIONS 1000), library rescan options.

## Persistence
| name | mountPath |
| --- | --- |
| library | /romm/library |
| resources | /romm/resources |
| config | /romm/config |
| assets | /romm/assets |

## Secret (chart defaults)
- `env-secrets`: ROMM_AUTH_SECRET_KEY = `CHANGE_ME-CHANGE_ME-CHANGE_ME-CHANGE_ME-CHANGE_ME-CHANGE_ME`; IGDB_CLIENT_SECRET = "".

## Probes
- liveness, readiness, startup: type http (no path set).

## Security context (chart)
- runAsUser 0, runAsGroup 0, runAsNonRoot false, readOnlyRootFilesystem false.

## Gotchas
- Chart pins `ROMM_DB_DRIVER: postgresql`; image also supports mariadb and mysql.
- Chart `ROMM_AUTH_SECRET_KEY` default is a placeholder, must be replaced (chart comment: `openssl rand -hex 32`).
- Image EXPOSEs 8080; chart uses 10680 via ROMM_PORT.
