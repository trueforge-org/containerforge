# linuxserver/docker-calibre Dockerfile (master; byte-identical at pinned 8aa349b17edf)

Source URL(s) + date: https://raw.githubusercontent.com/linuxserver/docker-calibre/master/Dockerfile (fetched 2026-11-27); https://raw.githubusercontent.com/linuxserver/docker-calibre/8aa349b17edf2d4bed988982d71803684399f01a/Dockerfile (blob URL; identical).

## What it is
Calibre desktop app (GUI) with the official x86_64 .txz binary, on the linuxserver Selkies base (GUI over browser).

## Base
- `FROM ghcr.io/linuxserver/baseimage-selkies:ubunturesolute` (single stage).
- ARG: BUILD_DATE, VERSION, CALIBRE_RELEASE (optional).
- Labels: build_version; maintainer aptalca.

## Env (set in Dockerfile)
| Var | Value |
| --- | --- |
| CUSTOM_PORT | 8080 |
| CUSTOM_HTTPS_PORT | 8181 |
| HOME | /config |
| TITLE | Calibre |
| QTWEBENGINE_DISABLE_SANDBOX | 1 |
| NO_GAMEPAD | true |
| PIXELFLUX_WAYLAND | true |

## Install steps
1. Icon: curl `calibre-icon.png` (docker-templates) -> `/usr/share/selkies/www/icon.png`.
2. apt (no-install-recommends): dbus, fcitx-rime, fonts-wqy-microhei, libnss3, libopengl0, libqpdf30, libxkbcommon-x11-0, libxcb-cursor0, libxcb-icccm4, libxcb-image0, libxcb-keysyms1, libxcb-randr0, libxcb-render-util0, libxcb-xinerama0, poppler-utils, python3, python3-xdg, ttf-wqy-zenhei, wget, xz-utils.
3. apt install speech-dispatcher (no --no-install-recommends).
4. `mkdir /opt/calibre`.
5. CALIBRE_RELEASE if unset: `api.github.com/repos/kovidgoyal/calibre/releases/latest` `.tag_name`. CALIBRE_VERSION = tag without leading `v`.
6. Download `https://github.com/kovidgoyal/calibre/releases/download/v${VER}/calibre-${VER}-x86_64.txz` -> /tmp/calibre-tarball.txz; fallback `https://download.calibre-ebook.com/${VER}/calibre-${VER}-x86_64.txz`.
7. `tar xvf ... -C /opt/calibre`; `/opt/calibre/calibre_postinstall`.
8. `dbus-uuidgen > /etc/machine-id`.
9. Writes `/build_version`; cleanup /tmp/*, apt lists.
10. `COPY root/ /`.

## Entrypoint/flags
- No ENTRYPOINT/CMD; s6 base. Start args come from CLI_ARGS env (README).

## Ports
- None (no EXPOSE). GUI ports from CUSTOM_PORT 8080 and CUSTOM_HTTPS_PORT 8181.

## Volumes/paths
- No VOLUME. HOME=/config. Library default `/config/Calibre Library` (README wizard).

## User/UID
- Not set in Dockerfile (base handles PUID/PGID).

## Arch
- Only x86_64 .txz is fetched here. arm64 tarball exists upstream (calibre-9.19.0-arm64.txz) but is not used by this Dockerfile. Hub still lists arm64 images.

## Gotchas
- QTWEBENGINE_DISABLE_SANDBOX=1 is a security relaxation.
- `dbus-uuidgen` writes `/etc/machine-id` at build time.
