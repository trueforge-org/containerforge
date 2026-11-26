# helfrichmichael/prusaslicer-novnc Dockerfile (+ entrypoint, supervisord, release script)

Source: https://github.com/helfrichmichael/prusaslicer-novnc/blob/master/Dockerfile (raw, master). Follow-ups merged: entrypoint.sh, supervisord.conf, get_latest_prusaslicer_release.sh (raw, master). Fetched 2026-11-26. Upstream origin noted in file: damanikjosh/virtualgl-turbovnc-docker.

## Build
- `ARG UBUNTU_VERSION=22.04`; `FROM nvidia/opengl:1.2-glvnd-runtime-ubuntu${UBUNTU_VERSION}`.
- `ARG VIRTUALGL_VERSION=3.1.1-20240228`, `ARG TURBOVNC_VERSION=3.1.1-20240127`.
- apt (one RUN, --no-install-recommends): wget xorg xauth gosu supervisor x11-xserver-utils libegl1-mesa libgl1-mesa-glx locales-all libpam0g libxt6 libxext6 dbus-x11 xkb-data python3 xterm novnc lxde gtk2-engines-* gnome-themes-standard arc-theme freeglut3 libgtk2.0-dev libwxgtk3.0-gtk3-dev libwx-perl libxmu-dev libgl1-mesa-dri xdg-utils locales pcmanfm jq curl git bzip2 gpg-agent software-properties-common libwebkit2gtk-4.0-dev libnvidia-egl-gbm1.
- Firefox: `add-apt-repository ppa:mozillateam/ppa`, `apt install firefox-esr` (no snap).
- VirtualGL + TurboVNC: `wget` .deb from packagecloud.io (`distro_version_id=35`), `dpkg -i`.
- PrusaSlicer: `ADD get_latest_prusaslicer_release.sh /slic3r`; downloads the asset URL returned by script; `--appimage-extract` into /slic3r/squashfs-root; removes AppImage.
- User: `groupadd slic3r`; `useradd -g slic3r --create-home --home-dir /home/slic3r slic3r` (no fixed UID); dirs /slic3r /configs /prints; chown.
- noVNC cert: `openssl req -x509 -nodes -newkey rsa:2048 -keyout /etc/novnc.pem ... -days 365 -subj CN=localhost` at build (not referenced by supervisord.conf).
- Firefox patched via sed to run under vglrun when `ENABLEHWGPU=true`.
- `ENV PATH ${PATH}:/opt/VirtualGL/bin:/opt/TurboVNC/bin`.
- Copies: entrypoint.sh -> /entrypoint.sh; supervisord.conf -> /etc/; vncresize.html -> /usr/share/novnc/index.html; prusaslicer icons -> /usr/share/novnc/app/images/icons/novnc-*.png (16..192).

## Entrypoint / runtime
- `ENTRYPOINT ["/entrypoint.sh"]`; `VOLUME /configs/`, `VOLUME /prints/`.
- entrypoint.sh: removes /tmp/.X*-lock and /tmp/.X11-unix/X*; if `VNC_PASSWORD` set, writes /root/.vnc/passwd via vncpasswd, else `VNC_SEC="-securitytypes TLSNone,X509None,None"` (no auth); `chown -R slic3r:slic3r /home/slic3r/ /configs/ /prints/ /dev/stdout`; then `exec gosu slic3r supervisord -e $SUPD_LOGLEVEL`. Runs as root until gosu.
- supervisord.conf programs (priority):
  - vnc (0): `/opt/TurboVNC/bin/vncserver $DISPLAY -fg $VNC_SEC -depth 24 -geometry $VNC_RESOLUTION -desktop Prusaslicer`
  - novnc (0): `websockify --web=/usr/share/novnc/ $NOVNC_PORT localhost:$LOCALFBPORT`
  - prusaslicer (1): `/bin/bash -c '$VGLRUN /slic3r/squashfs-root/AppRun --datadir /configs/.config/PrusaSlicer/'`
- Supervisor: nodaemon=true, pidfile /tmp/supervisord.pid.

## Env vars (runtime)
| Var | Default | Use |
| --- | --- | --- |
| DISPLAY | :0 | X display |
| NOVNC_PORT | 8080 | websockify port |
| VNC_PORT | 5900 | VNC port; LOCALFBPORT = VNC_PORT + display number |
| VNC_RESOLUTION | 1280x800 | |
| VNC_PASSWORD | unset | if unset, no VNC auth |
| ENABLEHWGPU | unset | "true" enables vglrun |
| VGL_DISPLAY | egl | |
| SUPD_LOGLEVEL | TRACE | supervisord loglevel |
| SSL_CERT_FILE | (README example) /etc/ssl/certs/ca-certificates.crt | |
| NVIDIA_VISIBLE_DEVICES / NVIDIA_DRIVER_CAPABILITIES | (README: all) | GPU |

## Ports
- 8080/tcp noVNC (HTTP, websockify). 5900/tcp raw VNC (optional, README).

## Volumes/paths
- /configs/ (PrusaSlicer config under /configs/.config/PrusaSlicer/), /prints/ (XDG_DOWNLOAD_DIR), /home/slic3r (HOME, .config symlink to /configs/.config/).

## User/UID
- Container starts as root (entrypoint chown), supervisord runs as `slic3r` via gosu.

## Version/asset naming
- PrusaSlicer: latest GitHub release, AppImage matched by regex `linux-x64-older-distros-GTK3.*AppImage$` (script, unpinned).
- VirtualGL/TurboVNC pinned by ARG.

## Gotchas
- PrusaSlicer version is unpinned (latest release at build time).
- AppImage asset regex is required; upstream PrusaSlicer README says Linux is distributed through Flathub (AppImage asset availability not verified; releases API not fetched).
- Base is nvidia/opengl (NVIDIA-branded image) on Ubuntu 22.04.
- noVNC SSL cert generated but not used by websockify command.
- VNC runs with no auth unless VNC_PASSWORD set.
- Chown of /dev/stdout in entrypoint.
