FROM ghcr.io/trueforge-org/python:3.13.12

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
  echo "**** install build packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    autoconf \
    automake \
    build-essential \
    cargo \
    libfreetype-dev \
    libjpeg-dev \
    liblcms2-dev \
    libffi-dev \
    libpng-dev \
    libwebp-dev \
    libxml2-dev \
    libxslt-dev \
    linux-headers-generic \
    libopenjp2-7-dev \
    libssl-dev \
    libtiff-dev \
    zlib1g-dev && \
  echo "**** install runtime packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    vnstat && \
  echo "**** install app ****" && \
  mkdir -p /app/htpcmanager && \
  curl -s -o \
    /tmp/htpc.tar.gz -L \
    "https://github.com/HTPC-Manager/HTPC-Manager/archive/${VERSION}.tar.gz" && \
  tar xf \
    /tmp/htpc.tar.gz -C \
    /app/htpcmanager --strip-components=1 && \
  echo "**** install pip packages ****" && \
  sed -i -e '/psutil\|pyopenssl\|pySMART/d' /app/htpcmanager/requirements.txt && \
  python3 -m venv /app/venv && \
  /app/venv/bin/pip install -U --no-cache-dir \
    pip \
    wheel && \
  /app/venv/bin/pip install --no-cache-dir --find-links https://wheel-index.linuxserver.io/alpine-3.20/ -r /app/htpcmanager/requirements.txt && \
  echo ${VERSION} > /app/htpcmanager/VERSION.txt && \
  echo "**** cleanup ****" && \
  apt-get autoremove -y && \
  rm -rf \
    $HOME/.cache \
    /tmp/*

# add local files
USER apps
COPY . /


# ports and volumes
EXPOSE 8085
VOLUME /config

WORKDIR /config
