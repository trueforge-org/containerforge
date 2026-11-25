# pigallery2 — implementation plan
> Source: ./draft.md · Target: apps/pigallery2/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Latest release `3.8.0`, published 2026-11-18. Source: https://api.github.com/repos/bpatrik/pigallery2/releases/latest. Draft used the same 3.8.0 download link. |
| Renovate | `datasource=github-releases depName=bpatrik/pigallery2 versioning=semver` (standard form; renovate config not fetched) |
| License | MIT (GitHub SPDX `MIT`). Source: https://api.github.com/repos/bpatrik/pigallery2 |
| Source URL | https://github.com/bpatrik/pigallery2 |
| Download (amd64 and arm64) | `https://github.com/bpatrik/pigallery2/releases/download/3.8.0/pigallery2-release.zip` (13177184 bytes). One zip for both architectures; native modules must match the architecture (see section 10). |
| Checksum source | GitHub asset digest from the API: `sha256:cbfd61b898feee112004ffcf00ef9ed2488d56a98c8863c2f3168d048c0e618c`. Verify with `echo "<sha> *file" \| sha256sum -c -`. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/bpatrik/pigallery2/43f348a254142eea521138b783e3b8df9fe547c8/docker/alpine/Dockerfile.build (summary only; verbatim fetch was refused). Both stages `node:26-alpine3.24`; builder sets `SHARP_FORCE_GLOBAL_LIBVIPS=1`, installs libvips, libheif, libraw, libjpeg-turbo, libwebp, gcc, make, python3; copies `pigallery2-release` to `/app`; installs `node-addon-api` and `node-gyp`, prunes dev deps; main stage: `WORKDIR /app`, `NODE_ENV=production`, `PI_DOCKER=true`, data paths under `/app/data`, `EXPOSE 80`, ffmpeg, `HEALTHCHECK` on `http://127.0.0.1:80/heartbeat`, `ENTRYPOINT node --expose-gc ./src/backend/index` with config `/app/data/config/config.json`. No `USER`, no `VOLUME`. |
| Docker Hub | `bpatrik/pigallery2:latest` last updated 2026-11-23, arches amd64 and arm64. Source: https://hub.docker.com/v2/repositories/bpatrik/pigallery2/tags/latest |
| copy-from | `no` for both arches: the upstream image is alpine (musl), which does not run on glibc Ubuntu. Build from the zip instead. |
| Port | Upstream listens on 80 (EXPOSE and healthcheck). Non-root cannot bind 80 in ContainerForge, so the runtime port must be changed through config (UNVERIFIED: the config key or env var name, since the source was not read). |
| Env vars | Upstream sets `NODE_ENV=production`, `PI_DOCKER=true`, and DB, media, tmp and extensions paths under `/app/data`. The names of the path variables are UNVERIFIED (not shown in the fetched summary). Do not invent names; read them from the source in the build step. |
| Chart paths | `/app/data/db`, `/app/data/images/`, `/app/data/tmp` (chart pvc defaults; draft). |
| Dependencies | None (sqlite embedded). |

## 2. Target layout

- `apps/pigallery2/Dockerfile`
- `apps/pigallery2/docker-bake.hcl`
- `apps/pigallery2/settings.yaml`
- `apps/pigallery2/container-test.yaml`
- `apps/pigallery2/start.sh` (seeds `/config` and starts node; see section 7)
- `apps/pigallery2/defaults/config.json` (only if a default config must be seeded into `/config`; reason: upstream reads a config file from `/app/data/config/config.json`, so the seed lives in `defaults/`)

No `root/`, no `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5` for the final stage and the build stage. Reason: Node.js app with native modules, so the python-node base provides node and npm. Closest siblings: `apps/changedetection` and `apps/budge` (python-node). UNVERIFIED: the Node major version shipped in the python-node base. Upstream uses Node 26, so check that the base's node satisfies the release's `engines` field before building.

## 4. Dockerfile

1. Build stage `FROM <python-node digest> AS build`, `ARG VERSION`, `USER root`.
2. `apt-get install -y --no-install-recommends unzip build-essential python3 libvips-dev libheif-dev libraw-dev ffmpeg` (names are the Ubuntu equivalents of the alpine packages; check each against the ubuntu 26.04 archive and pin the versions that are not in the base). Skip packages already in the base (`curl`, `ca-certificates` are present). `rm -rf /var/lib/apt/lists/*`.
3. `ENV NPM_CONFIG_CACHE=/tmp/npm SHARP_FORCE_GLOBAL_LIBVIPS=1 npm_config_build_from_source=true`.
4. `curl -fL -o /tmp/pigallery2-release.zip "https://github.com/bpatrik/pigallery2/releases/download/${VERSION}/pigallery2-release.zip"`, then `echo "<sha256> /tmp/pigallery2-release.zip" | sha256sum -c -`, then `unzip -q /tmp/pigallery2-release.zip -d /tmp/src`.
5. `cd /tmp/src && npm ci --omit=dev` (or `npm install --omit=dev` if no lockfile; UNVERIFIED: whether the zip has a lockfile). This rebuilds native modules (sharp, sqlite) for the build architecture (glibc, amd64 or arm64), so the zip's own `node_modules` is not trusted.
6. Final stage `FROM <python-node digest>`, `USER root`, `apt-get install -y --no-install-recommends libvips42 ffmpeg` (runtime libs only; pin versions), `rm -rf /var/lib/apt/lists/*`.
7. `COPY --from=build /tmp/src /app/pigallery2`, `chown -R apps:apps /app && chmod -R 755 /app`.
8. License: `COPY --from=build /tmp/src/LICENSE /usr/share/licenses/pigallery2/LICENSE` (UNVERIFIED: the LICENSE file is in the zip; the API reports MIT).
9. `ENV NODE_ENV=production PI_DOCKER=true` plus the path variables the source reads (names UNVERIFIED, see section 1).
10. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

