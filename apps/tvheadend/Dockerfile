############## build stage ##############
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:ea16b55109312b5eda59cf3cdd576c10979b7532e0a9561de068b9679794ea33 AS buildstage

ARG VERSION
# renovate: datasource=git-refs depName=https://github.com/erikkaashoek/Comskip currentValue=master
ARG COMSKIP_COMMIT="a140b6ac8bc8f596729e9052819affc779c3b377"
USER root

RUN \
  echo "**** install build packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    autoconf \
    automake \
    build-essential \
    bzip2 \
    cmake \
    gettext \
    git \
    libargtable2-dev \
    libavcodec-dev \
    libavdevice-dev \
    libavfilter-dev \
    libavformat-dev \
    libavutil-dev \
    libdvbcsa-dev \
    libgcrypt20-dev \
    libhdhomerun-dev \
    libopus-dev \
    libpcre2-dev \
    libsdl2-dev \
    libssl-dev \
    libswresample-dev \
    libswscale-dev \
    libtool \
    liburiparser-dev \
    libva-dev \
    libvorbis-dev \
    libvpx-dev \
    libx264-dev \
    libx265-dev \
    libxml2-dev \
    libxslt1-dev \
    pkg-config \
    pngquant \
    python3 \
    wget \
    zlib1g-dev

RUN \
  echo "**** compile tvheadend ****" && \
  git clone https://github.com/tvheadend/tvheadend.git /tmp/tvheadend && \
  cd /tmp/tvheadend && \
  git checkout "${VERSION}" && \
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
  make -j "$(nproc)" && \
  make DESTDIR=/tmp/tvheadend-build install

RUN \
  echo "**** compile comskip ****" && \
  git clone https://github.com/erikkaashoek/Comskip /tmp/comskip && \
  cd /tmp/comskip && \
  git checkout "${COMSKIP_COMMIT}" && \
  echo "**** patch comskip for FFmpeg 8 (AVCodecContext.ticks_per_frame removed) ****" && \
  sed -i \
    -e '/->ticks_per_frame = 1;/d' \
    -e 's/is->\(dec_ctx\(par\)\{0,1\}\)->ticks_per_frame/TICKS_PER_FRAME(is->\1)/g' \
    mpeg2dec.c && \
  sed -i '1i #define TICKS_PER_FRAME(c) (((c)->codec_descriptor \&\& ((c)->codec_descriptor->props \& AV_CODEC_PROP_FIELDS)) ? 2 : 1)' \
    mpeg2dec.c && \
  ./autogen.sh && \
  ./configure \
    --bindir=/usr/bin \
    --sysconfdir=/config/comskip && \
  make -j "$(nproc)" && \
  make DESTDIR=/tmp/comskip-build install

RUN \
  echo "**** determine runtime packages ****" && \
  ldd /tmp/tvheadend-build/usr/bin/tvheadend /tmp/comskip-build/usr/bin/comskip \
    | awk '/=> \// { print $3 }' \
    | sort -u \
    | xargs -r realpath \
    | xargs -r dpkg -S 2>/dev/null \
    | cut -d: -f1 \
    | sort -u \
    > /tmp/runtime-packages

############## runtime stage ##############
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:ea16b55109312b5eda59cf3cdd576c10979b7532e0a9561de068b9679794ea33

ARG VERSION
ARG TARGETARCH
USER root

ENV HOME="/config"

COPY --from=buildstage /tmp/runtime-packages /tmp/runtime-packages

RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    $(cat /tmp/runtime-packages) \
    bzip2 \
    ffmpeg \
    i965-va-driver \
    intel-media-va-driver \
    libdatetime-format-strptime-perl \
    libjson-perl \
    libjson-xs-perl \
    mesa-va-drivers \
    perl \
    python3 \
    python3-requests \
    xmltv && \
  mkdir -p /picons && \
  echo "**** cleanup ****" && \
  apt-get clean && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/*

COPY --from=buildstage /tmp/comskip-build/usr/ /usr/
COPY --from=buildstage /tmp/tvheadend-build/usr/ /usr/

USER apps
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 9981 9982
VOLUME /config

WORKDIR /config
