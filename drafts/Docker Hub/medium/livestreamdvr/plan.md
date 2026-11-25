# livestreamdvr — implementation plan
> Source: ./draft.md · Target: apps/livestreamdvr/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `LiveStreamDVR-2025-01-21-c2.4.3-s1.7.5.1-d1.1.2-v2.3.2.1`, marked "Latest" on the GitHub release page, released 2025-01-21. Same as the draft. |
| Chart tag | Chart runs `docker.io/mrbrax/twitchautomator:master` (Docker Hub `master` updated 2025-01-21; `develop` updated 2025-05-05). Upstream `master` is not compared with the 2025 release: UNVERIFIED whether they differ. |
| Renovate | Proposed: `// renovate: datasource=github-releases depName=MrBrax/LiveStreamDVR versioning=loose` (convention used by `apps/grocy`, `apps/syncthing`). UNVERIFIED against the upstream renovate config, which was not fetched. |
| License | MIT (`LICENSE` on `master`, Copyright (c) 2020 MrBrax). |
| Source URL | https://github.com/MrBrax/LiveStreamDVR |
| Download | One release asset, architecture-neutral: `https://github.com/MrBrax/LiveStreamDVR/releases/download/${VERSION}/${VERSION}.zip`. Whether the zip contains built JS or only sources: UNVERIFIED. |
| Checksum source | None published. No checksum asset in the release listing. Plan pins a sha256 computed from the zip (see section 4). |
| Upstream Dockerfile reviewed | commit `1cd7e8fa5b68e6c0cf9e657d1caa2cc74f7eb814`, `Dockerfile` plus `docker/fetch-tdl.sh` and `docker/fetch-ttv-lol.sh` (not read in full). |
| Upstream base and user | `node:20-bullseye-slim`. `USER node` is commented out, so upstream runs as root. |
| Upstream apt | ffmpeg, mediainfo, python3, python3-pip, python3-wheel, libxml2-dev, libxslt-dev, python3-dev, bash, git, curl, unzip, rclone. |
| Upstream build | `pipenv install --deploy` (Pipfile) as user `node`; Yarn builds of `twitch-chat-dumper`, `twitch-vod-chat` (+ buildlib), `server` (`lint:ts`, `build`, `generate-licenses`), `client-vue` (`build`, `generate-licenses`). |
| Upstream binaries | TwitchDownloaderCLI (`TD_VERSION=1.54.3` per `fetch-tdl.sh`) and the ttv-lol plugin, both fetched by the scripts above. Per-arch URLs and checksums: UNVERIFIED (scripts not read in full). |
| Real env vars (upstream ENV) | `TCD_BIN_DIR=/usr/local/bin`, `TCD_FFMPEG_PATH=/usr/bin/ffmpeg`, `TCD_BIN_PATH_PYTHON=/usr/bin/python`, `TCD_BIN_PATH_PYTHON3=/usr/bin/python3`, `TCD_MEDIAINFO_PATH=/usr/bin/mediainfo`, `TCD_NODE_PATH=/usr/local/bin/node`, `TCD_DOCKER=1`, `TCD_WEBSOCKET_ENABLED=1`, `TCD_SERVER_PORT=8080`, `TCD_PYTHON_ENABLE_PIPENV=1`, `TCD_TWITCHDOWNLOADER_PATH=/usr/local/bin/TwitchDownloaderCLI`, `HOME=/home/node`. |
| Ports | 8080/tcp (`EXPOSE 8080`, confirmed). |
| Entrypoint | `yarn run start`, WORKDIR `/usr/local/share/twitchautomator/server`. App dir `/usr/local/share/twitchautomator`. |
| Volumes | None declared by the Dockerfile. |
| Data write paths | UNVERIFIED beyond the draft: `/usr/local/share/twitchautomator/data/{config,cache,logs,storage}`. |
| Chart | `livestreamdvr` version 11.0.0, appVersion `master`, common 32.8.5 (`charts/stable/livestreamdvr/Chart.yaml`). |

