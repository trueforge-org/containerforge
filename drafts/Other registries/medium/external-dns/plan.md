# external-dns — implementation plan
> Source: ./draft.md · Target: apps/external-dns/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | v0.24.0, published 2026-10-23 (GitHub API). Source: https://github.com/kubernetes-sigs/external-dns/releases/tag/v0.24.0. Draft tag `registry.k8s.io/external-dns/external-dns:v0.24.0` matches. |
| Renovate | `datasource=github-releases depName=kubernetes-sigs/external-dns versioning=semver` (derived from the `vX.Y.Z` tag scheme; renovate config itself UNVERIFIED) |
| License | Apache-2.0 (GitHub license API, spdx_id) |
| Source URL | https://github.com/kubernetes-sigs/external-dns |
| Go version | `go 1.27.3` in go.mod. Source: https://raw.githubusercontent.com/kubernetes-sigs/external-dns/v0.24.0/go.mod |
| Per-arch download | No prebuilt binary is published as a release asset that was verified. Compile from the source archive per arch. UNVERIFIED: the exact archive URL was not fetched; the standard form is `https://github.com/kubernetes-sigs/external-dns/archive/refs/tags/v0.24.0.tar.gz`. |
| Checksum source | UNVERIFIED: release checksum files were not checked. Pin the tag and verify the tarball against the GitHub-provided sha256 when available. |
| Upstream build | No Dockerfile in the repo at v0.24.0 (404). The image is built with `ko build --bare` (Makefile lines ~93-125) using `.ko.yaml`: `defaultBaseImage: gcr.io/distroless/static-debian12:latest`, `CGO_ENABLED=0`, ldflags `-s -w` and `-X sigs.k8s.io/external-dns/pkg/version.Version`. |
| Port | Metrics and health endpoint on `:7979` (`MetricsAddress` default, flag `--metrics-address`; types.go lines 323 and 735). The draft's 8080 is NOT confirmed as a listening port: `ConnectorSourceServer` defaults to `localhost:8080` and is a client target. Health is served on the metrics address. |
| Env vars | UNVERIFIED: the app is configured with CLI flags; env binding was not checked against the source. Do not add env entries until verified. |
| Runtime requirement | Needs a Kubernetes API and DNS provider credentials. Source: https://raw.githubusercontent.com/kubernetes-sigs/external-dns/v0.24.0/README.md (lines 21-30) |
| Docs | https://kubernetes-sigs.github.io/external-dns/ |

## 2. Target layout

- `apps/external-dns/Dockerfile`
- `apps/external-dns/docker-bake.hcl`
- `apps/external-dns/settings.yaml`
- `apps/external-dns/container-test.yaml`
- `apps/external-dns/start.sh` (wraps the binary so `/config` is handled and flags are assembled; see section 7)

No `defaults/`, `etc/`, `health/` needed. No `root/` (never used). No `DOWNSTREAM_CHANGES.md` (nothing uses this image as a `FROM` base; the writer should grep `apps/*/Dockerfile` for `external-dns` to confirm).

## 3. Base image

- Final stage and build stage: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`. The brief's base table lists ubuntu for Go final stages.
- Build stage Go toolchain: apt `golang-go` on the ubuntu base is the sibling pattern (apps/pwndrop uses an ubuntu build stage with `golang-go`). The Go version must satisfy `go 1.27.3` in go.mod. UNVERIFIED: whether Ubuntu 26.04's `golang-go` package is >= 1.27.3. If not, use a pinned `golang:<ver>` build stage instead, and check the sibling pattern first.
- Closest sibling: `apps/pwndrop` (Go compiled in a build stage, copied into the ubuntu final stage).

## 4. Dockerfile

1. `FROM ubuntu@sha256:... AS buildstage`, `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. `apt-get install -y --no-install-recommends golang-go ca-certificates curl` (only what the base lacks; check the base first and do not reinstall `curl`/`ca-certificates` if present). Pin the Go package against the `go 1.27.3` requirement (see section 3).
3. `ENV GOCACHE=/tmp/gocache GOPATH=/tmp/gopath GOFLAGS=-mod=mod CGO_ENABLED=0`. Caches go to `/tmp`, never `/config` or `/app`.
4. Download and verify the tarball: `curl -fL -o /tmp/src.tar.gz https://github.com/kubernetes-sigs/external-dns/archive/refs/tags/v${VERSION}.tar.gz`, verify the checksum (UNVERIFIED source; see section 1), extract to `/tmp/src` with `--strip-components=1`.
5. Build for the target arch: `cd /tmp/src && GOOS=linux GOARCH=${TARGETARCH} go build -trimpath -ldflags "-s -w -X sigs.k8s.io/external-dns/pkg/version.Version=${VERSION}" -o /tmp/external-dns .`. Check the main package path with `ls /tmp/src` before the build (UNVERIFIED: that the main package lives at the repo root).
6. Copy the license: `install -Dm0644 /tmp/src/LICENSE /usr/share/licenses/external-dns/LICENSE`.
7. Final stage: `FROM ubuntu@sha256:...` (same digest), `USER root`, `COPY --from=buildstage /tmp/external-dns /app/external-dns`, `COPY --from=buildstage /usr/share/licenses/external-dns /usr/share/licenses/external-dns`. Set permissions so `apps` can execute: `chmod 0755 /app/external-dns`.
8. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 7979
VOLUME /config
```

Do not compile Go in the final stage (go-runtime rule). `/app` holds only the binary.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "external-dns"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=kubernetes-sigs/external-dns versioning=semver
  default = "0.24.0"
}
```

