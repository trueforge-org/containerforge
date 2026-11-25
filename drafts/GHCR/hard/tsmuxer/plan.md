# tsmuxer — implementation plan
> Source: ./draft.md · Target: apps/tsmuxer/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | tsMuxer `2.7.0` (latest upstream release, published 2025-04-21). Chart image `ghcr.io/jlesage/tsmuxer:v26.09.1` (published 2026-09-22) is the GUI wrapper image, not the app version. Source: https://api.github.com/repos/justdan96/tsMuxer/releases/latest |
| Upstream state | `justdan96/tsMuxer` is **archived** (`archived: true`), last push 2025-04-21. No further releases expected. Source: https://api.github.com/repos/justdan96/tsMuxer |
| Renovate | `datasource=github-releases depName=justdan96/tsMuxer versioning=loose` (tags are bare `2.7.0`, not `v`-prefixed) |
| License | Apache-2.0 (repo metadata). Ship the upstream LICENSE from the source tarball. |
| Source URL | https://github.com/justdan96/tsMuxer |
| Per-arch download (amd64) | `https://github.com/justdan96/tsMuxer/releases/download/2.7.0/tsMuxer-2.7.0-linux.zip` (asset confirmed in the release list). Zip contents (binary paths) UNVERIFIED: not downloaded in this run. |
| Per-arch download (arm64) | **No arm64 asset.** Release assets are `-linux.zip` (x86), `-mac`, `-win32`, `-win64`, and `tsMuxerGUI-2.7.0-x86_64.AppImage`. arm64 needs a source build from `https://github.com/justdan96/tsMuxer/archive/refs/tags/2.7.0.tar.gz` (CMake, g++, Qt5). |
| Checksum source | None published (no digest fields on assets). The upstream Dockerfile downloads the source tarball with no checksum. UNVERIFIED whether the jlesage `build.sh` checks it (script not fetched). |
| Upstream Dockerfile reviewed | `https://raw.githubusercontent.com/jlesage/docker-tsmuxer/v26.09.1/Dockerfile`. Build stage `tonistiigi/xx` + `alpine:3.20`, final `FROM jlesage/baseimage-gui:alpine-3.20-v4.14.0`. Qt5 packages via `add-pkg`, `COPY rootfs/ /`, `VOLUME ["/storage"]`. No ENV, EXPOSE, USER, ENTRYPOINT or CMD in the Dockerfile. |
| Ports | Inherited from `jlesage/baseimage-gui` (VNC/noVNC). Port numbers UNVERIFIED on a fetched page; draft says 5800/http and 5900/tcp (inferred). |
| Data paths | Upstream volume `/storage` (media in/out). Config path UNVERIFIED. |
| copy-from | `jlesage/tsmuxer` is Alpine/musl. Not usable with `COPY --from` on glibc Ubuntu. |

## 2. Target layout

- `apps/tsmuxer/Dockerfile`
- `apps/tsmuxer/docker-bake.hcl`
- `apps/tsmuxer/settings.yaml`
- `apps/tsmuxer/container-test.yaml`
- `apps/tsmuxer/start.sh`

