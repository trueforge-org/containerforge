# kubelet-csr-approver — implementation plan
> Source: ./draft.md · Target: apps/kubelet-csr-approver/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `v1.2.16` (GitHub release, published 2026-11-19). Matches the draft's chart image `ghcr.io/postfinance/kubelet-csr-approver:v1.2.16`. |
| Renovate | `datasource=github-releases depName=postfinance/kubelet-csr-approver versioning=semver` (UNVERIFIED: upstream renovate config not read). |
| License | MIT (GitHub SPDX `MIT`, `gh api repos/postfinance/kubelet-csr-approver`). The repo ships a `LICENSE` file. |
| Source URL | https://github.com/postfinance/kubelet-csr-approver |
| Download | No release assets. Source tarball `https://github.com/postfinance/kubelet-csr-approver/archive/refs/tags/${VERSION}.tar.gz`. Compiled here for amd64 and arm64. |
| Per-arch | `compile` on both (no prebuilt executable upstream). |
| Checksum source | None published for the release or the tag archive. Plan: pin the tarball SHA-256 as a Dockerfile `ARG` computed once at implementation (UNVERIFIED value). |
| Upstream Dockerfile reviewed | No Dockerfile in the repo root (root listing: `.github`, `charts`, `cmd`, `deploy`, `internal`, `go.mod`, `go.sum`, `.ko.yaml`, `CHANGELOG.md`, `LICENSE`, `README.md`). Upstream builds the image with `ko` (`.ko.yaml` present). Build is reconstructed from source. |
| Go requirement | `go.mod`: `module github.com/postfinance/kubelet-csr-approver`, `go 1.26.0` (gh api contents). |
| Main package | `cmd/` exists. Binary subdirectory is `cmd/kubelet-csr-approver` (`gh api contents/cmd?ref=v1.2.16`; `.ko.yaml` has `main: ./cmd/kubelet-csr-approver/`). |
| Ports | UNVERIFIED: draft guesses 8080 (metrics) and 8081 (health), not confirmed in source or `charts/`. Must read `cmd/` and `charts/` before fixing ports. |
| Env vars and flags | UNVERIFIED: none read. Likely flags for the kubelet CA, policy file and listen address; confirm in `cmd/` and `README.md`. |
| Config path | UNVERIFIED: the approval policy is a rules file deployed by the chart (ConfigMap). Path inside the image not confirmed. |
| Dependencies | Kubernetes cluster, RBAC and ServiceAccount, kubelet CSR API (external, runtime only). Not ContainerForge apps. |

## 2. Target layout

- `apps/kubelet-csr-approver/Dockerfile`
- `apps/kubelet-csr-approver/docker-bake.hcl`
- `apps/kubelet-csr-approver/settings.yaml`
- `apps/kubelet-csr-approver/container-test.yaml`
- `apps/kubelet-csr-approver/start.sh`

No `defaults/` unless the policy file needs a seeded default (UNVERIFIED; the chart supplies it). No `etc/`, `health/` or `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

- Build stage and final stage: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`, copied from `apps/hishtory-server/Dockerfile`.
- Closest sibling: `apps/hishtory-server` (Go built in an ubuntu `AS builder` stage, then `COPY --from=builder`).
- Go toolchain: `apps/ubuntu/docker-bake.hcl` sets `GO_VERSION` default `1.27.4`, which satisfies `go 1.26.0`. `apps/ubuntu/Dockerfile` is single-stage and installs Go into the image (as `apps/hishtory-server` relies on); the builder should still check `go version`.

## 4. Dockerfile

1. Build stage `FROM <ubuntu> AS builder`, `ARG VERSION`, `ARG TARGETARCH`, `ARG KUBELET_CSR_APPROVER_SHA256` (pinned tarball checksum, UNVERIFIED value), `USER root`.
2. Install only what the base lacks (`ca-certificates`, `curl`; check first, do not reinstall base packages).
3. `curl -fL -o /tmp/src.tar.gz https://github.com/postfinance/kubelet-csr-approver/archive/refs/tags/${VERSION}.tar.gz`, verify with `sha256sum -c`, extract to `/build/src` with `--strip-components=1`.
4. `cd /build/src && GOPATH=/tmp/go GOCACHE=/tmp/go-build GOMODCACHE=/tmp/go/pkg/mod go mod download`.
5. `CGO_ENABLED=0 GOOS=linux GOARCH=${TARGETARCH} go build -trimpath -ldflags "-s -w" -o /out/kubelet-csr-approver ./cmd/kubelet-csr-approver`. Upstream `.ko.yaml` sets `-X github.com/postfinance/kubelet-csr-approver/internal/cmd.commit` and `.ref` (from git env, absent in a tarball build), so no version `-X` is injected here; add `-X .../internal/cmd.ref=${VERSION}` only if wanted (UNVERIFIED the variable is a plain string).
6. Final stage `FROM <ubuntu>`, `USER root`:
   - `COPY --from=builder /out/kubelet-csr-approver /app/kubelet-csr-approver`; `chown apps:apps` and `chmod 0755`.
   - License: `COPY --from=builder /build/src/LICENSE /usr/share/licenses/kubelet-csr-approver/LICENSE`.
