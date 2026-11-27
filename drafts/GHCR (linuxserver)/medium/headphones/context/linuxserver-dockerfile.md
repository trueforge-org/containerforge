# linuxserver/docker-headphones Dockerfile

Source URL (fetched 2026-11-27, pinned commit):
- https://raw.githubusercontent.com/linuxserver/docker-headphones/2eda0d5edcbb/Dockerfile

## Base
- `FROM ghcr.io/linuxserver/baseimage-alpine:3.17` (tag only, no digest).
- `# syntax=docker/dockerfile:1`

## ARG / ENV
- ARG: `BUILD_DATE`, `VERSION`, `HEADPHONES_COMMIT` (optional; if unset it is resolved in RUN).
- ENV: `TZ="Etc/UTC"`.
- LABEL: `build_version`, `maintainer="aptalca"`.

## COPY
- `patches/` -> `/tmp/patches/`
- `root/` -> `/`

## Build steps (single RUN)
1. `apk add --no-cache --virtual=build-dependencies build-base`
2. Runtime packages: `ffmpeg`, `flac`, `mc`, `python3`.
3. shntool build from local `/tmp/patches/shntool-3.0.10.tar.gz` (strip-components=1), `cp /tmp/patches/config.*`, `./configure --infodir=/usr/share/info --localstatedir=/var --mandir=/usr/share/man --prefix=/usr --sysconfdir=/etc`, `make`, `make install`.
4. `mkdir -p /app/headphones`. If `HEADPHONES_COMMIT` unset: `curl https://api.github.com/repos/rembo10/headphones/commits/master` and `jq -r .sha`.
5. `curl -sL https://github.com/rembo10/headphones/archive/${HEADPHONES_COMMIT}.tar.gz` -> `/tmp/headphones.tar.gz`, extract to `/app/headphones` (strip-components=1). Writes commit hash to `/app/headphones/version.txt`.
6. Cleanup: `apk del --purge build-dependencies`, `rm -rf /tmp/* /usr/lib/*.la`.

## Runtime metadata
- `EXPOSE 8181`
- `VOLUME /config`
- No ENTRYPOINT, CMD, HEALTHCHECK, USER (inherited from base).

## Gotchas
- `curl` and `jq` are not installed in this file; assumed from base image.
- Base is Alpine 3.17 (older than fleet's 3.21 baseline).
