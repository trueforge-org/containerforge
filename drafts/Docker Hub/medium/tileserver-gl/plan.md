# tileserver-gl — implementation plan
> Source: ./draft.md · Target: apps/tileserver-gl/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | **5.7.0** (GitHub release `v5.7.0`, published 2026-10-23; npm `latest` is 5.7.0). Matches the draft's chart pin. |
| Renovate | `datasource=npm depName=tileserver-gl` (the app is installed from npm). |
| License | BSD-2-Clause per npm metadata. GitHub license API reports `NOASSERTION`, so check the repo `LICENSE` file before setting `LICENSE` in bake. |
| Source URL | https://github.com/maptiler/tileserver-gl |
| Docs | https://tileserver.readthedocs.io/ |
| Download | `npm install tileserver-gl@5.7.0` (tarball https://registry.npmjs.org/tileserver-gl/-/tileserver-gl-5.7.0.tgz, 35 runtime deps, unpacked 11.3 MB). The npm registry, not a release asset, is the source. |
| Checksum source | npm integrity (`dist.integrity` in the packument) for the tarball. npm verifies it on install. |
| engines | `node ^20.19.0 || ^22.13.0 || 24` (npm 5.7.0). |
| bin | `tileserver-gl` → `src/main.js`. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/maptiler/tileserver-gl/master/Dockerfile: `FROM ubuntu:noble` (builder and final), Node 24 from NodeSource, `npm ci --omit=dev`, `npm rebuild canvas` from source, jemalloc via `LD_PRELOAD`, `xvfb`, `libglfw3`, `libuv1`, `libcairo2`, `libpango-1.0-0`, `libjpeg-turbo8`, `libgif7`, `libpng16-16t64`, `libopengl0`, `libcurl4`, `librsvg2-dev`, `libicu74`. `EXPOSE 8080`, `VOLUME /data`, `WORKDIR /data`, `USER node:node`, `ENTRYPOINT /usr/src/app/docker-entrypoint.sh`, no `CMD`, `HEALTHCHECK node /usr/src/app/src/healthcheck.js`. |
| Env | `TILESERVER_GL_ALLOWED_HOSTS` (default `*`, README). Upstream also sets `NODE_ENV=production`, `LD_PRELOAD`, `MALLOC_CONF`, `CHOKIDAR_*` (dev file watching, not needed). |
| Ports | 8080 (`EXPOSE 8080`, README examples). The README states no default port. |
| Data path | `/data` upstream (`VOLUME`, `WORKDIR`, README `-v $(pwd):/data`). Maps to `/config` in ContainerForge. |
| CLI | `src/main.js` at `v5.7.0` (raw file, checked) defines `--file`, `--mbtiles`, `-c/--config`, `-b/--bind <address>`, `-p/--port` (default 8080), `-C/--no-cors`, `-u/--public_url`, `-V/--verbose [level]`, `--fetch-timeout`, `-s/--silent`, `-l/--log_file`. |
| Entrypoint and health | Upstream `docker-entrypoint.sh`: removes `/tmp/.X99-lock`, exports `DISPLAY=:99`, starts `Xvfb :99 -nolisten unix` in the background, then `exec node /usr/src/app/ "$@"`. `src/healthcheck.js` requests `http://localhost:8080/health` and expects 200. |
| Dependencies | none. |

Difference from draft: the draft's "copy-from" reference (`maptiler/tileserver-gl:v5.7.0`) is not needed. The npm install is the source. The draft's base choice (python-node) is kept because it provides Node; confirm the Node major in the base meets `engines`.

## 2. Target layout

- `apps/tileserver-gl/Dockerfile`
- `apps/tileserver-gl/docker-bake.hcl`
- `apps/tileserver-gl/settings.yaml`
- `apps/tileserver-gl/container-test.yaml`
- `apps/tileserver-gl/start.sh`

No `defaults/` or `etc/` (the app creates no seed file, and the map data is user-supplied). No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5`

Why: it provides Node (tileserver-gl is a Node package), and `apps/budge` uses the same base for an npm-built app. Closest sibling: `apps/budge` (npm install in `/app`, `USER apps`, `/config` volume), `apps/changedetection` (python-node with Playwright).

UNVERIFIED: the Node major in `python-node:3.15.2`. Check `node -v` in the base. It must satisfy `^20.19.0 || ^22.13.0 || 24`. If it does not, use `ghcr.io/trueforge-org/ubuntu` and install Node 24 (as upstream does), and record the change in the PR.

## 4. Dockerfile

1. `ARG VERSION` (`5.7.0`), `USER root`.
2. Build dependencies (install, then purge in the same layer):
   - `build-essential pkg-config libcairo2-dev libpango1.0-dev libjpeg-dev libgif-dev librsvg2-dev libpng-dev libcurl4-openssl-dev libicu-dev python3`
   - Only needed if `canvas` builds from source. Prefer the prebuilt canvas binary; add the build tools only if `npm install` fails for the arch (see section 10).
3. Runtime libraries (kept): `libcairo2 libpango-1.0-0 libjpeg-turbo8 libgif7 libpng16-16t64 librsvg2-2 libcurl4 libuv1 libglfw3 libopengl0 xvfb ca-certificates`. Package names are noble names (UNVERIFIED on ubuntu 26.04: `libpng16-16t64`, `libicu74`, `librsvg2-dev` may differ). Check with `apt-cache policy` in the build and adjust. `xvfb` is needed: the upstream entrypoint starts Xvfb on `:99` for raster rendering (see section 7).
4. Install the app into `/app/tileserver-gl`:
   - `mkdir -p /app/tileserver-gl && cd /app/tileserver-gl`
   - `npm init -y >/dev/null` then `npm install --omit=dev --no-audit --no-fund tileserver-gl@${VERSION}`. Use `npm_config_cache=/tmp/npm` so the cache is not left under `/root` or `/config`.
   - Purge build dependencies, `rm -rf /tmp/* $HOME/.npm /var/lib/apt/lists/*`.
5. Confirm the CLI: `node /app/tileserver-gl/node_modules/tileserver-gl/src/main.js --help` during the build and compare with the flags listed in section 1.
6. License: install the package LICENSE to `/usr/share/licenses/tileserver-gl/LICENSE` (from `node_modules/tileserver-gl/LICENSE`, if present; UNVERIFIED that the npm tarball ships it).
7. Permissions: `chown -R root:root /app/tileserver-gl && chmod -R 755 /app/tileserver-gl`.
8. `ENV` (only real vars): `NODE_ENV=production`, `TILESERVER_GL_ALLOWED_HOSTS="*"`. Optional jemalloc (`LD_PRELOAD`, `MALLOC_CONF`) only if `libjemalloc2` is installed; skip otherwise.
9. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 8080
VOLUME /config
WORKDIR /config
```

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "tileserver-gl" }
variable "VERSION" {
  // renovate: datasource=npm depName=tileserver-gl
  default = "5.7.0"
}
variable "LICENSE" { default = "BSD-2-Clause" }
variable "SOURCE" { default = "https://github.com/maptiler/tileserver-gl" }
```

Four standard targets and the default group copied from `apps/budge/docker-bake.hcl`. `LICENSE` must match the software: confirm the repo's `LICENSE` file before merge, because GitHub reports `NOASSERTION`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/maptiler/tileserver-gl"
ports:
  - port: 8080
    protocol: tcp
    required: false
env:
  - name: TILESERVER_GL_ALLOWED_HOSTS
    default: "*"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

No dependencies. Only `TILESERVER_GL_ALLOWED_HOSTS` is documented by upstream as read by the app. Do not add `PORT`: no upstream PORT var exists (section 1). Port is set by the CLI flag in `start.sh`, so `settings.yaml` must match the flag used.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config

# Map data, styles and fonts live in /config. Seed nothing: the server starts
# without maps and the user supplies them.
cd /config

export TILESERVER_GL_ALLOWED_HOSTS="${TILESERVER_GL_ALLOWED_HOSTS:-*}"

# virtual display for rendering, as upstream docker-entrypoint.sh does
export DISPLAY=:99
rm -f /tmp/.X99-lock
Xvfb "${DISPLAY}" -nolisten unix >/dev/null 2>&1 &

exec node /app/tileserver-gl/node_modules/tileserver-gl/src/main.js \
  --bind 0.0.0.0 \
  --port 8080
```

Notes:
- Bind all interfaces: `--bind 0.0.0.0` and `--port 8080` are real flags (section 1). Verify from outside the container in the build test.
- Idempotent: no seeding, no writes to `/app`.
- `/config` holds styles, fonts and mbtiles, supplied by the user. The start must succeed with an empty `/config` (no maps); the server then serves an empty tile index.
- `exec` the final node process so signals propagate.
- Caches go to `/tmp` (`npm_config_cache` is build-time only). Do not write to `/config`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 180
tcp:
- port: '8080'
http:
- port: '8080'
  path: /health
filePaths:
- /app/tileserver-gl/node_modules/tileserver-gl/src/main.js
- /usr/share/licenses/tileserver-gl/LICENSE
```

- Test runs with no env vars and an empty `/config`: this is the normal start, so no required-env path is needed.
- The HTTP status of `/` for an empty `/config` is UNVERIFIED. Upstream's own healthcheck uses `/health` (expects 200), so the probe above uses `path: /health`; confirm with `curl -i` in the build test. Do not weaken the probe.
- Drop the `LICENSE` filePath if the npm tarball does not ship it (section 4 step 6).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/data` (`VOLUME`, `WORKDIR`; styles, fonts, mbtiles) | `/config`. |
| npm cache and install scratch | `/tmp` (`npm_config_cache=/tmp/npm`) at build time only. |
| Node and jemalloc runtime | read-only `/app`; no runtime writes expected. |
| Xvfb (`xvfb`) lock | `/tmp/.X99-lock` (upstream removes it before start; `start.sh` does the same; `-nolisten unix` avoids a socket dir). |
| `CHOKIDAR_*` dev watch | not needed; not set. |

Draft's security expectations: chart runs as UID 568, read-only rootfs true, not privileged. Compatible with `--read-only --tmpfs /tmp` if no write path is found in the build test. Upstream runs as `node:node`; ContainerForge runs as `apps`.

## 10. Risks, caveats and open questions

- Node version: the python-node base's Node major must meet `^20.19 || ^22.13 || 24` (UNVERIFIED, section 3). If it fails, switch to `ubuntu` and install Node 24.
- `canvas` native module: prebuilt binaries cover most arches. If `npm install` builds from source and fails on arm64, add the build packages (section 4 step 2) only for that case.
- Empty-`/config` start: no maps means the viewer and tile index are empty. Confirm the server stays up and the probe passes with no data.
- CLI flags: verified from `src/main.js` (section 1); re-check with `--help` in the build (section 4 step 5).
- License: npm says BSD-2-Clause, GitHub says NOASSERTION. Confirm the repo LICENSE file.
- Draft caveats (inferred, kept): map rendering is CPU and RAM heavy; the chart pins v5.7.0, so newer releases may change style and font handling.
- Blockers: none confirmed (not musl, no GPU, no privileged, no DB).

## 11. Build and test steps

```sh
cd apps/tileserver-gl
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name tileserver-gl-probe --read-only --tmpfs /tmp \
  -v tileserver-gl-probe-config:/config tileserver-gl:5.7.0
docker logs -f tileserver-gl-probe
forgetool containers test --image tileserver-gl:5.7.0 --config ./apps/tileserver-gl/container-test.yaml
docker rm -f tileserver-gl-probe; docker volume rm tileserver-gl-probe-config
```

Readiness signals: the server logs its listening address (UNVERIFIED wording, check the first run), the process stays up, and `curl -i http://localhost:8080/` returns the expected status. Also curl from outside the container (`-p 8080:8080`).

## 12. PR checklist

- Branch `feat/add-tileserver-gl`, commit and PR title `feat(tileserver-gl): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections, check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: contributions need a signed CLA (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows status.
- Untested to state honestly: the Node version in the base, the Xvfb start, the empty-map HTTP status, the canvas build on arm64, and the license file.
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION`; no assertion weakened.