7. `ENV HOME=/config`.
8. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE <ports from upstream source, UNVERIFIED>
VOLUME /config
```

Ports are written in step 8 only after `cmd/` and `charts/` confirm them.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "kubelet-csr-approver"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=postfinance/kubelet-csr-approver versioning=semver
  default = "v1.2.16"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/postfinance/kubelet-csr-approver"
}
```

`group "default"`, `target "image"`, `image-local`, `image-all` copied from `apps/adguardhome-sync/docker-bake.hcl`. Note: this repo's tags carry a `v` prefix, so `VERSION` keeps it and the tarball URL uses `${VERSION}` as is. The Dockerfile `ARG VERSION` must be `v1.2.16` too. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/postfinance/kubelet-csr-approver"
ports: []
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

`ports` is left empty as a placeholder: the draft's 8080 and 8081 are unconfirmed. Replace with confirmed ports (and matching `tcp` probes in `container-test.yaml`) before the PR. Env: no upstream env var is confirmed; add only after `cmd/` is read. `/config` volume is listed only because the image writes nothing; keep it for the empty-start convention, or drop it if no writes are needed (decide with the reader of `cmd/`). `dependencies: []`: the Kubernetes cluster is external.

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config

cd /app
exec /app/kubelet-csr-approver <flags confirmed from cmd/, UNVERIFIED>
```

Idempotent. Seeds nothing unless a default policy file is confirmed. No writes to `/app`. Flags and paths are UNVERIFIED until `cmd/` is read. `exec` for signal handling.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 60
filePaths:
- /app/kubelet-csr-approver
- /usr/share/licenses/kubelet-csr-approver/LICENSE
```

No `tcp` or `http` probes until ports are confirmed (see section 6). Risk: the binary needs a kube-API connection (in-cluster config or kubeconfig) and may exit at startup without one. If it exits, the protocol's "still running" criterion fails. Resolve in the run step (section 11) before trusting the probes. `timeoutSeconds` value UNVERIFIED (adjust to sibling Go apps).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| Go build cache, module cache (build stage only) | `/tmp/go-build`, `/tmp/go` |
| Runtime writes | UNVERIFIED: none expected. Check logs on `--read-only`. |
| Policy file (chart ConfigMap) | Read-only, mounted by the chart. Not written by the app. |

Upstream chart security expectations (from the draft, to verify): `runAsUser 568`, `readOnlyRootFilesystem: true`, not privileged. These fit `apps` and `--read-only`. Cluster-scoped RBAC and the ServiceAccount are deployment concerns, not image ones.

## 10. Risks, caveats and open questions

- No Dockerfile upstream: the build is reconstructed, so it may differ from the upstream `ko` image.
- Ports and flags are unverified (section 1). Not guessing them.
- Behaviour only exists inside a cluster: standalone run tests the startup and the health surface, not CSR approval. Stated in the PR.
- Approval policy: a loose policy approves too broadly. Chart-owned, out of image scope (draft caveat, inferred).
- Go 1.26.0 requirement must be met by the builder (see section 3).
- arm64 compiled on buildx natively; not run on arm64 unless the failure is arm64-specific.

Blockers: none in source. Gating items are the port and flag confirmation and the standalone-start question.

## 11. Build and test steps

```sh
cd apps/kubelet-csr-approver
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name kubelet-csr-approver-probe --read-only --tmpfs /tmp \
  -v kubelet-csr-approver-probe-config:/config kubelet-csr-approver:v1.2.16
docker logs -f kubelet-csr-approver-probe
forgetool containers test --image kubelet-csr-approver:v1.2.16 --config ./apps/kubelet-csr-approver/container-test.yaml
docker rm -f kubelet-csr-approver-probe; docker volume rm kubelet-csr-approver-probe-config
```

Expected readiness signal: UNVERIFIED (read from `cmd/` logging). The container must stay running with an empty `/config`.

## 12. PR checklist

- Branch `feat/add-kubelet-csr-approver`, commit and PR title `feat(kubelet-csr-approver): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, check only the boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required at https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it; the `license/cla` check shows the status.
- Untested to state honestly: the in-cluster behaviour (CSR approval), the arm64 build and run, the ports, the checksum value.
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION`; no assertion weakened.
