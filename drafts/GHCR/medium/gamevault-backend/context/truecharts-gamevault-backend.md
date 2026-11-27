# TrueCharts chart: gamevault-backend

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/gamevault-backend/values.yaml (fetched 2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/gamevault-backend/Chart.yaml (fetched 2026-11-27)

## What it is
- Chart for the GameVault backend (self-hosted game library server). Requires PostgreSQL (chart dependency).

## Image
- `repository: ghcr.io/phalcode/gamevault-backend`
- `tag: 17.2.0@sha256:a2d4fe2cb4bc6cc0cd6badb57162692b108a25a4dd7ac839ddeadfd3454ecf48`
- `pullPolicy: IfNotPresent`

## Env vars (chart `workload.main.podSpec.containers.main.env`)
| Name | Chart value |
| --- | --- |
| VOLUMES_FILES | `/games` (persistence.games.mountPath) |
| VOLUMES_IMAGES | `/media` (persistence.images.mountPath) |
| VOLUMES_LOG | `/logs` (persistence.logs.mountPath) |
| DB_SYSTEM | `POSTGRESQL` |
| DB_PORT | `5432` |
| DB_HOST | secretKeyRef `<release>-postgresqlcreds`/`plainhost` |
| DB_DATABASE | `gamevault` |
| DB_USERNAME | `gamevault` |
| DB_PASSWORD | secretKeyRef `<release>-postgresqlcreds`/`postgresql-password` |
| SERVER_ADMIN_USERNAME | `admin` |
| SERVER_ADMIN_PASSWORD | secretKeyRef `env-secrets`/`SERVER_ADMIN_PASSWORD` (default `password`) |
| SERVER_REGISTRATION_DISABLED | `false` |
| SERVER_ACCOUNT_ACTIVATION_DISABLED | `false` |
| SERVER_LOG_LEVEL | `info` |
| SERVER_CORS_ALLOWED_ORIGINS | `*` |
| GAMES_INDEX_INTERVAL_IN_MINUTES | `5` |
| GAMES_SEARCH_RECURSIVE | `true` |
| GAMES_SUPPORTED_FILE_FORMATS | `.7z` |
| IMAGE_GC_KEEP_DAYS | `30` |
| IMAGE_GC_INTERVAL_MINUTES | `60` |
| RAWG_API_URL | `https://api.rawg.io/api` |
| RAWG_API_CACHE_DAYS | `7` |
| RAWG_API_KEY | secretKeyRef `env-secrets`/`RAWG_API_KEY` (default empty) |

## Ports
- Service `main`: http, port 8080, targetPort 8080.
- Upstream ENV: `SERVER_PORT=8080`, `SERVER_HTTPS_PORT=8443`. Dockerfile `EXPOSE ${SERVER_PORT}/tcp` and `EXPOSE ${SERVER_HTTPS_PORT}/tcp`.

## Volumes/paths
- Chart persistence: `logs` -> `/logs`, `images` -> `/media`, `games` -> `/games`.
- Dockerfile creates `/config /files /media /logs /db /plugins /savefiles` (chmod 777 in build, chown node in build).

## User/UID
- Chart: `runAsUser: 0`, `runAsGroup: 0`, `runAsNonRoot: false`, `readOnlyRootFilesystem: false`.
- Upstream: `PUID=1000`, `PGID=1000`. Entrypoint runs as root only if started as root, then `chown`s dirs and `exec sudo -u "#${PUID}" -g "#${PGID}" -E node "$@"`. If not root, runs `exec node "$@"`.

## Config files
- None in chart. Admin/RAWG secrets are in `env-secrets`.

## Healthcheck
- Chart probes (liveness/readiness/startup): HTTP `/api/v1/health`.
- Dockerfile HEALTHCHECK: `--start-period=300s CMD curl -f http://localhost:${SERVER_PORT}/api/status || exit 1`. Endpoint differs from the chart probe path.

## Gotchas
- Chart probe path `/api/v1/health` vs Dockerfile healthcheck `/api/status`.
- Chart runs as root (uid 0) and relies on the entrypoint for PUID/PGID drop.
- Chart dependency: PostgreSQL (`dependencies.postgresql`, db/user `gamevault`).
