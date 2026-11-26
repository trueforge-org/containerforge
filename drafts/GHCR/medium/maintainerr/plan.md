# maintainerr — implementation plan
> Source: ./draft.md · Target: apps/maintainerr/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Latest stable `v3.33.0` (published 2026-11-20). The TrueCharts chart pins `ghcr.io/maintainerr/maintainerr:3.32.0`. This plan builds `3.33.0`; see section 10. Source: https://api.github.com/repos/Maintainerr/Maintainerr/releases/latest |
| Draft vs verified | Draft says the image is a Node/TypeScript build run with node. Confirmed: upstream `Dockerfile` (commit `e6327bbb68b9`) has a yarn + turbo builder stage and a runner that runs `node dist/main` via `docker/start.sh`. Upstream base is `node:26.13.0-alpine` (musl), which is not usable on ContainerForge. |
| Renovate | `datasource=github-releases depName=Maintainerr/Maintainerr versioning=semver` (source tag; same pattern as `apps/changedetection`) |
| License | MIT (GitHub API `license.spdx_id` = `MIT`): https://api.github.com/repos/Maintainerr/Maintainerr/license |
| Source URL | https://github.com/Maintainerr/Maintainerr |
| Download | Source archive `https://github.com/Maintainerr/Maintainerr/archive/refs/tags/v${VERSION}.tar.gz`. No release assets exist on `v3.32.0` or `v3.33.0` (GitHub API assets list empty). No npm package (`registry.npmjs.org/maintainerr` returns Not Found). So a source build is required on both amd64 and arm64. |
| Checksum source | None published by upstream. The tag archive is content-addressed by tag only: UNVERIFIED that the tag is immutable. Record the tag and the commit SHA in the build log. |
| Upstream Dockerfile reviewed | `Dockerfile`, `docker/start.sh`, `docker/healthcheck.sh` at `e6327bbb68b9` (raw.githubusercontent.com). |
| Port | `UI_PORT`, default `6246`, bound to `UI_HOSTNAME` (default `0.0.0.0`). Upstream `EXPOSE 6246`. |
| Env vars (real, from upstream files) | `NODE_ENV=production`, `DEBUG=false`, `UI_PORT=6246`, `UI_HOSTNAME=0.0.0.0`, `DATA_DIR=/opt/data`, `BASE_PATH` (empty), `VERSION_TAG=develop`, `GIT_SHA`, `UV_USE_IO_URING=0` (libuv workaround). Other app env vars: UNVERIFIED, code search needs auth (see section 10). |
| Data path | `DATA_DIR` (default `/opt/data`). `start.sh` stages the UI into `${DATA_DIR}/ui` on every boot and rewrites `/__PATH_PREFIX__` there. Logs go to `${DATA_DIR}/logs` (upstream creates it, `mkdir -m 777 /opt/data/logs`). |
| Health | `docker/healthcheck.sh` runs `curl -fsS http://127.0.0.1:${UI_PORT}${PATH_PREFIX}/api/health/ready` (200 when the DB answers). |
| Process | `start.sh` runs `cd /opt/app/apps/server && exec node dist/main`, after `npm_package_version` is read from `package.json`. |

## 2. Target layout

- `apps/maintainerr/Dockerfile`
- `apps/maintainerr/docker-bake.hcl`
- `apps/maintainerr/settings.yaml`
- `apps/maintainerr/container-test.yaml`
- `apps/maintainerr/start.sh` (replaces upstream `docker/start.sh`, `docker/healthcheck.sh` is not needed: ContainerForge health comes from `container-test.yaml`)

No `defaults/`, `etc/` or `health/` needed (the app creates its database and logs on first start). No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base). `include/.dockerignore` allows `start.sh` and `container-test.yaml`, so the `COPY --chmod=0755 . /` line picks up both.

## 3. Base image

`FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5` for both the build stage and the final stage. Node is required at build (yarn, turbo, node-canvas) and at runtime (`node dist/main`). The porter table maps "Node" to `ubuntu`, but ubuntu does not ship node; `python-node` is the only ContainerForge base with node, and it is what `apps/changedetection` and `apps/budge` use for node work. Node version inside the base is UNVERIFIED (budge's comment suggests Node 24). Upstream needs the node engine declared in its `package.json`: check with `node -v` in the base before the first build (section 11). Closest siblings: `apps/changedetection` (python-node, build deps, `USER apps`), `apps/adguardhome-sync` (single-binary pattern).

## 4. Dockerfile

Two stages on the same base (`AS build`, then final). Keep `USER root` only for apt steps.

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Build stage: `apt-get install -y --no-install-recommends build-essential pkg-config libcairo2-dev libpango1.0-dev libpixman-1-dev` (Ubuntu names of upstream's `build-base python3 pkgconfig cairo-dev pango-dev pixman-dev`). Check which are already in the base before adding (dockerfile rule: do not reinstall base packages). Package names on ubuntu 26.04 are UNVERIFIED until the bake/build step.
3. Build-stage environment: `ENV YARN_ENABLE_TELEMETRY=0 CI=1 npm_config_cache=/tmp/npm COREPACK_HOME=/tmp/corepack` (all caches under `/tmp`).
4. Fetch source: `curl -fsSL "https://github.com/Maintainerr/Maintainerr/archive/refs/tags/v${VERSION}.tar.gz" | tar xz -C /tmp/src --strip-components=1`. Use `/tmp/src`, never `/app`.
5. Enable yarn 4 through corepack (`corepack enable` in the build stage; `corepack install` reads `.yarnrc.yml`/`yarn.lock`), then `yarn install --network-timeout 99999999`, and write `apps/ui/.env` with `VITE_BASE_PATH=/__PATH_PREFIX__` exactly as upstream does.
6. `yarn turbo build`, then `yarn workspaces focus --all --production`. Create empty `packages/contracts/node_modules` and `apps/server/node_modules` as upstream does.
7. Final stage: `WORKDIR /app/maintainerr`. Copy with `COPY --from=build --chmod=0755 --chown=apps:apps` from `/tmp/src`:
   - `node_modules` -> `./node_modules`
   - `apps/server/dist`, `apps/server/package.json`, `apps/server/node_modules`, `apps/server/assets` (fonts) -> `./apps/server/`; `apps/ui/dist` -> `./apps/server/dist/ui` (the bundle `start.sh` copies).
   - `packages/contracts/dist`, `packages/contracts/package.json`, `packages/contracts/node_modules` -> `./packages/contracts/`.
   - License: `COPY --from=build /tmp/src/LICENSE /usr/share/licenses/maintainerr/LICENSE`.
8. Runtime apt, as root: `apt-get install -y --no-install-recommends libcairo2 libpango-1.0-0 libpixman-1-0 curl` (curl only if the base lacks it; check first). Clean `/var/lib/apt/lists/*`.
9. Remove npm from the final image to match upstream (`rm -rf /usr/local/lib/node_modules/npm /usr/local/bin/npm /usr/local/bin/npx`), only if the base's node layout matches; otherwise skip and note it.
10. `start.sh`: `COPY` puts it at `/start.sh` through `COPY --chmod=0755 . /`. Keep it there and reference it as `/start.sh` (no extra copy of `healthcheck.sh`).
11. Tail:

```dockerfile
ENV NODE_ENV=production \
    DEBUG=false \
    UI_PORT=6246 \
    UI_HOSTNAME=0.0.0.0 \
    DATA_DIR=/config \
    BASE_PATH="" \
    UV_USE_IO_URING=0
USER apps
COPY --chmod=0755 . /
EXPOSE 6246
VOLUME /config
WORKDIR /app/maintainerr
```

No `ENTRYPOINT` override: the `ubuntu` base already sets `ENTRYPOINT ["/usr/bin/tini", "--", "/entrypoint.sh"]` (apps/ubuntu/Dockerfile), which hands over to `/start.sh`. UNVERIFIED: confirm in `apps/ubuntu` entrypoint how `/start.sh` is invoked.

`DATA_DIR=/config` replaces upstream `/opt/data` (ContainerForge persistence model). `start.sh` keeps the path logic and reads `DATA_DIR`. Upstream `mkdir -m 777` and `chown` are removed: `/config` is owned by `apps` at runtime and `/app` stays read-only.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "maintainerr"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=Maintainerr/Maintainerr versioning=semver
  default = "3.33.0"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/Maintainerr/Maintainerr"
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

`VERSION` is the source tag without the `v`; the Dockerfile fetches `v${VERSION}`. Validate with `docker buildx bake --print` from `apps/maintainerr/`. Decision on 3.32.0 vs 3.33.0: section 10.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/Maintainerr/Maintainerr"
ports:
  - port: 6246
    protocol: tcp
    required: true
env:
  - name: UI_PORT
    default: "6246"
    required: false
  - name: UI_HOSTNAME
    default: "0.0.0.0"
    required: false
  - name: BASE_PATH
    default: ""
    required: false
  - name: DEBUG
    default: "false"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

Only variables that `start.sh` or the upstream start path read are listed. External service URLs and API keys (Plex, Sonarr, Radarr) are set in the UI, not env, so they are not listed (draft caveat). `TZ` is listed only if the base image honours it; check the family siblings before keeping it. No `opt_dependencies`.

## 7. start.sh

Keep upstream behavior, with the data path moved to `/config`:

```bash
#!/bin/sh
set -eu

BASE_PATH_REPLACE="${BASE_PATH:-}"
BUNDLED_UI_DIR="/app/maintainerr/apps/server/dist/ui"
SERVED_UI_DIR="${DATA_DIR:-/config}/ui"

mkdir -p "${DATA_DIR:-/config}/logs"

# Rebuild the staged UI every boot. Upstream logic, paths moved to /config.
if [ -d "$SERVED_UI_DIR" ]; then chmod -R u+w "$SERVED_UI_DIR" 2>/dev/null || true; fi
rm -rf "$SERVED_UI_DIR"
mkdir -p "$SERVED_UI_DIR"
cp -R "$BUNDLED_UI_DIR/." "$SERVED_UI_DIR/"
chmod -R u+w "$SERVED_UI_DIR"
find "$SERVED_UI_DIR" -type f -print0 | xargs -0 sed -i "s,/__PATH_PREFIX__,${BASE_PATH_REPLACE},g"

cd /app/maintainerr/apps/server
npm_package_version="$(node -p "require('./package.json').version" 2>/dev/null || true)"
export npm_package_version
export DATA_DIR UI_PORT UI_HOSTNAME NODE_ENV DEBUG
exec node dist/main
```

Notes:
- Idempotent: an empty `/config` gets `logs/` and `ui/` created; a populated `/config` gets its `ui/` rebuilt, which is upstream's intent (upgrades and BASE_PATH changes never leave stale chunks). Database files and settings in `/config` are never touched.
- Never writes to `/app`: the bundle is copied from `/app` into `/config/ui` before `sed` runs.
- `sed -i` runs only on files under `${DATA_DIR}/ui`, never under `/app`.
- Caches: `npm` and `node` temp go to `/tmp` (`TMPDIR=/tmp` is set by the base; confirm in section 11).
- The final `exec node dist/main` makes node PID 1 (signal handoff).
- Whether the server reads `${DATA_DIR}/ui` by fixed path: UNVERIFIED. Confirm with `grep -r "ui" apps/server/dist` inside the build stage. If the server reads a fixed `/opt/data` path, keep this mapping and ask upstream.
- Bind all interfaces: `UI_HOSTNAME=0.0.0.0` (upstream default) must reach the server; confirm the listen address in the log.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '6246'
http:
- port: '6246'
  path: /api/health/ready
filePaths:
- /app/maintainerr/apps/server/dist/main.js
- /app/maintainerr/apps/server/dist/ui/index.html
- /usr/share/licenses/maintainerr/LICENSE
- /start.sh
```

- `/api/health/ready` returns 503 while the DB is not ready. The first boot runs migrations; keep the probe with `timeoutSeconds` long enough (180 is a guess; compare `apps/changedetection`, which is the closest python-node sibling, and adjust after the first run).
- `tcp` and `http` run on the container itself. They show the server listens on 6246; they do not prove reachability from another container.
- Tests run with no env vars and no secrets. Maintainerr needs none to start, so no `filePaths` entries for required-env code paths.
- Do not remove or weaken the http probe to make a failing run pass.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | ContainerForge remap |
| --- | --- |
| `/opt/data` (`DATA_DIR`: database, logs, `ui/` staging) | `DATA_DIR=/config` (volume) |
| `/opt/data/logs` (upstream `mkdir -m 777`) | `mkdir -p /config/logs` in `start.sh`; no world-writable mode |
| `/opt/app/apps/server/dist/ui` (bundle, `start.sh` `cp` source) | read-only in `/app/maintainerr`, copied to `/config/ui` each boot |
| `UV_USE_IO_URING=0`, npm cache, yarn cache | keep env var; caches only at build, under `/tmp` |
| Upstream user `node` (uid 1000) | `USER apps` (ContainerForge model); files copied with `--chown=apps:apps` where a runtime write could happen (none planned) |
| Upstream `chown -R node:node /opt/data` | not needed: `/config` is owned by the image user at runtime |

Read-only rootfs check: after build, run with `--read-only --tmpfs /tmp` (section 11). Any `EROFS` in the log means a path was missed.

## 10. Risks, caveats and open questions

- Version: the draft and the chart use `3.32.0`; latest stable is `3.33.0` (published 2026-11-20, five days ago). The plan builds `3.33.0`. If the renovate minimum release age is set, use `3.32.0` instead and record the choice in the PR. Chart version alignment is a separate task.
- Source build only: no release asset and no npm package (section 1). A full yarn/turbo build runs inside the container build, so the build is slow and needs a reliable network in CI.
- Base is not musl: upstream `node:26.13.0-alpine` is replaced by `python-node` (glibc). `node-canvas` needs cairo/pango/pixman dev packages in the build stage; `sharp` ships prebuilt glibc binaries and should not need compilation (UNVERIFIED on arm64).
- Node engine: the upstream build expects Node 26 (`node:26` base). The python-node base's Node version is UNVERIFIED; if it is older than the engine in `package.json`, the build fails and the plan is blocked (ask the base owner, do not install another node).
- Arm64: native modules (`node-canvas`, `sharp`) are built for arm64 in the build stage; not tested here. Say so in the PR.
- Upstream app env vars beyond `UI_PORT`, `UI_HOSTNAME`, `BASE_PATH`, `DATA_DIR` are not confirmed on fetched pages (GitHub code search needs auth). Do not invent more; list only what the code reads after a source check in the build stage.
- Draft caveats (not verified on fetched pages): Plex/Sonarr/Radarr credentials are entered in the UI; rules can delete media (dry-run first). Document both in the PR, not the image.
- Blockers: none confirmed. The main risks are the Node engine match and the native module build.

## 11. Build and test steps

Run from `/workspaces/containers/apps/maintainerr/` (copy the plan's files there first; the draft folder stays unchanged):

1. `docker buildx bake --print` (must exit 0).
2. Confirm node version and `TMPDIR` in the base: `docker run --rm ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e04... sh -c 'node -v; echo $TMPDIR'`.
3. `docker buildx bake --set image-local.platform=linux/amd64 image-local` (expect 10-20 minutes for the yarn/turbo build).
4. Probe: `docker run --rm -d --name maintainerr-probe --read-only --tmpfs /tmp -v maintainerr-probe-config:/config maintainerr:3.33.0`, then `docker logs -f maintainerr-probe`.
5. Readiness signal: a line that the Nest app is listening on port 6246 (for example `listening on` / `Nest application successfully started`), with the process still running and no fatal error after the first 60 seconds. `/api/health/ready` returns 200 once migrations finish.
6. `forgetool containers test --image maintainerr:3.33.0 --config ./container-test.yaml`.
7. Cleanup: `docker rm -f maintainerr-probe; docker volume rm maintainerr-probe-config`.
8. Only if the probe fails with a write error: fix the path in `start.sh`, rebuild, and re-run from step 3.
9. Arm64 is not built by default. Run `--set image-local.platform=linux/arm64` only if an arm64 failure is reported.

## 12. PR checklist

- Branch: `feat/add-maintainerr`. Commit: `feat(maintainerr): add new container`. PR title matches the commit.
- Notes: `🤖 This PR is AI generated.`
- Fill in `.github/PULL_REQUEST_TEMPLATE.md`, keeping its sections and checkboxes. Check only what applies. Do not check "Built container locally" unless step 3 and 4 passed.
- Say in the PR what was not tested (arm64 build, 3.32.0 vs 3.33.0, the server's fixed UI path, the Node engine).
- CLA: the user must sign at https://cla-assistant.io/trueforge-org/containerforge (`license/cla` check). Only the user can sign it.
- Renovate annotation on `VERSION` present; `docker buildx bake --print` passed; `Dockerfile` and `docker-bake.hcl` both use `3.33.0`.
- `container-test.yaml` has a tcp and an http probe for every port in `settings.yaml`.
- No change under `apps/` happens from this draft step; this plan is the input for the build.
