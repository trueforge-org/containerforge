# watcharr — implementation plan
> Source: ./draft.md · Target: apps/watcharr/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | v4.4.0 (GitHub latest release, published 2026-11-18). Source: https://api.github.com/repos/sbondCo/Watcharr/releases/latest (read via `gh api`). Draft container tag `ghcr.io/sbondco/watcharr:v4.4.0` matches. |
| Renovate | `datasource=github-releases depName=sbondCo/Watcharr versioning=semver` (tags are `v`-prefixed semver; `VERSION` stored without the `v`). |
| License | GPL-3.0 (GitHub SPDX `GPL-3.0`). Source: https://api.github.com/repos/sbondCo/Watcharr/license |
| Source URL | https://github.com/sbondCo/Watcharr |
| Download | No release binaries (release has no assets). Build from the source tarball `https://github.com/sbondCo/Watcharr/archive/refs/tags/v${VERSION}.tar.gz` (UNVERIFIED that the tag tarball is the same tree as the release commit; GitHub tag archives are standard). |
| Checksum source | None published for a binary. The tarball is pinned by tag `v${VERSION}`; the tag's commit SHA was not resolved in this run (UNVERIFIED). |
| Per-arch | amd64: compile. arm64: compile. No ready-made executable for either. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/sbondCo/Watcharr/v4.4.0/Dockerfile. Three stages: `golang:1.27-alpine` (cgo build of `/server/watcharr`, `CGO_ENABLED=1`, `CGO_CFLAGS="-D_LARGEFILE64_SOURCE"`, installs `musl-dev gcc build-base`), `node:24-alpine` UI build (`npm install && npm run build`, output `/app/build`), and `node:24-alpine` runner (`COPY --from=server /server/watcharr /`, `COPY --from=ui /app/build /ui`, `npm ci --omit=dev` in `/ui`, `EXPOSE 3080`, `CMD ["/watcharr"]`). No ENV, VOLUME, USER or ENTRYPOINT upstream. |
| Go version | `go 1.27` in `server/go.mod` (verified via `gh api`). |
| Port | `3080/tcp`. Source: `server/watcharr.go` binds `0.0.0.0:` + `port()`; `port()` returns `PORT` or `3080`. Upstream Dockerfile `EXPOSE 3080`. |
| Env vars (real) | `WATCHARR_DATA` (data dir, default `./data`; read in `server/config/config.go`), `PORT` (default `3080`; `server/watcharr.go`), `MODE` (only `DEV` is checked; dev-only, not exposed). Source doc: `doc/docs/server_config/environment-variables.md` at v4.4.0. |
| Data paths | Default `./data` relative to cwd. Holds `watcharr.db` and `watcharr.db-wal` (SQLite, users and watchlists), `watcharr.json` (server config), `img/up` (profile uploads), `img/games` (game posters when enabled). Source: https://watcharr.app/docs/server_config/backup and `config.go`. Upstream compose mounts `./data:/data` (`docker-compose.yml` at v4.4.0). |
| Dependencies | None. SQLite is embedded. |
| arm64 image | UNVERIFIED: `ghcr.io/sbondco/watcharr` manifest was not inspected. Build from source is the plan for both arches, so the upstream image is not needed. |
| Chart | Draft: chart `watcharr`, role `main`, UI and server in one process, SQLite data under `/data` in chart. |

## 2. Target layout

- `apps/watcharr/Dockerfile`
- `apps/watcharr/docker-bake.hcl`
- `apps/watcharr/settings.yaml`
- `apps/watcharr/container-test.yaml`
- `apps/watcharr/start.sh`

No `defaults/`, `etc/` or `health/` needed: Watcharr creates its data on first start. No `root/` (never used). No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

