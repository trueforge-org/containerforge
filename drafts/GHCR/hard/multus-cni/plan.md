# multus-cni — implementation plan
> Source: ./draft.md · Target: apps/multus-cni/ · Difficulty: hard · Role: main · Verified on 2026-11-25

> **Blocked by repo rules (decision needed before writing files).** Upstream `multus-daemon` needs host networking, host PID, root and hostPath writes to `/opt/cni/bin`, `/etc/cni/net.d` and `/var/lib/cni/multus`. ContainerForge requires `USER apps`, a read-only-rootfs-compatible runtime and empty-`/config` start (`.github/instructions/dockerfile.instructions.md`). These cannot all hold for the daemon. Section 10 lists the options. The plan below covers the one part that fits the repo rules: shipping the release binaries and copying them to a host path, the same way `apps/cni-plugins` does.

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `v4.3.2`, latest release (`gh api repos/k8snetworkplumbingwg/multus-cni/releases/latest`, tag `v4.3.2`, published 2026-11-05). Draft container tag `ghcr.io/k8snetworkplumbingwg/multus-cni:v4.3.2-thick` matches. |
| Renovate | `datasource=github-releases depName=k8snetworkplumbingwg/multus-cni` for `VERSION` (same pattern as `apps/cni-plugins/docker-bake.hcl`, which uses `datasource=github-releases depName=containernetworking/plugins`). Not verified that the upstream repo has a renovate config; the annotation is the repo's convention. |
| License (repo / app) | Apache-2.0 (`gh api repos/k8snetworkplumbingwg/multus-cni/license`). Source: https://github.com/k8snetworkplumbingwg/multus-cni |
| Source URL | https://github.com/k8snetworkplumbingwg/multus-cni |
| Documentation | https://k8snetworkplumbingwg.github.io/multus-cni/ (not fetched; UNVERIFIED for config paths). |
| Per-arch download (confirmed asset names) | amd64: `https://github.com/k8snetworkplumbingwg/multus-cni/releases/download/v4.3.2/multus-cni_4.3.2_linux_amd64.tar.gz` (85725952 bytes). arm64: `https://github.com/k8snetworkplumbingwg/multus-cni/releases/download/v4.3.2/multus-cni_4.3.2_linux_arm64.tar.gz` (78440954 bytes). Also published, not needed: `linux_386`, `linux_armv6`, `linux_s390x`. |
| Checksum source | Upstream `checksums.txt` on the same release: `https://github.com/k8snetworkplumbingwg/multus-cni/releases/download/v4.3.2/checksums.txt`. SHA-256 (fetched): amd64 `6775a43348e17d08b1be6dea2fc2185af418ece7149a94a469c0787f2e486ad8`; arm64 `2af3dd587a87423be74a70c23f1ddee56dedc424fde9d7edbcf330131fe9db10`. |
| Tarball contents | UNVERIFIED: not extracted. Upstream thick image ships `/usr/src/multus-cni/bin/` (contains `multus-daemon` and `cert-approver`, from the COPY lines) and `LICENSE`. Confirm the tarball layout with `tar tzf` after download. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/k8snetworkplumbingwg/multus-cni/v4.3.2/images/Dockerfile.thick. Stages: `FROM --platform=$BUILDPLATFORM golang:1.26 AS build`, final `FROM debian:stable-slim`. Final stage: `COPY --from=build /usr/src/multus-cni/bin /usr/src/multus-cni/bin`, `COPY --from=build /usr/src/multus-cni/LICENSE /usr/src/multus-cni/LICENSE`, `COPY --from=build /usr/src/multus-cni/bin/cert-approver /`, `ENTRYPOINT ["/usr/src/multus-cni/bin/multus-daemon"]`. No USER, ENV or EXPOSE. Build via `./hack/build-go.sh`. |
| Ports | None (draft: `ports: none`). Not confirmed on a fetched page for the daemon; UNVERIFIED that multus-daemon opens no listening port. |
| Env vars | None in the upstream Dockerfile. Runtime env for the chart: UNVERIFIED (chart values not fetched). |
| Dependencies (chart) | Draft: `crane` (alpine/crane, craneImage) and `cni` (ghcr.io/siderolabs/cni, talosCniImage), both missing from ContainerForge. UNVERIFIED (chart values not fetched). Sibling present: `apps/cni-plugins` (containernetworking plugins, `CNI_BIN_DIR=/host/opt/cni/bin`). It is not the siderolabs `cni` image. |
| Chart security (draft, not fetched) | Privileged init (talos path), hostNetwork, hostPID, runAsUser 0, hostPath mounts `/opt/cni/bin`, `/etc/cni/net.d`, `/var/lib/cni/multus`, `/`, `/run`, `/var/run/netns`, `/run/k8s.cni.cncf.io`, `/var/lib/kubelet`. UNVERIFIED: charts/stable/multus-cni values not fetched. |

