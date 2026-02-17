
FROM ghcr.io/trueforge-org/python:3.13.12

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
  echo "**** install build dependencies ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libjpeg-dev \
    libffi-dev \
    libwebp-dev \
    zlib1g-dev && \
  echo "**** install runtime packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    libjpeg-turbo8 \
    webp \
    nodejs \
    zlib1g && \
  echo "**** install mylar3 ****" && \
  mkdir /app/mylar3 && \
  curl -o \
    /tmp/mylar3.tar.gz -L \
    "https://github.com/mylar3/mylar3/archive/v${VERSION}.tar.gz" && \
  tar xf /tmp/mylar3.tar.gz -C \
    /app/mylar3/ --strip-components=1 && \
  cd /app/mylar3 && \
  python3 -m venv /config/venv && \
  pip install -U --no-cache-dir \
    pip \
    wheel && \
  pip install --no-cache-dir --find-links https://wheel-index.linuxserver.io/alpine-3.19/ -r requirements.txt && \
  echo "**** cleanup ****" && \
  apt-get autoremove -y && \
  rm -rf \
    /root/.cache \
    /tmp/*

# add local files
USER apps
COPY . /

# ports and volumes
VOLUME /config
EXPOSE 8090

WORKDIR /config
