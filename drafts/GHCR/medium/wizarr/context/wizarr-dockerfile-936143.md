# Wizarr Dockerfile + docker-entrypoint.sh @ 936143363897efd3ca68568fdf6fdd9a0d63f559

Source URL(s): https://raw.githubusercontent.com/Wizarrrr/wizarr/936143363897efd3ca68568fdf6fdd9a0d63f559/Dockerfile ; .../docker-entrypoint.sh (fetched 2026-11-27). api.github.com contents call hit rate limit; raw alt used.

## Stages
| Stage | Base | Work |
| --- | --- | --- |
| deps | ghcr.io/astral-sh/uv:python3.13-alpine | apk nodejs npm; uv sync --frozen --no-install-project --no-dev; npm --prefix app/static/ ci |
| builder | deps | copy app/, babel.cfg; uv sync --frozen --no-dev; pybabel compile --use-fuzzy -d app/translations; npm build (DOCKER_BUILD=true), rm node_modules |
| runtime | ghcr.io/astral-sh/uv:python3.13-alpine | apk curl tzdata su-exec; copies .venv, app, source (chown 1000:1000) |

## Runtime
- ENV PUID=1000, PGID=1000, HOST=0.0.0.0, PORT=5690, FLASK_ENV=production, APP_VERSION (ARG default dev).
- WORKDIR /app. mkdir /data/database and /.cache. Wizard steps copied to /opt/default_wizard_steps.
- EXPOSE 5690.
- HEALTHCHECK 30s interval, 5s timeout, 60s start, 3 retries: `curl -fs http://localhost:${PORT:-5690}/health`.
- ENTRYPOINT ["docker-entrypoint.sh"] (installed to /usr/local/bin).
- CMD `uv run --frozen --no-dev gunicorn --config gunicorn.conf.py --umask 007 run:app`.

## docker-entrypoint.sh (runs as root first)
- PUID/PGID default 1000/1000.
- If root: finds existing user/group for those IDs; else creates `wizarruser`/`wizarrgroup` (addgroup/adduser -S).
- mkdir /data/database; chown -R user:group on /data/database, /.cache, /opt/default_wizard_steps.
- If PUID:PGID not 1000:1000: chown -R PUID:PGID /data/database.
- If not 0:0: `exec su-exec user:group "$0" "$@"` (re-exec as the target user).
- Then `FLASK_SKIP_SCHEDULER=true uv run --frozen --no-dev flask db upgrade` (alembic migrations).
- `exec "$@"`.

## Env vars
| Var | Default | Source |
| --- | --- | --- |
| PUID / PGID | 1000 / 1000 | Dockerfile + entrypoint |
| HOST | 0.0.0.0 | Dockerfile |
| PORT | 5690 | Dockerfile |
| FLASK_ENV | production | Dockerfile |
| APP_VERSION | dev (build ARG) | Dockerfile |
| FLASK_SKIP_SCHEDULER | true (set only during migration) | entrypoint |

## Ports
- 5690/tcp.

## Volumes/paths
- /data (docs), /data/database (app DB as chart mounts it), /.cache, /opt/default_wizard_steps.

## User/UID
- Root at entry, then su-exec to PUID/PGID (wizarruser/wizarrgroup if no name exists for the IDs).

## Healthcheck
- `/health` on PORT (curl).

## Arch
- Not stated (uv alpine multi-arch base; no explicit arch list).

## Gotchas
- Entrypoint needs root (addgroup/adduser/chown/su-exec): not read-only-rootfs or USER-only compatible as-is.
- Runtime-generated `/.cache` directory at filesystem root.
- Chart mounts /data/database only; upstream docs say /path/to/appdata:/data.
