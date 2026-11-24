# emby-sync — implementation plan
> Source: ./draft.md · Target: apps/emby-sync/ · Difficulty: medium (high compatibility risk) · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

The plan targets the same upstream state as the draft (repo `cameronurnes/emby-sync`, commit `63bd8b3`). The upstream project has **no tags and no releases**, so `VERSION` is the full commit SHA of `master` HEAD: `63bd8b3e952aac416fa18dd1a1d16cb611f63a8e` (confirmed with `git ls-remote`). The Docker Hub owner `lastelement21` differs from the source repo owner; the README of `cameronurnes/emby-sync` points to `lastelement21/emby-sync`, so the repo is the authoritative source and the Hub image is a build of it.

| Item | Value |
| --- | --- |
| Version | commit `63bd8b3e952aac416fa18dd1a1d16cb611f63a8e` (no tags or releases exist) |
| Renovate | `datasource=git-refs depName=cameronurnes/emby-sync packageName=https://github.com/cameronurnes/emby-sync currentDigest=63bd8b3e952aac416fa18dd1a1d16cb611f63a8e` (pattern copied from the `KASM_NOVNC_VERSION` variable in this repo) |
| License | MIT (LICENSE file present in the repo) |
| Source | https://github.com/cameronurnes/emby-sync |
| Download | https://github.com/cameronurnes/emby-sync/archive/63bd8b3e952aac416fa18dd1a1d16cb611f63a8e.tar.gz (source archive, arch independent; dependencies from PyPI) |
| Checksum | None published. The commit SHA in the URL pins the content. |
| Upstream Dockerfile reviewed | https://github.com/cameronurnes/emby-sync/blob/63bd8b3/Dockerfile (`python:3.7-alpine`, venv, `pip install -r requirements.txt` plus `gunicorn`, `ENV FLASK_APP emby-sync.py`, `EXPOSE 5000`, `ENTRYPOINT ./boot.sh`). `boot.sh`: `flask db upgrade`, then `exec gunicorn -b :5000 --access-logfile - --error-logfile - emby-sync:app`. |

Env vars read by `config.py`: `SECRET_KEY` (both the Flask secret and the Emby API key sent as `X-Emby-Token`), `EMBY_SERVER` (Emby base URL), `DEFAULT_ROOM` (default `Bacon Bar`), `INTERVAL` (default `3.0`), `BUFFER` (default `0`), `SYNC_LIMIT` (default `8`), `DATABASE_URL` (default `sqlite:///<app dir>/app.db`). The dev server also reads `HOST` and `PORT` (not used in the container).

`requirements.txt` pins very old packages (Flask 1.1.2, Jinja2 2.11.2, MarkupSafe 1.1.1, SQLAlchemy 1.3.18, Flask-SQLAlchemy 2.4.4, Werkzeug 1.0.1, Flask-Bootstrap 3.3.7.1, and others).

## 2. Target layout

```
apps/emby-sync/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```

No `defaults/` (nothing to seed). No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`

Python web app with a venv and gunicorn. Closest siblings: `apps/bazarr` (python base, `uv pip install` during build) and `apps/apprise-api` (explicit `/app/venv`). Follow `python-runtime.instructions.md`: install into `/app/venv`, treat it as read-only at runtime.

## 4. Dockerfile

1. `FROM` from section 3, `ARG VERSION`, `ARG TARGETARCH` (unused, can be omitted).
2. `USER root`.
3. `ENV HOME=/tmp FLASK_APP=emby-sync.py DATABASE_URL=sqlite:////config/app.db`.
4. One `RUN` layer:
   - `mkdir -p /app/emby-sync /usr/share/licenses/emby-sync`
   - `curl -fsSL -o /tmp/src.tar.gz "https://github.com/cameronurnes/emby-sync/archive/${VERSION}.tar.gz"` then `tar xzf /tmp/src.tar.gz -C /app/emby-sync --strip-components=1`
   - install dependencies into the venv: `/app/venv/bin/pip install --no-cache-dir -r /app/emby-sync/requirements.txt gunicorn`. **This will very likely fail on Python 3.15** (see section 10). Fallback inside the same step: install the same package names without `==` pins (strip with `sed -E 's/==.*//' requirements.txt > /tmp/requirements.unpinned.txt`), constrained by `Flask<3`, `Flask-SQLAlchemy<3`, `SQLAlchemy<2`, `Werkzeug<3`, then fix the code incompatibilities the run test exposes. Keep whichever set builds and record it in a comment.
   - add build tools only if a wheel is missing (`build-essential`, `libffi-dev`), and purge them afterwards. Do not re-install packages already in the base.
   - `cp /app/emby-sync/LICENSE /usr/share/licenses/emby-sync/LICENSE`
   - `chown -R apps:apps /app && chmod -R 755 /app`, `rm -rf /tmp/*`
