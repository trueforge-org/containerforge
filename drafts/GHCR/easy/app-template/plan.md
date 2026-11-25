# app-template — implementation plan
> Source: ./draft.md · Target: apps/app-template/ · Difficulty: easy · Role: main (speedtest-exporter image, python) · Verified on 2026-11-25

Note: the folder name is `app-template` (the TrueCharts chart name). The container app to create is `speedtest-exporter`, so the target folder should be `apps/speedtest-exporter/` (APP=speedtest-exporter). Confirm the name before scaffolding; the draft's chart name must not become the app name.

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `v3.5.4`, the tag the chart pins (`ghcr.io/miguelndecarvalho/speedtest-exporter:v3.5.4`). Published 2023-06-28. Latest GitHub release returned by the API is v3.5.4. Source: https://api.github.com/repos/MiguelNdeCarvalho/speedtest-exporter/releases/tags/v3.5.4 (read via `gh api`). A newer tag after v3.5.4 is UNVERIFIED. |
| Renovate | `datasource=github-releases depName=MiguelNdeCarvalho/speedtest-exporter versioning=loose` (tags are `v`-prefixed) |
| Ookla CLI renovate | Separate pin `SPEEDTEST_VERSION=1.2.0` in upstream Dockerfile. No renovate datasource exists for Ookla; annotate manually or use a `customManagers` regex in renovate config (UNVERIFIED whether the repo's renovate config supports this; check `renovate.json` before choosing). |
| License | GPL-3.0. Source: https://raw.githubusercontent.com/MiguelNdeCarvalho/speedtest-exporter/v3.5.4/LICENSE (GitHub license API returned 404 for the repo, so the LICENSE file is the source). |
| Source URL | https://github.com/MiguelNdeCarvalho/speedtest-exporter |
| Documentation | https://docs.miguelndecarvalho.pt/projects/speedtest-exporter/ (not fetched; UNVERIFIED for anything beyond the env vars read in source) |
| Download (app) | Source tarball `https://github.com/MiguelNdeCarvalho/speedtest-exporter/archive/refs/tags/${VERSION}.tar.gz`. The tag has no release assets (`assets: []`). |
| Download (Ookla CLI) | `https://install.speedtest.net/app/cli/ookla-speedtest-${SPEEDTEST_VERSION}-linux-${ARCH}.tgz`. Both `x86_64` and `aarch64` for 1.2.0 returned HTTP 200 (checked with curl HEAD). Mapping: amd64 -> `x86_64`, arm64 -> `aarch64`. |
| Checksum source | None. Upstream does not verify the Ookla tarball and publishes no checksum for it. Source tarball is pinned by tag only (a tag can move; UNVERIFIED that upstream tags are immutable). |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/MiguelNdeCarvalho/speedtest-exporter/v3.5.4/Dockerfile: `FROM python:3.11.0-alpine3.15`, single stage, `pip install --no-cache-dir -r requirements.txt`, Ookla CLI via wget into `/usr/local/bin`, `USER speedtest`, `WORKDIR /app`, `CMD ["python", "-u", "exporter.py"]`, HEALTHCHECK on `http://localhost:${SPEEDTEST_PORT:=9798}/`. |
| Python deps | `src/requirements.txt`: `Werkzeug==2.3.6`, `Flask==2.3.2`, `prometheus_client==0.17.0`, `waitress==2.1.2` (read via `gh api`). |
| Port | 9798/tcp, HTTP. `serve(app, host='0.0.0.0', port=PORT)` in `src/exporter.py`, so it binds all interfaces already. |
| Endpoints | `/` returns an HTML welcome page; metrics through `make_wsgi_app` (prometheus). Whether `/metrics` triggers a live speedtest is UNVERIFIED (read `runTest` call sites before choosing the probe path). |
| Env vars (real) | `SPEEDTEST_PORT` (default 9798), `SPEEDTEST_CACHE_FOR` (default 0, seconds), `SPEEDTEST_TIMEOUT` (default 90, seconds), `SPEEDTEST_SERVER` (optional; passed as `--server-id`). Source: https://raw.githubusercontent.com/MiguelNdeCarvalho/speedtest-exporter/v3.5.4/src/exporter.py. The CLI is run with `--accept-license --accept-gdpr`. |
| Data / config write paths | None found in `exporter.py`. The Ookla CLI may write its state under `$HOME` (UNVERIFIED which path); set `HOME=/tmp` so it never lands in `/app` or `/config`. |
| Dependencies | None. The chart's optional mariadb, valkey and mongodb are chart-level and the exporter does not read them. |
| arm64 | Ookla aarch64 tarball reachable (see above). Upstream image is alpine-only. Native arm64 build via buildx is the expected path. |
| Blockers | None found. Caveat: each speedtest run consumes real bandwidth and needs outbound internet. |

## 2. Target layout

- `apps/speedtest-exporter/Dockerfile`
- `apps/speedtest-exporter/docker-bake.hcl`
- `apps/speedtest-exporter/settings.yaml`
- `apps/speedtest-exporter/container-test.yaml`
- `apps/speedtest-exporter/start.sh`

No `defaults/`, `etc/`, `health/` needed (no config file to seed, no state). No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base). No `/config` volume: the exporter keeps no state (see section 9).

