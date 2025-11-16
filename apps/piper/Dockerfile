
FROM ghcr.io/trueforge-org/python:3.13.7

# set version label
ARG VERSION
USER root

ENV TMPDIR="/run/piper-temp"

RUN python3 -m venv /lsiopy && \
  pip install -U --no-cache-dir \
    pip \
    wheel && \
  pip install -U --no-cache-dir --find-links https://wheel-index.linuxserver.io/ubuntu/ \
    piper-tts \
    "wyoming-piper==${VERSION}" && \
  echo "**** cleanup ****" && \
  rm -rf \
    /var/lib/apt/lists/* \
    /tmp/*

COPY root /

VOLUME /config

EXPOSE 10200
