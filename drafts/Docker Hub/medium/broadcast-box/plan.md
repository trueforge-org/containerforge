# broadcast-box — implementation plan
> Source: ./draft.md · Target: apps/broadcast-box/ · Difficulty: medium · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | `v2.1.1` (latest GitHub release, 2026-11-16; draft only said `latest`, so the plan pins `v2.1.1`) |
| Renovate | `datasource=github-releases`, `depName=Glimesh/broadcast-box`, default semver versioning (tags carry a `v` prefix) |
| License | MIT (SPDX `MIT`; GitHub API and LICENSE file, "Copyright (c) 2023 Glimesh") |
| Source | https://github.com/Glimesh/broadcast-box |
| Download | No release binaries (release has no assets). Build from tag tarball `https://github.com/Glimesh/broadcast-box/archive/refs/tags/${VERSION}.tar.gz` for both archs (compile on the build arch, no per-arch URL) |
| Checksum | None published for the tarball. Tags are not signed-checked here; UNVERIFIED: no upstream checksum exists |
| Upstream Dockerfile | Reviewed (commit 484a228). Three stages: `node` runs `npm install && npm run build` in `web/`, `golang:alpine` runs `go build`, runtime `golang:alpine` with `ENV APP_ENV=production`, `NETWORK_TEST_ON_START=true`, `WORKDIR /broadcast-box`, entrypoint `/broadcast-box/broadcast-box` |
| Go / Node | `go.mod` needs Go 1.26.0; web uses Vite 8. The ContainerForge ubuntu base already ships Go (`GO_VERSION` 1.27.4 in `apps/ubuntu/docker-bake.hcl`) and Node (`NODE_VERSION` 26.13.1) |

Ports and env (from `internal/environment/variables.go`, README, `.env.production`):
- HTTP: default `HTTP_ADDRESS=:8080` (binds all interfaces). Draft listed 8189/udp and the security note 60006/udp: both are NOT confirmed. WebRTC media is UDP on a random port unless `UDP_MUX_PORT` (or `UDP_MUX_PORT_WHIP` / `UDP_MUX_PORT_WHEP`) is set. README Docker example uses `UDP_MUX_PORT=8080` with `-p 8080:8080/udp`. This plan defaults `UDP_MUX_PORT=8080`.
- Real env vars: `APP_ENV`, `HTTP_ADDRESS`, `HTTPS_REDIRECT_PORT`, `ENABLE_HTTP_REDIRECT`, `NETWORK_TEST_ON_START`, `INCLUDE_PUBLIC_IP_IN_NAT_1_TO_1_IP`, `DISABLE_STATUS`, `SSL_KEY`, `SSL_CERT`, `STREAM_PROFILE_PATH` (default `profiles`), `STREAM_PROFILE_POLICY` (default `ANYONE_WITH_RESERVED`), `WEBHOOK_URL`, `DISABLE_FRONTEND`, `FRONTEND_PATH` (default `./web/build`), `FRONTEND_ADMIN_TOKEN`, `UDP_MUX_PORT`, `NAT_1_TO_1_IP`, `NAT_ICE_CANDIDATE_TYPE`, `INTERFACE_FILTER`, `NETWORK_TYPES`, `STUN_SERVERS`, `LOGGING_ENABLED`, `LOGGING_LEVEL` (default INFO), `LOGGING_DIRECTORY` (default `logs`), `CHAT_*`.
- Write paths: `STREAM_PROFILE_PATH` (profile JSON files written by the admin API), file logging to `logs/` (relative to cwd; startup exits with an error if the directory cannot be created), optional pprof on localhost:6060.
- Config lookup: `.env.production` and `./web/build` are resolved relative to cwd, then retried relative to the executable directory.

## 2. Target layout

