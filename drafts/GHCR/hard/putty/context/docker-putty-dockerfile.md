# jlesage/docker-putty Dockerfile

**Source URL(s):** https://raw.githubusercontent.com/jlesage/docker-putty/v26.09.1/Dockerfile (blob URL duplicate) · fetched 2026-11-27

## Build
- ARG `DOCKER_IMAGE_VERSION` (empty default, from build arg), `PUTTY_VERSION=0.85`, `PUTTY_URL=https://the.earth.li/~sgtatham/putty/${PUTTY_VERSION}/putty-${PUTTY_VERSION}.tar.gz`.
- Stage `xx`: `tonistiigi/xx` (cross-compile helpers).
- Stage `putty`: `FROM --platform=$BUILDPLATFORM alpine:3.20`; copies `src/putty` to /build, runs `/build/build.sh "$PUTTY_URL"`; `xx-verify` on putty, plink, pscp, psftp, psusan, puttygen, pageant, pterm under /tmp/putty-install/usr/bin.
- Final: `FROM jlesage/baseimage-gui:alpine-3.20-v4.14.0`.
- `add-pkg gtk+3.0 adwaita-icon-theme ttf-dejavu`.
- `install_app_icon.sh` from jlesage/docker-templates putty-icon.png.
- COPY `rootfs/` to /, COPY binaries from putty stage to /usr/bin.

## Runtime
- set-cont-env APP_NAME "PuTTY", APP_VERSION, DOCKER_IMAGE_VERSION.
- WORKDIR /tmp. No ENTRYPOINT/CMD in this file (inherited from baseimage-gui).

## Labels
- org.label-schema.name=putty, vcs-url https://github.com/jlesage/docker-putty, version from DOCKER_IMAGE_VERSION.

## Gotchas
- Upstream PuTTY is 0.85 (PUTTY_VERSION), image tag is v26.09.1. The chart appVersion is 26.11.2.
- Runtime scripts live in `rootfs/` (not fetched).
