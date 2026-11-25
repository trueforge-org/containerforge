# comet — implementation plan
> Source: ./draft.md · Target: apps/comet/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | v2.59.0 (GitHub release 2026-11-18, tag commit `a3b75ecbefc494747c30ab484ff86c07c61585f0`). Draft's Dockerfile blob is the same commit. Chart uses `ghcr.io/g0ldyy/comet:latest` (unpinned). |
| Renovate | `datasource=github-releases depName=g0ldyy/comet versioning=semver` (proposed) |
| License | GPL-3.0 (repo `license.spdx_id`) |
| Source | https://github.com/g0ldyy/comet |
| Download | Source tarball `https://github.com/g0ldyy/comet/archive/refs/tags/v2.59.0.tar.gz`. No release assets. |
| Checksum source | None published upstream. sha256 of the fetched tarball: `480258af7348ac3af29d8c5bba49bf04cbf1f89e7ba2db3a4dbab24299768c38` (our hash, re-check at build). |
| Upstream Dockerfile reviewed | `Dockerfile` at a3b75ec: builder on `python:3.13-slim-trixie` with uv from `ghcr.io/astral-sh/uv:0.11.32` and Rust from `rust:1.97.1-slim-trixie`; `uv sync --frozen --no-install-project` into `/app/.venv`; runtime on `python:3.13-slim-trixie` with `COPY comet ./comet`, `ENV PATH=/app/.venv/bin:$PATH` and jemalloc, `HEALTHCHECK python -m comet.healthcheck`, `ENTRYPOINT ["python","-m","comet.main"]`. No EXPOSE, no USER. |
| Python | `requires-python = ">=3.13"` (pyproject.toml, main branch; UNVERIFIED for the tag). Project `version = "0.1.0"` in pyproject. |
| Port and host | `FASTAPI_PORT=8000`, `FASTAPI_HOST=0.0.0.0` (.env-sample, main branch). `comet/main.py` binds these. Healthcheck targets `127.0.0.1:FASTAPI_PORT`. |
| Env vars | From `.env-sample` (main branch): `FASTAPI_HOST`, `FASTAPI_PORT`, `FASTAPI_WORKERS=1`, `USE_GUNICORN=True`, `GUNICORN_PRELOAD_APP=True`, `EXECUTOR_MAX_WORKERS=1`, `PUBLIC_BASE_URL`, `ADMIN_DASHBOARD_PASSWORD` (sample `CHANGE_ME`, random if unset per comment), `ADMIN_DASHBOARD_SESSION_TTL=86400`, `PUBLIC_METRICS_API=False`, `PROMETHEUS_ENABLED=False`, `PROMETHEUS_PATH=/metrics`, `PROMETHEUS_MULTIPROC_DIR=/tmp/comet-prometheus`, `CONFIGURE_PAGE_PASSWORD`, `CONFIGURE_PAGE_SESSION_TTL=86400`, `PUBLIC_API_TOKEN`, `PUBLIC_API_TOKEN_FILE=data/public_api_token.txt`, `DATABASE_TYPE=postgresql` (sample; code default UNVERIFIED), `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DB`, `DATABASE_URL`, `DATABASE_PATH=data/comet.db` (SQLite only), `DATABASE_BATCH_SIZE`, `DATABASE_STARTUP_CLEANUP_INTERVAL`, `MEMORY_TRIM_INTERVAL=300`, `GLOBAL_PROXY_URL`, `PROXY_ETHOS=always`, `TZ`. Many `BACKGROUND_SCRAPER_*`, `*_CACHE_TTL`, `SCRAPE_*`, `JACKETT_*`, `PROWLARR_*` also exist. |
| Data paths | Relative to the working directory: `data/` (`DATABASE_PATH`, `PUBLIC_API_TOKEN_FILE`). Upstream runs in `/app`, so writes land in `/app/data`. |
| Dependencies | PostgreSQL optional (chart lists postgresql, present in this repo as `apps/postgresql`). SQLite otherwise. External debrid and indexer API keys. |
| Arm64 | UNVERIFIED: `uv.lock` was not fetched, so per-arch wheel availability is unknown. Upstream carries a Rust toolchain for dependencies that compile. |

