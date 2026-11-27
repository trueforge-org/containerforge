# UNVERIFIED (initial draft): source build follows the plan. CMake flags, Qt6 and VNC
# package names on ubuntu 26.04, install paths and licence file names are not checked yet.
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS mediainfo-build

ARG VERSION
ARG MEDIAINFOLIB_VERSION
ARG ZENLIB_VERSION
USER root

RUN \
  echo "*** Installing build dependencies ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    pkg-config \
    zlib1g-dev \
    libtinyxml2-dev \
    qt6-base-dev \
    qt6-svg-dev && \
  rm -rf /var/lib/apt/lists/*

# Upstream publishes no checksums for these tarballs, so the tags are pinned by URL.
RUN \
  echo "*** Downloading sources ***" && \
  mkdir -p /tmp/src && \
  curl -fsSL "https://github.com/MediaArea/ZenLib/archive/refs/tags/v${ZENLIB_VERSION}.tar.gz" | tar -xz -C /tmp/src && \
  curl -fsSL "https://github.com/MediaArea/MediaInfoLib/archive/refs/tags/v${MEDIAINFOLIB_VERSION}.tar.gz" | tar -xz -C /tmp/src && \
  curl -fsSL "https://github.com/MediaArea/MediaInfo/archive/refs/tags/v${VERSION}.tar.gz" | tar -xz -C /tmp/src

# UNVERIFIED: Project/CMake source paths and the CMake options were not read from the tarballs.
RUN \
  echo "*** Building ZenLib ***" && \
  cmake -S /tmp/src/ZenLib-${ZENLIB_VERSION}/Project/CMake -B /tmp/build/zenlib \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/opt/mediainfo \
    -DCMAKE_INSTALL_LIBDIR=lib && \
  cmake --build /tmp/build/zenlib -j"$(nproc)" && \
  cmake --install /tmp/build/zenlib && \
  echo "*** Building MediaInfoLib ***" && \
  cmake -S /tmp/src/MediaInfoLib-${MEDIAINFOLIB_VERSION}/Project/CMake -B /tmp/build/mediainfolib \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/opt/mediainfo \
    -DCMAKE_INSTALL_LIBDIR=lib && \
  cmake --build /tmp/build/mediainfolib -j"$(nproc)" && \
  cmake --install /tmp/build/mediainfolib && \
  echo "*** Building MediaInfo CLI and GUI ***" && \
  cmake -S /tmp/src/MediaInfo-${VERSION}/Project/CMake -B /tmp/build/mediainfo \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/opt/mediainfo \
    -DCMAKE_INSTALL_LIBDIR=lib && \
  cmake --build /tmp/build/mediainfo -j"$(nproc)" && \
  cmake --install /tmp/build/mediainfo

# UNVERIFIED: licence file names inside each tarball.
RUN \
  echo "*** Collecting licences ***" && \
  mkdir -p /opt/mediainfo/share/licenses/mediainfo && \
  cp /tmp/src/ZenLib-${ZENLIB_VERSION}/LICENSE /opt/mediainfo/share/licenses/mediainfo/LICENSE-ZenLib && \
  cp /tmp/src/MediaInfoLib-${MEDIAINFOLIB_VERSION}/LICENSE /opt/mediainfo/share/licenses/mediainfo/LICENSE-MediaInfoLib && \
  cp /tmp/src/MediaInfo-${VERSION}/LICENSE /opt/mediainfo/share/licenses/mediainfo/LICENSE-MediaInfo

# UNVERIFIED: runtime package names for ubuntu 26.04 (Qt6, tinyxml2, Mesa, fonts, Xvfb and x11vnc).
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

USER root

RUN \
  echo "*** Installing runtime dependencies ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    xvfb \
    x11vnc \
    xkb-data \
    libtinyxml2-11 \
    libqt6core6 \
    libqt6gui6 \
    libqt6widgets6 \
    libqt6svg6 \
    libqt6dbus6 \
    libgl1-mesa-dri \
    fonts-roboto-mono && \
  rm -rf /var/lib/apt/lists/*

COPY --from=mediainfo-build /opt/mediainfo/ /opt/mediainfo/
COPY --from=mediainfo-build /opt/mediainfo/share/licenses/mediainfo/ /usr/share/licenses/mediainfo/

RUN \
  echo "*** Registering shared libraries and creating /config ***" && \
  echo /opt/mediainfo/lib > /etc/ld.so.conf.d/mediainfo.conf && \
  ldconfig && \
  mkdir -p /config && \
  chown apps:apps /config

ENV HOME=/config \
    XDG_CACHE_HOME=/tmp/.cache

USER apps
COPY --chmod=0755 . /

EXPOSE 5900
VOLUME /config
VOLUME /storage
