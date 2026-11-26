# idank/explainshell (upstream, GitHub)

## Source URL(s) + date
- https://raw.githubusercontent.com/idank/explainshell/827ebe3/prod/docker/Dockerfile (fetched 2026-11-26)
- https://raw.githubusercontent.com/idank/explainshell/827ebe3/prod/docker/start.sh (followed)
- https://raw.githubusercontent.com/idank/explainshell/master/README.md
- https://api.github.com/repos/idank/explainshell/releases/latest: 404 (no normal releases; DB is in moving release `db-latest`)
- Not fetched: https://github.com/idank/explainshell/releases/download/db-latest/... (asset digest taken from plan, unchanged)

## What it is
explainshell.com: maps shell command-line arguments to man-page help text. Python 3.12 web app (`explainshell.web:create_app()`) plus a prebuilt SQLite DB. Caddy fronts gunicorn upstream.

## Install/build steps (upstream Dockerfile, multi-stage)
1. `FROM caddy:2-builder AS caddy-builder`: `COPY prod/botshed /src/botshed`; `xcaddy build --with explainshell.com/botshed=/src/botshed`
2. `FROM python:3.12-slim AS db-builder`: apt `wget zstd jq`; `WORKDIR /db`; `COPY tools/download-latest-db.sh tools/`; `ARG DB_NAME`; `RUN tools/download-latest-db.sh --asset "$DB_NAME" explainshell.db` (script verifies sha256 against release metadata)
3. `FROM python:3.12-slim`: `COPY --from=caddy-builder /usr/bin/caddy /usr/local/bin/caddy`; `WORKDIR /opt/webapp`; `COPY requirements.txt .`; `pip3 install --no-cache-dir --no-warn-script-location -r requirements.txt` (web-serving set only; LLM SDKs in requirements-extraction.txt, not installed)
4. `COPY --from=db-builder /db/explainshell.db /db/explainshell.db.sha256 ./`
5. `COPY prod/docker/Caddyfile /etc/caddy/Caddyfile`; `COPY prod/docker/start.sh .`; `COPY explainshell/ explainshell/`

## Runtime deps
- Python 3.12-slim; Caddy 2 (xcaddy build with botshed plugin); requirements.txt (web set).
- DB: SQLite, zstd-compressed upstream asset (`explainshell-2026-06-22-063435.db.zst` per plan; download needs zstd to decompress).

## Entrypoint/flags
- `CMD ["./start.sh"]`
- start.sh (bash, `set -e`):
  - `UPSTREAM_ADDR` default `[::1]:8081`
  - `gunicorn -w 2 --threads 4 --timeout 15 --graceful-timeout 5 --max-requests 10000 --max-requests-jitter 2000 --preload -b "$UPSTREAM_ADDR" "explainshell.web:create_app()" &`
  - `caddy run --config /etc/caddy/Caddyfile --adapter caddyfile &`
  - traps TERM/INT, `wait -n`, then kills both.
- Caddy listens on :8080 and proxies to gunicorn on localhost:8081; gunicorn binds localhost only (upstream design).

## Env vars
| Var | Default (upstream) | Notes |
| --- | --- | --- |
| DEBUG | false (Dockerfile `ENV DEBUG=false`) | app config; code default per plan is true |
| DB_PATH | /opt/webapp/explainshell.db | sqlite path; sidecar `<DB_PATH>.sha256` read for ETag |
| GIT_SHA | unknown (`ARG GIT_SHA=unknown`) | cache ETag only |
| UPSTREAM_ADDR | [::1]:8081 | start.sh gunicorn bind |

## Ports
- 8080 (`EXPOSE 8080`, Caddy). gunicorn 8081 (localhost only, upstream).

## Volumes/paths
- `/opt/webapp` (WORKDIR), `/opt/webapp/explainshell.db` (+ `.sha256` sidecar), `/etc/caddy/Caddyfile`.
- No VOLUME upstream.

## User/UID
- Upstream: root (no USER).

## Config files
- `/etc/caddy/Caddyfile` (from `prod/docker/Caddyfile`; not fetched).

## Healthcheck
- None upstream.

## Version/asset naming
- No version tags. Plan pins commit `827ebe3` (master HEAD `827ebe38...` per plan).
- Release tags: `db-latest` (moving DB asset), `db-dump`.
- Docker Hub `spaceinvaderone/explainshell:latest`: amd64 only, last pushed 2020-05-27 (third-party image, not upstream).

## Arch
- amd64 on the Docker Hub tag. Upstream build pipeline not reviewed.

## Gotchas
- Upstream Dockerfile passes DB_NAME and GIT_SHA as build args; deploy pipeline sets them.
- Caddy is part of the upstream runtime; a gunicorn-only image (as the plan does) must bind 8080 directly, and start.sh bind differs from upstream (8081 localhost).
- Upstream Caddy buffers responses to protect gunicorn workers (comment in start.sh).
- README: local extraction uses `llm:` providers (not needed to serve).
