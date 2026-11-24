# kdenlive-vnc — implementation plan
> Source: ./draft.md · Target: apps/kdenlive-vnc/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to ship | `25.12.3` = Ubuntu 26.04 package `kdenlive 4:25.12.3-0ubuntu1.1` (resolute / resolute-updates, universe; ports arches carry `-0ubuntu1`, so verify amd64 and arm64 versions in the build). Upstream KDE latest stable tag is `v26.08.3` (newer `v26.11.80` is a pre-release); the image therefore trails upstream. Draft tag `latest` is not pinnable. |
| Renovate | UNVERIFIED for apt. Use the valkey pattern (disabled repology comment `ubuntu_26_04/kdenlive`, `versioning=loose`) and bump by hand. Alternative for upstream tracking: `datasource=github-tags depName=KDE/kdenlive` only if building from source (rejected, see section 10). |
| License | `GPL-3.0-or-later` (draft repo is GPL-3.0; Kdenlive itself is GPL-3.0-or-later, UNVERIFIED in `/usr/share/doc/kdenlive/copyright`). |
| Source URL | https://github.com/KDE/kdenlive |
| Download | apt only; no per-arch URL, no checksum (apt signatures). |
| Upstream Dockerfile reviewed | https://github.com/JonathanTreffler/kdenlive-vnc-docker/blob/64ec5a1/Dockerfile: `jlesage/baseimage-gui:ubuntu-18.04`; apt `software-properties-common dbus-x11 kdenlive vlc breeze-gtk-theme`; `ENV APP_NAME=Kdenlive`; `/startapp.sh`; no EXPOSE, no VOLUME. |
| Ports | 5800/tcp web (provided by jlesage base, not by Kdenlive), 5900/tcp VNC. Both come from the jlesage base image. |
| Env vars | The repo README documents none. The jlesage base reads many (`DISPLAY_WIDTH`, `SECURE_CONNECTION`, `VNC_PASSWORD`, `USER_ID` ...), UNVERIFIED and not relevant to our own stack. |
| Volumes | `/sharedContent` (optional, rw) in the draft; we use `/config`. |
| Supporting packages (resolute) | `tigervnc-standalone-server 1.15.0+dfsg-2build1` (amd64, arm64), `novnc 1:1.6.0-2`. |

## 2. Target layout

```
apps/kdenlive-vnc/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
  defaults/xstartup     # minimal session: window manager + kdenlive
```
`defaults/` seeds the session script into `/config` only when missing. No `root/`, no `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`

The jlesage base is replaced by apt TigerVNC plus noVNC on ubuntu. Closest siblings: `apps/xvfb`, `apps/kasmvnc`, `apps/rdesktop`. A single app window needs only a light window manager, so no full xfce (unlike the inkscape-desktop-g3 plan).

## 4. Dockerfile

1. `ARG VERSION`, `ARG PACKAGE_VERSION`, `USER root`.
2. Guard: `test "${PACKAGE_VERSION#*:}" ` stripped of epoch and revision equals `VERSION` (epoch `4:` must be handled: `v="${PACKAGE_VERSION#*:}"; test "${v%%-*}" = "${VERSION}"`).
3. `apt-get update && apt-get install -y --no-install-recommends kdenlive=${PACKAGE_VERSION} tigervnc-standalone-server tigervnc-tools novnc python3-websockify openbox dbus-x11 x11-xserver-utils xauth fonts-dejavu-core breeze-icon-theme` (UNVERIFIED names; check `vlc` is truly needed: it is in the upstream image, but Kdenlive uses MLT, so omit `vlc` unless a feature requires it). `rm -rf /var/lib/apt/lists/*`.
4. Licences: copy `/usr/share/doc/kdenlive/copyright` to `/usr/share/licenses/kdenlive-vnc/kdenlive-copyright`.
5. `ENV HOME=/config XDG_CONFIG_HOME=/config/.config XDG_DATA_HOME=/config/.local/share XDG_CACHE_HOME=/tmp/.cache XDG_RUNTIME_DIR=/tmp/runtime DISPLAY=:1 QT_X11_NO_MITSHM=1 VNC_PORT=5900 NOVNC_PORT=5800 VNC_RESOLUTION=1920x1080`.
6. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 5800 5900`, `VOLUME /config`, `CMD ["/start.sh"]`.

## 5. docker-bake.hcl

`APP = "kdenlive-vnc"`, `VERSION = "25.12.3"` (with NOTE + disabled repology comment as in valkey), `PACKAGE_VERSION = "4:25.12.3-0ubuntu1.1"`, `LICENSE = "GPL-3.0-or-later"`, `SOURCE = "https://github.com/KDE/kdenlive"`. `image` passes both args and OCI `source`/`licenses` labels; `image-local` (docker output, tag `${APP}:${VERSION}`); `image-all` (amd64, arm64); `docker-metadata-action`; `group "default"` -> `image-local`. Run `docker buildx bake --print`.

Renovate comment (disabled repology pattern copied from `valkey`, since renovate cannot track apt reliably; bump by hand with the base image):
```hcl
// renovate: datasource=repology depName=ubuntu_26_04/kdenlive versioning=loose
```

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/KDE/kdenlive"
ports:
  - {port: 5800, protocol: tcp, required: true}
  - {port: 5900, protocol: tcp, required: false}
env:
  - {name: VNC_PW, default: "", required: false}
  - {name: VNC_RESOLUTION, default: "1920x1080", required: false}
  - {name: VNC_PORT, default: "5900", required: false}
  - {name: NOVNC_PORT, default: "5800", required: false}
  - {name: TZ, default: "Etc/UTC", required: false}
volumes:
  - {path: /config, required: true}
dependencies: []
```
Ports keep the draft's 5800/5900 for compatibility with the TrueCharts chart; variables are read by our `start.sh`.

