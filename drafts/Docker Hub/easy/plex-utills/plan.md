# plex-utills — implementation plan
> Source: ./draft.md · Target: apps/plex-utills/ · Difficulty: medium (draft says easy; hard-coded paths, no usable release) · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | The draft's release `0.21.12` (tag `cb1cde4f...`, 2021-12-07) is **not** what the image runs: it predates the web UI (no `main.py`/`version` at that tag). Docker `:latest` is built from `master` = commit `e945c0cb113b8ec3bb0b0f15c544f600e6e16d3f` (2023-02-02, `version` file reads `23.02.02`). Plan: `VERSION=23.02.02`, `COMMIT=e945c0cb113b8ec3bb0b0f15c544f600e6e16d3f`. Upstream is dormant since 2023-02. |
| Renovate | No tag matches 23.02.02. Annotate `VERSION` with `datasource=github-tags depName=jkirkcaldy/plex-utills versioning=loose` (it will not propose the older 0.21.x tags as an upgrade only if a package rule ignores them; UNVERIFIED) and bump `COMMIT` by hand. Open question in section 10. |
| License | `MIT` (GitHub API; `LICENSE`: "MIT License, Copyright (c) 2021 jkirkcaldy") |
| Source | https://github.com/jkirkcaldy/plex-utills |
| Download | `https://github.com/jkirkcaldy/plex-utills/archive/${COMMIT}.tar.gz` (verified HTTP 200; pure Python, arch independent) |
| Checksum | None published. HTTPS only, pinned by full commit SHA. |
| Upstream Dockerfile reviewed | `python:3.9.16-slim-bullseye`; apt: `wget git`, mediaarea repo, `mediainfo nginx ffmpeg libsm6 libxext6 nano`; `COPY start.sh`, `./app`, `main.py`, `requirements.txt`, `version` into `/app`; `pip install -Ur requirements.txt` and `pip install git+https://github.com/AnthonyBloomer/tmdbv3api.git`; `EXPOSE 80 5000`; `VOLUME /films /config /logs`; `CMD /app/start.sh` |
| `start.sh` upstream | `nginx` (port 80 reverse proxy to 5000, serves `/static` from `/app/app/static`) then `gunicorn --chdir /app main:app -w 9 --threads 2 -b 0.0.0.0:5000` |
| requirements.txt (unpinned) | `plexapi configparser numpy pillow imagehash schedule flask flask_script flask_sqlalchemy bootstrap-flask flask_apscheduler flask_wtf wtforms pymediainfo tautulli croniter opencv-python-headless flask_paginate gunicorn` (`tmdbv3api` commented out; imported by the code, PyPI `tmdbv3api 1.10.0` exists). `tzlocal` is imported but not listed (comes transitively via APScheduler; UNVERIFIED). |
| Ports | `5000` (gunicorn, Flask UI at `/`, `/config`, `/films`, `/admin_config`). Port 80 (nginx) is not needed. |
| Config | No env vars. All settings live in SQLite `/config/app.db`, edited through the web UI (Plex URL/token, libraries, TMDB key, Tautulli). `TZ` is honored via `tzlocal`. The draft's compose also passes `UID`/`GID`, but the code does not read them. |
| Hard-coded paths | `/config/app.db`, `/config/backup/**`, `/logs/*.log` (RotatingFileHandler opened **at import time**), `/films` (media, read only), `/tmp/*_poster.png`, relative `app/static/default_db/default_app.db`, `app/img/...`, `./version` (needs cwd = source root). |
| `/` route | Reads the `plex_utills` table; renders `migrate.html` or `index.html` depending on the `migrated` flag. Needs the DB to exist (`setup.table_check` creates it from the default DB on first import). |

## 2. Target layout

