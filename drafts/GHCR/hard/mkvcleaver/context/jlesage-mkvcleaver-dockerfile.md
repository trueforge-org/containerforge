# Source: jlesage/docker-mkvcleaver Dockerfile (tag v26.09.1)

Source URL(s) + date: https://raw.githubusercontent.com/jlesage/docker-mkvcleaver/v26.09.1/Dockerfile (fetched 2026-11-27; blob variant = same content)

## What it is
Multi-stage Dockerfile building MKVCleaver (Windows app) under Wine on a jlesage GUI base.

## Build args / versions
| ARG | Default |
| --- | --- |
| DOCKER_IMAGE_VERSION | (empty, passed via build arg) |
| MKVCLEAVER_VERSION | 0802 |
| MKVTOOLNIX_VERSION | 33.1.0 |
| MEDIAINFO_VERSION | 26.01 |
| WINETRICKS_VERSION | 20260125 |

## Download URLs (ARG)
- MKVCLEAVER_URL: https://blogs.sapib.ca/apps/download/d47a70b2339c4809edd842ebc45d2efc/MKVCleaver_x64_v${MKVCLEAVER_VERSION}.exe
- MKVCLEAVER_SOURCE_URL: https://blogs.sapib.ca/apps/download/source/MKVcleaver-x64-v${MKVCLEAVER_VERSION}-Portable-Source.zip
- AUTOIT_URL: https://www.autoitscript.com/files/autoit3/autoit-v3.zip
- MKVTOOLNIX_URL: https://mkvtoolnix.download/windows/releases/${MKVTOOLNIX_VERSION}/mkvtoolnix-64-bit-${MKVTOOLNIX_VERSION}.7z
- MEDIAINFO_URL: https://mediaarea.net/download/binary/libmediainfo0/${MEDIAINFO_VERSION}/MediaInfo_DLL_${MEDIAINFO_VERSION}_Windows_x64_WithoutInstaller.7z
- WINETRICKS_URL: https://github.com/Winetricks/winetricks/archive/refs/tags/${WINETRICKS_VERSION}.tar.gz

## Stages
1. `alpine:3.18` AS winetricks: apk add curl make; fetch winetricks tarball; `make install` to /tmp/winetricks-install.
2. `alpine:3.18` AS mkvcleaver: COPY src/mkvcleaver -> /build; runs `/build/build.sh` with the URLs above. Outputs /opt/mkvcleaver, /opt/autoit, /opt/mkvtoolnix, /defaults.
3. Final: `jlesage/baseimage-gui:alpine-3.18-v4.14.0`.
   - WORKDIR /tmp
   - `add-pkg wine`
   - icon: install_app_icon.sh from https://raw.githubusercontent.com/jlesage/docker-templates/master/jlesage/images/mkvcleaver-icon.png
   - COPY rootfs/ /, plus /opt/mkvcleaver, /opt/autoit, /opt/mkvtoolnix, /defaults from build stage.
   - set-cont-env APP_NAME "MKVCleaver", APP_VERSION "$MKVCLEAVER_VERSION", DOCKER_IMAGE_VERSION.
   - `VOLUME ["/storage"]`
   - LABELs: org.label-schema.name/description/version/vcs-url/schema-version.

## Runtime deps
- wine (add-pkg), plus MKVToolNix and MediaInfo (bundled in build stage), AutoIt.

## Entrypoint/flags
- Inherited from jlesage baseimage-gui (no ENTRYPOINT/CMD in this Dockerfile).

## Volumes/paths
- /storage (VOLUME). /config comes from baseimage (see README, jlesage-mkvcleaver-readme.md).

## Gotchas
- Downloads Windows binaries from blogs.sapib.ca (author site) at build time; not reachable in this context (see README failures).
- Versions in Dockerfile (MKVCLEAVER 0802) differ from chart appVersion (26.11.2) and repo tag (v26.09.1): these are different versioning schemes, do not conflate.
