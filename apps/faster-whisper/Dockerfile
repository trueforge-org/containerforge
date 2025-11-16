
FROM ghcr.io/trueforge-org/python:3.13.7

# set version label
ARG VERSION
USER root

ENV HOME=/config \
   TMPDIR="/run/whisper-temp"

RUN \
  echo "**** install packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    build-essential \
    git \
  python3 -m venv /lsiopy && \
  pip install -U --no-cache-dir \
    pip \
    wheel && \
  pip install -U --no-cache-dir --find-links https://wheel-index.linuxserver.io/ubuntu/ \
    git+https://github.com/rhasspy/wyoming-faster-whisper@v${VERSION} && \
  echo "**** cleanup ****" && \
  apt-get purge -y --auto-remove \
    build-essential \
    git \
    python3-dev && \
  rm -rf \
    /var/lib/apt/lists/* \
    /tmp/*

USER apps
COPY ./root/ /

VOLUME /config

EXPOSE 10300
