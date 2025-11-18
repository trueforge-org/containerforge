
FROM ghcr.io/trueforge-org/ubuntu:24.4@sha256:0628c88c702e66783b5565dadf138d0f878ee3c5e8ef8fc7c52b28224ae4d174

# set version label
ARG VERSION
ARG TARGETARCH
USER root
ARG MINETEST_RELEASE

# environment variables
ENV HOME="/config" \
  MINETEST_GAME_PATH="/config/.minetest/games"

# build variables
ARG LDFLAGS="-lintl"

RUN \
  echo "**** install build packages ****" && \
  apk add --no-cache --virtual=build-dependencies \
    build-base \
    bzip2-dev \
    cmake \
    curl-dev \
    doxygen \
    gettext-dev \
    gmp-dev \
    hiredis-dev \
    icu-dev \
    leveldb-dev \
    libjpeg-turbo-dev \
    libogg-dev \
    libpng-dev \
    openssl-dev \
    libtool \
    libvorbis-dev \
    libxi-dev \
    luajit-dev \
    mesa-dev \
    ncurses-dev \
    ninja-build \
    ninja-is-really-ninja \
    openal-soft-dev \
    postgresql-dev \
    python3-dev \
    sdl2-dev \
    sqlite-dev \
    zstd-dev && \
  echo "**** install runtime packages ****" && \
  apk add --no-cache \
    gmp \
    hiredis \
    leveldb \
    libgcc \
    libintl \
    libpq \
    libstdc++ \
    luajit \
    lua-socket \
    sdl2 \
    sqlite \
    sqlite-libs \
    zstd \
    zstd-libs && \
  echo "**** compile prometheus-cpp ****" && \
  mkdir -p /tmp/prometheus-cpp && \
  PROM_URL=$(curl -sX GET "https://api.github.com/repos/jupp0r/prometheus-cpp/releases/latest" \
    | jq -r .assets[].browser_download_url) && \
  curl -o /tmp/prometheus-cpp.tar.gz \
    -L "$PROM_URL" && \
  tar xf /tmp/prometheus-cpp.tar.gz -C \
    /tmp/prometheus-cpp --strip-components=1 && \
  cd /tmp/prometheus-cpp && \
  mkdir build && \
  cd build && \
  cmake .. -B build \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_BUILD_TYPE=Release \
    -DENABLE_TESTING=0 \
    -GNinja && \
  cmake --build build && \
  cmake --install build && \
  echo "**** compile spatialindex ****" && \
  mkdir -p /tmp/spatialindex && \
  SPATIAL_VER=$(curl -sX GET "https://api.github.com/repos/libspatialindex/libspatialindex/commits/main" \
    | jq -r .sha) && \
  curl -o /tmp/spatialindex.tar.gz \
    -L "https://github.com/libspatialindex/libspatialindex/archive/${SPATIAL_VER}.tar.gz" && \
  tar xf /tmp/spatialindex.tar.gz -C \
    /tmp/spatialindex --strip-components=1 && \
  cd /tmp/spatialindex && \
  cmake . -B build \
    -DCMAKE_INSTALL_PREFIX=/usr && \
  cmake --build build && \
  cmake --install build && \
  echo "**** compile luanti ****" && \
  mkdir -p \
    /tmp/luanti && \
  curl -o \
    /tmp/luanti-src.tar.gz -L \
    "https://github.com/luanti-org/luanti/archive/${VERSION}.tar.gz" && \
  tar xf /tmp/luanti-src.tar.gz -C \
    /tmp/luanti --strip-components=1 && \
  sed -i 's/# enable_ipv6 = true/enable_ipv6 = true/' /tmp/luanti/minetest.conf.example && \
  sed -i 's/# ipv6_server = false/ipv6_server = true/' /tmp/luanti/minetest.conf.example && \
  cp /tmp/luanti/minetest.conf.example /defaults/minetest.conf && \
  cd /tmp/luanti && \
  cmake . -B build \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_CLIENT=0 \
    -DBUILD_SERVER=1 \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCUSTOM_BINDIR=/usr/bin \
    -DCUSTOM_DOCDIR="/usr/share/doc/luanti" \
    -DCUSTOM_SHAREDIR="/usr/share/luanti" \
    -DENABLE_CURL=1 \
    -DENABLE_GETTEXT=0 \
    -DENABLE_LEVELDB=1 \
    -DENABLE_LUAJIT=1 \
    -DENABLE_POSTGRESQL=1 \
    -DENABLE_PROMETHEUS=1 \
    -DENABLE_REDIS=1 \
    -DENABLE_SOUND=0 \
    -DENABLE_SYSTEM_GMP=1 \
    -DRUN_IN_PLACE=0 \
    -GNinja && \
  cmake --build build && \
  cmake --install build && \
  echo "**** copy games to temporary folder ****" && \
  mkdir -p \
    /defaults/games && \
  cp -pr  /tmp/luanti/games/* /defaults/games/ && \
  echo "**** cleanup ****" && \
  apk del --purge \
    build-dependencies && \
  rm -rf \
    /tmp/*

# add local files
USER apps
COPY . /


# ports and volumes
EXPOSE 30000/udp
VOLUME /config/.minetest