## 2. Target layout

- `apps/livestreamdvr/Dockerfile`
- `apps/livestreamdvr/docker-bake.hcl`
- `apps/livestreamdvr/settings.yaml`
- `apps/livestreamdvr/container-test.yaml`
- `apps/livestreamdvr/start.sh`

No `defaults/`: Twitch credentials are entered in the app, and the app creates its own data folders (UNVERIFIED). No `etc/`, `health/`, `root/`. No `DOWNSTREAM_CHANGES.md`: the image is not a `FROM` base.

## 3. Base image

`FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5`

- Fits because the server is Python (pipenv) and the client and tools are Node. `python-node` already provides both, plus `/app/venv`.
- Closest sibling: `apps/changedetection` (python-node, venv in `/app/venv`, Node available).
- Caveat: `apps/changedetection` pins `python-node:3.14.8` because a dependency (litellm) does not support 3.15. Check the upstream `Pipfile` `python_version` before accepting 3.15. Fallback: `ghcr.io/trueforge-org/python-node:3.14.8@sha256:feb6e44439ea272f47b46a1511960f58af5df8056811c83973e2edec9b18afca`, copied from that sibling.

## 4. Dockerfile

Two stages, because the Node and Python builds are source builds: build stage, then `COPY --from=build` into the final `python-node` stage.

1. Build stage: `FROM <python-node> AS build`, `ARG VERSION`, `ARG TARGETARCH`, `ARG LIVESTREAMDVR_SHA256`, `USER root`.
2. Fetch and verify the release zip:
   ```dockerfile
   RUN curl -fsSL -o /tmp/ldvr.zip \
       "https://github.com/MrBrax/LiveStreamDVR/releases/download/${VERSION}/${VERSION}.zip" && \
     echo "${LIVESTREAMDVR_SHA256}  /tmp/ldvr.zip" | sha256sum -c - && \
     unzip -q /tmp/ldvr.zip -d /tmp/src
   ```
   `LIVESTREAMDVR_SHA256` is computed once from the downloaded file and pinned in the bake file, since no upstream checksum exists. `unzip` availability in the base is UNVERIFIED; add it to apt if missing.
3. Build the Node parts only if the zip contains sources (UNVERIFIED). Use the same Yarn steps as upstream. `YARN_CACHE_FOLDER=/tmp/yarn` and `npm_config_cache=/tmp/npm` keep caches out of `/app`.
4. Python: export the lock file and install into the base venv at build time. Python-runtime rule: `/app/venv` may be written during the build, never at runtime.
   ```dockerfile
   RUN cd /tmp/src/<server-dir> && pipenv requirements --dev=false > /tmp/requirements.txt && \
     /app/venv/bin/pip install --no-cache-dir -r /tmp/requirements.txt
   ```
   `pipenv` itself must be installed first (`/app/venv/bin/pip install pipenv`), and the path of the Pipfile is UNVERIFIED. `streamlink` is listed in the draft as inferred only; confirm it in the Pipfile before adding it.
5. TwitchDownloaderCLI, per `TARGETARCH`: download URL and checksum UNVERIFIED. Install to `/usr/local/bin/TwitchDownloaderCLI`, `chmod 0755`. Decide on the ttv-lol plugin after reading `docker/fetch-ttv-lol.sh`.
6. Final stage: `FROM <python-node>` (same digest), then:
   ```dockerfile
   USER root
   RUN apt-get update && \
     apt-get install -y --no-install-recommends ffmpeg mediainfo && \
     rm -rf /var/lib/apt/lists/* /tmp/*
   COPY --from=build /app/venv /app/venv
   COPY --from=build /tmp/build/ /app/livestreamdvr/
   COPY --from=build /usr/local/bin/TwitchDownloaderCLI /usr/local/bin/TwitchDownloaderCLI
   ```
   Apt packages `mediainfo` and `ffmpeg` are toolchain, not the app, so no version pin is needed. `rclone`, `git`, `bash` and `curl` are in the upstream list; keep `rclone` only if the app uses it (UNVERIFIED).
