# steam-headless — implementation plan
> Source: ./draft.md · Target: apps/steam-headless/ · Difficulty: hard (desktop stack, GPU/input devices, upstream is root + privileged) · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | Wrapper project tag `1.0.3` (tags 1.0.3, 1.0.2, 1.0.1 on Steam-Headless/docker-steam-headless; the draft's Dockerfile link pins commit `824c88d`, and master HEAD is `824c88d2129c0147e559ed08faf83fce8aed58ff`). Draft image is `josh5/steam-headless:latest` (unversioned). Steam itself is `steam_latest.deb` (unversioned rolling package). |
| Renovate | `datasource=github-tags depName=Steam-Headless/docker-steam-headless versioning=loose` (tracks the overlay scripts); the Steam client updates itself at runtime. UNVERIFIED: that tag 1.0.3 matches the content of commit 824c88d. |
| License | Wrapper repo: GPL-2.0 (GitHub API). Steam client: proprietary Steam Subscriber Agreement. The image ships Steam, so `LICENSE` = `LicenseRef-Steam-Subscriber-Agreement`. UNVERIFIED: exact SPDX-style wording the repo prefers. |
| Source | https://github.com/Steam-Headless/docker-steam-headless (draft's "Application source" points to https://store.steampowered.com/about/) |
| Download | amd64 only: `https://repo.steampowered.com/steam/archive/stable/steam_latest.deb` (HTTP 200, 20379390 bytes on 2026-11-23). arm64: none (Valve ships x86-64 only), so the image is amd64 only. |
| Checksum | Valve publishes no checksum for `steam_latest.deb`. UNVERIFIED alternative: add Valve's apt repo (`repo.steampowered.com/steam`) with its signed `Release`, which gives signature verification instead. |
| Upstream Dockerfile reviewed | `Dockerfile.debian` (base `debian:trixie-slim`): installs supervisor, dumb-init 1.2.5, Xorg + dummy video, x11vnc, PulseAudio, XFCE4, Flatpak, Node.js 20, websockify 0.11.0, a pinned noVNC frontend, `steam-installer`, Sunshine v2026.516.143833, Neko binaries (from `m1k1o/neko:base`), Intel VA-API tools. `EXPOSE 8083`, no VOLUME, `ENTRYPOINT /entrypoint.sh`, creates user `default` (passwordless sudo), runs `/etc/cont-init.d/*` as root. |
| Upstream env vars (from the Dockerfile) | `DISPLAY=:55`, `DISPLAY_SIZEW=1600`, `DISPLAY_SIZEH=900`, `DISPLAY_REFRESH=120`, `DISPLAY_CDEPTH=24`, `PUID=99`, `PGID=100`, `UMASK=000`, `TZ`, `MODE=primary`, `WEB_UI_MODE=vnc`, `WEBUI_USER`, `WEBUI_PASS`, `ENABLE_STEAM=true`, `ENABLE_SUNSHINE=true`, `ENABLE_VNC_AUDIO=true`, `ENABLE_EVDEV_INPUTS=true`, `ENABLE_WOL_POWER_MANAGER=false`, `ENABLE_SID=false`, `STEAM_ARGS="-silent"`, `NEKO_PASSWORD`, `NEKO_PASSWORD_ADMIN`, `USER_PASSWORD`, `NVIDIA_VISIBLE_DEVICES`, `NVIDIA_DRIVER_CAPABILITIES`, `PORT_NOVNC_WEB=8083`. |
| Ports | 8083/tcp noVNC (upstream EXPOSE). The draft's 8084 https and Sunshine 47984/47990/47998-48000 are not in the Dockerfile's EXPOSE; Sunshine ports are UNVERIFIED against its docs and are out of scope for the first version. |
| Persistence | draft chart: `/home/default`, `/mnt/games`, `/var/lib/flatpak`. |

## 2. Target layout

```
apps/steam-headless/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh                         # replaces upstream root init: seeds /config, writes configs, execs supervisord
  etc/supervisor/steam-headless.conf   # rootless supervisord program list (Xvfb, x11vnc, websockify, xfce, steam)
  defaults/                        # xfce / pulse / x11vnc default configs seeded into /config when missing
```
Reason: no root/ allowed; etc/ and defaults/ are on the allow-list. No DOWNSTREAM_CHANGES.md (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`. Steam is a glibc, x86-64 binary and works on Ubuntu with `dpkg --add-architecture i386`. Closest sibling: `apps/steamcmd` (i386 multiarch + apt), and `apps/kasmvnc`, `apps/rdesktop`, `apps/xvfb` for the VNC/desktop parts (read these before writing; their patterns win over the upstream overlay).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`; fail early on arm64: `RUN [ "$TARGETARCH" = "amd64" ] || (echo "amd64 only" && exit 1)`; in bake only `image-all` is restricted to `linux/amd64` (deviation from the standard two-platform list, justified by Valve).
2. `USER root`. `dpkg --add-architecture i386`, `apt-get update`, install only what the base lacks (check `apps/xvfb`, `apps/kasmvnc`): `xvfb`, `x11vnc`, `novnc`/`websockify` (or the pinned frontend), `xfce4` (minimal), `supervisor`, `pulseaudio`, `dbus-x11`, `mesa-vulkan-drivers`, `libgl1:i386`, `libvulkan1:i386`, `ca-certificates`, `curl`. Pin versions of apt packages that define the image version where applicable.
3. Steam: download `steam_latest.deb` to `/tmp`, `apt-get install -y /tmp/steam_latest.deb`, remove the file. No checksum available, so record that in the PR.
4. Licenses: `/usr/share/licenses/steam-headless/` with the wrapper GPL-2.0 LICENSE and the Steam EULA text from `/usr/share/doc/steam-launcher/` (UNVERIFIED path).
5. `ENV HOME=/config DISPLAY=:55 XDG_RUNTIME_DIR=/tmp/runtime PULSE_SERVER=unix:/tmp/pulse/pulse-socket` (the last two match upstream values; HOME moves to `/config`).
6. `COPY --chmod=0755 . /`, `EXPOSE 8083`, `VOLUME /config`, last lines `USER apps` and `COPY --chmod=0755 . /`.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "steam-headless" }
variable "VERSION" {
  // renovate: datasource=github-tags depName=Steam-Headless/docker-steam-headless versioning=loose
  default = "1.0.3"
}
variable "LICENSE" { default = "LicenseRef-Steam-Subscriber-Agreement" }
variable "SOURCE"  { default = "https://github.com/Steam-Headless/docker-steam-headless" }
```
Targets: `docker-metadata-action`, `image`, `image-local` (`${APP}:${VERSION}`), `image-all` with `platforms = ["linux/amd64"]` only, `group "default" { targets = ["image-local"] }`. Run `docker buildx bake --print`.

## 6. settings.yaml

Schema header + `schema_version: 1`, `upstream_env_url: "https://github.com/Steam-Headless/docker-steam-headless"`.
- ports: `8083` tcp `required: false` (noVNC). Sunshine (47984, 47990, 47998-48000/udp) deferred to a second iteration; do not list them until the container opens them.
- env (only those start.sh passes through): `TZ` `Etc/UTC`; `DISPLAY_SIZEW` `1600`; `DISPLAY_SIZEH` `900`; `DISPLAY_REFRESH` `60` (upstream 120; UNVERIFIED if Xvfb honours it); `DISPLAY_CDEPTH` `24`; `WEB_UI_MODE` `vnc`; `WEBUI_USER` `""`; `WEBUI_PASS` `""`; `ENABLE_STEAM` `true`; `STEAM_ARGS` `-silent`. All required false.
- volumes: `/config` required true (home, steam data, flatpak not supported, see section 9); `/mnt/games` required false.
- dependencies: none.

## 7. start.sh

- `set -euo pipefail`; create `/config/{.steam,.config,.local/share,games}` and `/tmp/{runtime,pulse,.X11-unix}` (chmod 1777 for `.X11-unix`); copy defaults from `/defaults` with `cp -n`.
- Never write to `/app` or system paths; `HOME=/config`, caches `XDG_CACHE_HOME=/tmp/.cache`.
- Start a user-level dbus session, PulseAudio (`--exit-idle-time=-1`) and supervisord (`-n -c /etc/supervisor/steam-headless.conf`) as the final `exec`; supervised programs: `Xvfb :55 -screen 0 ${DISPLAY_SIZEW}x${DISPLAY_SIZEH}x${DISPLAY_CDEPTH}`, `x11vnc -forever -rfbport 5900 -localhost`, websockify/noVNC bound to `0.0.0.0:8083` (all interfaces), `startxfce4`, `steam ${STEAM_ARGS}` when `ENABLE_STEAM=true`.
- If `WEBUI_PASS` is set, write an x11vnc password file in `/tmp` (not on the command line, to keep it out of the process list).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 180
tcp:
- port: '8083'
filePaths:
- /start.sh
- /usr/bin/steam
- /etc/supervisor/steam-headless.conf
```
8083 is the only declared port. Long timeout because the desktop stack is slow to start. The test runs without env vars, so the default noVNC path must work with no password. UNVERIFIED: `/usr/bin/steam` path (deb installs `/usr/bin/steam`; confirm in the build).

## 9. Rootless and read-only-rootfs adaptations

- Upstream: root init (`cont-init.d`), user `default` with passwordless sudo, `privileged: true`, PUID/PGID remap, udev/sysctl scripts, Flatpak, GPU driver setup. Here: all root init steps are dropped; `USER apps`; no sudo; no udev; no sysctl.
- Writes: `/home/default` becomes `/config`; `/var/lib/flatpak` is not supported (Flatpak dropped; document); X sockets, pulse socket, XDG runtime to `/tmp`; Steam writes `~/.steam`, `~/.local/share/Steam` into `/config` (persistent, large).
- Draft expects privileged and GPU/input devices. They are NOT required for the noVNC desktop mode (software rendering with Mesa), so the first version targets `privileged: false`. Game streaming through Sunshine needs `/dev/uinput`, `/dev/dri`, and is deferred.
- `/mnt/games` volume optional for game libraries.

## 10. Risks, caveats and open questions

- Likely unfit for a pure rootless/read-only model: Steam needs writable home, bubblewrap/user namespaces for its runtime (`steam-runtime` may need `--cap-add SYS_ADMIN` or unprivileged userns). UNVERIFIED; this is the main blocker risk.
- amd64 only (no arm64), so CI `image-all` must be single-platform.
- No checksum for the Steam .deb; the `latest` package makes builds non-reproducible and the VERSION alignment weaker (image version = wrapper tag, not the Steam version).
- Steam login, game ownership and internet access are required to be useful. First start downloads a large Steam bootstrap (slow).
- Large image and slow build; consider whether ContainerForge wants this at all (blocker: GPU/privileged for the streaming feature).
- Several upstream features (Neko, Sunshine, Flatpak, WoL, evdev) are out of scope.

## 11. Build and test steps

```sh
cd apps/steam-headless
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name steam-headless-probe --read-only --tmpfs /tmp -v steam-headless-probe-config:/config steam-headless:1.0.3
docker logs -f steam-headless-probe
forgetool containers test --image steam-headless:1.0.3 --config ./apps/steam-headless/container-test.yaml
docker rm -f steam-headless-probe; docker volume rm steam-headless-probe-config
```
Expected: supervisord logs show `xvfb`, `x11vnc`, `novnc` entered RUNNING, port 8083 answers; no `permission denied` on `/` paths.

## 12. PR checklist

- Branch `feat/add-steam-headless`; commit and PR title `feat(steam-headless): add new container`; target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`; Notes contain `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- State in the PR: amd64 only; Steam .deb unchecked; Sunshine, Flatpak, GPU and input devices not covered.
- Untested (planning only): the whole build, the rootless Steam runtime, supervisor config, noVNC startup, container test. Do not tick "Built container locally" unless done.
