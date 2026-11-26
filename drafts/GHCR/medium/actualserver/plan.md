# actualserver — implementation plan
> Source: ./draft.md · Target: apps/actualserver/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `26.11.0` (GitHub release `v26.11.0`, published 2026-11-02). Matches the chart tag. Confirmed via `gh api repos/actualbudget/actual/releases/latest`. |
| Renovate | `datasource=github-releases depName=actualbudget/actual versioning=semver` (proposed; the version is confirmed, the annotation is a proposal). |
| License | MIT (repo and `@actual-app/sync-server` `package.json`). Source: https://api.github.com/repos/actualbudget/actual, https://registry.npmjs.org/@actual-app/sync-server/26.11.0 |
| Source URL | https://github.com/actualbudget/actual |
| Server artifact | npm package `@actual-app/sync-server@26.11.0` (bin `actual-server`, `engines.node >=22.19.0`). Runtime deps `@actual-app/web` and `@actual-app/crdt` are published packages. |
| Per-arch download | The draft's AppImages (`Actual-linux-x86_64.AppImage`, `Actual-linux-arm64.AppImage`) are the **desktop** app, not the sync server. Do not use them. The server is installed from npm, which is arch-neutral (native `better-sqlite3` fetches its prebuilt binary for glibc x64/arm64). |
| Checksum source | The npm registry publishes `dist.shasum` (`863d2e267ef7cd7c2ea859a8a34538c6828e9cb2`) and `dist.integrity` (sha512) for 26.11.0. The GitHub release has no checksum file. npm verifies the tarball itself, so no extra checksum step is needed. |
| Upstream Dockerfile reviewed | `packages/sync-server/docker/alpine.Dockerfile` at blob `1766241e3f4b3c578e424c4fa15f1eb83c0da17d` (tag v26.11.0). Two stages on `alpine:3.23` (musl). Builder runs `yarn workspaces focus @actual-app/sync-server --production`, then the prod stage copies `node_modules` and `build` to `/app`. Creates user `actual` (UID 1001) and `/data`. `ENTRYPOINT ["/sbin/tini","-g","--"]`, `EXPOSE 5006`, `CMD ["node","app.js"]`. |
| Port | 5006 (upstream `EXPOSE`; chart `targetPort 5006`). |
| Env vars | Only `NODE_ENV=production` is confirmed (upstream Dockerfile). Confirmed in `packages/sync-server/src/load-config.js` at tag v26.11.0: `ACTUAL_DATA_DIR` (default `/data` if it exists, else project root), `ACTUAL_PORT` (default 5006, or `PORT`), `ACTUAL_HOSTNAME` (default `::`, all interfaces), `ACTUAL_SERVER_FILES` and `ACTUAL_USER_FILES` (default under the data dir). The chart sets `env: {}`. |
| Data path | Upstream image creates `/data`; the chart mounts `/data`. The draft's `/config` is a ContainerForge choice (see section 9). |
| Dependencies | None. SQLite is embedded. |
| Draft versus verified | Draft's `copy-from` = `no` is correct (upstream is musl). Draft's `Application binary` AppImage link is wrong for a server image (see blockers). Draft's `amd64`/`arm64` = `yes` holds only through npm. |

## 2. Target layout

- `apps/actualserver/Dockerfile`
- `apps/actualserver/docker-bake.hcl`
- `apps/actualserver/settings.yaml`
- `apps/actualserver/container-test.yaml`
- `apps/actualserver/start.sh`

