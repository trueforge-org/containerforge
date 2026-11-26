# Dispatcharr/Dispatcharr (repository, README at v0.34.1, latest release, pyproject, aio compose)

Source URL(s) + fetch date:
- https://github.com/Dispatcharr/Dispatcharr (README via raw tag v0.34.1) · 2026-11-26
- https://github.com/Dispatcharr/Dispatcharr/releases/latest · 2026-11-26
- https://github.com/Dispatcharr/Dispatcharr/blob/main/docker/docker-compose.aio.yml (raw main) · 2026-11-26

## What it is
Open-source IPTV manager ("the *arr family's IPTV cousin"): stream proxy/relay, M3U and Xtream Codes import/export, EPG matching, built-in DVR, catch-up/timeshift, transcoding profiles, multi-user access control, plugins. Presents as HDHomeRun to Plex, Emby, Jellyfin. Output formats: M3U, XMLTV, Xtream Codes API, HDHomeRun emulation.

## Deployment modes (README)
- All-in-one (`docker/docker-compose.aio.yml`): recommended, everything in one container (embedded Postgres, Redis, celery).
- Modular (`docker/docker-compose.yml`): separate containers for Dispatcharr, Celery, Redis, Postgres.
- Development (`docker/docker-compose.dev.yml`).
- Source build: not officially supported; `debian_install.sh` exists for Debian.

## Image / quick start
- `ghcr.io/dispatcharr/dispatcharr:latest`. Example: `docker run -d -p 9191:9191 --name dispatcharr -v dispatcharr_data:/data ...`.
- Admin alternative: `docker exec <container> python manage.py createsuperuser`.

## Ports / data
- 9191 (web UI/app). Data at `/data` (named volume in examples).

## Env vars named in README
- `DISPATCHARR_SETUP_ALLOWED_IP`: first-time web setup allowed from this IP; unset means only local/private networks.
- `DISPATCHARR_TRUSTED_PROXIES`: reverse proxy IP/CIDR (or `none`). Reverse Proxy Auth signs nobody in while unset.

## Compose aio (main branch)
- Service `dispatcharr`, image `ghcr.io/dispatcharr/dispatcharr:latest`, port `9191:9191`, named volume `dispatcharr_data` at `/data`.
- Active env: `DISPATCHARR_ENV=aio`, `REDIS_HOST=localhost`, `CELERY_BROKER_URL=redis://localhost:6379/0`, `DISPATCHARR_LOG_LEVEL=info`.
- Commented options: `DISPATCHARR_PORT` (9191), `REDIS_IDLE_TIMEOUT` (300), `REDIS_MAX_CONNECTIONS` (50), `DISPATCHARR_SETUP_ALLOWED_IP`, `DISPATCHARR_TRUSTED_PROXIES`, `USE_LEGACY_NUMPY`, `UWSGI_NICE_LEVEL` (0, range -20..19), `CELERY_NICE_LEVEL` (5), `UWSGI_WORKERS` (4, 1-20), `CELERY_MAX_WORKERS` (6, 1-20), `CELERY_MIN_WORKERS` (1), `DISPATCHARR_NOFILE` (65536).
- Commented: `cap_add: SYS_NICE` (for negative nice), `/dev/dri` device (VA-API), NVIDIA GPU reservation.
- No healthchecks, no depends_on.

## pyproject (v0.34.1): see github-dispatcharr-dispatcharr-pyproject.md.

## Version/release
- Latest `v0.34.1` (marked Latest), 17 Nov (year not shown), commit `7448c4a`, one commit on main since.
- Release notes: only plugin bug fixes (uploaded plugin files kept on update; plugin data kept on unmanage; network actions for some plugins).
- "Assets 2" listed but asset names/digests did not load. No source-archive checksum found.

## License
- GNU AGPL v3.0 (pyproject: `AGPL-3.0-only`). Name and logo are trademarked; use needs maintainer permission.

## Gotchas
- `DISPATCHARR_ENV=aio` is the upstream default recommended mode; `modular` is the mode documented in `docker/docker-compose.yml` and `uwsgi.modular.ini`.