Final stage: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`. The Go server is the only runtime process and needs no interpreter, so ubuntu alone is enough (draft's "Runtime image: none"). The python-node alternative in the draft is not needed: the Node runtime is only used upstream to run `npm ci` for `/ui`, and the upstream CMD runs only `/watcharr` (see open question in section 10).

Build stages: `FROM golang:1.27-bookworm@sha256:<digest resolved at implementation; UNVERIFIED>` for the Go binary (glibc, so it links against the same glibc family as ubuntu), and `FROM node:24-bookworm@sha256:<digest resolved at implementation; UNVERIFIED>` for the UI. Digests are not in the brief and were not fetched; resolve them with `docker buildx imagetools inspect` before the first build, and keep the pinned form.

Closest sibling: `apps/pwndrop` (Go build stage copied into a ubuntu runtime stage with `COPY --from=buildstage`). Second sibling for UI-in-build-stage: `apps/changedetection` (node in the build path, runtime `apps` user).

## 4. Dockerfile

1. Build stage Go: `FROM golang:1.27-bookworm@<digest> AS build-go`, `ARG VERSION`, `USER root`. Fetch source: `curl -fL https://github.com/sbondCo/Watcharr/archive/refs/tags/v${VERSION}.tar.gz -o /tmp/watcharr.tar.gz && tar xzf ... -C /tmp/watcharr --strip-components=1`.
2. Compile: `cd /tmp/watcharr/server && CGO_ENABLED=1 CGO_CFLAGS="-D_LARGEFILE64_SOURCE" GOOS=linux go build -trimpath -ldflags="-s -w" -o /out/app/watcharr/watcharr .` (matches upstream `CGO_ENABLED=1` and `CGO_CFLAGS`; `-trimpath` and `-s -w` are additions for smaller binaries, confirm they do not break the build). `GOCACHE=/tmp/go-cache`, `GOPATH=/tmp/go` so no cache is written into the image.
3. Build stage UI: `FROM node:24-bookworm@<digest> AS build-ui`, `ARG VERSION`. Fetch the same tag tarball, `cd` into the UI sources (the upstream `Dockerfile` copies `package*.json vite.config.ts svelte.config.js tsconfig.json`, then `src`, `static` from repo root), `npm install && npm run build`, then copy `build/` into `/out/app/watcharr/ui/`. Keep the production dependency set: `npm ci --omit=dev --ignore-scripts=true` in `/out/app/watcharr/ui/` only if the built output needs `node_modules` at runtime (see section 10).
4. Final stage: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`, `ARG VERSION`, `ARG TARGETARCH`, `USER root`. No apt packages are needed at runtime (the Go binary is static-ish with cgo against glibc only; confirm with `ldd` in the build stage, UNVERIFIED that the SQLite driver is pure Go and needs no libsqlite3 at runtime).
5. `COPY --from=build-go /out/app/watcharr/ /app/watcharr/` and `COPY --from=build-ui /out/app/watcharr/ui/ /app/watcharr/ui/`. Licence file: `COPY --from=build-go /tmp/watcharr/LICENSE /usr/share/licenses/watcharr/LICENSE` (copy the license into the build stage output, not from the final stage source tree; GPL-3.0 notice must ship).
6. `RUN chown -R apps:apps /app/watcharr && chmod -R 755 /app/watcharr`.
7. `ENV WATCHARR_DATA=/config/data PORT=3080 HOME=/config TMPDIR=/tmp`.
8. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 3080

WORKDIR /config
VOLUME /config

CMD ["/start.sh"]
```

`COPY --chmod=0755 . /` is required (copies `start.sh` from the allow-list). `WORKDIR /config` keeps the relative default `./data` correct even though `WATCHARR_DATA` is set.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "watcharr"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=sbondCo/Watcharr versioning=semver
  default = "4.4.0"
}

