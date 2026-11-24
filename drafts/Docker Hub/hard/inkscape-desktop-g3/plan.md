# inkscape-desktop-g3 — implementation plan
> Source: ./draft.md · Target: apps/inkscape-desktop-g3/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to ship | `1.4.3` (Ubuntu 26.04 "resolute" package `inkscape 1.4.3-0ubuntu2`, universe, amd64+arm64). Draft tag `latest` is not pinnable. Upstream GitLab also has the 1.4 series. |
| Renovate | UNVERIFIED: apt package, no upstream binary. `valkey` has its repology rule disabled ("repology networking issues"). Plan: copy the valkey comment pattern (`// repologydepName=ubuntu_26_04/inkscape versioning=loose`, not an active renovate line) and bump by hand with the base image. |
| License | `GPL-2.0-or-later` (Inkscape). UNVERIFIED: exact SPDX text in `/usr/share/doc/inkscape/copyright`; confirm in the build. |
| Source URL | https://gitlab.com/inkscape/inkscape (SOURCE for bake: https://inkscape.org/) |
| Download | apt only: `inkscape=1.4.3-0ubuntu2` (resolute). Arch-independent from our side; no per-arch URL, no checksum (apt verifies signatures). |
| Upstream Dockerfile reviewed | https://github.com/accetto/headless-drawing-g3/blob/master/docker/Dockerfile.xfce.drawing (base ubuntu 24.04, `tini` + `/dockerstartup/startup.sh`, Inkscape from `ppa:inkscape.dev/stable`, TigerVNC and noVNC from archives/debs, user `headless` UID 1001). |
| Env vars the accetto image reads | `DISPLAY` (`:1`), `VNC_PORT` (5901), `NOVNC_PORT` (6901), `VNC_PW` (default `headless`), `VNC_RESOLUTION` (1360x768), `VNC_COL_DEPTH` (24), `VNC_VIEW_ONLY` (false), `NO_AT_BRIDGE=1`, `_INKSCAPE_GC=disable` (Unraid). |
| Ports | 6901/tcp noVNC (HTTP), 5901/tcp VNC. |
| Supporting packages in resolute | `tigervnc-standalone-server 1.15.0+dfsg-2build1` (amd64, arm64), `novnc 1:1.6.0-2` (all). websockify package: UNVERIFIED. |

The draft's `/UNRAID_SHARE` persistence is a TrueCharts/Unraid artefact; it is not used here (see section 9).

## 2. Target layout