No `defaults/`, `etc/` or `health/` needed. Never `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base). The `include/.dockerignore` allow-list already passes `start.sh`, so no extra copies are needed.

## 3. Base image

`FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5`, as the draft says. The repo's `apps/budge/Dockerfile` comment states that `python-node` ships Node 24, which satisfies `>=22.19.0`. Node is the only runtime needed; Python is unused but is part of the chosen base. Closest sibling: `apps/budge` (node app on python-node). If the Node version check fails on the pinned digest, switch to `ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` and add Node 22+ from a pinned source (UNVERIFIED for a pinned Ubuntu Node package).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. `ENV HOME=/tmp npm_config_cache=/tmp/npm NPM_CONFIG_UPDATE_NOTIFIER=false NODE_ENV=production ACTUAL_DATA_DIR=/config/data`.
3. Install the server into a fixed prefix (no lockfile is shipped in the npm tarball, so the version is pinned exactly):
   `npm install --omit=dev --no-audit --no-fund --prefix /app/actual-server @actual-app/sync-server@${VERSION}`
4. Verify the Node runtime: `node -e 'process.exit(process.versions.node.split(".").map(Number)[0] >= 22 ? 0 : 1)'` (fails the build if the base has a Node older than 22).
5. License: `mkdir -p /usr/share/licenses/actualserver && cp /app/actual-server/node_modules/@actual-app/sync-server/LICENSE /usr/share/licenses/actualserver/LICENSE`. If the package lacks a LICENSE file, add the upstream `LICENSE` from the tag (UNVERIFIED that the npm tarball ships it; `files` lists `LICENSE`, so it should).
6. Ownership and cleanup, following the `apps/adguardhome-sync` pattern: `chown -R apps:apps /app && chmod -R 755 /app`, then `rm -rf /tmp/npm /tmp/*`.
7. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 5006
VOLUME /config
CMD ["/start.sh"]
```

`/app` stays read-only at runtime regardless of the `chown` in step 6; the root-owned alternative (`chown -R root:root /app && chmod -R a+rX /app`) also works.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "actualserver"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=actualbudget/actual versioning=semver
  default = "26.11.0"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/actualbudget/actual"
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
  platforms = ["linux/amd64", "linux/arm64"]
}
```

Validate with `cd apps/actualserver && docker buildx bake --print`. The Dockerfile's `ARG VERSION` consumes the same value.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/actualbudget/actual"
ports:
  - port: 5006
    protocol: tcp
    required: true
env:
  - name: ACTUAL_DATA_DIR
    default: "/config/data"
    required: false
  - name: ACTUAL_PORT
    default: "5006"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

`ACTUAL_DATA_DIR` and `ACTUAL_PORT` are confirmed in `load-config.js`; `start.sh` exports the data dir and the app reads the port itself. `ACTUAL_HOSTNAME` is not listed because its default `::` is wanted. The `TZ` entry follows sibling apps.

## 7. start.sh

```bash
#!/usr/bin/env bash

export ACTUAL_DATA_DIR="${ACTUAL_DATA_DIR:-/config/data}"
mkdir -p "${ACTUAL_DATA_DIR}"

cd /app/actual-server/node_modules/@actual-app/sync-server || exit 1
exec node build/bin/actual-server.js
```

- Idempotent: it creates `/config/data` only when missing and seeds nothing. Upstream creates the first-run state (budget file, server password) through the browser setup, so the script does not write user state.
- No writes under `/app`: the data directory is set through `ACTUAL_DATA_DIR`, so no symlink is needed.
- Listen address: upstream `ACTUAL_HOSTNAME` defaults to `::` (all interfaces); confirm from outside the container on the first run.
- `exec` hands PID 1 to the process; the upstream `tini` is not needed because the base image provides init handling (UNVERIFIED for the base; check `apps/budge` if the process does not exit cleanly on `SIGTERM`).
- Caches go to `/tmp` (`npm_config_cache` set in the Dockerfile).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '5006'
http:
- port: '5006'
  path: /
filePaths:
- /app/actual-server/node_modules/@actual-app/sync-server/build/bin/actual-server.js
- /usr/share/licenses/actualserver/LICENSE
```

- Port 5006 has both `tcp` and `http` probes. `GET /` is the chart's probe path; the server should answer 200 on the first run (confirm; if it answers a redirect, use the confirmed status path).
- `timeoutSeconds` is set to 120 as a starting point; align it with the sibling `apps/budge` value when writing the file (not read in this run).
- No env-gated code path is needed for the test: the server starts with defaults.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/data` (upstream Docker data dir, chart PVC mount) | `ACTUAL_DATA_DIR=/config/data` (confirmed env var; set in the Dockerfile and `start.sh`). |
| `/app` (upstream `/app` tree) | Read-only at runtime. The server reads its code only. |
| npm cache, build scratch | `/tmp` (`npm_config_cache=/tmp/npm`). |
| Chart `securityContext` root (`runAsUser 0`) | Not used. The image runs as `apps` (`USER apps`). |
| Chart `readOnlyRootFilesystem: false` | Our image is designed for `--read-only --tmpfs /tmp` with a `/config` volume. |
| Chart `privileged` | `no` (default). |
| Chart mount `/data` vs draft `/config` | Persistent state lives in `/config/data`. Migrating an existing chart install means copying `/data` into the new `/config` volume (note for the PR). |

Security expectations from the draft are confirmed as expectations only: the chart runs as root and writes to `/data`, which this image does not do.

## 10. Risks, caveats and open questions

- **Draft binary link is wrong**: the AppImages are the desktop app. Use the npm package (section 1). Recorded so the next reviewer does not switch back to the AppImage.
- **No lockfile in the npm tarball**: the version is pinned, but transitive dependencies resolve at build time. Accept this for now, or switch to a source build of the tag with the vendored `.yarn` release and `yarn.lock` (the upstream approach). The source build is heavier, so it is the fallback.
- **Native module**: `better-sqlite3` installs its prebuilt binary from GitHub at build time. It needs network access during the build. If the prebuild is missing for arm64/glibc, the build must compile it (needs `build-essential`, `python3`; UNVERIFIED that the base has these).
- **Data and listen env names** are confirmed in `load-config.js` at v26.11.0 (section 1); no symlink is used.
- **First-run setup**: the browser asks for the server password and the budget file. The `reset-password` script exists in the package (`scripts` list). Passwords are not required at container start, so the test is unaffected.
- **Chart tag**: the chart pins `26.11.0@sha256:06cf186569cf58d93e12659ff1a517b65b5b0ebee7050a3991d4bd8a1d398da6` for the GHCR image. This plan uses the npm version, so the GHCR digest is not reused.
- **Upstream image arch list**: UNVERIFIED (no manifest fetched).
- **Node version**: `>=22.19.0` required. Relies on the `python-node` base shipping Node 24 (repo comment in `apps/budge`, not a fetched page).

## 11. Build and test steps

From `apps/actualserver/`, in protocol order:

1. `docker buildx bake --print` must exit 0.
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. Probe with an empty config volume:
   ```sh
   docker volume create actualserver-probe-config
   docker run --rm -d --name actualserver-probe --read-only --tmpfs /tmp \
     -v actualserver-probe-config:/config actualserver:26.11.0
   docker logs -f actualserver-probe
   ```
   Expected readiness signal: the server's startup log line (confirm the exact text from a real run; a listening line on port 5006 is the success signal). Then `docker rm -f actualserver-probe; docker volume rm actualserver-probe-config`.
4. `forgetool containers test --image actualserver:26.11.0 --config ./container-test.yaml`
5. arm64 is not needed unless the amd64 build fails for an arch-specific reason. Record that arm64 was not built if it is skipped.

## 12. PR checklist

- Branch `feat/add-actualserver`, commit `feat(actualserver): add new container`, PR title the same.
- PR body from `.github/PULL_REQUEST_TEMPLATE.md` with its sections and checkboxes kept; only check the boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it; the `license/cla` check shows status).
- State what was not tested: arm64 build, the data/listen env names if still unverified, and any first-run browser flow.
- `docker buildx bake --print` and the amd64 image-local build must be run and recorded; if they could not run, say so in the PR and do not tick "Built container locally".
