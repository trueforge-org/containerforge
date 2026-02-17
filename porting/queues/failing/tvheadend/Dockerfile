############## picons stage ##############
# built by https://github.com/linuxserver/picons-builder
FROM ghcr.io/trueforge-org/python:3.13.12


FROM ghcr.io/trueforge-org/ubuntu:24.04 as buildstage
############## build stage ##############

# package versions
ARG ARGTABLE_VER="2.13"

# environment settings
ARG TZ="Etc/UTC"
ENV HOME="/config"

# copy patches and picons
COPY patches/ /tmp/patches/
COPY --from=piconsstage /picons.tar.bz2 /picons.tar.bz2

RUN \
  echo "**** install build packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    autoconf \
    automake \
    bsd-compat-headers \
    build-essential \
    cmake \
    libavcodec-dev libavdevice-dev libavfilter-dev libavformat-dev libavutil-dev libpostproc-dev libswresample-dev libswscale-dev \
    file \
    findutils \
    gettext \
    gnu-libiconv-dev \
    libdvbcsa-dev \
    libgcrypt-dev \
    libhdhomerun-dev \
    libtool \
    libva-dev \
    libvpx-dev \
    libxml2-dev \
    libxslt-dev \
    linux-headers-generic \
    libssl-dev \
    opus-dev \
    patch \
    pcre2-dev \
    pkgconf \
    pngquant \
    python3 \
    libsdl2-dev \
    uriparser-dev \
    x264-dev \
    x265-dev \
    zlib1g-dev

RUN \
  echo "**** remove musl iconv.h and replace with gnu-iconv.h ****" && \
  rm -rf /usr/include/iconv.h && \
  cp /usr/include/gnu-libiconv/iconv.h /usr/include/iconv.h

RUN \
  echo "**** compile tvheadend ****" && \
  mkdir -p \
    /tmp/tvheadend && \
  git clone https://github.com/tvheadend/tvheadend.git /tmp/tvheadend && \
  cd /tmp/tvheadend && \
  git checkout ${VERSION} && \
  ./configure \
    `#Encoding` \
    --disable-ffmpeg_static \
    --disable-libfdkaac_static \
    --disable-libtheora_static \
    --disable-libopus_static \
    --disable-libvorbis_static \
    --disable-libvpx_static \
    --disable-libx264_static \
    --disable-libx265_static \
    --disable-libfdkaac \
    --enable-libopus \
    --enable-libvorbis \
    --enable-libvpx \
    --enable-libx264 \
    --enable-libx265 \
    \
    `#Options` \
    --disable-avahi \
    --disable-dbus_1 \
    --disable-bintray_cache \
    --disable-execinfo \
    --disable-hdhomerun_static \
    --enable-hdhomerun_client \
    --enable-libav \
    --enable-pngquant \
    --enable-trace \
    --enable-vaapi \
    --infodir=/usr/share/info \
    --localstatedir=/var \
    --mandir=/usr/share/man \
    --prefix=/usr \
    --python=python3 \
    --sysconfdir=/config && \
  make -j 2 && \
  make DESTDIR=/tmp/tvheadend-build install

RUN \
  echo "**** compile argtable2 ****" && \
  ARGTABLE_VER1="${ARGTABLE_VER//./-}" && \
  mkdir -p \
    /tmp/argtable && \
  curl -s -o \
  /tmp/argtable-src.tar.gz -L \
    "https://sourceforge.net/projects/argtable/files/argtable/argtable-${ARGTABLE_VER}/argtable${ARGTABLE_VER1}.tar.gz" && \
  tar xf \
  /tmp/argtable-src.tar.gz -C \
    /tmp/argtable --strip-components=1 && \
  cp /tmp/patches/config.* /tmp/argtable && \
  cd /tmp/argtable && \
  ./configure \
    --prefix=/usr && \
  make -j 2 && \
  make check && \
  make DESTDIR=/tmp/argtable-build install && \
  echo "**** copy to /usr for comskip dependency ****" && \
  cp -pr /tmp/argtable-build/usr/* /usr/

RUN \
  echo "***** compile comskip ****" && \
  git clone https://github.com/erikkaashoek/Comskip /tmp/comskip && \
  cd /tmp/comskip && \
  ./autogen.sh && \
  ./configure \
    --bindir=/usr/bin \
    --sysconfdir=/config/comskip && \
  make -j 2 && \
  make DESTDIR=/tmp/comskip-build install

RUN \
  echo "***** extract picons ****" && \
  mkdir -p /picons && \
  tar xf \
    /picons.tar.bz2 -C \
    /picons

############## runtime stage ##############
FROM ghcr.io/trueforge-org/ubuntu:24.04

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# environment settings
ENV HOME="/config"

RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    bsd-compat-headers \
    ffmpeg \
    libavcodec60 \
    libavdevice60 \
    libavfilter9 \
    libavformat60 \
    libavutil58 \
    libpostproc57 \
    libswresample4 \
    libswscale7 \
    gnu-libiconv \
    libdvbcsa1 \
    libhdhomerun-libs \
    libva \
    libva-intel-driver \
    intel-media-driver \
    libvpx \
    libxml2 \
    libxslt1.1 \
    linux-headers-generic \
    mesa-va-gallium \
    opus \
    pcre2 \
    perl \
    perl-datetime-format-strptime \
    perl-json \
    perl-json-xs \
    py3-requests \
    python3 \
    uriparser \
    x264 \
    x265 \
    xmltv \
    zlib

USER apps
# copy local files and buildstage artifacts
COPY --from=buildstage /tmp/argtable-build/usr/ /usr/
COPY --from=buildstage /tmp/comskip-build/usr/ /usr/
COPY --from=buildstage /tmp/tvheadend-build/usr/ /usr/
COPY --from=buildstage /picons /picons

COPY . /
COPY ./root /

# ports and volumes
EXPOSE 9981 9982
VOLUME /config

WORKDIR /config
