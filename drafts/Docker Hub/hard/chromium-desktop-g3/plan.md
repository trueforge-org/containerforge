# chromium-desktop-g3 — implementation plan
> Source: ./draft.md · Target: apps/chromium-desktop-g3/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | UNVERIFIED: the chart uses `accetto/ubuntu-vnc-xfce-chromium-g3:latest` (rolling). The image version is the Chromium version, which is not resolved here. Decide the source first (see section 4) and pin its version |
| Renovate | Depends on the Chromium source. For a PPA/apt pin: `datasource=repology depName=ubuntu_26_04/chromium-browser` style (UNVERIFIED); for a vendor .deb or Playwright build: `datasource=npm depName=playwright-core` |
| License | Chromium: BSD-3-Clause; accetto g3 scripts: MIT (README). Bake `LICENSE` = `BSD-3-Clause` (the software in the image is Chromium plus XFCE/TigerVNC under GPL packages, listed as UNVERIFIED completeness) |
| Source URL | https://github.com/accetto/ubuntu-vnc-xfce-g3 (the draft's app source is chromium.googlesource.com) |
| Download | Draft Dockerfile: https://github.com/accetto/ubuntu-vnc-xfce-g3/blob/master/docker/Dockerfile.xfce.24-04 (not fetched in detail; the README says Dockerfiles are multi-stage and feature-flagged, `FEATURES_CHROMIUM`, `FEATURES_NOVNC`). How Chromium is installed there is UNVERIFIED |
| Checksum | UNVERIFIED |
| Ports (verified, user guide) | VNC `5901/tcp` (`VNC_PORT`), noVNC web `6901/tcp` (`NOVNC_PORT`) |
| Env (verified, user guide) | `VNC_PW` (default `headless`), `VNC_RESOLUTION` (1360x768), `VNC_COL_DEPTH` (24), `VNC_VIEW_ONLY` (false), `DISPLAY` (:1), `VNC_PORT`, `NOVNC_PORT`, `NOVNC_HEARTBEAT`, `HEADLESS_USER_ID` (1001), `HEADLESS_USER_GROUP_ID` (0). Upstream user `headless` UID 1001; its Chromium flags file sets `--no-sandbox` and a window size from `VNC_RESOLUTION` |

## 2. Target layout

`Dockerfile`, `docker-bake.hcl`, `settings.yaml`, `container-test.yaml`, `start.sh`, `defaults/` (xfce session/xstartup, Chromium flags file `chromium-flags.conf`, `xfce4` minimal config), `scripts/` (helper to render the VNC password). No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`. Not a sibling-by-family; closest siblings: `apps/steamcmd`-style multi-package Ubuntu apps; a kasmvnc/xvfb sibling mentioned in the draft does not exist in `apps/` (check with `ls apps | grep -i vnc` when porting).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`; `USER root`.
2. Chromium without snap: Ubuntu 26.04's `chromium-browser` is a snap stub. Pick one and pin it (UNVERIFIED which works on 26.04 for both archs): (a) a non-snap apt source, (b) the Playwright-provided Chromium (`npx playwright install chromium`, supports amd64 and arm64), or (c) Debian's `chromium` .deb. The draft marks arm64 `yes*` (unconfirmed) and copy-from arm64 `no`.
3. apt (not already in base): `xfce4`/`xfce4-terminal` (minimal: `xfwm4`, `xfce4-panel`, `xfdesktop4`), `tigervnc-standalone-server`, `novnc`, `websockify`, `dbus-x11`, `fonts-liberation`, `xauth`. Pin versions that determine the image version.
4. Remove screen savers/power manager/lockers to keep it small.
5. Licence files to `/usr/share/licenses/chromium-desktop-g3/`.
6. `ENV HOME=/config DISPLAY=:1 VNC_PORT=5901 NOVNC_PORT=6901 XDG_RUNTIME_DIR=/tmp/runtime XDG_CACHE_HOME=/tmp/.cache`.
7. `COPY --chmod=0755 . /`, `EXPOSE 5901 6901`, `VOLUME /config`, final `USER apps`.

## 5. docker-bake.hcl

APP `chromium-desktop-g3`; VERSION = Chromium version of the pinned source (UNVERIFIED) with a `// renovate: datasource=... depName=...` comment matching the chosen source; LICENSE `BSD-3-Clause`; SOURCE `https://github.com/accetto/ubuntu-vnc-xfce-g3`. Four standard targets, default `image-local`. `docker buildx bake --print`.

## 6. settings.yaml

