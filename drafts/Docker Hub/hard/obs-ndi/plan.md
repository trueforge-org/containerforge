# obs-ndi — implementation plan
> Source: ./draft.md · Target: apps/obs-ndi/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | DistroAV `6.2.2` (latest release, `releases/latest` redirects to tag `6.2.2`; deb built 2026-10-14). The draft's third-party image is stale: `patrickstigler/docker-obs-ndi` at `400fc92` installs obs-ndi 4.10.0 and libndi4 4.5.1 from the old `Palakis/obs-ndi` project (renamed DistroAV). |
| Renovate | `datasource=github-releases depName=DistroAV/DistroAV versioning=loose` (tags are plain `6.2.2`). OBS from apt: `datasource=repology depName=ubuntu_26_04/obs-studio versioning=loose` (same pattern as `apps/mariadb` and `apps/valkey`). |
| License | DistroAV: GPL v2 (the `LICENSE` file is "GNU GENERAL PUBLIC LICENSE Version 2, June 1991"); use `GPL-2.0-only` (whether source headers say "or later" is UNVERIFIED). OBS Studio is GPL-2.0-or-later. The NDI runtime is proprietary (NDI SDK License Agreement), see section 10. |
| Source URL | https://github.com/DistroAV/DistroAV |
| amd64 download | https://github.com/DistroAV/DistroAV/releases/download/6.2.2/distroav-6.2.2-x86_64-linux-gnu.deb (141050 bytes), sha256 `d953385aa3082612899111801a05f63970163737cf3ab71128f56c58917bb826` (computed by downloading). |
| arm64 | None: the release has only the x86_64 Linux deb, macOS, Windows and source assets. Draft is right: amd64 only. |
| Deb contents | `Package: distroav`, `Depends: libc6 (>= 2.34), libcurl4t64, libgcc-s1, libqt6core6t64, libqt6gui6t64, libqt6widgets6t64, libstdc++6, obs-studio`; installs `/usr/lib/x86_64-linux-gnu/obs-plugins/distroav.so` and `/usr/share/obs/obs-plugins/distroav/locale/*`. It contains no license file. |
| Ubuntu archive | Ubuntu 26.04 (`resolute`) has `obs-studio 32.1.0-0ubuntu3` and `distroav 6.1.1-0ubuntu3` (Launchpad API). The archive DistroAV is older than the release, so use the release deb. DistroAV requires OBS 31.1.1 or higher and NDI Runtime 6.3 or higher (README). |
| NDI runtime | Not in the deb. The wiki says on Debian/Ubuntu run `CI/libndi-get.sh install`, which downloads `https://downloads.ndi.tv/SDK/NDI_SDK_Linux/Install_NDI_SDK_v6_Linux.tar.gz` (67 MB, unversioned URL, last modified 2026-11-18, sha256 seen `1b066cca076d3e8b49a5f1dc7fbf77065967256807e3cb5ea387c574176eace6`) and runs its installer script with the EULA piped in. The archive holds one shell script with an embedded archive (`__NDI_ARCHIVE_BEGIN__`) and shows the "NDI SDK License Agreement" (Vizrt NDI AB) first. |
| Extra Linux requirement | The wiki: `avahi-daemon` and `ffmpeg` for NDI source discovery on Linux. |
| Upstream (third-party) Dockerfile reviewed | `FROM accetto/ubuntu-vnc-xfce-g3`, `EXPOSE 5901 6901 4455`, `VNC_PASSWD=headless`, installs OBS from `ppa:obsproject/obs-studio`, symlinks `/config/obs-studio` to `/root/.config/obs-studio`, `VOLUME /config`. So the draft's ports 3000, 3001 and 5900 are **inferred wrongly for that image** (it uses 5901, 6901, 4455); they match the ContainerForge `kasmvnc` base instead (3000 and 3001), which is what this plan uses. 4455 is the obs-websocket port, opened only when the plugin is enabled (UNVERIFIED default). |
| GUI base | `apps/kasmvnc` exists (`ghcr.io/trueforge-org/kasmvnc`, tag `1.5.2`, index digest `sha256:870414f75035f215e19dbb5583e163b5d8e603e41ca8fa0e4669323c45fbdc27`, read from ghcr.io): Xvnc, openbox, nginx on 3000 (HTTP) and 3001 (HTTPS), `/start.sh` launching everything, openbox autostart seeded into `/config/.config/openbox/autostart` when missing, `HOME=/config`. |

## 2. Target layout

```
apps/obs-ndi/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
  defaults/obs-autostart     # openbox autostart that launches OBS (seeded into /config when missing)
```

