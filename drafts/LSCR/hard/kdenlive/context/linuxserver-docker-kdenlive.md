# linuxserver/docker-kdenlive @ f39884e7d1d55d31dd0babb973c1cb0ea066d84f

Source URL(s): https://raw.githubusercontent.com/linuxserver/docker-kdenlive/f39884e7d1d55d31dd0babb973c1cb0ea066d84f/Dockerfile ; .../root/defaults/autostart (fetched 2026-11-27)

## What it is
- Kdenlive video editor in a browser-streamed desktop (Selkies), linuxserver.io image.

## Build
- `FROM ghcr.io/linuxserver/baseimage-selkies:arch` (Arch Linux base, not Ubuntu).
- ARG BUILD_DATE, VERSION, KDENLIVE_VERSION (optional).
- ENV TITLE=Kdenlive, NO_GAMEPAD=true, PIXELFLUX_WAYLAND=true.
- Icon downloaded to /usr/share/selkies/www/icon.png (linuxserver docker-templates).
- `pacman -Sy --noconfirm --needed kdenlive${KDENLIVE_VERSION:+=$KDENLIVE_VERSION}`.
- Cleanup: /tmp/*, /var/cache/pacman/pkg/*, /var/lib/pacman/sync/*.
- COPY /root / (s6 files).

## Entrypoint / autostart
- Selkies base s6 init (not fetched). `root/defaults/autostart`: `dbus-launch kdenlive`.

## Ports
- EXPOSE 3001 (Selkies web UI). Chart uses 3000.

## Volumes
- VOLUME /config.

## User/UID
- Selkies base model (not verified here).

## Arch
- Arch Linux base image (pacman). Package is whatever Arch ships unless KDENLIVE_VERSION is set (pacman `=version` pin).

## Gotchas
- Install is unpinned by default (pacman -Sy at build time).
- Built on Selkies/Arch, so the Ubuntu-based plan needs its own display and streaming layer.
