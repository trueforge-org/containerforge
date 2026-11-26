# snapshot-controller — implementation plan
> Source: ./draft.md · Target: apps/snapshot-controller/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `v8.7.1` (latest release, published 2026-11-23): https://github.com/kubernetes-csi/external-snapshotter/releases/tag/v8.7.1. The draft says `v8.7.0`; the TrueCharts chart runs `v8.7.1` (`registry.k8s.io/sig-storage/snapshot-controller:v8.7.1@sha256:d3c3893704c86f0fe428a6429c705b7103a653bea151db0fc5ab0fdb25bb2290`), so `v8.7.1` is the target. Tag commit `9aea5b81a82aa262567bb4345c1caf2510d026dc` (git ls-remote). |
| Renovate | `datasource=github-releases depName=kubernetes-csi/external-snapshotter versioning=semver` (UNVERIFIED that no upstream renovate config overrides this; the tag format is plain `vX.Y.Z`, so the `v` prefix is kept in VERSION as in `apps/bazarr`). |
| License | Apache-2.0 (GitHub API `repos/kubernetes-csi/external-snapshotter` `.license.spdx_id`; LICENSE at https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/v8.7.0/LICENSE). |
| Source URL | https://github.com/kubernetes-csi/external-snapshotter |
| Download | None. No prebuilt binary is published; the controller is compiled from the tagged source (`cmd/snapshot-controller`). |
| Checksum source | None published for a binary. The source is pinned by tag and commit SHA (`9aea5b81…`), so the tarball `https://github.com/kubernetes-csi/external-snapshotter/archive/refs/tags/v8.7.1.tar.gz` is content-addressed. Verify the commit SHA after download. |
| Go toolchain | `go.mod` declares `go 1.26.0` (https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/v8.7.0/go.mod). Re-check the same line at `v8.7.1` before writing the bake file. |
| Upstream Dockerfile reviewed | `cmd/snapshot-controller/Dockerfile` at v8.7.0: `FROM gcr.io/distroless/static:latest`, `ARG binary=./bin/snapshot-controller`, `COPY ${binary} snapshot-controller`, `ENTRYPOINT ["/snapshot-controller"]`. It only copies a binary built elsewhere (UNVERIFIED: the Makefile build flags were not fetched). |
| Port | 8080/tcp, HTTP, metrics and health via `--http-endpoint=:8080` (TrueCharts values `service.main.ports.main.port: 8080`). The chart probes `/metrics` for liveness, readiness and startup. |
| Flags used by chart | `--http-endpoint=:<port>`, `--leader-election=true`, `--leader-election-namespace=<namespace>`. The chart's webhook is disabled and uses `--tlsPrivateKeyFile`, `--tlsCertFile`, `--port` (port 8443, https); not in scope. |
| Env vars | None read by the controller (configuration is by flags; the chart sets no env). |
| Data/config write paths | None. The controller keeps no state on disk. |
| Dependencies | A Kubernetes API server and the `VolumeSnapshot*` CRDs in the cluster (draft and chart). |

## 2. Target layout

- `apps/snapshot-controller/Dockerfile`
- `apps/snapshot-controller/docker-bake.hcl`
- `apps/snapshot-controller/settings.yaml`
- `apps/snapshot-controller/container-test.yaml`
- `apps/snapshot-controller/start.sh` (flag assembly and `exec`, see section 7)

No `defaults/`, `etc/`, `health/` or `root/`: nothing is seeded. No `DOWNSTREAM_CHANGES.md`: nothing uses this image as a `FROM` base.

## 3. Base image

