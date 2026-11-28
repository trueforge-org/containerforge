# filestash — implementation plan
> Source: ./draft.md · Target: apps/filestash/ · Difficulty: medium · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Upstream has no GitHub releases and the newest tag is stale (`v0.4`; the code says `APP_VERSION = "v0.6"` in `server/pkg/env/constants.go`). The Docker image is a rolling build of master. This plan pins master commit `331fb8be7255a0a24a16c3f7c1e6710ffec428c6` (checked 2026-11-24). Docker Hub `machines/filestash:latest` was updated 2026-11-24. |
| Difference from draft | The draft says "Go backend with a Node frontend build". Upstream `docker/Dockerfile` now has only a Go build (`make init && make build`, `golang:1.27.0-trixie`) and `debian:stable-slim`; there is no Node stage, so the base is plain ubuntu and `python-node` is not needed. The draft's `/app/data/state` path is confirmed (`FILESTASH_PATH` default `data/`). |
| Renovate | `datasource=git-refs depName=https://github.com/mickael-kerjean/filestash currentValue=master` (precedent `apps/tvheadend`) |
| License | AGPL-3.0 (GitHub SPDX `AGPL-3.0`; `LICENSE` is the GNU AGPL v3 text) -> `AGPL-3.0-only` in bake, matching the GitHub SPDX id (open question: upstream may allow "or later", UNVERIFIED) |
| Source URL | https://github.com/mickael-kerjean/filestash |
| Download | Source tarball `https://github.com/mickael-kerjean/filestash/archive/${VERSION}.tar.gz` (VERSION = commit SHA), compiled for amd64 and arm64. No prebuilt binary. |
| Checksum source | None; the tarball is pinned by commit SHA. |
| Upstream Dockerfile reviewed | `docker/Dockerfile` (3 stages: `alpine/git` clone of unpinned master, `golang:1.27.0-trixie` build, `debian:stable-slim` runtime; runtime packages `ca-certificates curl ffmpeg libbrotli1 poppler-utils`; user `filestash`; `chmod 730 /app/filestash`; `CMD ["/app/filestash"]`; `EXPOSE 8334`). |
| Build | `go 1.27.0` in `go.mod`. Makefile: `go get ./...`, `go generate -x ./server/...`, `go build --tags "fts5" -o dist/filestash cmd/main.go` (cgo). Build libraries used upstream: `libjpeg-dev libtiff-dev libpng-dev libwebp-dev libraw-dev libheif-dev libgif-dev libvips-dev libavcodec-dev libavdevice-dev libavfilter-dev libavformat-dev libswresample-dev libswscale-dev libavutil-dev curl make`. The ContainerForge ubuntu base ships Go (`GO_VERSION` 1.27.4 in `apps/ubuntu/docker-bake.hcl`, `/usr/local/go/bin`), which satisfies 1.27.0. |
| Port | 8334, set by the admin config `general.port`, default from env `FILESTASH_PORT` (`server/pkg/config/config.go`: `defaultValue(8334, "FILESTASH_PORT")`). HTTP server binds `:%d` (all interfaces; `plg_starter_http`). Log line `[http] listening on :8334`. |
| Health | `GET /healthz` (also `HEAD`) in `server/routes.go`; checks `config.json` readable, `/about`, secret key. |
| Env vars (real, from code) | `FILESTASH_PATH` (data root, default `data/`; sub-dirs `state/config`, `state/certs`, `state/plugins`, `state/db`, `state/search`, `state/log`, `cache/`), `FILESTASH_PORT`, `FILESTASH_BASE`, `APPLICATION_URL` (-> `general.host`), `ADMIN_PASSWORD` (-> `auth.admin`, UNVERIFIED whether a bcrypt hash is required), `CONFIG_SECRET` (encrypts secrets in `config.json`), `LOG_LEVEL`, `DEBUG=true`. |

## 2. Target layout

- `apps/filestash/Dockerfile`
- `apps/filestash/docker-bake.hcl`
- `apps/filestash/settings.yaml`
- `apps/filestash/container-test.yaml`
- `apps/filestash/start.sh`

