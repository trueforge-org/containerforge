
FROM ghcr.io/trueforge-org/python:3.13.12

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
    apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        libbz2-dev \
        cmake \
        doxygen \
        gettext \
        libgmp-dev \
        libhiredis-dev \
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
        ninja-build \
        libopenal-dev \
        libpq-dev \
        python3-dev \
        libsdl2-dev \
        libsqlite3-dev \
        libzstd-dev \
        pkg-config && \
    echo "**** install runtime packages ****" && \
    apt-get install -y --no-install-recommends \
        libgmp10 \
        libhiredis1.1.0 \
        libleveldb1d \
        libgcc-s1 \
        libpq5 \
        libstdc++6 \
        luajit \
        lua-socket \
        libsdl2-2.0-0 \
        zstd \
        libzstd1 && \
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
    apt-get remove --purge -y \
        build-essential \
        libbz2-dev \
        cmake \
        doxygen \
        gettext \
        libgmp-dev \
        libhiredis-dev \
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
        ninja-build \
        libopenal-dev \
        libpq-dev \
        python3-dev \
        libsdl2-dev \
        libsqlite3-dev \
        libzstd-dev \
        pkg-config && \
    apt-get autoremove -y && \
    rm -rf \
        /var/lib/apt/lists/* \
        /tmp/*

# add local files
USER apps
COPY . /


# ports and volumes
EXPOSE 30000/udp
VOLUME /config
VOLUME /config/.minetest

WORKDIR /config
