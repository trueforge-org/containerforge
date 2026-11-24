# fireshare — implementation plan

> Source: ./draft.md · Target: apps/fireshare/ · Difficulty: hard (Flask + React + nginx + ffmpeg, optional GPU) · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | 1.9.4 (tag `v1.9.4`, published 2026-11-22, GitHub "Latest"). Draft says 1.9.3; use 1.9.4 |
| Renovate | `datasource=github-releases depName=fireshare-app/fireshare versioning=semver` |
| License | GPL-3.0 (GitHub API; repo `LICENSE`). Bake `GPL-3.0-only` (UNVERIFIED only vs or-later) |
| Source URL | https://github.com/fireshare-app/fireshare (the draft's second link `ShaneIsrael/fireshare` is the old location) |
| Artifacts | No binary release assets (release lists none via API). Build from source tag `https://github.com/fireshare-app/fireshare/archive/refs/tags/v${VERSION}.tar.gz`; same for amd64 and arm64 |
| Checksum source | None published for source tarballs. Tag pin only; Git tag `v1.9.4` resolves to commit `8a321df459ecf3bc0ab00b97e416d7104797cdf1` (record, optionally check after download with `git`-less comparison is not possible, so UNVERIFIED) |
| Upstream Dockerfiles reviewed | `Dockerfile` (CUDA, source-built ffmpeg, not usable) and `Dockerfile.lite` (python:3.14-slim-bookworm, `ffmpeg` from apt, nginx-extras, supervisor, gosu; client built in `node:24-slim` with `npm ci && npm run build`, server installed with `pip install /app/server`). Lite is the template for this port |
| Python | upstream runs 3.14; `app/server/requirements.txt` pins old versions (e.g. Flask 3.1.1). Use python-node 3.14.8 like `apps/changedetection` does, not 3.15.2 (UNVERIFIED that the pins build on 3.15) |
| Layout | Server `app/server` (module `fireshare`, `FLASK_APP=/app/server/fireshare:create_app()`), client build output `/app/build`, nginx template `app/nginx/prod.conf`, migrations in `/migrations`, gunicorn config `/app/server/gunicorn.conf.py`, gunicorn binds `127.0.0.1:5000`, nginx serves on `FIRESHARE_PORT` (default 80) |
| Env vars (docs/EnvironmentVariables.md) | `DATA_DIRECTORY`, `PROCESSED_DIRECTORY`, `VIDEO_DIRECTORY`, `IMAGE_DIRECTORY`, `DOMAIN`, `ADMIN_USERNAME` (default `admin`), `ADMIN_PASSWORD` (default `admin`), `SECRET_KEY` (auto-generated into `/data/.secret_key`), `FIRESHARE_PORT` (80), `ENABLE_TRANSCODING` (false), `TRANSCODE_GPU` (false), `TRANSCODE_TIMEOUT` (7200), `MINUTES_BETWEEN_VIDEO_SCANS` (5), `FS_LOGLEVEL` (INFO), `THUMBNAIL_VIDEO_LOCATION` (50), `GUNICORN_WORKERS`, `GUNICORN_WORKER_CAP` (4), `GUNICORN_THREADS` (8), `SECURE_COOKIES` (false), `CORS_ORIGINS`, `LOGIN_IP_WHITELIST`, `LOGIN_IP_WHITELIST_TRUSTED_PROXIES` (1), `DISABLE_ADMINCREATE`, `STEAMGRIDDB_API_KEY`, `ANALYTICS_TRACKING_SCRIPT`, `DISCORD_WEBHOOK_URL`, `GENERIC_WEBHOOK_URL`, `GENERIC_WEBHOOK_PAYLOAD`, `PUID`/`PGID` (default 1000, handled by upstream entrypoint only) |
| Startup order (entrypoint.sh) | chown dirs, mount validation (exits if `/data`, `/videos`, `/processed` are not mountpoints), render nginx config, start nginx (`daemon on`), generate `SECRET_KEY`, `flask db upgrade`, `fireshare migrate-game-assets`, first-boot `python -m fireshare.cli create-boomerang-posters`, then `gunicorn --config /app/server/gunicorn.conf.py --bind=127.0.0.1:5000 "fireshare:create_app(init_schedule=True)"` as appuser via gosu |
| Port | Container 80 upstream; this image uses 8080 (non-root) via `FIRESHARE_PORT` |
| Volumes (upstream) | `/data` (DB, secret key), `/processed`, `/videos`, `/images` |