No `defaults/` (the app writes `config.json` itself and generates `general.secret_key` on first start). No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a` for the build stage (Go already installed in the base) and for the final stage. Closest sibling: `apps/pwndrop` (Go build stage, then runtime stage) and `.github/instructions/go-runtime.instructions.md`.

## 4. Dockerfile

1. Build stage `FROM <ubuntu> AS build`, `ARG VERSION`, `USER root`, `ENV GOPATH=/tmp/go GOCACHE=/tmp/gocache GOFLAGS=-mod=mod` (override the base's `GOPATH=/config/go`; caches must stay in `/tmp`; drop `GOFLAGS` if the repo vendors modules).
2. `apt-get update && apt-get install -y --no-install-recommends build-essential pkg-config make libjpeg-dev libtiff-dev libpng-dev libwebp-dev libraw-dev libheif-dev libgif-dev libvips-dev libavcodec-dev libavdevice-dev libavfilter-dev libavformat-dev libswresample-dev libswscale-dev libavutil-dev`. Package names are from Debian trixie; their 26.04 names (t64 suffixes) are UNVERIFIED. Do not re-add `curl`, `git`, `tar` (in base).
3. `curl -fL https://github.com/mickael-kerjean/filestash/archive/${VERSION}.tar.gz | tar xz -C /tmp/src --strip-components=1`.
4. `cd /tmp/src && make init && make build` (output `dist/filestash`). Do not modify `go.mod` or `go.sum` (go-runtime rules).
5. Final stage `FROM <ubuntu>`, `USER root`, `apt-get install -y --no-install-recommends ffmpeg libbrotli1 poppler-utils` plus the runtime shared libs that `ldd /app/filestash/filestash` reports as `not found` (candidate list from the `-dev` packages above, e.g. `libvips42t64`, `libheif1`, `libraw23t64`; UNVERIFIED which are needed). `ca-certificates` and `curl` are already in the base. Clean `/var/lib/apt/lists/*`. No version pins: these are system libraries, not the app (the app is pinned by commit).
6. `mkdir -p /app/filestash && COPY --from=build /tmp/src/dist/ /app/filestash/`. License: `COPY --from=build /tmp/src/LICENSE /usr/share/licenses/filestash/LICENSE`.
7. `chown -R apps:apps /app/filestash && chmod -R 755 /app/filestash` (upstream used `chmod 730`; 755 is needed so UID 568 can exec read-only).
8. `ENV FILESTASH_PATH=/config` and `ENV HOME=/config` (the base sets `HOME=/config`).
9. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 8334
VOLUME /config
WORKDIR /config
```

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "filestash" }
variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/mickael-kerjean/filestash currentValue=master
  default = "331fb8be7255a0a24a16c3f7c1e6710ffec428c6"
}
variable "LICENSE" { default = "AGPL-3.0-only" }
variable "SOURCE" { default = "https://github.com/mickael-kerjean/filestash" }
```

Standard four targets plus default group from `apps/adguardhome-sync`; run `docker buildx bake --print`. Dockerfile `ARG VERSION` consumes the same SHA.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/mickael-kerjean/filestash"
ports:
  - port: 8334
    protocol: tcp
    required: false
env:
  - name: FILESTASH_PORT
    default: "8334"
    required: false
  - name: APPLICATION_URL
    default: ""
    required: false
  - name: ADMIN_PASSWORD
    default: ""
    required: false
  - name: CONFIG_SECRET
    default: ""
    required: false
  - name: LOG_LEVEL
    default: "INFO"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

`FILESTASH_PATH=/config` is fixed by the image (not a user setting). Dependencies: none (SQLite and search index are embedded; storage backends are user supplied). If `ADMIN_PASSWORD` stays empty the admin console is set up through the UI at `/admin/setup`.

## 7. start.sh

```bash
#!/usr/bin/env bash

export FILESTASH_PATH="${FILESTASH_PATH:-/config}"

mkdir -p \
    "${FILESTASH_PATH}/state/config" \
    "${FILESTASH_PATH}/state/certs" \
    "${FILESTASH_PATH}/state/plugins" \
    "${FILESTASH_PATH}/state/db" \
    "${FILESTASH_PATH}/state/search" \
    "${FILESTASH_PATH}/state/log" \
    /tmp/filestash-cache

# TMP_PATH is <FILESTASH_PATH>/cache: keep it ephemeral in /tmp
if [[ ! -e "${FILESTASH_PATH}/cache" ]]; then
    ln -s /tmp/filestash-cache "${FILESTASH_PATH}/cache"
fi

cd /app/filestash
exec /app/filestash/filestash
```

