# hammond — implementation plan
> Source: ./draft.md · Target: apps/hammond/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | v0.0.24, published 2024-01-12, the latest release and tag (https://api.github.com/repos/AlfHou/hammond/releases/latest; tags list https://api.github.com/repos/AlfHou/hammond/tags). Matches the draft tag `ghcr.io/alfhou/hammond:v0.0.24`. No newer tag exists. |
| Renovate | `datasource=github-tags depName=AlfHou/hammond versioning=semver` (proposed; not checked against renovate config). |
| License | AGPL-3.0 (https://api.github.com/repos/AlfHou/hammond, `license.spdx_id`; repo `LICENSE` file). |
| Source URL | https://github.com/AlfHou/hammond |
| Per-arch download | None. No release assets. Build the Go API and the Vue UI for amd64 and arm64. |
| Source tarball | `https://github.com/AlfHou/hammond/archive/refs/tags/${VERSION}.tar.gz` (tag `v0.0.24`). |
| Checksum source | None published. Pin by tag; UNVERIFIED that the tag resolves to commit `c167642b889a7d939e6087d9bda9854d4346ee5c` (the commit the draft traced). |
| Upstream Dockerfile reviewed | https://api.github.com/repos/AlfHou/hammond/contents/Dockerfile?ref=c167642b889a7d939e6087d9bda9854d4346ee5c : `ARG GO_VERSION=1.20.6`; builder `golang:${GO_VERSION}-alpine` runs `go build -o ./app ./main.go` in `./server`; UI stage `node:16-alpine` runs `npm install` and `npm run build` in `./ui`; final `alpine:latest`, `ENV CONFIG=/config DATA=/assets UID=998 PID=100 GIN_MODE=release`, `VOLUME ["/config","/assets"]`, `chmod 777` on both, `WORKDIR /api`, `COPY app` and `dist`, `EXPOSE 3000`, `ENTRYPOINT ["./app"]`. No `USER`. |
| Go module | `server/go.mod`: `module hammond`, `go 1.16`. |
| UI build | `ui/package.json`: `"build": "vue-cli-service build --modern"` (output `dist`). Upstream builds it on Node 16. |
| Port | 3000/http. `server/main.go` line 59: `r.Run(":3000")`, which is not configurable by env. The draft's 8080 is wrong for this commit. |
| Env vars (real) | `DATA` (assets directory, read at `server/main.go` line 39), `CONFIG` (logged at line 81, see section 10). `GIN_MODE=release` is set in the Dockerfile. `UID` and `PID` are set in the Dockerfile; no read of them is seen in the code reviewed: UNVERIFIED. |
| Data paths | `CONFIG` = `/config`, `DATA` = `/assets` upstream. `/assets` is a second volume upstream. |
| Architectures | Compiles on both arches; no prebuilt binary. |
| copy-from | No. Upstream's final image is `alpine:latest` (musl). |

## 2. Target layout

- `apps/hammond/Dockerfile`
- `apps/hammond/docker-bake.hcl`
- `apps/hammond/settings.yaml`
- `apps/hammond/container-test.yaml`
- `apps/hammond/start.sh`

No `defaults/` unless an empty assets directory needs a placeholder (not needed). No `etc/`, `root/`. No `DOWNSTREAM_CHANGES.md` (not used as a `FROM` base).

## 3. Base image

Final stage: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`. Upstream uses `alpine:latest`; we switch to the glibc ubuntu base like the other ContainerForge apps.

Closest sibling: `apps/pwndrop` (ubuntu build stage copied into an ubuntu runtime stage). The UI build stage follows the same pattern.

## 4. Dockerfile

1. Go build stage: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:... AS gobuild`, `ARG VERSION`, `USER root`. Install Go with `apt-get install -y --no-install-recommends golang-go` (the upstream `go 1.16` directive is satisfied by any newer toolchain; confirm the version in the build log, UNVERIFIED). Set `ENV GOCACHE=/tmp/go-cache GOMODCACHE=/tmp/go-mod`.
2. UI build stage: `FROM <node-builder> AS uibuild` with a Node LTS image supported by the upstream Vue CLI build. Node 16 is end-of-life; test the build on a supported Node version first and record the version. The image tag is UNVERIFIED; pin a digest once chosen. Fallback: install nodejs from apt in the ubuntu base. `npm ci` (or `npm install`, as upstream does) then `npm run build` in `ui`.
3. Fetch source once in a shared step: `curl -fL "https://github.com/AlfHou/hammond/archive/refs/tags/${VERSION}.tar.gz" -o /tmp/hammond-src.tar.gz`, extract to `/tmp/hammond` with `--strip-components=1`. `VERSION` is `v0.0.24`.
4. Go API: `cd /tmp/hammond/server && CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /app/hammond/app ./main.go`.
5. UI: copy `/tmp/hammond/ui` into the UI stage and build; copy `dist` to `/app/hammond/dist`.
6. Final stage: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:...`, `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
7. `COPY --from=gobuild /app/hammond/ /app/hammond/` and `COPY --from=uibuild /app/hammond/dist /app/hammond/dist`.
8. License: `COPY --from=gobuild /tmp/hammond/LICENSE /usr/share/licenses/hammond/LICENSE` (copy the file into the build stage as part of step 3 so this is a single `COPY --from`).
9. `chown -R apps:apps /app/hammond && chmod -R 755 /app/hammond`. Do not use `chmod 777` as upstream does.
10. `ENV HOME=/config CONFIG=/config/config DATA=/config/assets GIN_MODE=release`. (`CONFIG` is set to a sub-path so it is inside the single `/config` volume; see section 10.)
11. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 3000
VOLUME /config
WORKDIR /app/hammond
```

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "hammond"
}

variable "VERSION" {
  // renovate: datasource=github-tags depName=AlfHou/hammond versioning=semver
  default = "v0.0.24"
}

variable "LICENSE" {
  default = "AGPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/AlfHou/hammond"
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

`VERSION` keeps the `v` because the tag does. Validate with `docker buildx bake --print` from `apps/hammond/`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/AlfHou/hammond"
ports:
  - port: 3000
    protocol: tcp
    required: true
env:
  - name: CONFIG
    default: "/config/config"
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

Only variables the code reads or the Dockerfile sets are listed. `UID` and `PID` are not listed (not confirmed as read). `DATA` and `CONFIG` defaults match `start.sh`.

## 7. start.sh

```bash
#!/bin/sh
set -eu

mkdir -p /config/config /config/assets

export CONFIG="${CONFIG:-/config/config}"
export DATA="${DATA:-/config/assets}"
export GIN_MODE="${GIN_MODE:-release}"

cd /app/hammond
echo "Starting hammond with CONFIG=${CONFIG} DATA=${DATA}"
exec ./app
```

- Idempotent: only creates directories if missing; no seed files. The assets directory is populated by the user, as upstream requires.
- Nothing writes to `/app`. Caches are in `/tmp` at build time only.
- `exec` hands PID 1 to the Go API.
- Gin listens on `:3000` (all interfaces) by default, so other containers can reach it.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

tcp:
- port: '3000'
http:
- port: '3000'
  path: /
```

- Every port in `settings.yaml` has a probe (3000).
- `/` is the UI. Confirm the status code on the first run (UNVERIFIED expected status).
- `timeoutSeconds`: copy the sibling value from `apps/pwndrop/container-test.yaml`.
- Test runs without env vars: defaults in `start.sh` apply. `filePaths`: `/app/hammond/app` (existence), `/app/hammond/dist/index.html` (UI build present; UNVERIFIED that this file is produced by the Vue build).

## 9. Rootless and read-only-rootfs adaptations

- Upstream runs as root (alpine default) and makes `/config` and `/assets` world-writable with `chmod 777`. We run as `apps` and keep ownership on `/config` only.
- Read-only rootfs: `/app/hammond` is read-only at run time; all writes go to `/config`. The app's log output goes to stdout.
- Upstream `UID=998` / `PID=100` are not applied (no read confirmed); the container runs as `apps`.
- Upstream extra persistence `/assets` is folded into `/config/assets` so the chart needs only one volume.

## 10. Risks, caveats and open questions

- Trace confidence was low in the draft. The Dockerfile at `c167642` is confirmed, and the tag `v0.0.24` matches the chart tag, but no release notes exist.
- Port 3000 is hard-coded in `main.go`. Changing it requires a code patch, which the plan does not do.
- The `CONFIG` value is logged, but the code reviewed does not show what it writes there. Confirm on first run: if the app writes nothing to `CONFIG`, keep the default and note it.
- Node 16 is end-of-life, and the Vue CLI build may fail on modern Node (OpenSSL changes). If it does, record the failure and fix the build stage only; do not change the UI source.
- Go 1.20.6 upstream vs `golang-go` from apt: confirm the apt version builds the module.
- The assets directory must be populated by the user (`/config/assets`); the app ships no content.
- No blockers for amd64 or arm64 once built (no prebuilt binary).

## 11. Build and test steps

From `apps/hammond/`:

```sh
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name hammond-probe --read-only --tmpfs /tmp \
  -v hammond-probe-config:/config hammond:v0.0.24
docker logs -f hammond-probe
docker rm -f hammond-probe; docker volume rm hammond-probe-config
forgetool containers test --image hammond:v0.0.24 --config ./apps/hammond/container-test.yaml
```

Expected readiness signal: `Starting hammond with CONFIG=... DATA=...` from `start.sh`, then Gin's `Listening and serving HTTP on :3000` line (Gin's standard text; confirm on the first run). The container must still be running after startup.

Run once with an empty `/config` and once more on restart with the same volume.

## 12. PR checklist

- Branch: `feat/add-hammond`.
- Commit: `feat(hammond): add new container`.
- PR title: `feat(hammond): add new container`.
- PR description: Notes section contains `🤖 This PR is AI generated.`, uses `.github/PULL_REQUEST_TEMPLATE.md`, and only checked boxes that apply.
- CLA: tell the user the PR needs a signed CLA at https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it).
- Untested: arm64 build and the UI status code until built; say so in the PR if not run.
- Checklist: bake print passes, image-local amd64 builds, container starts read-only with empty `/config`, `container-test.yaml` passes, no assertion weakened.
