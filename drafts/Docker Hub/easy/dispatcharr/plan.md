# dispatcharr — implementation plan
> Source: ./draft.md · Target: apps/dispatcharr/ · Difficulty: draft says easy, real work is hard (multi-process Django app, frontend build, external PostgreSQL and Redis) · Role: draft says sidecar (Alpine init helper); this plan builds the chart's main Dispatcharr image · Verified on 2026-11-23

## 1. Verified upstream facts

The draft is wrong about what to build. Its "Container" is `docker.io/library/alpine:3.24`, the chart's `alpineImage` used only by an init container that creates `/var/run/postgresql` and `chown`s `/data/db` to 999:999 for the embedded PostgreSQL. A plain Alpine clone adds nothing (`apps/ubuntu` already covers busybox-style helpers), so this plan targets the real application, `ghcr.io/dispatcharr/dispatcharr`, which the chart runs as `main` (`values.yaml`: tag `0.34.1`, port 9191, `DISPATCHARR_ENV=aio`). If the maintainers really want only a helper image, the answer is "do not port; the init container becomes unnecessary because our image never runs PostgreSQL" (see 9).

| Item | Value |
| --- | --- |
| Version | `v0.34.1` (latest release, published 2026-11-17; chart `appVersion: 0.34.1`) |
| Renovate | `datasource=github-releases depName=Dispatcharr/Dispatcharr versioning=semver` (tag has `v` prefix; keep in `VERSION`) |
| License | AGPL-3.0-only (`pyproject.toml`: `license = "AGPL-3.0-only"`; `LICENSE` is the GNU AGPL v3 text) |
| Source | https://github.com/Dispatcharr/Dispatcharr |
| Artifact | No binary release. Source tarball `https://github.com/Dispatcharr/Dispatcharr/archive/refs/tags/v0.34.1.tar.gz` (arch independent), Python deps from PyPI and the PyTorch CPU index, frontend built with npm. |
| Checksum | None published for the source archive; the tag is the anchor. UNVERIFIED whether the GHCR image digest could be used for supply-chain pinning instead. |
| Upstream Dockerfiles | Reviewed `docker/Dockerfile` (stage 1 `node:24` builds `frontend` with `npm install` and `npm run build`; final stage `FROM ghcr.io/dispatcharr/dispatcharr:base`, copies the source to `/app`, nginx conf to `/etc/nginx/sites-enabled/default`, `ENTRYPOINT ["/app/docker/entrypoint.sh"]`) and `docker/DispatcharrBase`. |
| `DispatcharrBase` | `ghcr.io/dispatcharr/ffmpeg:latest` (Ubuntu 26.04 plus a custom redistributable FFmpeg, NVENC API 13.0); Python 3.13 from deadsnakes into venv `/dispatcharrpy` via `uv sync`; apt `nginx libpcre2-8-0 libopenblas0 procps pciutils jq vlc-bin vlc-plugin-base libargtable2-0 libavformat62 libavcodec62 libavutil60 libswscale9`; builds `comskip` from master; Redis 7 and PostgreSQL 17 from vendor repos for aio mode. |
| Python deps (`pyproject.toml`) | `requires-python >=3.13`; Django 6.0.10, psycopg[binary], celery[redis] 5.7.0, redis>=8,<9, djangorestframework, gevent 26.9.0, django-db-geventpool, daphne, uwsgi, channels, channels-redis 4.3.0, django-redis, django-celery-beat, `torch==2.15.0+cpu` (from `https://download.pytorch.org/whl/cpu`), sentence-transformers 6.3.0, lxml, pillow, streamlink, yt-dlp, python-vlc, rapidfuzz, etc. |
| Deployment modes (`DISPATCHARR_ENV`) | `aio` (embedded PostgreSQL, Redis, nginx, uwsgi, celery; needs root, `su`, chown 999, writes `/etc`), `modular` (external PostgreSQL and Redis, separate celery container, `docker/docker-compose.yml`), `dev`. The chart README line says only `aio` is supported, but `docker/docker-compose.yml` and `uwsgi.modular.ini` document `modular` as a full mode. |
| Modular web container | `docker/entrypoint.sh` waits for PostgreSQL (needs server major >= image PG 17; our `postgresql` app is 18.x, OK) and Redis (`scripts/wait_for_redis.py`), runs nginx, `manage.py migrate --noinput`, `collectstatic --noinput`, then uwsgi with `docker/uwsgi.modular.ini` (uwsgi socket `/app/uwsgi.sock`, internal http `0.0.0.0:5656`, `attach-daemon = daphne -b 0.0.0.0 -p 8001 dispatcharr.asgi:application`, `virtualenv = /dispatcharrpy`, gevent 400). |
| Celery container | `docker/entrypoint.celery.sh`: waits for `/data/jwt` and `manage.py migrate --check`, then `celery -A dispatcharr beat`, a DVR worker (`-Q dvr`, threads, concurrency 20) and a prefork autoscale worker for the other queues. |
| Ports | `9191/http` nginx (`DISPATCHARR_PORT`, default 9191); internal only: 5656 (uwsgi http), 8001 (daphne). nginx also proxies logo cache to `127.0.0.1:5656`. |
| Env vars (read in `entrypoint.sh`) | `DISPATCHARR_ENV`, `DISPATCHARR_PORT` (9191), `DISPATCHARR_LOG_LEVEL` (INFO), `DISPATCHARR_TIME_ZONE` (falls back to `TZ`, then UTC), `DISPATCHARR_LOG_DIR` (/data/logs), `DISPATCHARR_DEBUG`, `DISPATCHARR_NOFILE`, `DISPATCHARR_SETUP_ALLOWED_IP`, `DISPATCHARR_TRUSTED_PROXIES`, `DISPATCHARR_ENABLE_IP_LOOKUP`, `POSTGRES_HOST`, `POSTGRES_PORT` (5432), `POSTGRES_DB` (`dispatcharr`), `POSTGRES_USER` (`dispatch`), `POSTGRES_PASSWORD` (`secret` default), `POSTGRES_SSL`, `POSTGRES_SSL_MODE`, `POSTGRES_SSL_CA_CERT`, `POSTGRES_SSL_CERT`, `POSTGRES_SSL_KEY`, `REDIS_HOST`, `REDIS_PORT` (6379), `REDIS_DB` (0), `REDIS_USER`, `REDIS_PASSWORD`, `REDIS_SSL`, `REDIS_SSL_VERIFY`, `REDIS_SSL_CA_CERT`, `REDIS_SSL_CERT`, `REDIS_SSL_KEY`, `REDIS_IDLE_TIMEOUT`, `REDIS_MAX_CONNECTIONS` (50), `UWSGI_WORKERS` (4), `UWSGI_NICE_LEVEL`, `CELERY_MAX_WORKERS` (6), `CELERY_MIN_WORKERS` (1), `CELERY_NICE_LEVEL` (5), `TMDB_API_KEY`, `OMDB_API_KEY`, `LIBVA_DRIVER_NAME`, `USE_LEGACY_NUMPY`, `PUID`, `PGID`. |
| Persistent paths | Everything under `/data`: `jwt` (Django secret, generated at first start), `db` (aio PostgreSQL only), `backups`, `logos`, `cache/{logos,sd_posters}`, `recordings`, `uploads/{m3us,epgs}`, `m3us`, `epgs`, `plugins`, `models`, `scripts`, `logs`. Plus `/app/media` and `/app/static` (image layer). |
| arch | amd64 and arm64: upstream publishes multi-arch images. UNVERIFIED that `torch==2.15.0+cpu` has aarch64 wheels on the PyTorch CPU index for cp314. |

