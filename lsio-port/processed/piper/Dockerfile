
FROM ghcr.io/linuxserver/baseimage-ubuntu:noble

# set version label
ARG VERSION
ARG PIPER_VERSION

ENV DEBIAN_FRONTEND="noninteractive" \
  TMPDIR="/run/piper-temp"

RUN \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    python3-venv && \
  if [ -z ${PIPER_VERSION+x} ]; then \
    PIPER_VERSION=$(curl -sL  https://pypi.python.org/pypi/wyoming-piper/json |jq -r '. | .info.version'); \
  fi && \
  python3 -m venv /lsiopy && \
  pip install -U --no-cache-dir \
    pip \
    wheel && \
  pip install -U --no-cache-dir --find-links https://wheel-index.linuxserver.io/ubuntu/ \
    piper-tts \
    "wyoming-piper==${PIPER_VERSION}" && \
  echo "**** cleanup ****" && \
  rm -rf \
    /var/lib/apt/lists/* \
    /tmp/*

COPY root /

VOLUME /config

EXPOSE 10200
