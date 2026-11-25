# spoolman — implementation plan
> Source: ./draft.md · Target: apps/spoolman/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `0.27.1`. Latest release `v0.27.1`, published 2026-10-31T14:12:51Z (`gh api repos/Donkie/Spoolman/releases/tags/v0.27.1`). pyproject `version = "0.27.1"` (https://raw.githubusercontent.com/Donkie/Spoolman/ff8efd517b76a4b2783f29c89e9b9fbcd8cd167b/pyproject.toml). Chart tag `0.27.1@sha256:1ebb4f6a62c2e72a07f18b07ebfdbd96322f5bc2eb72570af3088f68d7c393b1` (https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/spoolman/values.yaml). |
| Renovate | `// renovate: datasource=github-releases depName=Donkie/Spoolman versioning=semver` (tags are `v`-prefixed; the build uses `v${VERSION}`). |
| License | MIT (GitHub API `spdx MIT`; pyproject `license = "MIT"`). |
| Source URL | https://github.com/Donkie/Spoolman (docs https://donkie.github.io/Spoolman/) |
| Download | `https://github.com/Donkie/Spoolman/releases/download/v0.27.1/spoolman.zip`, 3383760 bytes. Architecture-independent (one zip). |
| Checksum source | GitHub release asset digest, `sha256:77ba10fa505a42cef606eabec1a7c9a5b93c51dc40067456a29a7d9480ef27d6` (`gh api repos/Donkie/Spoolman/releases/tags/v0.27.1`, field `digest`). Verify with `echo "77ba10fa505a42cef606eabec1a7c9a5b93c51dc40067456a29a7d9480ef27d6  spoolman.zip" \| sha256sum -c -`. |
| Zip contents | UNVERIFIED: not downloaded in this run. The first implementation step is `unzip -l spoolman.zip` to confirm it holds the Python package, `pyproject.toml`, `uv.lock`, and the built `client/dist` and `client_v2/build`. If it does not, use the source tarball `https://github.com/Donkie/Spoolman/archive/refs/tags/v0.27.1.tar.gz` and build the frontends (section 4). |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/Donkie/Spoolman/ff8efd517b76a4b2783f29c89e9b9fbcd8cd167b/Dockerfile: builder `FROM python:3.14-slim-bookworm`, apt `g++ libpq-dev libffi-dev patchelf`, `pip install uv`, `uv sync --locked --no-install-project`, copies `spoolman/`, `migrations/`, `alembic.ini`, `pyproject.toml`, `uv.lock`, then `uv sync --locked`. Runner `FROM python:3.14-slim-bookworm`, apt `gosu`, `useradd -u 1000 -U app`, copies built app to `/home/app/spoolman`, copies `client/dist` and `client_v2/build` from the build context, `ENV PATH=/home/app/spoolman/.venv/bin:...`, `EXPOSE 8000`, `ENTRYPOINT /home/app/spoolman/entrypoint.sh`, no `CMD`. |
| Python constraint | `requires-python = ">=3.10,<3.15"` (pyproject). ContainerForge's current `python` base is 3.15.2, which is outside this range. See section 3. |
| Upstream entrypoint reviewed | https://raw.githubusercontent.com/Donkie/Spoolman/ff8efd517b76a4b2783f29c89e9b9fbcd8cd167b/entrypoint.sh: starts as root, `PUID`/`PGID` (default 1000), `usermod`/`groupmod` on the `app` user, `exec gosu app "$0" "$@"`, then `exec uvicorn spoolman.main:app --host $SPOOLMAN_HOST --port $SPOOLMAN_PORT "$@"`. Rejects `PUID=0`. Ignores a Kubernetes service-link value for `SPOOLMAN_PORT`. |
| Env vars (real) | From `spoolman/env.py` (https://raw.githubusercontent.com/Donkie/Spoolman/ff8efd517b76a4b2783f29c89e9b9fbcd8cd167b/spoolman/env.py) and entrypoint: `SPOOLMAN_HOST` (0.0.0.0), `SPOOLMAN_PORT` (8000), `SPOOLMAN_DIR_DATA` (default `platformdirs` user data dir), `SPOOLMAN_DIR_LOGS` (default = data dir), `SPOOLMAN_DIR_BACKUPS` (default `<data>/backups`), `SPOOLMAN_DB_TYPE` (`sqlite`, `mysql`, `postgres`, `cockroachdb`), `SPOOLMAN_DB_HOST`, `SPOOLMAN_DB_PORT`, `SPOOLMAN_DB_NAME`, `SPOOLMAN_DB_QUERY`, `SPOOLMAN_DB_USERNAME`, `SPOOLMAN_DB_PASSWORD`, `SPOOLMAN_DB_PASSWORD_FILE`, `SPOOLMAN_LOGGING_LEVEL` (INFO), `SPOOLMAN_DEBUG_MODE` (FALSE), `SPOOLMAN_CORS_ORIGIN`, `SPOOLMAN_ALLOWED_HOSTS`, `SPOOLMAN_AUTOMATIC_BACKUP` (TRUE), `SPOOLMAN_UPDATE_CHECK` (TRUE). Chart values also name `EXTERNAL_DB_URL`, `EXTERNAL_DB_SYNC_INTERVAL`, `SPOOLMAN_METRICS_ENABLED`, `SPOOLMAN_BASE_PATH` (chart comments, https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/spoolman/values.yaml; the code-level defaults for these were not read in this run, so list them only after checking). `PUID`/`PGID` are read by the upstream entrypoint only. |
| Ports | 8000/http (`EXPOSE 8000`; chart service port 8000). |
| Chart env | `SPOOLMAN_DIR_DATA=/data`, `SPOOLMAN_DIR_LOGS=/logs`, `SPOOLMAN_DB_TYPE=postgres` with credentials from the chart's postgresql secret, `SPOOLMAN_DEBUG_MODE=true`. Chart persistence: `/data`, `/logs`. |
| Chart security | `readOnlyRootFilesystem: false`, `runAsUser: 0`, `runAsGroup: 0`, no privileged, no extra capabilities (draft and values.yaml). |
| Dependencies | PostgreSQL is optional (chart enables the postgresql dependency). `apps/postgresql` exists (draft: ✅). SQLite is the default and needs no service. |

## 2. Target layout

- `apps/spoolman/Dockerfile`
- `apps/spoolman/docker-bake.hcl`
- `apps/spoolman/settings.yaml`
- `apps/spoolman/container-test.yaml`
- `apps/spoolman/start.sh` (replaces the upstream `entrypoint.sh`; the upstream file is not copied because it needs root and `gosu`)
- No `defaults/`, `etc/`, `root/`, or `DOWNSTREAM_CHANGES.md` (not a FROM base).

## 3. Base image

Use `ghcr.io/trueforge-org/python:3.14.8@sha256:f099b700b824b7760cb846418f84a2c14c2f04992320506ab3ca5b79d3ac1232`, not the current `python:3.15.2`. Reason: `requires-python` is `<3.15`, the same constraint the repo already records for `apps/beets` ("stay on python 3.14 until beets supports 3.15") and `apps/changedetection`. The 3.14.8 base is used by eight existing apps (`beets`, `deluge`, `faster-whisper`, `home-assistant`, `lazylibrarian`, `medusa`, `piper`, `sabnzbd`). Closest sibling: `apps/beets` (python 3.14 pinned base, comment, `USER root` install block). The ubuntu base in the table above is the parent of the python image; do not use it directly.

UNVERIFIED: whether `ghcr.io/trueforge-org/python:3.14.8` ships `/app/venv` (the python-runtime rule assumes it does for the 3.15.2 base). Check with `docker run --rm <base> ls -d /app/venv` before writing the Dockerfile.

## 4. Dockerfile

1. `ARG VERSION=0.27.1`, `ARG TARGETARCH`, `USER root`. `VERSION` must equal the bake default (section 5).
2. Download and verify the zip into `/tmp`:

```sh
curl -fL -o /tmp/spoolman.zip "https://github.com/Donkie/Spoolman/releases/download/v${VERSION}/spoolman.zip"
echo "77ba10fa505a42cef606eabec1a7c9a5b93c51dc40067456a29a7d9480ef27d6  /tmp/spoolman.zip" | sha256sum -c -
```

The checksum is the one for `0.27.1`. Bumps must update it (the `digest` from the release API), so store it as an `ARG SPOOLMAN_SHA256` next to `VERSION` and say so in `docker-bake.hcl`. Renovate cannot update it by itself; add a second `renovate` annotation only if the repo already has a pattern for it (UNVERIFIED: none found in this run). Otherwise document the manual step in the PR.

3. Extract to `/app/spoolman` (read-only at runtime): `unzip -q /tmp/spoolman.zip -d /app/spoolman && rm /tmp/spoolman.zip`. Confirm the layout (section 1, zip contents). Install unzip only if the base lacks it; check first.
4. Install dependencies with `uv`, locked, into the base venv if it exists (section 3), otherwise into `/app/spoolman/.venv`:

```sh
pip install --no-cache-dir uv
cd /app/spoolman
UV_PYTHON_DOWNLOADS=0 UV_LINK_MODE=copy UV_NO_DEV=1 UV_PROJECT_ENVIRONMENT=/app/venv \
  uv sync --locked --no-install-project
UV_PYTHON_DOWNLOADS=0 UV_LINK_MODE=copy UV_NO_DEV=1 UV_PROJECT_ENVIRONMENT=/app/venv \
  uv sync --locked
uv cache clean
```

Use `--mount=type=cache,target=/tmp/uv-cache` with `UV_CACHE_DIR=/tmp/uv-cache` so the uv cache stays in `/tmp` and out of the image. Wheels cover `psycopg2-binary`, `asyncpg`, `uvloop`, `httptools`, `greenlet`, and `cbor2` on amd64 and arm64 (UNVERIFIED for `cbor2` on arm64; if it builds from source, the base needs a C toolchain, which the upstream builder got from apt `g++ libpq-dev libffi-dev`). armv7 is not a ContainerForge target and is skipped.

5. Do not copy the upstream `entrypoint.sh`. Write `start.sh` (section 7) and use `COPY --chmod=0755 . /` for it.
6. Build-time metadata (upstream writes `build.txt`): skip unless `GIT_COMMIT`/`BUILD_DATE` are wanted. Optional: `ARG GIT_COMMIT=unknown`, `ENV`, no file.
7. Frontend assets: the zip path (section 1) must contain `client/dist` and `client_v2/build`. If the zip lacks them, the fallback is the source tarball and a Node build stage (UNVERIFIED: frontend build steps, not read in this run).
8. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

ENV PATH="/app/venv/bin:${PATH}" SPOOLMAN_HOST=0.0.0.0 SPOOLMAN_PORT=8000
EXPOSE 8000
VOLUME /config
WORKDIR /app/spoolman
```

`USER apps` at the end is required. The `apps` user is the base's runtime user (UID is not hard-coded here; the upstream `app` user is UID 1000, not used).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" { default = "spoolman" }

variable "VERSION" {
  // renovate: datasource=github-releases depName=Donkie/Spoolman versioning=semver
  default = "0.27.1"
}

variable "LICENSE" { default = "MIT" }
variable "SOURCE" { default = "https://github.com/Donkie/Spoolman" }

group "default" { targets = ["image-local"] }
```

Then the four standard targets from `apps/adguardhome-sync/docker-bake.hcl`. Validate with `docker buildx bake --print` in `apps/spoolman`. The Dockerfile `ARG VERSION` must equal `0.27.1`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/Donkie/Spoolman"
ports:
  - port: 8000
    protocol: tcp
    required: false
env:
  - name: SPOOLMAN_HOST
    default: "0.0.0.0"
    required: false
  - name: SPOOLMAN_PORT
    default: "8000"
    required: false
  - name: SPOOLMAN_DB_TYPE
    default: "sqlite"
    required: false
  - name: SPOOLMAN_DB_HOST
    default: ""
    required: false
  - name: SPOOLMAN_DB_PORT
    default: "5432"
    required: false
  - name: SPOOLMAN_DB_NAME
    default: ""
    required: false
  - name: SPOOLMAN_DB_USERNAME
    default: ""
    required: false
  - name: SPOOLMAN_DB_PASSWORD
    default: ""
    required: false
  - name: SPOOLMAN_LOGGING_LEVEL
    default: "INFO"
    required: false
  - name: SPOOLMAN_DEBUG_MODE
    default: "FALSE"
    required: false
  - name: SPOOLMAN_AUTOMATIC_BACKUP
    default: "TRUE"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
opt_dependencies:
  - postgresql
```

- `SPOOLMAN_DEBUG_MODE` defaults to `FALSE`. The chart sets it `true`, which env.py documents as a security risk (accepts requests from any host). Do not copy the chart default.
- `SPOOLMAN_UPDATE_CHECK` (default TRUE, contacts GitHub) is left at the upstream default. Decide and document (UNVERIFIED what the check calls).
- The `SPOOLMAN_DB_*` variables are listed because the `postgres` option is supported. `SPOOLMAN_DB_PASSWORD_FILE` is read by env.py, so add it only if `start.sh` supports it.
- Dependencies key: the draft marks PostgreSQL as optional. Use `opt_dependencies` (the protocol's term) and check that the schema accepts it (`settings.yaml` rule: names must match the schema).

## 7. start.sh

```bash
#!/usr/bin/env bash
set -eu

# Persistent data, logs and backups under /config (empty /config is fine)
mkdir -p /config/data /config/logs /config/backups

# SQLite cache directory is under the data dir; keep the real cache in /tmp
mkdir -p /tmp/spoolman/cache
if [ ! -e /config/data/cache ]; then ln -s /tmp/spoolman/cache /config/data/cache; fi

export SPOOLMAN_DIR_DATA="${SPOOLMAN_DIR_DATA:-/config/data}"
export SPOOLMAN_DIR_LOGS="${SPOOLMAN_DIR_LOGS:-/config/logs}"
export SPOOLMAN_DIR_BACKUPS="${SPOOLMAN_DIR_BACKUPS:-/config/backups}"

# Kubernetes sets SPOOLMAN_PORT=tcp://<ip>:<port> when a Service named spoolman exists.
# Ignore it, as the upstream entrypoint does.
case "${SPOOLMAN_PORT:-8000}" in
    *://*) echo "Warning: ignoring SPOOLMAN_PORT service link, using 8000" >&2; SPOOLMAN_PORT=8000 ;;
esac

cd /app/spoolman
exec /app/venv/bin/uvicorn spoolman.main:app --host "${SPOOLMAN_HOST:-0.0.0.0}" --port "${SPOOLMAN_PORT:-8000}"
```

- Idempotent: directories are created only when missing, nothing existing is overwritten.
- Nothing is written under `/app`. Spoolman's `get_cache_dir()` is `data_dir / "cache"`, so the symlink sends cache writes to `/tmp` (repo rule: caches in `/tmp`). The symlink is only created when no `cache` entry exists, so a restart does not replace it.
- `exec` makes uvicorn PID 1 (signal handling).
- Upstream `PUID`/`PGID` and `gosu` are dropped: the container runs as `apps` (non-root, USER apps). Document in the PR that `PUID`/`PGID` are not supported.
- Draft caveat "upstream root entrypoint needs a path change to run as non-root": the path change is the `/config` mapping above, plus removing the `gosu` branch.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '8000'
http:
- port: '8000'
  path: /
filePaths:
- /app/spoolman/spoolman/main.py
- /app/venv/bin/uvicorn
- /usr/share/licenses/spoolman/LICENSE
```

- Runs with no env vars: SQLite, default data dir under `/config`. That is the supported default path, so it is the one tested.
- The PostgreSQL path needs a real database. Under the protocol's narrow exception, only if all three criteria hold (hard dependency, cannot start without DB, not feasible in one container). Here the DB is optional, so the exception does not apply. Do not narrow the test. Test PostgreSQL by hand per section 11.
- `path: /` must return 200. UNVERIFIED: the root route of Spoolman serves the web UI with 200 when no DB is set. If not, use the documented API info route after checking it on the running image.
- `/usr/share/licenses/spoolman/LICENSE` is written by the Dockerfile (step 2 of section 4). Add the copy from the zip if the zip includes a `LICENSE` (UNVERIFIED).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path or privilege | Remap or decision |
| --- | --- |
| `SPOOLMAN_DIR_DATA=/data` (chart) and `~/.local/share/spoolman` (upstream image) | `/config/data` (default in start.sh). |
| `SPOOLMAN_DIR_LOGS=/logs` (chart PVC) | `/config/logs`. |
| `SPOOLMAN_DIR_BACKUPS` (default `<data>/backups`) | `/config/backups`. |
| Cache dir `<data>/cache` (hard-coded in `get_cache_dir`) | Symlink to `/tmp/spoolman/cache`, so no cache is written to `/config`. |
| Runs as root and drops to `app` with `gosu` (upstream) | Runs as `apps` from the start. `PUID`/`PGID` are not supported. |
| `/app` read-only at runtime | Application and venv are installed at build time only. |
| Chart `readOnlyRootFilesystem: false`, `runAsUser 0` | Image is compatible with `--read-only --tmpfs /tmp`. Chart values are not copied. |
| Chart `SPOOLMAN_DEBUG_MODE=true` | Default `FALSE` (section 6). |
| Chart persistence `/data`, `/logs` | Replaced by `/config`. Existing users must move `data/` and `logs/` into `/config/data` and `/config/logs`. |

## 10. Risks, caveats and open questions

- Python version: the newest ContainerForge python base (3.15.2) is outside the project's `requires-python`, so the 3.14.8 base is used. When upstream supports 3.15, move to the 3.15.2 base, the same as `beets` and `changedetection` will need.
- Zip contents and frontend assets are UNVERIFIED (section 1). The first build step must check them, because the Dockerfile copies `client/dist` and `client_v2/build` from the build context upstream.
- `SPOOLMAN_DB_PASSWORD` and the postgres path are not exercised by the default test.
- Migrations: Alembic runs on startup and writes to the database, not to the filesystem. A schema migration is a one-way upgrade. Users must back up before upgrading.
- The update check (`SPOOLMAN_UPDATE_CHECK`) contacts GitHub, which may be undesirable in an air-gapped setup. Document the variable.
- Chart's `SPOOLMAN_DB_TYPE=postgres` default in the chart is not the image default. Our default is SQLite (user choice documented in settings).
- Arm64: the zip is architecture-independent, and upstream publishes multi-arch images (Dockerfile has `TARGETARCH`), but the arm64 GHCR image was not fetched (UNVERIFIED).
- Untested: the full build, the read-only runtime, the migration path from an upstream `/data` volume, PostgreSQL, arm64.
- Blockers: none after the 3.14.8 base is used. Without that choice, the 3.15.2 base cannot install a compatible wheel set under `requires-python <3.15`.

## 11. Build and test steps

```sh
cd apps/spoolman
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name spoolman-probe --read-only --tmpfs /tmp \
  -v spoolman-probe-config:/config spoolman:0.27.1
docker logs -f spoolman-probe
forgetool containers test --image spoolman:0.27.1 --config ./apps/spoolman/container-test.yaml
docker rm -f spoolman-probe; docker volume rm spoolman-probe-config
```

- Readiness signal: uvicorn log lines `Started server process` and `Uvicorn running on http://0.0.0.0:8000`, with the process still running after the startup window. Check the migration log for SQLite (`alembic` upgrade lines).
- Confirm `/config/data` (SQLite file), `/config/logs` and `/config/backups` exist after the first start, and that a restart keeps them.
- PostgreSQL (manual, not in the test): run `postgres` service, set `SPOOLMAN_DB_TYPE=postgres` with host/name/user/password, confirm migration and API response.
- Probe `curl -fsS http://127.0.0.1:8000/` inside and from the host with `-p 8000:8000`.

## 12. PR checklist

- Branch `feat/add-spoolman`, commit `feat(spoolman): add new container`, PR title the same, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections, check only applicable boxes.
- Notes section contains `🤖 This PR is AI generated.`
- CLA: the PR needs a signed Contributor License Agreement (https://cla-assistant.io/trueforge-org/containerforge). Tell the user. Only the user can sign it, and the `license/cla` check shows the status.
- State the Python base choice (3.14.8, `requires-python <3.15`) and why in the PR.
- State that `PUID`/`PGID` are not supported and that the chart's `SPOOLMAN_DEBUG_MODE=true` is not copied.
- Untested to state honestly if not run: the full build, read-only runtime, the zip contents, PostgreSQL, arm64, migration from upstream volumes.
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION` and the zip checksum is updated with the version.