5. `USER apps`
6. `COPY --chmod=0755 . /`
7. `WORKDIR /app/emby-sync`, `EXPOSE 5000`, `VOLUME /config`.

## 5. docker-bake.hcl

```hcl
variable "APP" {
  default = "emby-sync"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=cameronurnes/emby-sync packageName=https://github.com/cameronurnes/emby-sync currentDigest=63bd8b3e952aac416fa18dd1a1d16cb611f63a8e
  default = "63bd8b3e952aac416fa18dd1a1d16cb611f63a8e"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/cameronurnes/emby-sync"
}
```

Plus `docker-metadata-action`, `image`, `image-local` (tag `${APP}:${VERSION}`), `image-all` (amd64 and arm64) and the default group, copied from `apps/adguardhome-sync/docker-bake.hcl`. Validate with `docker buildx bake --print`. A SHA tag is long; if maintainers prefer, tag with the first 7 characters via a second variable (UNVERIFIED convention, check the `kasm` sibling).

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/cameronurnes/emby-sync"
ports:
  - port: 5000
    protocol: tcp
    required: true
env:
  - name: EMBY_SERVER
    default: ""
    required: false
  - name: SECRET_KEY
    default: ""
    required: false
  - name: DEFAULT_ROOM
    default: "Bacon Bar"
    required: false
  - name: INTERVAL
    default: "3.0"
    required: false
  - name: BUFFER
    default: "0"
    required: false
  - name: SYNC_LIMIT
    default: "8"
    required: false
  - name: DATABASE_URL
    default: "sqlite:////config/app.db"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

`EMBY_SERVER` and `SECRET_KEY` are required for real use (upstream README marks them required) but are `required: false` here with an empty default because the test harness runs with no env and `required: true` needs a non-empty default or handling in `start.sh`. `start.sh` logs a clear warning when they are empty. No container dependencies (Emby is an external server the user provides).

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

export TZ="${TZ:-Etc/UTC}"
export DATABASE_URL="${DATABASE_URL:-sqlite:////config/app.db}"
export FLASK_APP=emby-sync.py

mkdir -p /config

if [ -z "${EMBY_SERVER:-}" ] || [ -z "${SECRET_KEY:-}" ]; then
  echo "[start.sh] WARNING: EMBY_SERVER and/or SECRET_KEY (Emby API key) are not set; the app will start but cannot talk to Emby." >&2
fi

cd /app/emby-sync
/app/venv/bin/flask db upgrade
exec /app/venv/bin/gunicorn -b 0.0.0.0:5000 \
  --access-logfile - --error-logfile - emby-sync:app
```

- Idempotent: `flask db upgrade` is a no-op when the schema is current. It creates `/config/app.db` on an empty volume.
- Nothing is written under `/app` (migrations are only read).
- Binds `0.0.0.0:5000`. Upstream `-b :5000` is equivalent; made explicit.
- The final command is `exec gunicorn`. `SECRET_KEY` stays in the environment; it is never written to a file or placed in the argument list.
- The upstream gunicorn runs a single worker by default, which matters because the APScheduler sync loop starts in each process on import. Do not add `-w` greater than 1 without checking.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

tcp:
- port: '5000'

filePaths:
- /app/emby-sync/emby-sync.py
- /app/venv/bin/gunicorn
- /usr/share/licenses/emby-sync/LICENSE
```

