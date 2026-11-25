# gatus — implementation plan
> Source: ./draft.md · Target: apps/gatus/ · Difficulty: easy · Role: sidecar (sidecarImage) · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `0.6.1` (GitHub latest release, published 2026-11-01, via `gh api repos/home-operations/gatus-sidecar/releases/latest`). The release has no assets: the image is built from source. |
| Renovate (proposed) | `datasource=github-releases depName=home-operations/gatus-sidecar versioning=semver` (repo tags are plain `0.6.1`, UNVERIFIED that no `v` prefix is used). |
| License | AGPL-3.0 (GitHub repo metadata, SPDX `AGPL-3.0`). Use `AGPL-3.0` for `LICENSE`, not `-or-later`. |
| Source URL | https://github.com/home-operations/gatus-sidecar |
| Download / arch | No release binaries. Build from the tagged source with `go build`. arm64 build is UNVERIFIED (no arch-specific code is seen in the Dockerfile, and the golang and distroless bases support arm64). |
| Checksum source | None published. Pin the source by the git tag and `go.sum`. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/home-operations/gatus-sidecar/1aefae52150e/Dockerfile: `ARG GO_VERSION`; builder `FROM golang:${GO_VERSION}-alpine AS builder`; `ARG VERSION=dev`, `ARG REVISION=dev`; `COPY go.mod go.sum ./`, `RUN go mod download`, `COPY . .`; `RUN CGO_ENABLED=0 go build -ldflags "-s -w -X main.Version=${VERSION} -X main.Gitsha=${REVISION}" -trimpath -o /out/gatus-sidecar ./cmd/gatus-sidecar`; final `FROM gcr.io/distroless/static:nonroot`; `ENTRYPOINT ["/gatus-sidecar"]`. No ENV, EXPOSE, VOLUME, USER or CMD. |
| Go version | `go 1.27.0` in `go.mod` (fetched via `gh api`). The upstream `GO_VERSION` default is not shown in the fetched content, so the builder tag must be chosen to match `go.mod`: UNVERIFIED that a `golang:1.27` image is published. |
| Env vars | UNVERIFIED: the Dockerfile sets none, and `cmd/gatus-sidecar` was not read. Do not add env vars until the source confirms them. |
| Ports | UNVERIFIED: no `EXPOSE` upstream. The draft's 8080 health port is inferred. |
| Data/config write paths | None in the Dockerfile (static binary). The sidecar reads Kubernetes objects through the API (draft caveat, UNVERIFIED in source). |
| Dependencies | None for the image. Needs a Kubernetes API and a Gatus main container at run time (draft caveat, UNVERIFIED in source). |

## 2. Target layout

- `apps/gatus/Dockerfile`
- `apps/gatus/docker-bake.hcl`
- `apps/gatus/settings.yaml`
- `apps/gatus/container-test.yaml`
- `apps/gatus/start.sh`: `exec /app/gatus-sidecar "$@"`. Include only if the ContainerForge `CMD` contract needs it; see section 10.

No `defaults/` or `etc/`. No `DOWNSTREAM_CHANGES.md`: the image is not a `FROM` base for other apps. `root/` is not used.

## 3. Base image

- Builder: `FROM golang:1.27@sha256:<digest>` (matches `go.mod`). Closest sibling for the build pattern: `apps/whoami` (`git clone --branch "${VERSION}"`, `CGO_ENABLED=0 go build -trimpath -ldflags="-s -w"`). Note that `whoami` builds on the ContainerForge ubuntu base; the go-runtime rule says a dedicated `golang:<ver>` build stage is preferred, so this plan uses the golang image. UNVERIFIED that the tag is published and the digest is pinned at build time.
- Final: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`. Reason: the rule is that apps use the ContainerForge base, and a static binary needs no extra packages. Distroless (upstream final) is not used, because the image must be `USER apps` on the ContainerForge base.

## 4. Dockerfile

1. Build stage: `FROM golang:1.27@sha256:<digest> AS build`, `ARG VERSION`, `ARG REVISION`.
2. `WORKDIR /src`, `RUN git clone --depth 1 --branch "${VERSION}" https://github.com/home-operations/gatus-sidecar.git .` (or `COPY` from a checkout). Use the tag; keep `VERSION` equal to the bake default `0.6.1`.
3. `RUN CGO_ENABLED=0 go build -trimpath -ldflags "-s -w -X main.Version=${VERSION} -X main.Gitsha=${REVISION}" -o /out/gatus-sidecar ./cmd/gatus-sidecar`. `go mod download` runs before the build, as upstream does.
4. Final stage: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:...`. `USER root` only if a directory must be created.
5. `COPY --from=build /out/gatus-sidecar /app/gatus-sidecar`, then `RUN chmod 0755 /app/gatus-sidecar`.
6. License: copy the repo `LICENSE` from the source stage to `/usr/share/licenses/gatus/LICENSE` (path confirmed in the repo root, UNVERIFIED until cloned).
7. `USER apps`, `COPY --chmod=0755 . /`, `ENTRYPOINT ["/app/gatus-sidecar"]` (or `CMD ["/start.sh"]` if `start.sh` is kept).

No `ENV` for the binary, no `VOLUME /config` (stateless; see section 9).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "gatus"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=home-operations/gatus-sidecar versioning=semver
  default = "0.6.1"
}

variable "LICENSE" {
  default = "AGPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/home-operations/gatus-sidecar"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION  = "${VERSION}"
    REVISION = "0.6.1"   # set from the tag commit; UNVERIFIED value, see section 10
  }
  labels = {
    "org.opencontainers.image.source"   = "${SOURCE}"
    "org.opencontainers.image.licenses" = "${LICENSE}"
  }
}

target "image-local" {
  inherits = ["image"]
  output   = ["type=docker"]
  tags     = ["${APP}:${VERSION}"]
}

target "image-all" {
  inherits  = ["image"]
  platforms = ["linux/amd64", "linux/arm64"]
}
```

