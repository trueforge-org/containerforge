# slash — implementation plan
> Source: ./draft.md · Target: apps/slash/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `1.0.0-rc.3` (git tag `v1.0.0-rc.3`). The chart pins `yourselfhosted/slash:1.0.0-rc.3@sha256:c34a45a0197f1822cf7bd1796ead899efb77b7ff8b926f825ad82362fdc3d093` (TrueCharts `charts/stable/slash/values.yaml`). The newest stable GitHub release is `v0.5.3` (2024-02-06), so 1.0.0 is still a release candidate line. Draft tag matches. |
| Renovate | `datasource=github-tags depName=yourselfhosted/slash versioning=semver` (upstream publishes tags, not releases, for the RC line) |
| License | AGPL-3.0 (GitHub API `license.spdx_id`, https://api.github.com/repos/yourselfhosted/slash) |
| Source URL | https://github.com/yourselfhosted/slash |
| Download | Source tarball `https://github.com/yourselfhosted/slash/archive/refs/tags/v${VERSION}.tar.gz`. No prebuilt binary; the image is compiled from source for amd64 and arm64. |
| Checksum source | None published for the tarball. Content is pinned by tag; record the tag in the Dockerfile. |
| Upstream Dockerfile reviewed | commit `489efa67f3752e0d55e3487f820394d973322a2f`: `FROM node:22-alpine AS frontend` (corepack, `pnpm i --frozen-lockfile`, `pnpm build`), `FROM golang:1.23-alpine AS backend` (`CGO_ENABLED=0 go build -o slash ./bin/slash/main.go`), `FROM alpine:latest AS monolithic`. Source: https://raw.githubusercontent.com/yourselfhosted/slash/489efa67f3752e0d55e3487f820394d973322a2f/Dockerfile |
| Port | `5231` (`SLASH_PORT`). Chart `service.main.ports.main.port: 5231`. The draft's 8081 is wrong. |
| Env vars (real) | `SLASH_MODE` (`prod` or `dev`, default `dev` in code; the image sets `prod`), `SLASH_PORT` (default `5231`), `SLASH_DRIVER` and `SLASH_DSN` for PostgreSQL (`docs/install.md`). `TZ` is set by the upstream image. Source: https://raw.githubusercontent.com/yourselfhosted/slash/main/docs/install.md |
| Data path | `server/profile/profile.go`: in `prod` mode, an empty data dir defaults to `/var/opt/slash`. SQLite file is `slash_<mode>.db` in that dir. Source: https://raw.githubusercontent.com/yourselfhosted/slash/main/server/profile/profile.go |
| Runtime user | Upstream runs as root (no `USER`). The ContainerForge image runs as `apps`. |
| Dependencies | None for SQLite (the default). PostgreSQL is optional through `SLASH_DRIVER` and `SLASH_DSN`. |
| UNVERIFIED | (a) the env var name for the data dir (`SLASH_DATA` or a flag only): not confirmed, read `bin/slash/main.go` flags before writing `start.sh`; (b) the Go version in `go.mod` matches `golang:1.23`: not fetched; (c) the health path for `/` or an API route returns 200: not fetched. |

## 2. Target layout

- `apps/slash/Dockerfile`
- `apps/slash/docker-bake.hcl`
- `apps/slash/settings.yaml`
- `apps/slash/container-test.yaml`
- `apps/slash/start.sh`

No `defaults/`, `etc/` or `health/`: Slash creates its own database on first start. No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

Final stage: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`. The app is a static Go binary (`CGO_ENABLED=0`), so ubuntu is only the userland. Closest sibling: `apps/pwndrop` (Go build stage, then ubuntu runtime stage).

Build stages (build-only, never shipped): `FROM golang:1.23-alpine` for the binary, as `go-runtime.instructions.md` allows; and a Node 22 stage for the UI. The Node stage digest is UNVERIFIED: get it with `docker buildx imagetools inspect node:22-alpine` before pinning. Alternative: reuse `ghcr.io/trueforge-org/python-node` if its Node major is 22 (UNVERIFIED, see section 10).

## 4. Dockerfile

1. `FROM node:22-alpine@<digest> AS frontend`: `ARG VERSION`, fetch the tarball from the tag, `corepack enable && pnpm i --frozen-lockfile && pnpm build` in the directory upstream builds (`frontend/web`, as upstream `/frontend-build/frontend/web`; confirm with the upstream `WORKDIR`, UNVERIFIED).
2. `FROM golang:1.23-alpine@<digest> AS backend`: `ARG VERSION`, `ARG TARGETARCH`. Fetch the same tarball. Copy the `frontend/web/dist` output to `server/route/frontend/dist` (the Go module embeds it), then `CGO_ENABLED=0 GOOS=linux GOARCH=$TARGETARCH go build -trimpath -ldflags="-s -w" -o /out/slash ./bin/slash/main.go`. Using `GOARCH=$TARGETARCH` gives native arm64 output without QEMU for the Go step.
3. Final stage `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`, `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
4. `COPY --from=backend /out/slash /app/slash/slash` and `chmod 0755`.
5. License: copy `LICENSE` from the source tarball to `/usr/share/licenses/slash/LICENSE`.
6. Persistence redirect (root, at build time): `mkdir -p /var/opt && ln -s /config/slash /var/opt/slash`, so the upstream default data dir resolves to `/config` without changing `/app`. Upstream creates `/var/opt/slash` in its image; this keeps that path working.
7. `chown -R apps:apps /app/slash` and the `/var/opt` symlink is created as root, so it needs no chown.
8. `ENV TZ=UTC SLASH_MODE=prod SLASH_PORT=5231`.
9. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 5231
VOLUME /config
WORKDIR /config
```

`WORKDIR /config` so relative paths land on the writable volume. The binary is called by absolute path from `start.sh`.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "slash" }
variable "VERSION" {
  // renovate: datasource=github-tags depName=yourselfhosted/slash versioning=semver
  default = "1.0.0-rc.3"
}
variable "LICENSE" { default = "AGPL-3.0-only" }
variable "SOURCE" { default = "https://github.com/yourselfhosted/slash" }
```

Upstream `LICENSE` is `AGPL-3.0` (GitHub SPDX). Use `AGPL-3.0-only` only if the LICENSE header confirms "only" (UNVERIFIED; otherwise use `AGPL-3.0`). Four standard targets and the default group copied from `apps/adguardhome-sync`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/yourselfhosted/slash"
ports:
  - port: 5231
    protocol: tcp
    required: false
env:
  - name: SLASH_MODE
    default: "prod"
    required: false
  - name: SLASH_PORT
    default: "5231"
    required: false
  - name: SLASH_DRIVER
    default: "sqlite"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

`SLASH_DRIVER` and `SLASH_DSN` are PostgreSQL options. The `sqlite` default value for `SLASH_DRIVER` is UNVERIFIED (docs only show the PostgreSQL value; check `docs/install.md`). `SLASH_DSN` is a secret, so it is `required: false` with no default and is not listed with a baked value. Dependencies: none required. Optional: `postgresql` exists as `apps/postgresql`; per `settings-yaml.instructions.md` the `dependencies` list is for required apps, so leave it empty (an optional-dependency key is UNVERIFIED). `apps/pwndrop` uses an ubuntu build stage, not a Go builder stage, so it is a layout precedent only.

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config/slash

export SLASH_MODE="${SLASH_MODE:-prod}"
export SLASH_PORT="${SLASH_PORT:-5231}"

cd /config
echo "Starting Slash on port ${SLASH_PORT}"
exec /app/slash/slash
```

Idempotent. It creates `/config/slash` only when missing and writes nothing under `/app`. The `/var/opt/slash` symlink sends the SQLite file to `/config/slash`. The script does not overwrite existing user state. Whether the binary needs flags is UNVERIFIED: read `bin/slash/main.go` and confirm the env names before the first build. Bind is `0.0.0.0` by default in Slash (UNVERIFIED: confirm the listen address).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '5231'
http:
- port: '5231'
  path: /
filePaths:
- /app/slash/slash
- /usr/share/licenses/slash/LICENSE
```

Every settings.yaml port has a probe. The `http` path is UNVERIFIED: if `/` does not return 200 on an empty `/config`, use the health or API path that does, and record the change in the PR. No env-dependent code path is needed to start.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/var/opt/slash` (SQLite `slash_prod.db`, data dir) | build-time symlink to `/config/slash` |
| Go build and pnpm caches | build stages only, never in the final image |
| `TZ` and `/etc/localtime` | env `TZ`, unchanged |

Draft expectations reconciled: the chart runs non-root with `readOnlyRootFilesystem: true` and `privileged: false`. The image runs as `apps` and only writes to `/config` and `/tmp`, so it is compatible with `--read-only --tmpfs /tmp`. The chart's extra persistence `/var/opt/slash` maps to `/config/slash` here, so migrating users must move their data there.

## 10. Risks, caveats and open questions

- RC only: `1.0.0-rc.3` has no stable 1.0.0. Expect breaking changes; renovate will propose `1.0.0` when published.
- Build time: the UI and Go build from source; the first build is slow.
- Node 22 and Go 1.23 versions must match upstream's `go.mod` and `package.json` `engines` (UNVERIFIED, not fetched).
- Digest pins for the build-only `node:22-alpine` and `golang:1.23-alpine` are not yet fetched (UNVERIFIED).
- Upstream runs as root; this port must not rely on that. The `/var/opt` symlink is the only path redirect.
- arm64: Docker Hub publishes arm64 for rc.3, but ContainerForge builds from source for both arches; the arm64 build is not tested here.
- Blockers: none known (glibc-free static Go, not musl-only in the final image, no GPU, no privileges).

## 11. Build and test steps

```sh
cd apps/slash
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name slash-probe --read-only --tmpfs /tmp \
  -v slash-probe-config:/config slash:1.0.0-rc.3
docker logs -f slash-probe
forgetool containers test --image slash:1.0.0-rc.3 --config ./apps/slash/container-test.yaml
docker rm -f slash-probe; docker volume rm slash-probe-config
```

Readiness: the process stays up and the log shows a listen line on port 5231 (exact text UNVERIFIED until a run). Also check `/config/slash/slash_prod.db` exists after start, and that a restart keeps it.

## 12. PR checklist

- Branch `feat/add-slash`, commit and PR title `feat(slash): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections, check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows status.
- Untested to state honestly: the amd64 and arm64 builds, the `--read-only` run, the probe paths, and the `/var/opt` symlink on a real run.
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION`.
