# chroma — implementation plan
> Source: ./draft.md · Target: apps/chroma/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | `1.5.9`, published 2026-05-05, not a prerelease. Source: https://api.github.com/repos/chroma-core/chroma/releases/latest |
| Draft tag | Chart image `ghcr.io/chroma-core/chroma:1.5.9@sha256:1e0b73a187a28757c572acba508c46f48c9e8b0acaf5c20e6d95cdedce1acdf6`. Source: https://api.github.com/repos/trueforge-org/truecharts/contents/charts/stable/chroma/values.yaml |
| Renovate | `datasource=pypi depName=chromadb versioning=pep440`. Source: https://pypi.org/pypi/chromadb/json |
| License | Apache-2.0 (GitHub API `spdx_id`: https://api.github.com/repos/chroma-core/chroma). PyPI `license` field is empty; README says Apache 2.0. |
| Source URL | https://github.com/chroma-core/chroma |
| Per-arch download | Wheels for 1.5.9 (no build needed): `chromadb-1.5.9-cp39-abi3-manylinux_2_17_x86_64.manylinux2014_x86_64.whl` (sha256 `cc09b3df76e5a5cb...`) and `chromadb-1.5.9-cp39-abi3-manylinux_2_17_aarch64.manylinux2014_aarch64.whl` (sha256 `9192d111bd662241...`). Source: https://pypi.org/pypi/chromadb/1.5.9/json (files.pythonhosted.org URLs listed there). |
| Checksum source | sha256 digests in the PyPI JSON above (`urls[].digests.sha256`). |
| Upstream Dockerfile | https://raw.githubusercontent.com/chroma-core/chroma/11f3c7435e71024aa0a2b53710a28d3289d922d1/Dockerfile: multi-stage, `python:3.11-slim-bookworm`; builder compiles the Rust wheel from source (rustup, protoc); final stage copies `/install` into `/usr/local`; runs as root (no `USER`), no `VOLUME`, `EXPOSE 8000`, `ENTRYPOINT ["/docker_entrypoint.sh"]`. |
| Upstream entrypoint | https://api.github.com/repos/chroma-core/chroma/contents/bin/docker_entrypoint.sh?ref=11f3c7435e71024aa0a2b53710a28d3289d922d1: `export IS_PERSISTENT=1`, `CHROMA_SERVER_NOFILE` (default 65536), then `exec uvicorn chromadb.app:app $args`. |
| Upstream CMD | Single exec-form string: `--workers ${CHROMA_WORKERS} --host ${CHROMA_HOST_ADDR} --port ${CHROMA_HOST_PORT} --proxy-headers --reload --log-config ${CHROMA_LOG_CONFIG} --timeout-keep-alive ${CHROMA_TIMEOUT_KEEP_ALIVE}`. Upstream ENV: `CHROMA_HOST_ADDR=0.0.0.0`, `CHROMA_HOST_PORT=8000`, `CHROMA_WORKERS=1`, `CHROMA_LOG_CONFIG=chromadb/log_config.yml`, `CHROMA_TIMEOUT_KEEP_ALIVE=30`. |
| Data env (real) | `chromadb/config.py` `Settings`: `is_persistent: bool = False` (env `IS_PERSISTENT`), `persist_directory: str = "./chroma"` (env `PERSIST_DIRECTORY`). Source: https://api.github.com/repos/chroma-core/chroma/contents/chromadb/config.py?ref=11f3c7435e71024aa0a2b53710a28d3289d922d1 |
| Ports | 8000/tcp (HTTP API). Chart service `main`, targetPort 8000. |
| Security (chart) | `runAsUser: 0`, `runAsGroup: 0`, `runAsNonRoot: false`, `readOnlyRootFilesystem: false`; persistence `config` at `/chroma/chroma`. Source: chart values URL above. |
| Dependencies | None. |
| Blockers | None known. UNVERIFIED: auth default (upstream docs not fetched). |

Draft corrections: the draft expects `/config` for data; the chart uses `/chroma/chroma`. The plan uses `/config/chroma` (ContainerForge convention), which is a deliberate change, not a correction of the upstream path.

## 2. Target layout

- `apps/chroma/Dockerfile`
- `apps/chroma/docker-bake.hcl`
- `apps/chroma/settings.yaml`
- `apps/chroma/container-test.yaml`
- `apps/chroma/start.sh`

No `defaults/`, `etc/`, `health/`, `root/`. No `DOWNSTREAM_CHANGES.md` (chroma is not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`. Fits: a pure pip install with prebuilt wheels, and the base already provides `/app/venv` (`VENV_FOLDER=/app/venv`), `pip` and `PIP_NO_CACHE_DIR=1`. Closest sibling: `apps/bazarr` (python main app) and `apps/python` (base). Note the upstream image uses Python 3.11; the chromadb wheels are `cp39-abi3`, so they install on 3.15 (UNVERIFIED that every transitive dependency has a 3.15 wheel; check at build time).

## 4. Dockerfile

1. `FROM <python base above>`; `ARG VERSION`.
2. `USER root`.
3. `RUN /app/venv/bin/pip install --no-cache-dir "chromadb==${VERSION}"` at build time (installs into `/app/venv`, which is allowed at build time only; python-runtime rules forbid runtime mutation). No apt packages: the wheels are self-contained.
4. Verify: `RUN /app/venv/bin/python -c "import chromadb; print(chromadb.__version__)"` and check it equals `${VERSION}`. This is the version-alignment check.
5. The base's `chown -R apps:apps /app` ran before this install, so files added by this `pip install` (as root) are root-owned. Root-owned `chmod -R 755 /app/venv` is fine for a read-only runtime (as `apps/bazarr` does with `chown -R root:root /app`); `chmod -R 755 /app/venv` after the install.
6. `COPY --chmod=0755 start.sh /start.sh`.
7. `USER apps`, `COPY --chmod=0755 . /`.
8. `ENV IS_PERSISTENT=1 PERSIST_DIRECTORY=/config/chroma CHROMA_HOST_ADDR=0.0.0.0 CHROMA_HOST_PORT=8000 CHROMA_WORKERS=1 CHROMA_TIMEOUT_KEEP_ALIVE=30`, so the defaults match upstream.
9. `EXPOSE 8000`, `CMD ["/start.sh"]`. Add `VOLUME /config` explicitly (`apps/python/Dockerfile` has no `VOLUME` line).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "chroma"
}

variable "VERSION" {
  // renovate: datasource=pypi depName=chromadb versioning=pep440
  default = "1.5.9"
}

variable "LICENSE" {
  default = "Apache-2.0"
}

variable "SOURCE" {
  default = "https://github.com/chroma-core/chroma"
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

Both arches have wheels (section 1), so `image-all` lists amd64 and arm64. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/chroma-core/chroma"
ports:
  - port: 8000
    protocol: tcp
    required: true
env:
  - name: CHROMA_HOST_ADDR
    default: "0.0.0.0"
    required: false
  - name: CHROMA_HOST_PORT
    default: "8000"
    required: false
  - name: CHROMA_WORKERS
    default: "1"
    required: false
  - name: CHROMA_TIMEOUT_KEEP_ALIVE
    default: "30"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

Dependencies: none. `IS_PERSISTENT` and `PERSIST_DIRECTORY` are fixed by the image (set in the Dockerfile, not user-facing), so they are not listed. The `CHROMA_*` names are the upstream image's own names, read by `start.sh`.

## 7. start.sh

Plan (idempotent, empty `/config` safe, no writes to `/app`):

```bash
#!/usr/bin/env bash
set -euo pipefail

mkdir -p "${PERSIST_DIRECTORY:-/config/chroma}"

export IS_PERSISTENT=1
export PERSIST_DIRECTORY="${PERSIST_DIRECTORY:-/config/chroma}"

exec /app/venv/bin/uvicorn chromadb.app:app \
  --workers "${CHROMA_WORKERS:-1}" \
  --host "${CHROMA_HOST_ADDR:-0.0.0.0}" \
  --port "${CHROMA_HOST_PORT:-8000}" \
  --proxy-headers \
  --timeout-keep-alive "${CHROMA_TIMEOUT_KEEP_ALIVE:-30}"
```

- `mkdir -p` only creates the data directory; nothing is seeded (chroma creates its SQLite store itself on first start).
- `exec` so signals reach uvicorn.
- Drops upstream `--reload` (a dev option, it restarts on file changes and is not wanted in a container) and `--log-config` (upstream path `chromadb/log_config.yml` is relative to the upstream working directory; UNVERIFIED absolute path in this image, so uvicorn defaults are used). Both are decisions, see section 10.
- Quote every variable; no shell eval of user input.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '8000'
http:
- port: '8000'
  path: /api/v2/heartbeat
filePaths:
- /start.sh
- /app/venv/bin/uvicorn
```

`/api/v2/heartbeat` is UNVERIFIED: confirm the route against `chromadb/app.py` in the pinned commit before the run (the path is not in the fetched facts). If it differs, use the path that returns 200 and record the change. The chart's own probe path is not in the chart values fetched.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/chroma/chroma` (chart PVC, persisted data) | `/config/chroma` via `PERSIST_DIRECTORY`. |
| Upstream runs as root (no `USER`) | `USER apps` from base. |
| Pip cache / build tooling | Not used at runtime (`PIP_NO_CACHE_DIR=1` already in base). Build-time pip uses `--no-cache-dir`. |
| `HOME` | Inherited from base; uvicorn and chroma do not need a writable home beyond `/config` and `/tmp` (UNVERIFIED for every code path). |

Security reconciliation: chart runs root and writable rootfs; plan runs as `apps` with `--read-only --tmpfs /tmp`. Chroma writes only to the persist directory, so `/config` is the only writable path needed. Not privileged.

## 10. Risks, caveats and open questions

- **Wheel availability**: wheels exist for both arches at 1.5.9. Transitive dependencies on Python 3.15 are UNVERIFIED until the build runs.
- **Version drift**: the chart pins `1.5.9`; the bake pins the same version, so no drift.
- **No auth**: the API listens on 8000 without authentication by default (chart and draft say so; UNVERIFIED against upstream docs). Document this in the PR; it should only be reachable from trusted networks.
- **Dropped flags**: `--reload` and `--log-config` are not ported (section 7).
- **Upstream exec-form CMD**: upstream's single-string CMD does not expand variables in exec form (noted in the Dockerfile review); the plan avoids the problem by using a shell script.
- **Launch path**: upstream runs `uvicorn chromadb.app:app`; no `chroma run` CLI is used.
- **Blockers**: none known.

## 11. Build and test steps

From `apps/chroma`:

1. `docker buildx bake --print` must exit 0.
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. Run with empty config: `docker run --rm -d --name chroma-probe --read-only --tmpfs /tmp -v chroma-probe-config:/config chroma:1.5.9`, then `docker logs -f chroma-probe`. Pass signal: uvicorn logs `Uvicorn running on http://0.0.0.0:8000` (or the equivalent startup line), the process stays up, no traceback.
4. Confirm the heartbeat: `curl -fsS http://<container-ip>:8000/api/v2/heartbeat` (path UNVERIFIED, see section 8).
5. Cleanup: `docker rm -f chroma-probe; docker volume rm chroma-probe-config`.
6. `forgetool containers test --image chroma:1.5.9 --config ./container-test.yaml` (or by-hand checks if forgetool is missing).
7. Also build `image-all` (both arches) at least once, since both arches use the same wheel path.

## 12. PR checklist

- Branch `feat/add-chroma`, commit `feat(chroma): add new container`, PR title the same.
- PR body from `.github/PULL_REQUEST_TEMPLATE.md`, sections and checkboxes kept; tick only what applies.
- Notes section has `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it; the `license/cla` check shows status.
- Say what was not tested (for example arm64 build, heartbeat path, transitive wheels on 3.15) and every UNVERIFIED item above.
- Do not tick "Built container locally" unless the bake and build actually ran.
