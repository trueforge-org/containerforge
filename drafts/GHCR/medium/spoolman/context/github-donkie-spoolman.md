# GitHub: Donkie/Spoolman (pinned commit ff8efd51, version 0.27.1)

Source URL(s): https://raw.githubusercontent.com/Donkie/Spoolman/ff8efd517b76a4b2783f29c89e9b9fbcd8cd167b/{Dockerfile,entrypoint.sh,pyproject.toml,spoolman/env.py} (fetched 2026-11-27). Docs site donkie.github.io/Spoolman fetched, not summarized (covered by env.py/Dockerfile).

## What it is
- Python web service (FastAPI + uvicorn, SQLAlchemy, alembic). License MIT. Package `spoolman` 0.27.1, requires-python >=3.10,<3.15.

## Dockerfile (multi-stage, python:3.14-slim-bookworm)
- builder: apt `g++ libpq-dev libffi-dev patchelf`; `pip install uv`; `uv sync --locked --no-install-project`, then copies `migrations`, `spoolman`, `alembic.ini README.md uv.lock pyproject.toml`, `uv sync --locked`. ARG TARGETARCH/TARGETVARIANT used for uv cache id. armv7 patchelf adds libstdc++ to greenlet .so.
- runner: apt `gosu`; `useradd -u 1000 -U app`; mkdir `/home/app/.local/share/spoolman` owned by app.
- Copies `./client/dist` (legacy React) and `./client_v2/build` (Svelte, served by default) into `/home/app/spoolman/`.
- WORKDIR /home/app/spoolman; PATH prepends `/home/app/spoolman/.venv/bin`.
- Build args GIT_COMMIT, BUILD_DATE -> written to `build.txt`.
- EXPOSE 8000; ENTRYPOINT `/home/app/spoolman/entrypoint.sh` (no CMD).
- Labels: source=https://github.com/Donkie/Spoolman, licenses=MIT.

## entrypoint.sh (/bin/sh)
- Defaults: PUID=1000, PGID=1000, SPOOLMAN_PORT=8000, SPOOLMAN_HOST=0.0.0.0.
- If SPOOLMAN_PORT contains `://` (k8s service link), it is reset to 8000.
- PUID/PGID must be numeric; PUID 0 is rejected (fail).
- usermod/groupmod `app` to PUID/PGID when different.
- If running as root: `exec gosu app "$0" "$@"` (re-exec as app).
- Final: `exec uvicorn spoolman.main:app --host $SPOOLMAN_HOST --port $SPOOLMAN_PORT "$@"`

## Env vars (spoolman/env.py, os.getenv)
| var | default | note |
| --- | --- | --- |
| SPOOLMAN_DB_TYPE | - | sqlite, mysql, postgres, cockroachdb |
| SPOOLMAN_DB_HOST / _PORT / _NAME / _USERNAME | - | |
| SPOOLMAN_DB_PASSWORD | - | or SPOOLMAN_DB_PASSWORD_FILE |
| SPOOLMAN_DB_QUERY | - | extra DB query string |
| SPOOLMAN_DIR_DATA | - | data dir |
| SPOOLMAN_DIR_LOGS | - | logs dir |
| SPOOLMAN_DIR_BACKUPS | - | backups dir |
| SPOOLMAN_LOGGING_LEVEL | INFO | |
| SPOOLMAN_DEBUG_MODE | FALSE | |
| SPOOLMAN_CORS_ORIGIN | - | comma-separated, `*` allowed |
| SPOOLMAN_ALLOWED_HOSTS | - | |
| SPOOLMAN_BASE_PATH | "" | sub-path hosting |
| SPOOLMAN_AUTOMATIC_BACKUP | TRUE | |
| SPOOLMAN_UPDATE_CHECK | TRUE | |
| SPOOLMAN_METRICS_ENABLED | FALSE | prometheus |
| SPOOLMAN_LEGACY_CLIENT | FALSE | serve legacy React client |
| PUID / PGID | 1000 / 1000 | entrypoint only |

## Ports
- 8000/tcp (SPOOLMAN_PORT)

## Volumes/paths
- Data default `/home/app/.local/share/spoolman` (image), overridable via SPOOLMAN_DIR_DATA; TrueCharts uses `/data` and `/logs`.

## User/UID
- Container starts as root, entrypoint drops to `app` (uid 1000 default) via gosu. Chart runs as uid 0 (runAsUser 0) so entrypoint re-execs as app.

## Config files
- alembic.ini; migrations/ dir; build.txt written at build time.

## Arch
- Multi-arch incl. armv7 (special greenlet patchelf step); cbor2 pinned <6 because no armv7 wheels.

## Gotchas
- Kubernetes service links can set SPOOLMAN_PORT to `tcp://...`; entrypoint handles it, but the Service name `spoolman` is a hazard.