## 2. Target layout

```
apps/dispatcharr/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh                       # role dispatcher: web (default) or celery
  etc/dispatcharr/nginx.conf     # our main nginx.conf with /tmp paths, includes the upstream site fragment
```

`etc/` is allow-listed in `.dockerignore`. Never `root/`. No `defaults/` or `health/` (nothing else to seed; `valkey` uses `health/` only because its probe script is custom). No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

Final stage (runtime):

```
FROM ghcr.io/trueforge-org/python:3.14.8@sha256:f099b700b824b7760cb846418f84a2c14c2f04992320506ab3ca5b79d3ac1232
```

Frontend and build stage (Node needed only to build `frontend/dist`):

```
FROM ghcr.io/trueforge-org/python-node:3.14.8@sha256:feb6e44439ea272f47b46a1511960f58af5df8056811c83973e2edec9b18afca AS frontend
```

Reasoning: the app needs Python >= 3.13 and the brief's 3.15.2 digest is risky for the pinned scientific/compiled wheels (psycopg binary, gevent, lxml, torch, pillow). 3.14.8 is already used by eight apps and by `apps/changedetection` for the same reason. Re-check wheels for cp315 first; if all exist, switch to the 3.15.2 digests from the brief. Upstream builds the frontend on Node 24: UNVERIFIED that the `python-node` base ships a compatible Node; check `node --version` in the stage and compare with `frontend/package.json` engines. Closest siblings: `apps/changedetection` (python-node, pip into `/app/venv`, long RUN), `apps/budge` (python-node with a built frontend), `apps/valkey` (dependency).

