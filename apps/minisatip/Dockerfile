
FROM ghcr.io/trueforge-org/ubuntu:24.4@sha256:8b0b1f042b2fd6d7a2a8ad73e0b4470404cabfee1d209ae04fe6fcd2cc761152

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
    cmake \
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
  cmake -B build . && \
  cmake --build build -j"$(nproc)" && \
  mv /app/satip/build/minisatip /app/satip/minisatip && \
  rm -rf /app/satip/build && \
  echo "**** clean up ****" && \
  apt-get -y purge \
    build-essential \
    cmake \
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
    /var/tmp/*

# add local files
USER apps
COPY --chmod=0755 . /
COPY ./ /

# ports and volumes
EXPOSE 8875 554 1900/udp