variable "LICENSE" {
  default = "GPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/sbondCo/Watcharr"
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

The `VERSION` is `4.4.0` (tag `v4.4.0`). Dockerfile `ARG VERSION` consumes the same value; the source URL adds the `v`. Validate with `docker buildx bake --print` from `apps/watcharr/`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/sbondCo/Watcharr"
ports:
  - port: 3080
    protocol: tcp
    required: false
env:
  - name: PORT
    default: "3080"
    required: false
  - name: WATCHARR_DATA
    default: "/config/data"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

Dependencies: none (no `dependencies:` section needed). `WATCHARR_DATA` and `PORT` are read by the app (verified in source). `TZ` is an image-level convention (siblings list it), not read by Watcharr code that was reviewed; keep it only because every sibling lists it (UNVERIFIED that Watcharr honours it).

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p "${WATCHARR_DATA:-/config/data}"

cd /app/watcharr
exec /app/watcharr/watcharr
```

- Idempotent. Creates the data directory only. Watcharr creates `watcharr.db` and `watcharr.json` on first start (UNVERIFIED exact first-run behaviour; the backup docs name the files).
- No writes to `/app`. Caches are `/tmp` (no runtime cache expected).
- The Go server binds `0.0.0.0:$PORT` (verified), so no network change is needed.
- `exec` keeps the binary as PID 1 for signal handling.
- The first run asks for an admin account in the UI (draft caveat, not verified in source).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '3080'
filePaths:
- /app/watcharr/watcharr
- /app/watcharr/ui
- /usr/share/licenses/watcharr/LICENSE
```

- Every settings port has a probe: `3080` tcp. An `http` probe on `/` is not added until the response is checked (UNVERIFIED that `/` returns 200 before setup; the UI is served by the Go binary per the plan's assumption in section 10).
- `timeoutSeconds: 120` is a conservative value for a cgo Go binary on first start. Compare with the closest sibling's `timeoutSeconds` before finalising (not checked in this run).
- Test runs with no env vars, so the default data path `/config/data` is exercised with an empty `/config`.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `./data` (default, cwd-relative; upstream image has no WORKDIR, so it resolves to `/data`) | `WATCHARR_DATA=/config/data` set in Dockerfile and settings |
| `/data` (upstream compose mount) | Not used. Persistent state is `/config`. Users migrating from the chart must copy `/data` into `/config/data`. |
| Go build cache, npm cache | Build stages only, redirected to `/tmp`; none in the final image |
| Runtime temp files | `TMPDIR=/tmp` (ephemeral under `--tmpfs /tmp`) |

Draft expectations reconciled:
- Chart runs as UID 0 and `readOnlyRootFilesystem: false`. This plan runs as `apps` and works with `--read-only --tmpfs /tmp`; the chart's overrides are not copied.
- Not privileged, no hostNetwork, no extra persistence (draft says `none beyond /data`; this matches the plan).
- Upstream image has no `USER`, so it runs as root. The plan's `USER apps` is a deliberate change and must be tested (the app must not need root for any path under `/config` or `/app`).

## 10. Risks, caveats and open questions

- **UI serving (open):** the upstream runner stage uses Node only for `npm ci --omit=dev` in `/ui`, and CMD runs only `/watcharr`. This suggests the Go server serves the built UI from `/ui`, but the path the server reads for the UI is UNVERIFIED (not read from source in this run). Check `server/` for the static dir before dropping Node from the final image. If the UI needs a Node runtime, the final stage must switch to `ghcr.io/trueforge-org/python-node` (draft alternative) or add a node process to `start.sh`.
- **Working directory (inferred):** upstream sets no WORKDIR; `./data` resolves to `/data`. The plan replaces this with `WATCHARR_DATA=/config/data`. Confirm the `WATCHARR_DATA` path is used for `img/up` and `img/games` too.
- **cgo and glibc:** the upstream stage uses Alpine with `musl`. The plan builds against glibc (bookworm). Confirm the binary starts on ubuntu 26.04 (`ldd` and a container run).
- **Go version:** `go 1.27` is required by `server/go.mod`. The `golang:1.27-bookworm` tag must exist (UNVERIFIED digest; tag existence not checked).
- **Build time:** the draft's caveat holds: Go plus npm compile on both arches is slow, and `image-all` is two compiles.
- **arm64:** not validated. The plan treats arm64 as a build-from-source target with the same Dockerfile; no arm64 run was done.
- **First-run admin:** a manual UI step (draft caveat). The container test does not create an account.
- **Draft's base-choice question:** the draft lists python-node as an alternative runtime. Resolved here as ubuntu only, pending the UI open question above.
- No blockers known: not musl-only (the upstream musl build is not reused), no GPU, no privileged needs, no dependency containers.

## 11. Build and test steps

```sh
cd apps/watcharr
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name watcharr-probe --read-only --tmpfs /tmp \
  -v watcharr-probe-config:/config watcharr:4.4.0
docker logs -f watcharr-probe
forgetool containers test --image watcharr:4.4.0 --config ./apps/watcharr/container-test.yaml
docker rm -f watcharr-probe; docker volume rm watcharr-probe-config
```

- Readiness signal: the Go server's `listenAndServe` or the bind log line with `0.0.0.0:3080` (exact wording UNVERIFIED; read `server/watcharr.go` around the `net.Listen` call at line ~400 and use the logged address). Also confirm `/config/data/watcharr.db` exists after start and survives a restart with the same volume.
- Probe from outside the container (`-p 3080:3080`) to prove it is not bound to localhost.
- arm64: only after amd64 is green, via `--set image-local.platform=linux/arm64` on a runner with arm64 emulation or native hardware.

## 12. PR checklist

- Branch `feat/add-watcharr`, commit and PR title `feat(watcharr): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, check only the boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows the status.
- Say what was not tested: arm64 build and run, the UI open question, and the first-run UI flow unless those were actually run.
- `docker buildx bake --print` passes; bake `VERSION` equals the Dockerfile `ARG VERSION`; no assertion in `container-test.yaml` weakened.