An `http` probe is not used because the route behaviour with no `EMBY_SERVER` is unknown (the login page may call Emby); UNVERIFIED, upgrade to `http` with path `/login` once confirmed in the run test. The test supplies no env vars, so the Emby-dependent code paths are not exercised and must be checked by hand in the run step.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `<app dir>/app.db` (SQLite, from `config.py`) | `DATABASE_URL=sqlite:////config/app.db`, persistent. |
| `flask db upgrade` | Reads `/app/emby-sync/migrations` only; no writes under `/app`. |
| Python bytecode and pip caches | `PYTHONDONTWRITEBYTECODE` from the base; `HOME=/tmp`; the venv is installed at build time. |
| Upstream runs as `emby-sync` user (alpine) | Runs as `apps`. |

Draft expectations reconciled: the chart runs as root with a writable rootfs and no persistence (`persistence {}`), so its SQLite DB is lost on pod restart. The container here is rootless and read-only, and keeps the DB in `/config`.

## 10. Risks, caveats and open questions

- **Highest risk: Python compatibility.** Upstream targets Python 3.7 with 2020-era pins. Python 3.15 (base image) breaks old wheels (`MarkupSafe==1.1.1`, `SQLAlchemy==1.3.18`, `Flask==1.1.2` are all unlikely to build or import). Expect to upgrade the stack (Flask 2/3, SQLAlchemy 2, Flask-SQLAlchemy 3, Flask-Migrate 4, Flask-Login, Flask-WTF, Flask-Bootstrap replacement) and patch code such as `from flask_bootstrap import Bootstrap`. UNVERIFIED whether that is feasible without forking. If the 10-round limit is hit, record as `unfixable`; there is no older Python base in this repo to fall back to.
- The upstream `boot.sh` uses `source` under `#!/bin/sh`; not used here, `start.sh` calls the venv binaries directly.
- No releases or tags, so renovate tracks a git ref and will propose every new commit; review each.
- `SECRET_KEY` doubles as the Emby API key and the Flask session key. Reuse of one value for both is an upstream design choice.
- Needs a reachable Emby server and a valid API key. Not testable in the single-container suite.
- The source repo and the Docker Hub owner differ; the repo README names the Hub image, so it is treated as authoritative.
- UNVERIFIED: that the app starts without `EMBY_SERVER` and `SECRET_KEY` (the first sync-cycle job will likely log errors, and Flask may refuse sessions without a secret).
- Not a blocker for arm64: pure Python, but wheels must exist for 3.15 on arm64.

## 11. Build and test steps

```sh
cd apps/emby-sync
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local

docker run --rm -d --name emby-sync-probe --read-only --tmpfs /tmp \
  -v emby-sync-probe-config:/config emby-sync:63bd8b3e952aac416fa18dd1a1d16cb611f63a8e
docker logs -f emby-sync-probe

# from the repo root
forgetool containers test \
  --image emby-sync:63bd8b3e952aac416fa18dd1a1d16cb611f63a8e \
  --config ./apps/emby-sync/container-test.yaml

docker rm -f emby-sync-probe; docker volume rm emby-sync-probe-config
```

Readiness signal: gunicorn logs `Listening at: http://0.0.0.0:5000` and `Booting worker`, `flask db upgrade` finishes without a traceback, and `/config/app.db` exists. A second run with `-e EMBY_SERVER=http://emby.invalid -e SECRET_KEY=test` checks the configured path, which forgetool cannot do.

## 12. PR checklist

- Branch `feat/add-emby-sync`, commit and PR title `feat(emby-sync): add new container`, target `main`.
- Fill in `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections and checkboxes, check only what applies.
- Put `🤖 This PR is AI generated.` in the Notes section.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it. The `license/cla` check shows the status.
- Pre-completion: bake `--print` exits 0, `ARG VERSION` equals the bake default, final `USER apps`, `COPY --chmod=0755 . /`, `--read-only --tmpfs /tmp` start with empty `/config`.
- Untested until run: the whole build (dependency resolution on Python 3.15 is the main unknown), runtime behaviour against a real Emby server, arm64, and the forgetool run. State this in the PR; leave "Built container locally" unchecked if not done.
