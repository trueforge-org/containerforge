# avidemux — implementation plan
> Source: ./draft.md · Target: apps/avidemux/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Avidemux `2.8.1` (upstream ARG `AVIDEMUX_VERSION=2.8.1`). Upstream image tag `v26.09.1` (GitHub release, published 2026-09-22, no release assets). Draft tag `ghcr.io/jlesage/avidemux:v26.09.1` agrees. Source: https://api.github.com/repos/jlesage/docker-avidemux/releases/latest, https://raw.githubusercontent.com/jlesage/docker-avidemux/v26.09.1/Dockerfile |
| Renovate | `// renovate: datasource=github-releases depName=jlesage/docker-avidemux versioning=loose` (tracks the upstream image tag `v26.09.1`, the reference this plan follows). Avidemux app version `2.8.1` has no renovate datasource confirmed (UNVERIFIED; SourceForge datasource name not checked). |
| License | Repo: MIT (GitHub SPDX). Avidemux app itself: UNVERIFIED (not read). Do not set `LICENSE` in bake until the app license is read. |
| Source URL | https://avidemux.org/ (draft) and https://github.com/jlesage/docker-avidemux (upstream packaging). |
| Source tarball | `https://downloads.sourceforge.net/project/avidemux/avidemux/2.8.1/avidemux_2.8.1.tar.gz`. Checksum: none published (UNVERIFIED). |
| Codec sources (upstream build) | opencore-amr 0.1.5, twolame 0.4.0, aften 0.0.8 (bz2), libdca 0.0.7 (VideoLAN), dcaenc v3 (gitlab). All from the upstream Dockerfile ARGs. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/jlesage/docker-avidemux/v26.09.1/Dockerfile. Build stage `alpine:3.20` compiles avidemux and the codecs with `tonistiigi/xx` cross-compilation (TARGETPLATFORM aware, so upstream builds arm64 too). Final stage `jlesage/baseimage-gui:alpine-3.20-v4.14.0`. `WORKDIR /tmp`, `add-pkg` for Qt5 and codec libs, `VOLUME ["/storage"]`. |
| Ports | `5800/tcp` (noVNC web GUI, `WEB_LISTENING_PORT`) and `5900/tcp` (VNC, `VNC_LISTENING_PORT`). Source: https://github.com/jlesage/docker-baseimage-gui (README). |
| Env vars (real, from baseimage-gui) | `VNC_PASSWORD` (empty = no password), `WEB_LISTENING_PORT=5800`, `VNC_LISTENING_PORT=5900`, `HOME=/config`, `XDG_CONFIG_HOME=/config/xdg/config`, `XDG_DATA_HOME=/config/xdg/data`, `XDG_CACHE_HOME=/config/xdg/cache`, `TAKE_CONFIG_OWNERSHIP=1`. |
| Data / config write paths | `/config` (baseimage-gui HOME and XDG), `/storage` (`VOLUME` in the upstream image, where the user keeps video files). |
| Copy-from option | `ghcr.io/jlesage/avidemux` is built on `alpine:3.20` (musl). **Not usable on glibc Ubuntu.** Copy-from is `no`. |
| arm64 | Upstream Dockerfile cross-compiles per platform, so arm64 is supported upstream. ContainerForge arm64 Qt build: UNVERIFIED. |
| Dependencies | None. Sibling apps that may be reused: `apps/kasmvnc` (ports 3000/3001, Ubuntu 26.04 base, desktop layer), `apps/xvfb`. Neither is a dependency of avidemux. |

## 2. Target layout

- `apps/avidemux/Dockerfile`
- `apps/avidemux/docker-bake.hcl`
- `apps/avidemux/settings.yaml`
- `apps/avidemux/container-test.yaml`
- `apps/avidemux/start.sh`

