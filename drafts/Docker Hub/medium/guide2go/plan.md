# guide2go — implementation plan
> Source: ./draft.md · Target: apps/guide2go/ · Difficulty: medium · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | `1.2.0` (latest release and tag of `mar-mei/guide2go`, published 2023-01-04; tag commit `0af9b0a`, equal to `master` HEAD, so nothing newer exists). The draft pins no tag (image `alturismo/guide2go:latest`). |
| Upstream used | `mar-mei/guide2go` (the draft's "Application source"). The draft's `alturismo/guide2go` is a repo that wraps this code in an Alpine image with cron and a shell script; it has no releases and is not used here. |
| Renovate | `datasource=github-releases depName=mar-mei/guide2go versioning=semver` |
| License | MIT (GitHub SPDX `MIT`, `LICENSE` at repo root) |
| Source URL | https://github.com/mar-mei/guide2go (tarball `https://github.com/mar-mei/guide2go/archive/refs/tags/1.2.0.tar.gz`) |
| Per-arch download | None. The release has no assets. Compile from source for amd64 and arm64 (`go.mod`: `go 1.19`, deps `gorilla/mux v1.8.0`, `yaml.v3 v3.0.1`; pure Go, no cgo). |
| Checksum source | None published for the tarball. Integrity comes from `go.sum` (module checksums). UNVERIFIED: no upstream tarball checksum exists, so none is checked. |
| Upstream Dockerfile reviewed | `alturismo/guide2go` Dockerfile (Alpine, `ENV TZ`, `VOLUME /config /guide2go`, entrypoint starts `crond`) and its `cronjob.sh`/`entrypoint.sh`, plus `mar-mei/guide2go` `main.go` and `server.go` at 1.2.0. |

Behaviour (from `main.go`, `server.go`, README):
- Flags only: `-configure <file.yaml>` (interactive menu creating the config), `-config <file.yaml>` (fetch Schedules Direct data and write the XMLTV file), `-h`. No env vars are read by the program (the image only sets `TZ`).
- After `-config` finishes the process exits, unless `Local Images Cache` or `Proxy Images` is enabled. Then it starts an HTTP server on the port taken from the `Options.Hostname` setting (`host:port`, default 8080 when no port) and blocks. The server exposes `/images/...` and `/run` (starts a new grab).
- Needs a Schedules Direct account (Username/Password in the YAML). Sample config keys: `Files.Cache`, `Files.XMLTV`, `Options.Images Path`, `Options.Hostname`, `Station[]`.
- The draft's security hints (extra PVCs `/guide2go`, `/TVH`) belong to the alturismo wrapper (it copies the XML to a TVHeadend path). Not needed here.

## 2. Target layout

```
apps/guide2go/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
  defaults/guide2go.yaml      # seed config, copied from upstream sample-config.yaml with /config paths
```

`defaults/` is needed because a CLI that requires a config file needs a seed on an empty `/config`. No `root/`. No `DOWNSTREAM_CHANGES.md` (nothing uses this image as a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` for the final stage; build stage `FROM --platform=$BUILDPLATFORM golang:1.26@sha256:6e59e17a20f13c102e49d82dffab66d41cffe6c266b225d82794328aea859ab5 AS build` (the `1.26` digest is UNVERIFIED in this pass and no `apps/*/Dockerfile` uses a `golang:` stage; the repo precedent is the ubuntu base, which already ships Go 1.27.4 in `/usr/local/go`, so `FROM` the ubuntu line `AS build` is the safer alternative). Reason: single static Go binary, no language runtime needed; the repo's Go rule forbids compiling in the runtime stage. Closest sibling: `apps/adguardhome-sync` (Go binary on ubuntu, config seeded from `defaults/`) and `apps/cloudflareddns` (CLI that is not a server).

## 4. Dockerfile

1. Build stage (`AS build`): `ARG VERSION`, `ARG TARGETARCH`, `ENV GOCACHE=/tmp/go-cache GOPATH=/tmp/go CGO_ENABLED=0`. Download the tarball with `curl -fsSL "https://github.com/mar-mei/guide2go/archive/refs/tags/${VERSION}.tar.gz" | tar xz --strip-components=1 -C /src`, then `cd /src && GOOS=linux GOARCH=${TARGETARCH} go build -trimpath -ldflags="-s -w" -o /out/guide2go .`. Copy `LICENSE` to `/out/LICENSE`. Do not edit `go.mod`/`go.sum`.
2. Final stage: `FROM` ubuntu line above, `ARG VERSION`, `USER root`.
3. `COPY --from=build /out/guide2go /app/guide2go`, `COPY --from=build /out/LICENSE /usr/share/licenses/guide2go/LICENSE`, `ln -s /app/guide2go /usr/local/bin/guide2go` (so `docker exec -it <c> guide2go -configure /config/guide2go.yaml` works), `chown -R root:root /app && chmod -R 755 /app`. No apt packages (base already has `ca-certificates` and `curl`; no `tzdata` needed beyond the base).
4. `ENV HOME=/config`. `TZ` is read from the environment by Go at runtime.
5. `USER apps` then `COPY --chmod=0755 . /` (this places `start.sh` and `defaults/`).
6. `EXPOSE 8080` (only used when image caching or proxying is enabled), `VOLUME /config`, `WORKDIR /config`.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "guide2go" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=mar-mei/guide2go versioning=semver
  default = "1.2.0"
}
variable "LICENSE" { default = "MIT" }
variable "SOURCE" { default = "https://github.com/mar-mei/guide2go" }
```
Plus the four standard targets and `group "default" { targets = ["image-local"] }`, copied from `apps/adguardhome-sync/docker-bake.hcl` (`docker-metadata-action`, `image` with `args.VERSION` and OCI source/licenses labels, `image-local` tagged `${APP}:${VERSION}`, `image-all` for `linux/amd64` and `linux/arm64`). Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/mar-mei/guide2go"
ports: []
env:
  - { name: TZ, default: "Etc/UTC", required: false }
  - { name: G2G_CONFIG, default: "/config/guide2go.yaml", required: false }
  - { name: G2G_INTERVAL, default: "86400", required: false }
volumes:
  - path: /config
    required: true
dependencies: []
```
- `ports` is empty on purpose: by default the program opens no port. The 8080 image server only starts when the user turns on `Local Images Cache` or `Proxy Images` and sets `Hostname`. Listing it would claim a port the default container does not open. See section 10.
- `G2G_CONFIG` and `G2G_INTERVAL` are read by our `start.sh`, not by upstream (written as `{ ... }` for brevity here; use the sibling's block style in the real file). Dependencies: none (Schedules Direct is an external SaaS).

## 7. start.sh

Idempotent scheduler wrapper (upstream has none, the alturismo image uses cron):
1. `set -u`. `CONFIG="${G2G_CONFIG:-/config/guide2go.yaml}"`, `INTERVAL="${G2G_INTERVAL:-86400}"`, `mkdir -p /config/images`.
2. If `"$CONFIG"` is missing, `cp -n /defaults/guide2go.yaml "$CONFIG"` (never overwrite). The default file is the upstream `sample-config.yaml` with `Files.Cache: /config/cache.json`, `Files.XMLTV: /config/xmltv.xml`, `Images Path: /config/images`, `Local Images Cache: false`, `Proxy Images: false`, `Hostname: localhost:8080`, empty `Account` and no stations. Nothing is written to `/app`; Go caches are not used at runtime.
3. Loop forever: if the config has no `Username:` value, log `guide2go: no Schedules Direct account configured; run: docker exec -it <container> guide2go -configure ${CONFIG}` and wait for the interval; otherwise run `/app/guide2go -config "$CONFIG"` (when image caching is on this call blocks and serves on the configured port, which is the intended behaviour). Log the exit code and sleep `$INTERVAL`.
4. Sleep with `sleep "$INTERVAL" & wait $!` and a `trap 'kill 0; exit 0' TERM INT` so `docker stop` works. A loop cannot end in `exec`; this is the one place the "exec the final process" guideline does not apply. UNVERIFIED: whether `-config` exits non-zero on an empty account; the Username check avoids relying on it.
5. Servers must bind all interfaces: the upstream server listens on `:<port>` (all interfaces), so nothing to change.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 120
mainRunner:
  enabled: false
runners:
  - entrypoint: /app/guide2go
    cmd: -h
    exitCode: 0
filePaths:
  - /app/guide2go
  - /defaults/guide2go.yaml
  - /usr/share/licenses/guide2go/LICENSE
```
No ports are listed in `settings.yaml`, so no tcp/http probe is required. The test runs without env vars, so the account-dependent path (fetching data) cannot be tested; the `-h` runner proves the binary starts. `mainRunner.enabled: false` follows `apps/bookstack` (the CLI has no readiness signal). UNVERIFIED: `mainRunner.enabled: false` together with `filePaths` is accepted by forgetool; if not, drop `mainRunner` and keep the runner plus `filePaths` (the default container stays alive in the idle loop).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| Config file (any path given to `-config`) | `/config/guide2go.yaml` |
| `Files.Cache` (cache.json) | `/config/cache.json` |
| `Files.XMLTV` output | `/config/xmltv.xml` |
| `Images Path` (image cache) | `/config/images` |
| Go build/module cache | build stage only, `GOCACHE=/tmp/go-cache` |
| `$HOME` | `/config` |

Draft expectations: chart forces UID 0 and `readOnlyRootFilesystem: false`; here the image runs as `apps` with a read-only rootfs because every write goes to `/config`. The chart's extra PVCs `/guide2go` and `/TVH` are the alturismo wrapper's paths and are replaced by `/config` (users who want the XML elsewhere can set `Files.XMLTV` and mount that path). Not privileged.

## 10. Risks, caveats and open questions

- Draft caveats kept: no server or UI by default; it is a periodic job and needs a Schedules Direct account.
- Release has no binaries, so a source build (and a Go toolchain stage) is mandatory. The upstream repo has been idle since 2023-03 (last push), so no fixes are expected.
- Draft said "no ports"; true by default but the program does serve HTTP when image cache/proxy is enabled (port from `Hostname`). Open question for the maintainer: expose 8080 in `settings.yaml` as `required: false` and add a tcp probe (would then need a config that enables the cache, which a no-env test cannot provide). Current plan: no port declared, `EXPOSE 8080` only.
- `docker-compose` in upstream README maps `/data/livetv` and `/data/images`; we deviate to `/config`.
- UNVERIFIED: exact behaviour of `-config` when the account is empty (handled by the Username guard).
- Blockers: none (no musl, GPU, privileged or arm64 gap; pure Go).

## 11. Build and test steps

```sh
cd apps/guide2go
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create guide2go-probe-config
docker run --rm -d --name guide2go-probe --read-only --tmpfs /tmp -v guide2go-probe-config:/config guide2go:1.2.0
docker logs -f guide2go-probe     # expect the "no Schedules Direct account configured" line; container must stay running
docker exec guide2go-probe guide2go -h
forgetool containers test --image guide2go:1.2.0 --config ./apps/guide2go/container-test.yaml
docker rm -f guide2go-probe; docker volume rm guide2go-probe-config
```
Readiness signal: the start.sh "configure me" log line and the process staying alive. Also test manually: mount a config with a real account (not possible in CI) and with `Local Images Cache: true` to see `Listening on: :8080`. Optionally build arm64 once.

## 12. PR checklist

- Branch `feat/add-guide2go`; commit and PR title `feat(guide2go): add new container`; target `main`; use `.github/PULL_REQUEST_TEMPLATE.md` with only the true boxes checked.
- Put `🤖 This PR is AI generated.` in the Notes section.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; the `license/cla` check shows status).
- Pre-completion items: bake `--print` ok, version alignment (`ARG VERSION` equals bake `VERSION`), rootless and read-only, empty `/config` starts.
- Untested until run: the image build, arm64, the Go build with the 1.26 toolchain on `go 1.19` modules, real Schedules Direct fetch, the image server mode. Say so in the PR if not run.
