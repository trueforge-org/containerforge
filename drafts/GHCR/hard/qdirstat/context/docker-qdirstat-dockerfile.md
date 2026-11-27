# jlesage/docker-qdirstat Dockerfile

**Source URL(s):** https://raw.githubusercontent.com/jlesage/docker-qdirstat/v26.09.1/Dockerfile (blob URL duplicate) · fetched 2026-11-27

## Build
- ARG `DOCKER_IMAGE_VERSION` (empty), `QDIRSTAT_VERSION=2.0`.
- `QDIRSTAT_URL=https://github.com/shundhammer/qdirstat/archive/${QDIRSTAT_VERSION}.tar.gz`.
- Stage `xx`: `tonistiigi/xx`. Stage `qdirstat`: `FROM --platform=$BUILDPLATFORM alpine:3.20`; `/build/build.sh "$QDIRSTAT_URL"`; `xx-verify /tmp/qdirstat-install/usr/bin/qdirstat`.
- Final: `FROM jlesage/baseimage-gui:alpine-3.20-v4.14.0`.
- `add-pkg qt6-qtbase-x11 qt6-qt5compat adwaita-qt mesa-gl font-croscore file git make xterm`.
- `install_app_icon.sh` from jlesage/docker-templates qdirstat-icon.png.
- COPY `rootfs/` to /, COPY qdirstat binary to /usr/bin/.

## Runtime
- set-cont-env APP_NAME "QDirStat", APP_VERSION, DOCKER_IMAGE_VERSION.
- ENV `QDIRSTAT_STARTUP_SCAN_FOLDER=` (empty).
- `VOLUME ["/storage"]`. WORKDIR /tmp. No EXPOSE, no USER, no ENTRYPOINT here.

## Gotchas
- Upstream source version 2.0 (QDIRSTAT_VERSION) vs image tag v26.09.1.
- Runtime scripts in `rootfs/` not fetched.