7. Data redirect: `ln -s /config/data /app/livestreamdvr/data` (dangling until `start.sh` creates `/config/data`).
8. License: `/usr/share/licenses/livestreamdvr/LICENSE` from the zip's `LICENSE`. If the zip has none, take it from the repo `LICENSE` (MIT).
9. Permissions: `chown -R root:root /app && chmod -R 755 /app` (same as `apps/bazarr`). `/app` stays read-only at runtime.
10. Environment:
    ```dockerfile
    ENV HOME=/config \
        TCD_BIN_DIR=/usr/local/bin \
        TCD_FFMPEG_PATH=/usr/bin/ffmpeg \
        TCD_MEDIAINFO_PATH=/usr/bin/mediainfo \
        TCD_BIN_PATH_PYTHON3=/app/venv/bin/python \
        TCD_NODE_PATH=/usr/local/bin/node \
        TCD_TWITCHDOWNLOADER_PATH=/usr/local/bin/TwitchDownloaderCLI \
        TCD_DOCKER=1 \
        TCD_WEBSOCKET_ENABLED=1 \
        TCD_SERVER_PORT=8080 \
        TCD_PYTHON_ENABLE_PIPENV=0 \
        TMPDIR=/tmp
    ```
    `TCD_BIN_PATH_PYTHON3` moves to the venv (UNVERIFIED that the app needs it). `TCD_PYTHON_ENABLE_PIPENV=0` is the rootless choice (section 9).
11. Tail:
    ```dockerfile
    USER apps
    COPY --chmod=0755 . /

    EXPOSE 8080
    VOLUME /config
    WORKDIR /app/livestreamdvr/server
    ```
    `COPY --chmod=0755 . /` must come after `USER apps` and stay in place.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "livestreamdvr"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=MrBrax/LiveStreamDVR versioning=loose
  default = "LiveStreamDVR-2025-01-21-c2.4.3-s1.7.5.1-d1.1.2-v2.3.2.1"
}

