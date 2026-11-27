# Miniflux docs (Docker install + configuration)

## Source URL(s) + date
- https://miniflux.app/docs (nav only, no content)
- https://miniflux.app/docs/docker.html
- https://miniflux.app/docs/configuration.html
- Fetched 2026-11-26

## Docker images
- Registries: `docker.io/miniflux/miniflux`, `ghcr.io/miniflux/miniflux`, `quay.io/miniflux/miniflux`.
- Arch: amd64, arm64, arm/v7, arm/v6.
- Tags: `latest` (stable), `2.0.25` style (specific), `nightly` (dev). Docs recommend pinned version.

## Run (docker)
- `docker run -p 80:8080 -e DATABASE_URL=postgres://miniflux:<pw>@<dbhost>/miniflux?sslmode=disable -e RUN_MIGRATIONS=1 -e CREATE_ADMIN=1 -e ADMIN_USERNAME=... -e ADMIN_PASSWORD=... <image>`.
- Container listens on 8080.
- Compose healthcheck: `["CMD", "/usr/bin/miniflux", "-healthcheck", "auto"]`.
- Compose DB example uses postgres:18 with `POSTGRES_USER/PASSWORD/DB=miniflux`; PGDATA volume path `/var/lib/postgresql` for PG18 (`/var/lib/postgresql/data` for 17 and below).

## Config (env vars; _FILE variants read secrets from files)
| Name | Default / note |
| --- | --- |
| DATABASE_URL | `user=postgres password=postgres dbname=miniflux2 sslmode=disable` (default) |
| DATABASE_MAX_CONNS / MIN_CONNS | 20 / 1 |
| RUN_MIGRATIONS | run SQL migrations on start |
| CREATE_ADMIN, ADMIN_USERNAME, ADMIN_PASSWORD | create first admin (removable after init); default empty |
| BASE_URL | default `http://localhost`; path component sets subfolder base |
| LISTEN_ADDR | 0.0.0.0:8080 (from Dockerfile ENV) |
| DISABLE_HTTP_SERVICE | false |
| DISABLE_SCHEDULER_SERVICE | false |
| DISABLE_API | false |
| DISABLE_HSTS | false |
| DISABLE_LOCAL_AUTH | false (needs OAuth2/auth proxy/passkey alternative) |
| CERT_DOMAIN | Let's Encrypt domain; listens on port 80 for ACME |
| CERT_FILE / KEY_FILE | TLS cert/key paths |
| BATCH_SIZE | 100 feeds per interval |
| CLEANUP_FREQUENCY_HOURS | 24 |
| CLEANUP_ARCHIVE_READ_DAYS | 60 (-1 disables) |
| CLEANUP_ARCHIVE_UNREAD_DAYS | 180 (-1 disables) |
| CLEANUP_REMOVE_SESSIONS_DAYS | 30 |
| FETCHER_ALLOW_PRIVATE_NETWORKS | 0 (private networks refused) |
| FETCH_YOUTUBE_WATCH_TIME (and Bilibili/Nebula/Odysee) | disabled |
| AUTH_PROXY_HEADER / AUTH_PROXY_USER_CREATION | empty / disabled |

## Gotchas
- Config options are env vars; a config file is optional and env wins over it.
- Boolean env values accept 1/0, yes/no, true/false, on/off.
- Docs list the default `DATABASE_URL` as a libpq-style string, not a URL; the Docker example uses URL form.
- Docs page `docker.html` says the example tag `2.0.25` (docs version), not the chart's 2.3.5.