`REVISION` should hold the commit SHA of the tag; the value above is a placeholder that must be replaced by the real SHA (UNVERIFIED). Validate with `cd apps/gatus && docker buildx bake --print`.

## 6. settings.yaml

- Schema header and `schema_version: 1`.
- `upstream_env_url: "https://github.com/home-operations/gatus-sidecar"`.
- `ports`: `[]` (no confirmed port). Add a port only after the source confirms one.
- `env`: `[]` (none confirmed). Add entries only after reading `cmd/gatus-sidecar`.
- `volumes`: `[]`. The app is stateless; `/config` is not required by it. If the chart mounts `/config` anyway, add `/config` with `required: false`.
- `dependencies`: none. Gatus main (`ghcr.io/twin/gatus`) is a chart-level peer, not a ContainerForge dependency. No Gatus main app exists in `apps/` (checked); `apps/gatus` is the new sidecar target.

## 7. start.sh

- Only if kept: `set -euo pipefail`, `exec /app/gatus-sidecar "$@"`.
- Writes nothing. No `/config` seeding is needed.
- Never writes to `/app`.
- Its only job is the `exec` hand-off so signals reach the binary.

## 8. container-test.yaml

- forgetool schema header.
- `filePaths`: `/app/gatus-sidecar`, and `/start.sh` if kept.
- `tcp`: none until a port is confirmed in the source. The protocol requires a probe for every port in `settings.yaml`, so this is consistent only while `ports` is empty.
- Process-running check: the test relies on the container staying alive (protocol step 3). Without a Kubernetes API the sidecar may exit at once, which would fail that criterion; see section 10 before writing the test.

## 9. Rootless and read-only-rootfs adaptations

- Runs as `apps` (`USER apps`), not the chart's runAsUser 568 (matches the ContainerForge rule; the chart value is a common default).
- Read-only rootfs: the binary is in `/app` and nothing writes at run time. Chart expectation (`readOnlyRootFilesystem: true`) is met.
- Chart sysctl `net.ipv4.ping_group_range "0 2147483647"` is a pod setting, not a container setting; it is out of scope for the image (flag in the PR).
- RBAC and a service account for the sidecar are chart-level; the image does not need them.

## 10. Risks, caveats and open questions

- Blocker risk: the sidecar's run-time behaviour without a Kubernetes API is UNVERIFIED. If it exits at start, protocol step 3 ("still running") cannot pass in a plain container. Read `cmd/gatus-sidecar` (kube config handling) before implementing, and decide whether the test uses a fake API or the container is documented as unfit for standalone tests.
- `GO_VERSION` for the builder: upstream default is not shown. Choose the `golang` tag that matches `go 1.27.0` in `go.mod`, and confirm it is published.
- `REVISION` value: the placeholder in section 5 must be replaced with the real tag commit SHA.
- Env vars and ports: none are confirmed from the source. Do not list any until they are.
- Git tag format: the release tag is `0.6.1`; confirm it has no `v` prefix before using `git clone --branch`.
- License: AGPL-3.0 (not -or-later) per GitHub metadata.
- Keep the image tag in sync with the upstream sidecar version (draft caveat).
- No blockers found for amd64 or arm64 build. arm64 publication is UNVERIFIED.

## 11. Build and test steps

From `apps/gatus`:

1. `docker buildx bake --print` (must exit 0).
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. `docker run --rm -d --name gatus-probe --read-only --tmpfs /tmp -v gatus-probe-config:/config gatus:0.6.1`, then `docker logs -f gatus-probe`. Expected readiness signal: UNVERIFIED until the source is read (it depends on whether the sidecar logs a startup line without a cluster). Then `docker rm -f gatus-probe; docker volume rm gatus-probe-config`.
4. `forgetool containers test --image gatus:0.6.1 --config ./apps/gatus/container-test.yaml`.
5. Clean up scratch containers and volumes between rounds.

## 12. PR checklist

- Branch `feat/add-gatus`, commit `feat(gatus): add new container`, targets `main`.
- PR description uses `.github/PULL_REQUEST_TEMPLATE.md`; only check the boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- Tell the user about the CLA (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it.
- State what is not tested: image not built or run locally, the standalone run behaviour without Kubernetes, the unverified env vars and ports, and the unverified `golang` tag and digest.
- Note that this is a sidecar: it only works next to a Gatus main container and a Kubernetes API.
