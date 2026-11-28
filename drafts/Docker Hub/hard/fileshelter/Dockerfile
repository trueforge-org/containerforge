# syntax=docker/dockerfile:1@sha256:572cebbc2b15e6f84c077742952674889cb63cd5e9b80abdffcbe587b6f19183

# Build stage: Wt and fileshelter are compiled from source (no prebuilt binaries are published).
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS build

ARG VERSION
ARG WT_VERSION
USER root

# UNVERIFIED: Ubuntu package names for the upstream Alpine build list, confirm on 26.04 with apt-cache policy.
RUN echo "*** Installing build dependencies ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    pkg-config \
    curl \
    ca-certificates \
    libboost-program-options-dev \
    libboost-thread-dev \
    libboost-filesystem-dev \
    libboost-system-dev \
    libarchive-dev \
    libconfig++-dev \
    libssl-dev \
    zlib1g-dev \
    libsqlite3-dev && \
  rm -rf /var/lib/apt/lists/*

# Wt is pinned by WT_VERSION (upstream pins 4.12.3); HTTP connector and the sqlite3 Dbo backend must stay enabled.
# UNVERIFIED: the license file name inside the Wt tarball (LICENSE* glob assumed).
RUN echo "*** Building Wt ${WT_VERSION} ***" && \
  curl -fsSL -o /tmp/wt.tar.gz \
    "https://github.com/emweb/wt/archive/${WT_VERSION}.tar.gz" && \
  mkdir -p /tmp/wt-src && \
  tar xzf /tmp/wt.tar.gz -C /tmp/wt-src --strip-components=1 && \
  cmake -S /tmp/wt-src -B /tmp/wt-build \
    -DCMAKE_INSTALL_PREFIX=/opt/fileshelter \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CXX_STANDARD=20 \
    -DSHARED_LIBS=ON \
    -DBUILD_EXAMPLES=OFF \
    -DENABLE_LIBWTTEST=OFF \
    -DCONNECTOR_FCGI=OFF \
    -DWT_CPP17_FILESYSTEM_IMPLEMENTATION=std \
    -DWT_CPP17_ANY_IMPLEMENTATION=std && \
  cmake --build /tmp/wt-build --parallel "$(nproc)" && \
  cmake --install /tmp/wt-build && \
  mkdir -p /opt/fileshelter/share/licenses/wt && \
  cp /tmp/wt-src/LICENSE* /opt/fileshelter/share/licenses/wt/ && \
  rm -rf /tmp/wt-build /tmp/wt-src /tmp/wt.tar.gz

# Unity build plus LTO is RAM heavy. If CI runs out of memory, lower --parallel here.
RUN echo "*** Building fileshelter ${VERSION} ***" && \
  curl -fsSL -o /tmp/fileshelter.tar.gz \
    "https://github.com/epoupon/fileshelter/archive/refs/tags/v${VERSION}.tar.gz" && \
  mkdir -p /tmp/fileshelter-src && \
  tar xzf /tmp/fileshelter.tar.gz -C /tmp/fileshelter-src --strip-components=1 && \
  PKG_CONFIG_PATH=/opt/fileshelter/lib/pkgconfig cmake -S /tmp/fileshelter-src -B /tmp/fileshelter-build \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_UNITY_BUILD=ON \
    -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=TRUE \
    -DCMAKE_INSTALL_PREFIX=/opt/fileshelter \
    -DCMAKE_PREFIX_PATH=/opt/fileshelter && \
  cmake --build /tmp/fileshelter-build --parallel "$(nproc)" && \
  cmake --install /tmp/fileshelter-build && \
  mkdir -p /opt/fileshelter/share/licenses/fileshelter && \
  cp /tmp/fileshelter-src/COPYING /opt/fileshelter/share/licenses/fileshelter/ && \
  find /opt/fileshelter -type f \( -path '*/bin/*' -o -name '*.so*' \) -exec strip --strip-unneeded {} + 2>/dev/null || true && \
  rm -rf /tmp/fileshelter-build /tmp/fileshelter-src /tmp/fileshelter.tar.gz

# Runtime stage
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
USER root

# UNVERIFIED: runtime library names. Boost sonames are versioned, so the -dev packages are used
# until the exact runtime packages are confirmed with apt-cache search on 26.04.
RUN echo "*** Installing runtime dependencies ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    libarchive13t64 \
    libconfig++9v5 \
    libssl3t64 \
    zlib1g \
    libsqlite3-0 \
    libboost-program-options-dev \
    libboost-thread-dev \
    libboost-filesystem-dev \
    libboost-system-dev && \
  rm -rf /var/lib/apt/lists/*

COPY --from=build /opt/fileshelter /usr/local
RUN ldconfig

ENV \
  HOME=/config \
  TMPDIR=/tmp

USER apps
COPY --chmod=0755 . /

EXPOSE 5091

VOLUME /config
WORKDIR /config