## 2. Target layout

- `apps/comet/Dockerfile`
- `apps/comet/docker-bake.hcl`
- `apps/comet/settings.yaml`
- `apps/comet/container-test.yaml`
- `apps/comet/start.sh`

No `defaults/`, `etc/` or `health/` needed. No `root/`. `DOWNSTREAM_CHANGES.md` not needed.

## 3. Base image

`FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`, as the draft proposes. Python 3.15.2 satisfies `>=3.13`. Closest sibling: `apps/bazarr` (python app on the python base, uv installs, `WORKDIR /config`).

## 4. Dockerfile

1. Build stage `FROM <python> AS build`, `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. apt in build stage only: `gcc libc6-dev make git` (git only if a dependency needs it, UNVERIFIED). Install Rust only if a dependency compiles on arm64 (UNVERIFIED; the python base may already have what is needed).
3. Install uv pinned to a version: `pip install uv==<pinned>` or copy from `ghcr.io/astral-sh/uv` with a digest; record the version in a comment-free `ARG UV_VERSION`.
4. Download `https://github.com/g0ldyy/comet/archive/refs/tags/v${VERSION}.tar.gz` to `/tmp`, verify sha256 above, extract to `/tmp/src`.
5. Create the venv at `/app/comet/.venv` with `UV_PROJECT_ENVIRONMENT=/app/comet/.venv uv sync --frozen --no-install-project --project /tmp/src`. Cache at `/tmp/uv-cache` (`UV_CACHE_DIR=/tmp/uv-cache`).
6. Copy the package: `cp -r /tmp/src/comet /app/comet/comet`.
7. License: `/usr/share/licenses/comet/LICENSE` from `/tmp/src/LICENSE`.
8. Remove `rm -rf /tmp/*`.
9. Final stage: same python base, `USER root`, `COPY --from=build /app/comet /app/comet`, `chmod -R 755 /app`, create symlink `ln -s /config/data /app/comet/data` (dangling until `start.sh` creates `/config/data`).
10. `ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1 PYTHONMALLOC=malloc TZ=UTC PATH=/app/comet/.venv/bin:$PATH MALLOC_CONF=background_thread:true,dirty_decay_ms:5000,muzzy_decay_ms:0,narenas:2 HOME=/config`. Jemalloc: the upstream runtime installs `libjemalloc2` via apt and preloads it (`LD_PRELOAD=libjemalloc.so.2`). Add it only if the python base lacks it (UNVERIFIED).
11. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 8000
VOLUME /config
WORKDIR /app/comet
```

`WORKDIR /app/comet` is required, since the data paths are relative to the working directory.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "comet" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=g0ldyy/comet versioning=semver
  default = "2.59.0"
}
variable "LICENSE" { default = "GPL-3.0" }
variable "SOURCE" { default = "https://github.com/g0ldyy/comet" }
```

Four standard targets and the default group copied from `apps/adguardhome-sync`. Run `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/g0ldyy/comet"
ports:
  - port: 8000
    protocol: tcp
    required: false
env:
  - name: FASTAPI_HOST
    default: "0.0.0.0"
    required: false
  - name: FASTAPI_PORT
    default: "8000"
    required: false
  - name: FASTAPI_WORKERS
    default: "1"
    required: false
  - name: DATABASE_TYPE
    default: "sqlite"
    required: false
  - name: DATABASE_PATH
    default: "data/comet.db"
    required: false
  - name: PUBLIC_API_TOKEN_FILE
    default: "data/public_api_token.txt"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

`DATABASE_TYPE` default `sqlite` is a deployment choice for a single-container install; the upstream sample says sqlite is for development only, so this must be called out in the docs. The sample's `postgresql` default is not confirmed as the code default (UNVERIFIED). `ADMIN_DASHBOARD_PASSWORD` and `CONFIGURE_PAGE_PASSWORD` are secrets: list them only if start.sh passes them through, with empty defaults. PostgreSQL is optional, so `dependencies` lists `postgresql` as optional only if the chart's wiring is wanted; otherwise leave empty.

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config/data

cd /app/comet
exec python -m comet.main
```

