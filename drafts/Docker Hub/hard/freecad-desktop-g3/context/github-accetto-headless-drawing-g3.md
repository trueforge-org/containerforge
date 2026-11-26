# accetto/headless-drawing-g3 (upstream FreeCAD image Dockerfile)

Source URL(s) + fetch date:
- https://raw.githubusercontent.com/accetto/headless-drawing-g3/master/docker/Dockerfile.xfce.drawing.freecad (fetched 2026-11-26, summarised by WebFetch, not verbatim)
- https://github.com/accetto/headless-drawing-g3 (repo root, referenced from draft; not fetched separately)

What it is: multi-stage Dockerfile for the "G3" headless drawing images. The FreeCAD variant layers FreeCAD on the xfce + VNC base.

Install/build steps:
- Build ARGs: `BASEIMAGE=ubuntu`, `BASETAG=24.04` (defaults). Stages: cache, essentials, xserver, xfce, tools, vnc, novnc, mesa, virtualgl, chromium, firefox, firefox_plus, freecad, final, metadata.
- Build ARGs passed at build time (no defaults): `ARG_FREECAD_APPIMAGE`, `ARG_FREECAD_VERSION`, `ARG_TIGERVNC_VERSION`, `ARG_NOVNC_VERSION`, `ARG_WEBSOCKIFY_VERSION`, VirtualGL and Chromium version/distro args.
- FreeCAD stage:
  1. `mkdir ${FREECAD_PATH}` (`/opt/FreeCAD`).
  2. If not cached in `/tmp/g3-cache/freecad/`, wget `https://github.com/FreeCAD/FreeCAD/releases/download/${FREECAD_VERSION}/${FREECAD_APPIMAGE}`.
  3. Copy AppImage into `/opt/FreeCAD`, `chmod 775`.
  4. Copy `xfce-freecad/src/freecad` into `${FREECAD_PATH}`, Desktop files into `${HOME}/Desktop/`.
  5. SVG files mode 664, shell scripts 775, `envsubst` on `FreeCAD.desktop`.
- So the upstream runs the FreeCAD AppImage directly (no `--appimage-extract`).

Runtime deps (apt, by stage):
- essentials: gettext-base, gir1.2-rsvg-2.0, gpg, jq, nano, psmisc, sudo, tini, wget
- xserver: dbus-x11, xauth, xinit, x11-xserver-utils, xdg-utils, libxshmfence1, libxcvt0, libgbm1
- xfce: xfce4, xfce4-terminal, elementary-xfce-icon-theme
- tools: mousepad, python3, systemctl; optional ristretto, xfce4-screenshooter, tumbler
- novnc: python3-numpy
- mesa: mesa-utils, mesa-utils-extra, glmark2
- FreeCAD prerequisites: libpci3, libxss1, libxtst6

Binaries/entrypoint: `ENTRYPOINT ["/usr/bin/tini", "--", "/dockerstartup/startup.sh"]`, no CMD.

Env vars (defaults in upstream):
| Name | Default |
| --- | --- |
| DISPLAY | :1 |
| VNC_COL_DEPTH | 24 |
| VNC_PORT | 5901 |
| VNC_PW | headless |
| VNC_RESOLUTION | 1360x768 |
| VNC_VIEW_ONLY | false |
| NOVNC_HOME | /usr/libexec/noVNCdim |
| NOVNC_PORT | 6901 |
| NO_AT_BRIDGE | 1 |
| FREECAD_PATH | /opt/FreeCAD |
| FEATURES_VNC / FEATURES_MESA / FEATURES_FREECAD | 1 |
| STARTUPDIR | /dockerstartup |

Ports: `EXPOSE ${VNC_PORT}` (5901) and `EXPOSE ${NOVNC_PORT}` (6901).

Volumes/paths: no `VOLUME` instruction in the Dockerfile. Home is `/home/headless`; `WORKDIR ${HOME}`.

User/UID: user and group `headless`, UID/GID 1001. Final stage appends to /etc/passwd and /etc/group, shell `/bin/bash`, sudo via /etc/sudoers.d, sudo password from `ARG_SUDO_INITIAL_PW` (default `headless`), then `USER 1001`.

Gotchas:
- Upstream is a root-capable, sudo-enabled desktop; it is NOT rootless or read-only-rootfs ready. Its FreeCAD is the raw AppImage run at runtime (FUSE-style), not extracted at build time.
- Mesa/VirtualGL are installed; llvmpipe software GL is the upstream path.
- Chromium and Firefox are optional tags (`chromium`, `firefox`) and are not part of the FreeCAD requirement.
- The `latest` tag is built with `--build-arg` values that are not published in the repo (version pins unverified).
- Contradicts plan.md? No. Consistent with plan.md section 1 (AppImage into /opt/FreeCAD, libpci3 libxss1 libxtst6, mesa-utils, ports 5901/6901, user 1001 `headless`).

Failed to fetch: none.

---

## Section: GitHub README / docs (from the Dockerfile's linked docs, not fetched)
- User guide: https://accetto.github.io/user-guide-g3/ (not fetched; see the `dockerhub-accetto-ubuntu-vnc-xfce-freecad-g3.md` note)
