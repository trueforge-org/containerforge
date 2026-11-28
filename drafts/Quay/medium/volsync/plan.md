# volsync — implementation plan
> Source: ./draft.md · Target: apps/volsync/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `v0.17.0` (latest stable, published 2026-10-21). Source: `gh api repos/backube/volsync/releases/latest`. The chart uses `quay.io/backube/volsync:0.16.0` (draft), which is one release older. |
| Renovate | `datasource=github-releases depName=backube/volsync versioning=semver` (proposed; `VERSION` in bake is `v0.17.0` with the `v` prefix kept as in `apps/bazarr`). |
| License | AGPL-3.0 (GitHub `spdx_id` for `backube/volsync`). Use `AGPL-3.0-only` only if the LICENSE file says so (UNVERIFIED: LICENSE file not read; GitHub reports `AGPL-3.0`). |
| Source URL | https://github.com/backube/volsync |
| Release assets | Only kubectl-volsync tarballs: `kubectl-volsync-{darwin,linux}-{amd64,arm64}.tar.gz` (`gh api repos/backube/volsync/releases/latest`). No operator binary is published. |
| Download and build | Build the operator from source for amd64 and arm64. Clone or download the source tarball at the tag (UNVERIFIED URL pattern; use `https://github.com/backube/volsync/archive/refs/tags/${VERSION}.tar.gz` and confirm). |
| Checksum source | UNVERIFIED: no checksum file seen in the release asset list. Pin the source by tag and verify the commit hash, as the upstream Dockerfile does for its helper clones. |
| Upstream Dockerfile reviewed | v0.16.0 commit `22b97b0717c74f328853d92877151392ff5ecb42` (https://raw.githubusercontent.com/backube/volsync/22b97b0717c74f328853d92877151392ff5ecb42/Dockerfile). Stages: `golang:1.25` builder, `manager-builder`, `rclone-builder` (rclone v1.74.2 with git hash check), `restic-builder` (`go run build.go --enable-cgo`), `syncthing-builder` (v1.30.0), `diskrsync-builder` (v1.3.0), `diskrsync-tcp-builder`. Final stage `registry.access.redhat.com/ubi9-minimal`, `ENTRYPOINT ["/bin/bash"]`, no `USER`, no `EXPOSE`, no `VOLUME`. |
| v0.17.0 Dockerfile | Same file via `gh api repos/backube/volsync/contents/Dockerfile?ref=v0.17.0`: `FROM golang:1.26 AS golang-builder`, `ARG RCLONE_VERSION=v1.75.2` (hash `be8d6044eacb843b74d335db0c5fbe09222031fe`), `ARG SYNCTHING_VERSION="v1.30.0"` (hash `0945304a79d6bbaeac7fc2cc1b06f57d3cf66622`), `ARG DISKRSYNC_VERSION="v1.3.0"` (hash `507805c4378495fc2267b77f6eab3d6bb318c86c`). Final stage still `ubi9-minimal`. Remaining stage details at v0.17.0: UNVERIFIED beyond the ARG lines. |
| Ports | Draft says 8080 (metrics) and 8081 (health), both `(inferred)`. UNVERIFIED on a fetched page. Confirm from `cmd/` flags at the tag before writing settings.yaml. |
| Env vars (real) | `SYNCTHING_DATA_TRANSFERMODE=sendreceive` (upstream ENV). Operator flags such as `--scc-name` come from the draft and are UNVERIFIED in source. |
| Data and config paths | None on a fetched page. Operator is cluster-only (draft, inferred). |
| Dependencies | Kubernetes cluster with the VolSync CRDs installed (draft, inferred; UNVERIFIED). No ContainerForge app dependency. |

## 2. Target layout

- `apps/volsync/Dockerfile`: multi-stage Go build, final stage on the ContainerForge ubuntu base.
- `apps/volsync/docker-bake.hcl`: APP, VERSION, LICENSE, SOURCE, standard targets.
- `apps/volsync/settings.yaml`: ports (metrics and health, once confirmed), env, no `/config`.
- `apps/volsync/container-test.yaml`: probes for each declared port (see section 8 for the cluster problem).
- `apps/volsync/start.sh`: only if a wrapper is needed for flags; otherwise the image `ENTRYPOINT` runs the manager directly. Decide in section 7.
- Not needed: `defaults/`, `etc/`, `health/`, `root/`. `DOWNSTREAM_CHANGES.md` only if this image becomes a `FROM` base (it does not).

## 3. Base image

- Final stage: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`. Upstream uses `ubi9-minimal`; the ContainerForge rule is an ubuntu-based final stage (go-runtime rule).
- Build stage: `FROM golang:1.26@sha256:<digest>` (UNVERIFIED digest: resolve with `docker buildx imagetools inspect golang:1.26` at implementation time; v0.17.0 upstream uses `golang:1.26`). Pinning to the same Go minor as upstream v0.17.0 avoids surprises.
- Closest Go siblings to check before writing: `apps/go-yq`, `apps/kube-sa-proxy` (not read in this plan; confirm their Dockerfile shape first).

## 4. Dockerfile

1. Build stage `FROM golang:1.26@<digest> AS build`:
   - `ARG VERSION`, `ARG TARGETOS`, `ARG TARGETARCH`; `ENV GOFLAGS=-mod=readonly CGO_ENABLED=1 GOCACHE=/tmp/go-cache GOMODCACHE=/tmp/go-mod`.
   - Download the source at `${VERSION}`, verify the tag/commit hash, extract to `/src`.
   - `go build -o /out/manager ./cmd/...` (upstream uses `./cmd/...` and `cmd/`, `api/`, `internal/`).
   - Helper binaries as upstream does: `rclone` (`RCLONE_VERSION=v1.75.2`, hash `be8d6044eacb843b74d335db0c5fbe09222031fe`), `syncthing` (`v1.30.0`, hash `0945304a79d6bbaeac7fc2cc1b06f57d3cf66622`), `diskrsync` (`v1.3.0`, hash `507805c4378495fc2267b77f6eab3d6bb318c86c`), `diskrsync-tcp` (local source), `restic` (`mover-restic/`, `go run build.go --enable-cgo`). Each pinned by tag and hash, with an ARG per version and a renovate annotation (section 5 notes the extra ARGs).
   - Pin `restic` by the version in the source tree (UNVERIFIED version string).
2. Final stage `FROM ubuntu`:
   - `USER root` for installs, then `USER apps`.
   - Runtime packages needed by the helpers (rclone, restic, syncthing): UNVERIFIED which shared libraries they need on ubuntu; check with `ldd` in the build stage. Do not install packages already in the base.
   - `COPY --from=build /out/manager /manager` and `/usr/local/bin/{rclone,restic,syncthing,diskrsync,diskrsync-tcp}`.
   - `ENV SYNCTHING_DATA_TRANSFERMODE=sendreceive`, `ENV version=${VERSION}` (as upstream labels).
   - License and notices for the helper binaries into `/usr/share/licenses/volsync/` (each upstream project's LICENSE file, copied from its source tree).
3. `COPY --chmod=0755 . /`, `USER apps`, `ENTRYPOINT ["/manager"]` (or a start.sh per section 7), `EXPOSE` the ports confirmed in section 1.

Only Go compile in the build stage; no Go toolchain in the final stage (go-runtime rule).

## 5. docker-bake.hcl

- `variable "APP" { default = "volsync" }`
- `variable "VERSION" { // renovate: datasource=github-releases depName=backube/volsync versioning=semver
  default = "v0.17.0" }`
- `variable "LICENSE" { default = "AGPL-3.0" }`
- `variable "SOURCE" { default = "https://github.com/backube/volsync" }`
- Extra ARG pins (`RCLONE_VERSION`, `SYNCTHING_VERSION`, `DISKRSYNC_VERSION`) each with its own renovate annotation (datasource for the upstream project, for example `github-tags depName=rclone/rclone`; verify each).
- `group "default" { targets = ["image-local"] }`, `image`, `image-local` (`tags = ["${APP}:${VERSION}"]`), `image-all`; labels and args as `apps/bazarr/docker-bake.hcl`.
- Validate with `docker buildx bake --print` from `apps/volsync/`.

## 6. settings.yaml

- Header and `schema_version: 1`.
- `upstream_env_url: "https://github.com/backube/volsync"`
- `ports`: metrics and health ports from section 1 once confirmed (`required: false` for metrics if the probe is optional; UNVERIFIED).
- `env`: only variables the image reads. `SYNCTHING_DATA_TRANSFERMODE` is set in the image, so it is not a user env unless the operator reads it (UNVERIFIED). Do not invent env vars.
- `volumes`: none (no persistent state; cluster-only). Omit `/config`.
- `dependencies`: none in ContainerForge terms. The CRDs are a cluster prerequisite and go in the README/PR, not `dependencies:`.

## 7. start.sh

Decide with the user whether a wrapper is needed. Default plan: no `start.sh`; the image runs `/manager` directly. Reasons: the operator takes its settings from flags and env, not `/config`. If a wrapper is added, it must:
- write nothing to `/app` (none exists here) and nothing to `/config` (no `/config`);
- `exec` the manager so signals reach it;
- set `TMPDIR=/tmp`.

## 8. container-test.yaml

- Schema header as sibling apps.
- Probes: `tcp` for each declared port (metrics and health).
- **Blocker for the protocol**: the manager needs a Kubernetes API server (controller-runtime). Without one, it will likely exit, and the protocol's "still running" criterion fails. The test cannot run the operator in a single container.
  - Option A (preferred, needs decision): narrow the test to what can run without a cluster, such as `file` checks for `/manager` and the helper binaries, and `--version` or help output. Annotate the narrowing with a comment as the protocol requires. This is a narrowed test, not a skip.
  - Option B: run an envtest or kind cluster in CI. Out of scope for this single container suite; needs the user's approval.
  - Do not replace the probes with always-true checks.
- Helper binaries: `filePaths` (or the forgetool equivalent) for `/usr/local/bin/rclone`, `restic`, `syncthing`, `diskrsync`, `diskrsync-tcp` (UNVERIFIED schema field names; check the forgetool schema).
- `timeoutSeconds`: default unless a sibling Go operator sets one (check the sibling chosen in section 3).

## 9. Rootless and read-only-rootfs adaptations

- Upstream: no `USER` in the final stage (runs as root in the image), chart `runAsNonRoot` true, uid 568, `readOnlyRootFilesystem` true for the operator, `privileged` unknown, `--scc-name=volsync-privileged-mover` for data movers (draft).
- ContainerForge: `USER apps`. The manager needs no writes; caches and go-build scratch are in `/tmp` only at build time. Confirm the manager runs on `--read-only --tmpfs /tmp`.
- Privileged movers: the data-mover pods use a privileged SCC by default on OpenShift. That is a cluster configuration. The image does not need `privileged`, but the chart and docs must say which SCC applies on non-OpenShift clusters (draft caveat, inferred).
- `extra-persistence`: none (cluster-only).

## 10. Risks, caveats and open questions

- **Cluster-only**: the image cannot be run end to end without Kubernetes. Section 8 explains the test narrowing. This is the main risk to the protocol's success criteria.
- **Version choice**: the chart uses `0.16.0`; this plan targets `v0.17.0` (latest stable). If the chart must stay on `0.16.0`, change `VERSION` and `ARG`s to the v0.16.0 values (`golang:1.25`, rclone v1.74.2, syncthing v1.30.0, diskrsync v1.3.0). Both are documented in section 1.
- **Helper binaries**: the release ships only the kubectl plugin, so every helper is built from source. Their hashes must be pinned and rechecked on every bump.
- **Upstream base**: `ubi9-minimal` in upstream, ubuntu here. Check that rclone, restic and syncthing run on ubuntu (no RHEL-only libraries).
- **Ports and flags**: unconfirmed (`(inferred)` in the draft). Confirm in `cmd/` at the tag before writing settings.yaml and container-test.yaml.
- **Checksum**: no published checksum file seen; rely on the pinned tag and hash checks.
- **arm64**: source build for both architectures. Not validated here. Only build arm64 if amd64 fails for an arm64-specific reason.
- **OpenShift SCC**: `--scc-name` and the privileged mover depend on OpenShift; document, do not hard-code a cluster-specific SCC in the image.

## 11. Build and test steps

From `apps/volsync/`:
1. `docker buildx bake --print`
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. Probe run (no `/config` volume, since the image has none): `docker run --rm -d --name volsync-probe --read-only --tmpfs /tmp volsync:v0.17.0` then `docker logs -f volsync-probe`. Expected readiness signal depends on the cluster: without a cluster the manager exits, which is the known blocker (section 8). Record the first 100 log lines and decide (section 8 options).
4. `forgetool containers test --image volsync:v0.17.0 --config ./apps/volsync/container-test.yaml`
5. Cleanup: `docker rm -f volsync-probe`.
6. Verify helper binaries run: `docker run --rm volsync:v0.17.0 /usr/local/bin/rclone version` and the same for `restic`, `syncthing --version`.

## 12. PR checklist

- Branch `feat/add-volsync`, commit `feat(volsync): add new container`, PR title the same.
- PR template from `.github/PULL_REQUEST_TEMPLATE.md`, keeping sections and checkboxes; tick only what applies.
- Notes section contains `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it).
- State in the PR what was not tested: cluster behaviour, arm64 build, and any narrowed test in section 8.
- Downstream: none (not a `FROM` base).
