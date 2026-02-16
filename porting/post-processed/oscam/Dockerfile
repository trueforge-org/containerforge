
FROM ghcr.io/trueforge-org/ubuntu:24.4@sha256:0628c88c702e66783b5565dadf138d0f878ee3c5e8ef8fc7c52b28224ae4d174

# set version label
ARG VERSION
ARG TARGETARCH
USER root

ENV \
  MAKEFLAGS="-j4"

RUN \
  echo "**** install build packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libdvbcsa-dev \
    libusb-1.0-0-dev \
    linux-headers-generic \
    libssl-dev \
    libpcsclite-dev && \
  echo "**** install runtime packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    libccid \
    libdvbcsa1 \
    libusb-1.0-0 \
    openssl \
    pcscd \
    libpcsclite1 && \
  echo "**** compile oscam ****" && \
  mkdir -p /tmp/oscam && \
  curl -o \
    /tmp/oscam.tar.gz -L \
    "https://git.streamboard.tv/common/oscam/-/archive/${VERSION}/oscam-${VERSION}.tar.gz" && \
  tar xf \
    /tmp/oscam.tar.gz -C \
    /tmp/oscam --strip-components=1 && \
  cd /tmp/oscam && \
  ./config.sh \
    --enable all \
    --disable \
    CARDREADER_DB2COM \
    CARDREADER_INTERNAL \
    CARDREADER_STINGER \
    CARDREADER_STAPI \
    CARDREADER_STAPI5 \
    IPV6SUPPORT \
    LCDSUPPORT \
    LEDSUPPORT \
    READ_SDT_CHARSETS && \
  make \
    CONF_DIR=/config \
    DEFAULT_PCSC_FLAGS="-I/usr/include/PCSC" \
    NO_PLUS_TARGET=1 \
    OSCAM_BIN=/usr/bin/oscam \
    pcsc-libusb && \
  echo "**** fix broken permissions from pcscd install ****" && \
  chown root:root \
    /usr/sbin/pcscd && \
  chmod 755 \
    /usr/sbin/pcscd && \
  echo "**** install PCSC drivers from Linuxserver S3 due to Cloudflare blocking curl download from source (original file at https://www3.hidglobal.com/sites/default/files/drivers/ifdokccid_linux_$TARGETARCH-v4.2.8.tar.gz) ****" && \
  mkdir -p \
    /tmp/omnikey && \
  curl -o \
    /tmp/omnikey.tar.gz -L \
    "https://ci-tests.linuxserver.io/artifacts/ifdokccid_linux_$TARGETARCH-v4.2.8.tar.gz" && \
  tar xzf \
    /tmp/omnikey.tar.gz -C \
    /tmp/omnikey --strip-components=2 && \
  cd /tmp/omnikey && \
  ./install && \
  echo "**** fix group for card readers and add apps to dialout group ****" && \
  groupmod -g 24 cron && \
  groupmod -g 16 dialout && \
  usermod -a -G 16 apps && \
  echo "**** cleanup ****" && \
  apt-get autoremove -y && \
  rm -rf \
    /tmp/*

# copy local files
USER apps
COPY . /
COPY ./root /

# Ports and volumes
EXPOSE 8888

VOLUME /config

WORKDIR /config