## 4. Dockerfile

Stage `frontend`:

1. `ARG VERSION`; `USER root`; `curl -fsSL https://github.com/Dispatcharr/Dispatcharr/archive/refs/tags/${VERSION}.tar.gz | tar xz -C /tmp --strip-components=1`; `cd /tmp/frontend && npm install --no-audit --progress=false && npm run build`. Set `npm_config_cache=/tmp/.npm`. Output `frontend/dist`.

Final stage:

2. `FROM` python 3.14.8 above; `ARG VERSION`, `ARG TARGETARCH`; `USER root`.
3. `ENV PYTHONUNBUFFERED=1 PYTHONDONTWRITEBYTECODE=1 DISPATCHARR_ENV=modular DJANGO_SETTINGS_MODULE=dispatcharr.settings PATH=/app/venv/bin:$PATH` (check the base for `PATH` first; `DISPATCHARR_ENV` is baked to `modular` because `aio` cannot run rootless).
4. Apt, runtime only (no version pin: they are not the app; build packages are purged after): runtime `nginx libpcre2-8-0 libopenblas0 procps jq ffmpeg vlc-bin vlc-plugin-base postgresql-client`; build (purged afterwards) `build-essential libpcre2-dev libpq-dev libxml2-dev libxslt1-dev libjpeg-dev zlib1g-dev gfortran libopenblas-dev ninja-build`. UNVERIFIED: `ffmpeg` from Ubuntu replaces upstream's custom `ghcr.io/dispatcharr/ffmpeg` build (NVENC 13 and other features); alternative `COPY --from=ghcr.io/dispatcharr/ffmpeg:latest` of the binaries and libs (unpinned, so pin a digest if used). Skip `comskip` (needs a master build with patches) and say so in the PR.
5. Fetch source into `/app` (the base's `/app/venv` stays): `curl -fsSL "https://github.com/Dispatcharr/Dispatcharr/archive/refs/tags/${VERSION}.tar.gz" | tar xz -C /app --strip-components=1`; `rm -rf /app/frontend`; `COPY --from=frontend /tmp/frontend/dist /app/frontend/dist`.
6. Python deps into the existing venv, caches in `/tmp`: `/app/venv/bin/pip install --no-cache-dir uv` then `UV_PROJECT_ENVIRONMENT=/app/venv uv sync --no-install-project --no-dev --python /app/venv/bin/python` run from a dir holding the tag's `pyproject.toml`, `version.py`, `README.md` (as upstream does); this uses the `pytorch-cpu` index from `pyproject.toml`. Remove `uv` again. Do not set `UV_COMPILE_BYTECODE` (read-only fs, no benefit).
7. Rootless path changes, applied with `sed` at build time (assert each with `grep -q`):
   - `/app/docker/uwsgi.modular.ini`: `socket = /app/uwsgi.sock` to `/tmp/uwsgi.sock`; `virtualenv = /dispatcharrpy` to `/app/venv`.
   - `/app/docker/nginx.conf`: `uwsgi_pass unix:/app/uwsgi.sock` to `unix:/tmp/uwsgi.sock`.
   - Check `grep -rn "/dispatcharrpy\|/app/uwsgi.sock" /app` for any other reference.
8. `/data` compatibility: `rm -rf /data && ln -s /config /data` (the ubuntu base creates `/data`; all upstream `/data/...` paths then land on persistent `/config`).
9. Static files at build time: `DJANGO_SECRET_KEY=build python manage.py collectstatic --noinput` into `/app/static` (UNVERIFIED that it works with no database and no Redis; if it needs them, it cannot run at build time and `/app` is read-only at runtime, so instead run it from `start.sh` into `/tmp/static` by setting `STATIC_ROOT` there, and change the nginx `root /app/static` and uwsgi `static-map` to match). `mkdir -p /app/media`.
10. Licenses: `mkdir -p /usr/share/licenses/dispatcharr && cp /app/LICENSE /usr/share/licenses/dispatcharr/`.
11. `chown -R apps:apps /app && chmod -R 755 /app`; purge build packages, `apt-get autoremove -y`, `rm -rf /var/lib/apt/lists/* /tmp/* /root/.cache`.
12. `USER apps`; `COPY --chmod=0755 . /`; `EXPOSE 9191`; `VOLUME /config`; `WORKDIR /app`. Do not keep upstream's `ENTRYPOINT`; the base python image's start script and ours take over (`start.sh` at `/start.sh`, same as sibling python apps).

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "dispatcharr" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=Dispatcharr/Dispatcharr versioning=semver
  default = "v0.34.1"
}
variable "LICENSE" { default = "AGPL-3.0-only" }
variable "SOURCE"  { default = "https://github.com/Dispatcharr/Dispatcharr" }
```

Standard blocks (`docker-metadata-action`, `group "default"`, `image`, `image-local` tagged `${APP}:${VERSION}`, `image-all` amd64 and arm64) from `apps/bazarr/docker-bake.hcl`. Run `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/Dispatcharr/Dispatcharr"
ports:
  - port: 9191
    protocol: tcp
    required: true
