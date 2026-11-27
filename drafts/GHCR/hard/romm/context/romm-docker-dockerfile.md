# rommapp/romm docker/Dockerfile (tag 5.4.1)

**Source URL(s):** https://raw.githubusercontent.com/rommapp/romm/5.4.1/docker/Dockerfile (blob URL duplicate) · fetched 2026-11-27 (16944 bytes, full file read)

## Stages (multi-stage, Alpine-based)
- ARGs: ALPINE_VERSION=3.24, PYTHON_VERSION=3.14, PIP_VERSION=26.2.2, NODE_VERSION=24.22, NGINX_VERSION=1.30.5, UV_VERSION=0.13.4, EMSDK_VERSION=4.0.12, GME_VERSION=0.6.5, ROM_CONVERTO_VERSION=v0.23.2, EMULATORJS_VERSION=4.2.3, RUFFLE_VERSION=nightly-2025-08-14, JSDOS_VERSION=8.4.1, EASYRPG_VERSION=0.8.1.1 (each with sha256 pins).
- `frontend-build`: node Alpine; `npm ci`; `npm run build` -> /front/dist.
- `backend-node-build`: rom_patcher npm deps.
- `backend-build`: python-alias (python:3.14-alpine3.24); uv sync --frozen; libpq-dev, mariadb-connector-c-dev, gcc, musl-dev.
- `rahasher-build`: RALibretro at commit 8ab61f7 (RAHasher).
- `sigil-build`: argosy-sigil at commit 8a3b008 (python bindings).
- `gme-build`: libgme to WebAssembly (emsdk).
- `rom-converto-fetch`: rom-converto CLI v0.23.2.
- `emulator-stage`: EmulatorJS, Ruffle, js-dos, fake-08, EasyRPG (sha256 checked).
- `nginx-build`: nginx module mod_zip.
- `production-stage`: nginx:1.30.5-alpine3.24; apk bash, libarchive-tools, libmagic, mariadb-connector-c, libpq, nodejs, 7zip, tzdata, valkey, valkey-cli; copies python from python-runtime; RAHasher, rom-converto, nginx module, frontend to /var/www/html, backend to /backend; init scripts to /; nginx conf templates.
- User: `romm` uid/gid 1000 created; /romm and /redis-data owned by romm.
- `slim-image`: FROM scratch of production-stage + backend venv at /src/.venv, sigil bindings.
- `full-image` and `dev-*` add emulator stage (not fetched).

## Runtime
- `VOLUME ["/romm", "/redis-data"]`.
- `EXPOSE 8080 6379/tcp`.
- `WORKDIR /romm`.
- `ENTRYPOINT ["/docker-entrypoint.sh"]`, `CMD ["/init"]`.
- ENV: PATH=/src/.venv/bin, PYTHONDONTWRITEBYTECODE=1, PYTHONUNBUFFERED=1, PYTHONPATH=/backend, SCREENSCRAPER_DEV_ID / SCREENSCRAPER_DEV_PASSWORD (build args, empty by default).

## Gotchas
- Chart's `/romm` and `/redis-data` volumes: image declares both.
- nginx + valkey (redis-compatible) run in the same image via /init (init scripts not fetched).
- Build args for screenscraper credentials are injected from CI secrets; empty in published images.