- Idempotent. Creates `/config/data` only; the app writes `comet.db` and `public_api_token.txt` through the `/app/comet/data` symlink.
- Never writes under `/app` (the symlink points into `/config`).
- Binds `FASTAPI_HOST` (`0.0.0.0` by default). Confirm with an outside-container probe.
- `exec` for signal handling.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '8000'
http:
- port: '8000'
  path: /
filePaths:
- /app/comet/comet/main.py
- /app/comet/.venv/bin/python
- /usr/share/licenses/comet/LICENSE
```

The app may need debrid keys or a database to serve `/`; the HTTP probe status is UNVERIFIED until a real run. Choose a path that returns 200 without secrets, or the healthcheck path (`comet.healthcheck` hits the local port). Do not weaken the probe. `timeoutSeconds` is larger than sibling python apps because of dependency import time (UNVERIFIED).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `data/comet.db`, `data/public_api_token.txt` (relative to `/app`) | `/app/comet/data` -> `/config/data` symlink. |
| `/tmp/comet-prometheus` (`PROMETHEUS_MULTIPROC_DIR`) | Already `/tmp`; read-only rootfs with `--tmpfs /tmp` is fine. |
| uv cache | `/tmp/uv-cache` at build only. |
| Python bytecode | `PYTHONDONTWRITEBYTECODE=1`. |

Draft expectations reconciled: the chart runs as UID 568 with read-only rootfs and an emptyDir at `/.cache` (compatible). The chart's `/data` PVC maps to `/config/data` here. The draft's `/.cache` emptyDir is not needed because caches go to `/tmp`.

## 10. Risks, caveats and open questions

- PostgreSQL versus SQLite default is UNVERIFIED in code; sample says SQLite is development only. Document the choice.
- Comet is a Stremio add-on that relies on external debrid and indexer services with their own API keys.
- Env list comes from the main branch, not the pinned tag. Re-check against v2.59.0.
- `uv.lock` not fetched: arm64 wheels and any compile steps are UNVERIFIED. Dependencies without arm64 wheels would compile here, adding time.
- Rust toolchain may be needed for a compiled dependency; the plan avoids it unless the build proves it is needed.
- Upstream runs as root with no USER. This plan runs as `apps` (568).
- The draft's `latest` tag is not pinned upstream; the plan pins v2.59.0.
- No blockers confirmed (not musl-only, no GPU, no privileged need).

## 11. Build and test steps

```sh
cd apps/comet
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name comet-probe --read-only --tmpfs /tmp \
  -v comet-probe-config:/config comet:2.59.0
docker logs -f comet-probe
forgetool containers test --image comet:2.59.0 --config ./apps/comet/container-test.yaml
docker rm -f comet-probe; docker volume rm comet-probe-config
```

Readiness signal expected: the uvicorn/gunicorn bind line on port 8000 (exact text UNVERIFIED; confirm in the run). Confirm `/config/data/comet.db` exists after start and survives a restart. Probe from outside the container with `-p 8000:8000` to prove it is not bound to localhost.

## 12. PR checklist

- Branch `feat/add-comet`, commit and PR title `feat(comet): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections, check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA notice: a signed CLA is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows status.
- Untested to state honestly: builds on both architectures, arm64 wheel availability, runtime on `--read-only`, the probe status code, and the optional PostgreSQL path.
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION`; no assertion weakened.