env:        # block style as in apps/bazarr; names below are all read by upstream
  - DISPATCHARR_PORT        default "9191"
  - DISPATCHARR_LOG_LEVEL   default "info"
  - DISPATCHARR_TIME_ZONE   default "Etc/UTC"
  - POSTGRES_HOST           default "postgresql"   required true
  - POSTGRES_PORT           default "5432"
  - POSTGRES_DB             default "dispatcharr"
  - POSTGRES_USER           default "dispatch"
  - POSTGRES_PASSWORD       default "secret"       required true   # upstream's own default
  - REDIS_HOST              default "valkey"       required true
  - REDIS_PORT              default "6379"
  - REDIS_PASSWORD          default ""
  - UWSGI_WORKERS           default "4"
  - CELERY_MAX_WORKERS      default "6"
  - CELERY_MIN_WORKERS      default "1"
  - DISPATCHARR_SETUP_ALLOWED_IP   default ""
  - DISPATCHARR_TRUSTED_PROXIES    default ""
  - TZ                      default "Etc/UTC"
volumes:
  - path: /config
    required: true
dependencies:
  - postgresql ✅
  - valkey ✅
```

Notes: `POSTGRES_HOST` and `REDIS_HOST` defaults must be what `start.sh` uses; the "required true needs non-empty default" rule is satisfied. `valkey` is Redis compatible; UNVERIFIED that Dispatcharr (redis-py 8, channels-redis, celery) works against Valkey, so the dependency stays open until tested (no `redis` app exists in `apps/`). `PUID`, `PGID`, `USE_LEGACY_NUMPY`, `DISPATCHARR_ENV` are deliberately not exposed (not supported rootless). Add TLS/Redis-SSL variables only if you test them. Extend from the verified list in section 1.

## 7. start.sh

One script, two roles chosen by the first argument (`web` default, `celery`), so no invented env var:

```bash
#!/usr/bin/env bash
set -euo pipefail
ROLE="${1:-web}"

