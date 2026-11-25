# qinglong — implementation plan
> Source: ./draft.md · Target: apps/qinglong/ · Difficulty: medium · Role (main/sidecar): main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `v2.24.0`, published 2026-10-29, not prerelease. Source: https://api.github.com/repos/whyour/qinglong/releases/tags/v2.24.0 . Draft tag `2.24.0` matches (TrueCharts uses `ghcr.io/whyour/qinglong:2.24.0`). |
| Renovate | `// renovate: datasource=github-releases depName=whyour/qinglong versioning=semver` (repo has tags, so github-releases fits; upstream default branch is `develop`, not `main`, which matters only for any git-refs fallback). |
| License | Apache-2.0 (GitHub API `license` field, https://api.github.com/repos/whyour/qinglong). Use `LICENSE = "Apache-2.0"`. |
| Source URL | https://github.com/whyour/qinglong |
| Per-arch download | No release assets (`assets` array empty on v2.24.0). The app is built from source: git tag archive `https://github.com/whyour/qinglong/archive/refs/tags/v2.24.0.tar.gz` (standard GitHub tag archive; URL pattern not fetched, UNVERIFIED until the first `curl` in the build). Build is arch-independent JS plus native npm modules, so amd64 and arm64 both build natively through buildx. |
| Checksum source | None published on the release. The tag archive is content-addressed by tag; record the tag commit SHA in the Dockerfile comment for audit (UNVERIFIED: tag commit SHA not fetched). |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/whyour/qinglong/6e26899a235a955713edfb490f6ae538d0baf612/docker/Dockerfile . Stages: `node:24.18.1-alpine3.24` builder, `node-runtime-amd64` (node binary), final `python:3.11-alpine3.24`. ENTRYPOINT `./docker/docker-entrypoint.sh`, no CMD, no USER (root), EXPOSE 5700, VOLUME /ql/data, WORKDIR /ql. |
| Upstream entrypoint reviewed | https://raw.githubusercontent.com/whyour/qinglong/develop/docker/docker-entrypoint.sh . Starts `crond -f` (system scheduler) or `tail -f /dev/null` (node scheduler), optional `ql bot` and `ql extra` in background, runs `pm2` init check and `reload_pm2` (defined in `share.sh`, not fetched, UNVERIFIED which services). Ends `exec "$@"`. |
| Env vars (real, read by entrypoint) | `QL_DIR`, `HOME`, `AutoStartBot`, `EnableExtraShell`, `QL_SCHEDULER`, `ql_port`, `ql_grpc_port`, `dir_log`. Image sets `QL_DIR=/ql`, `QL_CONTAINER=true`, `LANG=C.UTF-8`, `SHELL=/bin/bash`, `HOME=/root`. Exports `BACK_PORT`, `GRPC_PORT`. |
| Ports | 5700 (EXPOSE). `ql_port`/`ql_grpc_port` defaults UNVERIFIED (defined in `share.sh`). |
| Data path | `/ql/data` (upstream VOLUME). Log dir `dir_log` UNVERIFIED (not fetched). |
| Packages (upstream) | Builder: `git`, `pnpm@8.3.1`, `pm2`, `ts-node`, `typescript@5`, `pnpm install --prod --frozen-lockfile`. Final apk: bash coreutils git curl wget tzdata perl openssl nodejs jq openssh procps netcat-openbsd unzip npm; pip `requests`. |
| Docs | https://qinglong.online/guide/getting-started/installation-guide (not fetched, UNVERIFIED for install details). |
| Node version | Upstream builds on Node 24.18.1. The ContainerForge `python-node` base Node version is UNVERIFIED, check with `docker run --rm <base> node -v` before the Dockerfile is written. |

## 2. Target layout

Exact files for `apps/qinglong/`:
- `Dockerfile` (required)
- `docker-bake.hcl` (required)
- `settings.yaml` (required)
- `container-test.yaml` (required)
- `start.sh` (required, supervises the panel and the scheduler)

Not needed: `defaults/` (Qinglong creates its own config on first start, UNVERIFIED), `etc/`, `scripts/`, `health/`, `root/` (never used). `DOWNSTREAM_CHANGES.md` not needed: nothing consumes this image as `FROM`.

## 3. Base image

`FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5` for the final stage. It is the Python plus Node base the draft names. The build stage uses the same image (Node and pnpm are needed to build). Closest siblings: `apps/changedetection` and `apps/budge` (both python-node). No existing `apps/*` sibling is a Node panel with cron. Dependency containers: none in the draft; no `apps/` dependency is needed.

## 4. Dockerfile

Build stage `FROM <python-node> AS build`, final stage `FROM <python-node>`.

1. `ARG VERSION`, `ARG TARGETARCH`. `USER root` for installs.
2. Build stage:
   - `apt-get install -y --no-install-recommends git` (if not in base; check base first).
   - `npm install -g pnpm@8.3.1` (pin to the version upstream uses; not renovate-bumped, record in a comment).
   - Fetch source: `curl -fL https://github.com/whyour/qinglong/archive/refs/tags/v${VERSION}.tar.gz | tar xz -C /tmp/ql --strip-components=1`.
   - `cd /tmp/ql && pnpm install --prod --frozen-lockfile --side-effects-cache=false` (mirrors upstream builder; set `PNPM_HOME` and the store under `/tmp`).
   - Store caches: `ENV npm_config_cache=/tmp/npm-cache PNPM_HOME=/tmp/pnpm`.
3. Final stage (apt, root): install only what the base lacks from the upstream list: `git curl wget jq openssh-client procps netcat-openbsd unzip` (check each with `dpkg -s`; drop anything in the base). Pin nothing from apt (not a version-aligned package). Clean apt lists.
4. Copy the built app: `COPY --from=build /tmp/ql /app/qinglong` (keeps `/app` read-only, runtime writes go to `/config`/`/tmp`).
5. Permissions: `chown -R apps:apps /app && chmod -R 755 /app`. `ln -s /config/data /app/qinglong/data` is NOT used; instead `start.sh` points `QL_DIR` data at `/config`, see section 9.
6. `ENV QL_DIR=/app/qinglong QL_CONTAINER=true HOME=/config LANG=C.UTF-8 PIP_CACHE_DIR=/tmp/pip NPM_CONFIG_PREFIX=/tmp/npm-global`.
7. `LICENSE`: `COPY --from=build /tmp/ql/LICENSE /usr/share/licenses/qinglong/LICENSE`.
8. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 5700
VOLUME /config
WORKDIR /app/qinglong
```

`ENTRYPOINT` is not set in the Dockerfile; `start.sh` is the entrypoint from `COPY . /` (the convention in `apps/adguardhome-sync`). Verify `start.sh` is executable after the copy.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "qinglong"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=whyour/qinglong versioning=semver
  default = "2.24.0"
}

variable "LICENSE" {
  default = "Apache-2.0"
}

variable "SOURCE" {
  default = "https://github.com/whyour/qinglong"
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

Use `image-all` as in siblings. Validate with `docker buildx bake --print` from `apps/qinglong`. `VERSION` must equal the Dockerfile `ARG VERSION` default (the Dockerfile has no default; it receives it from bake).

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/whyour/qinglong"
ports:
  - port: 5700
    protocol: tcp
    required: true
env:
  - name: AutoStartBot
    default: "false"
    required: false
  - name: EnableExtraShell
    default: "false"
    required: false
  - name: QL_SCHEDULER
    default: "system"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

Only env vars the entrypoint really reads are listed (section 1). `ql_port`/`ql_grpc_port` are NOT added as env: their defaults are UNVERIFIED (in `share.sh`), so do not invent them; add them only after `share.sh` is read in the build step. `TZ` is not added: it is not read by the entrypoint (the base sets it, UNVERIFIED).

## 7. start.sh

Requirements:
- `#!/usr/bin/env bash`, `set -euo pipefail` is NOT used (the upstream entrypoint is not strict; keep behaviour of `pm2` init check tolerant).
- Seed and config under `/config`: `mkdir -p /config/data`; point Qinglong's data at it. Upstream hardcodes `/ql/data`; the remap is by symlink created at start (`ln -sfn /config/data /app/qinglong/data`) because `/app` is read-only at runtime, so the symlink must be created in the Dockerfile as root and not in `start.sh`. Alternative (preferred if the app honours it): set the env var upstream reads for its data dir (UNVERIFIED, check `share.sh`).
- Writable runtime paths: `HOME=/config`, caches in `/tmp` (`npm_config_cache`, `PNPM_HOME`, `PIP_CACHE_DIR`). Logs: `dir_log=/config/log` (UNVERIFIED default, confirm in `share.sh`).
- Supervision: the entrypoint runs `crond -f` or `tail -f` in the foreground. Under `apps` (non-root) `crond` may not be allowed to run; the plan is to use node scheduler (`QL_SCHEDULER=node`) unless the build shows `crond` works as `apps`. Record the decision in the PR.
- Run the upstream entrypoint logic from `/app/qinglong/docker/docker-entrypoint.sh` only if its functions are needed; otherwise a shorter script that starts the panel is preferred. Final command: `exec node /app/qinglong/static/...` is UNVERIFIED: read the upstream `pm2` ecosystem file (`ecosystem.config.js`) in the build step to get the exact panel start command.
- Bind 0.0.0.0: the panel must listen on `0.0.0.0:5700` (check `ql_port`/listen host in `share.sh`/`ecosystem.config.js`).
- End with `exec` of the long-running process so signals reach it.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '5700'
http:
- port: '5700'
  path: /
filePaths:
- /app/qinglong/package.json
- /usr/share/licenses/qinglong/LICENSE
```

- `timeoutSeconds` set high because pnpm/Node start is slow; check the nearest Node sibling (`apps/changedetection`) and align.
- An `http` probe on `/` may return a login redirect; confirm the status code during step 11 and use the path that returns the expected status (UNVERIFIED).
- No env-gated code paths are in scope.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/ql/data` (VOLUME, hardcoded data dir) | `/config/data`, linked from `/app/qinglong/data` by the Dockerfile (root build step creates a dangling link; `start.sh` creates `/config/data`) |
| `/ql/.tmp` (when `$HOME` not writable) | `HOME=/config`, so the entrypoint fallback is not taken |
| `/etc/resolv.conf`, `/etc/hosts` (entrypoint writes) | Not writable as `apps`. Remove those writes from the runtime path or confirm they are only executed as root; if they run, the container fails under `apps` (open question, section 10) |
| `chown` of `$QL_DIR/data` | Never run as `apps`; check `ensure_ql_permissions` branch is not hit |
| npm/pnpm/pip caches | `/tmp` |
| pm2 state (`~/.pm2`) | `HOME=/config` writes `/config/.pm2`; alternatively `PM2_HOME=/tmp/pm2` (not persistent, decide per data needs) |

Rootless target: `USER apps` (UID 568 in ContainerForge base). Upstream runs as root (`USER` not set); the chart override `runAsUser 0` is not needed for this image. Read-only-rootfs: compatible with `--read-only --tmpfs /tmp` only if the entrypoint's `/etc` writes are removed or skipped, see section 10.

Reconciliation with the draft's expectations: draft says non-root no, read-only-rootfs no, privileged no. This plan targets non-root yes and read-only-rootfs yes, pending the build check. No privileged need identified.

## 10. Risks, caveats and open questions

- Upstream image is alpine/musl (`node:24-alpine`, `python:3.11-alpine`). This plan uses ubuntu-based python-node (glibc). Any native npm module that ships only a musl binary will fail. Check during build.
- Node version: upstream pins Node 24.18.1 via the alpine image; the python-node base Node version is UNVERIFIED. If it is older than the Qinglong `engines` field, the build must change base or pull Node (no `copy-from` of the upstream image: it is musl, so `copy-from` is `no`).
- `pnpm@8.3.1` is pinned upstream; newer pnpm may change lockfile handling. Keep the pin.
- Cron under non-root `apps`: `crond` may need root. Mitigated by `QL_SCHEDULER=node` if confirmed.
- `/etc/resolv.conf` and `/etc/hosts` writes in the entrypoint are incompatible with `apps` user and read-only rootfs (section 9).
- Task scripts and their dependencies are installed at runtime from the web panel: first start is slow and needs internet (inferred in draft, consistent with the upstream design). The container test's `timeoutSeconds` must cover the panel start only, not task installs.
- Git clone at build time was replaced by a tag tarball: this needs the tag URL to be confirmed on first `curl` (UNVERIFIED).
- Upstream `DockerfileBuild` and `Dockerfile` both reference older SDK/Alpine versions; the plan uses the upstream `Dockerfile` (the one TrueCharts uses) as the reference, not the build helper.
- Unverified: whether the panel process name/port in `ecosystem.config.js` is 5700 (EXPOSE says 5700, entrypoint reads `ql_port`).

## 11. Build and test steps

```sh
cd apps/qinglong
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local

docker run --rm -d --name qinglong-probe --read-only --tmpfs /tmp \
  -v qinglong-probe-config:/config qinglong:2.24.0
docker logs -f qinglong-probe

forgetool containers test --image qinglong:2.24.0 --config ./apps/qinglong/container-test.yaml

docker rm -f qinglong-probe; docker volume rm qinglong-probe-config
```

Expected readiness: a line from the panel saying it listens on port 5700 (exact text UNVERIFIED until `ecosystem.config.js` / `share.sh` are read), container still running after the start window, no `crond`/permission error on `/etc/hosts`. Test restart with the same `/config` volume to confirm idempotent start. arm64 is a separate build (`image-all`) only after amd64 is green.

## 12. PR checklist

- Branch `feat/add-qinglong`, commit `feat(qinglong): add new container`, PR title the same, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep all sections and checkboxes, check only the boxes that apply.
- Notes section contains `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; `license/cla` shows status).
- Downstream: none (`DOWNSTREAM_CHANGES.md` not needed).
- Not tested to state honestly: arm64 build, the scheduler under `apps`, bot and extra shell, the http probe status, the musl-to-glibc native module behaviour, and any runtime task installs.
- `docker buildx bake --print` passes and `VERSION` matches the Dockerfile input.