`defaults/` is on the allow-list of `include/.dockerignore`. No `root/`. No `DOWNSTREAM_CHANGES.md` (nothing builds on `obs-ndi`).

## 3. Base image

`FROM ghcr.io/trueforge-org/kasmvnc:1.5.2@sha256:870414f75035f215e19dbb5583e163b5d8e603e41ca8fa0e4669323c45fbdc27`. It already provides the X server, window manager, web VNC client, mesa software GL, ffmpeg, pulseaudio and nginx, so none of that is reinstalled. This replaces the draft's plain `ubuntu` (no language runtime) because the draft itself says a KasmVNC or Xvfb desktop is needed and `kasmvnc` is the existing sibling. Closest sibling: `apps/kasmvnc` (and `apps/xvfb` as the minimal alternative); `apps/rdesktop` for another GUI wrapper.

## 4. Dockerfile

1. `ARG VERSION` (DistroAV), `ARG OBS_VERSION`, `ARG OBS_PACKAGE_VERSION`, `ARG DISTROAV_SHA256`, `ARG TARGETARCH`. Fail fast on other architectures: `RUN [ "${TARGETARCH}" = "amd64" ] || (echo "obs-ndi is amd64 only" && exit 1)`.
2. `USER root` only for this install `RUN`:
   ```dockerfile
   RUN test "${OBS_PACKAGE_VERSION%%-*}" = "${OBS_VERSION}" && \
     apt-get update && \
     apt-get install -y --no-install-recommends "obs-studio=${OBS_PACKAGE_VERSION}" ca-certificates curl && \
     curl -fsSL -o /tmp/distroav.deb "https://github.com/DistroAV/DistroAV/releases/download/${VERSION}/distroav-${VERSION}-x86_64-linux-gnu.deb" && \
     echo "${DISTROAV_SHA256}  /tmp/distroav.deb" | sha256sum -c - && \
     apt-get install -y --no-install-recommends /tmp/distroav.deb && \
     mkdir -p /usr/share/licenses/obs-ndi && \
     curl -fsSL -o /usr/share/licenses/obs-ndi/LICENSE "https://raw.githubusercontent.com/DistroAV/DistroAV/${VERSION}/LICENSE" && \
     cp /usr/share/doc/obs-studio/copyright /usr/share/licenses/obs-ndi/OBS-COPYRIGHT && \
     rm -rf /tmp/distroav.deb /var/lib/apt/lists/*
   ```
   Packages are pinned (`obs-studio`) and checked against `OBS_VERSION`, as `apps/valkey/Dockerfile` does. `ca-certificates` and `curl` are likely already in the base, then drop them (check with `dpkg -l`). No `avahi-daemon` (cannot run rootless, section 10).
3. Move the base start script out of the way: `RUN mv /start.sh /kasmvnc-start.sh` (still as root, same layer or a following one), because `COPY . /` below installs this app's own `/start.sh` and the shared entrypoint runs `/start.sh`.
4. `ENV HOME=/config QT_QPA_PLATFORM=xcb XDG_CACHE_HOME=/tmp/.cache LIBGL_ALWAYS_SOFTWARE=1` (software rendering by default; GPU users can unset it). Caches go to `/tmp`, config to `/config`.
5. Final lines, in this order: `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 3000 3001`, `VOLUME /config`, `WORKDIR /config`. The last user is `USER apps` (the base's own `USER apps`, restated).

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "obs-ndi" }

variable "VERSION" {
  // renovate: datasource=github-releases depName=DistroAV/DistroAV versioning=loose
  default = "6.2.2"
}

variable "OBS_VERSION" {
  // renovate: datasource=repology depName=ubuntu_26_04/obs-studio versioning=loose
  default = "32.1.0"
}

variable "OBS_PACKAGE_VERSION" { default = "32.1.0-0ubuntu3" }
variable "DISTROAV_SHA256" { default = "d953385aa3082612899111801a05f63970163737cf3ab71128f56c58917bb826" }
variable "LICENSE" { default = "GPL-2.0-only" }
variable "SOURCE" { default = "https://github.com/DistroAV/DistroAV" }
```

`image` args: `VERSION`, `OBS_VERSION`, `OBS_PACKAGE_VERSION`, `DISTROAV_SHA256`; OCI labels `source` and `licenses`. Targets `docker-metadata-action`, `image`, `image-local` (`type=docker`, `${APP}:${VERSION}`), `image-all` with **`platforms = ["linux/amd64"]` only** (no arm64 plugin; document the deviation), `group "default" { targets = ["image-local"] }`. Run `docker buildx bake --print`. A new DistroAV release needs `DISTROAV_SHA256` updated by hand. The `PACKAGE_VERSION` for apt must be re-checked on each OBS bump.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/DistroAV/DistroAV"
ports:
  - port: 3000
    protocol: tcp
    required: false
  - port: 3001
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
  - name: CUSTOM_PORT
    default: "3000"
    required: false
  - name: CUSTOM_HTTPS_PORT
    default: "3001"
    required: false
  - name: CUSTOM_USER
    default: "apps"
    required: false
  - name: PASSWORD
    default: ""
    required: false
  - name: SUBFOLDER
    default: "/"
    required: false
  - name: NDI_ACCEPT_EULA
    default: ""
    required: false
volumes:
  - path: /config
    required: true
```

