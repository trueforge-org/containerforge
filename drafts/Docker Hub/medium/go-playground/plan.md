# go-playground — implementation plan
> Source: ./draft.md · Target: apps/go-playground/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Latest stable tag: UNVERIFIED. The GitHub releases page showed "3.0.0, released 27 Mar" with no year and no asset list; Docker Hub `x1unix/go-playground` last_updated 2026-03-27 matches. Treat `3.0.0` as a candidate only and confirm the tag exists before pinning. Draft names no version. |
| Renovate | Proposed: `datasource=github-releases depName=x1unix/go-playground versioning=semver`. The tag scheme and semver are UNVERIFIED (inferred). The draft's `docker` datasource is the fallback if the image is used instead. |
| License | MIT. Source: repo `LICENSE` (copyright 2020-2026 Denis Sedchenko). |
| Source URL | https://github.com/x1unix/go-playground |
| Download | No prebuilt binary. Source tarball per tag: `https://github.com/x1unix/go-playground/archive/refs/tags/${VERSION}.tar.gz` (URL pattern modelled on `apps/pwndrop`; UNVERIFIED that tags carry no `v` prefix). |
| Checksum source | None published by upstream in this run. Pin the tag and verify the tarball by content: UNVERIFIED how to obtain a published sha256 for the source archive. |
| Upstream Dockerfile reviewed | `https://raw.githubusercontent.com/x1unix/go-playground/master/build/Dockerfile` (stages below). Draft cites commit `55b1467` of the same file. |
| Upstream build stages | `node:${NODE_VERSION}-alpine AS ui-build` (NODE_VERSION=22.22.0, `yarn build` with `VITE_WASM_BASE_URL=/wasm`); `golang:${GO_VERSION}-alpine AS build` (GO_VERSION=1.25; builds the server, compiles the WASM analyzer `analyzer@${WASM_API_VER}.wasm` with WASM_API_VER=v3, runs `tools/pkgindexer`); `golang:${GO_VERSION}-alpine AS production`. |
| Upstream final image | Go Alpine (musl). Not usable as a `COPY --from` source on glibc Ubuntu. Build from source on ubuntu instead. |
| Upstream ENTRYPOINT | `/opt/playground/server -addr=:8000` |
| Upstream USER | None set (base default user). |
| Upstream EXPOSE | `8000` (the draft's 8080 is wrong, corrected). |
| Upstream VOLUME | None. |
| Upstream ENV | `GOROOT=/usr/local/go`, `APP_CLEAN_INTERVAL=10m`, `APP_DEBUG=false`, `APP_PLAYGROUND_URL=https://go.dev/_`, `APP_GTAG_ID=''`. |
| Port | `8000/tcp`. |
| Dependencies | None (no database). |
| Upstream runtime toolchain | The upstream final stage keeps the Go toolchain (`GOROOT=/usr/local/go`), because the server compiles user-submitted Go code. |
| Output paths of the build stages | UNVERIFIED: the exact `COPY` destinations (server, UI `dist`, WASM file, Go toolchain) are not in the facts. Read them from the upstream Dockerfile when implementing. |
| arm64 | Both Go and Node target arm64, so a source build should work. UNVERIFIED that upstream publishes an arm64 image (Docker Hub manifest list exists, platforms not listed). |

## 2. Target layout

- `apps/go-playground/Dockerfile`
- `apps/go-playground/docker-bake.hcl`
- `apps/go-playground/settings.yaml`
- `apps/go-playground/container-test.yaml`
- `apps/go-playground/start.sh`

No `defaults/`, `etc/` or `health/` needed (no config file is seeded; the app reads env vars). No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

- Build stage: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454 AS build`
- Final stage: the same line, `AS` omitted.

The ubuntu base already ships Go (`GO_VERSION` 1.27.4 at `/usr/local/go`, `GOTOOLCHAIN=local`), Node 26.13.1 and yarn 1.22.22 (`apps/ubuntu/docker-bake.hcl`, `apps/ubuntu/Dockerfile`), so it covers the runtime Go toolchain the server needs to compile user code. No separate language base is needed. Closest sibling: `apps/pwndrop` (Go built in a build stage, `COPY --from=buildstage` into an ubuntu runtime stage).

## 4. Dockerfile

1. Build stage, `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Toolchains (no version is verified in this run):
   - Go: upstream uses 1.25; the ubuntu base already provides Go 1.27.4 in `/usr/local/go`, so nothing is installed. Whether upstream builds with 1.27 is UNVERIFIED.
   - Node and yarn: upstream uses Node 22.22.0; the base provides Node 26.13.1 and yarn 1.22.22. Whether the UI builds on Node 26 is UNVERIFIED; if not, install a Node 22 tarball with a checksum.
   - Install only what is missing. Do not install `curl` or `tar`; the base has them.
3. Fetch the source, `ARG VERSION` is the tag:
   ```dockerfile
   RUN mkdir -p /tmp/go-playground && \
     curl -fL -o /tmp/src.tar.gz \
       "https://github.com/x1unix/go-playground/archive/refs/tags/${VERSION}.tar.gz" && \
     tar xzf /tmp/src.tar.gz -C /tmp/go-playground --strip-components=1
   ```
4. Build, following the upstream stages in order: `yarn build` with `VITE_WASM_BASE_URL=/wasm`; `go build` of the server; WASM analyzer build (`analyzer@v3.wasm`); `tools/pkgindexer` if upstream still needs it at runtime (UNVERIFIED which outputs the server reads). Set `GOCACHE=/tmp/go-cache`, `GOPATH=/tmp/go` and `GOMODCACHE=/tmp/go/pkg/mod` for every build step.
5. Final stage: `FROM` the same ubuntu line.
   - Server, UI assets and WASM: `COPY --from=build` into `/app/go-playground/`. Keep upstream's relative layout so the server finds its static files (UNVERIFIED which paths it hard-codes; upstream uses `/opt/playground`, which must not be copied as is).
   - Go toolchain: already present in the final stage from the ubuntu base (`/usr/local/go`), so no copy is needed. It is needed at runtime because the server compiles user code (the draft's main caveat).
   - License: `COPY --from=build /tmp/go-playground/LICENSE /usr/share/licenses/go-playground/LICENSE`.
6. Environment:
   ```dockerfile
   ENV GOROOT=/usr/local/go \
     PATH=/usr/local/go/bin:$PATH \
     GOCACHE=/tmp/go-cache \
     GOPATH=/tmp/go \
     APP_CLEAN_INTERVAL=10m \
     APP_DEBUG=false \
     APP_PLAYGROUND_URL=https://go.dev/_ \
     APP_GTAG_ID=''
   ```
7. Tail:
   ```dockerfile
   USER apps
   COPY --chmod=0755 . /

   EXPOSE 8000
   VOLUME /config
   ```
   `VOLUME /config` follows the repo rule although the app persists nothing; `/config` may stay empty. See section 9.
8. Clean apt lists and `/tmp/*` in the build stage.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "go-playground"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=x1unix/go-playground versioning=semver
  default = "3.0.0"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/x1unix/go-playground"
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

`default = "3.0.0"` is a candidate, UNVERIFIED (section 1). Copy the four standard targets and the default group from `apps/adguardhome-sync/docker-bake.hcl`. Run `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/x1unix/go-playground"
ports:
  - port: 8000
    protocol: tcp
    required: false
env:
  - name: APP_CLEAN_INTERVAL
    default: "10m"
    required: false
  - name: APP_DEBUG
    default: "false"
    required: false
  - name: APP_PLAYGROUND_URL
    default: "https://go.dev/_"
    required: false
  - name: APP_GTAG_ID
    default: ""
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
```

- Env names come from the upstream `ENV` lines. UNVERIFIED that the server reads each one. Keep only those the server reads.
- Add `volumes: [{path: /config, required: false}]` to match `VOLUME /config`. No dependencies.
- Port 8000 matches upstream `EXPOSE` and `-addr=:8000`. The draft's 8080 is not used.

## 7. start.sh

```bash
#!/usr/bin/env bash

cd /app/go-playground || exit 1
exec /app/go-playground/server -addr=:8000
```

- Listens on all interfaces (`:8000` binds every address).
- Writes nothing; no `/config` seeding is needed.
- Keeps the upstream `-addr` flag. Do not add a PORT variable unless the server reads one (UNVERIFIED).
- Uses `exec` so signals reach the server.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 240
tcp:
- port: '8000'
http:
- port: '8000'
  path: /
filePaths:
- /app/go-playground/server
- /usr/local/go/bin/go
- /usr/share/licenses/go-playground/LICENSE
```

- `timeoutSeconds: 240` is an upper-range value used by a few apps (`apps/pwndrop` sets no timeout; 240 is UNVERIFIED as needed). Build-time cost is not covered by the test.
- The http probe on `/` is UNVERIFIED: confirm it returns 200 before relying on it. Add the WASM file path once its name is confirmed (`analyzer@v3.wasm` is the expected name; UNVERIFIED for the install path).
- No env vars are set by the test, so the defaults in `settings.yaml` are the only config that runs.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path or need | Decision |
| --- | --- |
| Go build cache, module cache, GOPATH | `/tmp/go-cache`, `/tmp/go` via `ENV` (never `/config`, never `/app`). |
| `go` run by the server to compile user code | Needs writable GOCACHE and GOPATH: both are in `/tmp`. Runs as `apps`. |
| Server data and logs | None declared upstream. `/config` is declared as a volume but unused. |
| Static UI and WASM | Read-only under `/app/go-playground`. |
| Go toolchain at `/usr/local/go` | Read-only at runtime; `go` writes only to GOCACHE and GOPATH. |

Reconciled draft expectations: the chart runs as root (`runAsUser 0`) with `readOnlyRootFilesystem: false`. This image runs as `apps` (UID 568 in ContainerForge) and is meant to run with `--read-only --tmpfs /tmp`. The chart's root and writable-rootfs settings are not copied. Privileged: no.

## 10. Risks, caveats and open questions

- The version is UNVERIFIED (section 1). Confirm the latest stable tag before pinning.
- Build-time cost: Go plus Node/yarn plus WASM. Large image; check disk in CI (draft caveat, still valid).
- Security: the server compiles and runs user-submitted Go code. Sandboxing and CPU/memory limits are not in the upstream image (draft caveat, not verified upstream). Document that in the PR; do not add privileged settings.
- Upstream final image is Alpine (musl). Ubuntu with the glibc Go toolchain must be checked by running `go version` and a compile inside the built image.
- Go 1.27.4 and Node 26.13.1 come from the ubuntu base; compatibility with upstream's Go 1.25 and Node 22 is UNVERIFIED until built.
- arm64: source build expected to work; not verified. Test `linux/arm64` only if the amd64 build fails for an arm64-specific reason (protocol).
- Blocker check: none found (no musl-only binary, no GPU, no privileged need). The only open items are the unverified version, output paths and Go/Node availability.

## 11. Build and test steps

```sh
cd apps/go-playground
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name go-playground-probe --read-only --tmpfs /tmp \
  -v go-playground-probe-config:/config go-playground:<version>
docker logs -f go-playground-probe
forgetool containers test \
  --image go-playground:<version> \
  --config ./apps/go-playground/container-test.yaml
docker rm -f go-playground-probe
docker volume rm go-playground-probe-config
```

- Replace `<version>` with the verified tag.
- Readiness signal: the server's startup log line that names `:8000` or "listening" (UNVERIFIED exact text). The process must still be running after the startup window.
- Also run a compile request against the running server (the user-code path) to prove that the Go toolchain works read-only. This path is not covered by `container-test.yaml`.

## 12. PR checklist

- Branch `feat/add-go-playground`, commit `feat(go-playground): add new container`, PR title the same, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keeping its sections; check only the boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required. Tell the user; only they can sign it at https://cla-assistant.io/trueforge-org/containerforge. The `license/cla` check shows the status.
- State honestly what is untested: the version tag, Go/Node availability on ubuntu 26.04, the output paths, the http probe status, arm64, and the user-code compile path.
- Check: `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION`; no assertion weakened.
