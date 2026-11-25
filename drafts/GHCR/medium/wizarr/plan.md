# wizarr — implementation plan
> Source: ./draft.md · Target: apps/wizarr/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | v2026.10.1 (GitHub latest release, published 2026-10-12, "Stable Release v2026.10.1"). Source: https://api.github.com/repos/Wizarrrr/wizarr/releases/latest (read via `gh api`). Draft container tag `ghcr.io/wizarrrr/wizarr:v2026.10.1` matches. |
| Renovate | `datasource=github-releases depName=Wizarrrr/wizarr versioning=loose` (CalVer-style tags `vYYYY.MM.N`, not strict semver). |
| License | MIT (GitHub SPDX `MIT`, from `gh api repos/Wizarrrr/wizarr/license`). |
| Source URL | https://github.com/Wizarrrr/wizarr |
| Download | No release assets. Source tarball `https://github.com/Wizarrrr/wizarr/archive/refs/tags/v${VERSION}.tar.gz`. The app is installed at build time (uv venv plus npm build), so no arch-specific download. |
| Checksum source | None published on the release. The tag tarball is pinned by tag; the checksum of the tarball was not captured (UNVERIFIED). |
| Per-arch | amd64: yes (interpreted app, built in-image). arm64: yes (same process, built natively under buildx). Arm64 was not run. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/Wizarrrr/wizarr/936143363897efd3ca68568fdf6fdd9a0d63f559/Dockerfile (the commit pinned by the chart image's Dockerfile per the draft). Stages: `deps` and `builder` and runtime, all `ghcr.io/astral-sh/uv:python3.13-alpine`. Deps: `apk add nodejs npm`, `uv sync --frozen --no-install-project --no-dev`, `npm --prefix app/static/ ci`. Builder: `uv sync --frozen --no-dev`, `pybabel compile --use-fuzzy -d app/translations`, `DOCKER_BUILD=true npm --prefix app/static/ run build`. Runtime: `apk add curl tzdata su-exec`, `COPY --chown=1000:1000` of `.venv`, `app`, and the source; `mkdir -p /data/database /.cache`; `COPY wizard_steps /opt/default_wizard_steps`; `docker-entrypoint.sh` as `ENTRYPOINT`; `CMD ["uv","run","--frozen","--no-dev","gunicorn","--config","gunicorn.conf.py","--umask","007","run:app"]`; `EXPOSE 5690`; `HEALTHCHECK` on `/health`; no `VOLUME`, no `USER`. |
| Entrypoint (upstream) | https://api.github.com/repos/Wizarrrr/wizarr/contents/docker-entrypoint.sh?ref=936143363897efd3ca68568fdf6fdd9a0d63f559 (via `gh api`). Runs as root to map `PUID`/`PGID` to a user (`wizarruser`/`wizarrgroup`), chowns `/data/database`, `/.cache`, `/opt/default_wizard_steps`, then `exec su-exec`. Runs `FLASK_SKIP_SCHEDULER=true uv run --frozen --no-dev flask db upgrade`, then `exec "$@"`. |
| Gunicorn (upstream) | `gunicorn.conf.py` at the same ref (via `gh api`): `workers` from `GUNICORN_WORKERS` (default 1), `threads` from `GUNICORN_THREADS` (default 4), `worker_class = "gthread"`, `timeout` from `GUNICORN_TIMEOUT` (default 120), `bind` = `HOST:PORT` (defaults `0.0.0.0:5690`), `loglevel` from `GUNICORN_LOG_LEVEL` (default `warning`). SQLite, so one worker by default. |
| Port | `5690/tcp` (upstream `EXPOSE 5690`, `PORT` default 5690, docs `5690:5690`). |
| Env vars (real) | From the upstream Dockerfile, entrypoint and gunicorn config: `HOST` (default `0.0.0.0`), `PORT` (default `5690`), `FLASK_ENV=production`, `APP_VERSION`, `GUNICORN_WORKERS`, `GUNICORN_THREADS`, `GUNICORN_TIMEOUT`, `GUNICORN_LOG_LEVEL`, `UV_COMPILE_BYTECODE`, `UV_LINK_MODE` (build-time). From the docs (https://docs.wizarr.dev/getting-started/installation.md): `DISABLE_BUILTIN_AUTH` (example `false`; default not stated, UNVERIFIED), `TZ` (example `Europe/London`). `PUID`/`PGID` are read by the upstream entrypoint only; not used here (section 9). |
| Data paths | Docs: container data is `/data` (volume `/path/to/appdata:/data`). Upstream Dockerfile creates `/data/database`, and the entrypoint chowns it. The exact SQLite file name under `/data/database` was not confirmed (UNVERIFIED). Draft says the chart uses `/data/database`. |
| Other writable paths (upstream) | `/.cache` (uv/npm caches, created in the Dockerfile); `/opt/default_wizard_steps` (copied from `wizard_steps/`, chowned by the entrypoint; the app's use of it is UNVERIFIED). |
| Python version | Upstream builds on `ghcr.io/astral-sh/uv:python3.13-alpine`. This plan uses the ContainerForge `python:3.15.2` base. `requires-python` in `pyproject.toml` was not read in this run (UNVERIFIED that Wizarr supports Python 3.15). |
| Dependencies | None. Media servers (Plex, Jellyfin, Emby) and invitation settings are configured in the UI at runtime. |
| arm64 image | UNVERIFIED: `ghcr.io/wizarrrr/wizarr` manifest was not inspected. Build from source for both arches. |

## 2. Target layout

- `apps/wizarr/Dockerfile`
- `apps/wizarr/docker-bake.hcl`
- `apps/wizarr/settings.yaml`
- `apps/wizarr/container-test.yaml`
- `apps/wizarr/start.sh` (replaces upstream `docker-entrypoint.sh`)

No `defaults/`, `etc/` or `health/` needed: the app creates its database on first start (the `flask db upgrade` step runs from `start.sh`). No `root/` (never used). No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

- Final stage: `FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`. Fits because the app is a Python Flask app with a venv built at image build time; the python base supplies the interpreter.
- Build stage: `FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5`, because the static-asset build needs `npm` and the Python build needs `pip`. The draft's "Runtime image: python" and "node/npm: npm (inferred)" match this split.
- Closest sibling: `apps/bazarr` (python base, `uv pip install` of requirements at build time, `/app/bin` for app code, `exec` in `start.sh`). Second sibling for a python-node build: `apps/changedetection` (python-node base, venv under `/app`).

## 4. Dockerfile

1. Build stage: `FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5 AS build`, `ARG VERSION`, `USER root`, `ENV UV_COMPILE_BYTECODE=1 UV_LINK_MODE=copy UV_CACHE_DIR=/tmp/uv-cache PIP_CACHE_DIR=/tmp/pip-cache npm_config_cache=/tmp/npm-cache`.
2. Fetch the source: `curl -fL https://github.com/Wizarrrr/wizarr/archive/refs/tags/v${VERSION}.tar.gz -o /tmp/wizarr.tar.gz && mkdir -p /tmp/src && tar xzf /tmp/wizarr.tar.gz -C /tmp/src --strip-components=1`. Then `rm /tmp/wizarr.tar.gz`.
3. Install uv: `pip install uv` in the build stage (the uv image is not used; keeps the base pinned). Remove afterwards only if it is not needed at runtime (the runtime uses the venv binaries directly, see step 7).
4. Python deps: `cd /tmp/src && uv sync --frozen --no-dev --no-install-project` then `uv sync --frozen --no-dev` (matches upstream builder). Create the venv at `/app/wizarr/.venv` by setting `UV_PROJECT_ENVIRONMENT=/app/wizarr/.venv` so the build writes it directly into the final layout.
5. Translations and assets: `uv run --frozen --no-dev pybabel compile --use-fuzzy -d app/translations`, then `mkdir -p app/static/js app/static/css && DOCKER_BUILD=true npm --prefix app/static/ ci --cache /tmp/npm-cache && DOCKER_BUILD=true npm --prefix app/static/ run build && rm -rf app/static/node_modules`. These are the upstream builder steps (verified in the Dockerfile).
6. Copy the app tree into `/app/wizarr/` (`cp -r /tmp/src/app /tmp/src/run.py /tmp/src/gunicorn.conf.py /tmp/src/pyproject.toml /tmp/src/wizard_steps /app/wizarr/`; `run.py` is needed because `run:app` is the gunicorn target; confirm the file name in the tree before copying). Clean `/tmp/src` after.
7. Final stage: `FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`, `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
8. `COPY --from=build --chown=apps:apps /app/wizarr/ /app/wizarr/` and the license: `COPY --from=build /tmp/src/LICENSE /usr/share/licenses/wizarr/LICENSE`.
9. Default wizard steps: `COPY --from=build /tmp/src/wizard_steps/ /app/wizarr/default_wizard_steps/` (path inside `/app`, not `/opt`, so the read-only rootfs is respected; the app's read path for these steps is UNVERIFIED, see section 10).
10. No `/data` symlink is created in the image: the database location is handled through the app's config (section 9), not by a root-level link.
11. Permissions: `chown -R apps:apps /app/wizarr && chmod -R 755 /app/wizarr`.
12. `ENV HOST=0.0.0.0 PORT=5690 FLASK_ENV=production HOME=/config XDG_CACHE_HOME=/tmp UV_CACHE_DIR=/tmp/uv-cache`. `APP_VERSION=${VERSION}` (upstream sets `APP_VERSION` from `ARG APP_VERSION=dev`; set it from this image's `ARG VERSION`).
13. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 5690

WORKDIR /app/wizarr
VOLUME /config

CMD ["/start.sh"]
```

`COPY --chmod=0755 . /` copies `start.sh` (allow-listed). `WORKDIR /app/wizarr` lets `gunicorn.conf.py` and `run:app` resolve.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "wizarr"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=Wizarrrr/wizarr versioning=loose
  default = "2026.10.1"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/Wizarrrr/wizarr"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
  }
  labels = {
    "org.opencontainers.image.source" = "${SOURCE}"
    "org.opencontainers.image.licenses" = "${LICENSE}"
  }
}

target "image-local" {
  inherits = ["image"]
  output = ["type=docker"]
  tags = ["${APP}:${VERSION}"]
}

target "image-all" {
  inherits = ["image"]
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}
```

`VERSION` is `2026.10.1` (tag `v2026.10.1`; the `v` is added in the URL). Validate with `docker buildx bake --print` from `apps/wizarr/`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/Wizarrrr/wizarr"
ports:
  - port: 5690
    protocol: tcp
    required: false
env:
  - name: PORT
    default: "5690"
    required: false
  - name: GUNICORN_WORKERS
    default: "1"
    required: false
  - name: GUNICORN_THREADS
    default: "4"
    required: false
  - name: GUNICORN_TIMEOUT
    default: "120"
    required: false
  - name: GUNICORN_LOG_LEVEL
    default: "warning"
    required: false
  - name: DISABLE_BUILTIN_AUTH
    default: "false"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

Notes:
- Only variables the app or its gunicorn config reads are listed (verified in `gunicorn.conf.py` and the entrypoint). `DISABLE_BUILTIN_AUTH` default `false` follows the docs example; its actual default in the app is UNVERIFIED.
- `HOST` is intentionally not listed: it is fixed to `0.0.0.0` in the image and gunicorn reads it, so listing it would invite misconfiguration. Add it only if a user needs another bind address.
- `TZ` is kept because siblings list it; Wizarr's use of it is UNVERIFIED.
- No `dependencies:` (none).

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config/data/database

cd /app/wizarr
export FLASK_SKIP_SCHEDULER=true
/app/wizarr/.venv/bin/flask db upgrade

exec /app/wizarr/.venv/bin/gunicorn \
  --config gunicorn.conf.py \
  --umask 007 \
  run:app
```

- Idempotent: `mkdir -p` and `flask db upgrade` (alembic) are safe on every start. Empty `/config` works because the database is created by the upgrade.
- No writes to `/app`. The venv is used directly (python-runtime rule: `/app/venv` is read-only; this plan uses `/app/wizarr/.venv` read-only as well).
- `exec` makes gunicorn PID 1 for signal handling.
- The upstream `PUID`/`PGID` remap is not reproduced: ContainerForge runs as `apps`. Upstream `su-exec` and `adduser` are not used.
- `--umask 007` is kept from upstream gunicorn CMD. The bazarr sibling uses `UMASK=002` as a setting; decide whether to expose `UMASK` (not done here).
- Database path: `flask db upgrade` writes where the app's config says. The `/config/data/database` directory must match that path (section 9).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '5690'
http:
- port: '5690'
  path: /health
filePaths:
- /app/wizarr/.venv/bin/gunicorn
- /app/wizarr/app
- /usr/share/licenses/wizarr/LICENSE
```

- Every settings port has a probe: `5690` tcp and `5690` http on `/health`. `/health` is the upstream HEALTHCHECK path (verified in the Dockerfile); the status code it returns with no database has NOT been checked (UNVERIFIED). If `/health` fails on an empty `/config`, that is a real defect to fix, not an assertion to weaken.
- `timeoutSeconds: 120` covers the `flask db upgrade` step before gunicorn listens. Confirm against a Python sibling's value before finalising.
- The test runs with no env vars, so the default database path and no-PUID path are exercised with an empty `/config`.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/data/database` (SQLite database, upstream volume) | `/config/data/database`, created in `start.sh`. The app must be pointed at it: the database path setting in the app is UNVERIFIED (not read from `app/config.py` in this run). Either an app env var for the DB URL or a symlink `/app/wizarr/data -> /config/data` if the app uses a relative path. Resolve before the first build. |
| `/.cache` (uv, npm caches) | `UV_CACHE_DIR=/tmp/uv-cache`, `XDG_CACHE_HOME=/tmp` (build and run) |
| `/opt/default_wizard_steps` | `/app/wizarr/default_wizard_steps` (inside `/app`, read-only at runtime). If the app copies these into `/config` on first run, that behaviour is kept; if it writes into `/opt`, the path must be remapped (UNVERIFIED). |
| `/run/nginx`, `/var/run` (chart emptyDirs) | Not needed: the upstream image runs gunicorn directly with no nginx. Draft's extra-persistence entries are chart-only. |
| Python bytecode | `UV_COMPILE_BYTECODE=1` at build time only; runtime bytecode writes into `/app` are a risk on read-only rootfs (UNVERIFIED whether the app writes `__pycache__` at runtime; set `PYTHONDONTWRITEBYTECODE=1` at runtime to avoid writes). |

Draft expectations reconciled:
- Chart runs as UID 0 and `readOnlyRootFilesystem: false`. This plan runs as `apps` and must work with `--read-only --tmpfs /tmp`.
- Draft said the sqlite database goes under `/config`, the chart uses `/data/database`. The plan puts it under `/config/data/database` (ContainerForge convention). Migration note: a user moving from the chart copies `/data/database` into `/config/data/database`.
- Not privileged, no hostNetwork, no extra persistence beyond the database.

## 10. Risks, caveats and open questions

- **Database path (open, blocks step 9):** the exact config key or hard-coded path for the SQLite file was not read. Confirm from `app/` (look for `SQLALCHEMY_DATABASE_URI` or a `data/database` path) before the first build.
- **Python version (open):** upstream uses Python 3.13 via uv. The base here is Python 3.15.2. Confirm `requires-python` in `pyproject.toml` and that the locked dependencies install on 3.15 (`uv sync --frozen` will fail otherwise). Fallback: none in the ContainerForge base list other than the 3.15 base; open a question to the user rather than pinning a different interpreter.
- **Root entrypoint removed:** the upstream entrypoint runs as root and remaps users. The plan removes it. Verify the app does not require root for anything (for example `/opt/default_wizard_steps`).
- **Default wizard steps (open):** the app's use of `/opt/default_wizard_steps` (copy-on-first-run versus read-only reference) is UNVERIFIED. The plan's path change must match the app's read path.
- **`DISABLE_BUILTIN_AUTH` default (UNVERIFIED):** the docs show `false` as an example only.
- **Migrations:** `flask db upgrade` runs on every start. Migrations with side effects (the upstream release notes mention a `hide_users_from_login` migration) must be idempotent; the plan does not change this.
- **Build time:** npm and uv dependencies are installed in the build stage on both arches; the upstream builder does the same work.
- **Draft's inferred caveat:** uv caches in `/tmp` mean the first start after a restart may re-download packages. The plan does not call uv at runtime (the venv is used directly), so this caveat does not apply; it is removed.
- **Media-server and invitation setup:** done in the UI on first run (manual step, draft caveat). Not covered by the container test.
- **arm64:** not validated; the Python wheels for `--frozen` locks on arm64 are UNVERIFIED.
- No blockers known: not musl-only (upstream alpine is not reused), no GPU, no privileged needs, no dependency containers.

## 11. Build and test steps

```sh
cd apps/wizarr
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name wizarr-probe --read-only --tmpfs /tmp \
  -v wizarr-probe-config:/config wizarr:2026.10.1
docker logs -f wizarr-probe
forgetool containers test --image wizarr:2026.10.1 --config ./apps/wizarr/container-test.yaml
docker rm -f wizarr-probe; docker volume rm wizarr-probe-config
```

- Readiness signals: the `flask db upgrade` output (alembic "Running upgrade" lines or "no upgrades" line), then the gunicorn line `Gunicorn master ... ready on 0.0.0.0:5690` (the app's `when_ready` hook prints this in `gunicorn.conf.py`; the test pass is `GET /health` returning 200).
- Confirm `/config/data/database/` contains the database file after start, and a restart with the same volume keeps it.
- Probe from outside the container with `-p 5690:5690` to prove it is not bound to localhost.

## 12. PR checklist

- Branch `feat/add-wizarr`, commit and PR title `feat(wizarr): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections, check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: signed Contributor License Agreement required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; `license/cla` shows the status.
- Say what was not tested: arm64, the database path resolution, the default wizard steps path, and the `/health` status with an empty database, unless they were actually run.
- `docker buildx bake --print` passes; bake `VERSION` equals the Dockerfile `ARG VERSION`; no assertion weakened.
