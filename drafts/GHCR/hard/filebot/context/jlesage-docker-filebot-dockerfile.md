# jlesage/docker-filebot Dockerfile (v26.09.2)

Source URL: https://raw.githubusercontent.com/jlesage/docker-filebot/v26.09.2/Dockerfile (fetched 2026-11-27; tag v26.09.2 is the wrapper's CalVer)

## Build args
- DOCKER_IMAGE_VERSION (empty)
- FILEBOT_VERSION=5.3.0, MEDIAINFOLIB_VERSION=26.05, ZENLIB_VERSION=0.4.41, UNRAR_VERSION=6.1.7
- FILEBOT_URL=`https://get.filebot.net/filebot/FileBot_${FILEBOT_VERSION}/FileBot_${FILEBOT_VERSION}-portable.tar.xz`
- MEDIAINFOLIB_URL=`https://github.com/MediaArea/MediaInfoLib/archive/refs/tags/v${MEDIAINFOLIB_VERSION}.tar.gz`
- ZENLIB_URL=`https://github.com/MediaArea/ZenLib/archive/refs/tags/v${ZENLIB_VERSION}.tar.gz`
- UNRAR_URL=`https://www.rarlab.com/rar/unrarsrc-${UNRAR_VERSION}.tar.gz`

## Stages
1. `tonistiigi/xx` (cross helpers)
2. `alpine:3.20` filebot: `curl -L -f $FILEBOT_URL | tar xJ` into /tmp/filebot; copy `jar` to /opt/filebot/jar (no checksum check)
3. `alpine:3.20` unrar: builds from src/unrar/build.sh with UNRAR_URL; xx-verify
4. `alpine:3.20` libmediainfo: builds MediaInfoLib + ZenLib via src/libmediainfo/build.sh; xx-verify libmediainfo.so, libzen.so
5. Final `FROM jlesage/baseimage-gui:alpine-3.20-v4.14.0`

## Final stage
- add-pkg: bash, p7zip, findutils, coreutils, curl, ttf-dejavu, adwaita-icon-theme, openjdk17-jre, chromaprint (fpcalc), tinyxml2, zenity
- add-pkg from edge: java-jna-native
- Icon cleanup in /usr/share/icons/Adwaita (removes most svg/png)
- install_app_icon.sh from jlesage docker-templates icon URL
- COPY rootfs/ /; copy /opt/filebot, libmediainfo libs into /usr/lib, unrar to /usr/bin/unrar
- set-cont-env: APP_NAME "FileBot", APP_VERSION (FILEBOT_VERSION), DOCKER_IMAGE_VERSION, DISABLE_GLX 1

## ENV (public)
| Name | Default |
| --- | --- |
| FILEBOT_GUI | 1 |
| AMC_ENABLED | 1 |
| USE_FILEBOT_BETA | 0 |
| FILEBOT_CUSTOM_OPTIONS | (empty) |
| OPENSUBTITLES_USERNAME | (empty) |
| OPENSUBTITLES_PASSWORD | (empty) |
| AMC_INTERVAL | 1800 |
| AMC_INPUT_STABLE_TIME | 10 |
| AMC_ACTION | test |
| AMC_CONFLICT | auto |
| AMC_MATCH_MODE | opportunistic |
| AMC_ARTWORK | n |
| AMC_LANG | English |
| AMC_MUSIC_FORMAT / AMC_MOVIE_FORMAT / AMC_SERIES_FORMAT / AMC_ANIME_FORMAT | {plex} |
| AMC_PROCESS_MUSIC | y |
| AMC_SUBTITLE_LANG | (empty) |
| AMC_CUSTOM_OPTIONS | (empty) |
| AMC_INPUT_DIR | /watch |
| AMC_OUTPUT_DIR | /output |

## Volumes
- VOLUME `/storage`, `/output`, `/watch`

## Ports / user / healthcheck
- None declared in this Dockerfile (GUI base provides noVNC/VNC ports; base not fetched). No USER directive. No HEALTHCHECK.

## Gotchas
- Downloads FileBot and verifies nothing (pipes curl to tar). Plan uses the .sha256 files from the listing.
- FileBot 5.3.0 is the application version; v26.09.2 is the wrapper CalVer.
- Java 17 (openjdk17-jre) plus chromaprint, MediaInfoLib, UnRAR are installed.
