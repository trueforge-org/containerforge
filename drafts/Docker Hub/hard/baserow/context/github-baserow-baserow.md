# baserow/baserow (upstream source, all-in-one Dockerfile, release 2.4.3, premium licence)

**Source URL(s) + fetch date:** https://github.com/baserow/baserow (raw `master/README.md`; raw `deploy/all-in-one/Dockerfile` @ d897b90e9b819d4cde8b8c542f548bcdc21cd97f; https://github.com/baserow/baserow/releases/tag/2.4.3; raw `master/premium/LICENSE`); `embeddings/requirements.txt` 404 at both d897b90 and master (see README.md) · fetched 2026-11-26

## What it is
Open-source no-code platform for databases, apps, automations and AI agents (Django, Vue.js, PostgreSQL). Open-core: non-premium/non-enterprise code is MIT; `premium/` and `enterprise/` are under the Baserow Premium Edition licence (see below).

## Install/build steps and build deps (all-in-one Dockerfile at d897b90)
- ARGs: `UID=9999`, `GID=9999`, `BACKEND_IMAGE=baserow/backend`, `WEBFRONTEND_IMAGE=baserow/web-frontend`, `CADDY_VERSION=2.11.4`.
- Source images: `caddy:${CADDY_VERSION}` (binary `/usr/bin/caddy`), web-frontend image (`/usr/local/bin/node`, `/usr/local/lib/node_modules`, `/opt/yarn-v1.22.22` -> yarn symlink, `/baserow/web-frontend`), backend image (`/usr/local/bin/su-exec`, `/usr/local/bin/wasmtime`, `/usr/local/bin/mox`, `/usr/local/lib/baserow/qjs.wasm`, `/baserow/backend`, `/baserow/premium/backend`, `/baserow/enterprise/backend`, `/baserow/venv`).
- Stage `base`: `FROM python:3.14.7-slim-trixie`; bash with pipefail; ENV `DOCKER_USER=baserow_docker_user`, `POSTGRES_VERSION=15`, `BASEROW_IMAGE_TYPE="all-in-one"`, `DATA_DIR=/baserow/data`, `BASEROW_PLUGIN_DIR=/baserow/data/plugins`; apt: curl, gnupg2, ca-certificates, supervisor, psmisc, gawk, postgresql-client-15, xmlsec1, gettext, tini, tzdata-legacy (PGDG apt source added); group/user from UID/GID with home `/baserow`; data and plugin dirs chowned to UID:GID.
- ENV: `POSTGRES_LOCATION=/etc/postgresql/15/main`, `UV_PROJECT_ENVIRONMENT=/baserow/venv`, `UV_CACHE_DIR=/tmp/baserow_uv_cache`, `UV_VERBOSE=1`, `PYTHONUNBUFFERED=1`, `PATH` prefixed `/baserow/venv/bin`, `PYTHONPATH` covering backend/premium/enterprise `src`, `DJANGO_SETTINGS_MODULE=baserow.config.settings.base`, `NODE_OPTIONS=--max-old-space-size=4096`, `NODE_ENV=production`.
- Stage `prod-lite` (no embedded DB/cache): copies web-frontend, backend, venv; `Caddyfile` -> `/baserow/caddy/Caddyfile`; `deploy/all-in-one/supervisor/` -> `/baserow/supervisor`; `deploy/all-in-one/baserow.sh` -> `/baserow.sh`; `deploy/plugins/*.sh` -> `/baserow/plugins/`; `./backend/docker/mime.types` -> `/etc/`.
- Stage `prod` adds `postgresql-15`, `postgresql-15-pgvector`, `redis` (sed edits to redis.conf) on top of base; otherwise identical to prod-lite.
- No USER and no VOLUME in the file.

## Runtime deps
Embedded all-in-one: supervisor-managed Caddy, Django/gunicorn backend (venv), Nuxt web frontend (node/yarn at runtime), and optionally PostgreSQL 15 + Redis in `prod`. The `prod-lite` variant (used by plan) expects external PostgreSQL and Redis/Valkey.

