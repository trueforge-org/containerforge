# TrueCharts bitmagnet (stable chart v7.0.0, appVersion 0.10.1)

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/bitmagnet/values.yaml (fetched 2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/bitmagnet/Chart.yaml (fetched 2026-11-27)

## What it is
- "A self-hosted BitTorrent indexer, DHT crawler, content classifier and torrent search engine with web UI, GraphQL API and Servarr stack integration."
- Chart sources: bitmagnet.io, ghcr.io/bitmagnet-io/bitmagnet, github repo.
- Dependency: `common` 32.8.5; plus subchart `postgresql` (enabled, depconfig user/db = bitmagnet).

## Image
- repository: `ghcr.io/bitmagnet-io/bitmagnet`
- tag: `v0.10.1@sha256:b6373349a30193b436ce6b05e21f91aa4934074268105dded1f3b065b8c86f19` (chart tag; differs from 0.10.0 latest stable, see github-bitmagnet.md)

## Args / command
- args: `worker`, `run`, `--all`

## Env vars (chart)
| Name | Value |
| --- | --- |
| POSTGRES_NAME | postgresql depconfig database (bitmagnet) |
| POSTGRES_USER | postgresql depconfig username (bitmagnet) |
| POSTGRES_PASSWORD | secret `<release>-postgresqlcreds` key `postgresql-password` |
| POSTGRES_HOST | secret `<release>-postgresqlcreds` key `plainhost` |
| TMDB_API_KEY | secret env-secrets/TMDB_API_KEY (empty default) |
| DHT_CRAWLER_SAVE_FILES_THRESHOLD | "100" |

## Ports
| Service | Port | Proto |
| --- | --- | --- |
| main | 3333 | tcp (web UI/API, metrics at /metrics) |
| torrent.tcp | 3334 | tcp (enabled) |
| torrent.udp | 3334 | udp (enabled) |

## Health/metrics
- readiness, liveness, startup probes: http GET `/status` (all enabled).
- metrics: servicemonitor on port `main`, path `/metrics`.

## Volumes/paths
- none in chart (no persistence block). Configmap dashboard and grafana datasource secret are chart-only.

## Config files
- Docs (installation page): compose example mounts `./config:/root/.config/bitmagnet` (config dir for bitmagnet).

## Config keys (docs, configuration page)
- postgres.host (default localhost), postgres.name (bitmagnet), postgres.user (postgres), postgres.password (empty), postgres.dsn (overrides the rest)
- tmdb.api_key, tmdb.enabled (true)
- dht_crawler.save_files_threshold (100), dht_crawler.save_pieces (false)
- log.level (info), log.json (false), log.development (false), log.file_rotator.*
- http_server.options (default `["*"]`)

## Install/run (docs, installation page)
- Docker Compose example: `image: ghcr.io/bitmagnet-io/bitmagnet:latest`; ports `3333:3333`, `3334:3334/tcp`, `3334:3334/udp`.
- Env in compose example: `POSTGRES_HOST=postgres`, `POSTGRES_PASSWORD=postgres`, optional `TMDB_API_KEY`.
- Command: `worker run --keys=http_server --keys=queue_server --keys=dht_crawler` (dht_crawler key can be omitted).
- Postgres example: `postgres:16-alpine`, `POSTGRES_DB=bitmagnet`, `shm_size: 1g`, `pg_isready` healthcheck.
- Web UI at http://localhost:3333 after start.
- Native install: `go install github.com/bitmagnet-io/bitmagnet`.

## Gotchas
- Docs state the software is alpha; API and DB schema may change before 1.0.
- Docs state bitmagnet config keys map to postgres.* etc.; the env-var mapping for config keys is not spelled out on these pages (compose example shows POSTGRES_HOST / POSTGRES_PASSWORD / POSTGRES_DB).
- Postgres is a required external dependency (no embedded DB).