Idempotent; no writes to `/app`; `config.json` and the secret key are created by the app on first start (`Initialise()` saves when `general.secret_key` is empty). `ADMIN_PASSWORD`, `APPLICATION_URL`, `CONFIG_SECRET` and `FILESTASH_PORT` are read by the app directly from the environment, so they are only passed through. The HTTP starter binds `:port`, i.e. all interfaces.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '8334'
http:
- port: '8334'
  path: /healthz
filePaths:
- /app/filestash/filestash
- /usr/share/licenses/filestash/LICENSE
- /usr/bin/ffmpeg
```

Port 8334 has tcp and http probes. `/healthz` returns 200 only when `config.json` exists, which the app creates at first start. The test runs with no env vars; `ADMIN_PASSWORD` and `CONFIG_SECRET` paths are not testable and are verified manually (section 11).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/app/data/state/{config,certs,plugins,db,search,log}` (draft: chart pvc `/app/data/state`) | `FILESTASH_PATH=/config` -> `/config/state/...` |
| `/app/data/cache` (`TMP_PATH`) | `/config/cache` symlink to `/tmp/filestash-cache` (created by `start.sh`) |
| `config.json` (admin config) | `/config/state/config/config.json`, persistent |

Draft expectations reconciled: chart runs as UID 0 with `readOnlyRootFilesystem: false`; this image runs as `apps` (568) with a read-only rootfs because nothing is written under `/app`. Persistence moves from `/app/data/state` to `/config/state`: existing chart data must be mounted so that `state/` sits directly under `/config`. Not privileged.

## 10. Risks, caveats and open questions

- Reproducibility: upstream clones unpinned master; this plan pins a commit, so Renovate will propose a bump on every upstream push.
- Cgo build deps on Ubuntu 26.04 may differ from Debian trixie names (UNVERIFIED); runtime library set is determined with `ldd` after the first build.
- `go generate` and `go get` need network at build time; module downloads go to `/tmp/go` only.
- The app version string in the UI will read `v0.6` (+ build ref) rather than a release number.
- `ADMIN_PASSWORD` expected format (plain vs bcrypt) is UNVERIFIED; check `auth.admin` handling in `server/plugin/plg_authenticate_admin` before documenting it.
- Several build toolchains make the image large; ffmpeg adds many libraries.
- Plugin loading from `state/plugins` is runtime-discovered (`extension.Discovery`); user-supplied plugins live in `/config` and are not covered.
- No blockers: glibc-based, arm64 supported by Go and apt libraries (arm64 not built here).

## 11. Build and test steps

```sh
cd apps/filestash
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name filestash-probe --read-only --tmpfs /tmp \
  -v filestash-probe-config:/config filestash:331fb8be7255a0a24a16c3f7c1e6710ffec428c6
docker logs -f filestash-probe
docker exec filestash-probe ldd /app/filestash/filestash | grep "not found"
forgetool containers test --image filestash:331fb8be7255a0a24a16c3f7c1e6710ffec428c6 --config ./apps/filestash/container-test.yaml
docker rm -f filestash-probe; docker volume rm filestash-probe-config
```

Readiness signal: `[http] listening on :8334`; `curl -f http://localhost:8334/healthz` returns `{"status":"pass"...}` (shape UNVERIFIED) from outside the container (`-p 8334:8334`). Manually repeat once with `ADMIN_PASSWORD` and `CONFIG_SECRET` set and restart to confirm they apply on every start.

## 12. PR checklist

- Branch `feat/add-filestash`, commit and PR title `feat(filestash): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections, check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA notice: signed CLA required (https://cla-assistant.io/trueforge-org/containerforge); only the user can sign, `license/cla` shows status.
- Untested to state honestly: the cgo build on Ubuntu 26.04 (library names), arm64, runtime library completeness, `ADMIN_PASSWORD` semantics, migration of existing `/app/data/state` data.
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION`; no assertion weakened.
