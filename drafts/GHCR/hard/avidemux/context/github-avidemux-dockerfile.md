# jlesage/docker-avidemux Dockerfile (tag v26.09.1)

Source URL(s) + date: https://raw.githubusercontent.com/jlesage/docker-avidemux/v26.09.1/Dockerfile (fetched 2026-11-27)

## Build args
| Arg | Value |
| --- | --- |
| DOCKER_IMAGE_VERSION | empty default |
| AVIDEMUX_VERSION | 2.8.1 |
| OPENCORE_AMR_VERSION | 0.1.5 |
| TWOLAME_VERSION | 0.4.0 |
| AFTEN_VERSION | 0.0.8 |
| LIBDCA_VERSION | 0.0.7 |
| DCAENC_VERSION | 3 |
- Source URLs: AVIDEMUX_URL = sourceforge `avidemux/${AVIDEMUX_VERSION}/avidemux_${AVIDEMUX_VERSION}.tar.gz`; others from sourceforge, videolan, gitlab (patrakov/dcaenc).

## Stages
- `xx` = tonistiigi/xx (cross-compile helpers).
- `avidemux` = `alpine:3.20` build stage: `COPY src/avidemux /build`, `RUN /build/build.sh <URLs...>`; then `xx-verify` of `/tmp/avidemux-install/usr/bin/avidemux3_qt5`, `avidemux3_jobs_qt5`, `avidemux3_cli`.
- Final: `FROM jlesage/baseimage-gui:alpine-3.20-v4.14.0`.
- Copies from build: /usr/bin (avidemux binaries), /usr/lib (avidemux libs), /usr/share/avidemux6.

## Runtime deps (apk, `add-pkg`)
sqlite-libs, qt5-qtbase-x11, glu, libva, libvdpau, libxv, libvorbis, lame, faac, alsa-lib, faad2-libs, opus, x264-libs, x265, xvidcore, fribidi, fdk-aac, libvpx, font-croscore, libpulse.

## Runtime
- Icon: `install_app_icon.sh` from jlesage docker-templates URL.
- `set-cont-env APP_NAME "Avidemux"`, `APP_VERSION $AVIDEMUX_VERSION`, `DOCKER_IMAGE_VERSION`.
- `VOLUME ["/storage"]`.
- No EXPOSE, no ENTRYPOINT/CMD in this file (inherited from baseimage-gui).
- LABEL: org.label-schema.* (name avidemux, vcs-url github jlesage/docker-avidemux).
- `COPY rootfs/ /` (service scripts from repo rootfs, not fetched).

## Gotchas
- Final base is Alpine (musl). Upstream image is not usable on glibc Ubuntu (plan confirms), so the build has to compile Avidemux itself.
- Upstream runs as root under the GUI base (per plan).
