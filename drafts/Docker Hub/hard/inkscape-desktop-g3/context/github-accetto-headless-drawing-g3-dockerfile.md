# accetto/headless-drawing-g3 docker/Dockerfile.xfce.drawing

Source URL: https://github.com/accetto/headless-drawing-g3/blob/master/docker/Dockerfile.xfce.drawing
Fetched via: https://raw.githubusercontent.com/accetto/headless-drawing-g3/master/docker/Dockerfile.xfce.drawing
Date fetched: 2026-11-26
Note: master branch, not pinned to a commit. Multi-stage, BuildKit (`RUN --mount`) required.

## Global ARGs
| ARG | Default |
| --- | --- |
| BASEIMAGE | ubuntu |
| BASETAG | 24.04 |
| ARG_HEADLESS_USER_ID | 1001 |
| ARG_HEADLESS_USER_NAME | headless |
| ARG_HEADLESS_USER_GROUP_ID | 1001 |
| ARG_HEADLESS_USER_GROUP_NAME | headless |
| ARG_SUDO_INITIAL_PW | headless |
| ARG_HOME | /home/headless |

## Stage chain (drawing variant)
stage_cache -> stage_essentials -> stage_xserver -> stage_xfce -> stage_tools -> stage_vnc -> stage_novnc -> merge_stage_vnc -> stage_mesa -> merge_stage_mesa -> merge_stage_browser (chromium, firefox, firefox_plus, drawio, gimp, inkscape, blender branch from it) -> merge_stage_drawing -> stage_final -> stage_metadata

Final stage base is `ARG_FINAL_STAGE_BASE` (default `merge_stage_drawing`). `stage_inkscape` is a branch `FROM merge_stage_browser`, so it is built only when targeted or chained through the ARGs.

## Packages per stage (apt)
| Stage | Packages |
| --- | --- |
| essentials | gettext-base gir1.2-rsvg-2.0 gpg jq nano psmisc sudo tini wget |
| xserver | dbus-x11 xauth xinit x11-xserver-utils xdg-utils libxshmfence1 libxcvt0 libgbm1 |
| xfce | xfce4 xfce4-terminal elementary-xfce-icon-theme |
| tools | mousepad python3 systemctl (+ ristretto, xfce4-screenshooter, tumbler by feature flag) |
| mesa | mesa-utils mesa-utils-extra glmark2 |
| virtualgl | VirtualGL .deb from SourceForge (ARG_VIRTUALGL_*) |
| inkscape | software-properties-common, `add-apt-repository ppa:inkscape.dev/stable`, then `inkscape` |
| drawio | libasound2t64 libdrm2 libgbm1 libgl1 libxshmfence1 libnss3 libsecret-1-0 + drawio .deb from GitHub releases |
| gimp | libasound2t64 gimp |
| blender | blender |

## Download-at-build URLs (cached in /tmp/g3-cache)
- TigerVNC: sourceforge `tigervnc/stable/<ARG_TIGERVNC_VERSION>/tigervnc-<ver>.<ARG_TIGERVNC_DISTRO>.tar.gz`, extracted to `/`, then `/usr/bin/vncserver` symlink
- noVNC: github.com/novnc/noVNC archive `v<ARG_NOVNC_VERSION>`; websockify `v<ARG_WEBSOCKIFY_VERSION>` (to `/usr/libexec/noVNCdim`)
- VirtualGL: sourceforge downloads `virtualgl_<ver>_<distro>.deb`
- drawio: github.com/jgraph/drawio-desktop/releases/download/v<ver>/drawio-<distro>-<ver>.deb
- Chromium (not used for inkscape variant): archive.ubuntu.com pool

## ENV (final/runtime)
| Name | Value |
| --- | --- |
| DISPLAY | `${ARG_VNC_DISPLAY:-:1}` |
| VNC_PORT | `${ARG_VNC_PORT:-5901}` |
| VNC_PW | `${ARG_VNC_PW:-headless}` |
| VNC_RESOLUTION | `${ARG_VNC_RESOLUTION:-1360x768}` |
| VNC_COL_DEPTH | `${ARG_VNC_COL_DEPTH:-24}` |
| VNC_VIEW_ONLY | `${ARG_VNC_VIEW_ONLY:-false}` |
| NOVNC_PORT | `${ARG_NOVNC_PORT:-6901}` |
| NOVNC_HOME | /usr/libexec/noVNCdim |
| HEADLESS_USER_ID/NAME/GROUP_ID/GROUP_NAME | from ARGs |
| HOME | `${ARG_HOME:-/home/<name>}` |
| STARTUPDIR | /dockerstartup |
| FEATURES_* | set per stage (FEATURES_VNC=1, FEATURES_NOVNC=1, FEATURES_INKSCAPE=1, FEATURES_OVERRIDING_ENVV, FEATURES_VERSION_STICKER=1, ...) |
| NO_AT_BRIDGE | 1 |
| _INKSCAPE_GC | disable (inkscape stage; comment cites Unraid issue) |

## Ports
- EXPOSE `${VNC_PORT}` (5901) and `${NOVNC_PORT}` (6901)

## Volumes
- None declared in Dockerfile.

## User/UID
- Runtime USER `${HEADLESS_USER_ID}` (1001). User `headless`, group `headless` (1001), home `/home/headless`, sudo via `/etc/sudoers.d/headless` with ALL.
- Sudo initial pw from ARG_SUDO_INITIAL_PW (default `headless`), written to `${STARTUPDIR}/.initial_sudo_password`, cleared by startup script after use. Remains in image history.
- `/etc/passwd` and `/etc/group` are temporarily chmod 666 then reset by set_user_permissions.sh.

## Entrypoint
- `ENTRYPOINT [ "/usr/bin/tini", "--", "/dockerstartup/startup.sh" ]`

## Healthcheck
- None.

## Config files
- `/home/headless/.config` from `xfce/src/home/config`
- `/home/headless/.chromium-browser.init` (chromium stage only)

## Arch
- Not declared in Dockerfile.

## Gotchas
- `RUN --mount` requires BuildKit.
- Inkscape installed from ppa:inkscape.dev/stable (not Ubuntu archive).
- Build-time VNC password default is `headless`; override with ARG_VNC_PW.
- `stage_inkscape` is defined in this file, `FROM merge_stage_browser`. The fetched file does not show how the inkscape image target is selected.