## 2. Target layout

```
apps/fireshare/
  Dockerfile              multi-stage: client build stage + python-node runtime
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh                directory setup, nginx render, db upgrade, gunicorn
  defaults/nginx.conf.template   copy of upstream app/nginx/prod.conf adapted (no `user`, pid/cache/temp in /tmp, listen __FIRESHARE_PORT__)
```

`defaults/` is needed for the adapted nginx template (it cannot live under read-only `/etc`; start.sh renders it to `/tmp`). No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

Runtime and build stage: `ghcr.io/trueforge-org/python-node:3.14.8@sha256:feb6e44439ea272f47b46a1511960f58af5df8056811c83973e2edec9b18afca` (copied from `apps/changedetection/Dockerfile`, which stays on 3.14 for the same kind of reason; the python-node 3.15.2 digest from the brief is not used because upstream targets 3.14). Reason: Flask server needs Python, the React client needs Node and npm. Closest siblings: `apps/changedetection` (python-node, `/app/venv`), `apps/budge` (node build inside the final image). Follow `python-runtime.instructions.md`: `/app/venv` read-only at runtime, caches in `/tmp`. If 3.14.8 tag/digest is no longer current when implementing, re-copy from changedetection.

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`, `ENV PYTHONUNBUFFERED=1`.
2. Install: `apt-get install -y --no-install-recommends nginx-extras ffmpeg libvulkan1 mesa-vulkan-drivers build-essential libssl-dev libffi-dev` (build packages purged after pip). Upstream lite uses `nginx-extras supervisor gosu ffmpeg libvulkan1 mesa-vulkan-drivers`; `supervisor` and `gosu` are not needed (single shell + `USER apps`). `nginx-extras` vs plain `nginx` depends on directives in `prod.conf` (UNVERIFIED which module is used; grep for `more_set_headers`/`headers_more` and drop to `nginx` if unused). Ubuntu 26.04 apt `ffmpeg` is unpinned and not tied to `VERSION`, which is allowed because VERSION is the app version.
3. Download source: `curl -fL https://github.com/fireshare-app/fireshare/archive/refs/tags/v${VERSION}.tar.gz` to `/tmp`, extract to `/tmp/src --strip-components=1`.
4. Client build: `cd /tmp/src/app/client && npm ci --silent && npm run build`; `mkdir -p /app && cp -r build /app/build && cp package.json /app/package.json`. Upstream uses Node 24; check `node --version` in the base satisfies the client (`engines` was not present in `package.json`, UNVERIFIED). If the base npm breaks `npm ci` (budge pins `npm@10`), apply the same pin. Set `npm_config_cache=/tmp/npm`.
5. Server: `cp -r /tmp/src/app/server /app/server && cp -r /tmp/src/migrations /app/migrations`; `/app/venv/bin/pip install --no-cache-dir /app/server` (pip cache disabled; `PIP_CACHE_DIR=/tmp/pip`).
6. nginx assets: copy `app/nginx/error.html`, `api_unavailable.html` to `/usr/local/share/fireshare/nginx/`; `prod.conf` is shipped as `defaults/nginx.conf.template` (adapted) rather than copied from the tarball, so keep a pinned copy and diff it on every version bump.
7. License: `mkdir -p /usr/share/licenses/fireshare && cp /tmp/src/LICENSE /usr/share/licenses/fireshare/`.
8. Purge build packages, `rm -rf /tmp/* /var/lib/apt/lists/*`; `chown -R apps:apps /app` is not needed beyond read access (755).
9. `ENV HOME=/config FLASK_APP=/app/server/fireshare:create_app() ENVIRONMENT=production DATA_DIRECTORY=/config/data PROCESSED_DIRECTORY=/config/processed VIDEO_DIRECTORY=/videos IMAGE_DIRECTORY=/images TEMPLATE_PATH=/app/server/fireshare/templates TRANSCODE_GPU=false FIRESHARE_LITE=true FIRESHARE_PORT=8080`. The venv bin path is already on `PATH` in the base (verify; otherwise prefix `/app/venv/bin`). Template path: upstream sets `/app/server/fireshare/templates`; with pip-installed package confirm where templates land (UNVERIFIED).
10. `USER apps`; `COPY --chmod=0755 . /`; `EXPOSE 8080`; `VOLUME /config`; `WORKDIR /config`.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}
variable "APP" { default = "fireshare" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=fireshare-app/fireshare versioning=semver
  default = "1.9.4"
}
variable "LICENSE" { default = "GPL-3.0-only" }
variable "SOURCE"  { default = "https://github.com/fireshare-app/fireshare" }
```

Add `group "default"` -> `image-local`; `image` (args `VERSION`, labels source/licenses); `image-local` (`type=docker`, tag `${APP}:${VERSION}`); `image-all` (amd64, arm64) as in `apps/adguardhome-sync`. Run `docker buildx bake --print`.

## 6. settings.yaml

- `upstream_env_url: "https://github.com/fireshare-app/fireshare"`.
- ports: `8080` tcp `required: false`.
- env (names exist in upstream docs; defaults equal to start.sh): `TZ` (`Etc/UTC`), `DOMAIN` (`""`), `ADMIN_USERNAME` (`admin`), `ADMIN_PASSWORD` (`admin`, required false; documented upstream default, flag in PR that users must change it), `SECRET_KEY` (`""`, generated into `/config/data/.secret_key`), `ENABLE_TRANSCODING` (`false`), `MINUTES_BETWEEN_VIDEO_SCANS` (`5`), `FS_LOGLEVEL` (`INFO`), `FIRESHARE_PORT` (`8080`), `GUNICORN_WORKERS` (`""`), `GUNICORN_THREADS` (`8`), `SECURE_COOKIES` (`false`). Do not list `PUID`/`PGID` (not honored, container runs as 568) and not `TRANSCODE_GPU` (fixed false in this image).
- volumes: `/config` required, `/videos` required false, `/images` required false.
- dependencies: none (no database container; SQLite in `/config/data`).

## 7. start.sh

1. `mkdir -p /config/data /config/processed /videos /images /tmp/nginx/{cache,auth-cache,client_body,proxy,fastcgi,uwsgi,scgi}` (ignore failures for `/videos` and `/images` if the rootfs is read-only and no volume is mounted; warn instead, upstream makes `/videos` mandatory, here an empty library is allowed so the container starts with no env or mounts).
2. `rm -f /config/data/*.lock /config/data/jobs.sqlite` (as upstream cleanup).
3. Render nginx: `sed "s/__FIRESHARE_PORT__/${FIRESHARE_PORT:-8080}/" /defaults/nginx.conf.template > /tmp/nginx.conf`; run `nginx -c /tmp/nginx.conf` with `daemon on` (as upstream) or start it in the background and `wait`-trap it. Needs: no `user` directive, `pid /tmp/nginx.pid`, `proxy_cache_path /tmp/nginx/cache`, `/tmp/nginx/auth-cache`, `*_temp_path /tmp/nginx/...`, `error_log stderr`, `thread_pool` allowed.
4. SECRET_KEY: if unset or an example value, read `/config/data/.secret_key`, else generate `python -c "import secrets; print(secrets.token_hex(32))"` and store with `umask 077`; export without echoing.
5. `flask db upgrade`, `fireshare migrate-game-assets` (both exist in upstream entrypoint), first-boot flag `/config/data/.boomerangs_generated` with `python -m fireshare.cli create-boomerang-posters || true`. Run with `cd /app/server` as needed; set `TMPDIR=/tmp`.
6. Apply `ADMIN_USERNAME`/`ADMIN_PASSWORD` on every start: upstream does this in-app ("re-applied on every start"), so only export them.
7. `exec gunicorn --config /app/server/gunicorn.conf.py --bind=127.0.0.1:5000 "fireshare:create_app(init_schedule=True)"`. Gunicorn stays on localhost on purpose (nginx is the public listener on 0.0.0.0:8080). `_SHM_DIR` in the gunicorn config uses `/dev/shm` if present, else tmp: fine under `--read-only` as `/dev/shm` is a tmpfs in Docker.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '8080'
http:
- port: '8080'
  path: /
filePaths:
- /app/build/index.html
- /app/server/gunicorn.conf.py
runners:
- entrypoint: ffmpeg -version
```

Matches the one settings port; `timeoutSeconds` follows `apps/changedetection` (180). Test runs with no env, so the default admin/`SECRET_KEY` paths run in the plain start; paths that need env (transcoding, `LOGIN_IP_WHITELIST` validation, webhooks) are not covered and must be run by hand. Confirm schema for `runners`/`filePaths` against siblings.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/data` (sqlite DB, secret key, game assets) | `/config/data` via `DATA_DIRECTORY` |
| `/processed` (posters, transcodes, symlinks) | `/config/processed` via `PROCESSED_DIRECTORY` (nginx `root /processed/` and `alias /data/game_assets` in the template must be rewritten to `/config/processed` and `/config/data/game_assets`) |
| `/videos`, `/images` | user volumes; unchanged; must be writable by UID 568 for uploads (upstream chowns empty dirs as root, which is impossible here; document `fsGroup`/permissions) |
| `/var/cache/nginx`, `/var/log/nginx`, `/var/run/nginx.pid`, `/etc/nginx/nginx.conf` | `/tmp/nginx/*`, `/tmp/nginx.conf` |
| `/app/build/index.html` rewrite for `ANALYTICS_TRACKING_SCRIPT` | upstream edits the file in place; unsupported here (read-only `/app`): either drop the variable or copy `/app/build` to `/tmp/build` at start and point nginx root there (UNVERIFIED need; recommend dropping in v1) |
| useradd/usermod/chown with PUID/PGID | removed; runs as `apps` 568 |

Draft security expectations: chart runs UID 0, writable rootfs, persistence `/data /processed /videos /images`. Here UID 568, read-only rootfs, persistence moves `/data` and `/processed` under `/config`. Document the data migration (mount old `/data` content at `/config/data`). No GPU/privileged in this plan.

## 10. Risks, caveats and open questions

- GPU (CUDA/NVENC) variant is out of scope: only the "lite" CPU path is ported (`TRANSCODE_GPU` forced false, no CUDA ffmpeg). The draft flags GPU as the main blocker; this is a scope decision to state in the PR.
- Python 3.14 vs 3.15: pinned to 3.14.8; revisit when requirements move.
- nginx template adaptation is the biggest risk (video auth subrequests, `X-Accel`-style locations, symlinks into `/videos`); keep a diff of upstream `prod.conf` for each bump.
- Default `ADMIN_PASSWORD=admin` is upstream's default; it is a security smell. Consider generating one when unset and printing a notice (deviation from upstream, decide before implementing).
- Library indexing on first start can be slow (draft caveat); `MINUTES_BETWEEN_VIDEO_SCANS` controls rescans.
- `nginx-extras` vs `nginx`, template path of the pip-installed package, and venv PATH are UNVERIFIED.
- No source checksum.

## 11. Build and test steps

```sh
cd apps/fireshare
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name fireshare-probe --read-only --tmpfs /tmp \
  -v fireshare-probe-config:/config fireshare:1.9.4
docker logs -f fireshare-probe
forgetool containers test --image fireshare:1.9.4 --config ./apps/fireshare/container-test.yaml
docker rm -f fireshare-probe; docker volume rm fireshare-probe-config
```

Readiness: log lines `Running migrations` complete (`flask db upgrade` finishes with no traceback), gunicorn "Listening at: http://127.0.0.1:5000", nginx accepting on 8080, `curl -fsS http://127.0.0.1:8080/` returns the React index. Second pass: mount a folder with one sample mp4 at `/videos`, wait for the scan, confirm a poster appears in `/config/processed`, and an upload works. Cap at 10 rounds.

## 12. PR checklist

- Branch `feat/add-fireshare`; commit `feat(fireshare): add new container`; same PR title; target `main`.
- Fill in `.github/PULL_REQUEST_TEMPLATE.md`; check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA notice: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; see `license/cla` check).
- Honest untested list: arm64, large-library scanning, transcoding, upload permissions on mounted volumes, analytics script feature (dropped), GPU variant (not provided).
- Pre-completion: bake `--print` ok, Dockerfile/bake aligned on `VERSION`, rootless + read-only verified, empty `/config` start verified, no downstream consumers.