Plus `defaults/` only if a default Openbox or window-manager config must be seeded. `root/` is not allowed (agents must not touch it). No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`

Fits: the Ubuntu 26.04 base is glibc, and Qt5 avidemux is built against glibc. The desktop layer comes from `apps/kasmvnc` (or `apps/xvfb` + a VNC server). Closest sibling for a GUI on this base: `apps/kasmvnc` (its `Dockerfile` and `start.sh` show the layout). The jlesage Alpine base is NOT reused.

## 4. Dockerfile

Two build options. Pick one in section 10.

Option A (recommended, less build time): install the distro package on Ubuntu 26.04 instead of compiling.
1. `ARG VERSION` (must match `docker-bake.hcl`), `USER root`.
2. `apt-get install -y --no-install-recommends avidemux3-qt5 avidemux3-plugins-qt5 xvfb` (package names are UNVERIFIED on resolute 26.04: check with `apt-cache policy` in a scratch build before committing). Pin the package version against `VERSION` only if the package version carries the avidemux version; otherwise record the apt version in `docker-bake.hcl` comment.
3. Desktop: reuse the `apps/kasmvnc` approach (noVNC on 5800-style port). Confirm the port mapping in section 6.
4. `COPY --chmod=0755 . /`, `USER apps`, `EXPOSE <web> <vnc>`, `VOLUME /storage`, `VOLUME /config`.

Option B (upstream parity): compile Avidemux 2.8.1 from the SourceForge tarball on Ubuntu 26.04: install Qt5 dev packages, codec dev packages, `cmake`, build in a `build` stage, `COPY --from=build` the install tree to `/usr/local`. Codec sources (opencore-amr, twolame, aften, libdca, dcaenc) are only needed if the upstream codec set is required. Long build; arm64 Qt build untested (section 10).

License file: copy the avidemux license text to `/usr/share/licenses/avidemux/` (path confirmed to be the convention in `dockerfile.instructions.md`). Source for the text: UNVERIFIED until read.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" { default = "avidemux" }

variable "VERSION" {
  // renovate: datasource=github-releases depName=jlesage/docker-avidemux versioning=loose
  default = "v26.09.1"
}

variable "LICENSE" { default = "UNVERIFIED" }
variable "SOURCE" { default = "https://avidemux.org/" }
```

Open question: `VERSION` must match the image version the Dockerfile consumes. If option A uses the apt package, `VERSION` should be the Ubuntu package version, and the upstream jlesage tag is only the reference (section 10). Standard targets and `group "default"` copied from `apps/bazarr/docker-bake.hcl`. Run `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://avidemux.org/"
ports:
  - port: 5800
    protocol: tcp
    required: false
  - port: 5900
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
  - name: VNC_PASSWORD
    default: ""
    required: false
volumes:
  - path: /config
    required: true
  - path: /storage
    required: false
dependencies: []
```

Ports: `5800` and `5900` are the baseimage-gui defaults. Keep only the ports the chosen desktop layer actually opens (option A with kasmvnc: 3000/3001 instead; UNVERIFIED which is correct until the desktop layer is chosen). `VNC_PASSWORD` default empty is the upstream default.

## 7. start.sh

- `mkdir -p /config/xdg/config /config/xdg/data /config/xdg/cache` (idempotent). Do not seed files.
- Export `HOME=/config`, `XDG_*` as above (or `/tmp` for cache if the cache is not wanted in `/config`).
- Start the desktop (Xvfb + VNC/noVNC from the chosen layer), then `exec` the avidemux binary. Optional: `exec` the desktop process last so signals propagate.
- Never write to `/usr` or `/app`. Video files stay under `/storage`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 180
tcp:
- port: '5800'
- port: '5900'
http:
- port: '5800'
  path: /
