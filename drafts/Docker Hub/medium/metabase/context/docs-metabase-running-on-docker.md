# Metabase: Running Metabase on Docker (docs)

**Source URL(s):** https://www.metabase.com/docs/latest/installation-and-operation/running-metabase-on-docker (named reference in plan.md; no URL in draft.md)
**Fetched:** 2026-11-26

## Port
- Serves on port 3000 inside the container. Default mapping `-p 3000:3000`. Host port may differ (`-p 12345:3000`).
- `MB_JETTY_PORT`: not mentioned on this page (Jetty options are on a separate page).

## Images and tags
- Open source: `metabase/metabase:v0.65.7` (tags begin `v0.`). Enterprise: `metabase/metabase-enterprise:v1.65.7`.
- Pin a fixed tag; `latest` moves with major versions.

## Env vars
- `MB_DB_TYPE` (e.g. `postgres`), `MB_DB_DBNAME`, `MB_DB_PORT` (e.g. 5432), `MB_DB_USER`, `MB_DB_PASS`, `MB_DB_HOST`, `MB_DB_CONNECTION_URI`.
- `MB_DB_FILE`: H2 file path (e.g. `/metabase-data/metabase.db` or `/metabase.db`).
- `JAVA_TIMEZONE` (e.g. `US/Pacific`), read by the launch script.
- `MUID`, `MGID`: IDs to align file permissions with the host.
- `MB_PREMIUM_EMBEDDING_TOKEN`: Pro/Enterprise license token.
- `JAVA_OPTS`: not mentioned on this page.

## `_FILE` secret variants
Append `_FILE` and point at a file (e.g. `MB_DB_PASS_FILE: /run/secrets/db_password`). Supported: `MB_DB_USER`, `MB_DB_PASS`, `MB_DB_CONNECTION_URI`, `MB_EMAIL_SMTP_PASSWORD`, `MB_EMAIL_SMTP_USERNAME`, `MB_LDAP_PASSWORD`, `MB_LDAP_BIND_DN`.

## Default H2 database
- Embedded H2 on the filesystem. Default path in the container: `/metabase.db/metabase.db.mv.db`.
- Not suitable for production; removing the container loses data.
- Change location with `MB_DB_FILE` and a volume, e.g. `-v ~/metabase-data:/metabase-data -e MB_DB_FILE=/metabase-data/metabase.db`.

## Volumes and paths
- `/metabase.db`: default H2 directory.
- `/metabase-data`: example persistence mount.
- `/plugins`: external JARs (drivers); host dir must be readable and writable.
- `/run/secrets/...`: secret files.

## User
No fixed user; `MUID`/`MGID` set the IDs used.

## Java version
Not stated.

## Run examples
- Quick: `docker run -d -p 3000:3000 --name metabase metabase/metabase:v0.65.7`.
- Postgres: `-e MB_DB_TYPE=postgres -e MB_DB_DBNAME=metabaseappdb -e MB_DB_PORT=5432 -e MB_DB_USER=... -e MB_DB_PASS=... -e MB_DB_HOST=...`.
- Host-owned H2: `-v ~/my-metabase-db:/metabase.db -e MB_DB_FILE=/metabase.db -e MUID=$UID -e MGID=$GID`.
- Timezone: `-e JAVA_TIMEZONE=US/Pacific`.
- Plugins: `--mount type=bind,source=/path/to/plugins,destination=/plugins`.

## Compose notes
- Healthcheck: `curl --fail -I http://localhost:3000/api/health || exit 1` (interval 15s, timeout 5s, retries 5).
- Postgres examples: `postgres:16`; secrets example uses `POSTGRES_USER_FILE` and `POSTGRES_PASSWORD_FILE`.
- Compose examples are not for production.
