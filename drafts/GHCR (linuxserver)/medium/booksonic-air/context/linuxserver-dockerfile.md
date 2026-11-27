# linuxserver/docker-booksonic-air Dockerfile
Source: https://raw.githubusercontent.com/linuxserver/docker-booksonic-air/a70824fbf40f6dc16ab7a8e957dda58267c05ed3/Dockerfile (fetched 2026-11-27)

## Build
- `# syntax=docker/dockerfile:1`, single stage FROM ghcr.io/linuxserver/baseimage-alpine:3.20
- ARG BUILD_DATE, VERSION, BOOKSONIC_AIR_RELEASE
- ENV BOOKSONIC_AIR_HOME=/app/booksonic-air, BOOKSONIC_AIR_SETTINGS=/config, LANG=C.UTF-8
- LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}", maintainer="chbmb"

## Install (single RUN, && chained)
1. apk add -U --no-cache ffmpeg flac fontconfig lame openjdk11-jre ttf-dejavu (no version pins)
2. Remove accessibility.properties under /etc and /usr (status page fix)
3. If BOOKSONIC_AIR_RELEASE unset: tag_name from https://api.github.com/repos/popeen/Booksonic-Air/releases/latest (awk)
4. mkdir -p $BOOKSONIC_AIR_HOME; curl -L -o $BOOKSONIC_AIR_HOME/booksonic.war https://github.com/popeen/Booksonic-Air/releases/download/${BOOKSONIC_AIR_RELEASE}/booksonic.war
5. printf build version file to /build_version
6. rm -rf /tmp/* $HOME/.cache

## Other
- COPY root/ /
- EXPOSE 4040
- VOLUME /config
- USER: none set
- ENTRYPOINT/CMD: none (inherits base init; root/ supplies service scripts)
- HEALTHCHECK: none

## Gotchas
- Runtime is Java 11 JRE (openjdk11-jre) on Alpine 3.20; WAR is the single artifact `booksonic.war`.
- Asset name booksonic.war is fixed per release tag.