```
apps/inkscape-desktop-g3/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
  defaults/xstartup        # xfce session start script copied to /config/.vnc on first run
```
`defaults/` is needed so the VNC session script is seeded into `/config` only when missing. No `root/`, no `health/`, no `DOWNSTREAM_CHANGES.md` (not used as a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`

Draft says ubuntu alone is enough; the desktop stack comes from apt. Closest siblings: `apps/xvfb` (apt desktop bits on ubuntu), `apps/kasmvnc` (VNC plus noVNC web, heavier, built from source) and `apps/rdesktop` (xfce/xrdp). Do not build on `kasmvnc` (its `FROM` chain would add a source build); using apt TigerVNC plus noVNC stays small.

## 4. Dockerfile

1. `ARG VERSION`, `ARG PACKAGE_VERSION`, `USER root`.
2. Version guard like `apps/valkey`: `test "${PACKAGE_VERSION%%-*}" = "${VERSION}"`.
3. One `RUN`: `apt-get update && apt-get install -y --no-install-recommends inkscape=${PACKAGE_VERSION} tigervnc-standalone-server tigervnc-tools novnc python3-websockify xfce4-session xfwm4 xfce4-panel xfdesktop4 xfce4-terminal dbus-x11 x11-xserver-utils xauth fonts-dejavu-core ca-certificates` then `apt-get clean && rm -rf /var/lib/apt/lists/*`. Check each name exists on resolute during the build (package split of xfce4 in 26.04 is UNVERIFIED); prefer these small xfce parts over the `xfce4` metapackage. Do not install packages already in the base (check `dpkg -l` in the base once).
4. Licences: `mkdir -p /usr/share/licenses/inkscape-desktop-g3 && cp /usr/share/doc/inkscape/copyright /usr/share/licenses/inkscape-desktop-g3/inkscape-copyright`.
5. `ENV HOME=/config XDG_CONFIG_HOME=/config/.config XDG_CACHE_HOME=/tmp/.cache XDG_RUNTIME_DIR=/tmp/runtime DISPLAY=:1 NO_AT_BRIDGE=1 _INKSCAPE_GC=disable VNC_PORT=5901 NOVNC_PORT=6901 VNC_RESOLUTION=1360x768 VNC_COL_DEPTH=24`.
6. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 5901 6901`, `VOLUME /config`, `CMD ["/start.sh"]` (match the sibling pattern; final user is `apps`).

## 5. docker-bake.hcl

- `APP = "inkscape-desktop-g3"`, `VERSION = "1.4.3"` (preceded by the valkey-style NOTE and repology comment; see section 1), `PACKAGE_VERSION = "1.4.3-0ubuntu2"`, `LICENSE = "GPL-2.0-or-later"`, `SOURCE = "https://inkscape.org/"`.
- `args` in `image` must pass both `VERSION` and `PACKAGE_VERSION`.
- Standard targets: `docker-metadata-action`, `image` (OCI `source`/`licenses` labels), `image-local` (`type=docker`, tag `${APP}:${VERSION}`), `image-all` (`linux/amd64`, `linux/arm64`), `group "default" { targets = ["image-local"] }`.
- Validate: `docker buildx bake --print`.

Renovate comment (disabled repology pattern copied from `valkey`, since renovate cannot track apt reliably; bump by hand with the base image):
```hcl
// renovate: datasource=repology depName=ubuntu_26_04/inkscape versioning=loose
```

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://inkscape.org/"
ports:
  - {port: 6901, protocol: tcp, required: true}   # noVNC web
  - {port: 5901, protocol: tcp, required: false}  # raw VNC
env:
  - {name: VNC_PW, default: "", required: false}          # empty => random password generated and logged once
  - {name: VNC_RESOLUTION, default: "1360x768", required: false}
  - {name: VNC_COL_DEPTH, default: "24", required: false}
  - {name: VNC_PORT, default: "5901", required: false}
  - {name: NOVNC_PORT, default: "6901", required: false}
  - {name: TZ, default: "Etc/UTC", required: false}
volumes:
  - {path: /config, required: true}
dependencies: []
```
Env names mirror the accetto image, but they are read by our own `start.sh`, not by Inkscape. Dependencies: none.

## 7. start.sh

- `#!/usr/bin/env bash`, `set -euo pipefail`.
- `mkdir -p /config/.vnc /config/.config /tmp/runtime && chmod 700 /tmp/runtime`.
- Seed `/config/.vnc/xstartup` from `/defaults/xstartup` only if missing (`cp -n`). `xstartup` runs `exec dbus-launch --exit-with-session startxfce4`.
- Password handled each start: if `VNC_PW` is empty, generate one with `openssl rand -base64 12` (UNVERIFIED that openssl is in the base; else `tr` on `/dev/urandom`) and log it once. Write with `printf '%s' "$VNC_PW" | vncpasswd -f > /config/.vnc/passwd` (stdin, never on the command line); `chmod 600`.
- Start `Xtigervnc`/`tigervncserver`-equivalent bound to all interfaces (no `-localhost`): `Xtigervnc :1 -rfbport "$VNC_PORT" -rfbauth /config/.vnc/passwd -geometry "$VNC_RESOLUTION" -depth "$VNC_COL_DEPTH" -SecurityTypes VncAuth -localhost no &`. UNVERIFIED: exact option names for TigerVNC 1.15 (check `Xtigervnc -help`); socket dir `/tmp/.X11-unix` must be writable in `/tmp`.
- Start session (`/config/.vnc/xstartup`) with `DISPLAY=:1`.
- Run websockify with the noVNC web root in the foreground: `exec websockify --web /usr/share/novnc "0.0.0.0:${NOVNC_PORT}" "localhost:${VNC_PORT}"`. UNVERIFIED: `/usr/share/novnc` path and `vnc.html` entry file; if a `trap` is needed to stop children, add `trap 'kill 0' TERM INT`.
- Nothing is written to `/app`; X sockets, locks and caches go to `/tmp`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '5901'
http:
- port: '6901'
  path: /vnc.html
filePaths:
- /usr/bin/inkscape
- /start.sh
- /usr/share/licenses/inkscape-desktop-g3/inkscape-copyright
```
Probes cover both ports in settings.yaml. `timeoutSeconds: 120` is a guess (desktop start is slower than the 30s-ish siblings); sibling `kasm` uses 300. The test runs with no env vars, so the random-password path is what gets tested; the explicit `VNC_PW` path must be run by hand.

## 9. Rootless and read-only-rootfs adaptations

- Upstream runs as user `headless` UID 1001 with sudo (and chart sets `runAsUser 0`, `readOnlyRootFilesystem false`). Here: `USER apps`, no sudo, no root at runtime; this is an intentional deviation from the draft.
- Upstream writes: `$HOME` (`/home/headless`) -> `HOME=/config`; `/dockerstartup` scripts -> not used; X sockets/locks `/tmp/.X11-unix`, `/tmp/.X1-lock` -> `/tmp`; xfce/Inkscape caches -> `XDG_CACHE_HOME=/tmp/.cache`; runtime dir -> `/tmp/runtime`; dconf/xfce settings -> `/config/.config` (persistent).
- Extra persistence `/UNRAID_SHARE`: not adopted; user files go to `/config` (or a user-mounted subfolder of it). Document in the PR.
- `readOnlyRootFilesystem: true` is the target; if xfce insists on writing elsewhere (e.g. `/var/tmp`, `/run/user`), fix by env or `--tmpfs` documentation, not by weakening.
- No privileged, no device access needed.

## 10. Risks, caveats and open questions

- Large image and heavy RAM (draft caveat); xfce package selection is a guess and may need iteration.
- A VNC password is needed before use (draft caveat). Decision here: random password logged once when `VNC_PW` is unset; alternative `-SecurityTypes None` was rejected as unsafe.
- Inkscape from Ubuntu apt (1.4.3) differs from the upstream PPA used by accetto; renovate cannot track apt automatically.
- noVNC 1.6.0 and websockify package availability/paths on resolute: UNVERIFIED.
- Dbus/session under rootless with no systemd: UNVERIFIED, may need `dbus-launch`.
- arm64 builds: all chosen packages list arm64 for resolute (inkscape, tigervnc); not built.
- Open question: should the app name be `inkscape-desktop-g3` or `inkscape`? Draft uses the chart name; keep it.

## 11. Build and test steps

```sh
cd apps/inkscape-desktop-g3
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name inkscape-desktop-g3-probe --read-only --tmpfs /tmp \
  -v inkscape-desktop-g3-probe-config:/config inkscape-desktop-g3:1.4.3
docker logs -f inkscape-desktop-g3-probe
forgetool containers test --image inkscape-desktop-g3:1.4.3 --config ./apps/inkscape-desktop-g3/container-test.yaml
docker rm -f inkscape-desktop-g3-probe; docker volume rm inkscape-desktop-g3-probe-config
```
Expected readiness: websockify "WebSocket server settings"/"proxying from 0.0.0.0:6901" (exact text UNVERIFIED), TigerVNC "Listening on port 5901" style line, ports 6901 and 5901 open, container still running. Also run once with `-e VNC_PW=test` and connect from the host (not only inside the container), and open Inkscape from the desktop.

## 12. PR checklist

- Branch `feat/add-inkscape-desktop-g3`; commit and PR title `feat(inkscape-desktop-g3): add new container`, target `main`.
- PR body follows `.github/PULL_REQUEST_TEMPLATE.md`, keeps its sections and only checks boxes that apply; Notes contain `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; `license/cla` shows status).
- `bake --print` passes; version aligned in Dockerfile and bake; settings ports/env match `start.sh`; every port has a probe.
- Untested until done: image build (amd64 and arm64), xfce package names, TigerVNC/websockify options, read-only-rootfs run, explicit `VNC_PW` path, forgetool run. State this in the PR if not run.
