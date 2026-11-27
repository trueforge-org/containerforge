# linuxserver/docker-filezilla Dockerfile
Source URL: https://raw.githubusercontent.com/linuxserver/docker-filezilla/ad89ad1bdd0f2bad2d7dd8a68a3f989c3449949f/Dockerfile (fetched 2026-11-27)

## Build (single stage)
- `# syntax=docker/dockerfile:1`
- `FROM ghcr.io/linuxserver/baseimage-selkies:ubunturesolute`
- ARG BUILD_DATE, VERSION, FILEZILLA_VERSION; LABEL maintainer thelamer
- ENV `TITLE=Filezilla`, `NO_GAMEPAD=true`, `PIXELFLUX_WAYLAND=true`
- RUN: curl icon to `/usr/share/selkies/www/icon.png`
- RUN: `apt-get install -y --no-install-recommends filezilla${FILEZILLA_VERSION:+=$FILEZILLA_VERSION}` (pin optional via build arg)
- RUN cleanup: apt-get autoclean; rm `/config/.cache`, `/config/.launchpadlib`, apt lists, /var/tmp, /tmp
- COPY /root /
- EXPOSE 3001
- VOLUME /config
- No ENTRYPOINT, CMD or HEALTHCHECK (from base)

## Gotchas
- Package from Ubuntu archive (resolute); version pinned only if FILEZILLA_VERSION is passed.
