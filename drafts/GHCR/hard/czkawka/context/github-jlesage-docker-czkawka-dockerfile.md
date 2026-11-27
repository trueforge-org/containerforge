# Upstream Dockerfile: jlesage/docker-czkawka @ v26.09.2

Source URL(s) + date: https://raw.githubusercontent.com/jlesage/docker-czkawka/v26.09.2/Dockerfile (blob variant https://github.com/jlesage/docker-czkawka/blob/v26.09.2/Dockerfile is the same file), fetched 2026-11-27.

## Versions (ARG defaults)
- CZKAWKA_VERSION=12.0.2
- LIBHEIF_VERSION=1.23.4
- CZKAWKA_URL=https://github.com/qarmin/czkawka/archive/${CZKAWKA_VERSION}.tar.gz
- LIBHEIF_URL=https://github.com/strukturag/libheif/releases/download/v${LIBHEIF_VERSION}/libheif-${LIBHEIF_VERSION}.tar.gz
- DOCKER_IMAGE_VERSION: build arg (empty default).

## Build stages
1. `FROM --platform=$BUILDPLATFORM tonistiigi/xx AS xx` (cross-compile helpers).
2. `FROM --platform=$BUILDPLATFORM alpine:3.20 AS czkawka`: copies `src/czkawka` to /build, runs `/build/build.sh "$CZKAWKA_URL" "$LIBHEIF_URL"`, then `xx-verify` on `/tmp/czkawka-install/czkawka_cli` and `czkawka_gui`.
3. Final: `FROM jlesage/baseimage-gui:alpine-3.20-v4.14.0`.

## Install steps (final stage)
- `add-pkg gtk4.0 alsa-lib ffmpeg ffplay pcmanfm adwaita-icon-theme font-dejavu`.
- `add-pkg mate-icon-theme` then copy tab-new.png (16,22,24) into hicolor, `del-pkg mate-icon-theme`, `gtk-update-icon-cache /usr/share/icons/hicolor`.
- `install_app_icon.sh` with icon URL from jlesage/docker-templates (templated, not fetched).
- `COPY rootfs/ /`.
- COPY from build stage: /tmp/czkawka-install/czkawka_cli, czkawka_gui -> /usr/bin/; /tmp/libheif-install/usr/lib -> /usr/lib; heif-convert, heif-dec -> /usr/bin/.
- `set-cont-env APP_NAME "Czkawka"`, `APP_VERSION "$CZKAWKA_VERSION"`, `DOCKER_IMAGE_VERSION`, `DISABLE_GLX 1`.

## Runtime deps
- gtk4.0, alsa-lib, ffmpeg, ffplay, pcmanfm, adwaita-icon-theme, font-dejavu, mate-icon-theme (temp), libheif 1.23.4 (copied libs).

## Entrypoint/flags
- Inherited from jlesage/baseimage-gui (not in this Dockerfile). Dockerfile sets no ENTRYPOINT/CMD.

## Volumes/paths
- `VOLUME ["/storage"]`. WORKDIR /tmp.

## Ports
- No EXPOSE. GUI web 5800 and VNC 5900 are documented in the upstream README, not in this Dockerfile.

## Gotchas
- Labels use `org.label-schema.*`; version label from DOCKER_IMAGE_VERSION.
- Build stage uses alpine:3.20 and jlesage base alpine-3.20; Dockerfile itself is not a Debian/Ubuntu build.
- This Dockerfile builds czkawka 12.0.2 and includes GTK GUI (`czkawka_gui`).