WORKDIR /app/pigallery2
EXPOSE 8080
VOLUME /config
```

    Port 8080 is used instead of the upstream 80 because the app runs as `apps`.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "pigallery2"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=bpatrik/pigallery2 versioning=semver
  default = "3.8.0"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/bpatrik/pigallery2"
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

Validate with `docker buildx bake --print` from `apps/pigallery2`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/bpatrik/pigallery2"
ports:
  - port: 8080
    protocol: tcp
    required: false
env:
  - name: NODE_ENV
    default: "production"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

Add the upstream data-path variables only after they are confirmed in the source (UNVERIFIED). Draft's image dirs (`/app/data/images`, `/app/data/tmp`) map to `/config/...` and `/tmp` respectively (see section 9).

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config/config /config/db /config/images
if [ ! -s /config/config/config.json ]; then
    cp /defaults/config.json /config/config/config.json
fi

cd /app/pigallery2
exec node --expose-gc ./src/backend/index
```

`/config` is seeded only when missing. The config file path, the DB and image paths, and the port key inside `defaults/config.json` are UNVERIFIED until the source is read. `exec` keeps signals. No write to `/app`. Temp files go to `/tmp`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '8080'
http:
- port: '8080'
  path: /
filePaths:
- /app/pigallery2/src/backend/index.js
- /usr/share/licenses/pigallery2/LICENSE
```

Port 8080 has both a `tcp` and an `http` probe. `timeoutSeconds: 120` is a starting value; the sibling `apps/changedetection` uses 180, so raise it to 180 if startup is slow. The file path `index.js` is UNVERIFIED: the upstream entrypoint is `./src/backend/index`, so the built file may be `.js` or compiled. Check after the build.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/app/data/config` | `/config/config` (seeded by `start.sh`) |
| `/app/data/db` (sqlite) | `/config/db` (must be writable and persistent) |
| `/app/data/images` (thumbnails) | `/config/images` (persistent) |
| `/app/data/tmp` (chart PVC `tmp`) | `/tmp` (ephemeral, per the rules; chart's own `tmp` mount is not the common `/tmp`) |
| Node and npm caches | `/tmp` (`NPM_CONFIG_CACHE` in build stage only) |

Draft security expectations, reconciled: the chart runs as UID 0 with `readOnlyRootFilesystem: false`. This image runs as `apps` and must work with `--read-only --tmpfs /tmp`. Not privileged. The alpine-vs-debian variant question from the draft is moot: this plan uses the ubuntu-based python-node base, not alpine.

## 10. Risks, caveats and open questions

- **Native modules from the zip.** The release zip may contain `node_modules` built for musl or for another arch. The plan rebuilds them with `npm ci` on glibc. If `npm ci` fails on arm64, record it as arm64-specific and stop per the protocol.
- **Port 80 to 8080.** The upstream image exposes 80. Changing it requires a config key or env var that is not confirmed yet (UNVERIFIED). If no supported setting exists, the image must run behind the nginx sibling instead, which changes the plan.
- **Thumbnail CPU and RAM** on large libraries (draft caveat, inferred).
- **Upstream data path env names** are not confirmed; without them, the paths cannot be remapped to `/config` safely.
- **Node version** in the python-node base versus upstream Node 26 is UNVERIFIED.
- **ffmpeg** is large; keep it only if the app needs it for video thumbnails (UNVERIFIED).
- Not blocking: MIT license, no database, not privileged, no GPU. arm64 is listed upstream but untested here.

## 11. Build and test steps

```sh
cd apps/pigallery2
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name pigallery2-probe --read-only --tmpfs /tmp \
  -v pigallery2-probe-config:/config pigallery2:3.8.0
docker logs -f pigallery2-probe
forgetool containers test --image pigallery2:3.8.0 --config ./apps/pigallery2/container-test.yaml
docker rm -f pigallery2-probe; docker volume rm pigallery2-probe-config
```

Expected readiness: a Node start line and a listening line on the configured port, the process stays up, `/heartbeat` (or `/`) returns 200 on 8080. Restart with the same `/config` volume and confirm the DB survives. Also curl from outside the container (`-p 8080:8080`) to prove it is not bound to localhost.

## 12. PR checklist

- Branch `feat/add-pigallery2`, commit and PR title `feat(pigallery2): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections, check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows the status.
- Untested to state honestly: the source build on both architectures, the config and port remap, the upstream env names, and the runtime on `--read-only`.
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION`; no assertion weakened.