## 7. start.sh

Same shape as the inkscape-desktop-g3 plan: strict mode; `mkdir -p /config/.vnc /config/.config /config/Videos /tmp/runtime`; seed `/config/.vnc/xstartup` only if missing; if `VNC_PW` empty generate a random password and log it once; write the VNC password file via stdin (`vncpasswd -f`), mode 600, every start; start `Xtigervnc :1` on `0.0.0.0` (no `-localhost`) at `${VNC_RESOLUTION}`; run `xstartup` (`openbox` then `kdenlive`, restarted by a small loop if Kdenlive is closed, UNVERIFIED if wanted); `exec websockify --web /usr/share/novnc 0.0.0.0:${NOVNC_PORT} localhost:${VNC_PORT}`. UNVERIFIED: TigerVNC 1.15 option spelling and noVNC web root. No writes to `/app`; caches in `/tmp`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '5900'
http:
- port: '5800'
  path: /vnc.html
filePaths:
- /usr/bin/kdenlive
- /start.sh
- /usr/share/licenses/kdenlive-vnc/kdenlive-copyright
```
Both settings ports are probed. No env vars in the test, so the generated-password path is exercised; test `VNC_PW` by hand.

## 9. Rootless and read-only-rootfs adaptations

- Chart: `runAsUser 0`, `readOnlyRootFilesystem false`, extra PVC `/sharedContent`. Here: `USER apps`, read-only rootfs target, persistence at `/config` (projects, Kdenlive settings in `/config/.config`, media under `/config/Videos`). `/sharedContent` is not used; users may bind-mount their media anywhere and the PR must say so.
- Upstream writes: `$HOME` -> `/config`; Qt/MLT/fontconfig caches -> `/tmp/.cache`; X sockets -> `/tmp`; Kdenlive temp render files default to a temp folder, UNVERIFIED -> make sure it is `/tmp` or a `/config` path chosen by the user (large renders on a ramdisk `/tmp` can fill memory).
- No privileged or devices; GPU acceleration is not provided (software rendering).

## 10. Risks, caveats and open questions

- GUI-only; needs VNC password; heavy RAM/disk (draft caveats). Size `/tmp` tmpfs and `/config` generously.
- Apt version lags upstream (25.12.3 vs 26.08.3). Building Kdenlive from source or using the upstream AppImage (needs FUSE, Qt) was rejected as too heavy; revisit only if the distro version becomes a problem.
- Epoch in the package version (`4:`) complicates the Dockerfile guard and the bake variable.
- `vlc` in upstream image is probably not needed; verify before dropping.
- Qt under Xtigervnc without GPU: UNVERIFIED; may need `QT_QUICK_BACKEND=software` or `LIBGL_ALWAYS_SOFTWARE=1`.
- ARM64 package build number differs; check `apt-cache policy kdenlive` on both arches.

## 11. Build and test steps

```sh
cd apps/kdenlive-vnc
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name kdenlive-vnc-probe --read-only --tmpfs /tmp \
  -v kdenlive-vnc-probe-config:/config kdenlive-vnc:25.12.3
docker logs -f kdenlive-vnc-probe
forgetool containers test --image kdenlive-vnc:25.12.3 --config ./apps/kdenlive-vnc/container-test.yaml
docker rm -f kdenlive-vnc-probe; docker volume rm kdenlive-vnc-probe-config
```
Expected: websockify proxy line for 5800 (exact text UNVERIFIED), TigerVNC listening on 5900, container stays up, `pgrep kdenlive` succeeds and the web client shows the Kdenlive window.

## 12. PR checklist

- Branch `feat/add-kdenlive-vnc`; commit/PR title `feat(kdenlive-vnc): add new container`; target `main`.
- Use `.github/PULL_REQUEST_TEMPLATE.md`; only check applicable boxes; Notes contain `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only they can sign).
- Version aligned between Dockerfile ARGs and bake; every port probed; `bake --print` ok.
- Untested unless run: both-arch build, Qt software rendering, read-only run, explicit `VNC_PW` path, forgetool. Say so in the PR.