The first six env vars are the ones the `kasmvnc` `start.sh` really reads (same list as `apps/kasmvnc/settings.yaml`); `NDI_ACCEPT_EULA` is implemented by this app's `start.sh`. The draft's port 5900 (VNC) is not listed because the `kasmvnc` base does not open it (UNVERIFIED either way; only ports the container really opens are listed). No `dependencies:` (none; `kasmvnc` is a build-time base, not a runtime service).

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

# Seed OBS autostart only when missing (the base only seeds its xterm default when this file is absent)
mkdir -p /config/.config/openbox /config/.config/obs-studio /tmp/.cache
if [[ ! -f /config/.config/openbox/autostart ]]; then
  cp /defaults/obs-autostart /config/.config/openbox/autostart
fi

# NDI runtime: downloaded on first start only after the user accepts the NDI SDK license
if [[ "${NDI_ACCEPT_EULA:-}" == "yes" ]] && ! ls /config/ndi/libndi.so.6* >/dev/null 2>&1; then
  mkdir -p /config/ndi /tmp/ndi
  curl -fsSL -o /tmp/ndi/sdk.tar.gz "https://downloads.ndi.tv/SDK/NDI_SDK_Linux/Install_NDI_SDK_v6_Linux.tar.gz"
  tar -xzf /tmp/ndi/sdk.tar.gz -C /tmp/ndi
  # extract the embedded archive without running the interactive installer
  start_line="$(awk '/^__NDI_ARCHIVE_BEGIN__/ { print NR+1; exit }' /tmp/ndi/Install_NDI_SDK_v6_Linux.sh)"
  tail -n +"${start_line}" /tmp/ndi/Install_NDI_SDK_v6_Linux.sh | tar -xz -C /tmp/ndi
  case "$(uname -m)" in x86_64) libdir=x86_64-linux-gnu ;; aarch64) libdir=aarch64-newtek-linux-gnu ;; esac
  find /tmp/ndi -path "*${libdir}*" -name 'libndi.so*' -exec cp -a {} /config/ndi/ \;
  rm -rf /tmp/ndi
fi
if ls /config/ndi/libndi.so.6* >/dev/null 2>&1; then
  export NDI_RUNTIME_DIR_V6=/config/ndi LD_LIBRARY_PATH="/config/ndi:${LD_LIBRARY_PATH:-}"
else
  echo "NDI runtime not installed: set NDI_ACCEPT_EULA=yes to download it, or mount it at /config/ndi"
fi

exec /kasmvnc-start.sh "$@"
```

The `libdir` directory name inside the SDK archive, the archive marker handling and the `NDI_RUNTIME_DIR_V6` variable are UNVERIFIED and must be checked by running it. The script is idempotent (downloads once, never overwrites user state), writes only to `/config` and `/tmp`, and hands off to the base script with `exec`, which binds Xvnc and nginx on all interfaces (`-interface 0.0.0.0`). No secrets are handled here. `defaults/obs-autostart` content: `obs --disable-shutdown-check --multi &` style single line launching OBS (flags UNVERIFIED; run `obs --help` in the image), preceded by exports if needed.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '3000'
- port: '3001'
http:
- port: '3000'
  path: /
filePaths:
- /usr/bin/obs
- /usr/lib/x86_64-linux-gnu/obs-plugins/distroav.so
- /usr/share/licenses/obs-ndi/LICENSE
- /kasmvnc-start.sh
```