filePaths:
- /usr/bin/avidemux3_qt5
- /usr/share/licenses/avidemux/LICENSE
```

- Test runs with no env. Option A: `avidemux3_qt5` exists from apt. Option B: path under `/usr/local/bin/` after install (UNVERIFIED path).
- Ports: every port in `settings.yaml` needs a probe (`tcp` for both; `http` for the noVNC port).
- Do not weaken: a GUI app with no headless path cannot run the editor in the test. Test only startup (desktop up, port open, binary present).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | ContainerForge remap |
| --- | --- |
| `/config` (HOME, XDG, desktop state) | `/config` (persistent, as is) |
| `/storage` (`VOLUME`, user video files) | `/storage` (optional, user bind mount) |
| `/tmp` (scratch) | `/tmp` (tmpfs under `--read-only --tmpfs /tmp`) |
| Xvfb / VNC socket dirs (`/tmp/.X11-unix`, `/tmp/.ICE-unix`) | `/tmp` (must exist: create in `start.sh`, `mkdir -p` only when missing) |

Upstream sets root for the GUI base. ContainerForge runs `USER apps`. Xvfb and VNC bind to ports above 1024 (5800, 5900, 3000, 3001), so no `CAP_NET_BIND_SERVICE` is needed. The draft's `capabilities add NET_BIND_SERVICE, KILL` is NOT needed under the ContainerForge model: do not copy it.

Draft's chart security expectations (root, `readOnlyRootFilesystem: false`) are chart-side, not image-side. Keep the image rootless.

## 10. Risks, caveats and open questions

- **Blocker 1, desktop layer.** The GUI needs an X server plus VNC/noVNC. Option A reuses `apps/kasmvnc` (ports 3000/3001). Option B needs a new layer. Decide before writing `start.sh`.
- **Blocker 2, Qt and codec build (option B).** Compile time is long and the arm64 Qt build is untested (draft says inferred; upstream cross-compiles, so arm64 is plausible but unverified here).
- **Blocker 3, GPU and hardware acceleration.** Upstream image uses VA-API and VDPAU libs (`libva`, `libvdpau`). No GPU is available in CI. Rendering is software only in the test.
- **Caveat: no headless path.** The editor is only usable through the GUI. The test can prove the desktop and port are up, not editing.
- **Caveat: upstream is Alpine/musl.** Copy-from is not possible. Any reuse of the jlesage image is out of scope.
- **Caveat: 2.8.1 is old.** Verify the version is still the one upstream ships (the upstream build pins 2.8.1 in v26.09.1).
- License: avidemux app license UNVERIFIED. Do not set `LICENSE` until read.
- Draft's package names `avidemux3-qt5`, `xvfb`, `kasmvnc` are `(inferred)`, not checked against the Ubuntu archive.

## 11. Build and test steps

From `apps/avidemux/`:

1. `docker buildx bake --print`
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. `docker volume create avidemux-probe-config`
4. `docker run --rm -d --name avidemux-probe --read-only --tmpfs /tmp -v avidemux-probe-config:/config -p 5800:5800 avidemux:v26.09.1`
5. `docker logs -f avidemux-probe`. Expected readiness signal: the desktop/VNC server starts (for example a line naming the VNC or web port), process still running, no `Cannot open display` error (UNVERIFIED wording until the desktop layer is chosen).
6. `forgetool containers test --image avidemux:v26.09.1 --config ./container-test.yaml`
7. Cleanup: `docker rm -f avidemux-probe; docker volume rm avidemux-probe-config`.

arm64 only if amd64 fails for an arch-specific reason. Option B build time is long: run it once, not per round, where possible.

## 12. PR checklist

- Branch `feat/add-avidemux`, commit `feat(avidemux): add new container`, PR title the same.
- Use `.github/PULL_REQUEST_TEMPLATE.md`. Keep sections and checkboxes. Check only what applies.
- Notes: `🤖 This PR is AI generated.`
- CLA: tell the user to sign at https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it.
- State what was not tested: the full editor (GUI only), arm64, GPU acceleration, and the codec set.
- Do not check "Built container locally" unless the build ran.
