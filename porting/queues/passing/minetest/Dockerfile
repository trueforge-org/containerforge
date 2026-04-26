
FROM ghcr.io/trueforge-org/python:3.13.12

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# environment variables
ENV HOME="/config" \
  MINETEST_GAME_PATH="/config/.minetest/games"

# build variables
ARG LDFLAGS=""

RUN \
  echo "**** install build packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libbz2-dev \
    cmake \
    libcurl4-openssl-dev \
    doxygen \
    gettext \
    libgmp-dev \
    libhiredis-dev \
    libicu-dev \
    libirrlicht-dev \
    libleveldb-dev \
    libjpeg-dev \
    libogg-dev \
    libpng-dev \
    libssl-dev \
    libtool \
    libvorbis-dev \
    libxi-dev \
    libluajit-5.1-dev \
    libgl1-mesa-dev \
    libncurses-dev \
    libopenal-dev \
    libpq-dev \
    python3-dev \
    libsdl2-dev \
    libsqlite3-dev \
    libzstd-dev && \
  echo "**** install runtime packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    libgmp10 \
    libhiredis1.1.0 \
    libleveldb1d \
    libgcc-s1 \
    libpq5 \
    libstdc++6 \
    luajit \
    lua-socket \
    libsdl2-2.0-0 \
    sqlite3 \
    zstd \
    libzstd1 && \
  echo "**** compile minetestserver ****" && \
  mkdir -p \
    /tmp/minetest && \
  curl -o \
    /tmp/minetest-src.tar.gz -L \
    "https://github.com/minetest/minetest/archive/${VERSION}.tar.gz" && \
  tar xf \
  /tmp/minetest-src.tar.gz -C \
    /tmp/minetest --strip-components=1 && \
  mkdir -p /defaults && \
  sed -i 's/# enable_ipv6 = true/enable_ipv6 = true/' /tmp/minetest/minetest.conf.example && \
  sed -i 's/# ipv6_server = false/ipv6_server = true/' /tmp/minetest/minetest.conf.example && \
  cp /tmp/minetest/minetest.conf.example /defaults/minetest.conf && \
  cd /tmp/minetest && \
  cmake . \
    -DBUILD_CLIENT=0 \
    -DBUILD_SERVER=1 \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCUSTOM_BINDIR=/usr/bin \
    -DCUSTOM_DOCDIR="/usr/share/doc/minetest" \
    -DCUSTOM_SHAREDIR="/usr/share/minetest" \
    -DENABLE_CURL=1 \
    -DENABLE_FREETYPE=1 \
    -DENABLE_GETTEXT=0 \
    -DENABLE_LEVELDB=1 \
    -DENABLE_LUAJIT=1 \
    -DENABLE_POSTGRESQL=1 \
    -DENABLE_PROMETHEUS=0 \
    -DENABLE_REDIS=0 \
    -DENABLE_SOUND=0 \
    -DENABLE_SYSTEM_GMP=1 \
    -DRUN_IN_PLACE=0 && \
  make -j 4 && \
  make install && \
  echo "**** copy games to temporary folder ****" && \
  mkdir -p \
    /defaults/games && \
  cp -pr  /tmp/minetest/games/* /defaults/games/ && \
  echo "**** cleanup ****" && \
  apt-get autoremove -y && \
  rm -rf \
    /tmp/*

# add local files
USER apps
COPY --chmod=0755 . /


# ports and volumes
EXPOSE 30000/udp
VOLUME /config
VOLUME /config/.minetest

WORKDIR /config
