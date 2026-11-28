# cowyo — implementation plan
> Source: ./draft.md · Target: apps/cowyo/ · Difficulty: medium · Role: main · Verified on 2026-11-25

Status: **blocked** on license (section 10, blocker 1). Build and test cannot start until the license is confirmed, because `docker-bake.hcl` `LICENSE` must match the software in the image.

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `3.0.1` (latest stable release, published 2026-08-02, source archives only). The draft names no version. Upstream `v3.0.0` and `v2.12.0` also exist. |
| Image the chart uses today | `schollz/cowyo:latest` (Docker Hub, pushed 2020-05-14, amd64 only). This is the original 2020 cowyo, not the current code. |
| What the rewrite is | `cowyo2`, Go module `github.com/schollz/cowyo2` (go 1.26.5), read from `main`. UNVERIFIED that the `v3.0.1` tag contains the same module (not fetched). |
| Renovate | `datasource=github-releases depName=schollz/cowyo versioning=semver`. Tags carry a `v` prefix; the bake `VERSION` has none, as `apps/adguardhome-sync` does. Candidate only: the repo convention was not checked in this step. |
| License | UNVERIFIED: no `LICENSE` or `LICENSE.md` at `main` (both 404), and GitHub showed no detected license. |
| Source URL | https://github.com/schollz/cowyo |
| Download | Source archive `https://github.com/schollz/cowyo/archive/refs/tags/v${VERSION}.tar.gz`. No binary assets. Built per architecture. |
| Checksum source | None published. The archive is pinned by tag only (not content-addressed). |
| Upstream Dockerfile reviewed | `main` Dockerfile (https://raw.githubusercontent.com/schollz/cowyo/main/Dockerfile): stage 1 `node:24-alpine` (`npm ci`, `npm run build` for the vite frontend); stage 2 `golang:1.26.5-alpine` (`CGO_ENABLED=0 GOOS=linux go build -trimpath -ldflags="-s -w" -o /out/cowyo2 .`); runtime `alpine:3.23`, user `cowyo`, `ENV SQLITE_PATH=/data/cowyo2.sqlite3`, `EXPOSE 8001`, `CMD /usr/local/bin/cowyo2`, no `VOLUME`. The draft's linked commit `77f28842` has a different layout (`web/`, `./cmd/cowyo`, `internal/site/build`) and is not used. The `v3.0.1` tag's Dockerfile was not fetched (UNVERIFIED). |
| Port | Upstream `EXPOSE 8001`, README `-port` flag default `8001`, `disco.json` also `8001`. The chart uses `8050`. |
| Env vars (real) | `SQLITE_PATH` (Dockerfile). `SITE_URL` (README, production origin). `DATABASE_URL` (PostgreSQL, README/.env.example; not fetched, so not used in this plan). Flag `-port`. |
| Data path | Upstream `/data/cowyo2.sqlite3` through `SQLITE_PATH`. The chart mounts `/data`. |
| Per-arch | No prebuilt binary. Pure Go with CGO off, so amd64 and arm64 are built from the same source. |

## 2. Target layout

- `apps/cowyo/Dockerfile`
- `apps/cowyo/docker-bake.hcl`
- `apps/cowyo/settings.yaml`
- `apps/cowyo/container-test.yaml`
- `apps/cowyo/start.sh`

No `defaults/`, `etc/`, `health/` or `root/`: nothing needs seeding or config files. No `DOWNSTREAM_CHANGES.md`, because cowyo is not a `FROM` base for other apps.

## 3. Base image

- Final stage: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`.
- Frontend build stage: `FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5`, because it provides Node (sibling `apps/budge` notes Node 24 in this base). The Node version in the base is UNVERIFIED and must be read with `node --version` during the build.
- Go build stage: the ubuntu base, which already ships Go 1.27.4 (as `apps/hishtory-server` uses it); no apt `golang-go`.
- Closest siblings: `apps/pwndrop` (Go compiled on ubuntu, build stage then runtime stage) and `apps/adguardhome-sync` (single-binary app on ubuntu, `/app` layout, `EXPOSE`, `VOLUME /config`).

## 4. Dockerfile

1. Frontend stage `FROM <python-node> AS frontend`, `ARG VERSION`, `USER root`. Fetch the source into `/tmp/src`, `cd` into the frontend directory named by the upstream Dockerfile (UNVERIFIED: read it from the `v3.0.1` tag), then `npm ci` and `npm run build`. Clean `/tmp` and npm caches.
2. Go build stage `FROM <ubuntu> AS build`, `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
   - Do not install `golang-go`: the ubuntu base already ships Go (`GO_VERSION` 1.27.4 in `apps/ubuntu/docker-bake.hcl`, which satisfies `go 1.26.5`), as `apps/hishtory-server` relies on. `curl` and `tar` are in the base.
   - `curl -fL https://github.com/schollz/cowyo/archive/refs/tags/v${VERSION}.tar.gz | tar xz -C /tmp/src --strip-components=1`.
   - Copy the built frontend into the path the Go code embeds (UNVERIFIED: read from the upstream `go:embed` directive): `COPY --from=frontend /tmp/src/<build output> /tmp/src/<embed path>`.
   - `ENV CGO_ENABLED=0 GOOS=linux GOARCH=$TARGETARCH GOCACHE=/tmp/go-cache GOPATH=/tmp/go`, then `cd /tmp/src && go build -trimpath -ldflags="-s -w" -o /app/cowyo/cowyo2 .`.
   - Copy the licence file into `/usr/share/licenses/cowyo/` once it is known (blocked, see section 10).
   - Remove `/tmp/*` and apt lists.
3. Final stage `FROM <ubuntu>`, `ARG VERSION`, `USER root`.
   - `COPY --from=build /app/cowyo/ /app/cowyo/`.
   - `ENV HOME=/config SQLITE_PATH=/config/cowyo2.sqlite3 TZ=Etc/UTC`.
4. Tail, the same as `apps/adguardhome-sync`:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 8001
VOLUME /config
WORKDIR /config
```

Do not set `ENV SQLITE_PATH=/data/...`: the upstream path is replaced by `/config` (section 9). No `chown` is needed, because `/app` is only read at runtime.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "cowyo" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=schollz/cowyo versioning=semver
  default = "3.0.1"
}
variable "LICENSE" { default = "UNVERIFIED" }  // blocker: set the SPDX id from upstream before build
variable "SOURCE" { default = "https://github.com/schollz/cowyo" }
```

Use the four standard targets and `group "default" { targets = ["image-local"] }`, copied from `apps/adguardhome-sync`. Run `docker buildx bake --print` from `apps/cowyo`. The Dockerfile consumes `VERSION` through `ARG VERSION`, and both must be `3.0.1`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/schollz/cowyo"
ports:
  - port: 8001
    protocol: tcp
    required: false
env:
  - name: SQLITE_PATH
    default: "/config/cowyo2.sqlite3"
    required: false
  - name: SITE_URL
    default: ""
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

Dependencies: none. PostgreSQL (`DATABASE_URL`) is optional upstream and not listed, because its variable name and behaviour were not verified here. Port `8001` is upstream's, not the chart's `8050` (section 10).

## 7. start.sh

```bash
#!/usr/bin/env bash

export SQLITE_PATH="${SQLITE_PATH:-/config/cowyo2.sqlite3}"
mkdir -p "$(dirname "${SQLITE_PATH}")"

cd /config
exec /app/cowyo/cowyo2 -port 8001
```

- Idempotent. Nothing is seeded, because cowyo2 creates its SQLite file itself (UNVERIFIED: confirm on the first run with an empty `/config`).
- Nothing is written to `/app`. Scratch goes to `/tmp` (`TMPDIR` is unset, so Go and the app use `/tmp`).
- `exec` hands PID 1 to the server.
- Bind address: UNVERIFIED that `-port 8001` binds all interfaces. Check it with `ss -ltn` inside the container and with a curl from the host on a published port.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 60
tcp:
- port: '8001'
http:
- port: '8001'
  path: /
filePaths:
- /app/cowyo/cowyo2
- /usr/share/licenses/cowyo/LICENSE   # add once the licence is confirmed
```

- Both `tcp` and `http` probes for `8001`, per the coverage rule. The `http` path `/` returning 200 is UNVERIFIED.
- The test runs with no env vars, which is the default start path, so no required-env code paths exist.
- If the upstream start needs a secret or a database, the path goes into `filePaths` and is run by hand under the protocol.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/data/cowyo2.sqlite3` (`SQLITE_PATH`, upstream Dockerfile) | `SQLITE_PATH=/config/cowyo2.sqlite3` (env, not a rebuild). |
| Chart mount `/data` (`persistence`) | Image uses `/config`. Existing chart users must move their data to `/config`, or the chart maps `/config`. |
| Go build cache and module cache | `/tmp/go-cache`, `/tmp/go` (build stage only). |
| Frontend `npm` cache | `/tmp` (frontend stage only), removed before the stage ends. |

Reconciliation of the draft's expectations: the chart runs as UID 0 and GID 0 (`runAsUser 0`), but this image runs as `apps`. The chart sets `readOnlyRootFilesystem: false`, but the image is compatible with `--read-only --tmpfs /tmp`. The chart is not privileged, which matches the plan.

## 10. Risks, caveats and open questions

Blockers (the plan cannot finish until each is resolved):

1. **License unknown.** No `LICENSE` file on `main`, and no SPDX detected. `LICENSE` in `docker-bake.hcl` and the `/usr/share/licenses` copy cannot be filled in. Ask upstream or check the `v3.0.1` tree.
2. **Wrong image in the chart.** The chart's `schollz/cowyo:latest` is the 2020 original, not cowyo2. Building cowyo2 changes the app, the data format and the port. The chart behaviour is not the same. Confirm that the cowyo2 version is the intended target, and whether a 2020 database migrates (UNVERIFIED).
3. **Port.** Upstream uses `8001`, the chart uses `8050`. The plan uses `8001`. The chart's target port must be checked before the chart mapping is reused.

Other caveats:

- The draft's `/config` data path is supported as a remap through `SQLITE_PATH`, not by upstream. The chart's `/data` mount is a chart matter.
- Go toolchain: `go.mod` needs `go 1.26.5`; the ubuntu base ships 1.27.4. Do not let the build download a toolchain at build time without a checksum.
- Node version for the frontend: UNVERIFIED. `node:24` is upstream, and the base is assumed to provide Node 24 (from `apps/budge`), so verify.
- Frontend output path and embed path: UNVERIFIED (not in the fetched facts).
- `v3.0.1` tag contents: UNVERIFIED that the tag is `cowyo2` and that its Dockerfile matches `main`.
- Maintenance: upstream activity is low (inferred), so long-term updates may fall to ContainerForge.
- Architecture: no blocker found. The build is pure Go with CGO off, so arm64 is expected to build, but it is UNVERIFIED until tested.
- No musl-only, GPU or privileged needs were found.

## 11. Build and test steps

```sh
cd apps/cowyo
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name cowyo-probe --read-only --tmpfs /tmp \
  -v cowyo-probe-config:/config cowyo:3.0.1
docker logs -f cowyo-probe
forgetool containers test --image cowyo:3.0.1 --config ./apps/cowyo/container-test.yaml
docker rm -f cowyo-probe; docker volume rm cowyo-probe-config
```

Readiness signal: UNVERIFIED log text. Expect a listen line on port `8001` (cowyo2's own wording must be taken from the first run). Confirm that `/config/cowyo2.sqlite3` exists after start and survives a restart. Then curl from outside the container with `-p 8001:8001`.

## 12. PR checklist

- Branch `feat/add-cowyo`, commit and PR title `feat(cowyo): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, and tick only the boxes that apply.
- Notes section contains `🤖 This PR is AI generated.`
- Tell the user about the CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it, and the `license/cla` check shows the status.
- Say honestly what is untested: the amd64 and arm64 builds, the `--read-only` start, the empty `/config` start, the http probe status, the Go version, the frontend build, the cowyo2 data migration from the 2020 image, and the license.
- `docker buildx bake --print` passes; bake `VERSION` equals the Dockerfile `ARG VERSION`; no assertion is weakened.
