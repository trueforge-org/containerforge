# csi-addons-controller — implementation plan
> Source: ./draft.md · Target: apps/csi-addons-controller/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | v0.15.1 (latest release, published 2026-09-21). Source: https://api.github.com/repos/csi-addons/kubernetes-csi-addons/releases/latest. The draft's chart pins `quay.io/csiaddons/k8s-controller:v0.15.0`; v0.15.1 is newer. Quay lists a `v0.15.1` tag (https://quay.io/api/v1/repository/csiaddons/k8s-controller/tag/). |
| Renovate | `datasource=github-releases depName=csi-addons/kubernetes-csi-addons versioning=semver` (tags are `vX.Y.Z`) |
| License | Apache-2.0 (GitHub SPDX, https://api.github.com/repos/csi-addons/kubernetes-csi-addons) |
| Source URL | https://github.com/csi-addons/kubernetes-csi-addons |
| Download | Source tarball `https://github.com/csi-addons/kubernetes-csi-addons/archive/refs/tags/${VERSION}.tar.gz`, compiled per arch. No prebuilt binary. Tarball URL pattern is the standard GitHub one; not fetched on this run: UNVERIFIED. |
| Checksum source | None published by upstream. Pin the tag; record the commit SHA. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/csi-addons/kubernetes-csi-addons/main/Dockerfile. Stage `builder`: `FROM --platform=$BUILDPLATFORM quay.io/projectquay/golang:1.26`, `ENV CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH`, `RUN ... make build-manager` (sets `GOARM=7` for v7). Final: `FROM gcr.io/distroless/static:nonroot`, `COPY --from=builder .../bin/csi-addons-manager .`, `USER 65532:65532`, `ENTRYPOINT ["/csi-addons-manager"]`. |
| Makefile build | https://api.github.com/repos/csi-addons/kubernetes-csi-addons/contents/Makefile (read via `gh api`): `go build -ldflags '$(LDFLAGS)' -a -o bin/csi-addons-manager cmd/manager/main.go`. `LDFLAGS` value UNVERIFIED. |
| Ports | UNVERIFIED: draft inferred 8080 (metrics), 8081 (health), 9443 (webhook). Not confirmed from `cmd/manager/main.go` on this run. |
| Env vars | None read from the Dockerfile. Flags on `cmd/manager/main.go` UNVERIFIED. |
| Dependencies | None for the image. Runtime needs a Kubernetes cluster with a CSI driver and csi-addons CRDs (assets `crds.yaml`, `rbac.yaml`, `setup-controller.yaml` in the release). |
| Go version | Upstream builds with Go 1.26. The go.mod `go` line for v0.15.1 is UNVERIFIED. |

## 2. Target layout

- `apps/csi-addons-controller/Dockerfile`
- `apps/csi-addons-controller/docker-bake.hcl`
- `apps/csi-addons-controller/settings.yaml`
- `apps/csi-addons-controller/container-test.yaml`
- `apps/csi-addons-controller/start.sh` (only if an entrypoint wrapper is needed; the binary can be the entrypoint directly, see section 7)

No `defaults/`, `etc/` or `health/` needed. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

- Final stage: `ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`. The protocol rule for Go apps: build in a dedicated stage, copy the binary into the ubuntu final stage.
- Build stage: `quay.io/projectquay/golang:1.26` (upstream's builder image, tag only). Digest UNVERIFIED: pin it at build time. Alternative: the ubuntu base with `golang-go` apt package, as `apps/pwndrop` does. Go 1.26 apt availability on 26.04 UNVERIFIED, so the upstream builder image is preferred.
- Closest sibling: `apps/pwndrop` (Go build stage, ubuntu final).
- Draft said "distroless nonroot". ContainerForge uses ubuntu, so distroless is not copied. Runtime user is `apps`, not 65532 (see section 9).

## 4. Dockerfile

1. `ARG VERSION` (default `v0.15.1`), `ARG TARGETOS`, `ARG TARGETARCH`, `ARG TARGETVARIANT`.
2. Stage `builder` (`FROM --platform=$BUILDPLATFORM quay.io/projectquay/golang:1.26 AS builder`):
   - `ARG VERSION`, `curl -fL https://github.com/csi-addons/kubernetes-csi-addons/archive/refs/tags/${VERSION}.tar.gz` into `/tmp/src`, `tar xzf --strip-components=1`.
   - `ENV CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH`.
   - `RUN if [ "$TARGETVARIANT" = "v7" ]; then export GOARM=7; fi; cd /tmp/src && go build -ldflags "-s -w" -a -o /out/csi-addons-manager cmd/manager/main.go`. Use the same command as upstream's `make build-manager` so the Makefile is not required; keep `LDFLAGS` identical to upstream if it is verified.
   - Go modules: `go mod download` cached in `/tmp` (`GOCACHE=/tmp/gocache`, `GOMODCACHE=/tmp/gomod`). Never `/config`, never `/app`.
   - Vendor directory: if the source includes `vendor/`, `-mod=vendor` may be needed (UNVERIFIED).
3. Final stage `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:…`:
   - `ARG VERSION`, `USER root` only if package installs are needed (none expected).
   - `COPY --from=builder /out/csi-addons-manager /app/csi-addons-manager`.
   - Licence: copy `LICENSE` from the tarball to `/usr/share/licenses/csi-addons-controller/LICENSE` (needs the file, so fetch it in the builder stage and copy).
   - `ENV HOME=/tmp`.
   - `USER apps`, `COPY --chmod=0755 . /`, `ENTRYPOINT ["/app/csi-addons-manager"]`.
   - `EXPOSE` the ports from section 1 only after they are verified.
   - No `VOLUME /config`: the controller persists nothing. Confirm in section 9.

## 5. docker-bake.hcl

- `APP = "csi-addons-controller"`, `VERSION = "v0.15.1"` with `// renovate: datasource=github-releases depName=csi-addons/kubernetes-csi-addons versioning=semver`.
- `LICENSE = "Apache-2.0"`, `SOURCE = "https://github.com/csi-addons/kubernetes-csi-addons"`.
- Standard targets and default group from `apps/adguardhome-sync/docker-bake.hcl`.
- Validate: `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/csi-addons/kubernetes-csi-addons"
ports:
  - port: 8080
    protocol: tcp
    required: false
  - port: 8081
    protocol: tcp
    required: false
  - port: 9443
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes: []
dependencies: []
```

- The three ports are UNVERIFIED (section 1). Keep only the ports confirmed in `cmd/manager/main.go`. Remove any unconfirmed one before merge.
- `volumes: []`: the app persists nothing, so no `/config`. Confirm with the source; if it writes nothing, the `/config` rule does not apply.
- No `dependencies`: the cluster provides CRDs and CSI, which is not a ContainerForge app.

## 7. start.sh

- Not needed if the binary is the entrypoint. The Dockerfile sets `ENTRYPOINT ["/app/csi-addons-manager"]`.
- If a wrapper is added, it must `exec "/app/csi-addons-manager" "$@"` and must not write to `/app`.
- Pass-through of cluster flags (`--leader-elect`, metrics bind address, etc.) is UNVERIFIED: confirm the flag names in `cmd/manager/main.go` before documenting.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

tcp:
- port: '8080'
- port: '8081'
```

- Probe only the ports confirmed in section 1. Add `9443` only if the webhook is started without a cluster, and only if confirmed. A webhook needs TLS certificates, which the image does not have: expect the process to exit or wait; verify with the log.
- `timeoutSeconds`: copy from a sibling Go controller app if any; otherwise start at 60 (UNVERIFIED).
- Important: with no cluster, the manager may fail to start (it needs kubeconfig or in-cluster config). The test may need the process to stay up with no cluster. If it exits, record the log and decide whether `container-test.yaml` can assert the binary (`filePaths`) instead of a port. Do not weaken real assertions; document the reason in the PR.

## 9. Rootless and read-only-rootfs adaptations

- Upstream: `USER 65532:65532` on distroless nonroot. ContainerForge: `USER apps`.
- Chart: `runAsUser` default 568 (no override) and `readOnlyRootFilesystem true`. Target matches: nothing is written except `/tmp`.
- Writes: none expected. Metrics and health use the network. Leader election uses the API, not disk.
- `privileged`: false. `automountServiceAccountToken: true` is needed for the controller to talk to the API. Keep it in the chart, not the image.
- RBAC is cluster-wide (PVCs, csiaddons resources): an operational risk, not an image change. Note in the PR.
- `/config`: not used, so no empty-`/config` test beyond the standard run.

## 10. Risks, caveats and open questions

- **Cluster-only app**: runs only with a Kubernetes cluster, CSI driver and csi-addons CRDs. Local tests can only check that it starts and exposes ports. A full functional test is out of scope for the single-container suite.
- **Webhook TLS**: needs a certificate, typically from cert-manager (draft, inferred). The image does not provide one.
- **Ports and flags** UNVERIFIED (section 1).
- **Chart tag**: chart pins v0.15.0, image v0.15.1 is newer. Downstream chart update is not ContainerForge's job; mention in the PR.
- **arm64**: builds with `GOARCH=$TARGETARCH`; cross-arch not tested.
- **Go module download**: needs network at build time. If the build is offline, the source tarball must include `vendor/` (UNVERIFIED).
- Blockers: none confirmed.

## 11. Build and test steps

From `apps/csi-addons-controller/`:

1. `docker buildx bake --print`
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. Run and log check (read-only, no volume needed):
   ```sh
   docker run --rm -d --name csi-probe --read-only --tmpfs /tmp \
     csi-addons-controller:v0.15.1
   docker logs -f csi-probe
   ```
   Expected readiness signal: the manager's "starting manager" or the metrics/health listener line (UNVERIFIED text). Without a cluster, expect a config error; if so the readiness rule cannot be met in this suite, so record it and follow section 8.
   Clean up: `docker rm -f csi-probe`.
4. `forgetool containers test --image csi-addons-controller:v0.15.1 --config ./apps/csi-addons-controller/container-test.yaml`
5. Check the image runs as UID 65532 is NOT required: confirm `USER apps` with `docker inspect`.

## 12. PR checklist

- Branch: `feat/add-csi-addons-controller`
- Commit: `feat(csi-addons-controller): add new container`
- PR title: matches the commit.
- PR body: `.github/PULL_REQUEST_TEMPLATE.md`, keep sections and checkboxes; check only what applies.
- Notes section: `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it).
- Say what was not tested: cluster behaviour, webhook TLS, arm64, and any port not confirmed.
- Do not check "Built container locally" unless the build was run.