Schema header, `schema_version: 1`, `upstream_env_url` = SOURCE. ports: `6901/tcp`, `5901/tcp`. env: `VNC_PW` (default `""`; start.sh generates and prints nothing if empty? Rule: generate a random password into `/config/.vnc_pw` and log that it was generated), `VNC_RESOLUTION` `1360x768`, `VNC_COL_DEPTH` `24`, `VNC_VIEW_ONLY` `false`, `VNC_PORT` `5901`, `NOVNC_PORT` `6901`, `TZ`. Do not list `HEADLESS_USER_ID/GROUP_ID` (user fixed to 568). volumes: `/config` required. Chart mount `/UNRAID_SHARE` is deployment-specific (not declared). dependencies: none.

## 7. start.sh

1. `mkdir -p /config/.config /config/Downloads /tmp/runtime /tmp/.X11-unix`; copy defaults to `/config` only when missing.
2. Create the VNC password file in `/config/.vnc/passwd` from `VNC_PW` (via `vncpasswd -f` with the password on stdin, not argv); generate a random one when unset.
3. Start `Xvnc :1 -rfbport $VNC_PORT -geometry $VNC_RESOLUTION -depth $VNC_COL_DEPTH -SecurityTypes VncAuth -interface 0.0.0.0` in the background, wait for the X socket in `/tmp/.X11-unix`.
4. Start `dbus-launch xfce4-session` (or the minimal wm), Chromium via the flags file with `--no-sandbox --disable-dev-shm-usage --user-data-dir=/config/chromium`, and `websockify --web /usr/share/novnc 6901 localhost:5901` in the background.
5. Final: `exec` websockify (or a small supervisor loop) as the foreground process; if any background child exits, exit non-zero so the container restarts. Binding on all interfaces.

## 8. container-test.yaml

Schema header, `timeoutSeconds: 240` (desktop startup). `tcp: - port: '5901'` and `- port: '6901'`; `http: - port: '6901' path: /` (noVNC index, path UNVERIFIED). `filePaths`: Chromium binary path (depends on source), `/usr/bin/Xvnc` (UNVERIFIED). The tests run without `VNC_PW`, so the generated-password path is exercised by default.

## 9. Rootless and read-only-rootfs adaptations

- Upstream user `headless` UID 1001 and sudo; we use `apps` UID 568, no sudo.
- Writes: `$HOME` (`/config`), Chromium profile `/config/chromium`, X sockets `/tmp/.X11-unix`, runtime dir and caches `/tmp`, `.vnc` state `/config/.vnc`.
- Sandbox: no `CAP_SYS_ADMIN`; Chromium runs with `--no-sandbox` (matches upstream flags file) unless user namespaces are allowed. Not privileged.
- Draft expects runAsUser 0 and writable rootfs; both are removed. `/UNRAID_SHARE` is just a user bind mount.
- `/dev/shm` needs about 1 GiB or use `--disable-dev-shm-usage`.

## 10. Risks, caveats and open questions

- Chromium source and version are undecided and arm64 availability is unconfirmed (`yes*`).
- Several processes with no supervisor; failure of one child must end the container.
- Heavy on RAM and CPU; Chromium runs unsandboxed.
- Draft Dockerfile (`Dockerfile.xfce.24-04`) is for Ubuntu 24.04, not reviewed in detail; 26.04 package names may differ.
- VNC with a known default password is unsafe; a random password is generated instead.

## 11. Build and test steps

```sh
cd apps/chromium-desktop-g3
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create chromium-desktop-g3-probe-config
docker run --rm -d --name chromium-desktop-g3-probe --read-only --tmpfs /tmp --shm-size=1g -v chromium-desktop-g3-probe-config:/config chromium-desktop-g3:<VERSION>
docker logs -f chromium-desktop-g3-probe
forgetool containers test --image chromium-desktop-g3:<VERSION> --config ./apps/chromium-desktop-g3/container-test.yaml
docker rm -f chromium-desktop-g3-probe; docker volume rm chromium-desktop-g3-probe-config
```
Expected readiness: Xvnc `Listening for VNC connections on TCP port 5901`, websockify `proxying from 0.0.0.0:6901`, and the Chromium process present (`pgrep chrom`); noVNC page loads on 6901.

## 12. PR checklist

- Branch `feat/add-chromium-desktop-g3`; commit and PR title `feat(chromium-desktop-g3): add new container`; target `main`.
- Fill the PR template; Notes include `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Untested: Chromium source choice, build, read-only desktop session, arm64, noVNC login.