- Final stage: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`. The draft's `ubuntu` foundation is the right fit because the rules require the runtime to be ContainerForge's own base; the binary is static Go, so no runtime packages are needed.
- Build stage: a Go toolchain image is needed for `go 1.26.0`. UNVERIFIED: no ContainerForge golang base is confirmed. Use `FROM docker.io/library/golang:<1.26.x> AS build`, with a pinned digest taken from the registry at build time. The bake file's renovate comment would then use `datasource=docker depName=docker.io/library/golang`, as the existing bake files do for golang.
- Closest sibling: `apps/pwndrop` (Go build stage on ubuntu, then runtime stage). Note that pwndrop installs `golang-go` from apt; that is not used here because the apt Go version is UNVERIFIED against `go 1.26.0`.

## 4. Dockerfile

1. Build stage `FROM <golang> AS build`, `ARG VERSION`, `ARG TARGETARCH`, `ARG TARGETOS=linux`.
2. Fetch the source: `curl -fL https://github.com/kubernetes-csi/external-snapshotter/archive/refs/tags/${VERSION}.tar.gz -o /tmp/src.tar.gz`, unpack to `/tmp/src` with `--strip-components=1`. Confirm the commit matches section 1 when `VERSION=v8.7.1`.
3. Set `ENV GOCACHE=/tmp/go-cache GOMODCACHE=/tmp/go-mod` so caches stay out of `/config` and `/app`.
4. Compile: `CGO_ENABLED=0 GOOS=linux GOARCH=${TARGETARCH} go build -trimpath -ldflags="-s -w" -o /out/snapshot-controller ./cmd/snapshot-controller` (UNVERIFIED against upstream `Makefile`; compare the flags with the upstream build before merge). Build per arch with buildx, so arm64 is compiled natively or cross-compiled by Go.
5. License: copy `LICENSE` from the source into the runtime image at `/usr/share/licenses/snapshot-controller/LICENSE`. Ship the upstream `NOTICE` file too, if present (UNVERIFIED that one exists).
6. Final stage `FROM <ubuntu 26.04 digest above>`, `ARG VERSION`, `USER root`.
7. `mkdir -p /app/snapshot-controller`, `COPY --from=build /out/snapshot-controller /app/snapshot-controller/snapshot-controller`, `chown -R apps:apps /app/snapshot-controller`, `chmod -R 755 /app/snapshot-controller`.
8. `ENV HOME=/tmp`.
9. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 8080
```

No `VOLUME /config`: the controller has no persistent state and no seeding (see section 9).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "snapshot-controller"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=kubernetes-csi/external-snapshotter versioning=semver
  default = "v8.7.1"
}

variable "LICENSE" {
  default = "Apache-2.0"
}

variable "SOURCE" {
  default = "https://github.com/kubernetes-csi/external-snapshotter"
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

Keep `VERSION` as `v8.7.1` (tag form) and let the Dockerfile strip the `v` only where a path needs it. Run `docker buildx bake --print` in `apps/snapshot-controller`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/kubernetes-csi/external-snapshotter"
ports:
  - port: 8080
    protocol: tcp
    required: false
env:
  - name: LEADER_ELECTION
    default: "true"
    required: false
  - name: LEADER_ELECTION_NAMESPACE
    default: ""
    required: false
  - name: HTTP_ENDPOINT_PORT
    default: "8080"
    required: false
volumes: []
dependencies: []
```

- Only add env names that `start.sh` really reads (section 7). The three above are the ones proposed for mapping to flags; they are not read by the upstream binary and must not be documented as upstream variables.
- `volumes: []`: nothing persists. This is the only app shape where `/config` is not listed, because the rule applies only "when the app persists state".
- `dependencies: []`: the Kubernetes API and CRDs are cluster prerequisites, not ContainerForge apps (no `apps/` entry).
- Port 8080 matches the chart and must have a probe in `container-test.yaml`.

## 7. start.sh

```bash
#!/usr/bin/env bash

args=(
  "--http-endpoint=:${HTTP_ENDPOINT_PORT:-8080}"
  "--leader-election=${LEADER_ELECTION:-true}"
)
if [[ -n "${LEADER_ELECTION_NAMESPACE:-}" ]]; then
  args+=("--leader-election-namespace=${LEADER_ELECTION_NAMESPACE}")
fi

cd /app/snapshot-controller
exec /app/snapshot-controller/snapshot-controller "${args[@]}"
```

