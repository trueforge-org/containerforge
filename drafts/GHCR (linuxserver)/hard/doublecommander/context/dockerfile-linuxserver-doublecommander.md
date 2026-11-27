# linuxserver/docker-doublecommander Dockerfile
Source URL: https://raw.githubusercontent.com/linuxserver/docker-doublecommander/05e15297277457b38b1c99c2207185cf73873f15/Dockerfile (fetched 2026-11-27)

## Build (single stage)
- `FROM ghcr.io/linuxserver/baseimage-selkies:debiantrixie`
- ARG BUILD_DATE, VERSION, DOUBLECOMMANDER_VERSION; LABEL maintainer thelamer
- ENV `TITLE=DoubleCommander`, `NO_GAMEPAD=true`, `PIXELFLUX_WAYLAND=true`
- ARG DEBIAN_FRONTEND=noninteractive
- RUN: curl icon to `/usr/share/selkies/www/icon.png`
- RUN apt install: arj, doublecmd-gtk, doublecmd-plugins, libsmbclient, libssh2-1, libunrar5, p7zip-full, unace, xz-utils, zpaq
- RUN cleanup: apt-get clean; rm /tmp/*, apt lists, /var/tmp/*
- COPY /root /
- EXPOSE 3001
- VOLUME /config
- No ENTRYPOINT, CMD or HEALTHCHECK (from base)

## Gotchas
- Uses Debian package `doublecmd-gtk` (not the upstream release tarballs); DOUBLECOMMANDER_VERSION ARG is declared but not used in the RUN steps shown.
