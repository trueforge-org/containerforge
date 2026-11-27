# linuxserver/docker-digikam Dockerfile
Source URL: https://raw.githubusercontent.com/linuxserver/docker-digikam/fd0663bebb867b7dba24c63d14e0493e7d94c0b9/Dockerfile (fetched 2026-11-27)

## Build (single stage)
- `# syntax=docker/dockerfile:1`
- `FROM ghcr.io/linuxserver/baseimage-selkies:debiantrixie`
- ARG BUILD_DATE, VERSION, DIGIKAM_VERSION; LABEL maintainer hackerman
- ENV `TITLE=DigiKam`, `NO_GAMEPAD=true`, `PIXELFLUX_WAYLAND=true`
- RUN: curl icon to `/usr/share/selkies/www/icon.png`
- RUN apt install (no-install-recommends): breeze-icon-theme, caja, chromium, mariadb-server, openexr, libimage-exiftool-perl
- RUN: if DIGIKAM_VERSION unset, scrape latest `x.y.z` dir from https://mirrors.mit.edu/kde/stable/digikam/
- RUN: curl `https://mirrors.mit.edu/kde/stable/digikam/${DIGIKAM_VERSION}/digiKam-${DIGIKAM_VERSION}-Qt6-x86-64.appimage` to /tmp/digi.app; chmod +x; `--appimage-extract`; mv squashfs-root to /opt/digikam
- Tweaks: mv /usr/bin/chromium to chromium-real; write `/usr/sbin/digikam` wrapper (`cd /opt/digikam && ./AppRun`); `ln -s /usr/bin/chromium /usr/bin/firefox`
- COPY /root /
- EXPOSE 3001
- No VOLUME, ENTRYPOINT, CMD or HEALTHCHECK in this file

## Arch
- AppImage is x86-64 only (`x86-64` in filename); Dockerfile has no arm branch.

## Gotchas
- Version resolved from a mirror at build time if no arg; pin DIGIKAM_VERSION for reproducible builds.
- Bundles mariadb-server (internal MySQL mode).