```
apps/plex-utills/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```
No nginx config, no `defaults/` (the default DB ships inside the source tree). No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`

Why: Python Flask app plus apt `mediainfo`. Closest sibling: `apps/bazarr` (python base, `apt` for `mediainfo`, deps installed into the system interpreter, source under `/app`).

## 4. Dockerfile

1. `FROM` above; `ARG VERSION`, `ARG COMMIT`; `USER root`.
2. `ENV HOME=/config TZ=Etc/UTC PYTHONUNBUFFERED=1`.
3. `RUN apt-get update && apt-get install -y --no-install-recommends mediainfo && rm -rf /var/lib/apt/lists/*` (the `mediainfo` package pulls in its `libmediainfo` library; UNVERIFIED on Ubuntu 26.04, confirm with `apt-cache depends mediainfo` in the build step). The draft also lists `ffmpeg`; code review found no `ffmpeg` or `subprocess` use (only `pymediainfo.MediaInfo.parse` and OpenCV, whose headless wheel bundles its own codecs), so **omit ffmpeg** unless the run shows otherwise. These apt packages are not the app's version, so they are not pinned (documented here; `VERSION` does not depend on apt). `rm -rf /var/lib/apt/lists/*`.
4. Source and Python deps in one `RUN`:
   - `curl -fsSL -o /tmp/pu.tar.gz "https://github.com/jkirkcaldy/plex-utills/archive/${COMMIT}.tar.gz"`; `mkdir -p /app/plex-utills && tar xzf /tmp/pu.tar.gz -C /app/plex-utills --strip-components=1`.
   - `grep -qx "${VERSION}" /app/plex-utills/version` (fails the build if the `version` file does not match, keeping the image and tag aligned).
   - `pip install -r /app/plex-utills/requirements.txt tmdbv3api tzlocal` (use the PyPI `tmdbv3api`, pin `==1.10.0` after checking against the git HEAD the upstream image installs; UNVERIFIED that PyPI and git HEAD are API-identical).
   - `ln -s /config/logs /logs` (upstream hard-codes `/logs`; the target is created at runtime).
   - `mkdir -p /usr/share/licenses/plex-utills && cp /app/plex-utills/LICENSE /usr/share/licenses/plex-utills/`.
   - `rm -rf /tmp/* && chown -R root:root /app/plex-utills && chmod -R a+rX,go-w /app/plex-utills`.
5. `USER apps`; `COPY --chmod=0755 . /`.
6. `WORKDIR /app/plex-utills`; `EXPOSE 5000`; `VOLUME /config`. `/films` is a read-only user mount, not declared as `VOLUME`.

nginx is dropped: Flask serves `/static` itself, and port 80 would need privileges. This is a deliberate change from upstream.

## 5. docker-bake.hcl

- `APP = "plex-utills"`
- `VERSION`: `// renovate: datasource=github-tags depName=jkirkcaldy/plex-utills versioning=loose` then `default = "23.02.02"`
- extra `variable "COMMIT"` with default `"e945c0cb113b8ec3bb0b0f15c544f600e6e16d3f"` passed in `target "image"` `args = { VERSION = "${VERSION}", COMMIT = "${COMMIT}" }`.
- `LICENSE = "MIT"`; `SOURCE = "https://github.com/jkirkcaldy/plex-utills"`
- Standard four targets and the default group as in `apps/adguardhome-sync/docker-bake.hcl`; validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/jkirkcaldy/plex-utills"
ports:
  - port: 5000
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
  - name: GUNICORN_THREADS        # ours, read by start.sh
    default: "4"
    required: false
volumes:
  - path: /config
    required: true
  - path: /films                  # read-only media library, same path as Plex sees it
    required: false
```
Only `TZ` is read by the app (via `tzlocal`). `GUNICORN_THREADS` is an image-level knob read by `start.sh`; drop it if maintainers prefer no custom vars. `UID`/`GID` from the upstream compose are deliberately not listed (not read). No `dependencies` (Plex is external, `apps/plex` exists but is not required in the same container set).

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config/logs /config/backup     # first-run dirs; /logs is a symlink to /config/logs

cd /app/plex-utills                      # app opens app/static/default_db/... and ./version relatively
exec /usr/local/bin/gunicorn --chdir /app/plex-utills main:app \
  -w 1 --threads "${GUNICORN_THREADS:-4}" -b 0.0.0.0:5000 \
  --worker-tmp-dir /tmp --access-logfile -
```
Why `-w 1`: `app/schedule.py` starts an APScheduler and `app/__init__.py` opens the SQLite DB at import, so 9 workers (upstream) would run 9 schedulers and race on first-run DB creation. First-run DB seeding is done by the app itself (`setup.table_check` copies `default_app.db` to `/config/app.db` when missing), which only writes to `/config`. Binds `0.0.0.0`; logs also go to stdout via the app's stream handler plus gunicorn's access log.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '5000'
filePaths:
- /app/plex-utills/main.py
- /app/plex-utills/app/static/default_db/default_app.db
- /usr/share/licenses/plex-utills/LICENSE
```
Port 5000 is the only declared port. An `http` probe on `/` can be added once step 3 shows that `/` returns 200 with an empty DB (UNVERIFIED; the route reads `plex[0].migrated` and fails if the default DB seeding did not run). The test needs no env vars, so no code path is hidden from it.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
|---|---|
| `/config/app.db`, `/config/backup/**` | already `/config`; seeded by the app on first run |
| `/logs/application_log.log`, `application_#log.log`, `script_log.log` (opened at import; crash if missing) | `/logs` symlink to `/config/logs`, directory created by `start.sh` before gunicorn |
| `/logs/support.csv`, `/logs/system_info.txt` (support bundle) | same symlink |
| `/tmp/*_poster.png` (poster temp files) | already `/tmp` |
| `chmod 777` walk over `/config` (`main.py`/`setup.py`) | harmless when `apps` owns `/config` |
| nginx logs `/var/log/plex_utills.log`, port 80 | nginx removed |
| gunicorn worker heartbeat files | `--worker-tmp-dir /tmp` |
| `/films` | mount read-only (the app only reads media for mediainfo) |

Draft reconciliation: chart runs UID 0 and a writable rootfs; neither is needed. Extra persistence `/logs` becomes `/config/logs`; `/films` stays a user-supplied read-only mount. Not privileged (the upstream compose adds `SYS_ADMIN`/`DAC_READ_SEARCH` only for CIFS mounts on Windows hosts).

## 10. Risks, caveats and open questions

- Version decision: the draft's 0.21.12 release is the old CLI/script generation. The running image is `master` at 23.02.02. Renovate cannot track this cleanly; maintainers must accept a manual `COMMIT` bump or decline the app.
- Hard-coded secrets in code: `app.secret_key` and a TMDB API key are in the source (`app/__init__.py`, `app/scripts.py`). Sessions and CSRF protection are weak; do not expose to the internet.
- Upstream is dormant and its `requirements.txt` is unpinned. UNVERIFIED on Python 3.15: `numpy`, `pillow`, `opencv-python-headless`, `imagehash`, `flask_sqlalchemy` (new major versions vs 2023 code using `Plex.query` patterns), `flask_apscheduler`, `bootstrap-flask`. Expected failure candidates are the Flask-SQLAlchemy 3.x and Bootstrap-Flask APIs; fallbacks: pin versions from early 2023 (`Flask<2.3`, `Flask-SQLAlchemy<3.1`, `SQLAlchemy<2`), or use the 3.14 python base.
- `tzlocal` is imported but missing from `requirements.txt`; the Dockerfile installs it explicitly.
- Draft caveats confirmed: the library must be mounted at `/films` with the same relative layout as Plex; scans are CPU/IO heavy. Draft's `ffmpeg` is likely unnecessary; image size is smaller without it.
- No auth on the UI; it stores the Plex token in SQLite in `/config`.
- Image has no checksum for the source tarball; pinned by commit SHA.
- amd64 and arm64: `opencv-python-headless` and `numpy` ship aarch64 wheels (UNVERIFIED for 3.15).

## 11. Build and test steps

```sh
cd apps/plex-utills
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create plex-utills-probe-config
docker run --rm -d --name plex-utills-probe --read-only --tmpfs /tmp \
  -v plex-utills-probe-config:/config plex-utills:23.02.02
docker logs -f plex-utills-probe    # expect "Listening at: http://0.0.0.0:5000", "Running setup Helper", no traceback
curl -fsS http://<container-ip>:5000/ -o /dev/null -w '%{http_code}\n'
docker exec plex-utills-probe ls /config    # expect app.db, backup/, logs/
docker rm -f plex-utills-probe; docker volume rm plex-utills-probe-config
forgetool containers test --image plex-utills:23.02.02 --config ./apps/plex-utills/container-test.yaml
```
Then restart with the same volume to confirm idempotent startup. A real Plex server is needed to test scans; mount a small media folder at `/films:ro`. Cap at 10 rounds and clean up each round.

## 12. PR checklist

- Branch `feat/add-plex-utills`; commit and PR title `feat(plex-utills): add new container`; base `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections and checkboxes, tick only what applies.
- Put `🤖 This PR is AI generated.` in the Notes section.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it (`license/cla` check).
- Be honest about what is untested: dependency resolution on Python 3.15, arm64, any real Plex scan or poster upload, the media-path mapping, whether `/` returns 200 on first run. Explain the commit-pinned version and the nginx removal in the PR body.
- Pre-completion: bake `--print` OK, `VERSION`/`COMMIT` aligned with the Dockerfile and the `version` file check, rootless, read-only rootfs, empty `/config` start, tests not weakened.