export DISPATCHARR_ENV=modular
export POSTGRES_HOST="${POSTGRES_HOST:-postgresql}" POSTGRES_PORT="${POSTGRES_PORT:-5432}"
export POSTGRES_DB="${POSTGRES_DB:-dispatcharr}" POSTGRES_USER="${POSTGRES_USER:-dispatch}"
export POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-secret}"
export REDIS_HOST="${REDIS_HOST:-valkey}" REDIS_PORT="${REDIS_PORT:-6379}"
export DISPATCHARR_PORT="${DISPATCHARR_PORT:-9191}" DISPATCHARR_LOG_LEVEL="${DISPATCHARR_LOG_LEVEL:-info}"
export DISPATCHARR_TIME_ZONE="${DISPATCHARR_TIME_ZONE:-${TZ:-UTC}}"
export UWSGI_WORKERS="${UWSGI_WORKERS:-4}" CELERY_MAX_WORKERS="${CELERY_MAX_WORKERS:-6}" CELERY_MIN_WORKERS="${CELERY_MIN_WORKERS:-1}"

mkdir -p /config/{backups,logos,cache/logos,cache/sd_posters,recordings,uploads/m3us,uploads/epgs,m3us,epgs,plugins,models,scripts,logs} /tmp/nginx
```

Then:

- Secret: `[ -f /config/jwt ] || ( umask 077; python -c 'import secrets;print(secrets.token_urlsafe(64))' > /config/jwt.tmp && mv /config/jwt.tmp /config/jwt )`; `export DJANGO_SECRET_KEY="$(tr -d '\r\n' < /config/jwt)"`. Never echo it.
- Wait loops: PostgreSQL `until pg_isready -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" -q; do sleep 1; done` (apt `postgresql-client`, or a `/dev/tcp` loop); Redis `python /app/scripts/wait_for_redis.py` (upstream script). Waiting is the log signal in a DB-less test (section 8). The DB password is applied by the external postgres app on its own start, nothing to do here.
- `role web`: render nginx: `sed "s/NGINX_PORT/${DISPATCHARR_PORT}/g" /app/docker/nginx.conf > /tmp/dispatcharr-site.conf` (and drop the `listen [::]:` line if `ip -6 addr` shows no inet6, as upstream does); `nginx -c /etc/dispatcharr/nginx.conf -e /tmp/nginx/error.log &` where our `etc/dispatcharr/nginx.conf` sets `pid /tmp/nginx.pid; error_log /dev/stderr;`, `http { client_body_temp_path /tmp/nginx/body; proxy_temp_path /tmp/nginx/proxy; fastcgi_temp_path /tmp/nginx/fastcgi; uwsgi_temp_path /tmp/nginx/uwsgi; scgi_temp_path /tmp/nginx/scgi; include /etc/nginx/mime.types; include /tmp/dispatcharr-site.conf; }` plus `events {}`; check what else upstream's site fragment expects from the Debian main `nginx.conf` (it uses `$sd_poster_cache_key` maps and `proxy_cache_path` which are `http` level directives, so the fragment goes directly inside `http`). Then `python manage.py migrate --noinput`, then `exec uwsgi --ini /app/docker/uwsgi.modular.ini --disable-logging` (drop `--disable-logging` when `DISPATCHARR_DEBUG=true`). nginx runs in the background, uwsgi is the `exec`'d main process; if nginx dies, add a small `wait -n` supervisor instead of `exec` (open question: `exec` vs `wait -n`; prefer the supervisor so a dead nginx restarts the container).
- `role celery`: wait for `/config/jwt` and `python manage.py migrate --check`, then reproduce `entrypoint.celery.sh`: `celery -A dispatcharr beat -l info &`, DVR worker, prefork autoscale worker with `--autoscale=${CELERY_MAX_WORKERS},${CELERY_MIN_WORKERS}` copied from the tag's script; final worker `exec`'d. Take the exact commands from `docker/entrypoint.celery.sh` at the tag.
- Binds: nginx listens on all interfaces (`listen NGINX_PORT`), uwsgi http 0.0.0.0:5656 and daphne 0.0.0.0:8001 are internal. All writes are under `/config` (via `/data` symlink) and `/tmp`; nothing in `/app`.

