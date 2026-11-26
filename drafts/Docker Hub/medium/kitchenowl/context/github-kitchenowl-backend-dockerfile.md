# Upstream backend (TomBursch/kitchenowl @ v0.8.1): Dockerfile, wsgi.ini, entrypoint.sh, LICENSE

## Source URL(s) + date
- https://raw.githubusercontent.com/TomBursch/kitchenowl/v0.8.1/backend/Dockerfile (2026-11-26)
- https://raw.githubusercontent.com/TomBursch/kitchenowl/v0.8.1/backend/wsgi.ini (merged follow-up)
- https://raw.githubusercontent.com/TomBursch/kitchenowl/v0.8.1/backend/entrypoint.sh (merged follow-up; the Dockerfile COPYs it; path inferred from COPY line, fetch succeeded)
- https://raw.githubusercontent.com/TomBursch/kitchenowl/v0.8.1/LICENSE (first lines)
- Not fetched (same content): https://github.com/TomBursch/kitchenowl/blob/v0.8.1/backend/Dockerfile

## Builder (`FROM python:3.14-slim AS builder`)
- apt (no-recommends): gcc g++ libffi-dev libpcre2-dev libre2-dev build-essential cargo libxml2-dev libxslt-dev cmake gfortran libopenblas-dev liblapack-dev pkg-config ninja-build autoconf automake zlib1g-dev libjpeg62-turbo-dev libssl-dev libsqlite3-dev libexpat1-dev libicu-dev.
- `pip install uv`; `ENV UV_PROJECT_ENVIRONMENT=/opt/venv`; `PATH=/opt/venv/bin:$PATH`.
- `COPY pyproject.toml uv.lock`; `uv python list --no-managed-python && uv sync --no-dev`; strips `test`/`tests` dirs and `*.pyc`/`*.pyo`.
- `python -c "import nltk; nltk.download('averaged_perceptron_tagger_eng', download_dir='/opt/venv/nltk_data')"`.

## Runner (`FROM python:3.14-slim AS runner`)
- apt: libxml2 libpcre2-dev libre2-dev libexpat1 curl media-types libicu-dev gosu; no cache dir left.
- `groupadd -g 1000 kitchenowl`; `useradd -u 1000 -g kitchenowl -d /usr/src/kitchenowl -s /sbin/nologin kitchenowl`.
- COPY `/opt/venv` from builder; PATH set.
- `mkdir -p /usr/src/kitchenowl /data && chown kitchenowl:kitchenowl ...`.
- COPY (chown kitchenowl) `wsgi.ini wsgi.py entrypoint.sh manage.py manage_default_items.py upgrade_default_items.py` -> `/usr/src/kitchenowl/`; `app/`, `templates/`, `migrations/`.
- `WORKDIR /usr/src/kitchenowl`; `VOLUME ["/data"]`.
- `HEALTHCHECK --interval=60s --timeout=3s CMD uwsgi_curl localhost:5000 /api/health/8M4F88S8ooi4sMbLBfkkV7ctWwgibW6V || exit 1`.
- `chmod u+x ./entrypoint.sh`.
- `CMD ["wsgi.ini", "--gevent", "200", "--max-fd", "1048576"]`; `ENTRYPOINT ["./entrypoint.sh"]`.

## Env vars (Dockerfile)
| Name | Default |
| --- | --- |
| STORAGE_PATH | `/data` |
| JWT_SECRET_KEY | `PLEASE_CHANGE_ME` |
| DEBUG | `False` |
| LABEL org.opencontainers.image.source | https://github.com/TomBursch/kitchenowl |

## entrypoint.sh (v0.8.1)
- Runs `set -e`.
- If `id -u` = 0: `mkdir -p $STORAGE_PATH/upload`; `chown -R kitchenowl:kitchenowl $STORAGE_PATH`; `exec gosu kitchenowl "$0" "$@"`.
- If `/proc/net/if_inet6` missing: `sed -i 's/\[::\]//g' /usr/src/kitchenowl/wsgi.ini`.
- `BASE_HREF` (optional): must start and end with `/`, no `#`; sed-replaces `<base href="/">` in `/var/www/web/kitchenowl/index.html`.
- `mkdir -p $STORAGE_PATH/upload`; `flask db upgrade`.
- Unless `SKIP_UPGRADE_DEFAULT_ITEMS` is `true`/`True`: `python upgrade_default_items.py`.
- `exec uwsgi "$@"`.

## wsgi.ini (v0.8.1)
- `[uwsgi]`: `socket = [::]:5000`, `wsgi-file = wsgi.py`, `callable = app`, `procname-prefix-spaced = kitchenowl`, `chmod-socket = 664`, `die-on-term`, `need-app`, `lazy-apps`, `http-websockets`.
- `[celery]`: smart-attach-daemon `celery -A app.celery_app worker -B`.
- `[web]`: `http = [::]:8080`, `http-to = :5000`, `static-map = /=/var/www/web/kitchenowl`, route non-`/api`/`/mcp` to `index.html`.

## Ports
- 5000 (uwsgi socket, healthcheck target). 8080 (`[web]` HTTP). No `EXPOSE` in backend Dockerfile.

## Volumes/paths
- `/data` (VOLUME). `/usr/src/kitchenowl` (app). `/opt/venv` (venv). `/var/www/web/kitchenowl` (static web, from wsgi.ini).

## User/UID
- Runner `kitchenowl` UID 1000 / GID 1000. Entrypoint drops from root via gosu when started as root.

## License
- LICENSE: GNU AFFERO GENERAL PUBLIC LICENSE Version 3, 19 November 2007 (AGPL-3.0).

## Gotchas
- Builder `cargo`, `gfortran`, `cmake` installed; builds deps from uv.lock.
- No `EXPOSE`.
