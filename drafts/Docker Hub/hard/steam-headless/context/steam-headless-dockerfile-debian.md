# Steam-Headless/docker-steam-headless Dockerfile.debian

Source URL(s): https://github.com/Steam-Headless/docker-steam-headless/blob/824c88d/Dockerfile.debian (raw, fetched 2026-11-26)

## Base
- `FROM debian:trixie-slim`; LABEL maintainer = upstream author (not copied).
- apt sources: adds `contrib non-free` to debian.sources; locales en_US.UTF-8 + en_GB.UTF-8.
- ENV LANG/LANGUAGE/LC_ALL = en_US.UTF-8 / en_US:en / en_US.UTF-8

## Default user (build-time ENV, overridable at run)
| ENV | Default |
| --- | --- |
| PUID | 99 |
| PGID | 100 |
| UMASK | 000 |
| USER | default |
| USER_PASSWORD | password |
| USER_HOME | /home/default |
| USER_LOCALES | en_US.UTF-8 UTF-8 |
| TZ | Pacific/Auckland |
- `useradd -d /home/default -s /bin/bash default`; `echo "default ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers`

## Packages (grouped)
- tools: bash, curl, git, jq, sudo, wget, xmlstarlet, p7zip-full, etc.
- python3 + numpy, pip, venv; supervisor
- X: xorg, xserver-xorg-*, x11vnc, xdotool, xinit, xclip, etc.; XORG_SOCKET_DIR=/tmp/.X11-unix, XDG_RUNTIME_DIR=/tmp/.X11-unix/run, XDG_SESSION_TYPE=x11
- audio: pulseaudio, alsa-utils, libasound2(+plugins); PULSE_SOCKET_DIR=/tmp/pulse, PULSE_SERVER=unix:/tmp/pulse/pulse-socket
- desktop: xfce4, xfce4-terminal, gedit, imagemagick, msttcorefonts, fonts-vlgothic
- steam-installer (dpkg --add-architecture i386); symlink /usr/bin/steam -> /usr/games/steam
- flatpak + gnome-software-plugin-flatpak; flathub remote added at build; `dpkg-statoverride ... /usr/bin/bwrap 0755 root root`
- gstreamer 1.0 plugin set; intel-media-va-driver-non-free, i965-va-driver-shaders, libva2, va-driver-all; vainfo, htop, cpu-x

## Fetched-at-build pieces
- Node: latest v20.x linux-x64 from nodejs.org (NODE_VERSION default "v20", scraped listing)
- Web frontend: `git clone https://github.com/Steam-Headless/frontend.git --branch v2-update`, checkout `FRONTEND_VERSION=c1d9f6e`, submodules; index.html redirects to ./web/
- Websockify `WEBSOCKETIFY_VERSION=0.11.0` tarball from github novnc/websockify -> /opt/frontend/utils/websockify
- dumb-init `DUMB_INIT_VERSION=1.2.5` (x86_64 binary) -> /usr/bin/dumb-init
- dumb-udev `DUMB_UDEV_VERSION=64d1427` via `pip --break-system-packages git+https://github.com/Steam-Headless/dumb-udev.git@...`
- Sunshine pinned `SUNSHINE_RELEASE=v2026.516.143833`; asset chosen via GitHub API (debian trixie amd64 .deb); installed with apt
- Neko: `COPY --from=m1k1o/neko:base /usr/bin/neko` and `/var/www`
- `COPY overlay /` (incl. /entrypoint.sh, chmod +x)

## Container ENV (run-time)
| ENV | Default |
| --- | --- |
| DISPLAY | :55 |
| DISPLAY_SIZEW / SIZEH / REFRESH / CDEPTH | 1600 / 900 / 120 / 24 |
| DISPLAY_VIDEO_PORT | DFP |
| MODE | primary |
| WEB_UI_MODE | vnc |
| ENABLE_VNC_AUDIO | true |
| NEKO_PASSWORD | neko |
| NEKO_PASSWORD_ADMIN | admin |
| ENABLE_STEAM | true |
| STEAM_ARGS | -silent |
| WEBUI_USER / WEBUI_PASS | "" |
| ENABLE_SUNSHINE | true |
| ENABLE_EVDEV_INPUTS | true |
| ENABLE_WOL_POWER_MANAGER | false |
| ENABLE_SID | false |
| PORT_NOVNC_WEB | 8083 |
| NEKO_NAT1TO1 | "" |
| NVIDIA_DRIVER_CAPABILITIES / NVIDIA_VISIBLE_DEVICES | all / all |
| PULSE_*, XDG_DATA_DIRS | see above |

## Entry / ports
- `EXPOSE 8083`; `ENTRYPOINT ["/entrypoint.sh"]`. No USER line (root at start, entrypoint drops/uses supervisord as root).

## Gotchas
- Default passwords baked in (USER_PASSWORD=password, NEKO_PASSWORD=neko, NEKO_PASSWORD_ADMIN=admin).
- Sudo NOPASSWD for default user.
- Requires X server in container (Xorg + dummy video), /dev access for GPUs/input (see compose docs).
- Network fetches at build: nodejs.org, github (frontend, websockify, dumb-udev, Sunshine), flathub.
