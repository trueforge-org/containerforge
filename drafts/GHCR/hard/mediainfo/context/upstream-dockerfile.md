# jlesage/docker-mediainfo Dockerfile (upstream)

Source URL(s) + date: https://raw.githubusercontent.com/jlesage/docker-mediainfo/v26.10.1/Dockerfile · fetched 2026-11-27

## Versions (ARG)
- MEDIAINFO_VERSION=26.10, MEDIAINFOLIB_VERSION=26.10, ZENLIB_VERSION=0.4.41
- Sources: github.com/MediaArea/{MediaInfo,MediaInfoLib,ZenLib} release tarballs (v<ver>)

## Build
- Stage xx: tonistiigi/xx (cross-compile helpers)
- Stage mediainfo: `alpine:3.20`, build.sh from src/mediainfo
- xx-verify: /tmp/mediainfo-install/usr/bin/{mediainfo,mediainfo-gui}, usr/lib/{libmediainfo.so,libzen.so}

## Final stage
- Base: `jlesage/baseimage-gui:alpine-3.20-v4.14.0`
- Packages (add-pkg): tinyxml2, qt6-qtbase-x11, qt6-qtsvg, adwaita-qt, mesa-gl, font-roboto-mono
- Icon: jlesage/docker-templates mediainfo-icon.png
- COPY rootfs/ /, copies mediainfo usr/bin and usr/lib
- set-cont-env APP_NAME "MediaInfo", APP_VERSION from MEDIAINFO_VERSION

## Volumes / env
- VOLUME ["/storage"]
- No ENV block and no EXPOSE in fetched content

## Gotchas
- Base is Alpine 3.20 here.
- mesa-gl is added explicitly because it is not pulled on some arches (arm64).
- Chart appVersion 26.11.2 vs upstream MEDIAINFO_VERSION 26.10 (different scheme: chart tag tracks container release).
- GitHub releases/latest API call not made after the first rate-limit observed on sibling repos (not retried).
