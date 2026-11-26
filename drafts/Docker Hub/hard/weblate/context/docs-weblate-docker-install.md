# Weblate docs: Docker install

Source URL: https://docs.weblate.org/en/latest/admin/install/docker.html (fetched 2026-11-26; page text is 189,765 chars, only first 100,000 read; upgrade/db details below are from that portion)

## Required / key env vars
| Var | Default / behavior |
| --- | --- |
| WEBLATE_SITE_DOMAIN | required; host or IPv4 (no IPv6); include non-standard port |
| WEBLATE_ADMIN_PASSWORD | unset = random password printed on first start (if admin absent); if set, admin adjusted every start |
| WEBLATE_ADMIN_NAME / WEBLATE_ADMIN_EMAIL | admin identity; feeds ADMINS |
| WEBLATE_SERVER_EMAIL | error mail sender |
| WEBLATE_DEFAULT_FROM_EMAIL | outgoing mail sender |
| WEBLATE_EMAIL_HOST / _HOST_USER / _HOST_PASSWORD | SMTP |
| WEBLATE_SECRET_KEY | Django SECRET_KEY; falls back to `/app/data/secret`; keep stable across containers (added 2026.12) |
| WEBLATE_ALLOWED_HOSTS | `*` |
| WEBLATE_ENABLE_HTTPS | off; assumes HTTPS proxy only |
| WEBLATE_IP_PROXY_HEADER | none, e.g. `HTTP_X_FORWARDED_FOR` |
| WEBLATE_TRUSTED_PROXY_ADDRESSES | empty; must be set for X-Forwarded-For (2026.9) |
| WEBLATE_LOGLEVEL | INFO (DEBUG if debug on) |
| WEBLATE_WORKERS | auto from CPU count |
| CELERY_WORKER_MODE | combined; options split, single |
| WEBLATE_SERVICE | container role for horizontal scaling |
| CLIENT_MAX_BODY_SIZE | body limit, k/m/g suffix; 0 disables |
| POSTGRES_DB / POSTGRES_PASSWORD | DB setup (values not shown) |

## Secrets
- Append `_FILE` to a var to read from file (since 5.0), e.g. `POSTGRES_PASSWORD_FILE: /run/secrets/db_password`.
- `WEBLATE_SECRET_KEY_FILE` takes precedence over direct value; unreadable file = config error.
- Own TLS: `ssl/fullchain.pem`, `ssl/privkey.pem` in data volume; owned by starting user, mode 600.
- Custom CA: `ssl/ca-certificates/*.crt` merged with system bundle on each start (2026.11).

## Volumes / ports
- `/app/data`: shared across containers when scaling (cluster FS recommended). Startup warnings stored here.
- `/app/cache`: per container.
- Port 8080 HTTP (example maps 80:8080); 4443 HTTPS (example 443:4443).

## Hardware
- Min 3 GB RAM, 2 cores, 1 GB storage; 4 GB+ recommended for hundreds of components.
- From 2026.8: NumPy required; x86-64 image needs x86-64-v2 CPU (`grep sse4_2 /proc/cpuinfo`).

## Database / cache
- PostgreSQL default DB; Valkey cache. Compose services: weblate, database, cache.
- Default PG volume: `weblate-docker_postgres-data` (project name = directory).

## Upgrades
- Pull, then `docker compose down` and `up -d`; DB migrates on first start.
- Direct upgrades supported only from current or previous calendar year releases.
- PostgreSQL not auto-upgraded: stop weblate and cache, `pg_dumpall`, remove volume, switch version, restore with psql; reset password if PG 14/15.
- PostgreSQL 18 data dir is `/var/lib/postgresql`; update mount or set PGDATA.
- Env changes need container recreate (`up -d`), not restart.
- From 2026.9 bundled nginx no longer trusts X-Forwarded-For from all addresses.

## Tags
- `latest`, `<YEAR>`, `<YEAR>.<MONTH>`, `<YEAR>.<MONTH>.<PATCH>.<BUILD>`, `edge`, `edge-<DATE>-<SHA>`, `bleeding`, `bleeding-<DATE>-<SHA>`. Docker Hub and GitHub Packages.

## Not covered (in read portion)
- Container UID/user; healthcheck; DB/cache connection var names (POSTGRES_HOST, REDIS_HOST).
