
FROM ghcr.io/trueforge-org/ubuntu:24.4@sha256:c0d65e9793c7c477d7c27c7936d9aa40dad9a404fdf49f1cfdd69da7220988bb

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
  echo "**** install build packages ****" && \
  apk add --no-cache --virtual=build-dependencies \
    build-base && \
  echo "**** install runtime packages ****" && \
  apk add --no-cache \
    bind-tools \
    inotify-tools \
    perl \
    perl-digest-sha1 \
    perl-io-socket-inet6 \
    perl-io-socket-ssl \
    perl-json \
    perl-netaddr-ip && \
  echo "***** install perl modules ****" && \
  curl -L http://cpanmin.us | perl - App::cpanminus && \
  cpanm \
    Data::Validate::IP \
    JSON::Any && \
  echo "**** install ddclient ****" && \
  mkdir -p \
    /tmp/ddclient && \
  curl -o \
  /tmp/ddclient.tar.gz -L \
    "https://github.com/ddclient/ddclient/archive/v${VERSION}.tar.gz" && \
  tar xf \
  /tmp/ddclient.tar.gz -C \
    /tmp/ddclient --strip-components=1 && \
  cp /tmp/ddclient/ddclient.in /usr/bin/ddclient.in && \
  ln -s /usr/bin/ddclient.in /usr/bin/ddclient && \
  mkdir -p /etc/ddclient/ && \
  cp /tmp/ddclient/sample-get-ip-from-fritzbox /etc/ddclient/get-ip-from-fritzbox && \
  echo "**** cleanup ****" && \
  apk del --purge \
    build-dependencies && \
  rm -rf \
    /config/.cpanm \
    /root/.cpanm \
    /tmp/*

# copy local files
USER apps
COPY . /
COPY ./root /

# ports and volumes
VOLUME /config
