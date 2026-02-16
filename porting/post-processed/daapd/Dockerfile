
FROM ghcr.io/trueforge-org/ubuntu:24.4@sha256:0628c88c702e66783b5565dadf138d0f878ee3c5e8ef8fc7c52b28224ae4d174 AS buildstage
############## build stage ##############
USER root
ARG VERSION
ARG TARGETARCH

RUN \
  echo "**** install build packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    libasound2-dev \
    autoconf \
    automake \
    libavahi-client-dev \
    libavahi-common-dev \
    bison \
    build-essential \
    libconfuse-dev \
    libcurl4-libssl-dev \
    libavcodec-dev \
    libavformat-dev \
    libavutil-dev \
    libflac-dev \
    flex \
    libgettextpo-dev \
    libgnutls28-dev \
    gperf \
    libjson-c-dev \
    libevent-dev \
    libgcrypt20-dev \
    libogg-dev \
    libplist-dev \
    libsodium-dev \
    libtool \
    libunistring-dev \
    libwebsockets-dev \
    libxml2-dev \
    libmxml-dev \
    default-jre-headless \
    libssl-dev \
    libprotobuf-c-dev \
    libsqlite3-dev \
    libtag1-dev && \
  rm -rf /var/lib/apt/lists/* && \
  mkdir -p \
    /tmp/source/owntone && \
  echo "**** compile owntone-server ****" && \
  curl -o \
  /tmp/source/owntone.tar.gz -L \
    "https://github.com/owntone/owntone-server/archive/${VERSION}.tar.gz" && \
  tar xf /tmp/source/owntone.tar.gz -C \
    /tmp/source/owntone --strip-components=1 && \
  export PATH="/tmp/source:$PATH" && \
  cd /tmp/source/owntone && \
  autoreconf -i -v && \
  ./configure \
    --build=$CBUILD \
    --enable-chromecast \
    --enable-lastfm \
    --enable-mpd \
    --host=$CHOST \
    --infodir=/usr/share/info \
    --localstatedir=/var \
    --mandir=/usr/share/man \
    --prefix=/usr \
    --sysconfdir=/etc && \
  make && \
  make DESTDIR=/tmp/daapd-build install && \
  mv /tmp/daapd-build/etc/owntone.conf /tmp/daapd-build/etc/owntone.conf.orig && \
  rm -rf /tmp/daapd-build/var

############## runtime stage ##############
FROM ghcr.io/trueforge-org/ubuntu:24.4@sha256:0628c88c702e66783b5565dadf138d0f878ee3c5e8ef8fc7c52b28224ae4d174

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    avahi-daemon \
    libconfuse2 \
    dbus \
    ffmpeg \
    libgnutls30 \
    libjson-c3 \
    libevent-2.1-7 \
    libgcrypt20 \
    libplist3 \
    libsodium23 \
    libunistring2 \
    libuuid1 \
    libwebsockets18 \
    libmxml1 \
    libprotobuf-c1 \
    libsqlite3-0 \
    sqlite3 && \
  apt-get install -y --no-install-recommends librespot || true && \
  rm -rf /var/lib/apt/lists/* && \
  mkdir -p /music

# copy buildstage and local files
COPY --from=buildstage /tmp/daapd-build/ /
USER apps
COPY . /


# ports and volumes
EXPOSE 3689

VOLUME /config
VOLUME /music

WORKDIR /config