`defaults/` only if a Qt/desktop config seed is needed. No `root/`. No `DOWNSTREAM_CHANGES.md` (not a base image). Closest desktop/VNC sibling: `apps/kasmvnc`; check its Dockerfile before copying the VNC layout.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`. Ubuntu is the foundation for generic userland; the app is a native binary, so no language runtime is needed. Do not use the jlesage Alpine base: it is musl and does not fit the glibc layout. The desktop stack (Xvfb, VNC, Qt5 libs) is installed on top of ubuntu.

## 4. Dockerfile

1. Build stage `FROM <ubuntu> AS tsmuxer-amd64`, `ARG TARGETARCH`, `ARG VERSION`, `USER root`.
2. Download and verify: `curl -fL -o /tmp/tsmuxer.zip "https://github.com/justdan96/tsMuxer/releases/download/${VERSION}/tsMuxer-${VERSION}-linux.zip"`. No upstream checksum exists, so record the sha256 computed locally in `ARG SHA256_TSMUXER_AMD64` and check with `sha256sum -c`. Comment that the hash is local, not upstream.
3. Install `unzip` (`--no-install-recommends`), extract, copy the binaries (`tsmuxer`, `tsMuxerGUI`; names UNVERIFIED until the zip is listed) to `/app/tsmuxer/`.
4. arm64 (only if requested, see section 10): separate stage building from the source tarball with `cmake`, `g++`, `qtbase5-dev`, `qtmultimedia5-dev`. Not in the first PR.
5. Final stage `FROM <ubuntu>`, `USER root`, `apt-get install -y --no-install-recommends` for `xvfb`, `x11vnc`, `libqt5gui5`, `libqt5widgets5`, `libqt5multimedia5`, `fonts-croscore`, `adwaita-qt` (inferred; confirm each name on Ubuntu 26.04 with `apt-cache policy`). Clean `/var/lib/apt/lists/*`.
6. `COPY --from=tsmuxer-amd64 /app/tsmuxer/ /app/tsmuxer/` and the license to `/usr/share/licenses/tsmuxer/LICENSE`.
7. `ENV HOME=/config XDG_CACHE_HOME=/tmp/cache XDG_RUNTIME_DIR=/tmp/runtime`. No caches in `/config`.
8. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /
EXPOSE 5800 5900
VOLUME /config
VOLUME /storage
```

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "tsmuxer"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=justdan96/tsMuxer versioning=loose
  default = "2.7.0"
}

variable "LICENSE" {
  default = "Apache-2.0"
}

variable "SOURCE" {
  default = "https://github.com/justdan96/tsMuxer"
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
  platforms = ["linux/amd64"]
}
```

`image-all` is amd64 only until an arm64 build exists. Run `docker buildx bake --print` from `apps/tsmuxer/`. Dockerfile `ARG VERSION` must equal `2.7.0`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/justdan96/tsMuxer"
ports:
  - port: 5800
    protocol: http
    required: false
  - port: 5900
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
  - path: /storage
    required: false
dependencies: []
```

Ports 5800 and 5900 are inferred and must be confirmed against baseimage-gui docs before merge. Add `VNC_PASSWORD` only if `start.sh` reads it (name UNVERIFIED). Dependencies: none.

## 7. start.sh

- Idempotent: `mkdir -p /config /tmp/cache /tmp/runtime`, `chmod 0700 /tmp/runtime`. Never write to `/app`.
- Seed `/config` only if missing.
- Start Xvfb on `:0`, then the VNC server bound to `0.0.0.0`.
- Start `/app/tsmuxer/tsMuxerGUI` in the background; `exec` the long-running process (VNC) so PID 1 gets signals.
- Set `DISPLAY=:0` and `QT_QPA_PLATFORM=xcb` in the script.

## 8. container-test.yaml

- Schema header from the siblings (`# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json`).
- `filePaths`: `/start.sh`, `/app/tsmuxer/tsMuxerGUI`, `/app/tsmuxer/tsmuxer` (confirm names), `/usr/share/licenses/tsmuxer/LICENSE`.
- `tcp` probe for 5900. Add an `http` probe for 5800 once confirmed. Probes run inside the container, so they do not prove remote access.
- `timeoutSeconds`: take the value from `apps/kasmvnc/container-test.yaml`.

## 9. Rootless and read-only-rootfs adaptations

- Upstream runs as root. ContainerForge runs as `apps`; X11 sockets go to `/tmp` (needs `--tmpfs /tmp`).
- `XDG_RUNTIME_DIR=/tmp/runtime` (0700) and `XDG_CACHE_HOME=/tmp/cache` keep writes out of `/config`.
- `/storage` is user media, not a cache; keep it writable only if the chart needs it.
- Chart capabilities `NET_BIND_SERVICE` and `KILL`, and `runAsUser 0`, are not needed for ports above 1024. Note for the chart PR; out of scope here.
- Not privileged.

## 10. Risks, caveats and open questions

- **arm64 blocker.** No arm64 binary. Source build needs CMake, g++, Qt5 dev packages. Not in the first PR.
- **Archived upstream.** No further upstream fixes are expected.
- **No checksum.** The zip is unsigned. The locally computed sha256 is not an upstream checksum; say so in the PR.
- **UNVERIFIED zip contents** and **UNVERIFIED ports/env** until built and inspected.
- **GUI, not a service.** Output and input are manual through VNC.
- **Chart drift.** The chart uses `ghcr.io/jlesage/tsmuxer:v26.09.1`; the chart must change when this app lands (chart repo, not this one).

## 11. Build and test steps

From `apps/tsmuxer/`, in order (`.github/instructions/build-test-protocol.instructions.md`):

1. `docker buildx bake --print`
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. `docker run --rm -d --name tsmuxer-probe --read-only --tmpfs /tmp -v tsmuxer-probe-config:/config tsmuxer:2.7.0`, then `docker logs -f tsmuxer-probe` until idle. Readiness signal: the VNC server log line that it is listening (exact text confirmed in the build). Container must stay up.
4. `forgetool containers test --image tsmuxer:2.7.0 --config ./container-test.yaml`
5. Cleanup: `docker rm -f tsmuxer-probe; docker volume rm tsmuxer-probe-config`.

No build or docker run was done for this plan.

## 12. PR checklist

- Branch `feat/add-tsmuxer`; commit and title `feat(tsmuxer): add new container`.
- Use `.github/PULL_REQUEST_TEMPLATE.md`; keep its sections and checkboxes; tick only what was run.
- Notes: `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; `license/cla` shows status).
- Say what was not tested: arm64; ports and VNC env not confirmed live; zip contents unverified until built.
- Downstream: none (not a base image).
