# meshroom — implementation plan
> Source: ./draft.md · Target: apps/meshroom/ · Difficulty: very-hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | v2025.1.0 (GitHub release published 2025-08-19, https://api.github.com/repos/alicevision/Meshroom/releases/tags/v2025.1.0). A `nightly` prerelease (2026-06-09) exists: do not pin it. |
| Renovate | `datasource=github-releases depName=alicevision/Meshroom versioning=loose extractVersion=^v(?<version>.+)$` (same `extractVersion` form as `apps/code-server`). The tag has a `v` prefix, stripped by `extractVersion`; the nightly tag must be excluded (UNVERIFIED whether renovate excludes it by default). |
| License | MPL-2.0 per Zenodo record (https://zenodo.org/records/16887472, "License: Mozilla Public License 2.0"). GitHub reports `NOASSERTION` (https://api.github.com/repos/alicevision/Meshroom), so the repo LICENSE file is UNVERIFIED. |
| Source URL | https://github.com/alicevision/Meshroom |
| Binary (amd64) | `Meshroom-2025.1.0-Linux.tar.gz`, 14.3 GB, https://zenodo.org/records/16887472/files/Meshroom-2025.1.0-Linux.tar.gz (Zenodo record lists it; the Windows zip is not used). The GitHub release has no assets in the API response. |
| Checksum source | Zenodo lists MD5 only: `eb8124515bfdd5368faf6929b28c85ba` (https://zenodo.org/records/16887472). No SHA-256 published. Verify with `md5sum` against this value; do not use a SHA-256 that is not published. |
| Per-arch | amd64: prebuilt tarball. arm64: none (`no`). |
| Upstream Dockerfile reviewed | `https://raw.githubusercontent.com/alicevision/Meshroom/v2025.1.0/docker/Dockerfile_ubuntu`: `FROM alicevision/meshroom-deps:${MESHROOM_VERSION}-av${AV_VERSION}-ubuntu${UBUNTU_VERSION}-cuda${CUDA_VERSION}`; builds Meshroom with `python setup.py install_exe`; installs `ssh xauth`; sets `PermitRootLogin yes`; sets root password `meshroom` (do not copy); `EXPOSE 22`; `CMD ["/usr/sbin/sshd", "-D"]`; no ENTRYPOINT; no USER (root); no VOLUME; ENV `MESHROOM_DEV=/opt/Meshroom`, `MESHROOM_BUILD=/tmp/Meshroom_build`, `MESHROOM_BUNDLE=/opt/Meshroom_bundle`, `AV_INSTALL=/opt/AliceVision_install`, `QT_DIR=/opt/Qt/6.8.3/gcc_64`. Header comment says run with `--runtime nvidia`. |
| Chart image | `docker.io/alicevision/meshroom:2025.1.0-av3.3.0-ubuntu22.04-cuda12.1.1@sha256:a53a5926e087409300cc6aaf32e4115d208e1f449fe83b3f52503d438132ef4b` (chart values). Image is the upstream dev image, not the tarball. |
| Chart ports and security | Service `main` port 10243, targetPort 22 (ssh). Security: runAsUser 0, runAsGroup 0, runAsNonRoot false, readOnlyRootFilesystem false, privileged unset. Persistence `data` at `/data`. No env vars. |
| Ports | The draft's 5800/noVNC is NOT supported by the upstream Dockerfile or the chart. Upstream exposes 22/ssh. UNVERIFIED whether a GUI channel exists beyond X11 forwarding. |
| Dependencies | None. GPU: NVIDIA runtime (upstream header; CUDA 12.1.1 in the chart tag). |

## 2. Target layout

- `apps/meshroom/Dockerfile`
- `apps/meshroom/docker-bake.hcl`
- `apps/meshroom/settings.yaml`
- `apps/meshroom/container-test.yaml`
- `apps/meshroom/start.sh`

`etc/` is needed only if an sshd config is shipped; prefer a runtime `sed` in `start.sh` (section 7) so `etc/` is not needed. No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`

The upstream tarball bundles its own libraries and CUDA 12 runtime, so the base is used for the OS only. Closest sibling for a large prebuilt tarball on ubuntu: `apps/adguardhome-sync` (prebuilt binary on ubuntu). UNVERIFIED: whether the bundled libraries run on ubuntu 26.04 rather than the 22.04 the tarball was built on.

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Guard: fail the build on non-amd64 so the image is not published for arm64:
   ```dockerfile
   RUN test "${TARGETARCH}" = "amd64" || { echo "meshroom: amd64 only"; exit 1; }
   ```
3. Runtime libraries not in the bundle (UNVERIFIED list): `apt-get install -y --no-install-recommends openssh-server libgl1 libglu1-mesa libxkbcommon0 libxrender1 libxi6 libsm6 libice6 xvfb` (pinned check against the bundle is UNVERIFIED; add only what `ldd` reports missing in step 3 of the protocol). Then `rm -rf /var/lib/apt/lists/*`.
4. Fetch and verify the 14.3 GB tarball, unpack to `/app/meshroom`:
   ```dockerfile
   RUN curl -fL -o /tmp/meshroom.tar.gz \
       "https://zenodo.org/records/16887472/files/Meshroom-2025.1.0-Linux.tar.gz" && \
       echo "eb8124515bfdd5368faf6929b28c85ba  /tmp/meshroom.tar.gz" | md5sum -c - && \
       mkdir -p /app/meshroom && \
       tar xzf /tmp/meshroom.tar.gz -C /app/meshroom --strip-components=1 && \
       rm -f /tmp/meshroom.tar.gz
   ```
   The tarball is 14.3 GB: the build needs a large `/tmp` on the builder, so use a build stage (`FROM <ubuntu> AS build`) and `COPY --from=build /app/meshroom /app/meshroom` to keep the final layer tidy. UNVERIFIED: the builder disk is large enough.
   Replace the literal `2025.1.0` in the URL and file name with `${VERSION}`. `VERSION` is `2025.1.0` (no `v`; the renovate `extractVersion` strips it). The Zenodo record id (`16887472`) is fixed per release and must be bumped by hand with the version (UNVERIFIED how renovate handles it).
5. Licence: ship the MPL-2.0 text to `/usr/share/licenses/meshroom/LICENSE` if the tarball includes it, else add the upstream MPL-2.0 text from a fetched source (UNVERIFIED: not in the tarball listing, check after unpack).
6. Mutable paths: Meshroom writes its cache and project files to the user's home. Set `ENV HOME=/config` and `XDG_CACHE_HOME=/tmp/cache`, `XDG_CONFIG_HOME=/config/.config`.
7. Tail:
   ```dockerfile
   USER apps
   COPY --chmod=0755 . /

   EXPOSE 2222
   VOLUME /config

   WORKDIR /app/meshroom
   ```

Version alignment: `ARG VERSION` must match `docker-bake.hcl` (`2025.1.0`).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "meshroom"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=alicevision/Meshroom versioning=loose extractVersion=^v(?<version>.+)$
  default = "2025.1.0"
}

variable "LICENSE" {
  default = "MPL-2.0"
}

variable "SOURCE" {
  default = "https://github.com/alicevision/Meshroom"
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
    "linux/amd64"
  ]
}
```

`image-all` lists only `linux/amd64` because there is no arm64 route. Validate with `cd apps/meshroom && docker buildx bake --print`. The Dockerfile uses `VERSION` directly for the tarball name (step 4).

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/alicevision/Meshroom"
ports:
  - port: 2222
    protocol: tcp
    required: true
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
  - name: NVIDIA_DRIVER_CAPABILITIES
    default: "compute,utility,graphics"
    required: false
volumes:
  - path: /config
    required: true
```

Rules: list only what the app reads. `NVIDIA_DRIVER_CAPABILITIES` is a runtime variable the NVIDIA runtime reads; confirm it is needed (UNVERIFIED; common in TrueCharts as `NVIDIA_CAPS`). Upstream sshd listens on 22 (Dockerfile `EXPOSE 22`, chart targetPort 22), but a non-root `apps` process cannot bind below 1024, so this image runs sshd on 2222 (`-p 2222`); there is no 5800 entry. Map service port 22 to 2222 and note the change from the chart's targetPort 22.

## 7. start.sh

- `mkdir -p /config/meshroom /config/.config /tmp/cache`.
- Start sshd on `0.0.0.0:2222` (`-p 2222`; ports below 1024 need root): sshd needs `/run/sshd` and host keys in writable paths. Generate host keys into `/tmp/ssh` on each start (`ssh-keygen -A -f /tmp`) since `/etc` is read-only. UNVERIFIED that sshd accepts a `-h` key path; check `sshd -t` in step 3.
- Authentication: do not carry over `PermitRootLogin yes` and the fixed root password. Use key-based login for `apps` only, with `authorized_keys` in `/config/.ssh`. UNVERIFIED how the user will be seeded; decide in the PR.
- Start the X11 display if GUI forwarding is expected: `Xvfb :99 -screen 0 1920x1080x24 &` in `/tmp` (only when `DISPLAY` is not set). UNVERIFIED.
- `exec /usr/sbin/sshd -D -e -p 2222 -h /tmp/ssh/ssh_host_ed25519_key` (`openssh-server` is in the apt list in Dockerfile step 3; UNVERIFIED that it is not already in the base and that it installs on 26.04).
- No writes to `/app`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 600
tcp:
- port: '2222'
filePaths:
- /app/meshroom/meshroom
- /usr/share/licenses/meshroom/LICENSE
```

- No `http` probe: sshd is not HTTP. The `tcp` probe on 2222 is the readiness check.
- `timeoutSeconds` is large because the image is about 14 GB to pull and unpack. UNVERIFIED: whether the CI runner has enough disk.
- The GPU pipeline is not exercised (no NVIDIA runtime in CI). Narrowed: a GPU path is not testable in this suite.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/root` (home, Meshroom projects and cache) | `/config` (`HOME=/config`) |
| `/tmp/Meshroom_build` (build only) | Not in the final image |
| sshd host keys in `/etc/ssh` | `/tmp/ssh` (generated per start) |
| `/data` (chart persistence `data`) | Not used: this plan uses `/config` as the single persistent path. Remap the chart's `/data` in the PR notes. |
| Chart security | Chart runs root (runAsUser 0, runAsNonRoot false). The plan runs as `apps` on 2222 (no privileged port) with key-only ssh. Privileged is not set in the chart; the NVIDIA runtime needs `NVIDIA_*` env, and is host-side. |

## 10. Risks, caveats and open questions

- Size: 14.3 GB tarball. Build and CI disk space is UNVERIFIED. The `image-local` build may not fit on a standard runner.
- No arm64: `image-all` is amd64 only; the TARGETARCH guard (step 2) makes arm64 fail on purpose.
- NVIDIA GPU: the pipeline needs an NVIDIA runtime on the host. Without it, Meshroom is very slow or fails.
- Access: the upstream image uses sshd with root and a fixed password (`meshroom`). This plan does not carry either over. The draft's noVNC on 5800 is unsupported by any fetched source.
- MPL-2.0: licence file location and content are UNVERIFIED (GitHub reports NOASSERTION).
- Checksum: MD5 only (Zenodo). Use `md5sum -c` as in step 4.
- Renovate: the nightly tag must not become the pin. UNVERIFIED that renovate excludes it.
- Tarball bundles its own libs; compatibility with ubuntu 26.04 is UNVERIFIED.
- Blockers: 14 GB size, NVIDIA runtime. The app cannot be built or tested in the default CI without a large disk.

## 11. Build and test steps

```sh
cd apps/meshroom
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create meshroom-probe-config
docker run --rm -d --name meshroom-probe --read-only --tmpfs /tmp \
  -v meshroom-probe-config:/config meshroom:2025.1.0
docker logs -f meshroom-probe
docker rm -f meshroom-probe; docker volume rm meshroom-probe-config
forgetool containers test --image meshroom:2025.1.0 --config ./apps/meshroom/container-test.yaml
```

Expected readiness signal: sshd logs `Server listening on 0.0.0.0 port 2222` (UNVERIFIED exact text; confirm in step 3). The container must stay running. The build is about 14 GB, so run it on a machine with enough disk.

## 12. PR checklist

- Branch: `feat/add-meshroom`
- Commit: `feat(meshroom): add new container`
- Title: `feat(meshroom): add new container`
- Use `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections and checkboxes.
- Notes section: `🤖 This PR is AI generated.`
- CLA: tell the user to sign at https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Say what was not tested: the GPU run, arm64 (not applicable), the full 14 GB pull and unpack, and the ssh key seeding design.