- Idempotent and stateless: nothing is seeded, nothing written to `/app`, nothing written to `/config`.
- Binds `:8080`, which is all interfaces (Go's `:port` form), so other containers can reach metrics.
- `exec` so the controller receives signals as PID 1.
- Kubernetes in-cluster config comes from the service account token, not from env, so `start.sh` does not handle kubeconfig.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 60
tcp:
- port: '8080'
http:
- port: '8080'
  path: /metrics
filePaths:
- /app/snapshot-controller/snapshot-controller
- /usr/share/licenses/snapshot-controller/LICENSE
```

- The `tcp` and `http` probes cover the one declared port (coverage minimum).
- Blocking risk: the controller needs a Kubernetes API to start (in-cluster config, then informers wait for the `VolumeSnapshot` CRDs). Without a cluster, it is expected to exit at startup. That would fail the protocol's step 3 and the test. The protocol has no exception for a cluster dependency (its database exception covers databases only). See section 10 for the decision that must be made before this app can be marked green. Do not weaken or drop the probes to pass.
- `timeoutSeconds: 60` is a guess; take the value from a sibling app of the same family once the startup time is measured.

## 9. Rootless and read-only-rootfs adaptations

| Item | Result |
| --- | --- |
| Runs as | `apps` (568) via `USER apps`. The chart's default 568 matches. |
| `readOnlyRootFilesystem` | Compatible. The binary writes nothing; `HOME=/tmp` and `GOCACHE` are only used at build time. |
| `privileged` | Not set (chart default false). |
| Writes to `/app` | None at runtime. |
| `/config` | Not used. No persistence, so no `VOLUME /config`. |
| Extra persistence | None (draft and chart). |
| Service account | Needs a mounted token (`automountServiceAccountToken: true` in the chart). This is a Kubernetes deployment requirement, not a container write path. |

## 10. Risks, caveats and open questions

- Cluster dependency (blocker for green test): the controller needs an API server and CRDs. Options for a decision by the maintainers before work starts: (a) a test that provides a fake API server (UNVERIFIED that the controller can run against one); (b) a documented narrow exception in `container-test.yaml` (requires a justified comment, no always-true checks); (c) accept a failing step 3 and record the app as blocked. Choose one and record it in the PR.
- Version drift: the draft says `v8.7.0`, the chart uses `v8.7.1`. Use `v8.7.1`; the downstream chart update is out of scope here.
- Go version: `go 1.26.0` in `go.mod`; the build image tag and digest must be pinned to a release that satisfies it (UNVERIFIED which tags exist).
- arm64: compiled per architecture; the arm64 build must be checked separately (draft caveat, confirmed that no prebuilt arm64 binary exists upstream).
- Upstream `Makefile` build flags were not fetched; the `go build` line in section 4 is a plan, not a copy of upstream.
- CRD requirement: the `VolumeSnapshot*` CRDs must be installed in the cluster before the controller starts (draft, not confirmed by a fetched page).
- Not a blocker: no GPU, no musl-only build (static Go), no privileged mode.

## 11. Build and test steps

```sh
cd apps/snapshot-controller
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name snapshot-controller-probe --read-only --tmpfs /tmp \
  -v snapshot-controller-probe-config:/config snapshot-controller:v8.7.1
docker logs -f snapshot-controller-probe
forgetool containers test --image snapshot-controller:v8.7.1 --config ./apps/snapshot-controller/container-test.yaml
docker rm -f snapshot-controller-probe; docker volume rm snapshot-controller-probe-config
```

- The `/config` volume is attached only to keep the protocol's command shape; the app does not use it.
- Expected readiness signal: controller log lines from `klog`/`component-base` about starting the metrics endpoint on `:8080` and waiting for leader election. UNVERIFIED exact text. Without a cluster, expect an error and exit; that outcome is the blocker in section 10, not a pass.
- arm64: `docker buildx bake --set image-local.platform=linux/arm64 image-local` only if the amd64 build fails for an arm64-specific reason.

## 12. PR checklist

- Branch `feat/add-snapshot-controller`, commit `feat(snapshot-controller): add new container`, PR title `feat(snapshot-controller): add new container`, target `main`.
- Tell the user that a signed Contributor License Agreement is needed (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows the status.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections and checkboxes, check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- Say in the PR what is untested: the arm64 build, the test against a real cluster, and any step not run locally. Do not check "Built container locally" unless the build ran.
- `docker buildx bake --print` passes; `VERSION` in bake equals the Dockerfile `ARG VERSION`; no assertion weakened.