Note: `include/.dockerignore` is an allow-list. `COPY --chmod=0755 . /` only reaches `start.sh`. The app source (`src/exporter.py`) is fetched during the build from the tarball, so it does not need to be in the folder.

## 3. Base image

`FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d` for the final stage. Python runtime is required; the exporter is a Python WSGI app. Closest sibling: `apps/bazarr` (python base, `USER root` for install, then `USER apps`) and `apps/changedetection` (python-node sibling). The python base sets `VENV_FOLDER=/app/venv` and `PATH=/usr/local/bin:$PATH`.

Python version note: upstream pins Flask 2.3.2 and Werkzeug 2.3.6 (2023 era) and was tested on Python 3.11. Running on Python 3.15 is UNVERIFIED; check that the pinned wheels install on 3.15 during the build. If they do not, bump only within the same major Flask line and record the reason.

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `ARG SPEEDTEST_VERSION=1.2.0`, `USER root`.
2. Set `ENV` for runtime defaults and HOME:

```dockerfile
ENV SPEEDTEST_PORT=9798 \
    SPEEDTEST_CACHE_FOR=0 \
    SPEEDTEST_TIMEOUT=90 \
    HOME=/tmp
```

3. Ookla CLI, arch mapping and extract (no checksum available):

```dockerfile
RUN set -eux; \
    case "${TARGETARCH}" in \
        amd64) OOKLA_ARCH=x86_64 ;; \
        arm64) OOKLA_ARCH=aarch64 ;; \
        *) echo "unsupported arch: ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    curl -fsSL -o /tmp/speedtest.tgz \
      "https://install.speedtest.net/app/cli/ookla-speedtest-${SPEEDTEST_VERSION}-linux-${OOKLA_ARCH}.tgz"; \
    tar -xzf /tmp/speedtest.tgz -C /usr/local/bin speedtest; \
    rm -f /tmp/speedtest.tgz
```

The tarball layout (single `speedtest` binary at the root) is UNVERIFIED; list it with `tar -tzf` once during the first build and adjust `-C`/member name.

4. Exporter source from the tag tarball, into `/app`, with deps installed into `/app/venv` at build time (python-runtime rule: `/app/venv` is read-only at runtime, so it is written only here):

```dockerfile
RUN set -eux; \
    curl -fsSL -o /tmp/src.tgz \
      "https://github.com/MiguelNdeCarvalho/speedtest-exporter/archive/refs/tags/${VERSION}.tar.gz"; \
    mkdir -p /tmp/src && tar -xzf /tmp/src.tgz -C /tmp/src --strip-components=1; \
    mkdir -p /app; \
    cp /tmp/src/src/exporter.py /app/exporter.py; \
    mkdir -p /usr/share/licenses/speedtest-exporter; \
    cp /tmp/src/LICENSE /usr/share/licenses/speedtest-exporter/LICENSE; \
    /usr/local/bin/python -m venv /app/venv; \
    /app/venv/bin/pip install --no-cache-dir -r /tmp/src/src/requirements.txt; \
    rm -rf /tmp/src /tmp/src.tgz /tmp/* ; \
    chown -R root:root /app && chmod -R 755 /app
```

Notes for this step: create `/usr/share/licenses/speedtest-exporter` with `mkdir -p` before the `cp` (remove the `|| true` once the path exists, so a missing license fails the build). `pip` cache goes to `/tmp` via `PIP_CACHE_DIR=/tmp/pip` if the base does not already set it (the base sets `PIP_NO_CACHE_DIR=1`, which is fine). Use the `python` base's `/usr/local/bin/python` only if that is the interpreter it provides (check `which python` in the base during the first bake run).

5. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /
WORKDIR /app

EXPOSE 9798
```

No `VOLUME /config`: the exporter keeps no persistent state. Add `VOLUME` only if a later change needs it.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "speedtest-exporter"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=MiguelNdeCarvalho/speedtest-exporter versioning=loose
  default = "v3.5.4"
}

variable "LICENSE" {
  default = "GPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/MiguelNdeCarvalho/speedtest-exporter"
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

Notes: `LICENSE` is GPL-3.0 per the LICENSE file; the SPDX form `GPL-3.0-only` vs `GPL-3.0-or-later` depends on the file text (confirm the "or later" clause in the LICENSE header; the file is the standard GPL-3 text, so `GPL-3.0-only` is the default reading). Ookla CLI renovate annotation: a second `// renovate:` comment above `SPEEDTEST_VERSION` in the Dockerfile is not read by bake; keep the pin in `docker-bake.hcl` as `variable "SPEEDTEST_VERSION"` with its own annotation and pass it via `args` so the Dockerfile `ARG` matches. Validate with `docker buildx bake --print` from `apps/speedtest-exporter`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/MiguelNdeCarvalho/speedtest-exporter"
ports:
  - port: 9798
    protocol: tcp
    required: false
