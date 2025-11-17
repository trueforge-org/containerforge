
FROM ghcr.io/trueforge-org/ubuntu:24.4@sha256:c0d65e9793c7c477d7c27c7936d9aa40dad9a404fdf49f1cfdd69da7220988bb AS buildstage
############## build stage ##############
USER root
ARG VERSION
ARG TARGETARCH

RUN \
  echo "**** install build packages ****" && \
  apk add -U --update --no-cache \
    alsa-lib-dev \
    autoconf \
    automake \
    avahi-dev \
    bison \
    bsd-compat-headers \
    build-base \
    confuse-dev \
    curl-dev \
    ffmpeg-dev \
    flac-dev \
    flex \
    gettext-dev \
    gnutls-dev \
    gperf \
    json-c-dev \
    libevent-dev \
    libgcrypt-dev \
    libogg-dev \
    libplist-dev \
    libsodium-dev \
    libtool \
    libunistring-dev \
    libwebsockets-dev \
    libxml2-dev \
    mxml-dev \
    openjdk8-jre-base \
    openssl-dev \
    protobuf-c-dev \
    sqlite-dev \
    taglib-dev && \
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
FROM ghcr.io/trueforge-org/ubuntu:24.4@sha256:c0d65e9793c7c477d7c27c7936d9aa40dad9a404fdf49f1cfdd69da7220988bb

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
  echo "**** install runtime packages ****" && \
  apk add -U --update --no-cache \
    avahi \
    confuse \
    dbus \
    ffmpeg \
    gnutls \
    json-c \
    libevent \
    libgcrypt \
    libplist \
    libsodium \
    libunistring \
    libuuid \
    libwebsockets \
    mxml \
    protobuf-c \
    sqlite \
    sqlite-libs && \
  apk add -U --update --no-cache --repository https://dl-cdn.alpinelinux.org/alpine/edge/testing \
    librespot && \
  mkdir -p /music && \
# copy buildstage and local files
COPY --from=buildstage /tmp/daapd-build/ /
USER apps
COPY . /


# ports and volumes
EXPOSE 3689

VOLUME /config /music
