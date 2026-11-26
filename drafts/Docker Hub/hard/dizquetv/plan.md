# dizquetv — implementation plan
> Source: ./draft.md · Target: apps/dizquetv/ · Difficulty: hard (draft) / medium in practice · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | `1.7.0` (draft tag `1.7.0`; same). Latest GitHub release feed: `1.7.0` (2025-12-15) and a non-semver tag `20251201-0`. |
| Renovate | `datasource=github-releases depName=vexorian/dizquetv versioning=loose` (the repo also has date tags like `20251201-0`, so `loose`, not `semver`). |
| License | `Zlib` (SPDX; LICENSE text starts "zlib License", Copyright 2020 Dan Ferguson, Victor Hugo Soliz Kuncar; package.json `"license": "Zlib"`). |
| Source URL | https://github.com/vexorian/dizquetv |
| Release assets | `dizquetv-linux-x64`, `dizquetv-macos-x64`, `dizquetv-win-x64.exe`, `dizquetv-win-x86.exe`. No arm64 asset, so the draft's "arm64 release link" does not exist. |
| Source tarball (both arches) | `https://github.com/vexorian/dizquetv/archive/refs/tags/${VERSION}.tar.gz` |
| Checksum | None published. UNVERIFIED: compute the tarball sha256 when implementing and pin it as `ARG SOURCE_SHA256`, or accept the tag download. |
| npm package | The draft says "dizquetv 1.7.0 npm package". There is none: `registry.npmjs.org/dizquetv` returns Not Found. Build from the source tarball instead. |
| Upstream Dockerfile | `vexorian/dizquetv/Dockerfile` reviewed: stage 1 `node:12.18-alpine3.12` (`npm install`, `npm run build`, nexe, `make_dist.sh linuxonly`), stage 2 `jrottenberg/ffmpeg:4.3-ubuntu1804`, `EXPOSE 8000`, `ENTRYPOINT ./dizquetv`, WORKDIR `/home/node/app`, no ENV, no VOLUME. |
| Runtime env (from `index.js` / `helperFuncs.js`) | `PORT` (default `8000`), `DATABASE` (data dir, default `./.dizquetv` relative to cwd). Also CLI flags `-p/--port` and `-d/--database`. |
| Data layout | Under `$DATABASE`: `images/`, `channels/`, `filler/`, `custom-shows/`, `cache/`, `cache/images/`, plus db json files. The app creates these itself when missing. |
| Build | `npm run build` = `browserify ./web/app.js -o ./web/public/bundle.js` (needs devDependency browserify). `npm start` = `node index.js`. Needs `web/`, `resources/`, `locales/` at runtime (make_dist copies them). |
| ffmpeg | Needed at runtime. Ubuntu 26.04 (resolute) `ffmpeg` = `7:8.0.1-3ubuntu2` (universe). |

## 2. Target layout

```
apps/dizquetv/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```
No `defaults/`, `etc/`, `health/` needed (the app seeds its own data dir). No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

```
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454
```
Why: the ubuntu base already ships Node (`NODE_VERSION` 26.x in `apps/ubuntu/docker-bake.hcl`), yarn, tini, curl, tar. The draft suggested python-node; that base is not needed because there is no Python. The prebuilt nexe binary is x64-only and bundles Node 12, so building from source on the base's Node supports amd64 and arm64. Closest sibling: `apps/overseerr` / `apps/pairdrop` (Node source builds on ubuntu); layout from `apps/adguardhome-sync`.

## 4. Dockerfile

1. `FROM` as above; `ARG VERSION`, `ARG TARGETARCH` (arch not needed for a source build, keep `TARGETARCH` unused only if lint requires; otherwise omit).
2. `USER root`.
3. `ENV HOME=/config NPM_CONFIG_CACHE=/tmp/npm PORT=8000 DATABASE=/config/.dizquetv`.
4. One `RUN`:
   - `apt-get update && apt-get install -y --no-install-recommends ffmpeg=7:8.0.1-3ubuntu2` (pinned; check against the `apt-cache policy` result at build time, it is a runtime dep, not tied to `VERSION`).
   - `mkdir -p /app/dizquetv && curl -fsSL -o /tmp/dizquetv.tar.gz "https://github.com/vexorian/dizquetv/archive/refs/tags/${VERSION}.tar.gz"` then (if pinned) `echo "${SOURCE_SHA256}  /tmp/dizquetv.tar.gz" | sha256sum -c -`.
   - `tar xzf /tmp/dizquetv.tar.gz -C /app/dizquetv --strip-components=1`.
   - `cd /app/dizquetv && npm install --no-audit --no-fund && npm run build && npm prune --omit=dev` (browserify is a devDependency, so prune after the build).
   - License: `install -d /usr/share/licenses/dizquetv && cp /app/dizquetv/LICENSE /usr/share/licenses/dizquetv/`.
   - `chown -R apps:apps /app && chmod -R 755 /app`, then `rm -rf /tmp/* /var/lib/apt/lists/*`.
5. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 8000`, `VOLUME /config`, `WORKDIR /config`.

Notes: do not compile with nexe or babel (`npm run compile` is only for nexe). Run the plain sources with `node index.js`.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" { default = "dizquetv" }

variable "VERSION" {
  // renovate: datasource=github-releases depName=vexorian/dizquetv versioning=loose
  default = "1.7.0"
}

variable "LICENSE" { default = "Zlib" }
variable "SOURCE" { default = "https://github.com/vexorian/dizquetv" }
```
Plus `group "default"`, `target "image"` (args `VERSION`, labels source/licenses), `target "image-local"` (`type=docker`, tag `${APP}:${VERSION}`), `target "image-all"` (linux/amd64, linux/arm64), copied from `apps/adguardhome-sync/docker-bake.hcl`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/vexorian/dizquetv"
ports:
  - port: 8000
    protocol: tcp
    required: true
env:
  - name: PORT
    default: "8000"
    required: false
  - name: DATABASE
    default: "/config/.dizquetv"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```
Dependencies: none (Plex server is external, not a ContainerForge app). `TZ` is read by Node/ffmpeg via tzdata in the base.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -e
export DATABASE="${DATABASE:-/config/.dizquetv}"
export PORT="${PORT:-8000}"
mkdir -p "${DATABASE}"
cd /app/dizquetv
exec node index.js
```
Idempotent; the app creates `images/ channels/ filler/ custom-shows/ cache/` on first run. It binds all interfaces by default: index.js calls `app.listen(process.env.PORT)` with no host argument (verified in source); still confirm with a connection from outside during the run test. No writes to `/app`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

tcp:
- port: '8000'
http:
- port: '8000'
  path: /
filePaths:
- /app/dizquetv/index.js
- /app/dizquetv/web/public/bundle.js
- /usr/bin/ffmpeg
- /usr/share/licenses/dizquetv/LICENSE
```
Check the exact `filePaths` key name against a sibling `container-test.yaml` that uses it before writing. `timeoutSeconds`: copy the value from `apps/overseerr/container-test.yaml` (Node sibling).

## 9. Rootless and read-only-rootfs adaptations

- Upstream writes only to `$DATABASE` (relative `./.dizquetv`). Remap to `/config/.dizquetv` (also what a TrueCharts migration should mount: old path `/home/node/app/.dizquetv`).
- `HOME=/config`, npm cache to `/tmp/npm` (runtime does not run npm).
- i18next backend is configured with `addPath` into `/app/dizquetv/locales/server/`; it only writes when `saveMissing` is on. UNVERIFIED: confirm no write attempt in logs under `--read-only`.
- Draft security: chart uses default UID 568 and read-only rootfs "possible"; this plan satisfies both (`USER apps`, UID 568). Extra persistence `/home/node/app/.dizquetv` is replaced by `/config/.dizquetv`.
- Not privileged. The NVIDIA variant is out of scope (see section 10).

## 10. Risks, caveats and open questions

- Upstream builds against Node 12 (nexe 12.16.2) and old deps (`request`, `diskdb`, `node-ssdp`). Running them on Node 26 is UNVERIFIED; if `npm install` or startup fails, do not install a second Node (base reuse rule); patch or bump the failing dependency in the Dockerfile build step, or report it as a blocker. Decide after the first build.
- Source build instead of the release binary: no checksum published; tarball checksum must be pinned by us.
- GPU/NVENC variant (`1.7.0-nvidia`, `jrottenberg/ffmpeg:4.3-nvidia1804`) is not reproduced; Ubuntu `ffmpeg` is CPU/VAAPI only. Document this.
- ffmpeg 8.0 vs upstream requirement "FFMPEG 4.2.3 or later" (wiki; development tested 4.2.4; upstream Docker base 4.3): dizqueTV's ffmpeg arguments may break; the UI exposes an ffmpeg path and settings. UNVERIFIED.
- Renovate cannot bump the apt `ffmpeg` pin; it needs a manual refresh when Ubuntu updates it.
- Draft said "hard" because of GPU; the CPU image is simple, so GPU is a documented non-goal.

## 11. Build and test steps

```sh
cd apps/dizquetv
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name dizquetv-probe --read-only --tmpfs /tmp \
  -v dizquetv-probe-config:/config dizquetv:1.7.0
docker logs -f dizquetv-probe      # expect the express "listening" / dizqueTV start line and port 8000 open
forgetool containers test --image dizquetv:1.7.0 --config ./apps/dizquetv/container-test.yaml
docker rm -f dizquetv-probe; docker volume rm dizquetv-probe-config
```
Expected readiness: container stays running, port 8000 answers `GET /` with the web UI, `/config/.dizquetv/channels` created. Try arm64 only if amd64 passes.

## 12. PR checklist

- Branch `feat/add-dizquetv`; commit and PR title `feat(dizquetv): add new container`; target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`; put `🤖 This PR is AI generated.` in Notes (no "Generated with" line).
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it).
- Check only boxes that apply. Untested until run: Node 26 compatibility, arm64 build, non-root bind on all interfaces, read-only rootfs behavior, ffmpeg 8 streaming against a real Plex.
