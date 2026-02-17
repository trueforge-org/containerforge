
FROM ghcr.io/trueforge-org/ubuntu:24.4@sha256:7f4b4dfea9fcd818103c5d1f64cd5135785977fc90927aab58d25a155f27be4a

# set version label
ARG VERSION
ARG TARGETARCH
USER root

ENV \
   MAKEFLAGS="-j4" \
  ATTACHED_DEVICES_PERMS="/dev/dvb -type c"

RUN \
  echo "**** install packages ****" && \
  apt-get update && \
  apt-get install --no-install-recommends -y \
    build-essential \
    git \
    libdvbcsa-dev \
    libssl-dev \
    linux-headers-generic \
    openssl \
    perl && \
  echo "***** compile satip ****" && \
  mkdir -p \
    /app/satip && \
  curl -o \
    /tmp/satip.tar.gz -L \
    "https://github.com/catalinii/minisatip/archive/v${VERSION}.tar.gz" && \
  tar xf \
    /tmp/satip.tar.gz -C \
    /app/satip --strip-components=1 && \
  cd /app/satip && \
  ./configure && \
  make DDCI=1 && \
  echo "**** clean up ****" && \
  apt-get -y purge \
    build-essential \
    git \
    libssl-dev \
    linux-headers-generic \
    perl && \
  apt-get -y autoremove && \
  mkdir -p /var/cache/minisatip && \
  chown -R apps:apps /var/cache/minisatip && chmod -R 755 /var/cache/minisatip && \
  chown -R apps:apps /app && chmod -R 755 /app && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /root/.cache

# add local files
USER apps
COPY ./ /

# ports and volumes
EXPOSE 8875 554 1900/udp