Every port in `settings.yaml` (3000, 3001) has a tcp probe; 3000 also has an http probe. Timeout is copied from the heavier GUI siblings. The test runs with no env, and the NDI runtime path (`NDI_ACCEPT_EULA=yes`) is only reachable by hand (section 11), so it is not covered by this suite. `kasmvnc`'s own test only has the two tcp probes (`apps/kasmvnc/container-test.yaml`).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
|---|---|
| `/root/.config/obs-studio` symlinked to `/config/obs-studio` | `HOME=/config`, OBS writes `/config/.config/obs-studio` (migration from the chart's `/config/obs-studio`: move the folder). |
| `/etc/nginx`, nginx pid/log | already handled in the `kasmvnc` base (`/tmp/nginx*`). |
| Mesa/Qt/X caches | `XDG_CACHE_HOME=/tmp/.cache`; base uses `XDG_RUNTIME_DIR=${HOME}/.XDG`. |
| NDI runtime install to `/usr/local/lib` (the SDK installer) | `/config/ndi` plus `NDI_RUNTIME_DIR_V6`/`LD_LIBRARY_PATH`; nothing is installed into the root filesystem at runtime. |
| `avahi-daemon` (system service) | not run, see section 10. |
| root user in the third-party image | `USER apps` (inherited). |

Draft reconciliation: the chart runs uid 0 with `NET_BIND_SERVICE` and `KILL` capabilities and a writable rootfs; this image runs as `apps` on unprivileged ports 3000/3001, so neither capability nor root are needed. Not privileged. The base's own `kasmvnc` start script already sets up the read-only workarounds (it writes to `/tmp`). `/config` replaces the chart's `/config/obs-studio` path. Real GL acceleration needs `/dev/dri` mounts (not part of the test).

## 10. Risks, caveats and open questions

- **NDI runtime license**: the NDI SDK installer shows the "NDI SDK License Agreement" and requires acceptance; whether a public container image may bundle `libndi` is a licensing question for the maintainers (UNVERIFIED). This plan avoids redistributing it: the runtime is downloaded at first start only when the user sets `NDI_ACCEPT_EULA=yes`. The downloaded URL is unversioned, so no checksum can be pinned (sha256 seen on 2026-11-23: `1b066cca...ce6`), and the first start needs internet access.
- **Discovery**: NDI source discovery on Linux uses `avahi-daemon` per the DistroAV wiki, which needs root and a system bus; it is not available as `apps`. Discovery may therefore fail; sources can be added by IP, or an NDI Discovery Server can be used. mDNS also needs `--network host` or a macvlan network, and NDI uses further TCP and UDP ports that are not declared here (UNVERIFIED, see NDI docs).
- amd64 only; `image-all` limited to amd64 (draft). A multi-arch CI matrix may need an exception.
- `obs-studio=32.1.0-0ubuntu3` is pinned from the Launchpad data of 2026-11-23; a security update in the archive changes the pinned version and the build then fails until `OBS_PACKAGE_VERSION` is bumped.
- DistroAV 6.2.2 declares `Depends: obs-studio` without a version, but the README requires OBS 31.1.1 or higher; 32.1.0 satisfies it. NDI Runtime 6.3 or higher is required.
- Software rendering (llvmpipe) is slow for real streaming; no GPU or hardware encode in the test.
- The image depends on `apps/kasmvnc` keeping `/start.sh` as its entrypoint script and `/defaults` layout; changes there must be checked against this image.
- Exact OBS command-line flags, the `obs-autostart` content and the SDK archive layout are UNVERIFIED until a run.

## 11. Build and test steps

```sh
cd apps/obs-ndi
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name obs-ndi-probe --read-only --tmpfs /tmp \
  -v obs-ndi-probe-config:/config obs-ndi:6.2.2
docker logs -f obs-ndi-probe
forgetool containers test --image obs-ndi:6.2.2 --config ./apps/obs-ndi/container-test.yaml
docker rm -f obs-ndi-probe; docker volume rm obs-ndi-probe-config
```

Expected readiness: container keeps running, `[entrypoint] Info: Executing /start.sh` followed by the Xvnc websocket and nginx start lines from the base, `curl -sk https://localhost:3001/` and `curl http://localhost:3000/` answer, and the OBS window starts (check `docker exec ... pgrep obs`). Then repeat with `-e NDI_ACCEPT_EULA=yes` to prove the NDI download path and check that OBS lists the DistroAV entries under Tools. Second start on the same volume must not redownload. Round limit 10.

## 12. PR checklist

- Branch `feat/add-obs-ndi`, commit and PR title `feat(obs-ndi): add new container`, target `main`.
- Use `.github/PULL_REQUEST_TEMPLATE.md`, keep sections and checkboxes, check only what applies.
- Notes section: `🤖 This PR is AI generated.`
- CLA notice to the user: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- State plainly: amd64 only; NDI runtime is not bundled and needs `NDI_ACCEPT_EULA=yes`; avahi discovery unavailable rootless; chart path `/config/obs-studio` moves to `/config/.config/obs-studio`.
- Untested until built: the whole image, the NDI download path, OBS flags, GPU rendering, arm64 (not supported). Do not tick "Built container locally" unless it was built.
