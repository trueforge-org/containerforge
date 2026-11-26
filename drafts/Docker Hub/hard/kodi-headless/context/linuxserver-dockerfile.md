# linuxserver/docker-kodi-headless Dockerfile (commit 8962e35)

Source URL(s): https://raw.githubusercontent.com/linuxserver/docker-kodi-headless/8962e35/Dockerfile (blob: https://github.com/linuxserver/docker-kodi-headless/blob/8962e35/Dockerfile); repo tree: https://github.com/linuxserver/docker-kodi-headless/tree/8962e35. Fetched 2026-11-26.

## Repo layout (tree)
- Root: `.github/`, `patches/Leia/`, `root/`, `Dockerfile`, `Dockerfile.aarch64`, `Dockerfile.armhf`, `LICENSE`, `README.md`, `.dockerignore`, `.gitattributes`, `.gitignore`
- root/ and patches/Leia contents not shown in tree listing.

## Stages / base
- Two-stage: `buildstage` -> runtime
- Both: `lsiobase/ubuntu:bionic` (no digest)

## ARG / ENV / LABEL
- Build ARG: `KODI_NAME=Leia`, `KODI_VER=18.5`, `KODI_ADDONS=vfs.libarchive and vfs.rar`, `DEBIAN_FRONTEND=noninteractive`
- Runtime ARG: BUILD_DATE, VERSION, DEBIAN_FRONTEND; ENV `HOME=/config`
- LABEL build_version, maintainer sparklyballs

## Build stage
- apt (--no-install-recommends): autoconf automake autopoint binutils cmake curl default-jre g++ gawk gcc git gperf libass-dev libavahi-client/common-dev libbluray-dev libbz2-dev libcurl4-openssl-dev libegl1-mesa-dev libflac-dev libfmt-dev libfreetype6-dev libfstrcmp-dev libgif-dev libglew-dev libiso9660-dev libjpeg-dev liblcms2-dev liblzo2-dev libmicrohttpd-dev libmysqlclient-dev libnfs-dev libpcre3-dev libplist-dev libsmbclient-dev libsqlite3-dev libssl-dev libtag1-dev libtiff5-dev libtinyxml-dev libtool libvorbis-dev libxrandr-dev libxslt-dev make nasm python-dev rapidjson-dev swig uuid-dev yasm zip zlib1g-dev
- Source: `https://github.com/xbmc/xbmc/archive/${KODI_VER}-${KODI_NAME}.tar.gz` -> /tmp/kodi.tar.gz -> /tmp/kodi-source (strip 1)
- `COPY patches/ /patches/`; `git apply /patches/${KODI_NAME}/headless.patch`
- cmake in /tmp/kodi-source/build; `INSTALL_LIBDIR=/usr/lib INSTALL_PREFIX=/usr`
  - OFF: AIRTUNES ALSA AVAHI BLUETOOTH CAP CEC DBUS DVDCSS GLX LIBUSB OPENGL OPTICAL PULSEAUDIO SNDIO UDEV VAAPI VDPAU
  - ON: BLURAY INTERNAL_FLATBUFFERS NFS UPNP
- `make -j3`; `make DESTDIR=/tmp/kodi-build install`
- Addons: `make -j3 -C tools/depends/target/binary-addons ADDONS="$KODI_ADDONS" PREFIX=/tmp/kodi-build/usr`
- kodi-send.py -> `/tmp/kodi-build/usr/bin/kodi-send` (755); xbmcclient.py -> `/tmp/kodi-build/usr/lib/python2.7/` (644)

## Runtime stage
- apt (--no-install-recommends): libass9 libbluray2 libegl1 libfstrcmp0 libgl1 liblcms2-2 liblzo2-2 libmicrohttpd12 libmysqlclient20 libnfs11 libpcrecpp0v5 libpython2.7 libsmbclient libtag1v5 libtinyxml2.6.2v5 libxrandr2 libxslt1.1
- `COPY root/ /`; `COPY --from=buildstage /tmp/kodi-build/usr/ /usr/`
- Cleanup: /tmp/*, /var/lib/apt/lists/*, /var/tmp/*
- No pip packages

## Entrypoint / ports / volumes
- VOLUME `/config/.kodi`
- EXPOSE 8080, 9090, 9777/udp
- ENTRYPOINT/CMD: none (inherited from base, s6). HEALTHCHECK none.
- User setup: none in Dockerfile; PUID/PGID handling must come from base or root/ (root/ not fetched).

## Gotchas
- Python 2.7 runtime (libpython2.7; xbmcclient.py under python2.7).
- Kodi 18.5 Leia; RAR support via addons compiled in but must be enabled in UI.
