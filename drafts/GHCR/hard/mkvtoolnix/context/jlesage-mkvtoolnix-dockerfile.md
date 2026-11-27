# Source: jlesage/docker-mkvtoolnix Dockerfile (tag v26.10.1)

Source URL(s) + date: https://raw.githubusercontent.com/jlesage/docker-mkvtoolnix/v26.10.1/Dockerfile (fetched 2026-11-27; blob variant same content)

## Build args / versions
| ARG | Default |
| --- | --- |
| DOCKER_IMAGE_VERSION | (empty, build arg) |
| MKVTOOLNIX_VERSION | 103.0 |
| MEDIAINFO_VERSION | 26.10 |
| MEDIAINFOLIB_VERSION | 26.10 |
| ZENLIB_VERSION | 0.4.41 |

## Download URLs (ARG)
- MKVTOOLNIX_URL: https://mkvtoolnix.download/sources/mkvtoolnix-${MKVTOOLNIX_VERSION}.tar.xz
- MEDIAINFO_URL: https://github.com/MediaArea/MediaInfo/archive/refs/tags/v${MEDIAINFO_VERSION}.tar.gz
- MEDIAINFOLIB_URL: https://github.com/MediaArea/MediaInfoLib/archive/refs/tags/v${MEDIAINFOLIB_VERSION}.tar.gz
- ZENLIB_URL: https://github.com/MediaArea/ZenLib/archive/refs/tags/v${ZENLIB_VERSION}.tar.gz
- APP_ICON_URL: https://github.com/jlesage/docker-templates/raw/master/jlesage/images/mkvtoolnix-icon.png

## Stages
1. `tonistiigi/xx` (cross helpers).
2. `alpine:3.20` AS mkvtoolnix: `/build/build.sh "$MKVTOOLNIX_URL"`; xx-verify of mkvmerge, mkvinfo, mkvextract, mkvpropedit, mkvtoolnix-gui.
3. `alpine:3.20` AS mediainfo: `/build/build.sh` with MediaInfo, MediaInfoLib, ZenLib URLs; xx-verify mediainfo-gui, libmediainfo.so, libzen.so.
4. Final: `jlesage/baseimage-gui:alpine-3.20-v4.14.0`.
   - WORKDIR /tmp
   - `add-pkg` boost1.84-filesystem, font-croscore, flac, libdvdread, tinyxml2, qt6-qtbase-x11, libcmark, fmt, libvorbis, qt6-qtsvg, adwaita-qt6, mesa-gl; removes /usr/lib/qt6/plugins/platforms/libqwayland-*.
   - `echo > /etc/fstab`
   - install_app_icon.sh
   - COPY rootfs/ /; mkvtoolnix bins -> /usr/bin; icons, locale, qt_resources.rcc; mediainfo bins -> /usr/bin; libs -> /usr/lib/.
   - set-cont-env APP_NAME "MKVToolNix", APP_VERSION, DOCKER_IMAGE_VERSION.
   - `VOLUME ["/storage"]`
   - LABEL org.label-schema.* (name, description, version, vcs-url, schema-version).

## Runtime deps
- Qt6 (qtbase-x11, qtsvg, adwaita-qt6), boost1.84-filesystem, tinyxml2, libcmark, fmt, libvorbis, flac, libdvdread, font-croscore, mesa-gl.

## Entrypoint/flags
- None set in this Dockerfile (inherits baseimage-gui).

## Volumes/paths
- /storage (VOLUME). Config path from baseimage (/config per README).

## Gotchas
- Wrapper builds MKVToolNix 103.0 from source tarball; official latest is 104.0 (see mkvtoolnix-downloads.md).
- Base is Alpine 3.20 (musl), not Ubuntu.
- Comments in add-pkg list mention arm64 mesa-gl dependency.
