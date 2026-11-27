# docs.invidious.io/installation (Docker, production)

Source URL(s): https://docs.invidious.io/installation (301 to http://docs.invidious.io/installation/ , then fetched 2026-11-27, WebFetch summary)

## Prereqs
- Docker Engine + Docker Compose V2. Clone repo (postgres mounts config/sql and docker/init-invidious-db.sh).

## Images
- quay.io/invidious/invidious:latest (Quay only)
- quay.io/invidious/invidious-companion:latest
- docker.io/library/postgres:14

## Services / ports
- invidious: 127.0.0.1:3000:3000 (drop 127.0.0.1 for external). restart unless-stopped; depends_on invidious-db.
- companion: 8282 port commented out by default; enable 127.0.0.1:8282:8282 only if public_url or API use.
- invidious-db: no host ports.

## Config (INVIDIOUS_CONFIG env YAML, no config.yml)
- db: dbname invidious, user kemal, password kemal, host invidious-db, port 5432
- check_tables: true
- invidious_companion.private_url: http://companion:8282/companion
- invidious_companion_key: second generated secret ; hmac_key: first generated secret (pwgen 16 1, run twice)
- Optional: external_port, domain, https_only, statistics_enabled

## Companion
- SERVER_SECRET_KEY must equal invidious_companion_key. cap_drop ALL, read_only true, no-new-privileges.
- Volume companioncache:/var/tmp/youtubei.js:rw

## Postgres
- POSTGRES_DB invidious, POSTGRES_USER kemal, POSTGRES_PASSWORD kemal
- Volumes: postgresdata:/var/lib/postgresql/data ; ./config/sql:/config/sql ; ./docker/init-invidious-db.sh:/docker-entrypoint-initdb.d/init-invidious-db.sh
- Healthcheck: pg_isready -U $$POSTGRES_USER -d $$POSTGRES_DB

## Invidious healthcheck
- wget -nv --tries=1 --spider http://127.0.0.1:3000/api/v1/stats || exit 1 ; interval 30s, timeout 5s, retries 2

## Logging / volumes
- logging max-size 1G, max-file 4. Named volumes: postgresdata, companioncache.

## Gotchas
- Restart Invidious often (daily or hourly). Behind reverse proxy set https_only, domain, external_port.
- Docs use kemal/kemal placeholder DB creds; chart uses postgresql depconfig (kemal user).
