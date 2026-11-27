# bitmagnet docs (bitmagnet.io)

## Source URL(s) + date
- https://bitmagnet.io (home, fetched 2026-11-27)
- https://bitmagnet.io/setup/installation.html (follow-up, fetched 2026-11-27)
- https://bitmagnet.io/setup/configuration.html (follow-up, fetched 2026-11-27)

## What it is
- Self-hosted BitTorrent indexer, DHT crawler, classifier, search with web UI, GraphQL API, Servarr integration.
- Status: alpha; API and DB schema may change before 1.0.

## Install/build steps
- Docker Compose is the recommended path (example below). Native: `go install github.com/bitmagnet-io/bitmagnet`, needs a Postgres instance.

## Runtime deps
- PostgreSQL 16 (compose example: `postgres:16-alpine`, `shm_size: 1g`, `pg_isready` healthcheck).
- Optional: TMDB API key (`TMDB_API_KEY`).

## Entrypoint/flags
- Command in compose example: `worker run --keys=http_server --keys=queue_server --keys=dht_crawler` (the dht_crawler key is optional).
- CLI: `bitmagnet` binary is the entrypoint.

## Env vars (documented in compose example)
| Name | Example value |
| --- | --- |
| POSTGRES_HOST | postgres |
| POSTGRES_PASSWORD | postgres |
| TMDB_API_KEY | your_api_key (commented out) |

## Config keys (configuration page; env mapping not documented)
- postgres.host (localhost), postgres.name (bitmagnet), postgres.user (postgres), postgres.password (empty), postgres.dsn (overrides others)
- tmdb.api_key, tmdb.enabled (true)
- dht_crawler.save_files_threshold (100), dht_crawler.save_pieces (false)
- log.level (info), log.json (false), log.development (false)
- http_server.options (default ["*"])

## Ports
- 3333 (API and web UI, http)
- 3334 tcp and udp (BitTorrent)

## Volumes/paths
- Compose: `./config:/root/.config/bitmagnet` (config directory)
- Compose: `./data/postgres:/var/lib/postgresql/data` (postgres service)

## User/UID
- Not stated.

## Gotchas
- Compose example uses `ghcr.io/bitmagnet-io/bitmagnet:latest`; upgrade by pull and up.
- DHT crawler starts with default run keys; items appear in UI within about a minute.