## Binaries/entrypoint/CLI flags
- `ENTRYPOINT ["/baserow.sh"]`, `CMD ["start"]`.
- HEALTHCHECK: interval 60s, `/bin/bash /baserow/backend/docker/docker-entrypoint.sh backend-healthcheck`.

## Env vars
From the Docker Hub run example and chart: `BASEROW_PUBLIC_URL` (must match the browser address), `BASEROW_CADDY_ADDRESSES` (e.g. `:443` for automatic HTTPS), `DATABASE_URL` or `DATABASE_HOST/PORT/NAME/USER/PASSWORD`, `REDIS_URL` or `REDIS_HOST/...`, `SECRET_KEY`. Full list is in the Baserow docs (not fetched; see baserow-docs-index.md). The Dockerfile itself sets only the ENV listed above.

## Ports
`EXPOSE 80 25` (HTTP via Caddy; 25 = SMTP for the optional email-receiver role). Hub examples publish 80 and 443 (Caddy HTTPS when enabled).

## Volumes/paths and persistent data
`/baserow/data` (`DATA_DIR`): `SECRET_KEY` auto-generated in `/baserow/data/.secret` (per plan.md, not confirmed in this fetch), plugins in `/baserow/data/plugins`, caddy certs in `/baserow/data/caddy`. Hub: embedded Postgres data created before 1.24 must be upgraded with `baserow/baserow-pgautoupgrade:1.30.1` before running a newer image.

## User/UID & permissions
UID/GID 9999 by default (ARG). Dockerfile has no USER line; `baserow.sh` uses su-exec (per Dockerfile stages). Chart runs as root.

## Config files and formats
`defaults/`-style files in this repo: `Caddyfile`, supervisor config; Django settings module `baserow.config.settings.base`.

## Healthcheck/readiness endpoints
`backend-healthcheck` via docker-entrypoint.sh (HEALTHCHECK in Dockerfile). Chart probes: tcp.

## Version/release info and asset naming
- Release `2.4.3`, marked Latest, published 14 Nov 09:40 (year not shown), commit `d897b90e9b819d4cde8b8c542f548bcdc21cd97f`, by bram2w. 339 commits on develop since.
- One fix: select option values containing dollar signs converted wrongly on field type change.
- Release shows "Assets 2"; names did not load. Tags are bare `2.4.3`.
- Source archive `https://github.com/baserow/baserow/archive/refs/tags/${VERSION}.tar.gz` (not downloaded).

## Arch support
Not stated by the Dockerfile; Hub lists none.

## Licence
- Core: MIT (README and Hub: "non-premium/non-enterprise code is MIT").
- `premium/LICENSE`: "Baserow Premium Edition license (PE License)", © 2019-present Baserow B.V.; proprietary/commercial; production use requires a paid subscription per user count; copying, publishing, distributing, sublicensing and selling prohibited; development/testing free. Parts shared in Baserow OSE and client-side assets fall under MIT Expat.
- The all-in-one image copies `premium/backend` and `enterprise/backend` into `/baserow/`, so the image ships PE-licensed code.

## Gotchas
- README run example still shows `baserow/baserow:2.4.1` in an older doc page. Use 2.4.3 per release.
- `latest` tag on Hub is 12 days old at fetch; `develop-latest` exists but is "use at your own risk".
- GitLab URL https://gitlab.com/bramw/baserow is the old location (project says migrated to GitHub; 137 tags, 92 releases, created 2019-02-15).

## Contradictions with plan.md
- plan.md section 1 Dockerfile facts (python:3.14.7-slim-trixie, Caddy 2.11.4, supervisor, su-exec, node/yarn 1.22.22, entrypoint `/baserow.sh start`, `DATA_DIR=/baserow/data`, ports 80 and 25): confirmed.
- plan.md section 1 licence `UNVERIFIED` on premium/enterprise: now confirmed that `premium/LICENSE` is proprietary PE licence and the upstream image ships premium code. Left in plan.md as the decision point (bake LICENSE / removing dirs).
- plan.md section 1 version 2.4.3 published 14 Nov: confirmed.