env:
  - name: SPEEDTEST_PORT
    default: "9798"
    required: false
  - name: SPEEDTEST_CACHE_FOR
    default: "0"
    required: false
  - name: SPEEDTEST_TIMEOUT
    default: "90"
    required: false
  - name: SPEEDTEST_SERVER
    default: ""
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes: []
dependencies: []
```

Notes: `SPEEDTEST_SERVER` is optional with no default (empty means auto-select). `volumes: []` because no `/config` is used; if the schema rejects an empty list, omit the key (UNVERIFIED). `TZ` is listed only if the start script or the base uses it; drop it otherwise (do not invent env vars).

## 7. start.sh

```bash
#!/usr/bin/env bash

cd /app
exec /app/venv/bin/python -u /app/exporter.py
```

Notes: no seeding (no `/config`). No writes to `/app`. `exec` so the Python process is PID 1 (or under tini). The exporter reads `SPEEDTEST_PORT` itself, so the script needs no port logic. Binding is `0.0.0.0` in `exporter.py`, which satisfies the network rule. Do not add `/config` handling for this app.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '9798'
http:
- port: '9798'
  path: /
filePaths:
- /app/exporter.py
- /app/venv/bin/python
- /usr/local/bin/speedtest
- /usr/share/licenses/speedtest-exporter/LICENSE
```

Notes:
- Coverage: the one port (9798) has a tcp and an http probe.
- `path: /` is used because it returns the welcome page. If `/metrics` does not trigger a speedtest, `/metrics` is a better probe (it checks the Prometheus endpoint); confirm in `exporter.py` before switching.
- Timeout: raise `timeoutSeconds` only if the probe path runs a live speedtest (then use at least `SPEEDTEST_TIMEOUT` plus margin). The 120s value is a placeholder; take the sibling family value if a Python exporter sibling exists.
- No env-only code paths exist that the test cannot reach; `SPEEDTEST_SERVER` only adds an argument to the CLI call.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/app` (upstream WORKDIR, pip install) | Written at build time only, owned by root, mode 755. Runtime read-only. |
| Ookla CLI state under `$HOME` (UNVERIFIED path) | `HOME=/tmp` (tmpfs under `--read-only --tmpfs /tmp`). |
| pip cache | Disabled by base (`PIP_NO_CACHE_DIR=1`); build scratch in `/tmp`, removed in the same RUN. |
| `/tmp` extraction scratch | Removed in the same RUN step. |

Upstream user `speedtest` is replaced by `USER apps` (568). Read-only rootfs is compatible: nothing writes at runtime except the Ookla CLI's `$HOME`, which is `/tmp`. The chart's `readOnlyRootFilesystem: true` default matches. Privileged: no.

## 10. Risks, caveats and open questions

- Each `/metrics` or `/` probe that runs a live test uses real bandwidth and needs outbound internet. CI runners may not allow the Ookla download host at test time (not an issue at build time because the tarball is fetched during build). Confirm the probe path does not run a test on every request.
- Ookla CLI 1.2.0 is pinned upstream and has no renovate datasource. Decide whether to track it manually or with a renovate custom regex.
- No checksum for the Ookla tarball and no checksum for the source tarball. Either verify with an upstream-published hash (none found) or document as a known gap.
- Pinned Flask/Werkzeug (2023) on Python 3.15: install compatibility UNVERIFIED.
- `ookla` CLI needs glibc; the ubuntu-family python base is glibc, so this should be fine (UNVERIFIED by running it).
- Draft expectation `extra-persistence: none` is confirmed (no state written).
- Draft expects optional mariadb/valkey/mongodb: not used by the exporter, so `dependencies: []` (not a DB-dependent app; the DB exception in the protocol does not apply).
- Speedtest server selection depends on the Ookla service; results vary by network.

## 11. Build and test steps

```sh
cd apps/speedtest-exporter
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name speedtest-exporter-probe --read-only --tmpfs /tmp \
  speedtest-exporter:v3.5.4
docker logs -f speedtest-exporter-probe
docker exec speedtest-exporter-probe /usr/local/bin/speedtest --version
forgetool containers test --image speedtest-exporter:v3.5.4 --config ./apps/speedtest-exporter/container-test.yaml
docker rm -f speedtest-exporter-probe
```

No `/config` volume is created (none is used), so there is no volume to remove. Readiness signal: `Starting Speedtest-Exporter on http://localhost:9798` (line 148 of `exporter.py`; the message says localhost but the bind is `0.0.0.0`). Also check the container stays up and that `curl -s http://localhost:9798/` returns the welcome page from inside the container.

Outside-container check (for the "not only localhost" rule): run with `-p 9798:9798` and curl from the host.

## 12. PR checklist

- Branch `feat/add-speedtest-exporter` (folder and app name: `speedtest-exporter`, not `app-template`), commit and PR title `feat(speedtest-exporter): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections, check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows status.
- DOWNSTREAM_CHANGES.md: not needed (not a `FROM` base).
- Untested to state honestly (unless done): the Python 3.15 install of pinned deps, the Ookla CLI run and its `$HOME` behavior on read-only rootfs, the probe path choice, the arm64 build and run, and the Ookla tarball layout.
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION`; no assertion weakened.
