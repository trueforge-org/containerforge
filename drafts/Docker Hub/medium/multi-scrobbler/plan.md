# multi-scrobbler — implementation plan
> Source: ./draft.md · Target: apps/multi-scrobbler/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Latest stable `0.21.2` (published 2026-11-22). Draft pins `0.21.1` (published 2026-11-17). Plan uses `0.21.2`; the Node engine, `package.json` and Dockerfile were checked at `0.21.1` only and must be re-checked at tag `0.21.2` before implementing (UNVERIFIED for 0.21.2). |
| Renovate | `datasource=github-releases depName=FoxxMD/multi-scrobbler versioning=semver` (suggested; repo renovate config not checked, UNVERIFIED) |
| License | MIT (GitHub SPDX `MIT`; `package.json` at tag `0.21.1`; upstream image label `org.opencontainers.image.licenses="MIT"`) |
| Source URL | https://github.com/FoxxMD/multi-scrobbler |
| Download | Source tarball `https://github.com/FoxxMD/multi-scrobbler/archive/refs/tags/${VERSION}.tar.gz` (tag has no `v` prefix: `0.21.1`, `0.21.2`). |
| Per-arch | Source build, so the same tarball on both architectures. Native addons (`sharp`, `classic-level`) are compiled in the build stage on each arch. Upstream Hub `0.21.1` has amd64 and arm64 active. |
| Checksum source | None found for the tag tarball (UNVERIFIED). GitHub tag archive is content-addressed by commit. |
| Node engine | `>=24.14.0`, npm `^11.12.1` (`package.json` at tag `0.21.1`) |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/FoxxMD/multi-scrobbler/d164f568a47874e7a8d33604db630e6edbfdcca6/Dockerfile. Stages: builder `node:24-trixie-slim` (digest pinned), `app-src` (`npm run install:parallel`), `test` (`npm run test:parallel`), `app-build` (`npm run build:parallel`, `NODE_ENV=production`), `app-deps` (`npm ci --omit=dev`, prunes dev tools), runtime `gcr.io/distroless/nodejs24-debian13:nonroot`, `WORKDIR /app`, `CMD ["/app/src/backend/index.ts"]`, runs as UID/GID 65532. |
| Ports | 9078 (`PORT`, from upstream Dockerfile). Confirmed. |
| Env vars (upstream Dockerfile) | `CONFIG_DIR=/config`, `LOGS_DIR=/config/logs`, `DATA_DIR=/config`, `TZ=Etc/GMT`, `NODE_ENV=production`, `IS_DOCKER=true`, `COLORED_STD=true`, `PORT=9078`, `APP_VERSION` (from build arg). |
| Env vars (`.env.example` at 0.21.1) | `TZ`, `CONFIG_DIR`, `DATA_DIR`, `LOGS_DIR`, `LOG_LEVEL` (default value not verified, UNVERIFIED). Source: https://raw.githubusercontent.com/FoxxMD/multi-scrobbler/0.21.1/.env.example |
| Write paths (upstream) | `/config` (`VOLUME $data_dir`, `ARG data_dir=/config`), `/config/logs`. Docs for directories: https://docs.multi-scrobbler.app/installation/#config-and-data-directories (not fetched, UNVERIFIED detail). |
| User | Distroless `nonroot`, UID/GID 65532. |
| Dependencies | None required by the image. Sources (Spotify, Last.fm, Plex, Jellyfin, and others) need their own credentials at runtime (README: https://raw.githubusercontent.com/FoxxMD/multi-scrobbler/0.21.1/README.md). |

## 2. Target layout

- `apps/multi-scrobbler/Dockerfile`
- `apps/multi-scrobbler/docker-bake.hcl`
- `apps/multi-scrobbler/settings.yaml`
- `apps/multi-scrobbler/container-test.yaml`
- `apps/multi-scrobbler/start.sh` (creates `/config` subdirs when missing, then `exec`s node)

No `defaults/`, `etc/`, `health/` (no seeded config needed; the app writes its own). No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

Build and runtime on the same base, so node is available in both stages:

```dockerfile
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5
```

Upstream's runtime is distroless, which is not a ContainerForge base. The python-node base gives node and npm, and `apps/budge` shows a node build on it. `apps/python-node` does not exist in this repo, so the base's Node version cannot be read from a Dockerfile here; `apps/budge`'s comment says Node 24 (UNVERIFIED for this tag). The `python-node` base must provide Node `>=24.14.0`: NOT VERIFIED (node version of `python-node:3.15.2` not checked). If it is lower, the base has to change (use the `ubuntu` base plus a node install, or a newer python-node), and that is a blocker to raise with the user. Closest sibling: `apps/budge` (python-node, build with npm, `USER apps`, `WORKDIR`, `VOLUME /config`).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `ARG APP_BUILD_VERSION` (set to `${VERSION}`), `USER root` for the build.
2. Build stage on the same base (`FROM <python-node> AS build`):
   ```dockerfile
   ENV npm_config_cache=/tmp/npm CI=true NODE_ENV=development
   RUN mkdir -p /tmp/src && \
       curl -fsSL "https://github.com/FoxxMD/multi-scrobbler/archive/refs/tags/${VERSION}.tar.gz" \
         | tar xz -C /tmp/src --strip-components=1
   WORKDIR /tmp/src
   RUN npm run install:parallel && npm run build:parallel
   RUN npm ci --omit=dev && npm cache clean --force
   ```
   Upstream scripts are kept by name, so the build matches upstream. Set `npm_config_cache` to `/tmp` (rules: caches never in `/config`). The `test:parallel` step can be run in the build stage, but it is optional; do not skip it silently (decide before implementing, UNVERIFIED test runtime).
3. Final stage (`FROM <python-node>` again, `ARG VERSION` re-declared because ARGs do not cross stages): `COPY --from=build` the runtime artifacts to `/app`: `package.json`, `src/backend`, `src/core`, `node_modules`, `dist` (if produced by `build:parallel`, UNVERIFIED path), and `docsite/build` only if the app serves it (UNVERIFIED).
4. License: `COPY --from=build /tmp/src/LICENSE /usr/share/licenses/multi-scrobbler/LICENSE`.
5. `chown -R apps:apps /app` and `chmod -R 755 /app`, as in `apps/budge`.
6. `ENV CONFIG_DIR=/config LOGS_DIR=/config/logs DATA_DIR=/config NODE_ENV=production IS_DOCKER=true COLORED_STD=true PORT=9078 TZ=Etc/UTC HOME=/config APP_VERSION=${VERSION}`.
7. Final stage:
   ```dockerfile
   USER apps
   COPY --chmod=0755 . /

   WORKDIR /app
   EXPOSE 9078
   VOLUME /config
   CMD ["/start.sh"]
   ```

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "multi-scrobbler"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=FoxxMD/multi-scrobbler versioning=semver
  default = "0.21.2"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/FoxxMD/multi-scrobbler"
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

Validate with `docker buildx bake --print` from `apps/multi-scrobbler/`. `VERSION` must equal the Dockerfile `ARG VERSION`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/FoxxMD/multi-scrobbler"
ports:
  - port: 9078
    protocol: tcp
    required: false
env:
  - name: PORT
    default: "9078"
    required: false
  - name: CONFIG_DIR
    default: "/config"
    required: false
  - name: LOGS_DIR
    default: "/config/logs"
    required: false
  - name: LOG_LEVEL
    default: "info"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

`LOG_LEVEL` default `info` is a guess (UNVERIFIED against `.env.example`); set it to the verified default before merge. `DATA_DIR` is set in the image to `/config` and is not user-facing. Dependencies: none.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

export CONFIG_DIR="${CONFIG_DIR:-/config}"
export LOGS_DIR="${LOGS_DIR:-/config/logs}"
mkdir -p "$CONFIG_DIR" "$LOGS_DIR"

cd /app
exec node /app/src/backend/index.ts
```

- Idempotent: creates directories only when missing; seeds nothing.
- Never writes under `/app`.
- Node 24 runs `.ts` directly (type stripping) as the upstream `CMD` does. Confirm on the chosen base (UNVERIFIED).
- `exec` so node is PID 1 under the handoff.
- The app binds to `PORT`; confirm it listens on all interfaces, not only `127.0.0.1` (UNVERIFIED, check in the run).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '9078'
filePaths:
- /app/src/backend/index.ts
- /app/node_modules
- /usr/share/licenses/multi-scrobbler/LICENSE
```

- The `settings.yaml` port has a `tcp` probe. An `http` probe is not added until the status code on `/` is known from a run (UNVERIFIED).
- `timeoutSeconds: 120` is a guess; check `apps/budge` for the family value.
- No required-env code path: the app starts without source credentials, so `filePaths` covers the runtime files.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/config` (config, tokens, state) | `/config` (`VOLUME`), kept as upstream |
| `/config/logs` | `/config/logs` via `LOGS_DIR` |
| npm cache during build | `/tmp` (`npm_config_cache`) |
| Runtime temp files | `/tmp` (ephemeral, allowed by the read-only rule) |
| Runtime code | `/app`, owned by `apps`, read-only at runtime |

Expectations reconciled with the draft: the chart forces UID 0 and `readOnlyRootFilesystem: false`. Upstream runs as UID 65532; this image runs as `apps` (`USER apps`). `/config` must be writable by `apps` on a fresh volume: the volume is created by Docker with the image's ownership, so `start.sh` or the image must create `/config` owned by `apps` (verify on an empty volume). Not privileged.

## 10. Risks, caveats and open questions

- Node version: `python-node:3.15.2` Node version NOT VERIFIED against the `>=24.14.0` engine. This is the main blocker.
- Upstream builds on `node:24-trixie-slim`; the Ubuntu-based python-node may not match native addon builds (`sharp`, `classic-level`) on arm64 (UNVERIFIED).
- The distroless upstream runs as UID 65532; the ContainerForge `apps` user is different. Check ownership of `/config` on a fresh volume (section 9).
- Each source (Spotify, Last.fm, Plex, Jellyfin and others) needs its own account or token; the image starts without them.
- `LOG_LEVEL` default unverified (section 6).
- Version drift: the draft pins `0.21.1`; this plan uses `0.21.2`. Re-check the engine and build scripts at `0.21.2` before implementing.
- No blocker beyond the Node version check. MIT license confirmed.

## 11. Build and test steps

```sh
cd apps/multi-scrobbler
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name multi-scrobbler-probe --read-only --tmpfs /tmp \
  -v multi-scrobbler-probe-config:/config multi-scrobbler:0.21.2
docker logs -f multi-scrobbler-probe
forgetool containers test --image multi-scrobbler:0.21.2 --config ./apps/multi-scrobbler/container-test.yaml
docker rm -f multi-scrobbler-probe; docker volume rm multi-scrobbler-probe-config
```

Expected readiness signal: the app's startup log line for the web server on port 9078 (UNVERIFIED exact wording; read it from the run). Confirm `/config` has the expected subdirectories after start and survives a restart. Test from outside the container (`-p 9078:9078`) to prove it is not bound to localhost.

## 12. PR checklist

- Branch `feat/add-multi-scrobbler`, commit and PR title `feat(multi-scrobbler): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections and checkboxes, check only applicable boxes.
- Notes section contains `🤖 This PR is AI generated.`
- Tell the user about the CLA: signed Contributor License Agreement required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows the status.
- Say in the PR what was not tested: the Node engine on the base, arm64 native addon build, the `0.21.2` engine and scripts, the http probe, and integrations with real sources.
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION`; no assertion weakened.
