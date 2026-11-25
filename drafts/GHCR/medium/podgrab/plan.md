# podgrab — implementation plan
> Source: ./draft.md · Target: apps/podgrab/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | No GitHub release: `GET /repos/akhilrex/podgrab/releases/latest` returns 404 and the tags list is empty. Draft image tag `ghcr.io/akhilrex/podgrab:1.0.0` is UNVERIFIED. Pin the commit the draft traced: `032248091294dbf5b6a439a5afd93788a7cc647f` (source: https://github.com/akhilrex/podgrab/tree/032248091294dbf5b6a439a5afd93788a7cc647f). |
| Renovate | `datasource=git-refs depName=https://github.com/akhilrex/podgrab currentValue=master` (same pattern as `apps/fenrus`, which pins a master commit). |
| License | GPL-3.0 (GitHub SPDX `GPL-3.0`). Default branch `master`. |
| Source URL | https://github.com/akhilrex/podgrab |
| Download | Source tarball `https://github.com/akhilrex/podgrab/archive/${VERSION}.tar.gz`, compiled with Go. No prebuilt binary and no release assets. |
| Checksum source | None published. The tarball is content-addressed by commit SHA. |
| Go module | `github.com/akhilrex/podgrab`, `go 1.25.0` (https://raw.githubusercontent.com/akhilrex/podgrab/032248091294dbf5b6a439a5afd93788a7cc647f/go.mod). |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/akhilrex/podgrab/032248091294dbf5b6a439a5afd93788a7cc647f/Dockerfile: builder `FROM golang:${GO_VERSION}-alpine` with `ARG GO_VERSION=1.15.2`; `go build -o ./app ./main.go`; final `FROM alpine:latest`; `WORKDIR /api`; `COPY client ./client`, `COPY webassets ./webassets`; `EXPOSE 8080`; `ENTRYPOINT ["./app"]`; no `CMD`; no `USER` (runs as root). |
| Version conflict | Upstream builder pins Go 1.15.2, which cannot build a module that declares `go 1.25.0`. We must use a current Go toolchain. The draft does not mention this. |
| Frontend | Prebuilt `client/` and `webassets/` directories are in the source tree, so no Node build step is needed (confirmed by the upstream Dockerfile copying them directly). |
| Ports | 8080 (upstream `EXPOSE 8080`). |
| Env vars (upstream Dockerfile) | `CONFIG=/config`, `DATA=/assets`, `UID=998`, `PID=100`, `GIN_MODE=release`. Whether the Go code reads `UID`/`PID` is UNVERIFIED (not checked in source); do not list them in `settings.yaml`. |
| Volumes (upstream) | `/config` and `/assets`, both `chmod 777`. |
| Data / config write paths | Upstream: `CONFIG` and `DATA` env. For ContainerForge both move under `/config`: `CONFIG=/config`, `DATA=/config/assets`. Where the app stores its database under `CONFIG` is UNVERIFIED. |
| arm64 | UNVERIFIED for the upstream image (not published). Go builds for arm64 from the same source; confirm with `--platform linux/arm64` build. |
| Dependencies | None. No database service; the app uses an embedded store (UNVERIFIED which). |

## 2. Target layout

- `apps/podgrab/Dockerfile`: build stage plus runtime stage, same shape as `apps/pwndrop`.
- `apps/podgrab/docker-bake.hcl`
- `apps/podgrab/settings.yaml`
- `apps/podgrab/container-test.yaml`
- `apps/podgrab/start.sh`

No `defaults/`, `etc/`, `root/`, or `health/` needed: the app creates its own config and data on first start. No `DOWNSTREAM_CHANGES.md` (not used as a `FROM` base).

## 3. Base image

- Build stage and runtime stage: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`.
- Reason: Go is compiled in the build stage and the binary is copied into the runtime stage. Ubuntu is the final base for Go apps (`apps/pwndrop`, `apps/webgrabplus`).
- Closest sibling: `apps/pwndrop` (Go compiled from source in a `buildstage`, then `COPY --from=buildstage` into the ubuntu runtime stage).

## 4. Dockerfile

1. Build stage: `FROM <ubuntu> AS buildstage`, `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Install the Go toolchain. Ubuntu's `golang-go` may be older than 1.25 (UNVERIFIED for the 26.04 archive). Check the version in the build. If it is older, download the official Go tarball for `${TARGETARCH}` from https://go.dev/dl/ and verify its SHA-256 from the same page, then add it to `PATH`. Do not use the upstream `golang:1.15.2`.
3. `ENV GOCACHE=/tmp/go-cache GOPATH=/tmp/go GOMODCACHE=/tmp/go/pkg/mod`. Build caches stay in `/tmp`.
4. Fetch the source: `curl -fL https://github.com/akhilrex/podgrab/archive/${VERSION}.tar.gz -o /tmp/podgrab.tar.gz && tar xf /tmp/podgrab.tar.gz -C /tmp/podgrab --strip-components=1`.
5. Compile: `cd /tmp/podgrab && CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /app/podgrab/podgrab ./main.go`. Build with `CGO_ENABLED=0` if no cgo dependency is found in `go.mod` (the first 5 requires are listed in the facts file; the full list is UNVERIFIED for cgo use). If the build needs cgo, use `CGO_ENABLED=1` and keep `build-essential` in the build stage only.
6. Copy the frontend: `cp -r /tmp/podgrab/client /tmp/podgrab/webassets /app/podgrab/`.
7. License: `install -D /tmp/podgrab/LICENSE /usr/share/licenses/podgrab/LICENSE` in the runtime stage (copy via the build stage).
8. Runtime stage: `FROM <ubuntu>`, `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
   - `COPY --from=buildstage /app/podgrab/ /app/podgrab/`
   - `COPY --from=buildstage /usr/share/licenses/podgrab/ /usr/share/licenses/podgrab/` (only if the license is copied in the build stage).
   - `chown -R apps:apps /app/podgrab && chmod -R 755 /app/podgrab`.
9. `ENV CONFIG=/config DATA=/config/assets GIN_MODE=release HOME=/config`.
10. Tail, same as `apps/pwndrop`:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 8080
WORKDIR /config
VOLUME /config
```

Note: `apps/pwndrop` runs from `/config` as `WORKDIR`. Podgrab reads `client` and `webassets` relative to its working directory (`WORKDIR /api` upstream). Set `WORKDIR /app/podgrab` for the binary and let `start.sh` change to `/config` only if the app writes relative paths there (UNVERIFIED; check in the build).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "podgrab"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/akhilrex/podgrab currentValue=master
  default = "032248091294dbf5b6a439a5afd93788a7cc647f"
}

variable "LICENSE" {
  default = "GPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/akhilrex/podgrab"
}
```

Then the default group and the four standard targets (`image`, `image-local`, `image-all`) copied from `apps/adguardhome-sync/docker-bake.hcl`. Validate with `docker buildx bake --print` in `apps/podgrab/`.

Renovate note: `git-refs` tracks `master`, so every upstream commit is a PR. That is the same behaviour as `apps/fenrus`. Use `versioning=loose` only if the project later tags releases.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/akhilrex/podgrab"
ports:
  - port: 8080
    protocol: tcp
    required: true
env:
  - name: CONFIG
    default: "/config"
    required: false
  - name: DATA
    default: "/config/assets"
    required: false
  - name: GIN_MODE
    default: "release"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

Rules check: `CONFIG`, `DATA`, `GIN_MODE` are set in the Dockerfile and read by `start.sh`. `TZ` is a standard ContainerForge variable (`apps/adguardhome-sync`). Do not list `UID` or `PID` (see section 1). `/assets` is not listed, because the image maps `DATA` under `/config`.

## 7. start.sh

```bash
#!/usr/bin/env bash

CONFIG="${CONFIG:-/config}"
DATA="${DATA:-/config/assets}"

mkdir -p "${CONFIG}" "${DATA}"

export CONFIG DATA GIN_MODE="${GIN_MODE:-release}"

cd /app/podgrab || exit 1
exec /app/podgrab/podgrab
```

- Idempotent: `mkdir -p` only; no seeding is needed because the app creates its own state.
- Never writes to `/app`.
- Listens on all interfaces: confirm that `main.go` binds `0.0.0.0:8080` (UNVERIFIED; check the source; if it binds localhost, patch the port via env only if the app supports it, otherwise stop and record a blocker).
- `exec` hands PID 1 to the binary.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '8080'
```

- One TCP probe for the single port in `settings.yaml`.
- No Go sibling sets `timeoutSeconds`; 120 is a starting value and may be changed after measuring startup.
- Empty environment: the default `CONFIG`/`DATA` in the Dockerfile are used, so no `filePaths` are needed.

## 9. Rootless and read-only-rootfs adaptations

| Upstream | Our version | Reason |
| --- | --- | --- |
| Runs as root (no `USER`) | `USER apps` | Rootless rule. The app only needs port 8080 (above 1024). |
| `UID=998`, `PID=100` env | Not used | Not read by the app (UNVERIFIED); the runtime user is `apps`. |
| `chmod 777 /config /assets` | Not needed | `/config` is owned by `apps` through the base image. |
| `DATA=/assets` volume | `DATA=/config/assets` | Single persistent volume `/config` (the chart uses `/config` only: "extra-persistence: none"). |
| `/app` writes (none upstream) | None | `/app/podgrab` is read-only at runtime. |
| Caches | `GOCACHE`, `GOMODCACHE` in `/tmp` | Build caches must not reach `/config`. |

Chart reconciliation (from the draft's security expectations): the chart runs as 568 with `readOnlyRootFilesystem: true` and `privileged: false`. Our image matches on all three, so no chart-side override is expected.

## 10. Risks, caveats and open questions

- Go version: upstream `golang:1.15.2` cannot build `go 1.25.0`. The toolchain version must be chosen in the build (section 4 step 2). Blocker if no Go >= 1.25 is obtainable.
- Version not verified: there is no release. The image tag `1.0.0` in the chart is UNVERIFIED. We pin a commit, not a version. Confirm the commit still builds on `master` when the PR is opened.
- Listen address: upstream `EXPOSE 8080` only; the bind address in `main.go` is UNVERIFIED.
- Database location: where the app stores its database under `CONFIG` is UNVERIFIED. Confirm empty `/config` first start works (the protocol requires it).
- Disk: podcast downloads grow without limit (from the draft). The `/config` volume must be sized by the user.
- arm64: the Go build is portable but has not been built for arm64 (UNVERIFIED).
- Blockers: none confirmed. Stop and report if the Go toolchain or the bind address fails.

## 11. Build and test steps

Run from `apps/podgrab/`, in this order (`.github/instructions/build-test-protocol.instructions.md`):

1. `docker buildx bake --print`: must exit 0.
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`: must build.
3. Probe with an empty config volume:
   ```sh
   docker volume create podgrab-probe-config
   docker run --rm -d --name podgrab-probe --read-only --tmpfs /tmp \
     -v podgrab-probe-config:/config podgrab:<version>
   docker logs -f podgrab-probe
   ```
   Expected readiness signal: a line such as `listening on` or a Gin route banner on port 8080 (exact text UNVERIFIED; confirm in the build), and the container still running.
   Cleanup: `docker rm -f podgrab-probe; docker volume rm podgrab-probe-config`.
4. Test suite: `forgetool containers test --image podgrab:<version> --config ./apps/podgrab/container-test.yaml`.

## 12. PR checklist

- Branch: `feat/add-podgrab` from `main`.
- Commit: `feat(podgrab): add new container`.
- PR title: `feat(podgrab): add new container`.
- PR description: fill in `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections and checkboxes, and tick only what was done. Mention the Go version used and the pinned commit.
- Notes section: `🤖 This PR is AI generated.`
- CLA: contributions need a signed CLA at https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it. Tell the user when the PR opens. The `license/cla` check shows the status.
- Not tested (state in the PR if it applies): arm64 build, the upstream frontend in a browser, the database path under `/config`, and any run that has not been executed.