Note: the repo's tag is `v0.24.0`; the `VERSION` value is `0.24.0` and the Dockerfile builds `v${VERSION}`. Keep `ARG VERSION` identical to this default.

Remaining variables and targets are copied from `apps/valkey/docker-bake.hcl`: `LICENSE` = `Apache-2.0`, `SOURCE` = `https://github.com/kubernetes-sigs/external-dns`, `target "image"` with `org.opencontainers.image.source` and `.licenses` labels, `target "image-local"` (`output = ["type=docker"]`, tag `${APP}:${VERSION}`), `target "image-all"` (`linux/amd64`, `linux/arm64`), and `group "default" { targets = ["image-local"] }`. Validate with `docker buildx bake --print` from `apps/external-dns`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/kubernetes-sigs/external-dns"
ports:
  - port: 7979
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

- Ports: 7979 only (see section 1). Do not list 8080.
- Env: only `TZ`, because no env binding was verified. Add env entries only after the source shows the app reads them.
- Dependencies: none in ContainerForge terms (the app needs a Kubernetes API, which is not a container dependency).

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config
cd /config

exec /app/external-dns --metrics-address=":7979" "$@"
```

- `/config` is only for persistent state; this app writes none, so `mkdir -p` is harmless and keeps an empty `/config` valid.
- No writes to `/app`. No seeding needed.
- `exec` so signals reach the process. The metrics address binds `:7979` on all interfaces (matches "servers listen on all interfaces").
- The real flags come from the user's chart/args; `start.sh` only passes through `"$@"`. UNVERIFIED: whether ContainerForge expects args via env. Do not invent env names.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 60
tcp:
- port: '7979'
http:
- port: '7979'
  path: /healthz
filePaths:
- /app/external-dns
- /usr/share/licenses/external-dns/LICENSE
```

- The `/healthz` path is UNVERIFIED for v0.24.0; confirm the health endpoint path in `pkg/` before the test is final. If it differs, use the path the source shows. Do not drop the http probe.
- The test runs with no arguments and no Kubernetes API. Expect the process to fail its controller sync. Run the container per the protocol (section 11) and confirm it stays up and serves 7979 before trusting this test; if it exits without a cluster, the test cannot pass as written and the DB-style narrowing does not apply (no DB dependency). Record it as a blocker rather than weakening the assertion.
- `timeoutSeconds: 60` is an estimate; use the sibling value from a Go sibling after the first run.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| None observed (stateless controller). | Nothing to remap. `--read-only --tmpfs /tmp` is sufficient. |
| Go build caches (`GOCACHE`, `GOPATH`) | Build stage only, under `/tmp`. |

The draft's expectations are reconciled as: non-root (yes, `USER apps`), read-only rootfs (yes), privileged (no), no extra persistence. The chart's cluster-wide ClusterRole is a Kubernetes RBAC concern, not a container setting; it is out of scope for this image and must be noted in the PR.

## 10. Risks, caveats and open questions

- Cluster-only: the app cannot do useful work outside Kubernetes. The container test can only prove the binary starts and the metrics port is open.
- Cluster-wide RBAC needed by the chart (draft expectation, confirmed as out of container scope).
- No DNS provider credentials are in the image; users must supply them through the chart.
- UNVERIFIED: Go version compatibility of `golang-go` on Ubuntu 26.04 with `go 1.27.3`.
- UNVERIFIED: health path and whether the health check needs the metrics port.
- UNVERIFIED: env var support (section 1). Draft's 8080 port is not confirmed.
- Blockers: none found (no musl-only, no GPU, no privileged, Go is cross-compilable for arm64 with `CGO_ENABLED=0`).

## 11. Build and test steps

```sh
cd apps/external-dns
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name external-dns-probe --read-only --tmpfs /tmp \
  -v external-dns-probe-config:/config external-dns:0.24.0
docker logs -f external-dns-probe
forgetool containers test --image external-dns:0.24.0 --config ./apps/external-dns/container-test.yaml
docker rm -f external-dns-probe; docker volume rm external-dns-probe-config
```

Readiness signal to look for in logs: the metrics/health server listening on `:7979` and the controller starting its sync loop. Exact strings are UNVERIFIED until the first run. Test arm64 only if the amd64 failure is arm64-specific (protocol rule).

## 12. PR checklist

- Branch `feat/add-external-dns`, commit `feat(external-dns): add new container`, PR title matches, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections, only check applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows status.
- State honestly what is untested: the build on both architectures, the health path, the env var mapping, and a live Kubernetes run.
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION`; no assertion weakened.