## 8. container-test.yaml

DB exception: Dispatcharr has hard `dependencies` on `postgresql` and `valkey`, will not become healthy without them (`start.sh` waits forever), and a two-service sidecar wiring is not available in `container-test.yaml`. All three criteria hold, so use narrowed smoke checks with the required comment:

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

# narrowed: requires external postgresql and valkey; full functional test not feasible in single-container suite
timeoutSeconds: 180
filePaths:
- /app/manage.py
- /app/frontend/dist/index.html
- /app/venv/bin/uwsgi
- /app/venv/bin/celery
- /usr/sbin/nginx
- /usr/share/licenses/dispatcharr/LICENSE
```

Port 9191 is in `settings.yaml`, so a probe is expected; nginx only starts after the DB and Redis waits. Option: let `start.sh` start nginx before the waits so `tcp: 9191` can pass (it would serve 502 until uwsgi is up); decide when implementing. If nginx starts first, add `tcp: [{port: '9191'}]` (a real port probe, still narrow). Never replace with no-op assertions. Verify `frontend/dist/index.html` name after the first build. Because the python base ships `HEALTHCHECK` reading `/container-test.yaml`, ensure the file list assertions pass.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write or privilege | Remap |
| --- | --- |
| Embedded PostgreSQL in `/data/db`, `su` to uid 999, `chown`, `/var/run/postgresql` | Removed: modular mode only. The chart's `setup-postgres-dirs` Alpine init container (the draft's container) is not needed. |
| Embedded Redis | Removed: external `valkey`. |
| `/etc/environment`, `/etc/profile.d/dispatcharr.sh`, `/root/.bashrc` writes | Not executed (own `start.sh`). |
| `useradd`/`PUID`/`PGID` user juggling | Not used: runs as `apps` 568. |
| `/data/*` | `/data` symlink to `/config`. |
| `/app/uwsgi.sock` | `/tmp/uwsgi.sock` (sed at build time). |
| `/app/static`, `/app/media` | `collectstatic` at build time; `/app/media` must be writable if the app uploads there, UNVERIFIED (set `MEDIA_ROOT`/symlink to `/config/media` if it is used). |
| nginx pid, temp dirs, logs | `/tmp` via own `nginx.conf` |
| `uv pip install` at runtime (`USE_LEGACY_NUMPY`) | Not supported (venv is read-only). Document. |
| Log collector writes `/data/logs/dispatcharr.log` | Under `/config/logs`; stdout stays the primary log. |
| `ulimit -n`, `nice` | Best effort; no capability needed for non-negative nice. |
| `/var/lib/nginx`, `/var/log/nginx` | Not used with our `-c` config (check `nginx -t` as UID 568). |

Draft/chart security expectations: UID 0 and writable rootfs, privileged false, extra persistence `/data` and `/var/run/postgresql`. Here: UID 568, `readOnlyRootFilesystem` true with `/tmp` tmpfs, not privileged, persistence `/config` only (replaces `/data`). Migration from the chart's aio layout is a manual dump and restore into the external PostgreSQL; the on-disk `/data/db` cannot be reused. Document it.

## 10. Risks, caveats and open questions

- Scope mismatch: the draft describes the Alpine helper. Confirm with maintainers that porting the full app is wanted; otherwise close the draft.
- Difficulty is high: Django app, nginx, uwsgi plus daphne, celery, frontend build, torch/sentence-transformers wheels (large image, several GB).
- Modular mode only; the chart and README say `aio` is the supported mode. UNVERIFIED that modular is fully supported in 0.34.1 for everything (the repository compose file and `check_external_postgres_version` suggest yes).
- Valkey as Redis replacement is UNVERIFIED. No `redis` app in this repo.
- `ffmpeg` and `comskip` differ from upstream's custom builds; hardware acceleration (VA-API, NVENC, `/dev/dri`, render group 109) needs device mounts and group membership; not handled.
- Python 3.14 is outside upstream's tested 3.13; run the app's own checks. The torch CPU wheel for aarch64 and cp314 is UNVERIFIED (may force amd64 only).
- Needs the web container and a separate celery container (same image, argument `celery`); the chart has no celery workload, so the deployment manifest must be written elsewhere.
- No DISPATCHARR_ENV `aio` fallback; users must provide PostgreSQL 17 or newer.
- First-time web setup (`DISPATCHARR_SETUP_ALLOWED_IP`) is restricted to private networks by default (compose comments).
- AGPL: ship source offer link in docs (the image contains the full source in `/app`).

## 11. Build and test steps

```sh
cd apps/dispatcharr
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local      # expect a long build
# dependencies for the run (scratch, removed afterwards)
docker network create dispatcharr-probe
docker run -d --name dispatcharr-pg --network dispatcharr-probe -e POSTGRES_USER=dispatch -e POSTGRES_PASSWORD=secret -e POSTGRES_DB=dispatcharr postgresql:<tag-from-apps/postgresql>
docker run -d --name dispatcharr-valkey --network dispatcharr-probe valkey:<tag-from-apps/valkey>
docker run --rm -d --name dispatcharr-probe --network dispatcharr-probe --read-only --tmpfs /tmp \
  -e POSTGRES_HOST=dispatcharr-pg -e REDIS_HOST=dispatcharr-valkey -v dispatcharr-probe-config:/config -p 9191:9191 dispatcharr:v0.34.1
docker logs -f dispatcharr-probe     # expect waits succeed, "Applying ... OK" migrations, uwsgi "spawned uWSGI worker", nginx up
curl -fsS http://127.0.0.1:9191/ | head
docker run --rm -d --name dispatcharr-celery --network dispatcharr-probe --read-only --tmpfs /tmp -e POSTGRES_HOST=dispatcharr-pg -e REDIS_HOST=dispatcharr-valkey -v dispatcharr-probe-config:/config dispatcharr:v0.34.1 /start.sh celery
forgetool containers test --image dispatcharr:v0.34.1 --config ./apps/dispatcharr/container-test.yaml
docker rm -f dispatcharr-probe dispatcharr-celery dispatcharr-pg dispatcharr-valkey; docker volume rm dispatcharr-probe-config; docker network rm dispatcharr-probe
```

Per protocol, step 3 (run and log parse) is mandatory. Also run once with no database present: the container must stay alive, logging "waiting for database", with no fatal exit. Use an empty `/config` volume every round. Confirm `/config/jwt` is created once and reused after restart. Max 10 rounds.

## 12. PR checklist

- Branch `feat/add-dispatcharr`; commit `feat(dispatcharr): add new container`; target `main`; PR title the same.
- Use `.github/PULL_REQUEST_TEMPLATE.md`; tick only the boxes that apply; `🤖 This PR is AI generated.` in Notes.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; the `license/cla` check shows status).
- State clearly in the PR what was not tested: arm64, hardware transcoding, comskip (not shipped), Valkey compatibility, TLS to PostgreSQL or Redis, upgrade from the chart's aio data, the celery role under load.
- Pre-completion: `bake --print` passes, VERSION aligned in Dockerfile and bake, empty `/config` works, read-only rootfs run clean, DB-dep narrowing annotated and justified, `settings.yaml` ports/env match `start.sh` and the test file.
