# multus-cni — implementation plan
> Source: ./draft.md · Target: apps/multus-cni/ · Difficulty: easy · Role: sidecar (talosCniImage) · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | v1.10.0 (published 2026-11-09). The draft pins v1.9.0, which is out of date. Source: https://api.github.com/repos/containernetworking/plugins/releases/latest |
| Chart image | Draft says `ghcr.io/siderolabs/cni:v1.14.0`. Not fetched in this run: UNVERIFIED for its contents and build (`https://github.com/siderolabs/pkgs/blob/main/cni/pkg.yaml` not read). |
| Renovate | `datasource=github-releases depName=containernetworking/plugins versioning=semver` (matches `apps/cni-plugins/docker-bake.hcl`) |
| License | Apache-2.0 (https://raw.githubusercontent.com/containernetworking/plugins/main/LICENSE). Note: `apps/cni-plugins/docker-bake.hcl` declares `AGPL-3.0-or-later`, which does not match the upstream license. Flagged in section 10. |
| Source URL | https://github.com/containernetworking/plugins |
| Download amd64 | https://github.com/containernetworking/plugins/releases/download/v1.10.0/cni-plugins-linux-amd64-v1.10.0.tgz |
| Download arm64 | https://github.com/containernetworking/plugins/releases/download/v1.10.0/cni-plugins-linux-arm64-v1.10.0.tgz |
| Checksum source | Per-asset `.sha256` next to each tarball (confirmed). amd64 `ce8603d6a1bd448efba5bd6dc44f38dce349f821aa57e1bb354b52628ebf1853`, arm64 `4f25d7f136be368746185fba6557d799cf3e1890f7556d450744ea20d300d68c`. `.sha512` also published. |
| Upstream Dockerfile reviewed | Not applicable: the upstream project ships release tarballs, not a Dockerfile for this bundle. The Dockerfile for the chart image (`siderolabs/pkgs`) is UNVERIFIED. |
| Multus meta-plugin | The Multus binary (`k8snetworkplumbingwg/multus-cni`) is NOT in the containernetworking tarball. UNVERIFIED whether the chart's image adds it. Not fetched in this run. |
| Ports | None (file delivery only). |
| Env vars | None read by an upstream runtime. Draft's install target is set by our own start.sh. |
| Data / write paths | Host paths only, from the chart: `/opt/cni/bin`, `/etc/cni/net.d`, `/var/lib/cni/multus`, `/run/...`. Image itself writes nothing. |
| Existing sibling | `apps/cni-plugins` already ships the same containernetworking v1.10.0 bundle (`/plugins`, installs with rsync to `/host/opt/cni/bin`). |

## 2. Target layout

- `apps/multus-cni/Dockerfile`
- `apps/multus-cni/docker-bake.hcl`
- `apps/multus-cni/settings.yaml`
- `apps/multus-cni/container-test.yaml`
- `apps/multus-cni/start.sh` (copies the plugins to the mounted CNI bin path; `exec` at end)

Not needed: `defaults/`, `etc/`, `health/`, `root/` (never used), `DOWNSTREAM_CHANGES.md` (not used as a `FROM` base).

Scope check (blocker for the PR, see section 10): `apps/cni-plugins` covers the same tarballs. Confirm with the user that a second image is wanted before opening a PR, or that multus-cni should differ from cni-plugins by including the Multus binary.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`. Static Go binaries need no runtime. Closest sibling: `apps/cni-plugins`.

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH` (buildx values `amd64`/`arm64` match the asset names directly, no mapping needed). `USER root` for the install step.
2. `ENV DEBIAN_FRONTEND=noninteractive`. Do not `apt-get install` packages the base already has. `rsync` is only needed if start.sh uses it (see section 7): add `apt-get install -y --no-install-recommends rsync` with a pinned version checked against the base, or use `cp` and skip apt entirely (preferred).
3. Download and verify in one step, in `/tmp`:
   ```sh
   curl -fsSL -o /tmp/cni.tgz "https://github.com/containernetworking/plugins/releases/download/${VERSION}/cni-plugins-linux-${TARGETARCH}-${VERSION}.tgz"
   curl -fsSL -o /tmp/cni.tgz.sha256 "https://github.com/containernetworking/plugins/releases/download/${VERSION}/cni-plugins-linux-${TARGETARCH}-${VERSION}.tgz.sha256"
   (cd /tmp && sha256sum -c cni.tgz.sha256)   # file name inside the .sha256 must be renamed, see below
   ```
   The upstream `.sha256` names the original tarball, so either `sed -i "s#  .*#  cni.tgz#"` the checksum file first, or name the downloaded file as the upstream name in `/tmp`. Pick one and keep it.
4. Extract to `/app/cni-plugins/`: `mkdir -p /app/cni-plugins && tar xzf /tmp/cni.tgz -C /app/cni-plugins`. Keep the tar content flat, as in `apps/cni-plugins`.
5. Ship licenses: `mkdir -p /usr/share/licenses/multus-cni && cp <upstream LICENSE> /usr/share/licenses/multus-cni/LICENSE` (get the LICENSE from the release tree or the repo, Apache-2.0, see section 1).
6. `chown -R apps:apps /app/cni-plugins && chmod -R 755 /app/cni-plugins`. Remove `/tmp/cni.tgz*`.
7. `ENV CNI_BIN_DIR=/host/opt/cni/bin` (same name as `apps/cni-plugins`, so the chart can reuse it).
8. Final stage tail:
   ```dockerfile
   USER apps
   COPY --chmod=0755 . /

   VOLUME /config
   ```
   No `EXPOSE`. `VOLUME /config` is kept as the repo rule requires it, although start.sh does not write there (see section 7). Keep `COPY --chmod=0755 . /` (required).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "multus-cni"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=containernetworking/plugins versioning=semver
  default = "v1.10.0"
}