```
apps/broadcast-box/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```
No `defaults/`, `etc/` or `scripts/` needed (nothing to seed; upstream `.env.production` is all comments). No `root/`. No `DOWNSTREAM_CHANGES.md` (not used as a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a` for the final stage; the build stage uses the same image as `AS builder` because it already provides Go and Node (no `golang`/`node` images needed, matching `apps/it-tools` and `apps/hishtory-server`). Closest siblings: `apps/hishtory-server` (Go build stage) and `apps/it-tools` (Node build stage).

## 4. Dockerfile

1. `FROM <ubuntu> AS builder`, `ARG VERSION`, `USER root`, `ENV HOME=/tmp GOCACHE=/tmp/go-build GOPATH=/tmp/go npm_config_cache=/tmp/npm CGO_ENABLED=0`. Do not compile Go in the final stage.
2. Download `https://github.com/Glimesh/broadcast-box/archive/refs/tags/${VERSION}.tar.gz` to `/tmp`, extract to `/build` with `--strip-components=1`.
3. Web build: `cd /build/web && npm install && npm run build` (output `/build/web/build`). Use `npm ci` only if a `web/package-lock.json` exists (the lockfile found is at repo root: UNVERIFIED which dir).
4. Go build: `cd /build && go build -trimpath -o /out/broadcast-box .` (upstream builds with plain `go build`; pion is pure Go, CGO disabled UNVERIFIED but expected).
5. Final stage `FROM <ubuntu>`, `ARG VERSION`, `USER root` only for file placement: `COPY --from=builder /out/broadcast-box /app/broadcast-box`, `COPY --from=builder /build/web/build /app/web/build`, `COPY --from=builder /build/LICENSE /usr/share/licenses/broadcast-box/LICENSE`, then `chown -R apps:apps /app && chmod -R 755 /app` (pattern from `apps/adguardhome-sync`).
6. `ENV APP_ENV=production HOME=/config` (no apt packages required; base has ca-certificates and curl).
7. `EXPOSE 8080` and `EXPOSE 8080/udp`, `VOLUME /config`.
8. `COPY --chmod=0755 . /` (copies `start.sh`; `.dockerignore` allow-list applies).
9. Final line `USER apps`.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "broadcast-box"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=Glimesh/broadcast-box
  default = "v2.1.1"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/Glimesh/broadcast-box"
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
Validate with `docker buildx bake --print` from `apps/broadcast-box/`. Dockerfile `ARG VERSION` must receive exactly this value (no extra defaults).

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/Glimesh/broadcast-box"
ports:
  - port: 8080
    protocol: tcp
    required: true
  - port: 8080
    protocol: udp
    required: true
env:
  - name: UDP_MUX_PORT
    default: "8080"
    required: false
  - name: HTTP_ADDRESS
    default: ":8080"
    required: false
  - name: NAT_1_TO_1_IP
    default: ""
    required: false
  - name: INCLUDE_PUBLIC_IP_IN_NAT_1_TO_1_IP
    default: ""
    required: false
  - name: STREAM_PROFILE_PATH
    default: "/config/profiles"
    required: false
  - name: STREAM_PROFILE_POLICY
    default: "ANYONE_WITH_RESERVED"
    required: false
  - name: FRONTEND_ADMIN_TOKEN
    default: ""
    required: false
  - name: LOGGING_ENABLED
    default: "false"
    required: false
  - name: LOGGING_LEVEL
    default: "INFO"
    required: false
  - name: NETWORK_TEST_ON_START
    default: "false"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```
No `dependencies:` (none; draft confirms none).

## 7. start.sh

`#!/usr/bin/env bash`, no `set -e` surprises beyond what siblings do.
1. `mkdir -p "${STREAM_PROFILE_PATH:=/config/profiles}"` (only creates when missing; no overwrite).
2. `export UDP_MUX_PORT="${UDP_MUX_PORT:-8080}"`, `export LOGGING_ENABLED="${LOGGING_ENABLED:-false}"` (file logging would try to create `/app/logs` and abort the process on a read-only rootfs; logs go to stdout), `export NETWORK_TEST_ON_START="${NETWORK_TEST_ON_START:-false}"`, `export STREAM_PROFILE_PATH`, `export APP_ENV=production`. If `LOGGING_ENABLED=true` is requested, default `LOGGING_DIRECTORY` to `/tmp/logs`.
3. HTTP binds `:8080` (all interfaces) by default; leave `HTTP_ADDRESS` to the app.
4. `cd /app` so `./web/build` resolves, then `exec /app/broadcast-box`.
Secrets (`FRONTEND_ADMIN_TOKEN`) stay in env, never written to files or argv.

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
- /app/broadcast-box
- /app/web/build/index.html
healthCommands:
- command: bash -c "grep -qi ':1F90 ' /proc/net/udp /proc/net/udp6"   # UDP 8080 probe (schema has no udp check)
```
Probes: tcp 8080 and http 8080 for the TCP port, healthCommand for 8080/udp. UNVERIFIED: whether `healthCommands.command` is shell-split (so the `bash -c` form works) and that `index.html` is the build output name. The test runs without env, so UDP_MUX_PORT comes from the `start.sh` default.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write | Remap |
|---|---|
| `logs/` under cwd (file logging on by default) | `LOGGING_ENABLED=false` default, or `LOGGING_DIRECTORY=/tmp/logs` |
| `profiles/` (stream profile JSON) | `/config/profiles` via `STREAM_PROFILE_PATH` |
| `.env.production` lookup | Absent file is fine (logs "continuing with system environment") |
| Go/npm caches (build only) | `/tmp` in builder stage |
| pprof | Off unless `ENABLE_PROFILING=true`, localhost only |

Draft security expectations: chart runs as root, no read-only rootfs, no extra persistence. ContainerForge runs as UID 568 (`apps`) with read-only rootfs; only `/config` (profiles) and `/tmp` are written. Not privileged. Chart's "UDP 60006" is not an upstream default; the media UDP port is `UDP_MUX_PORT`.

## 10. Risks, caveats and open questions

- WebRTC needs UDP reachable by clients. Behind NAT set `NAT_1_TO_1_IP` (or `INCLUDE_PUBLIC_IP_IN_NAT_1_TO_1_IP=true` with host networking). Without `UDP_MUX_PORT` the media port is random and cannot be published; hence the 8080/udp default.
- Draft port 8189/udp and chart port 60006/udp are unconfirmed and are not used. Charts must map whichever UDP port `UDP_MUX_PORT` has.
- No release binary: both Go and Node builds must succeed on amd64 and arm64 (Vite 8 and Go 1.26 are current; QEMU arm64 builds are slow).
- Stream keys and admin token: `FRONTEND_ADMIN_TOKEN` empty means `/admin` is disabled; with `STREAM_PROFILE_POLICY=ANYONE_WITH_RESERVED` anyone may stream to unreserved keys.
- `NETWORK_TEST_ON_START` defaulted to false (upstream image default is true) to avoid blocking start on outbound network; behaviour of the test itself UNVERIFIED.
- No upstream checksum for the source tarball.

## 11. Build and test steps

Run per `build-test-protocol.instructions.md`, one app only, max 10 rounds:

```sh
cd apps/broadcast-box
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create broadcast-box-probe-config
docker run --rm -d --name broadcast-box-probe --read-only --tmpfs /tmp \
  -v broadcast-box-probe-config:/config broadcast-box:<VERSION>
docker logs -f broadcast-box-probe        # expect: `Booting up Broadcast Box` then `Starting HTTP` with `address=:8080`
docker rm -f broadcast-box-probe; docker volume rm broadcast-box-probe-config
forgetool containers test --image broadcast-box:<VERSION> --config ./apps/broadcast-box/container-test.yaml
```

Always start from an empty `/config` volume and check that the container is still running, with no fatal errors or repeated stack traces. Attempt arm64 only if the amd64 loop is green or the failure is arm64-specific.

## 12. PR checklist

- [ ] Branch `feat/add-broadcast-box` from fresh `main`; one app per PR.
- [ ] Commit and PR title: `feat(broadcast-box): add new container` (Conventional Commits, target `main`).
- [ ] PR body uses `.github/PULL_REQUEST_TEMPLATE.md`, keeps its sections, and only checks boxes that apply.
- [ ] Notes section contains `🤖 This PR is AI generated.` (no "Generated with ..." line).
- [ ] `docker buildx bake --print` exits 0; `VERSION` in `docker-bake.hcl` matches the Dockerfile `ARG VERSION`.
- [ ] Runtime is rootless (`USER apps`) and works with `--read-only --tmpfs /tmp` and an empty `/config`.
- [ ] Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (the `license/cla` check shows status). Only the user can sign it; never sign for them.
- [ ] Untested items stated honestly in the PR: amd64 and arm64 builds not run, real WebRTC publish/watch through UDP not tested, admin portal and profile persistence not tested.
