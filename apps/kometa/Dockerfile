
FROM ghcr.io/trueforge-org/python:3.13.7@sha256:436649ee533b748645c1e3ad8e4a1fc3fd2d9d4f0b1cc937bf742a5c3a7f32e5

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# environment settings
ENV S6_STAGE2_HOOK=/init-hook
ENV HOME="/config" \
PYTHONIOENCODING=utf-8

RUN \
    echo "**** install packages ****" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        libffi-dev \
        libxml2-dev \
        libzen-dev \
        python3-dev \
        libjpeg-dev \
        libxslt1-dev \
        python3-venv \
        python3-pip && \
    mkdir -p /app/kometa && \
    python3 - <<'PY'
import os, urllib.request, tarfile, io
url = "https://github.com/Kometa-Team/Kometa/archive/v${VERSION}.tar.gz"
mkdir -p /app/kometa && \
  curl -o \
    /tmp/kometa.tar.gz -L \
    "https://github.com/Kometa-Team/Kometa/archive/v${VERSION}.tar.gz" && \
  tar xf \
    /tmp/kometa.tar.gz -C \
    /app/kometa --strip-components=1 && \
  cd /app/kometa && \
  python3 -m venv /config/venv && \
  pip install -U --no-cache-dir \
    pip \
    wheel && \
  pip install -U --no-cache-dir --find-links https://wheel-index.linuxserver.io/ubuntu/ -r requirements.txt && \
  echo "**** cleanup ****" && \
    apt-get remove -y --purge \
        build-essential \
        libffi-dev \
        libxml2-dev \
        libzen-dev \
        python3-dev && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* $HOME/.cache

# add local files
USER apps
COPY . /
COPY ./root /

# ports and volumes
VOLUME /config

ENTRYPOINT ["/init-kometa"]