variable "LICENSE" {
  default = "Apache-2.0"
}

variable "SOURCE" {
  default = "https://github.com/containernetworking/plugins"
}
```

Then the default group, `image`, `image-local` and `image-all` targets copied from `apps/cni-plugins/docker-bake.hcl`. Run `docker buildx bake --print` in `apps/multus-cni`. `LICENSE` must be `Apache-2.0`, not the sibling's AGPL value (section 10).

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/containernetworking/plugins"
ports:
  []
env:
  - name: CNI_BIN_DIR
    default: "/host/opt/cni/bin"
    required: false
volumes:
  - path: /config
    required: false
dependencies:
  []
```

Notes: `/config` is not written by this image, so `required: false` (the protocol's empty-`/config` check still runs). `CNI_BIN_DIR` is read by start.sh, so it must be listed. No ports: do not list any.

## 7. start.sh

```bash
#!/usr/bin/env bash

CNI_BIN_DIR="${CNI_BIN_DIR:-/host/opt/cni/bin}"

if [ -d "${CNI_BIN_DIR}" ] && [ -w "${CNI_BIN_DIR}" ]; then
  cp -a /app/cni-plugins/. "${CNI_BIN_DIR}/"
  echo "Installed CNI plugins to ${CNI_BIN_DIR}"
else
  echo "CNI_BIN_DIR ${CNI_BIN_DIR} is missing or not writable; nothing installed"
fi

exec sleep infinity
```

- Idempotent: overwrites plugin files with the same version each start; no `/config` writes.
- No writes to `/app`.
- Bind: no server, no listener.
- `exec sleep infinity` keeps the sidecar alive (the chart runs it as a long-lived container). Mark as a decision: if the chart expects the container to exit after install, use `exec true` instead. Confirm against the chart before opening the PR.
- The install target only exists when the chart mounts the host path. The test runs without it, so the copy branch is not exercised by the test; run it manually per section 11.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
filePaths:
- /app/cni-plugins/macvlan
- /app/cni-plugins/bridge
- /app/cni-plugins/host-local
- /usr/share/licenses/multus-cni/LICENSE
```

- No `tcp` or `http` probes: no ports in `settings.yaml`.
- `filePaths` covers the install payload and the license. The test runs without `CNI_BIN_DIR`, so the copy branch is not tested.
- `timeoutSeconds: 120` is a choice for a file-only image; sibling values range 120-240 (e.g. `apps/babybuddy` 180).

## 9. Rootless and read-only-rootfs adaptations

| Item | Upstream / chart | Plan |
| --- | --- | --- |
| UID | Chart runs installer containers as UID 0 | Image runs as `apps` (568). Writing `/opt/cni/bin` on the host needs a root-owned or writable mount. This is an open question (section 10). |
| readOnlyRootFilesystem | Chart default true; hostPath mounts must be writable | Image is compatible with `--read-only --tmpfs /tmp`. Only the host mount must be writable. |
| privileged | Chart sets `privileged: true` on installer containers | Not needed for the file copy itself; the chart's hostPID/hostNetwork settings are not reproduced by this image. Keep the chart's values as they are. |
| hostNetwork, hostPID, hostPath `/`, `/run`, `/run/netns`, `/var/lib/kubelet` | Chart | Not part of the image; the chart owns them. Not used by start.sh. |
| `/opt/cni/bin` | Draft's extra persistence | Mounted by the chart at `CNI_BIN_DIR`; not in `/config`. |
| `/etc/cni/net.d`, `/var/lib/cni/multus` | Chart hostPaths | Not written by this image. |

The draft's security expectations (root, privileged, host mounts) belong to the chart, not the image. The image itself can run rootless. Confidence: medium, as in the draft.

## 10. Risks, caveats and open questions

- **Duplicate of `apps/cni-plugins`.** Same upstream tarballs, same install target. Confirm with the user before opening a PR; the only real difference would be adding the Multus binary.
- **Multus binary missing.** The containernetworking bundle does not contain the `multus` meta-plugin. UNVERIFIED whether the chart needs it from this image or from the siderolabs image. Not fetched in this run.
- **Chart image not inspected.** `ghcr.io/siderolabs/cni:v1.14.0` and `siderolabs/pkgs cni/pkg.yaml` were not read. Its contents may differ from the containernetworking bundle.
- **Host install needs root.** An `apps` (UID 568) process cannot normally write root-owned `/opt/cni/bin`. Must be decided with the chart maintainer (run as root in the chart, or use a writable mount).
- **License mismatch in sibling.** `apps/cni-plugins/docker-bake.hcl` declares `AGPL-3.0-or-later` while upstream is Apache-2.0. Out of scope here; flagged for the user, not changed.
- **Version drift.** Draft's v1.9.0 is out of date (latest is v1.10.0). Use v1.10.0.
- Draft caveats kept: file-delivery image, not a service; useful only on Kubernetes or Talos nodes.
- No blockers for arm64: `cni-plugins-linux-arm64-v1.10.0.tgz` exists.

## 11. Build and test steps

```sh
cd apps/multus-cni
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name multus-cni-probe --read-only --tmpfs /tmp \
  -v multus-cni-probe-config:/config multus-cni:v1.10.0
docker logs -f multus-cni-probe
docker rm -f multus-cni-probe; docker volume rm multus-cni-probe-config
forgetool containers test --image multus-cni:v1.10.0 --config ./apps/multus-cni/container-test.yaml
```

Manual install check (copy branch, not covered by the test):

```sh
mkdir -p /tmp/cni-bin-check
docker run --rm --read-only --tmpfs /tmp -v /tmp/cni-bin-check:/host/opt/cni/bin multus-cni:v1.10.0 /start.sh
```

Expected readiness signal: "Installed CNI plugins to /host/opt/cni/bin" in logs, and the container stays up (the `sleep infinity` path). If `sleep infinity` is changed (section 7), expect exit 0 instead.

## 12. PR checklist

- [ ] Scope confirmed with the user (duplicate of `apps/cni-plugins`, section 10).
- [ ] Branch `feat/add-multus-cni`, commit `feat(multus-cni): add new container`, PR title the same.
- [ ] Notes section contains `🤖 This PR is AI generated.`
- [ ] Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it; `license/cla` check shows status).
- [ ] PR template `.github/PULL_REQUEST_TEMPLATE.md` kept; only applicable boxes checked.
- [ ] Not tested: arm64 build, host install path, forgetool test run, Multus binary, chart image. Say so in the PR unless they are done.
- [ ] `docker buildx bake --print` run for the bake and Dockerfile changes.