variable "LIVESTREAMDVR_SHA256" {
  default = "UNVERIFIED: compute from the downloaded zip on the first build"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/MrBrax/LiveStreamDVR"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
    LIVESTREAMDVR_SHA256 = "${LIVESTREAMDVR_SHA256}"
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

Add a `TD_VERSION` variable with its own `renovate:` comment once the TwitchDownloader source is confirmed (depName UNVERIFIED). Validate with `docker buildx bake --print` from `apps/livestreamdvr`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/MrBrax/LiveStreamDVR"
ports:
  - port: 8080
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

- The `TCD_*` variables are set in the Dockerfile `ENV`, not listed here, because users do not need to change them.
- Twitch client ID and secret are set inside the app (UNVERIFIED that they are not read from env). Do not list them until verified.
- No `dependencies:` section: no database or sidecar (same as `apps/bazarr`).

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config/data/config /config/data/cache /config/data/logs /config/data/storage

cd /app/livestreamdvr/server
exec yarn run start
```

- Idempotent and seeds nothing. The data folders are created only when missing (`mkdir -p`).
- Writes only under `/config`. Caches and temp files go to `/tmp`.
- `yarn` must be on `PATH` in the final image. If the base does not have it, copy it from the build stage or run `node` on the built entry file (UNVERIFIED).
- The `exec` hands PID 1 to the app, so signals reach it.
- The data subfolder names come from the draft and are UNVERIFIED. Confirm them in the source before relying on them.

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
- /app/livestreamdvr/server
- /app/venv/bin/python
- /usr/local/bin/TwitchDownloaderCLI
- /usr/share/licenses/livestreamdvr/LICENSE
```

- `timeoutSeconds: 180` follows `apps/changedetection`, which also starts a Node/Python stack.
- The test runs with no env vars. No code path needs Twitch credentials to start (UNVERIFIED), so no `filePaths` are needed for that.
- `/app/livestreamdvr/server` is the built server directory (UNVERIFIED path until the zip layout is checked).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap in ContainerForge |
| --- | --- |
| Runs as root (`USER node` commented out) | `USER apps` (568). `HOME=/home/node` becomes `HOME=/config`. |
| `/usr/local/share/twitchautomator/data/{config,cache,logs,storage}` (UNVERIFIED list) | `ln -s /config/data /app/livestreamdvr/data`; `/config` is the single persistent volume. |
| `TCD_PYTHON_ENABLE_PIPENV=1` (pipenv at runtime) | Set to `0`. Runtime pipenv would write a venv, which `/app` does not allow. Confirm the app runs without it (UNVERIFIED). |
| Yarn and npm caches | `/tmp` at build time only. |
| TwitchDownloader and ffmpeg temp files | `TMPDIR=/tmp` (UNVERIFIED that the app honours it). |

Draft security expectations, reconciled:
- Chart forces UID 0 and `readOnlyRootFilesystem: false`. The image runs as 568 and must work with `--read-only --tmpfs /tmp`. Verify this in section 11.
- Chart PVCs for `/app/.../data/*` become one `/config` volume with `data/` inside. Existing users must copy their data across.
- Not privileged.

## 10. Risks, caveats and open questions

- The release is from 2025-01-21, about 22 months old. Upstream `master` and `develop` have newer commits. Decide whether to keep this release or pin a newer `master` commit (then use `datasource=git-refs`, as `apps/fenrus` does).
- The zip contents (built or source) are UNVERIFIED. This decides whether the Node build stage is needed.
- Python version: `python-node:3.15.2` against the upstream `Pipfile` `python_version` is UNVERIFIED. See section 3 for the fallback.
- Node version: upstream uses Node 20. The Node version in `python-node` is UNVERIFIED. Yarn availability is UNVERIFIED.
- TwitchDownloaderCLI and the ttv-lol plugin: per-arch URLs and checksums are UNVERIFIED. If there is no arm64 TwitchDownloaderCLI build, arm64 is blocked. The draft's "amd64: yes, arm64: yes" is not confirmed for this binary.
- Runs as root upstream, so the app may write into its own folder. Read-only rootfs may fail. UNVERIFIED.
- No database. Twitch credentials are needed for real use but not to start.
- Recordings and VOD downloads fill disks quickly (inferred; keep `/config` on a large volume).
- No blockers confirmed. Not musl-only, no GPU, not privileged. arm64 is the main open risk (TwitchDownloader).

## 11. Build and test steps

```sh
cd apps/livestreamdvr
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name livestreamdvr-probe --read-only --tmpfs /tmp \
  -v livestreamdvr-probe-config:/config \
  livestreamdvr:LiveStreamDVR-2025-01-21-c2.4.3-s1.7.5.1-d1.1.2-v2.3.2.1
docker logs -f livestreamdvr-probe
forgetool containers test \
  --image livestreamdvr:LiveStreamDVR-2025-01-21-c2.4.3-s1.7.5.1-d1.1.2-v2.3.2.1 \
  --config ./container-test.yaml
docker rm -f livestreamdvr-probe; docker volume rm livestreamdvr-probe-config
```

- Readiness: the server log line is UNVERIFIED; record the first real line. Pass also needs port 8080 open and `/` answering HTTP.
- Confirm `/config/data` exists after start and survives a restart.
- Confirm the image starts with the probe on an empty `/config`.
- Test from outside the container (`-p 8080:8080`) to confirm it is not bound to localhost.

## 12. PR checklist

- Branch `feat/add-livestreamdvr`, commit and PR title `feat(livestreamdvr): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, and check only the boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it. The `license/cla` check shows the status.
- Say in the PR what was not tested: arm64 (TwitchDownloader), the Node build if the zip has no sources, read-only runtime, and the Twitch flow.
- `docker buildx bake --print` passes; bake `VERSION` equals the Dockerfile `ARG VERSION`; no assertion weakened.
