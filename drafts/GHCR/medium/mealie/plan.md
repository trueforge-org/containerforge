# mealie — implementation plan
> Source: ./draft.md · Target: apps/mealie/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Latest stable `v3.31.0` (published 2026-11-13). The TrueCharts chart pins `ghcr.io/mealie-recipes/mealie:v3.31.0`, which matches. Source: https://api.github.com/repos/mealie-recipes/mealie/releases/latest |
| Draft vs verified | Draft: "FastAPI app with the wheel installed on the python base". Confirmed: upstream `docker/Dockerfile` (tag `v3.31.0`) builds the frontend with node + pnpm, builds the wheel with `uv build`, exports hashed requirements with `uv export`, and installs them into a venv at `/opt/mealie`. Runtime entrypoint is `exec mealie` (from `docker/entry.sh`). |
| Python version (draft did not state it) | `requires-python = ">=3.14,<3.15"` in `pyproject.toml` (https://raw.githubusercontent.com/mealie-recipes/mealie/v3.31.0/pyproject.toml). The brief's default `python:3.15.2` base is NOT compatible. Use `python:3.14.8` (see section 3). |
| Renovate | `datasource=github-releases depName=mealie-recipes/mealie versioning=semver` (source tag). Nested renovate for `uv` (`datasource=pypi depName=uv`, upstream pins `uv==0.13.7`) and `pnpm` (`datasource=npm depName=pnpm`, upstream pins `pnpm@12.18.0`). |
| License | AGPL-3.0 (GitHub API `spdx_id` = `AGPL-3.0`): https://api.github.com/repos/mealie-recipes/mealie/license |
| Source URL | https://github.com/mealie-recipes/mealie |
| Download | Source archive `https://github.com/mealie-recipes/mealie/archive/refs/tags/v${VERSION}.tar.gz`. No release assets on `v3.31.0` (GitHub API assets list empty). PyPI `mealie` returns Not Found, so there is no ready-made wheel. Source build on both amd64 and arm64. |
| Checksum source | None published as a release asset. Upstream verifies its own Python dependencies with `pip --require-hashes` against `uv.lock` (export). The source tarball is content-addressed by tag only: UNVERIFIED that the tag is immutable. |
| Upstream Dockerfile reviewed | `docker/Dockerfile`, `docker/entry.sh`, `docker/healthcheck.sh` at `v3.31.0`. `docker/setup_nltk_data.sh` referenced but not fetched (UNVERIFIED content; see section 10). |
| Port | `APP_PORT=9000` (Dockerfile `ENV APP_PORT=9000`), `HOST=0.0.0.0`. Healthcheck uses `API_PORT` (default 9000). |
| Env vars (confirmed on fetched pages) | `PUID`, `PGID` (entry.sh, upstream-only user remap: not used here), `APP_PORT`, `API_PORT`, `HOST`, `TLS_CERTIFICATE_PATH`, `TLS_PRIVATE_KEY_PATH`, `PRODUCTION`, `TESTING`, `NLTK_DATA=/nltk_data/`, `MEALIE_HOME=/app`, `VENV_PATH=/opt/mealie`. Settings (`mealie/core/settings/settings.py`): `BASE_URL` (default `http://localhost:8080`), `DB_ENGINE` (default `sqlite`, options `sqlite`, `postgres`). Postgres names read by entry.sh: `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_SERVER`, `POSTGRES_PORT`, `POSTGRES_DB`, `POSTGRES_URL_OVERRIDE`, each also as `*_FILE`. SMTP, LDAP and OIDC names exist in entry.sh with `_FILE` support. |
| Data path | Upstream `VOLUME $MEALIE_HOME/data/` = `/app/data`. `mealie/core/config/config.py` writes `.secret` and `.session_secret` into `data_dir` and calls `data_dir.mkdir(parents=True, exist_ok=True)`. The exact default `data_dir` value in settings is UNVERIFIED; the volume path `/app/data` is the best evidence. |
| Process | `entry.sh`: `cd /app`, source `/opt/mealie/bin/activate`, `exec mealie`. Upstream runs as root and uses `gosu` to switch to `PUID`; not used here. |

## 2. Target layout

- `apps/mealie/Dockerfile`
- `apps/mealie/docker-bake.hcl`
- `apps/mealie/settings.yaml`
- `apps/mealie/container-test.yaml`
- `apps/mealie/start.sh` (replaces upstream `docker/entry.sh`; upstream `healthcheck.sh` is not needed: `container-test.yaml` probes the port)

No `defaults/`, `etc/`, `health/` needed (mealie creates its data on first start). `docker/setup_nltk_data.sh` is run during the build from the source tree, so it does not ship in the app folder unless it is copied: copy it into `apps/mealie/scripts/` only if the build cannot run it from `/tmp/src`. No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/python:3.14.8@sha256:f099b700b824b7760cb846418f84a2c14c2f04992320506ab3ca5b79d3ac1232` for all stages (build and final). Reason: mealie `requires-python >=3.14,<3.15`, so the default `python:3.15.2` base cannot run it. This digest is the one already used by eight sibling apps in this repo (for example `apps/changedetection` uses the python-node variant of 3.14.8), so it is a repo-proven base, not a new one.

Frontend build: upstream uses `node:26`. Use the `ghcr.io/trueforge-org/python-node:3.14.8@sha256:feb6e44439ea272f47b46a1511960f58af5df8056811c83973e2edec9b18afca` base for a dedicated `frontend` build stage only (it already has node), then copy `dist` out. The final stage stays on the python 3.14.8 base. Node version in that base is UNVERIFIED (section 10). Closest siblings: `apps/changedetection` (python 3.14.8 + venv), `apps/bazarr` (python, venv), `apps/postgresql` (optional DB).

## 4. Dockerfile

Multi-stage, mirroring upstream but on ContainerForge bases.

1. `FROM ghcr.io/trueforge-org/python-node:3.14.8@sha256:feb6e4... AS frontend` (node stage). `ARG VERSION`, `ENV npm_config_cache=/tmp/npm`. `npm install --global pnpm@12.18.0` (`# renovate: datasource=npm depName=pnpm`). Fetch source: `curl -fsSL https://github.com/mealie-recipes/mealie/archive/refs/tags/v${VERSION}.tar.gz | tar xz -C /tmp/src --strip-components=1`. Then `cd /tmp/src/frontend && pnpm clean-install && pnpm generate`. Copy `mealie/repos/seed/resources/units/locales` into the same relative path as upstream (the lang files import it).
2. `FROM ghcr.io/trueforge-org/python:3.14.8@... AS build` (python). `ARG VERSION`, `USER root`. `apt-get install -y --no-install-recommends build-essential libpq-dev libwebp-dev libsasl2-dev libldap2-dev libssl-dev` (upstream venv-builder list, minus `ffmpeg`, `gnupg*`, which belong to the final stage; `curl` is in the base or add it). Check each against the base before adding (dockerfile rule).
3. `ENV PIP_CACHE_DIR=/tmp/pip UV_CACHE_DIR=/tmp/uv UV_FROZEN=1 PIP_DISABLE_PIP_VERSION_CHECK=on`. `UV_FROZEN=1` installs from the committed `uv.lock` and never re-resolves (upstream comment).
4. Install build tools: `pip install uv==0.13.7` (`# renovate: datasource=pypi depName=uv`).
5. Source is at `/tmp/src`. Copy `frontend/dist` into `/tmp/src/mealie/frontend`, then `uv build --out-dir /tmp/dist`.
6. `uv export --no-dev --no-editable --no-emit-project --extra pgsql --format requirements-txt --output-file /tmp/dist/dependencies.txt`; build `requirements.txt` the way upstream does (hashed mealie wheel line appended). Keep `--extra pgsql` so PostgreSQL works as the optional dependency.
7. Create the venv in the build stage at `/opt/mealie` (upstream path, outside `/app` so the python base's `/app/venv` is not touched): `python3 -m venv --upgrade-deps /opt/mealie`. `ENV VENV_PATH=/opt/mealie PATH="/opt/mealie/bin:$PATH"`. `pip install --require-hashes -r /tmp/dist/dependencies.txt`, then `pip install --require-hashes -r /tmp/dist/requirements.txt --find-links /tmp/dist`.
8. NLTK data: `ENV NLTK_DATA=/nltk_data/`. Run `docker/setup_nltk_data.sh` in the build stage (it writes `/nltk_data`, read at runtime). Make `/nltk_data` `0755` and owned by root. Upstream `setup_nltk_data.sh` is UNVERIFIED (not fetched): read it before running it.
9. Final stage: `FROM python:3.14.8@... AS final`. `USER root`. `apt-get install -y --no-install-recommends ffmpeg libldap-common libldap2` plus `curl` and `libpq5` only if the base lacks them. Do not install `gosu` or `iproute2`: `gosu` only serves upstream's root-to-PUID switch, and nothing here needs `iproute2`. Clean `/var/lib/apt/lists/*`.
10. `COPY --from=build --chmod=0755 /opt/mealie /opt/mealie` and `COPY --from=build --chmod=0755 /nltk_data /nltk_data`.
11. `mkdir -p /app` is in the base; do not write into `/app` at build beyond the symlink below. `RUN ln -s /config/data /app/data` so mealie's `data_dir` (`/app/data`) resolves to the writable volume. The symlink is created at build time; `/config/data` is created by `start.sh`.
12. License: `COPY --from=build /tmp/src/LICENSE /usr/share/licenses/mealie/LICENSE`.
13. Tail:

```dockerfile
ENV PRODUCTION=true \
    TESTING=false \
    APP_PORT=9000 \
    HOST=0.0.0.0 \
    MEALIE_HOME=/app \
    VENV_PATH=/opt/mealie \
    NLTK_DATA=/nltk_data/ \
    PATH="/opt/mealie/bin:${PATH}" \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1
USER apps
COPY --chmod=0755 . /
EXPOSE 9000
VOLUME /config
WORKDIR /app
```

No `ENTRYPOINT` override: the `ubuntu` base entrypoint (`tini` then `/entrypoint.sh`) execs `/start.sh`.

`ARG COMMIT` into `GIT_COMMIT_HASH` only if the version string needs it (upstream has it; optional). `VOLUME /config` replaces upstream `/app/data/`; the symlink in step 11 keeps mealie's own path working.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "mealie"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=mealie-recipes/mealie versioning=semver
  default = "3.31.0"
}

variable "LICENSE" {
  default = "AGPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/mealie-recipes/mealie"
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

Validate with `docker buildx bake --print` from `apps/mealie/`. Note the tag is `3.31.0`; the source tarball fetch uses `v${VERSION}` (Dockerfile), matching the chart's `v3.31.0`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/mealie-recipes/mealie"
ports:
  - port: 9000
    protocol: tcp
    required: true
env:
  - name: APP_PORT
    default: "9000"
    required: false
  - name: HOST
    default: "0.0.0.0"
    required: false
  - name: BASE_URL
    default: "http://localhost:8080"
    required: false
  - name: DB_ENGINE
    default: "sqlite"
    required: false
  - name: POSTGRES_SERVER
    default: ""
    required: false
  - name: POSTGRES_PORT
    default: "5432"
    required: false
  - name: POSTGRES_DB
    default: "mealie"
    required: false
  - name: POSTGRES_USER
    default: "mealie"
    required: false
  - name: POSTGRES_PASSWORD
    default: ""
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
opt_dependencies:
  - postgresql
```

`BASE_URL` default must match what mealie reads (`http://localhost:8080` per settings.py). Postgres defaults are UNVERIFIED (upstream defaults not fetched): leave `POSTGRES_*` empty and only list names the app reads. `TZ` only if the base honours it. `opt_dependencies: postgresql` (optional DB; `apps/postgresql` exists). The `_FILE` variants are supported by upstream entry.sh; list them only if `start.sh` passes them through.

## 7. start.sh

```bash
#!/bin/sh
set -eu

# Mealie keeps its data (SQLite, .secret, .session_secret) in /app/data, which is a
# symlink to /config/data (created at build time). Create the target on every start.
mkdir -p /config/data

cd /app
. /opt/mealie/bin/activate
export HOST="${HOST:-0.0.0.0}"
export APP_PORT="${APP_PORT:-9000}"
exec mealie
```

- Idempotent: `mkdir -p` only; empty `/config` works; existing data is never overwritten.
- No writes to `/app`: `/app/data` is a symlink created at build time, and `/app` is read-only at runtime. Any mealie write goes through the symlink into `/config/data`.
- `load_secrets` from upstream `entry.sh` (the `*_FILE` variables for POSTGRES_*, SMTP_*, LDAP_*, OIDC_*) is NOT copied in this first version: add it only if the PostgreSQL path needs it, and then keep secrets out of files and the process list (the rule for `*_FILE` is to read them into env, not to log them). Note this in section 10.
- Upstream `change_user` / `gosu` are removed: ContainerForge runs `USER apps`, so PUID/PGID are ignored (document this).
- Caches: pip, uv and npm caches are build-only under `/tmp`; mealie itself uses `/config/data` for state. Set `TMPDIR`/cache envs to `/tmp` if mealie writes temp files (verify in the first run).
- Process model: `exec mealie`, so the process is PID 1 handoff.
- Bind all interfaces: `HOST=0.0.0.0` (check the log after start shows 0.0.0.0:9000).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 300
tcp:
- port: '9000'
http:
- port: '9000'
  path: /api/app/about
filePaths:
- /opt/mealie/bin/python
- /opt/mealie/bin/mealie
- /nltk_data
- /app/data
- /start.sh
- /usr/share/licenses/mealie/LICENSE
```

- `/api/app/about` is the upstream healthcheck path (`docker/healthcheck.sh`), answered with JSON; it works without DB setup.
- `timeoutSeconds: 300`: the first start builds the SQLite DB and runs migrations. Compare with sibling python apps and tune after the first run; never lower it to hide a slow start.
- `filePaths` checks the venv entry points and the NLTK directory (build-time artifacts that runtime needs).
- No env-dependent code paths here: mealie starts with defaults (SQLite). The Postgres path needs a database and is not exercised by this test; say so in the PR.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | ContainerForge remap |
| --- | --- |
| `/app/data` (volume; `.secret`, `.session_secret`, SQLite DB, uploads, logs) | symlink `/app/data -> /config/data` created at build; `start.sh` creates `/config/data` |
| `PUID`/`PGID` user remap with `usermod`/`groupmod` and `chown -R /app` (entry.sh, root) | removed. Image runs as `USER apps`, `/app` stays read-only |
| `gosu` to switch user | removed (not needed for `USER apps`) |
| NLTK data `/nltk_data` | built into the image at build, read-only at runtime |
| `/opt/mealie` venv | built at build time, read-only at runtime; no `pip install` at runtime |
| pip/uv/pnpm caches | `/tmp` at build only (`PIP_CACHE_DIR`, `UV_CACHE_DIR`, `npm_config_cache`) |
| `frontend` build tree | built in the `frontend` stage; only `mealie/frontend` (dist) is copied into the wheel |

Read-only rootfs check: run with `--read-only --tmpfs /tmp`. Any mealie write outside `/config` or `/tmp` fails with `EROFS` and shows in the log.

## 10. Risks, caveats and open questions

- Python version: `requires-python >=3.14,<3.15` forces `3.14.8`. The draft and the brief assume the 3.15.2 base. Record this in the PR and in DOWNSTREAM if mealie is later re-pinned to 3.15 (not required now).
- Node in the `python-node:3.14.8` base is UNVERIFIED. The frontend needs node 26 upstream; if the base node is older, the frontend build fails. Confirm with `node -v` first (section 11). Do not install another node into the final image.
- `docker/setup_nltk_data.sh` (NLTK downloads at build time) was not fetched. Read it before running it: the build needs internet access, and a runtime download would break the read-only rule. If it downloads at runtime, move it to build and say so in the PR.
- The draft says "first start downloads NLTK data": upstream installs it at build (Dockerfile line `RUN $MEALIE_HOME/setup_nltk_data.sh`). The draft caveat is therefore likely wrong; verify on first start.
- `DB_ENGINE` default is `sqlite`. PostgreSQL is optional; the Postgres env names are confirmed in entry.sh, and the connection is not exercised by the test. Say so.
- Native wheels: `libwebp-dev`, `libpq-dev`, `libldap2-dev`, `libsasl2-dev` are needed when a wheel is not published for the arch. arm64 wheel availability for the full `--require-hashes` set is UNVERIFIED; the build on arm64 is the test.
- Upstream `PUID`/`PGID` are ignored by design. A user who sets them expects a different UID; document this.
- Upstream `BASE_URL` default is `http://localhost:8080`, not the port the container listens on. Users must set `BASE_URL` for links and OIDC; say so in the settings description.
- Checksums: no published asset checksum. Hashes come from `uv.lock` export (`--require-hashes`) for Python deps; the source tarball is pinned by tag only.
- Blockers: none confirmed. Main risks: node version, arm64 native wheels, setup_nltk_data content.

## 11. Build and test steps

Run from `/workspaces/containers/apps/mealie/` (copy the files there; the draft folder stays unchanged):

1. `docker buildx bake --print` (must exit 0).
2. Check base facts: `docker run --rm ghcr.io/trueforge-org/python-node:3.14.8@sha256:feb6e4... sh -c 'node -v; python3 -V'`, and `docker run --rm ghcr.io/trueforge-org/python:3.14.8@sha256:f099b7... python3 -V` (must print 3.14.x).
3. `docker buildx bake --set image-local.platform=linux/amd64 image-local` (frontend build plus uv build; expect 10-20 minutes).
4. Probe: `docker run --rm -d --name mealie-probe --read-only --tmpfs /tmp -v mealie-probe-config:/config mealie:3.31.0`, then `docker logs -f mealie-probe`.
5. Readiness signal: uvicorn/mealie log line showing it serves on `0.0.0.0:9000` (or `Application startup complete`), process still running, no fatal errors or repeated tracebacks after the first minute. `curl -fsk http://127.0.0.1:9000/api/app/about` returns JSON from inside the container.
6. `forgetool containers test --image mealie:3.31.0 --config ./container-test.yaml`.
7. Cleanup: `docker rm -f mealie-probe; docker volume rm mealie-probe-config`.
8. If the probe fails on a write to `/app`, fix the path (symlink or `/config`), rebuild, and re-run from step 3.
9. Arm64 only after amd64 is green: `--set image-local.platform=linux/arm64`.

## 12. PR checklist

- Branch: `feat/add-mealie`. Commit: `feat(mealie): add new container`. PR title matches the commit.
- Notes: `🤖 This PR is AI generated.`
- Fill in `.github/PULL_REQUEST_TEMPLATE.md`, keeping sections and checkboxes; check only what applies. Do not check "Built container locally" unless steps 3 and 4 passed.
- Say what was not tested: arm64 build, PostgreSQL path, OIDC/LDAP/SMTP, PUID/PGID behavior (ignored by design), the NLTK script content if not reviewed.
- CLA: the user must sign at https://cla-assistant.io/trueforge-org/containerforge (`license/cla` check). Only the user can sign it.
- `VERSION` renovate annotation present; `docker buildx bake --print` passed; Python base 3.14.8 justified by `requires-python`.
- Container-test: tcp and http probes for port 9000.