## 2. Target layout

Option A (recommended only if the maintainer accepts a host-install image, see section 10): files under `apps/multus-cni/` mirroring `apps/cni-plugins`:

- `Dockerfile` (required)
- `docker-bake.hcl` (required)
- `settings.yaml` (required)
- `container-test.yaml` (required)
- `start.sh` is not needed if the command is a `CMD` with `rsync`, as in `apps/cni-plugins`. Add it only if the copy needs logic.
- `defaults/`, `etc/`, `health/`: not needed. Reason: no config is shipped in option A.

Option B (daemon in the container): same files plus `start.sh` running `multus-daemon` with its config. Not recommended: it cannot meet the repo rules (section 9).

Do not create `root/`. Do not create `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

- `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a` (same as `apps/cni-plugins`, the closest sibling; it uses the `26.4` tag form, which is the sibling's choice, keep it for consistency).
- Why it fits: a prebuilt Go binary needs no runtime beyond glibc-compatible userland. Upstream's `debian:stable-slim` is replaced by the ContainerForge ubuntu base (repo base table: generic Debian/Ubuntu userland). The static Go build is not known to be static (UNVERIFIED); test that it runs on ubuntu glibc.
- Build stage is not needed: the release tarball is used, not a source build (repo rule for Go: build stage only if compiled in this image; here it is not).

## 4. Dockerfile

Option A steps:

1. Header: `ARG VERSION`, `ARG TARGETARCH`. Map `TARGETARCH` to the tarball name: `amd64` and `arm64` are the only two needed (`386`, `armv6`, `s390x` are not built).
2. `USER root`.
3. One `RUN` with `set -eu`:
   - `apt-get update && apt-get install -y --no-install-recommends rsync` (same as `apps/cni-plugins`).
   - `mkdir -p /usr/src/multus-cni`.
   - `curl -fsSL -o /tmp/multus.tar.gz "https://github.com/k8snetworkplumbingwg/multus-cni/releases/download/v${VERSION}/multus-cni_${VERSION}_linux_${TARGETARCH}.tar.gz"`. Note: the tag is `v4.3.2` and the file name uses `4.3.2`; make the URL use the tag and the bare version separately (two ARGs or `${VERSION#v}`, as `apps/adguardhome-sync` does).
   - Verify against the upstream checksum: `echo "<sha256-for-arch>  /tmp/multus.tar.gz" | sha256sum -c -`. Pick the sha by `TARGETARCH` from `checksums.txt` (values in section 1; put them in the Dockerfile or pass them as ARGs from `docker-bake.hcl`; the bake file is the place for version-tied values).
   - Extract: `tar xzf /tmp/multus.tar.gz -C /usr/src/multus-cni`.
   - Ship the licence: `mkdir -p /usr/share/licenses/multus-cni && cp /usr/src/multus-cni/LICENSE /usr/share/licenses/multus-cni/` (if the tarball has it; UNVERIFIED).
   - Keep `rsync` installed (the `CMD` uses it at runtime). Clean up with `rm -rf /var/lib/apt/lists/* /tmp/*`; do not purge `rsync`.
4. `ENV CNI_BIN_DIR=/host/opt/cni/bin` (same as `apps/cni-plugins`).
5. `COPY --chmod=0755 health /health` is not needed (no `health/` dir).
6. Final: `USER apps`, `COPY --chmod=0755 . /`, `CMD rsync -av --exclude=LICENSE --exclude=README.md /usr/src/multus-cni/bin/* $CNI_BIN_DIR` (mirrors the sibling's `CMD`; the exact exclude list depends on the tarball layout, UNVERIFIED).

Note: `USER apps` cannot write to `/host/opt/cni/bin` unless the host mount is writable by its UID. This is a conflict with the chart's root requirement; see section 9.

Option B (not recommended): `FROM ubuntu`, `COPY --from=` the upstream image's `/usr/src/multus-cni/bin` (copy-from amd64 and arm64 are `ghcr.io/k8snetworkplumbingwg/multus-cni:v4.3.2-thick`, from the draft). Copying from a upstream image is not the repo pattern for a binary that can be downloaded, so use the tarball instead.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "multus-cni"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=k8snetworkplumbingwg/multus-cni versioning=semver
  default = "v4.3.2"
}

variable "LICENSE" {
  default = "Apache-2.0"
}

variable "SOURCE" {
  default = "https://github.com/k8snetworkplumbingwg/multus-cni"
}
```

- `VERSION` in bake and `ARG VERSION` in the Dockerfile must match. The default tag form is `v4.3.2`; the Dockerfile strips the `v` for the tarball name (see section 4).
- Keep the four standard targets and the `default` group as in `apps/cni-plugins`/`apps/adguardhome-sync`. `image-all` lists `linux/amd64` and `linux/arm64` (both tarballs confirmed).
- Validate with `cd apps/multus-cni && docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/k8snetworkplumbingwg/multus-cni"
ports:
  []
env:
  - name: CNI_BIN_DIR
    default: "/host/opt/cni/bin"
    required: false
volumes:
  - path: /config
    required: false
dependencies: []
```

- `ports: []` (no listening port in option A; the sibling `cni-plugins` uses the same). UNVERIFIED for option B.
- `/config`: not used in option A. Mark `required: false`, or omit it, since the repo rule requires `/config` only when the app persists state. Keep `dependencies: []` for option A. For option B, `dependencies` would list no ContainerForge app, because `crane` and `cni` are not ContainerForge apps (the chart's images are not in this repo).
- `CNI_BIN_DIR` is only read by the `CMD`. Keep it, since the sibling does the same.

## 7. start.sh

Not needed in option A (the `CMD` in the Dockerfile runs `rsync`, as `apps/cni-plugins` does). If a script is added later:

- `set -euo pipefail`, `exec` the final process.
- Only write to `$CNI_BIN_DIR` (host path, passed in by the chart) and `/tmp`. Never write to `/app`.
- Option B would have to start `multus-daemon` with a generated config under `/config` or `/tmp`, wait for the kube API and keep the process as PID 1. UNVERIFIED that the daemon starts without a cluster; test before deciding.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

runners:
- entrypoint: test -f /usr/src/multus-cni/bin/multus-daemon
- entrypoint: /usr/src/multus-cni/bin/multus-daemon --version
filePaths:
- /usr/src/multus-cni/bin/multus-daemon
- /usr/share/licenses/multus-cni/LICENSE
```

- `ports` is empty, so there are no tcp/http probes (repo rule: each port in `settings.yaml` needs a probe; there are none).
- `--version` for `multus-daemon` is UNVERIFIED (the flag must be confirmed on the binary before it is used as an assertion). Remove the line if the binary does not support it.
- The test runs with no env vars. Option A does not need any. Option B needs a Kubernetes cluster, which the single-container suite does not provide. The database-dependency exception in the build protocol does not apply (no database dependency), so option B cannot be functionally tested here. This is a blocker for option B.
- `timeoutSeconds` default from the suite is fine (option A starts and exits quickly). Option A is a one-shot copy container, so the "container still running" step of the protocol does not apply as written. Confirm with the maintainer how a one-shot `CMD` should be judged under the protocol (UNVERIFIED how forgetool handles it).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap / decision |
| --- | --- |
| `/opt/cni/bin` (host) | Option A: `CNI_BIN_DIR=/host/opt/cni/bin`, bind-mounted from the host by the chart. The container must write there, which needs a root-owned or writable host directory. `USER apps` cannot write to a root-owned host directory. Conflict with the repo rule. |
| `/etc/cni/net.d` (host) | Written by multus-daemon (option B) or by the chart's CNI config. Not written by option A. |
| `/var/lib/cni/multus`, `/run/k8s.cni.cncf.io`, `/run/netns`, `/var/run/netns` (host) | Option B only. Host paths, not ContainerForge-owned. Cannot be remapped to `/config` or `/tmp` without breaking CNI behaviour (the kubelet and other CNI plugins use these paths). |
| `/` (hostroot), `/var/lib/kubelet` (host) | Option B only. The draft lists them for the chart. Not reproducible rootless. |
| `/tmp` | Keep at `/tmp` (protocol runs with `--tmpfs /tmp`). |

Security expectations (draft, from the chart, unverified):

- `runAsUser 0`, `runAsNonRoot false`, `readOnlyRootFilesystem false`: incompatible with the repo rules for the daemon. Option A still needs root to write to the host path unless the host directory is writable by `apps` (UID 1000 default; the chart must provide that).
- `privileged: yes` (talos init container): not allowed to be a ContainerForge default. Requires a maintainer decision.
- `hostNetwork`, `hostPID`: option B only. Not reproducible rootless.

## 10. Risks, caveats and open questions

Blockers (must be resolved before PR):

- Repo rules vs. the upstream daemon (section 9). Choose one before any file is written:
  1. Option A: ship only the binaries and a copy-to-host `CMD` (as `apps/cni-plugins`). Compatible with `USER apps` only if the host directory is writable by the container UID; otherwise it needs root and an explicit exception.
  2. Option B: ship the daemon. Needs root, host networking, host PID and hostPath writes. Cannot be `USER apps` nor read-only, and the test suite cannot exercise it (no cluster). Requires an explicit exception from the maintainer, documented in the PR.
  3. Do not port. Record as `blocked: host-privileged CNI daemon` in the draft and move on.
- Option B's test coverage: no cluster in CI, so the suite can prove only that the binary exists and runs `--version`.
- The talos init path (privileged, `ghcr.io/siderolabs/cni`) and the crane image are not ContainerForge apps and are not verified. Out of scope for this app.
- Tarball layout (section 1) and the `--version` flag are UNVERIFIED.

Caveats (draft, `inferred`):

- Only works on a Kubernetes node. Cannot be tested rootless.
- The `apps/cni-plugins` sibling already copies plugins to `/host/opt/cni/bin`. Multus would copy into the same directory: confirm the copy does not overwrite the plugin set the chart expects.

Open questions for the maintainer:

- Option A, B or do not port (above).
- Whether a one-shot copy container is an acceptable ContainerForge app, given the protocol's "container still running" step.

## 11. Build and test steps

From `apps/multus-cni/` (one app at a time, per the build protocol). Only option A is testable here.

1. `docker buildx bake --print` (must exit 0).
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. Run with empty `/config` and read-only rootfs, with a temporary host directory standing in for `/host/opt/cni/bin`:
   ```sh
   mkdir -p /tmp/multus-probe-bin
   docker run --rm --name multus-probe --read-only --tmpfs /tmp \
     -e CNI_BIN_DIR=/host/opt/cni/bin \
     -v /tmp/multus-probe-bin:/host/opt/cni/bin \
     multus-cni:v4.3.2
   ```
   Expected (UNVERIFIED until run): rsync copies `multus-daemon` into the mount and exits 0. Note: the protocol's "still running" check does not apply to a copy job, so record how it was judged.
4. Check the copy: `test -x /tmp/multus-probe-bin/multus-daemon`. Cleanup: `rm -rf /tmp/multus-probe-bin`.
5. Test suite: `forgetool containers test --image multus-cni:v4.3.2 --config ./apps/multus-cni/container-test.yaml`.
6. Option B only: not testable here (no cluster). Record as not tested.
7. arm64: build only if amd64 fails for an arm64-specific reason (protocol rule). Checksum for arm64 is in section 1, so a separate arm64 test is possible on an arm64 host.

## 12. PR checklist

- Branch: `feat/add-multus-cni` from `main`.
- Commit: `feat(multus-cni): add new container`.
- PR title matches the commit. Target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keeping sections and checkboxes. Tick "Built container locally" only if it was built.
- Notes section: `🤖 This PR is AI generated.`
- CLA: tell the user to sign at https://cla-assistant.io/trueforge-org/containerforge (the `license/cla` check shows status). Only the user can sign it.
- State what was not tested: the daemon itself (no cluster), option B, the chart's hostPath and privileged settings (not fetched), arm64, and the one-shot copy judgement.
- The repo-rule conflict (section 10) must be stated in the PR body. The PR must not claim `USER apps` compliance for the daemon.
- Do not add `DOWNSTREAM_CHANGES.md` (not a `FROM` base).
- Pre-completion: bake-print ran; `VERSION`/`ARG VERSION` aligned; checksum verified; `USER apps` in the final stage.

## Fix attempt (2026-11-28)

Policy blocker overridden (draft only): wrote Dockerfile, docker-bake.hcl, settings.yaml, container-test.yaml for the daemon image (option B shape, no start.sh). Verified by downloading the v4.3.2 amd64 tarball: the SHA-256 matches checksums.txt (amd64 `6775a433...`, arm64 `2af3dd58...` from checksums.txt), and the tarball layout is `multus-cni_4.3.2_linux_<arch>/{LICENSE,README.md,multus,multus-daemon,multus-shim}` (no `cert-approver`, unlike the upstream thick image). Binaries are installed to `/usr/src/multus-cni/bin` to match upstream's image path. Still open: the chart must run it as root/privileged with hostPath mounts (the image sets `USER apps`), the `--version` flag and "no listening port" are unverified, the chart's metrics port 8080 is not confirmed on the daemon, the arm64 tarball was not downloaded, nothing was built or run, and the chart's crane/talos installer images are not ContainerForge apps.
