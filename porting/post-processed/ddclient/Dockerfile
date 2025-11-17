
FROM ghcr.io/trueforge-org/ubuntu:24.4@sha256:c0d65e9793c7c477d7c27c7936d9aa40dad9a404fdf49f1cfdd69da7220988bb

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
  echo "**** install build packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    build-essential && \
  echo "**** install runtime packages ****" && \
  apt-get install -y --no-install-recommends \
    dnsutils \
    inotify-tools \
    perl \
    libdigest-sha1-perl \
    libio-socket-inet6-perl \
    libio-socket-ssl-perl \
    libjson-perl \
    libnetaddr-ip-perl && \
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
  apt-get purge -y --auto-remove build-essential && \
  rm -rf \
    /config/.cpanm \
    /root/.cpanm \
    /tmp/* && \
  rm -rf /var/lib/apt/lists/*

# copy local files
USER apps
COPY . /
COPY ./root /

# ports and volumes
VOLUME /config
