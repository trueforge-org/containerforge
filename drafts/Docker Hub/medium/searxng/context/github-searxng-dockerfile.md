# GitHub: searxng/searxng container files and base

Source URL(s): raw container/Dockerfile at 1ebea4a073ec6011bae25c042d97308278184c83; raw container/entrypoint.sh, container/settings.template.yml, requirements.txt (master); raw searxng/base Dockerfile (main); api releases/latest (fetched 2026-11-27)

## Release
- `GET /repos/searxng/searxng/releases/latest` returns Not Found. No GitHub releases published; versions come from Docker Hub tags (`YYYY.MM.DD-<sha>`).

## Upstream container/Dockerfile (commit 1ebea4a)
- Stage `builder`: `FROM docker.io/searxng/base:searxng-builder`. Copies requirements.txt + requirements-server.txt; `uv venv`; `uv pip install --requirements requirements.txt --requirements requirements-server.txt`; strips/compiles .venv; compiles searx/; gzip/brotli static assets.
- Stage `dist`: `FROM docker.io/searxng/base:searxng`. COPY .venv and searx/ owned 977:977; COPY container/ files; copies version_frozen.py.
- LABELs: licenses AGPL-3.0-or-later; title SearXNG; doc url docs.searxng.org/admin/installation-docker.
- ENV: `__SEARXNG_VERSION`, `__SEARXNG_SETTINGS_PATH=$__SEARXNG_CONFIG_PATH/settings.yml`, `GRANIAN_PROCESS_NAME=searxng`, `GRANIAN_INTERFACE=wsgi`, `GRANIAN_HOST=::`, `GRANIAN_PORT=8080`, `GRANIAN_WEBSOCKETS=false`, `GRANIAN_BLOCKING_THREADS=4`, `GRANIAN_WORKERS_KILL_TIMEOUT=30s`, `GRANIAN_BLOCKING_THREADS_IDLE_TIMEOUT=5m`.
- `VOLUME $__SEARXNG_CONFIG_PATH`, `VOLUME $__SEARXNG_DATA_PATH`; `EXPOSE 8080`; `ENTRYPOINT ["/usr/local/searxng/entrypoint.sh"]`.
- Build args: CREATED, VERSION, VCS_URL, VCS_REVISION.

## Base image (searxng/base Dockerfile, raw main)
- Void Linux xbps based. Stages: bootstrap (alpine:latest), searxng-builder, core, searxng (scratch).
- Builder packages: xbps base-files busybox ca-certificates gcc tzdata brotli wget python3-devel uv libffi-devel.
- Core packages: xbps base-files busybox ca-certificates. Searxng packages: libstdc++ tzdata python3 wget.
- User: `searxng:x:977:977`, home `/usr/local/searxng/`, shell /usr/bin/sh.
- Dirs created 977:977: `/usr/local/searxng/` (0555), `/etc/searxng/` (0755), `/var/cache/searxng/` (0755).
- ENV: `__SEARXNG_CONFIG_PATH=/etc/searxng`, `__SEARXNG_DATA_PATH=/var/cache/searxng`, PATH.
- ENTRYPOINT `/usr/bin/sh` in base.

## entrypoint.sh (raw master)
- Checks `$__SEARXNG_CONFIG_PATH` and `$__SEARXNG_DATA_PATH` are directories; if owner not searxng:searxng and FORCE_OWNERSHIP (default true) and uid 0, runs `chown -R searxng:searxng`.
- Setup: if `$__SEARXNG_CONFIG_PATH/settings.yml` missing, copies `/usr/local/searxng/settings.template.yml` and replaces `ultrasecretkey` with random base64 chunk.
- If uid 0: `update-ca-certificates`.
- `SEARXNG_PORT` (digits only) exported as GRANIAN_PORT; non-numeric unset.
- `exec /usr/local/searxng/.venv/bin/granian searx.webapp:app`.

## settings.template.yml (raw master)
- `use_default_settings: true`; `server: secret_key: "ultrasecretkey"`, `image_proxy: true`.

## requirements.txt (raw master, head)
- certifi 2026.10.23, babel 2.18.0, flask-babel 4.0.0, flask 3.1.3, jinja2 3.1.6, lxml 6.1.3, pygments 2.21.0, python-dateutil 3.0.0, pyyaml 6.0.3, curl_cffi 0.17.0, valkey 6.1.1 (client), markdown-it-py 4.3.0, msgspec 0.22.0, typer 0.29.1, isodate 0.7.2, whitenoise 6.12.0, typing-extensions 4.16.0 (list truncated at fetch).
- requirements-server.txt not fetched.

## Ports
- 8080/tcp (GRANIAN_PORT).

## Volumes/paths
- `/etc/searxng` (settings.yml), `/var/cache/searxng` (data).

## User/UID
- searxng uid/gid 977. Entrypoint runs as root only for ownership fix and CA update; app runs as searxng via granian (as set by image).

## Gotchas
- Container build uses uv + compiled venv; upstream entrypoint assumes root start for chown.
- Docker Hub reports amd64, arm64, arm for searxng/searxng.
